vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
vim.g.colors_name = "gray-mono"
vim.o.termguicolors = true

-- Palette from config/shared/kitty/mocha.conf
local c = {
  bg      = "#1a1a1a",
  fg      = "#e0e0e0",
  sel_bg  = "#d0d0d0",
  sel_fg  = "#1a1a1a",
  comment = "#505050",
  muted   = "#666666",
  mid     = "#808080",
  mid2    = "#888888",
  soft    = "#a0a0a0",
  bright  = "#b0b0b0",
  light   = "#d0d0d0",
  white   = "#ffffff",
  red     = "#cc6666",
}

local hl = function(name, opts) vim.api.nvim_set_hl(0, name, opts) end

-- Editor chrome
hl("Normal",          { fg = c.fg,     bg = c.bg })
hl("NormalNC",        { fg = c.fg,     bg = c.bg })
hl("NormalFloat",     { fg = c.fg,     bg = "#222222" })
hl("FloatBorder",     { fg = c.mid,    bg = "#222222" })
hl("Cursor",          { fg = c.bg,     bg = c.light })
hl("CursorLine",      { bg = "#222222" })
hl("CursorLineNr",    { fg = c.light,  bold = true })
hl("LineNr",          { fg = c.comment })
hl("SignColumn",      { fg = c.mid,    bg = c.bg })
hl("ColorColumn",     { bg = "#222222" })
hl("Visual",          { fg = c.sel_fg, bg = c.sel_bg })
hl("Search",          { fg = c.sel_fg, bg = c.soft })
hl("IncSearch",       { fg = c.sel_fg, bg = c.light, bold = true })
hl("StatusLine",      { fg = c.fg,     bg = "#252525" })
hl("StatusLineNC",    { fg = c.mid,    bg = "#1e1e1e" })
hl("WinSeparator",    { fg = c.comment })
hl("Pmenu",           { fg = c.fg,     bg = "#222222" })
hl("PmenuSel",        { fg = c.sel_fg, bg = c.sel_bg })
hl("PmenuSbar",       { bg = "#252525" })
hl("PmenuThumb",      { bg = c.mid })
hl("EndOfBuffer",     { fg = c.comment })
hl("MatchParen",      { fg = c.white,  bold = true, underline = true })
hl("NonText",         { fg = c.comment })
hl("SpecialKey",      { fg = c.comment })
hl("Folded",          { fg = c.soft,   bg = "#222222" })
hl("FoldColumn",      { fg = c.comment, bg = c.bg })
hl("TabLine",         { fg = c.soft,   bg = c.comment })
hl("TabLineSel",      { fg = c.sel_fg, bg = c.light })
hl("TabLineFill",     { bg = c.bg })

-- Syntax
hl("Comment",         { fg = c.mid,    italic = true })
hl("Constant",        { fg = c.light })
hl("String",          { fg = c.bright })
hl("Character",       { fg = c.bright })
hl("Number",          { fg = c.soft })
hl("Boolean",         { fg = c.soft })
hl("Float",           { fg = c.soft })
hl("Identifier",      { fg = c.fg })
hl("Function",        { fg = c.white,  bold = true })
hl("Statement",       { fg = c.light })
hl("Keyword",         { fg = c.light,  bold = true })
hl("Operator",        { fg = c.mid2 })
hl("PreProc",         { fg = c.soft })
hl("Type",            { fg = c.bright })
hl("Special",         { fg = c.mid2 })
hl("Underlined",      { underline = true })
hl("Error",           { fg = c.red,    bold = true })
hl("Todo",            { fg = c.sel_fg, bg = c.soft, bold = true })

-- Diagnostics
hl("DiagnosticError",          { fg = c.red })
hl("DiagnosticWarn",           { fg = c.soft })
hl("DiagnosticInfo",           { fg = c.mid2 })
hl("DiagnosticHint",           { fg = c.mid })
hl("DiagnosticUnderlineError", { sp = c.red,  underline = true })
hl("DiagnosticUnderlineWarn",  { sp = c.soft, underline = true })

-- Git signs
hl("GitSignsAdd",    { fg = c.soft })
hl("GitSignsChange", { fg = c.mid2 })
hl("GitSignsDelete", { fg = c.red })

-- Treesitter
hl("@comment",     { link = "Comment" })
hl("@string",      { link = "String" })
hl("@keyword",     { link = "Keyword" })
hl("@function",    { link = "Function" })
hl("@type",        { link = "Type" })
hl("@variable",    { fg = c.fg })
hl("@property",    { fg = c.bright })
hl("@punctuation", { fg = c.mid })
hl("@operator",    { link = "Operator" })
hl("@constant",    { link = "Constant" })
hl("@number",      { link = "Number" })
hl("@boolean",     { link = "Boolean" })
