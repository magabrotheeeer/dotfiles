-- colors/myblack.lua
-- Делает тему доступной через :colorscheme myblack

-- стандартная процедура для colorscheme
vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "myblack"

-- применяем наши хайлайты из lua/core/theme.lua
require("core.theme").setup()

