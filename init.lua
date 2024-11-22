-- Install lazy.nvim if not already installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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

-- Configure plugins with lazy.nvim
require("lazy").setup({
  -- Essential plugins
  'tpope/vim-sensible',
  
  -- Treesitter for better syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter', 
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { "c", "rust", "go", "typescript", "javascript", "lua", "vim", "vimdoc" },
        highlight = { enable = true },
        indent = { enable = true }
      }
    end
  },
  
  -- LSP Configuration
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = { 'rust_analyzer', 'gopls', 'ts_ls' }
      })
      
      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      
      -- Setup language servers
      lspconfig.rust_analyzer.setup { capabilities = capabilities }
      lspconfig.gopls.setup { capabilities = capabilities }
      lspconfig.ts_ls.setup { capabilities = capabilities }
    end
  },
  
  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
        })
      })
    end
  },
  
  -- Git integration
  {
    'tpope/vim-fugitive',
    'lewis6991/gitsigns.nvim',
    config = true
  },
  
  -- Fuzzy Finder
  {
    'nvim-telescope/telescope.nvim', 
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup{
        defaults = {
          file_ignore_patterns = { "^.git/", "node_modules" }
        }
      }
    end
  },
  
  -- File Explorer
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30 },
        renderer = { group_empty = true },
        filters = { dotfiles = false }
      })
    end
  },
  
  -- Status Line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup {
        options = {
          theme = 'auto',
          component_separators = '|',
          section_separators = { left = '', right = '' },
        }
      }
    end
  },
  
  -- Themes
{
  'Shatur/neovim-ayu',
  lazy = false,
  priority = 1000,
  config = function()
    require('ayu').setup({
      mirage = false,
      overrides = {}
    })
    vim.cmd('colorscheme ayu-dark')
  end
}, 

  
  -- Utilities
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
  },
  
  {
    'numToStr/Comment.nvim',
    config = true
  },
  
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    config = true
  },
  
  -- Which Key
  {
    'folke/which-key.nvim',
    config = function()
      require('which-key').setup{}
    end
  },
  
  -- Add Neoformat plugin for formatting
{
  'sbdchd/neoformat',
  config = function()
    -- Formatters for specific languages
    vim.g.neoformat_enabled_go = {'gofumpt', 'goimports'}
    vim.g.neoformat_enabled_rust = {'rustfmt'}
    vim.g.neoformat_enabled_typescript = {'prettier', 'eslint_d'}
  end
},
  
  -- Wakatime
  'wakatime/vim-wakatime'
})

-- Keymappings
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Leader key
vim.g.mapleader = ' '

-- File navigation
keymap('n', '<leader>ff', ':Telescope find_files<CR>', opts)
keymap('n', '<leader>fg', ':Telescope live_grep<CR>', opts)
keymap('n', '<leader>fb', ':Telescope buffers<CR>', opts)

-- File tree
keymap('n', '<leader>e', ':NvimTreeToggle<CR>', opts)

-- Buffer navigation
keymap('n', '<leader>bn', ':bnext<CR>', opts)
keymap('n', '<leader>bp', ':bprevious<CR>', opts)
keymap('n', '<leader>bd', ':bdelete<CR>', opts)

-- LSP mappings
keymap('n', 'gd', vim.lsp.buf.definition, opts)
keymap('n', 'K', vim.lsp.buf.hover, opts)
keymap('n', '<leader>ca', vim.lsp.buf.code_action, opts)
keymap('n', '<leader>rn', vim.lsp.buf.rename, opts)

-- Diagnostic mappings
keymap('n', '<leader>df', vim.diagnostic.open_float, opts)
keymap('n', '[d', vim.diagnostic.goto_prev, opts)
keymap('n', ']d', vim.diagnostic.goto_next, opts)

-- Terminal mappings
keymap('n', '<leader>tt', ':terminal<CR>', opts)
keymap('t', '<Esc>', '<C-\\><C-n>', opts)

-- Additional settings
vim.opt.number = true           -- Show line numbers
vim.opt.relativenumber = true   -- Show relative line numbers
vim.opt.expandtab = true        -- Use spaces instead of tabs
vim.opt.tabstop = 2             -- Number of spaces a tab counts for
vim.opt.softtabstop = 2         -- Number of spaces to insert/delete when editing
vim.opt.shiftwidth = 2          -- Number of spaces to use for each step of autoindent
vim.opt.smartindent = true      -- Smart autoindenting when starting a new line

-- Existing keymappings
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Add or update write file mapping
keymap('n', '<leader>w', ':w<CR>', opts)
keymap('n', '<leader>x', ':wq<CR>', opts)

-- Existing and additional file-related mappings
keymap('n', '<leader>q', ':q<CR>', opts)
keymap('n', '<leader>e', ':e<CR>', opts)

-- Quick escape in insert mode (like your previous jj mapping)
keymap('i', 'jj', '<Esc>', opts)

-- Center screen after vertical movements
keymap('n', 'j', 'jzz', opts)
keymap('n', 'k', 'kzz', opts)

-- Auto-escape after new line (like your previous mapping)
keymap('n', 'o', 'o<Esc>', opts)
keymap('n', 'O', 'O<Esc>', opts)

-- Additional comfort settings
vim.opt.ignorecase = true       -- Case-insensitive searching
vim.opt.smartcase = true        -- Case-sensitive if mix case in search
vim.opt.hlsearch = false        -- Don't highlight search results
vim.opt.updatetime = 250        -- Faster update time
vim.opt.signcolumn = 'yes'      -- Always show sign column

-- Diagnostic configuration
vim.diagnostic.config({
  virtual_text = { prefix = '● ' },
  float = { 
    source = 'always', 
    border = 'rounded' 
  },
  signs = true,
  underline = true,
  update_in_insert = false,
})

-- Auto format on save for specific languages
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = {'*.go', '*.rs', '*.ts', '*.tsx', '*.js', '*.html', '*.json'},
  callback = function()
    vim.cmd('Neoformat')
  end
})
