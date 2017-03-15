" MAde with <3 by @cambalamas

" allow save on RO files with :W instead :w
command! W silent execute 'w !sudo tee % > /dev/null' | :e! | syn on



" --- PLUGINS ! ------------------------------------------------------------ "

call plug#begin('~/.vim/plugged')

" plug shortcuts
nnoremap <C-p> :PlugInstall<CR> :PlugUpdate<CR> :PlugUpgrade<CR>

"" ignored packages
"Plug 'godlygeek/tabular'      " easy align text. ( :Tab /pattern )
"Plug 'jiangmiao/auto-pairs'   " auto match delimiters.


"" visuals

"Plug 'vim-airline/vim-airline'
"Plug 'vim-airline/vim-airline-themes'
"let g:airline#extensions#tabline#enabled = 1
"let g:airline#extensions#tabline#left_sep = ' '
"let g:airline#extensions#tabline#left_alt_sep = '|'

"Plug 'itchyny/lightline.vim'

Plug 'junegunn/rainbow_parentheses.vim'
au VimEnter * :RainbowParentheses


"" tools
Plug 'junegunn/vim-pseudocl'  " needed for vim-fnr
Plug 'junegunn/vim-fnr'       " replace <leader>r (Range), <leader>R (Under).
Plug 'tpope/vim-repeat'       " extends dot capacities.
Plug 'sickill/vim-pasta'      " auto indent paste (better than, p`[v`]= remap)
Plug 'tpope/vim-surround'     " modify delimites.
Plug 'tpope/vim-commentary'   " easy comment with gcc or gc
Plug 'airblade/vim-gitgutter' " git line status.

Plug 'terryma/vim-multiple-cursors'
let g:multi_cursor_use_default_mapping=0
let g:multi_cursor_next_key=','
let g:multi_cursor_prev_key=';'
let g:multi_cursor_skip_key='-'
let g:multi_cursor_quit_key='<Esc>'

Plug 'majutsushi/tagbar'
noremap <C-b> :TagbarToggle<CR>

Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }
noremap <C-u> :UndotreeToggle<CR>

Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
noremap <C-n> :NERDTreeToggle<cr>
let NERDTreeShowHidden=1
let g:NERDTreeAutoDeleteBuffer=1


"" langs

Plug 'honza/dockerfile.vim'

Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
setlocal omnifunc=go#complete#Complete
let g:go_fmt_command = "goimports"
au FileType go nnoremap <leader>gor :GoRun<CR>
au FileType go nnoremap <leader>got :GoTest<CR>
au FileType go nnoremap <leader>god :GoDecls<CR>
au FileType go nnoremap <leader>gon :GoRename<CR>
au FileType go nnoremap <leader>goe :GoMetaLint<CR>
au FileType go nnoremap <leader>goc :GoErrCheck<CR>
au FileType go nnoremap <leader>goa :GoAlternate<CR>
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_autodetect_gopath = 1
let g:go_highlight_methods = 1
let g:go_highlight_functions = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_space_tab_error = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_array_whitespace_error = 1
let g:go_highlight_trailing_whitespace_error = 1


"" colors
Plug 'morhetz/gruvbox'
let g:gruvbox_italic = 1
let g:gruvbox_invert_signs = 1
let g:gruvbox_invert_tabline = 1
let g:gruvbox_contrast_ = "hard"
let g:gruvbox_vert_split = "gray"
let g:gruvbox_number_column = "bg1"
let g:gruvbox_italicize_strings = 1
let g:gruvbox_invert_indent_guides = 1


"close_plug.
call plug#end()



" --- SET OPTIONS ! -------------------------------------------------------- "

syntax enable     " let the colors be.
set nomodeline    " security stuff.
set noshowmode    " hide mode in favour of lightline.
set nocompatible  " let to vim be vim and not vi.
set synmaxcol=120 " avoid highlight slow.

set mouse=a                 " allow mouse.
silent! set ttyfast
silent! set ttymouse=xterm2 " allow mouse.

