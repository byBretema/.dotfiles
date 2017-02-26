" Made with ♥ by cambalamas.

" PLUGINS !
call plug#begin('~/.vim/plugged')
nnoremap <leader>pi :PlugInstall<CR>
nnoremap <leader>pu :PlugUpdate<CR>
nnoremap <leader>pU :PlugUpgrade<CR>

" tools
Plug 'tpope/vim-repeat'       " extends dot capacities.
Plug 'junegunn/vim-pseudocl'  " needed for vim-fnr
Plug 'junegunn/vim-fnr'       " replace <leader>r (Range), <leader>R (Under).
Plug 'jiangmiao/auto-pairs'   " auto match delimiters.
Plug 'airblade/vim-gitgutter' " git line status.
Plug 'sickill/vim-pasta'      " auto indent paste (better than, p`[v`]= remap)
Plug 'tpope/vim-surround'     " modify delimites.
Plug 'tpope/vim-commentary'   " easy comment with gcc or gc
Plug 'godlygeek/tabular'      " easy align text. ( :Tab /pattern )

Plug 'majutsushi/tagbar'
map <leader>t :TagbarToggle<CR>

Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }
map <leader>u :UndotreeToggle<CR>

Plug 'terryma/vim-multiple-cursors'
let g:multi_cursor_use_default_mapping=0
let g:multi_cursor_next_key=','
let g:multi_cursor_prev_key=';'
let g:multi_cursor_skip_key='-'
let g:multi_cursor_quit_key='<Esc>'

Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
noremap <C-Space> :NERDTreeToggle<cr>
let NERDTreeShowHidden=1
let g:NERDTreeAutoDeleteBuffer=1


"" visuals
Plug 'junegunn/rainbow_parentheses.vim'
au VimEnter * :RainbowParentheses


"" langs
Plug 'honza/dockerfile.vim'

" Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
" setlocal omnifunc=go#complete#Complete
" let g:go_fmt_command = "goimports"
" nnoremap <leader>gor :GoRun<CR>
" nnoremap <leader>got :GoTest<CR>
" nnoremap <leader>god :GoDecls<CR>
" nnoremap <leader>gon :GoRename<CR>
" nnoremap <leader>goe :GoMetaLint<CR>
" nnoremap <leader>goc :GoErrCheck<CR>
" nnoremap <leader>goa :GoAlternate<CR>
" let g:go_highlight_types = 1
" let g:go_highlight_fields = 1
" let g:go_autodetect_gopath = 1
" let g:go_highlight_methods = 1
" let g:go_highlight_functions = 1
" let g:go_highlight_operators = 1
" let g:go_highlight_extra_types = 1
" let g:go_highlight_space_tab_error = 1
" let g:go_highlight_build_constraints = 1
" let g:go_highlight_array_whitespace_error = 1
" let g:go_highlight_trailing_whitespace_error = 1

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


" SET OPTIONS !

" let the colors be.
syntax enable
" hide mode in favour of powerline.
"set noshowmode
" no comment
silent! set ttyfast
" let to vim be vim and not vi.
set nocompatible
" prefix for quick commands.
let mapleader = ' '
" allow mouse.
set mouse=a
silent! set ttymouse=xterm2
" security stuff.
set nomodeline
" avoid highlight slow.
set synmaxcol=150
" allow save on RO files with :W instead :w
command! W silent execute 'w !sudo tee % > /dev/null' | :e! | syn on

set secure        " vimrc and exrc protection.
set hidden        " let me switch between unsaved buffers.
set confirm       " ask before exit if exists unsaved changes.
set autoread      " autoload changes on focus.
set laststatus=2  " always show the tab line.
" set showtabline=2 " always show the status line.

set wrapscan   " loop search over the file.
set hlsearch   " highlight the matches.
set incsearch  " search while you type.
set ignorecase " don't care about upper/lower case.
set smartcase  " don't ignore case if write an upper case.
set gdefault   " defualt global option for s/foo/bar/.

