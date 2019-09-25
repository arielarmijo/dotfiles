" VIM Configuration file
set mouse=a

" Display
set title                 " Update the title of your window or your terminal
set number				  " Show current line number
set relativenumber        " Display line numbers
"set ruler                 " Display cursor position
set showcmd
set wrap                  " Wrap lines when they are too long
set wildmenu
set laststatus=2
set noshowmode

set scrolloff=5           " Display at least 3 lines around you cursor
                          " (for scrolling)
set timeoutlen=1000
set ttimeoutlen=10

set background=dark
let g:solarized_termtrans=1
colorscheme solarized

let g:lightline = {
	\ 'colorscheme': 'powerline',
	\}

" Transparent status line background
let s:palette = g:lightline#colorscheme#{g:lightline.colorscheme}#palette
let s:palette.normal.middle = [ [ 'NONE', 'NONE', 'NONE', 'NONE' ] ]
let s:palette.insert.middle = [ [ 'NONE', 'NONE', 'NONE', 'NONE' ] ]
let s:palette.replace.middle = [ [ 'NONE', 'NONE', 'NONE', 'NONE' ] ]
let s:palette.inactive.middle = s:palette.normal.middle
let s:palette.tabline.middle = s:palette.normal.middle

" -- Search
set ignorecase            " Ignore case when searching
set smartcase             " If there is an uppercase in your search term
set incsearch             " Highlight search results when typing
set hlsearch              " Highlight search results

" Hide buffer (file) instead of abandoning when switching to another buffer
set hidden

" Tabs and spaces configuration
set ts=4
set sts=4
set sw=4
set noexpandtab

syntax enable
set autoindent
filetype plugin indent on
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

set spelllang=es
set foldmethod=marker

" Custom maps
nmap <Space> za
nnoremap <F2> :set hlsearch!<CR>
nnoremap <F3> :call ToggleFoldMethod()<CR>

function ToggleFoldMethod()
	if &foldmethod == "marker"
		set foldmethod=syntax
	elseif &foldmethod == "syntax"
		set foldmethod=indent
	elseif &foldmethod == "indent"
		set foldmethod=marker
	endif
	echo join(["foldmethod", &foldmethod], "=")
endfunction
