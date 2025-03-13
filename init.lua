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
vim.g.mapleader = " "

-- Core settings (load early)
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.updatetime = 250
vim.opt.signcolumn = "yes"
vim.opt.background = "dark"
vim.opt.termguicolors = false
vim.g.have_nerd_font = true
vim.opt.wrap = true
vim.opt.hidden = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undofiles"
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.clipboard = "unnamedplus"

-- LSP on_attach function (defined once for reuse)
local on_attach = function(client, bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
  vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
end

-- Configure plugins with lazy.nvim
require("lazy").setup({
  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" }, -- Lazy load
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "rust", "go", "kotlin", "typescript", "javascript", "lua", "vim", "vimdoc", "svelte" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Enhanced f/t motions
  {
    "ggandor/leap.nvim",
    event = "VeryLazy", -- Defer loading
    config = function()
      require('leap').add_default_mappings()
    end,
  },

  -- Surround text objects
  {
    "kylechui/nvim-surround",
    event = "VeryLazy", -- Defer loading
    config = true,
  },

  -- Better quickfix list
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf", -- Only load when quickfix is opened
    config = true,
  },

  { "nvim-neotest/nvim-nio" },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy", -- Defer loading
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          component_separators = "|",
          section_separators = { left = "", right = "" },
        },
      })
    end,
  },

  {
    "j-hui/fidget.nvim",
    event = "LspAttach", -- Only load when LSP attaches
    config = function()
      require("fidget").setup({
        text = {
          spinner = "dots",
        },
        window = {
          relative = "win",
          blend = 0,
          zindex = 1,
        },
      })
    end,
  },

  -- Undo tree
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle", -- Only load when command runs
    keys = {
      { "<leader>u", ":UndotreeToggle<CR>", noremap = true, silent = true, desc = "Toggle undotree" }
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "VeryLazy", -- Defer loading
    opts = {
      indent = {
        char = ".",
      },
      scope = {
        show_start = false,
        show_end = false,
        highlight = "CursorColumn",
      },
      whitespace = {
        highlight = "CursorColumn",
      },
    },
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter", -- Only load in insert mode
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
        }),
      })
    end,
  },

  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" }, -- Lazy load
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "+" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
      })
    end,
  },

  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gstatus", "Gblame", "Gpush", "Gpull" }, -- Lazy load
    keys = {
      { "<leader>gs", ":Git<CR>",        noremap = true, silent = true, desc = "Git status" },
      { "<leader>gc", ":Git commit<CR>", noremap = true, silent = true, desc = "Git commit" },
      { "<leader>gp", ":Git push<CR>",   noremap = true, silent = true, desc = "Git push" },
    },
  },

  -- Fuzzy Finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope", -- Lazy load
    keys = {
      { "<leader>ff", ":Telescope find_files<CR>", noremap = true, silent = true, desc = "Find files" },
      { "<leader>fg", ":Telescope live_grep<CR>",  noremap = true, silent = true, desc = "Live grep" },
      { "<leader>fb", ":Telescope buffers<CR>",    noremap = true, silent = true, desc = "Buffers" },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { "^.git/", "node_modules" },
        },
      })
    end,
  },

  {
    "olimorris/persisted.nvim",
    event = "VimEnter", -- Load after Vim starts
    config = function()
      require("persisted").setup({
        save_dir = vim.fn.stdpath("data") .. "/sessions/",
        silent = true,
        autoload = true,
        on_autoload_no_session = function() end,
      })
    end,
  },

  -- File Explorer
  {
    "nvim-tree/nvim-tree.lua",
    cmd = "NvimTreeToggle", -- Only load when toggled
    keys = {
      { "<leader>e", ":NvimTreeToggle<CR>", noremap = true, silent = true, desc = "Toggle file tree" }
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30 },
        renderer = { group_empty = true },
        filters = { dotfiles = false },
      })
    end,
  },

  -- Theme
  { "tallestlegacy/darcula.nvim" },

  -- Utilities
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter", -- Only load in insert mode
    config = true,
  },

  {
    "numToStr/Comment.nvim",
    event = "VeryLazy", -- Defer loading
    config = true,
  },

  -- Formatter
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPre", "BufNewFile" }, -- Lazy load
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.formatting.gofmt,
          null_ls.builtins.formatting.rustfmt,
          null_ls.builtins.formatting.stylua,
        },
      })
    end,
  },

  {
    "glepnir/lspsaga.nvim",
    event = "LspAttach", -- Only load when LSP attaches
    config = function()
      require("lspsaga").setup({
        symbol_in_winbar = { enable = false },
        lightbulb = { enable = false },
      })
    end,
  },

  -- Markdown
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },


  -- Wakatime
  { "wakatime/vim-wakatime", event = "VeryLazy" }, -- Defer loading

  {
    "simrat39/rust-tools.nvim",
    ft = "rust", -- Only load for Rust files
  },

  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" }, -- Load before saving
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          rust = { "rustfmt" },
          go = { "gofmt" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
    end,
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy", -- Defer loading
    opts = {},
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
  },

  -- Session management
  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- Load after reading a buffer
    opts = {
      options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" }
    },
    keys = {
      { "<leader>ss", function() require("persistence").load() end,                desc = "Restore Session" },
      { "<leader>sl", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>sd", function() require("persistence").stop() end,                desc = "Don't Save Current Session" },
    },
  },

  -- Syntax highlighting for Kotlin
  {
    "udalov/kotlin-vim",
    ft = { "kotlin" }, -- Only load for Kotlin files
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" }, -- Lazy load
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "rust_analyzer", "gopls", "ts_ls", "lua_ls", "kotlin_language_server" },
      })

      require("mason-lspconfig").setup_handlers({
        function(server_name)
          require("lspconfig")[server_name].setup({
            on_attach = on_attach,
            capabilities = capabilities,
          })
        end,
        ["ts_ls"] = function()
          require("lspconfig").ts_ls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            root_dir = require("lspconfig.util").root_pattern("package.json",
              "tsconfig.json", "jsconfig.json"),
            single_file_support = false,
            filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
          })
        end,
        ["rust_analyzer"] = function()
          require("rust-tools").setup({
            server = {
              on_attach = on_attach,
              capabilities = capabilities,
              settings = {
                ["rust-analyzer"] = {
                  checkOnSave = {
                    command = "clippy",
                  },
                  imports = {
                    granularity = {
                      group = "module",
                    },
                    prefix = "self",
                  },
                },
              },
            },
          })
        end,
        ["gopls"] = function()
          require("lspconfig").gopls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
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
        end,
        ["kotlin_language_server"] = function()
          require("lspconfig").kotlin_language_server.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
              kotlin = {
                compiler = {
                  jvm = {
                    target = "17"
                  }
                },
                completion = {
                  snippets = {
                    enabled = true
                  }
                },
                hints = {
                  typeHints = true,
                  parameterHints = true,
                  chainCallHints = true
                },
                formatting = {
                  enabled = true
                },
                diagnostics = {
                  enabled = true
                },
                references = {
                  includeDecompiled = true
                }
              }
            }
          })
        end,
      })
    end,
  }
})

