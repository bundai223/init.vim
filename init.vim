set encoding=utf-8
scriptencoding utf-8
set fileencoding=utf-8

" release autogroup in MyAutoCmd
augroup MyAutoCmd
  autocmd!
augroup END

let s:conf_root = expand('~/.config/nvim')
let s:repos_path = expand('~/repos')
let s:dotfiles_path = s:repos_path . '/github.com/bundai223/dotfiles'
let s:backupdir = s:conf_root . '/backup'
let s:swapdir = s:conf_root . '/swp'
let s:undodir = s:conf_root . '/undo'
let s:dein_repo_dir = s:conf_root . '/dein'

function! MkDir(dirpath)
  if !isdirectory(a:dirpath)
    call mkdir(a:dirpath, "p")
  endif
endfunction
call MkDir(s:conf_root)
call MkDir(s:repos_path)
call MkDir(s:backupdir)
call MkDir(s:swapdir)
call MkDir(s:undodir)

" help日本語・英語優先
"set helplang=ja,en
set helplang=en
" カーソル下の単語をhelp
set keywordprg =:help

set fileformat=unix
set fileformats=unix,dos

" バックアップファイルの設定
let &backupdir=s:backupdir
set backup
let &directory=s:swapdir
set swapfile

" クリップボードを使用する
set clipboard=unnamed

" Match pairs setting.
set matchpairs=(:),{:},[:],<:>

" 改行時の自動コメントをなしに
augroup MyAutoCmd
  autocmd FileType * setlocal formatoptions-=o
augroup END

" 分割方向を指定
set splitbelow
"set splitright

" BS can delete newline or indent
set backspace=indent,eol,start
let vim_indent_cont=6 " ' '*6+'\'+' ' →実質8sp

set completeopt=menu,preview
" 補完でプレビューしない
"set completeopt=menuone,menu

" C-a, C-xでの増減時の設定
set nrformats=hex

" Default comment format is nothing
" Almost all this setting override by filetype setting
" e.g. cpp: /*%s*/
"      vim: "%s
set commentstring=%s

if has('vim_starting')
  " Goのpath
  if $GOROOT != ''
    set runtimepath+=$GOROOT/misc/vim
    "set runtimepath+=$GOPATH/src/github.com/nsf/gocode/vim
  endif

  let &runtimepath .= ',' . s:conf_root
  let &runtimepath .= ',' . s:conf_root . '/after'
  if has('win32')
  else
    " 自前で用意したものへの path
    set path=.,/usr/include,/usr/local/include
  endif
endif

if has('unix')
  let $USERNAME=$USER
endif

" Select last pasted.
nnoremap <expr> gp '`['.strpart(getregtype(), 0, 1).'`]'

" History
set history=10000

if has('persistent_undo' )
  let &undodir=s:undodir
  set undofile
endif

" Indent
set expandtab

" Width of tab
set tabstop=2

" How many spaces to each indent level
set shiftwidth=2

" <>などでインデントする時にshiftwidthの倍数にまるめる
set shiftround

" 補完時に大文字小文字の区別なし
set infercase

" Automatically adjust indent
set autoindent

" Automatically indent when insert a new line
set smartindent
set smarttab

" スリーンベルを無効化

set t_vb=
set novisualbell

" Search
" Match words with ignore upper-lower case
set ignorecase

" Don't think upper-lower case until upper-case input
set smartcase

" Incremental search
set incsearch

" Highlight searched words
set hlsearch

" http://cohama.hateblo.jp/entry/20130529/1369843236
" Auto complete backslash when input slash on search command(search by slash).
cnoremap <expr> / (getcmdtype() == '/') ? '\/' : '/'
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

" Expand 単語境界入力
" https://github.com/cohama/.vim/blob/master/.vimrc
cnoremap <C-w> <C-\>eToggleWordBounds(getcmdtype(), getcmdline())<CR>
function! ToggleWordBounds(type, line)
  if a:type == '/' || a:type == '?'
    if a:line =~# '^\\<.*\\>$'
      return substitute(a:line, '^\\<\(.*\)\\>$', '\1', '')
    else
      return '\<' . a:line . '\>'
    endif

  elseif a:type == ':'
    " s || %sの時は末尾に連結したり削除したり
    if a:line =~# 's/.*' || a:line =~# '%s/.*'
      if a:line =~# '\\<\\>$'
        return substitute(a:line, '\\<\\>$', '\1', '')
      else
        return a:line . '\<\>'
      endif
    else
      return a:line
    endif

  else
    return a:line
  endif
endfunction

" Auto escape input
cnoremap <C-\> <C-\>eAutoEscape(getcmdtype(), getcmdline())<CR>
function! AutoEscape(type, line)
  if a:type == '/' || a:type == '?'
    return substitute(a:line, '/', '\\/', 'g')
  else
    return a:line
  endif
