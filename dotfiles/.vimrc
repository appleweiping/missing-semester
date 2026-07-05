" ~/.vimrc — Missing Semester dotfiles
" Based on the course's suggested basic vimrc, trimmed and commented.

" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" Enable type file detection and plugins/indent for the detected filetype.
filetype plugin indent on

" Turn syntax highlighting on.
syntax on

" --- Display ---
set number              " line numbers
set relativenumber      " relative line numbers (great for j/k motions)
set ruler               " show cursor position
set showcmd             " show partial commands in the last line
set showmode            " show current mode
set laststatus=2        " always show the status line
set wildmenu            " visual autocomplete for the command menu
set wildmode=list:longest

" --- Search ---
set incsearch           " incremental search
set hlsearch            " highlight matches
set ignorecase          " case-insensitive search...
set smartcase           " ...unless the pattern has uppercase

" --- Editing ---
set backspace=indent,eol,start
set autoindent
set expandtab           " tabs -> spaces
set tabstop=4
set shiftwidth=4
set scrolloff=5         " keep 5 lines visible above/below cursor
set hidden              " allow switching buffers without saving

" --- Quality of life ---
set history=1000
set clipboard=unnamed   " use system clipboard where available
set mouse=a             " enable mouse in all modes

" Unbind arrow keys in normal mode to build hjkl muscle memory (course advice).
nnoremap <Left>  :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up>    :echoe "Use k"<CR>
nnoremap <Down>  :echoe "Use j"<CR>

" CtrlP plugin (installed under ~/.vim/pack/vendor/start/ctrlp.vim):
" open the fuzzy finder with Ctrl-P (editors lecture exercise 3).
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

" Clear search highlight with <leader> + Enter.
nnoremap <silent> <CR> :nohlsearch<CR><CR>
