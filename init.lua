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

-- Core settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = false
vim.opt.wrap = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.undofile = true
vim.opt.scrolloff = 8
-- vim.opt.clipboard = "unnamedplus"

-- LSP on_attach function
local on_attach = function(client, bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
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
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "lua", "vim", "vimdoc" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Theme
  { "tallestlegacy/darcula.nvim" },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
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

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls" },
      })

      require("mason-lspconfig").setup_handlers({
        function(server_name)
          require("lspconfig")[server_name].setup({
            on_attach = on_attach,
            capabilities = capabilities,
          })
        end,
      })
    end,
  },

  -- Fuzzy Finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
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
})

-- Set colorscheme
vim.cmd("colorscheme darcula")

-- Keymappings
local opts = { noremap = true, silent = true }

-- Quick commands
vim.keymap.set("n", "<leader>w", ":w<CR>", opts)
vim.keymap.set("n", "<leader>q", ":q<CR>", opts)
vim.keymap.set("n", "<leader>x", ":x<CR>", opts)
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', opts)

-- Insert mode shortcuts
vim.keymap.set("i", "jk", "<Esc>", opts)
vim.keymap.set("i", "kj", "<Esc>", opts)

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Clear search highlights
vim.keymap.set("n", "<leader>nh", ":nohlsearch<CR>", opts)

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
-- vim.keymap.set("n", "<Up>", "<Nop>", opts)
-- vim.keymap.set("n", "<Down>", "<Nop>", opts)
-- vim.keymap.set("n", "<Left>", "<Nop>", opts)
-- vim.keymap.set("n", "<Right>", "<Nop>", opts)

-- Session management (already handled via lazy keys)

-- Visual Mode
vim.keymap.set("v", "<", "<gv", opts) -- Indent left and stay in selection mode
vim.keymap.set("v", ">", ">gv", opts) -- Indent right and stay in selection mode

-- Set up diagnostic signs
local signs = { Error = "✗", Warn = "!", Hint = "➤", Info = "ℹ" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- Format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.c", "*.rs", "*.go", "*.ts", "*.tsx", "*.js", "*.py", "*.html" },
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Create new file function
local function create_new_file()
  local new_file = vim.fn.input("New file: ")
  if new_file ~= "" then
    vim.cmd("edit " .. new_file)
  end
end

vim.keymap.set("n", "<leader>nf", create_new_file, { desc = "Create new file" })
