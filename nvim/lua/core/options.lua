local o = vim.opt
local g = vim.g

g.mapleader = ","          -- leader = Space

o.number = true
o.relativenumber = true

o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4

o.termguicolors = true
o.background = "dark"
o.cursorline = true
o.signcolumn = "yes"

o.wrap = false
o.scrolloff = 4
o.sidescrolloff = 4

o.splitright = true
o.splitbelow = true

o.ignorecase = true
o.smartcase = true

o.updatetime = 300
o.timeoutlen = 500

-- Буферы
o.hidden = true

-- Клипборд Windows
o.clipboard = "unnamedplus"