endfunction

" tagファイルの検索パス指定
" カレントから親フォルダに見つかるまでたどる
" tagの設定は各プロジェクトごともsetlocalする
set tags+=tags;

" 外部grepの設定
set grepprg=grep\ -nH

augroup MyAutoCmd
  " make, grep などのコマンド後に自動的にQuickFixを開く
  autocmd QuickfixCmdPost make,grep,grepadd,vimgrep cwindow

  " QuickFixおよびHelpでは q でバッファを閉じる
  autocmd FileType help,qf nnoremap <buffer> q <C-w>c
augroup END

" filetype 調査
" :verbose :setlocal filetype?
"
" Set encoding when open file {{{
command! Utf8 edit ++enc=utf-8 %
command! Utf16 edit ++enc=utf-16 %
command! Cp932 edit ++enc=cp932 %
command! Euc edit ++enc=eucjp %

command! Unix edit ++ff=unix %
command! Dos edit ++ff=dos %

" Copy current path.
command! CopyCurrentPath :call s:copy_current_path()
"nnoremap <C-\> :<C-u>CopyCurrentPath<CR>

function! s:copy_current_path()
  if has('win32')
    let @*=substitute(expand('%:p'), '\\/', '\\', 'g')
  else
    let @*=expand('%:p')
  endif
endfunction

" Json Formatter
command! JsonFormat :execute '%!python -m json.tool'
  \ | :execute '%!python -c "import re,sys;chr=__builtins__.__dict__.get(\"unichr\", chr);sys.stdout.write(re.sub(r\"\\\\u[0-9a-f]{4}\", lambda x: chr(int(\"0x\" + x.group(0)[2:], 16)).encode(\"utf-8\"), sys.stdin.read()))"'
  \ | :%s/ \+$//ge
  \ | :set ft=javascript
  \ | :1


" Leaderを設定
" 参考: http://deris.hatenablog.jp/entry/2013/05/02/192415
noremap [myleader] <nop>
map <Space> [myleader]
"noremap map \ , "もとのバインドをつぶさないように

" 有効な用途が見えるまであけとく
noremap s <nop>
noremap S <nop>
noremap <C-s> <nop>
noremap <C-S> <nop>

" Invalidate that don't use commands
nnoremap ZZ <Nop>
" exモード？なし
nnoremap Q <Nop>

" 矯正のために一時的に<C-c>無効化
inoremap <C-c> <Nop>
nnoremap <C-c> <Nop>
vnoremap <C-c> <Nop>
cnoremap <C-c> <Nop>

" Easy to esc
inoremap <C-g> <Esc>
nnoremap <C-g> <Esc>
vnoremap <C-g> <Esc>
cnoremap <C-g> <Esc>


" Easy to cmd mode
nnoremap ; :
vnoremap ; :
nnoremap : q:i
vnoremap : q:i

" Easy to help
nnoremap [myleader]h :<C-u>vert bel help<Space>
nnoremap [myleader]H :<C-u>vert bel help<Space><C-r><C-w><CR>

" カレントパスをバッファに合わせる
nnoremap <silent>[myleader]<Space> :<C-u>lcd %:h<CR>:pwd<CR>

" Quick splits
nnoremap [myleader]_ :sp<CR>
nnoremap [myleader]<Bar> :vsp<CR>

" Delete line end space|tab.
nnoremap [myleader]s<Space> :%s/ *$//g<CR>
"nnoremap [myleader]s<Space> :%s/[ |\t]*$//g<CR>

" Yank to end
nnoremap Y y$

" C-y Paste when insert mode
inoremap <C-y> <C-r>*

" BS act like normal backspace
nnoremap <BS> X

" tab
nnoremap tn :<C-u>tabnew<CR>
nnoremap te :<C-u>tabnew +edit `=tempname()`<CR>
nnoremap tc :<C-u>tabclose<CR>
" Move window.
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" 関数単位で移動
nmap <C-p> [[
nmap <C-n> ]]

" Toggle 0 and ^
nnoremap <expr>0 col('.') == 1 ? '^' : '0'
nnoremap <expr>^ col('.') == 1 ? '^' : '0'

" highlight off
nnoremap <silent>[myleader]/ :noh <CR>

" 検索結果をウインドウ真ん中に
nnoremap n nzzzv
nnoremap N Nzzzv


if &compatible
  set nocompatible
endif
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
    call MkDir(s:dein_repo_dir)
    execute '!curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer_dein.sh'
    execute '!sh installer_dein.sh '. s:dein_repo_dir
    execute '!rm installer_dein.sh'

  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, 'p')
  " set runtimepath+=~/.config/nvim/dein/repos/github.com/Shougo/dein.vim
endif

call dein#begin(expand(s:dein_repo_dir))

