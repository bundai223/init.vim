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
let s:dein_dir = s:dein_repo_dir . '/repos/github.com/Shougo/dein.vim'

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
    call MkDir(s:dein_repo_dir)
  endif

  if !isdirectory(s:dein_dir)
    execute '!curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer_dein.sh'
    execute '!sh installer_dein.sh '. s:dein_repo_dir
    execute '!rm installer_dein.sh'

  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_dir, 'p')
  " set runtimepath+=~/.config/nvim/dein/repos/github.com/Shougo/dein.vim
endif

if dein#load_state(expand(s:dein_dir))
  call dein#begin(expand(s:dein_repo_dir))

  call dein#add('andrewradev/switch.vim')
  call dein#add('bundai223/mysnip')
  call dein#add('bundai223/mysyntax.vim')
  call dein#add('bundai223/vim-template')
  call dein#add('bronson/vim-trailing-whitespace')
  call dein#add('Shougo/dein.vim')
  call dein#add('Shougo/deoplete.nvim')
  call dein#add('Shougo/neomru.vim')
  call dein#add('Shougo/denite.nvim')
  call dein#add('Shougo/neosnippet.vim')
  call dein#add('Shougo/neosnippet-snippets')
  call dein#add('vim-scripts/dbext.vim')
  call dein#add('osyo-manga/vim-anzu')
  call dein#add('tyru/caw.vim')
  call dein#add('kana/vim-submode')
  call dein#add('kana/vim-smartinput')
  call dein#add('kana/vim-textobj-user')
  call dein#add('rhysd/clever-f.vim')
  call dein#add('rhysd/vim-textobj-ruby')
  call dein#add('sgur/vim-textobj-parameter')
  call dein#add('osyo-manga/vim-textobj-multiblock')
  call dein#add('osyo-manga/vim-textobj-multitextobj')
  call dein#add('kana/vim-operator-user')
  call dein#add('thinca/vim-quickrun')
  call dein#add('thinca/vim-localrc')
  call dein#add('Yggdroot/indentLine')
  call dein#add('itchyny/lightline.vim')
  call dein#add('airblade/vim-gitgutter')
  "call dein#add('neomake/neomake')
  call dein#add('w0rp/ale')

  " rust
  call dein#add('rust-lang/rust.vim')
  call dein#add('racer-rust/vim-racer')

  " go
  call dein#add('Shougo/deoplete.nvim')
  call dein#add('zchee/deoplete-go')
  call dein#add('benekastah/neomake')
  call dein#add('fatih/vim-go')

  " ruby
  call dein#add('tpope/vim-rails')
  call dein#add('tpope/vim-bundler')

  " python
  call dein#add('zchee/deoplete-jedi')

  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable

if dein#check_install()
  call dein#install()
endif

""" Deoplete
let g:deoplete#enable_at_startup = 1

let g:deoplete#omni#input_patterns = {}
		let g:deoplete#omni#input_patterns.ruby =
		\ ['[^. *\t]\.\w*', '[a-zA-Z_]\w*::']

""" racer
set hidden
let g:racer_cmd = "~/.cargo/bin/racer/target/release/racer"
" let $RUST_SRC_PATH #terminal上で設定しているはず
"

