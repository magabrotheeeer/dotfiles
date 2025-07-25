filetype plugin indent on
syntax on
highlight Cursorline cterm=bold
set incsearch 
set hlsearch 
set smartcase 
set ignorecase
set mouse=
set tabstop=4
set shiftwidth=4
set noexpandtab
set relativenumber
set number
set noswapfile
set linebreak
set list
set wrap
set ai
set cursorline
set softtabstop=2
set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz
set encoding=utf-8
set nobackup
set nowritebackup
set updatetime=300
set signcolumn=yes
highlight LineNr guifg=Yellow ctermfg=Yellow
highlight CursorLineNr guifg=Purple ctermfg=magenta
call plug#begin('~/.config/nvim/plugged')
	" git
	Plug 'Xuyuanp/nerdtree-git-plugin'
    Plug 'hrsh7th/vim-vsnip'
    Plug 'neovim/nvim-lspconfig'
    Plug 'junegunn/vim-plug'
    " Плагин для работы с CMake
    Plug 'cdelledonne/vim-cmake'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'  " Дополнительные темы для airline
    " Плагин для отображения дерева файлов
    Plug 'preservim/nerdtree'
    Plug 'hrsh7th/nvim-cmp'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-path'
    Plug 'hrsh7th/cmp-cmdline'
    Plug 'jiangmiao/auto-pairs'
    Plug 'ray-x/go.nvim'  " Дополнительные возможности для Go
    Plug 'ray-x/guihua.lua'  " Зависимость для go.nvim
call plug#end()

lua << EOF
-- Импорт модуля lspconfig
local lspconfig = require('lspconfig')

-- Настройка clangd для C/C++
lspconfig.clangd.setup {
  cmd = {'clangd'},  -- Команда для запуска сервера
  filetypes = {'c', 'cpp'},  -- Типы файлов, которые обрабатывает сервер
  root_dir = lspconfig.util.root_pattern('.git', 'compile_commands.json', 'Makefile'),  -- Корневая директория проекта
  settings = {
    clangd = {
      -- Дополнительные настройки сервера (если нужны)
    }
  }
}
EOF

nnoremap <silent> <Esc> :nohlsearch<CR>
" Открытие NERDTree с помощью Ctrl+n
map <C-n> :NERDTreeToggle<CR>
vnoremap <C-c> "+y
inoremap <C-v> <C-r>+
" Настройки для CMake
let g:cmake_build_dir = 'build'
let g:cmake_build_type = 'Debug'

let g:airline#extensions#tabline#enabled = 1  " Показывать вкладки вверху
let g:airline#extensions#tabline#formatter = 'unique_tail'  " Формат имени файла
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#whitespace#enabled = 1
set background=dark

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

" Переключение между окнами с помощью Ctrl + h/j/k/l
nnoremap <C-h> <C-w>h  " Перейти в левое окно
nnoremap <C-j> <C-w>j  " Перейти в нижнее окно
nnoremap <C-k> <C-w>k  " Перейти в верхнее окно
nnoremap <C-l> <C-w>l  " Перейти в правое окно
" Отключить встроенные подсказки (inline hints)


" Настройка автодополнения
lua << EOF
local cmp = require('cmp')

cmp.setup {
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
      ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable,
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
  })
}
EOF

lua << EOF
vim.diagnostic.config({
  virtual_text = true,  -- Отображение текста рядом с ошибкой
  signs = {
    enable = true,
    priority = 10,
    values = {
      { name = "DiagnosticSignError", text = "" },
      { name = "DiagnosticSignWarn", text = "" },
      { name = "DiagnosticSignInfo", text = "" },
      { name = "DiagnosticSignHint", text = "" },
    },
  },
  underline = true,     -- Подчеркивание ошибок
  update_in_insert = false,
  severity_sort = true,
})

-- Настройка clangd для C/C++
local lspconfig = require('lspconfig')
lspconfig.clangd.setup {
  cmd = {'clangd'},
  filetypes = {'c', 'cpp'},
  root_dir = lspconfig.util.root_pattern('.git', 'compile_commands.json', 'Makefile'),
  settings = {
    clangd = {
      -- Дополнительные настройки сервера (если нужны)
    }
  }
}
EOF
lua << EOF
-- Настройка gopls для Go
local lspconfig = require('lspconfig')
lspconfig.gopls.setup {
  cmd = {'gopls'},
  filetypes = {'go', 'gomod', 'gowork', 'gotmpl'},
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
  on_attach = function(client, bufnr)
  end
}
EOF
let g:airline_section_c = '%{expand("%:p:h")}'
" Копирование в системный буфер обмена по Ctrl + c
vnoremap <C-c> "+y

" Вставка из системного буфера обмена по Ctrl + v
inoremap <C-v> <C-r>+
nnoremap <C-v> "+p

" Открывать файл в вертикальном сплите по 's' в NERDTree
let NERDTreeMapOpenVSplit = 's'

" значки для nerdtree git
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
