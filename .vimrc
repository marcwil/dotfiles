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
colo delek
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

" CtrlP
let g:ctrlp_cmd = 'CtrlPMixed'
nnoremap <Leader>p :CtrlPBuffer<cr>

" nerdtree
nnoremap <Leader>e :NERDTreeToggle<cr>

" TagBar
nnoremap <Leader>o :TagbarToggle<cr>
let g:tagbar_sort = 0

if has('nvim')
    " like traces.vim (%s live preview)
    set inccommand=split
    set mouse=a

    " enable ale completion
    let g:ale_completion_enabled = 1
"    set omnifunc=ale#completion#OmniFunc
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

    " Rust
    let g:ale_rust_rls_toolchain= 'stable'

endif


" Load all plugins now.
" Plugins need to be added to runtimepath before helptags can be generated.
packloadall
" Load all of the helptags now, after plugins have been loaded.
" All messages and errors will be ignored.
silent! helptags ALL

