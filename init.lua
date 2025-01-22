-- Install lazy.nvim if not already installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Define leader key before lazy setup
vim.g.mapleader = ' '

-- Configure plugins with lazy.nvim
require("lazy").setup({
  -- Treesitter for better syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { "c", "rust", "go", "typescript", "javascript", "lua", "vim", "vimdoc", "svelte", "dart" },
        highlight = { enable = true },
        indent = { enable = true }
      }
    end
  },

  -- Undo tree
  {
    'mbbill/undotree',
    config = function()
      vim.keymap.set('n', '<leader>u', ':UndotreeToggle<CR>', { noremap = true, silent = true })
    end
  },

  -- Snippets
  {
    'rafamadriz/friendly-snippets',
    dependencies = { 'L3MON4D3/LuaSnip' },
  },

  -- Git integration
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({
        signs = {
          add          = { text = '+' },
          change       = { text = '│' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
      })
    end
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

  -- Theme
  {
    'Shatur/neovim-ayu',
    lazy = false,
    priority = 1000,
    config = function()
      require('ayu').setup({
        mirage = false,
        overrides = {
          LineNr = { fg = "#964B00" },  -- brown
        }
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

  -- Formatter
  {
    'sbdchd/neoformat',
    config = function()
      vim.g.neoformat_enabled_go = {'gofumpt', 'goimports'}
      vim.g.neoformat_enabled_rust = {'rustfmt'}
      vim.g.neoformat_enabled_typescript = {'prettier', 'eslint_d'}
      vim.g.neoformat_enabled_javascript = {'prettier', 'eslint_d'}
      vim.g.neoformat_enabled_python = {'black'}
      vim.g.neoformat_enabled_c = {'clang-format'}
    end
  },

  -- Markdown preview
  {
    "toppair/peek.nvim",
    event = { "VeryLazy" },
    build = "deno task --quiet build:fast",
    config = function()
      require("peek").setup()
      vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
      vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end,
  },

  -- Wakatime
  'wakatime/vim-wakatime',

  -- coc.nvim for LSP
  {
    'neoclide/coc.nvim',
    branch = 'release',
    lazy = false,
  },
})

-- General settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.updatetime = 300
vim.opt.signcolumn = 'yes'
vim.opt.background = 'dark'
vim.opt.termguicolors = true

-- Keymappings
local opts = { noremap = true, silent = true }

-- File navigation
vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>', opts)
vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>', opts)
vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>', opts)

-- File tree
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', opts)

-- Buffer navigation
vim.keymap.set('n', '<leader>bn', ':bnext<CR>', opts)
vim.keymap.set('n', '<leader>bp', ':bprevious<CR>', opts)
vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', opts)

-- Quick commands
vim.keymap.set('n', '<leader>w', ':w<CR>', opts)
vim.keymap.set('n', '<leader>q', ':q<CR>', opts)
vim.keymap.set('n', '<leader>x', ':wq<CR>', opts)
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', opts)

-- Markdown preview
vim.keymap.set('n', '<leader>po', ':PeekOpen', opts)
vim.keymap.set('n', '<leader>pc', ':PeekClose', opts)

-- Insert mode shortcuts
vim.keymap.set('i', 'jj', '<Esc>', opts)

-- Center screen after vertical movements
vim.keymap.set('n', 'j', 'jzz', opts)
vim.keymap.set('n', 'k', 'kzz', opts)

-- Auto-escape after new line
vim.keymap.set('n', 'o', 'o<Esc>', opts)
vim.keymap.set('n', 'O', 'O<Esc>', opts)

-- Undo tree keymapping
vim.keymap.set('n', '<leader>u', ':UndotreeToggle<CR>', opts)

-- coc.nvim keybindings
vim.keymap.set('n', 'gd', '<Plug>(coc-definition)', opts)
vim.keymap.set('n', 'gr', '<Plug>(coc-references)', opts)
vim.keymap.set('n', 'K', ':call CocActionAsync("doHover")<CR>', opts)
vim.keymap.set('n', '<leader>rn', '<Plug>(coc-rename)', opts)
vim.keymap.set('n', '<leader>ca', '<Plug>(coc-codeaction)', opts)
vim.keymap.set('n', '<leader>f', ':call CocAction("format")<CR>', opts)

-- Format on save
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = {'*.c', '*.rs', '*.go', '*.ts', '*.tsx', '*.js' ,'*.py', '*.html', '*.dart'},
  callback = function()
    vim.cmd('call CocAction("format")')
    vim.cmd('Neoformat')
  end
})
