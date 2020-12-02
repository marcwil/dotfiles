set nocompatible              " be iMproved, required
let g:ale_completion_enabled = 1
"if has('python') " if dynamic py|py3, this line already activates python2.
"  let s:python_version = 2
"elseif has('python3')
"  let s:python_version = 3
"else
"  let s:python_version = 0
"endif

set t_Co=256

let mapleader = " "

syntax on
set ai " autoindent
set ts=4
set nu
set background=dark
set so=3
nnoremap DD ddk
filetype plugin indent on

set expandtab
set tabstop=4
set shiftwidth=4
set smarttab
set smartindent

set foldmethod=marker

colo chroma
set cursorline

" for :set list
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣

" from https://dougblack.io/words/a-good-vimrc.html
" visual line movement
nnoremap j gj
nnoremap k gk
nnoremap $ g$
nnoremap 0 g0
nnoremap gj j
nnoremap gk k
nnoremap g$ $
nnoremap g0 0
" neo arrow keys as hjkl
nmap <Left> h
nmap <Down> j
nmap <Up> k
nmap <Right> l
" append and prepend to visual line
nnoremap gA g$i
nnoremap gI g0i
" better completion
set wildmode=longest,list,full
set wildmenu
set lazyredraw
set showmatch
" search
set incsearch
set hlsearch
set ignorecase
set smartcase
" keine wörter umbrechen
set linebreak

"""""""""""""""""""""
"      Plugins      "
"""""""""""""""""""""
call plug#begin('~/.vim/plugged')
Plug 'ctrlpvim/ctrlp.vim'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'vim-scripts/haskell.vim'
Plug 'vim-scripts/indenthaskell.vim'
Plug 'preservim/tagbar', { 'on': 'TagbarToggle' }
Plug 'vim-airline/vim-airline'
Plug 'nathangrigg/vim-beancount'
Plug 'vimwiki/vimwiki'
Plug 'dense-analysis/ale'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
if !has('nvim')
    Plug 'markonm/traces.vim'
end
call plug#end()

"""""""""""""""""""""
"   Plugin Config   "
"""""""""""""""""""""

" CtrlP
let g:ctrlp_cmd = 'CtrlPMixed'
nnoremap <Leader>p :CtrlPBuffer<cr>

" nerdtree
nnoremap <Leader>e :NERDTreeToggle<cr>

" TagBar
nnoremap <Leader>o :TagbarToggle<cr>
let g:tagbar_sort = 0

" Ale config
let g:ale_completion_enabled = 1 " enable ale completion
set omnifunc=ale#completion#OmniFunc
" autocomplete workaround
set completeopt+=noinsert

" AleCommands
nnoremap <Leader>h :ALEHover<cr>
nnoremap <Leader>q :ALEDocumentation<cr>
nnoremap <Leader>Q :ALEDetail<cr>
nnoremap <Leader>d :ALEGoToDefinition<cr>
nnoremap <Leader>D :ALEGoToDefinition<cr>
nnoremap <Leader>dt :ALEGoToDefinition -tab<cr>
nnoremap <Leader>ds :ALEGoToDefinition -split<cr>
nnoremap <Leader>dv :ALEGoToDefinition -vsplit<cr>
nnoremap <Leader>R :ALERename<cr>
nnoremap <Leader>r :ALEFindReferences<cr>
nnoremap <Leader>f :ALEFix<cr>
nnoremap <Leader>F :ALEFixSuggest<cr>
nnoremap <Leader>l :ALELint<cr>
nnoremap <Leader>n :ALENext<cr>
nnoremap <Leader>N :ALEPrevious<cr>

if has('nvim')
    " like traces.vim (%s live preview)
    set inccommand=split
    set mouse=a
endif