-- Set colorscheme
vim.cmd("colorscheme darcula")

-- Keymappings
local opts = { noremap = true, silent = true }

-- File navigation (already handled via lazy keys)

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", opts)
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", opts)
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", opts)

-- Quick commands
vim.keymap.set("n", "<leader>w", ":w<CR>", opts)
vim.keymap.set("n", "<leader>q", ":q<CR>", opts)
vim.keymap.set("n", "<leader>x", ":x<CR>", opts)
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', opts)


-- Insert mode shortcuts
vim.keymap.set("i", "jk", "<Esc>", opts)
vim.keymap.set("i", "kj", "<Esc>", opts)

-- Center cursor after vertical movements
vim.keymap.set("n", "j", "jzz", opts)
vim.keymap.set("n", "k", "kzz", opts)
vim.keymap.set("n", "<C-d>", "<C-d>zz", opts)
vim.keymap.set("n", "<C-u>", "<C-u>zz", opts)
vim.keymap.set("n", "n", "nzzzv", opts)

-- Auto-escape after new line
vim.keymap.set("n", "o", "o<Esc>", opts)
vim.keymap.set("n", "O", "O<Esc>", opts)

-- Disable arrow keys in normal mode
vim.keymap.set("n", "<Up>", "<Nop>", opts)
vim.keymap.set("n", "<Down>", "<Nop>", opts)
vim.keymap.set("n", "<Left>", "<Nop>", opts)
vim.keymap.set("n", "<Right>", "<Nop>", opts)

-- Session management (already handled via lazy keys)

-- Visual Mode
vim.keymap.set("v", "<", "<gv", opts) -- Indent left and stay in selection mode
vim.keymap.set("v", ">", ">gv", opts) -- Indent right and stay in selection mode

-- Key mappings for LSP (handled in on_attach function)

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Resize windows with arrows
vim.keymap.set("n", "<C-Up>", ":resize -2<CR>", opts)
vim.keymap.set("n", "<C-Down>", ":resize +2<CR>", opts)
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", opts)
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Move text up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", opts)
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", opts)

-- Keep cursor in place when joining lines
vim.keymap.set("n", "J", "mzJ`z", opts)

-- Clear search highlights
vim.keymap.set("n", "<leader>nh", ":nohlsearch<CR>", opts)

vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, { desc = "Code Lens" })

-- Markdown preview

vim.keymap.set("n", "<leader>mm", ":MarkdownPreviewToggle<CR>", opts)

-- Toggle relative line numbers
function _G.toggle_relative_number()
  vim.wo.relativenumber = not vim.wo.relativenumber
end

vim.keymap.set("n", "<leader>tr", ":lua toggle_relative_number()<CR>", opts)

-- Save and source current file
vim.keymap.set("n", "<leader>so", ":w<CR>:source %<CR>", opts)

-- Create new file function
local function create_new_file()
  local new_file = vim.fn.input("New file: ")
  if new_file ~= "" then
    vim.cmd("edit " .. new_file)
  end
end

-- Set up diagnostic signs
local signs = { Error = "✗", Warn = "!", Hint = "➤", Info = "ℹ" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

vim.keymap.set("n", "<leader>nf", create_new_file, { desc = "Create new file" })

-- Format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.c", "*.rs", "*.go", "*.ts", "*.tsx", "*.js", "*.py", "*.html" },
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})
