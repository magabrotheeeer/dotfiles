-- lua/core/theme.lua
local M = {}

local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local colors = {
  bg     = "#000000",
  bg2    = "#101010",

  white  = "#FFFFFF",  -- основной код
  violet = "#AA55FF",  -- структура языка, функции/типы/методы
  green  = "#00FF00",  -- строки
  red    = "#FF3333",  -- числа/константы/ошибки
}

M.colors = colors

function M.setup()
  ----------------------------------------------------------------
  -- БАЗА
  ----------------------------------------------------------------
  hl("Normal",       { fg = colors.white, bg = colors.bg })
  hl("NormalFloat",  { fg = colors.white, bg = colors.bg })
  hl("LineNr",       { fg = "#555555" })
  hl("CursorLineNr", { fg = colors.white, bold = true })
  hl("CursorLine",   { bg = colors.bg2 })
  hl("VertSplit",    { fg = "#303030" })

  hl("Visual",       { bg = "#333333" })

  -- комментарии серые, чтобы не шумели
  hl("Comment",      { fg = "#777777", italic = true })

  ----------------------------------------------------------------
  -- КОД: ТОЛЬКО 4 ЦВЕТА
  ----------------------------------------------------------------
  -- основной код: переменные, имена полей и т.п.
  hl("Identifier",   { fg = colors.white })

  -- строки
  hl("String",       { fg = colors.green })

  -- числа / константы / булевые
  hl("Number",       { fg = colors.red })
  hl("Boolean",      { fg = colors.red, bold = true })
  hl("Constant",     { fg = colors.red })

  -- структура языка (ВСЁ, что “языковое”)
  hl("Keyword",      { fg = colors.violet, bold = true })
  hl("Statement",    { fg = colors.violet, bold = true })
  hl("Conditional",  { fg = colors.violet, bold = true })  -- if, switch
  hl("Repeat",       { fg = colors.violet, bold = true })  -- for, while
  hl("Operator",     { fg = colors.violet })               -- &&, ||, :=, == и т.п.
  hl("Exception",    { fg = colors.violet, bold = true })  -- try/catch/throw
  hl("Include",      { fg = colors.violet, bold = true })  -- import, package, #include
  hl("PreProc",      { fg = colors.violet })               -- preprocessor stuff

  -- типы и объявления типов
  hl("Type",         { fg = colors.violet })
  hl("StorageClass", { fg = colors.violet })               -- class, struct, interface и т.п.
  hl("Structure",    { fg = colors.violet })

  -- функции/методы:
  hl("Function",              { fg = colors.violet, bold = true })
  hl("@function",             { fg = colors.violet, bold = true })
  hl("@function.builtin",     { fg = colors.violet, bold = true })
  hl("@method",               { fg = colors.violet, italic = true })
  hl("@function.method",      { fg = colors.violet, italic = true })
  hl("@property",             { fg = colors.white })  -- поля/свойства оставим белыми

  ----------------------------------------------------------------
  -- LSP диагностика (ошибки и предупреждения)
  ----------------------------------------------------------------
  hl("DiagnosticError", { fg = colors.red })
  hl("DiagnosticWarn",  { fg = colors.red })
  hl("DiagnosticInfo",  { fg = colors.white })
  hl("DiagnosticHint",  { fg = colors.white })

  hl("DiagnosticUnderlineError", { undercurl = true, sp = colors.red })
  hl("DiagnosticUnderlineWarn",  { undercurl = true, sp = colors.red })

  ----------------------------------------------------------------
  -- Git-индикаторы (gitsigns + nvim-tree)
  ----------------------------------------------------------------
  hl("GitSignsAdd",    { fg = colors.green })
  hl("GitSignsChange", { fg = colors.violet })
  hl("GitSignsDelete", { fg = colors.red })

  hl("NvimTreeGitDirty",   { fg = colors.violet })
  hl("NvimTreeGitStaged",  { fg = colors.green })
  hl("NvimTreeGitNew",     { fg = colors.green })
  hl("NvimTreeGitDeleted", { fg = colors.red })
  hl("NvimTreeGitRenamed", { fg = colors.violet })

  ----------------------------------------------------------------
  -- Статус-лайн
  ----------------------------------------------------------------
  hl("StatusLine",   { fg = colors.bg, bg = colors.white, bold = true })
  hl("StatusLineNC", { fg = "#222222", bg = "#888888" })

  ----------------------------------------------------------------
  -- Поиск
  ----------------------------------------------------------------
  hl("Search",       { fg = colors.bg, bg = colors.red })
  hl("IncSearch",    { fg = colors.bg, bg = colors.violet })

  ----------------------------------------------------------------
  -- nvim-cmp (меню автодополнения) в те же цвета
  ----------------------------------------------------------------
  hl("Pmenu",                 { fg = colors.white, bg = colors.bg2 })
  hl("PmenuSel",              { fg = colors.bg,    bg = colors.violet })
  hl("CmpItemAbbr",           { fg = colors.white })
  hl("CmpItemAbbrMatch",      { fg = colors.violet, bold = true })
  hl("CmpItemAbbrMatchFuzzy", { fg = colors.violet })
  hl("CmpItemKind",           { fg = colors.violet })
  hl("CmpItemMenu",           { fg = colors.green })
end

return M

