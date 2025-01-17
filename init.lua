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

  { "nvim-neotest/nvim-nio" },
  
  -- Undo tree
  {
    'mbbill/undotree',
    config = function()
      vim.keymap.set('n', '<leader>u', ':UndotreeToggle<CR>', { noremap = true, silent = true })
    end
  },

  {
  'rafamadriz/friendly-snippets',
  dependencies = { 'L3MON4D3/LuaSnip' },
},

  {
  'mfussenegger/nvim-dap',
  dependencies = { 'rcarriga/nvim-dap-ui' },
  config = function()
    require('dap-python').setup('~/.virtualenvs/debugpy/bin/python')
    require('dapui').setup()
  end
},
{
  'mfussenegger/nvim-dap-python',
  dependencies = { 'mfussenegger/nvim-dap' },
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
      ensure_installed = { 'clangd', 'rust_analyzer', 'gopls', 'ts_ls', 'denols', 'pyright' }
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
      
        -- clangd 
          lspconfig.clangd.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      cmd = { "clangd", "--background-index", "--clang-tidy" },
      init_options = {
        clangdFileStatus = true,
      },
      filetypes = { "c", "cpp", "objc", "objcpp" },
    })

        
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

      -- python 
      lspconfig.pyright.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
      },
    },
  },
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
  
  -- Formatter
  {
    'sbdchd/neoformat',
    config = function()
      vim.g.neoformat_enabled_go = {'gofumpt', 'goimports'}
      vim.g.neoformat_enabled_rust = {'rustfmt'}
      vim.g.neoformat_enabled_typescript = {'prettier', 'eslint_d'}
      vim.g.neoformat_enabled_javascript = {'prettier', 'eslint_d'}
      vim.g.neoformat_enabled_python = {'black'}
      vim.g.neoformat_enabled_c = {'clangd'}
    end
  },
  
  -- markdown preview 
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

    --
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
vim.opt.background = 'dark'

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
-- map leader+y to copy to system clipboard in normal and visual mode
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { noremap = true, silent = true })

-- markdown preview 
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

local function create_new_file()
  local new_file = vim.fn.input("New file: ")
  if new_file ~= "" then
    vim.cmd("edit " .. new_file)
  end
end

local signs = { Error = "✗", Warn = "!", Hint = "➤", Info = "ℹ" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end


vim.keymap.set("n", "<leader>nf", create_new_file, { desc = "Create new file" })

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
  pattern = {'*.c', '*.rs', '*.go', '*.ts', '*.tsx', '*.js' ,'*.py', '*.html'},
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

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt.expandtab = true
    vim.opt.tabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.softtabstop = 4
  end
})

-- Function to create a floating terminal
local function create_float_term()
    -- Calculate dimensions
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    
    -- Calculate starting position
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    
    -- Create the floating window
    local opts = {
        relative = 'editor',
        row = row,
        col = col,
        width = width,
        height = height,
        style = 'minimal',
        border = 'rounded'
    }
    
    -- Create buffer for terminal
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, opts)
    
    -- Spawn terminal
    vim.fn.termopen(vim.o.shell, {
        on_exit = function()
            vim.api.nvim_win_close(win, true)
        end
    })
    
    -- Enter insert mode
    vim.cmd('startinsert')
    
    -- Add mappings for this terminal buffer
    local opts_term = { buffer = buf, noremap = true, silent = true }
    vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], opts_term)
    vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-W>h]], opts_term)
    vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-W>j]], opts_term)
    vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-W>k]], opts_term)
    vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-W>l]], opts_term)
end

-- Add the keymapping for the terminal
vim.keymap.set('n', '<leader>tt', create_float_term, { noremap = true, silent = true, desc = "Toggle floating terminal" })-- Function to create a floating terminal
local function create_float_term()
    -- Calculate dimensions
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    
    -- Calculate starting position
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    
    -- Create the floating window
    local opts = {
        relative = 'editor',
        row = row,
        col = col,
        width = width,
        height = height,
        style = 'minimal',
        border = 'rounded'
    }
    
    -- Create buffer for terminal
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, opts)
    
    -- Spawn terminal
    vim.fn.termopen(vim.o.shell, {
        on_exit = function()
            vim.api.nvim_win_close(win, true)
        end
    })
    
    -- Enter insert mode
    vim.cmd('startinsert')
    
    -- Add mappings for this terminal buffer
    local opts_term = { buffer = buf, noremap = true, silent = true }
    vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], opts_term)
    vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-W>h]], opts_term)
    vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-W>j]], opts_term)
    vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-W>k]], opts_term)
    vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-W>l]], opts_term)
end

-- Add the keymapping for the terminal
vim.keymap.set('n', '<leader>tt', create_float_term, { noremap = true, silent = true, desc = "Toggle floating terminal" })