call dein#add('Shougo/dein.vim')
call dein#add('Shougo/deoplete.nvim')
call dein#add('Shougo/neomru.vim')
call dein#add('Shougo/denite.nvim')
call dein#add('Shougo/neosnippet.vim')
call dein#add('Shougo/neosnippet-snippets')
call dein#add('bundai223/mysnip')
call dein#add('bundai223/mysyntax.vim')

" rust
call dein#add('rust-lang/rust.vim')
call dein#add('racer-rust/vim-racer')

" go
call dein#add('Shougo/deoplete.nvim')
call dein#add('zchee/deoplete-go')
call dein#add('benekastah/neomake')
call dein#add('fatih/vim-go')

" ruby
call dein#add('fishbullet/deoplete-ruby')
call dein#add('tpope/vim-rails')
call dein#add('tpope/vim-bundler')

" python
call dein#add('zchee/deoplete-jedi')

call dein#end()

filetype plugin indent on
syntax enable

if dein#check_install()
  call dein#install()
endif

" Use deoplete
let g:deoplete#enable_at_startup = 1

" racer
set hidden
let g:racer_cmd = "~/.cargo/bin/racer/target/release/racer"
" let $RUST_SRC_PATH #terminal上で設定しているはず
"

" denite key bind {{{
" <Space>をdeniteのキーに
nnoremap [denite] <Nop>
nmap <C-u> [denite]

" source
" denite file
nnoremap <silent> [denite]f   :<C-u>Denite file_rec buffer<CR>
nnoremap <silent> [denite]m   :<C-u>Denite file_mru<CR>
nnoremap <silent> [denite]o   :<C-u>Denite -no-quit -wrap outline<CR>
nnoremap <silent> [denite]g   :<C-u>Denite -auto-preview grep<CR>
nnoremap <silent> [denite]tw  :<C-u>Denite tweetvim<CR>
nnoremap <silent> [denite]ns  :<C-u>Denite neosnippet<CR>
nnoremap <silent> [denite]ens :<C-u>Denite neosnippet/user<CR>
nnoremap <silent> [denite]b   :<C-u>Denite buffer<CR>
nnoremap <silent> [denite]c   :<C-u>Denite -auto-preview colorscheme<CR>

" denite resume
nnoremap <silent> [denite]r   :<C-u>Denite -resume<CR>
nnoremap <silent> [denite]R   <Plug>(denite_restart)

nnoremap <silent> [denite]<Space> :<C-u>Denite file_rec/async<CR>

let g:neomru#time_format = "(%Y/%m/%d %H:%M:%S) "

"""""""""""""o
" Change file_rec command.
call denite#custom#var('file_rec', 'command',
\ ['ag', '--follow', '--nocolor', '--nogroup', '-g', ''])

" Change mappings.
call denite#custom#map('insert', '<C-p>', 'move_to_prev_line')
call denite#custom#map('insert', '<C-n>', 'move_to_next_line')

" Change matchers.
call denite#custom#source(
\ 'file_mru', 'matchers', ['matcher_fuzzy', 'matcher_project_files'])
call denite#custom#source(
\ 'file_rec', 'matchers', ['matcher_cpsm'])

" Change sorters.
call denite#custom#source(
\ 'file_rec', 'sorters', ['sorter_sublime'])

" Add custom menus
let s:menus = {}

let s:menus.zsh = {
	\ 'description': 'Edit your import zsh configuration'
	\ }
let s:menus.zsh.file_candidates = [
	\ ['zshrc', '~/.zshrc'],
	\ ['zshrc', '~/.zshrc_local'],
	\ ['zshenv', '~/.zshenv'],
	\ ['zshenv', '~/.zshenv_local'],
	\ ]

let s:menus.tmux = {
	\ 'description': 'Edit your import tmux configuration'
	\ }
let s:menus.zsh.file_candidates = [
	\ ['tmux.conf', '~/.tmux.conf'],
	\ ]

let s:menus.my_commands = {
	\ 'description': 'Example commands'
	\ }
let s:menus.my_commands.command_candidates = [
	\ ['Split the window', 'vnew'],
	\ ['Open zsh menu', 'Denite menu:zsh'],
	\ ['Open tmux menu', 'Denite menu:tmux'],
	\ ]

call denite#custom#var('menu', 'menus', s:menus)

call denite#custom#source('file_mru', 'converters',
      \ ['converter_relative_word'])

" Define alias
call denite#custom#alias('source', 'file_rec/git', 'file_rec')
call denite#custom#var('file_rec/git', 'command',
      \ ['git', 'ls-files', '-co', '--exclude-standard'])

" Change default prompt
call denite#custom#option('default', 'prompt', '>')

" Change ignore_globs
call denite#custom#filter('matcher_ignore_globs', 'ignore_globs',
      \ [ '.git/', '.ropeproject/', '__pycache__/',
      \   'venv/', 'images/', '*.min.*', 'img/', 'fonts/'])
