"
"  function 'SitePrefix' culled from 'Author' by Luc Hermitte(?) in his
"  mu-template file
"
function! SitePrefix(...)
  let short = (a:0>0 && a:1==1) ? '_short' : ''
  if     exists('b:siteprefix'.short) | return b:siteprefix{short}
  elseif exists('g:siteprefix'.short) | return g:siteprefix{short}
  else                            | return ''
  endif
endfunction
"
" Function ShortTabLine from 'Hacking VIM' (Kim Schulz)
"
function! ShortTabLine()
  let ret = ''
  for i in range(tabpagenr('$'))
"
"   select the colour group for highlighting the active tab
"
    if i + 1 == tabpagenr()
      let ret .= '%#errorMsg#'
    else
      let ret .= '%#TabLine#'
    endif
"
"   find the buffer name for the tab label
"
    let buflist = tabpagebuflist(i + 1)
    let winnr = tabpagewinnr(i + 1)
    let buffername = bufname(buflist[winnr - 1])
    let filename = fnamemodify(buffername,':t')
"
"   Check to see if there is no name
"
    if filename == ''
      let filename = '(No Name)'
    endif
    if strlen( filename ) > 12
"
"     Show up to 12 letters of the file name, truncated to 10
"     plus an ellipsis if the name is longer then 12
"
      let ret .= filename[0:9] . '..'
    else
"
"     Pad the file name, out to 12 letters
"
      let ret .= strpart(filename . '          ',0, 12 )
    endif
  endfor
"
" After the last tab fill with tablinefill  and reset the tab page
"
  let ret .= '%#TabLineFill#%T'
  return ret
endfunction

fun! vim_addon_AndyLong#Activate(vam_features)
  let g:vim_addon_urweb = { 'use_vim_addon_async' : 1 }
  let g:netrw_silent = 0
  let g:linux=1
  let g:config = { 'goto-thing-handler-mapping-lhs' : 'gf' }

  let plugins = {
      \ 'always': ['vim-addon-completion', 'vim-addon-async', 'tlib', 'vim-addon-toggle-buffer', 'vim-addon-git', 'vim-addon-mw-utils', 'snipMate', 'vim-addon-goto-thing-at-cursor', 'matchit.zip', 'VisIncr', 'YankRing', 'vcscommand', 'searchInRuntime', 'AutoAlign', 'Align294', 'vim-addon-signs'], 
      \ 'extra' : ['textobj-diff', 'textobj-function', 'narrow_region'], 
      \ 'vim': ['reload', 'vim-dev-plugin'], 
      \ 'vme': ['github:AndyLong/vim-syntax-vme-scl', 'github:AndyLong/vim-syntax-vme-mtup', 'github:AndyLong/vim-syntax-vme-ddcl', 'github:AndyLong/vim-syntax-vme-idmsx', 'github:AndyLong/vim-syntax-vme-tp-pfile', 'github:AndyLong/vim-syntax-vme-tp-tpstats', 'github:AndyLong/vim-syntax-vme-tp-tptext', 'github:AndyLong/vim-syntax-vme-tp-tsin' ], 
      \ 'sql': ['vim-addon-sql'], 
      \ 'urweb': ['vim-addon-urweb'], 
      \ 'nix' : ['vim-addon-nix'], 
      \ }
  let activate = []
  for [k,v] in items(plugins)
    if k == 'always' 
          \ || (type(a:vam_features) == type([]) && index(a:vam_features, k) >= 0)
          \ || (type(a:vam_features) == type('') && a:vam_features == 'all')
      echoe "Selecting addon '".k."'"
      call extend(activate, v)
      echoe "selected"
    endif
  endfor

  " trailing-whitespace.vim 
  " "yaifa",
  " "vim-addon-blender-scripting",
  " scion-backend-vim",
  " "JSON", 
  " "vim-addon-povray",
  " "vim-addon-lout",
  " \ "delimitMate",
  echoe "activating selected add-ons"
  call vam#ActivateAddons(activate,{'auto_install':1})
  echoe "Activated?"

  " command MergePluginFiles call vam#install#MergePluginFiles(g:merge+["tlib"], '\%(cmdlinehelp\|concordance\|evalselection\|glark\|hookcursormoved\|linglang\|livetimestamp\|localvariables\|loremipsum\|my_tinymode\|pim\|scalefont\|setsyntax\|shymenu\|spec\|tassert\|tbak\|tbibtools\|tcalc\|tcomment\|techopair\|tgpg\|tmarks\|tmboxbrowser\|tortoisesvn\|tregisters\|tselectbuffer\|tselectfile\|tsession\|tskeleton\|tstatus\|viki\|vikitasks\)\.vim_merged')
  " command UnmergePluginFiles call vam#install#UnmergePluginFiles()

  noremap <m-w>/ /\<\><left><left>
  noremap <m-w>? ?\<\><left><left>
  noremap <c-,> :cprevious<cr>
  noremap <c-c> :cnext<cr>



  " inoremap <C-x><C-w> <c-o>:setlocal omnifunc=vim_addon_completion#CompleteWordsInBuffer<cr><c-x><c-o>
  inoremap <C-x><C-w> <c-r>=vim_addon_completion#CompleteUsing('vim_addon_completion#CompleteWordsInBuffer')<cr>

  if !has('gui_running')
    set timeoutlen=200
  endif
  " set guioptions+=c
  set guioptions+=M
  set guioptions-=m
  set guioptions-=T
  set guioptions-=r
  set guioptions-=l

  set clipboard=unnamed
  let tags = split(&tags,',')
  for i in split(expand('$buildInputs'),'\s\+')
    call extend(tags, split(glob(i.'/src/*/*_tags'),"\n"))
  endfor
  call extend(tags, split($TAG_FILES,":"))
  call filter(tags, 'filereadable(v:val)')
  for t in tags
    exec "set tags+=".t
  endfor


  augroup ADD_CONFLICT_MARKERS_MATCH_WORDS
    " git onlny for now
    autocmd BufRead,BufNewFile * exec 'let b:match_words '.(exists('b:match_words') ? '.' : '').'= '.string(exists('b:match_words') ? ',' : ''.'<<<<<<<:=======:>>>>>>>')
  augroup end


