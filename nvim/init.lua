-- Settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.scrolloff = 8
vim.opt.updatetime = 50
vim.diagnostic.config {
    virtual_text = true,
    severity_sort = true,
}

-- Remaps
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>e", vim.cmd.Ex)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set('n', '<leader>q', function() vim.lsp.buf.hover() end)
vim.keymap.set('n', '<leader>gd', function() vim.lsp.buf.definition() end)
vim.keymap.set('n', '<leader>a', function() vim.lsp.buf.code_action() end)

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require 'nvim-treesitter.configs'.setup {
                sync_install = false,
                auto_install = true,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
            }
        end
    },
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true
    },
    -- {
    --     "L3MON4D3/LuaSnip",
    --     version = "v2.*",
    --     build = "make install_jsregexp"
    -- },
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
    "RRethy/vim-illuminate",
    "stevearc/dressing.nvim",
    "bluz71/vim-moonfly-colors",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-vsnip",
    "hrsh7th/vim-vsnip",
    "hrsh7th/vim-vsnip-integ",
}

-- Telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', builtin.find_files, {})
vim.keymap.set('n', '<leader>gf', builtin.live_grep, {});

-- Color scheme
vim.cmd.colorscheme("moonfly")

-- Illuminate
require('illuminate').configure {
    providers = {
        'lsp',
        'treesitter',
        'regex',
    },
    delay = 100,
    under_cursor = true,
    min_count_to_highlight = 2,
}

require("mason").setup()
require("mason-lspconfig").setup()


-- Format on save
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp", { clear = true }),
    callback = function(args)
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = args.buf,
            callback = function()
                vim.lsp.buf.format { async = false, id = args.data.client_id }
            end,
        })
    end
})

-- Completion
local cmp = require 'cmp'
cmp.setup {
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<Esc>'] = cmp.mapping.abort(),
        ['<Tab>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = {
        { name = 'nvim_lsp' },
        { name = 'vsnip' },
        { name = 'path' },
        { name = 'buffer' },
    }
}

local caps = require('cmp_nvim_lsp').default_capabilities()

local lsp = require 'lspconfig'
lsp.veridian.setup {
    root_dir = function() return vim.loop.cwd() end,
    capabilities = caps,
}
lsp.verible.setup {
    root_dir = function() return vim.loop.cwd() end,
    capabilities = caps,
}
lsp.mesonlsp.setup {
    root_dir = function() return vim.loop.cwd() end,
    capabilities = caps,
}
lsp.zls.setup { capabilities = caps }
lsp.clangd.setup { capabilities = caps }
lsp.pyright.setup { capabilities = caps }
lsp.rust_analyzer.setup { capabilities = caps }
lsp.lua_ls.setup {
    on_init = function(client)
        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = { version = 'LuaJIT' },
            workspace = {
                checkThirdParty = false,
                library = vim.api.nvim_get_runtime_file("", true)
            }
        })
    end,
    settings = {
        Lua = {}
    },
    capabilities = caps,
}
