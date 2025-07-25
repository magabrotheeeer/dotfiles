" Basic settings
filetype plugin indent on
syntax on
set mouse=
set encoding=utf-8
set nobackup
set nowritebackup
set noswapfile
set updatetime=300
set signcolumn=yes

" Search settings
set incsearch
set hlsearch
set smartcase
set ignorecase

" Line numbers
set number
set relativenumber

" Tabs and indentation
set tabstop=4
set shiftwidth=4
set softtabstop=2
set noexpandtab
set ai

" UI settings
set linebreak
set list
set wrap
set background=dark
highlight Cursorline cterm=bold
highlight LineNr guifg=Yellow ctermfg=Yellow
highlight CursorLineNr guifg=Purple ctermfg=magenta

" Keyboard layout
set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz

" Plugins
call plug#begin('~/.config/nvim/plugged')
" LSP and completion
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/vim-vsnip'
Plug 'jiangmiao/auto-pairs'

" UI and navigation
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvimdev/lspsaga.nvim'
Plug 'ray-x/lsp_signature.nvim'
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'lewis6991/gitsigns.nvim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Language specific
Plug 'ray-x/go.nvim'
Plug 'ray-x/guihua.lua'
Plug 'cdelledonne/vim-cmake'

" Terminal
Plug 'akinsho/toggleterm.nvim'
call plug#end()

" Key mappings
nnoremap <silent> <Esc> :nohlsearch<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
vnoremap <C-c> "+y
inoremap <C-v> <C-r>+
nnoremap <C-v> "+p
map <C-n> :NERDTreeToggle<CR>
let NERDTreeMapOpenVSplit = 's'

" Airline config
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#whitespace#enabled = 1

" CMake config
let g:cmake_build_dir = 'build'
let g:cmake_build_type = 'Debug'

" Color scheme
hi Normal      ctermbg=black guibg=black
hi Type        ctermfg=green cterm=bold guifg=#58ff55 gui=bold
hi PreProc     ctermfg=blue cterm=bold guifg=#3f5df7 gui=bold
hi Constant    ctermfg=magenta cterm=bold guifg=#ff00ff gui=bold
hi Number      ctermfg=magenta cterm=bold guifg=#ff00ff gui=bold
hi String      ctermfg=magenta cterm=bold guifg=#ff00ff gui=bold
hi Identifier  ctermfg=14 guifg=#00ffff
hi Function    ctermfg=6 guifg=#00ffff
hi Statement   ctermfg=3 guifg=#ffff00
hi Special     ctermfg=red guifg=#ff0000
hi Comment     ctermfg=cyan cterm=bold guifg=#00ffff gui=bold

" Git signs config
let g:NERDTreeGitStatusIndicatorMapCustom = {
    \ 'Modified'  : '✹',
    \ 'Staged'    : '✚',
    \ 'Untracked' : '✭',
    \ 'Renamed'   : '➜',
    \ 'Unmerged'  : '═',
    \ 'Deleted'   : '✖',
    \ 'Dirty'     : '✗',
    \ 'Ignored'   : '☒',
    \ 'Clean'     : '✔︎',
    \ 'Unknown'   : '?'
    \ }

highlight GitSignsAdd    guifg=#ffff00 ctermfg=3
highlight GitSignsChange guifg=#0000ff ctermfg=4
highlight GitSignsDelete guifg=#ff0000 ctermfg=1
highlight GitSignsAddNr    guifg=#ffff00 ctermfg=3
highlight GitSignsChangeNr guifg=#0000ff ctermfg=4
highlight GitSignsDeleteNr guifg=#ff0000 ctermfg=1

" LUA Configurations
lua <<EOF
-- Treesitter setup
require('nvim-treesitter.configs').setup({
  ensure_installed = {'go', 'c', 'cpp'},
  highlight = { enable = true }
})

-- LSP Signature setup
require('lsp_signature').setup({
  bind = true,
  hint_enable = true,
  hint_prefix = "🖝 ",
  hi_parameter = "LspSignatureActiveParameter",
  handler_opts = { border = "rounded" },
  toggle_key = "<C-s>"
})

-- LSP Setup
local lspconfig = require('lspconfig')

-- Common on_attach function
local on_attach = function(client, bufnr)
  require('lsp_signature').on_attach({}, bufnr)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
  vim.keymap.set('n', 'gh', '<cmd>Lspsaga hover_doc<CR>', { buffer = bufnr })
end

-- Go setup
require('go').setup({
  gofmt = 'gofumpt',
  goimports = 'goimports',
  lsp_cfg = true,
  lsp_on_attach = on_attach
})

-- Gopls setup
lspconfig.gopls.setup({
  on_attach = on_attach,
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = { unusedparams = true },
      staticcheck = true
    }
  }
})

-- Clangd setup
lspconfig.clangd.setup({
  cmd = {'clangd'},
  filetypes = {'c', 'cpp'},
  root_dir = lspconfig.util.root_pattern('.git', 'compile_commands.json', 'Makefile'),
  on_attach = on_attach
})

-- LSPSaga setup
require('lspsaga').setup({
  ui = { border = 'rounded', title = true, devicons = true },
  hover = { max_width = 0.8, open_link = 'gx' }
})

-- Completion setup
local cmp = require('cmp')
cmp.setup({
  snippet = { expand = function(args) vim.fn["vsnip#anonymous"](args.body) end },
  mapping = {
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_next_item() else fallback() end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_prev_item() else fallback() end
    end, { 'i', 's' }),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
  })
})

-- Diagnostics config
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Terminal setup
require('toggleterm').setup({
  open_mapping = [[<c-`>]],
  direction = 'horizontal',
  size = 15,
  shade_terminals = true,
  persist_mode = false,
  float_opts = { border = 'none' }
})
EOF

" LSPSaga key mappings
nnoremap <silent> <C-j> :Lspsaga hover_doc scroll_down<CR>
nnoremap <silent> <C-k> :Lspsaga hover_doc scroll_up<CR>
nnoremap <silent> <Leader>q :Lspsaga close_floaterm<CR>

lua <<EOF
-- Автоформатирование при сохранении
vim.api.nvim_create_autocmd("BufWritePre", {
	    pattern = { "*.go", "*.c", "*.cpp", "*.h", "*.hpp" },
		    callback = function()
			        vim.lsp.buf.format({ async = false })
					    end,
})
EOF