""" Denite
" denite key bind
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

nnoremap <silent> [denite]<Space> :<C-u>Denite menu<CR>

let g:neomru#time_format = "(%Y/%m/%d %H:%M:%S) "

"""""""""""""o
" Change file_rec command.
" For silver searcher
"call denite#custom#var('file_rec', 'command',
"\ ['ag', '--follow', '--nocolor', '--nogroup', '-g', ''])

" For ripgrep
" Note: It is slower than ag
call denite#custom#var('file_rec', 'command',
\ ['rg', '--files', '--glob', '!.git'])

" Change mappings.
call denite#custom#map('insert', '<C-p>', '<denite:move_to_prev_line>')
call denite#custom#map('insert', '<C-n>', '<denite:move_to_next_line>')

" Change matchers.
call denite#custom#source(
\ 'file_mru', 'matchers', ['matcher_fuzzy', 'matcher_project_files'])
call denite#custom#source(
\ 'file_rec', 'matchers', ['matcher_cpsm'])

" Change sorters.
call denite#custom#source(
\ 'file_rec', 'sorters', ['sorter_sublime'])

" Ripgrep command on grep source
call denite#custom#var('grep', 'command', ['rg'])
call denite#custom#var('grep', 'default_opts',
		\ ['--vimgrep', '--no-heading'])
call denite#custom#var('grep', 'recursive_opts', [])
call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
call denite#custom#var('grep', 'separator', ['--'])
call denite#custom#var('grep', 'final_opts', [])

" Add custom menus
let s:menus = {}

let s:menus.nvim = {
	\ 'description': 'Edit your import nvim configuration'
	\ }
let s:menus.nvim.file_candidates = [
	\ ['init.vim', '~/.config/nvim/init.vim'],
	\ ['ginit.vim', '~/.config/nvim/ginit.vim'],
	\ ]

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
let s:menus.tmux.file_candidates = [
	\ ['tmux.conf', '~/.tmux.conf'],
	\ ]

let s:menus.my_commands = {
	\ 'description': 'Example commands'
	\ }
let s:menus.my_commands.command_candidates = [
	\ ['Open nvim menu', 'Denite menu:nvim'],
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

""" neosnippet
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" SuperTab like snippets' behavior.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
"imap <expr><TAB>
" \ pumvisible() ? "\<C-n>" :
" \ neosnippet#expandable_or_jumpable() ?
" \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
"smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
" \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For conceal markers.
if has('conceal')
  set conceallevel=2 concealcursor=niv
endif

" path to mysnippet
let s:mysnip_path=dein#get('mysnip').path
let g:neosnippet#snippets_directory=s:mysnip_path

" Enable snipMate compatibility feature.
" let g:neosnippet#enable_snipmate_compatibility = 1

""" neomake
" autocmd! BufWritePost,BufEnter * Neomake
" " neomake uses robocop for ruby
" let g:neomake_ruby_enabled_makers = ['rubocop']
"
" let g:neomake_error_sign   = {'text': '>>', 'texthl': 'Error'}
" let g:neomake_warning_sign = {'text': '>>', 'texthl': 'Todo'}
let g:ale_linters = {
      \   'ruby': ['rubocop'],
      \}
let g:ale_sign_column_always = 1
let g:ale_sign_error = '>'
let g:ale_sign_warning = '>'

""" Whitespace
" uniteでスペースが表示されるので、設定でoffる
let g:extra_whitespace_ignored_filetypes = ['unite', 'vimfiler']

""" anzu
" こっちを使用すると
" 移動後にステータス情報をコマンドラインへと出力を行います。
" statusline を使用したくない場合はこっちを使用して下さい。
nmap n <Plug>(anzu-n-with-echo)
nmap N <Plug>(anzu-N-with-echo)
nmap * <Plug>(anzu-star-with-echo)
nmap # <Plug>(anzu-sharp-with-echo)

""" clever-f
nmap [myleader]f <Plug>(clever-f-reset)
let g:clever_f_use_migemo = 1