set secure        " vimrc and exrc protection.
set hidden        " let me switch between unsaved buffers.
set confirm       " ask before exit if exists unsaved changes.
set autoread      " autoload changes on focus.
set laststatus=2  " always show the tab line.
set showtabline=2 " always show the status line.

set wrapscan   " loop search over the file.
set hlsearch   " highlight the matches.
set incsearch  " search while you type.
set ignorecase " don't care about upper/lower case.
set smartcase  " don't ignore case if write an upper case.
set gdefault   " default global option for s/foo/bar/.

set nofoldenable                      " fuck code folding.
set noerrorbells novisualbell t_vb=   " not use any type bell.


"" text
set encoding=utf-8  " for a better wor(l)d.
set nojoinspaces    " let only one space when join lines.

set iskeyword-=,    " consider comma as separator.
set iskeyword+=$    " take $symbol as part of word for php/shell variables.
set matchpairs+=<:> " match <> for html and xml.

set showbreak=↪\ \  wrapmargin=30 wrap        " fancy breakline.
set tabstop=4 shiftwidth=4 softtabstop=4       " indent length.
set smarttab autoindent smartindent shiftround " correct indent.


"" visual
set bg=dark
set ruler            " where am I? position info.
set number           "relativenumber # let me see lines number and distance.
set mousehide        " hide mouse when you type.
set showmatch        " highlight the delims matches.
set scrolloff=30     " let 30 lines always at view.
set textwidth=80
set nostartofline    " navigate over visual lines.
set colorcolumn=+1
colorscheme gruvbox  " fancy warm colorscheme.
set list listchars=tab:¦-,eol:$,nbsp:¬,trail:•,extends:❯,precedes:❮


"" complete
set wildmenu
set wildmode=longest,list,full
set wildignore+=*/.git*,*/.DS_Store/*
set completeopt=menu,menuone,longest,preview


"" stuff
set ttimeoutlen=0				   " fast timeout for escape codes
set timeoutlen=1000                " fast timeout for escape codes
set formatoptions-=t               " DON'T break line at textwidth setting !!!
set diffopt+=filler,vertical       " vimdiff stuff.
set backspace=indent,eol,start     " overpowered backspace.
set clipboard+=unnamed,unnamedplus " system clipboard


"" splits
set splitright     " verticals splits on the right.
set nolazyredraw   " always redraw


"" backups
set undodir=~/.vim/undo//
set backupdir=~/.vim/back//
set directory=~/.vim/swap//



" --- KEYMAPS ! ------------------------------------------------------------ "

"... switch between tabs: gt, gT
"... switch between splits: ctrl+w+w
"... auto-indent: gg=G

let mapleader = ' ' " prefix for quick commands.

" shortcuts
noremap Y y$
nnoremap <leader>º :set rnu!<CR>
nnoremap <silent><leader>h :noh<CR>
nnoremap <leader>v :e ~/.vimrc<CR>
nnoremap <leader>V :source~/.vimrc<CR>

" fix move over visual lines.
nnoremap j gj
nnoremap k gk
inoremap <UP> <C-o>gk
inoremap <DOWN> <C-o>gj

" save.
nnoremap <C-s> :update<CR>
inoremap <C-s> <C-o>:update<CR>
vnoremap <C-s> <Esc>:update<CR>

" buffers
nnoremap <S-TAB> :bn<CR>
nnoremap <leader><leader> :ls<CR>

" undo/redo.
nnoremap U <C-r>
inoremap <C-u> <C-o>u
inoremap <C-r> <C-o><C-r>

" swap lines.
nnoremap <C-j> :m+<CR>==
nnoremap <C-k> :m-2<CR>==
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv
inoremap <C-j> <Esc>:m+<CR>==gi
inoremap <C-k> <Esc>:m-2<CR>==gi



" --- AUTOCOMMANDS ! -------------------------------------------------------- "

" markdown
au BufNewFile,BufRead *.md set filetype=markdown

" autoreload
au FocusGained,BufEnter * :silent! !

" autosave
au FocusLost,BufLeave,CursorHold,CursorHoldI * silent! wa