"  command! AsyncSh call async_porcelaine#LogToBuffer({'cmd':'/bin/sh -i', 'move_last':1, 'prompt': '^.*\$[$] '})
"  command! AsyncCoq call async_porcelaine#LogToBuffer({'cmd':'coqtop', 'move_last':1, 'prompt': '^Coq < '})
"  command! AsyncRubyIrb call repl_ruby#RubyBuffer({'cmd':'irb','move_last' : 1})
"  command! AsyncRubySh call repl_ruby#RubyBuffer({'cmd':'/bin/sh','move_last' : 1})
"  command! AsyncPython call repl_python#PythonBuffer({'cmd':'python -i','move_last' : 1, 'prompt': '^>>> '})
"  command! AsyncSMLNJ call repl_ruby#RubyBuffer({'cmd':'sml','move_last' : 1, 'prompt': '^- '})

  "autocommands:"{{{
    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid or when inside an event handler
    " (happens when dropping a file on gvim).
    autocmd BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line("$") |
      \   exe "normal g`\"" |
      \ endif
  "}}}e
  
 
  "window cursor movement
  nnoremap <m-s-v><m-s-p> :exec "wincmd g\<c-]>" <bar> exec 'syntax keyword Tag '.expand('<cword>')<cr>
  vnoremap <m-s-v><m-s-p> y:sp<bar>tjump <c-r>"<cr>
   
  nnoremap <m-b><m-n> :bn<cr>
  nnoremap <m-b><m-p> :bp<cr>
  nnoremap <m-a> :b<space>

  imap <c-o> <c-x><c-o>
  imap <c-_> <c-x><c-u>

  noremap \a :ActionOnWrite<cr>
  noremap \A :ActionOnWrite!<cr>

  noremap \aps : if filereadable('pkgs/top-level/all-packages.nix') <bar> e pkgs/top-level/all-packages.nix <bar> else <bar> exec 'e '.expand("$NIXPKGS_ALL") <bar> endif<cr>

  noremap <m-s-f> :e! %<cr>

  command! SlowTerminalSettings :set slow-terminal| set sidescroll=20 | set scrolljump=10 | set noshowcmd

  noremap <leader>lt :set invlist<cr>
  noremap <leader>iw :set invwrap<cr>
  noremap <leader>ip :set invpaste<cr>
  noremap <leader>hl :set invhlsearch<cr>
  noremap <leader>dt :diffthis<cr>
  noremap <leader>do :diffoff<cr>
  noremap <leader>dg :diffget<cr>
  noremap <leader>du :diffupdate<cr>
  noremap <leader>ts :if exists("syntax_on") <Bar>
  \   syntax off <Bar>
  \ else <Bar>
  \   syntax enable <Bar>
  \ endif <CR>
  inoremap <s-cr> <esc>o
  noremap <m-s-e><m-s-n> :enew<cr>
  inoremap <c-cr> <esc>O
  noremap <m--> k$
  noremap <m-s-a> <esc>jA
  noremap <m-e> :e<space>

  set foldlevel=1
  set foldlevelstart=1

  let match_ignorecase=1
"
" YankRing plugin options
"
  let g:yankring_history_dir = '$VIMHOME'
  nnoremap <silent> <F2> :YRShow<CR>

"
" Load generic abbreviations from files'abbreviations.vim' in system-wide
" locations and personal ones
"
  runtime abbreviations.vim

  set tabline=%!ShortTabLine()
"
"  Alternative implementation for 'gf'... 
"
  map gf :edit <cfile><CR>
"
"  ... And add a list of common program file suffixes
"
  set suffixesadd=".scl,.cbl,.mtup,.vim,,pl,.sh,.java,.c,.cpp,.h"
"
"  Use <Alt-Up>, <Alt-Down> to navigate visually between lines
"
  map <A-Down> gj
  map <A-Up> gk
  imap <A-Down> <ESC>gji
  imap <A-Up> <ESC>gki
"
"  Use <Alt-PageUp>, <Alt-PageDown> to navigate between buffers
"
  nmap <A-PageDown> :bn<CR>
  nmap <A-PageUp> :bp<CR>
"
"  Make 'F1' look for help for words that are close to the cursor
"
  imap <F1> <ESC>:exec "help " . expand("<cWORD>")<CR>
  nmap <F1> :exec "help " . expand("<cWORD>")<CR>
"
"  Suggest a spelling for the word at the cursor
"
  map <F7> z=
  imap <F7> <ESC>z=
"
"  Place a sign in the file
"
  sign define information text=!> linehl=Warning texthl=Error icon=/Users/andy/Pictures/right-arrow.png
  map <F6> :exe ":sign place 123 line=" . line(".") . " name=information file=" . expand("%:p")<CR>
  map <S-F6> :sign unplace<CR>
"
"  Change default YankRing <Ctrl-N> & <Ctrl-P> (replace paste with next/previous 
"  yankring items), because they interfere with autocompletion
"
  let g:yankring_replace_n_pkey = '<C-S-P>'
  let g:yankring_replace_n_nkey = '<C-S-N>'
endf