""" submode
" let g:submode_timeout = 0
" TELLME: The above setting do not work.
" Use the following instead of above.
let g:submode_timeoutlen = 1000000

let g:submode_keep_leaving_key=1

" http://d.hatena.ne.jp/thinca/20130131/1359567419
" https://gist.github.com/thinca/1518874
" Window size mode.
call submode#enter_with('winsize', 'n', '', '<C-w>>', '<C-w>>')
call submode#enter_with('winsize', 'n', '', '<C-w><', '<C-w><')
call submode#enter_with('winsize', 'n', '', '<C-w>+', '<C-w>+')
call submode#enter_with('winsize', 'n', '', '<C-w>-', '<C-w>-')
call submode#map('winsize', 'n', '', '>', '<C-w>>')
call submode#map('winsize', 'n', '', '<', '<C-w><')
call submode#map('winsize', 'n', '', '+', '<C-w>+')
call submode#map('winsize', 'n', '', '-', '<C-w>-')

" Tab move mode.
call submode#enter_with('tabmove', 'n', '', 'gt', 'gt')
call submode#enter_with('tabmove', 'n', '', 'gT', 'gT')
call submode#map('tabmove', 'n', '', 't', 'gt')
call submode#map('tabmove', 'n', '', 'T', 'gT')

""" smartinput
let g:smartinput_no_default_key_mappings = 1

" <CR>をsmartinputの処理付きの物を指定する版
call smartinput#map_to_trigger( 'i', '<Plug>(physical_key_CR)', '<CR>', '<CR>')
imap <CR> <Plug>(physical_key_CR)

" 改行時に行末スペースを削除する
call smartinput#define_rule({
      \   'at': '\s\+\%#',
      \   'char': '<CR>',
      \   'input': "<C-o>:call setline('.', substitute(getline('.'), '\\s\\+$', '', ''))<CR><CR>",
      \   })

" 対になるものの入力。無駄な空白は削除
call smartinput#map_to_trigger('i', '<Space>', '<Space>', '<Space>')
call smartinput#define_rule({ 'at': '\%#',    'char': '(', 'input': '(<Space>', })
call smartinput#define_rule({ 'at': '( *\%#', 'char': ')', 'input': '<BS>)', })
call smartinput#define_rule({ 'at': '\%#',    'char': '{', 'input': '{<Space>', })
call smartinput#define_rule({ 'at': '{ *\%#', 'char': '}', 'input': '<BS>}', })
call smartinput#define_rule({ 'at': '\%#',    'char': '[', 'input': '[<Space>', })
call smartinput#define_rule({ 'at': '[ *\%#', 'char': ']', 'input': '<BS>]', })

""" IndentLine
let g:indentLine_faster = 1
" IndentLinesReset

""" lightline
let s:colorscheme = 'wombat'
if !empty($COLORSCHEME)
  let s:colorscheme = $COLORSCHEME
endif
let g:lightline = {
      \ 'colorscheme': s:colorscheme,
      \ 'separator': { 'left': "\ue0b0", 'right': "\ue0b2" },
      \ 'subseparator': { 'left': "\u20b1", 'right': "\ue0b3" },
      \ 'mode_map': {'c': 'NORMAL'},
      \ 'active': {
      \   'left': [
      \     [ 'mode', 'plugin', 'paste' ],
      \     [ 'fugitive', 'filename' ],
      \     [ 'pwd' ]
      \   ],
      \   'right': [
      \     ['lineinfo', 'syntax_check'],
      \     ['percent'],
      \     ['charcode', 'fileformat', 'fileencoding', 'filetype']
      \   ]
      \ },
      \ 'component_function': {
      \   'mode': 'MyMode',
      \   'plugin': 'MySpPlugin',
      \   'fugitive': 'MyFugitive',
      \   'gitgutter': 'MyGitgutter',
      \   'filename': 'MyFilename',
      \   'pwd': 'MyPwd',
      \   'charcode': 'MyCharCode',
      \   'fileformat': 'MyFileformat',
      \   'fileencoding': 'MyFileencoding',
      \   'filetype': 'MyFiletype'
      \ },
      \ 'conponent_expand': {
      \   'syntax_check': 'qfstatusline#Update',
      \ },
      \ 'conponent_type': {
      \   'syntax_check': 'error',
      \ },
      \}

function! MyModified()
  return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! MyReadonly()
  return &readonly ? '⭤'  : ''
endfunction