set nofoldenable                      " fuck code folding.
set nobackup noswapfile nowritebackup " don't use vim as vcs.
set noerrorbells novisualbell t_vb=   " not use any type bell.

"" text
set encoding=utf-8  " for a better wor(l)d.
set nojoinspaces    " let only one space when join lines.

set iskeyword-=,    " consider comma as separator.
set iskeyword+=$    " take $symbol as part of word for php/shell variables.
set matchpairs+=<:> " match <> for html and xml.

set showbreak=↪\ \  wrapmargin=30 wrap " fancy break out of range lines.
set tabstop=4 shiftwidth=4 softtabstop=4 " indent length.
set smarttab autoindent smartindent shiftround " correct indent.

"" visual
set bg=dark
set t_Co=256 " darkness and rainbows.
"colorscheme gruvbox  " fancy warm colorscheme.
" hi Normal ctermbg=darkblack

set textwidth=80   " max line chars. /hi= outrange, cc./
set colorcolumn=+1 " visual mark chars limit."
hi OverLength ctermbg=blue
hi ColorColumn ctermbg=black

set number "relativenumber " let me see lines number and distance.
set list listchars=tab:¦\ ,eol:¬,trail:•,extends:❯,precedes:❮ " no printable

set ruler          " where am I? position info.
set mousehide      " hide mouse when you type.
" set showmatch      " highlight the delims matches.
set scrolloff=30   " let 30 lines always at view.
set nostartofline  " navigate over visual lines.

"" splits
set splitright   " verticals splits on the right.
set nolazyredraw " always redraw

"" complete
set wildmenu " completion and its options.
set wildmode=list:longest,full
set wildignore+=*/.git*,*/.DS_Store/*
set completeopt=menu,menuone,longest,preview

"" last but not least
set formatoptions-=t               " don't break line at textwidth setting.
set diffopt+=filler,vertical       " vimdiff stuff.
set backspace=indent,eol,start     " overpowered backspace.
set timeoutlen=1000 ttimeoutlen=0  " fast timeout for escape codes
set clipboard+=unnamed,unnamedplus " system clipboard


" KEYMAPS !
"... 'gt'and 'gT' switch between Tabs.
"... 'Ctrl+w+w' switch between Splits.

"" shortcuts
noremap Y y$
inoremap jk <Esc>
inoremap kj <C-o>
set pastetoggle=<C-p>
" toogle RelativeNumber.
nnoremap <leader>n :set rnu!<CR>

" edit/load vimrc.
nnoremap <leader>v :e ~/.vimrc<CR>
nnoremap <leader>V :source ~/.vimrc<CR>
" clear highlight.
nnoremap <silent><leader>h :noh<CR>

"" fixes
nnoremap ´´ :silent! !<CR>
" move over visual lines.
nnoremap j gj
nnoremap k gk
inoremap <UP> <C-o>gk
inoremap <DOWN> <C-o>gj

"" ide-like
" buffers
nnoremap <S-TAB> :bn<CR>
nnoremap <leader><leader> :ls<CR>:b
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
" auto-indent.
nnoremap <silent><leader>fix :call Fix()<CR>


" " FUNCS !
" "" not lost the cursros position.
" function! Preserve(command)
"   let l:search=@/
"   let l:line = line(".")
"   let l:col = col(".")
"   execute a:command
"   let @/=l:search
"   call cursor(l:line, l:col)
" endfunction
" "" fix indents, trailing spaces & mixeds EOLs
" function! Fix()
"   :call Preserve("normal! gg=G")
"   :call Preserve("%s/\\s\\+$//e")
"   :call Preserve("%s///e")
" endfunction


" AUTOCOMMANDS !
" markdown
au BufNewFile,BufRead *.md set filetype=markdown
" autoreload
au FocusGained,FocusLost,BufEnter,BufRead,BufLeave,WinEnter,WinLeave,BufWinEnter,BufWinLeave * :silent! !
" autosave
au FocusLost,BufLeave,CursorHold,CursorHoldI * silent! wa
