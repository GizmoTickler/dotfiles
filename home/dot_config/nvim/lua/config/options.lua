-- Neovim Options Configuration
-- Sensible defaults for modern development

local opt = vim.opt

-- General
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.undofile = true
opt.updatetime = 250
opt.timeoutlen = 300
opt.conceallevel = 0

-- UI
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.cursorline = true
opt.termguicolors = true
opt.background = "dark"
opt.pumheight = 10
opt.showmode = false
opt.showcmd = true
opt.cmdheight = 1
opt.laststatus = 3
opt.splitbelow = true
opt.splitright = true

-- Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true
opt.breakindent = true

-- Search
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Completion
opt.completeopt = "menu,menuone,noselect"

-- Folding
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

-- Performance
opt.lazyredraw = true
opt.synmaxcol = 240

-- Wildmenu
opt.wildmenu = true
opt.wildmode = "longest:full,full"
opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.git/*", "node_modules/*" })

-- Format options
opt.formatoptions:remove({ "c", "r", "o" })

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable netrw in favor of file explorers
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1