function! MyFilename()
  let fname = expand('%:t')
  return
        \ fname =~ '__Gundo' ? '' :
        \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
        \  &ft == 'unite' ? unite#get_status_string() :
        \  &ft == 'vimshell' ? vimshell#get_status_string() :
        \ ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
        \ ('' != MyModified() ? ' ' . MyModified() : '') .
        \ '' != fname ? fname : '[No Name]')
endfunction

function! MyFugitive()
  try
    if expand('%:t') !~? 'Gundo\|NERD' && &ft !~? 'vimfiler' && exists('*fugitive#head')
      let _ = fugitive#head()
      return strlen(_) ? '⭠ '._ : ''
    endif
  catch
  endtry
  return ''
endfunction

function! MyGitgutter()
  if ! exists('*GitGutterGetHunkSummary')
        \ || ! get(g:, 'gitgutter_enabled', 0)
        \ || winwidth('.') <= 90
    return ''
  endif
  let symbols = [
        \ g:gitgutter_sign_added . ' ',
        \ g:gitgutter_sign_modified . ' ',
        \ g:gitgutter_sign_removed . ' '
        \ ]
  let hunks = GitGutterGetHunkSummary()
  let ret = []
  for i in [0, 1, 2]
    if hunks[i] > 0
      call add(ret, symbols[i] . hunks[i])
    endif
  endfor
  return join(ret, ' ')
endfunction
function! MyFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! MyFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! MyFileencoding()
  return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! MyMode()
  return winwidth(0) > 60 ? lightline#mode() : ''
endfunction

function! MySpPlugin()
  let fname = expand('%:t')
  return  winwidth(0) <= 60 ? '' :
        \ fname == '__Gundo__' ? 'Gundo' :
        \ fname == '__Gundo_Preview__' ? 'Gundo Preview' :
        \ &ft == 'unite' ? 'Unite' :
        \ &ft == 'vimfiler' ? 'VimFiler' :
        \ &ft == 'vimshell' ? 'VimShell' :
        \ ''
endfunction

function! MyPwd()
  if winwidth(0) > 60
    " $HOMEは'~'表示の方が好きなので置き換え
    let s:homepath = expand('~')
    return substitute(getcwd(), expand('~'), '~', '')
  else
    return ''
  endif
endfunction


function! MyCharCode()
  if winwidth('.') <= 70
    return ''
  endif

  " Get the output of :ascii
  redir => ascii
  silent! ascii
  redir END

  if match(ascii, 'NUL') != -1
    return 'NUL'
  endif

  " Zero pad hex values
  let nrformat = '0x%02x'

  let encoding = (&fenc == '' ? &enc : &fenc)

  if encoding == 'utf-8'
    " Zero pad with 4 zeroes in unicode files
    let nrformat = '0x%04x'
  endif

  " Get the character and the numeric value from the return value of :ascii
  " This matches the two first pieces of the return value, e.g.
  " "<F>  70" => char: 'F', nr: '70'
  let [str, char, nr; rest] = matchlist(ascii, '\v\<(.{-1,})\>\s*([0-9]+)')

  " Format the numeric value
  let nr = printf(nrformat, nr)

  return "'". char ."' ". nr
endfunction

""" quickrun
" vimprocで起動
" バッファが空なら閉じる
let g:quickrun_config = get(g:, 'quickrun_config', {})
let g:quickrun_config._ = {
      \   'outputter/buffer/split' : ':botright',
      \   'outputter/buffer/close_on_empty' : 1,
      \}
"      \   'runner' : 'vimproc',
"      \   'runner/vimproc/updatetime' : 60,
let g:quickrun_config['rust'] = {
      \   'type' : 'rust/cargo',
      \}

""" textobj-multiblock
vmap ab <Plug>(textobj-multiblock-a)
vmap ib <Plug>(textobj-multiblock-i)

""" caw
nmap <Leader>c <Plug>(caw:hatpos:toggle)
vmap <Leader>c <Plug>(caw:hatpos:toggle)


if has('unix')
  if !has('gui_running')
    colorscheme desert
  endif
endif
