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
  -- Essential plugins
  'tpope/vim-sensible',
  
  -- Treesitter for better syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter', 
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { "c", "rust", "go", "typescript", "javascript", "lua", "vim", "vimdoc", "svelte" },
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
      -- Define on_attach function
      local on_attach = function(client, bufnr)
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
        vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
      end

      -- Setup Mason
      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = { 'rust_analyzer', 'gopls', 'ts_ls', 'denols', 'pyright'  }
      })
      
      -- Get LSP capabilities
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local lspconfig = require('lspconfig')
      -- Function to safely setup LSP servers
      local function safe_setup(server_name, config)
      local success, err = pcall(function()
        lspconfig[server_name].setup(config)
      end)
      if not success then
        -- Suppress error messages for missing language servers
        vim.notify("LSP server " .. server_name .. " not found: " .. err, vim.log.levels.WARN, { title = "LSP Setup" })
      end 
      end
      
      -- Deno LSP setup
      lspconfig.denols.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
        init_options = {
          lint = true,
          unstable = true,
          suggest = {
            imports = {
              hosts = {
                ["https://deno.land"] = true,
                ["https://cdn.nest.land"] = true,
                ["https://crux.land"] = true,
              },
            },
          },
        },
        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "json" },
      })

      -- TypeScript LSP setup
      lspconfig.ts_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json"),
        single_file_support = false,
        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
      })

      -- Rust LSP setup
      lspconfig.rust_analyzer.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          ['rust-analyzer'] = {
            checkOnSave = {
              command = "clippy",
            },
            imports = {
              granularity = {
                group = "module",
              },
              prefix = "self",
            },
          }
        }
      })

      -- Go LSP setup
      lspconfig.gopls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
            gofumpt = true,
          },
        },
      })
  
    lspconfig.pyright.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "basic",
            diagnosticSeverityOverrides = {
              reportUnknownMemberType = "none",
              reportUnknownParameterType = "none",
              reportUnknownVariableType = "none",
              reportUnknownArgumentType = "none",
            }
          }
      }
    }
  })
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
    }
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
  
  -- Formatter
  {
    'sbdchd/neoformat',
    config = function()
      vim.g.neoformat_enabled_go = {'gofumpt', 'goimports'}
      vim.g.neoformat_enabled_rust = {'rustfmt'}
      vim.g.neoformat_enabled_typescript = {'prettier', 'eslint_d'}
      vim.g.neoformat_enabled_javascript = {'prettier', 'eslint_d'}
      vim.g.neoformat_enabled_html = {'prettier'}
      vim.g.neoformat_enabled_python = {'black'}
    end
  },
  
  -- markdown preview 
  {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = "cd app && yarn install",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  ft = { "markdown" },

   },

  -- Wakatime
  'wakatime/vim-wakatime'
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
vim.opt.updatetime = 250
vim.opt.signcolumn = 'yes'

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

-- Insert mode shortcuts
vim.keymap.set('i', 'jj', '<Esc>', opts)

-- Center screen after vertical movements
vim.keymap.set('n', 'j', 'jzz', opts)
vim.keymap.set('n', 'k', 'kzz', opts)

-- Auto-escape after new line
vim.keymap.set('n', 'o', 'o<Esc>', opts)
vim.keymap.set('n', 'O', 'O<Esc>', opts)

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

-- Format on save
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = {'*.rs', '*.go', '*.ts', '*.tsx', '*.js' ,'*.py', '*.html'},
  callback = function()
    vim.lsp.buf.format({ async = false })
    vim.cmd('Neoformat')
  end
})

-- Handle Deno vs Node projects
vim.api.nvim_create_autocmd("BufRead", {
  pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
  callback = function(ctx)
    local root = vim.fn.findfile("deno.json", ".;")
    if root == "" then
      root = vim.fn.findfile("deno.jsonc", ".;")
    end
    
    if root ~= "" then
      vim.cmd([[set filetype=denots]])
    end
  end,
})

