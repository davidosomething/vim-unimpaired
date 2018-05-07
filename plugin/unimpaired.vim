" unimpaired.vim - Pairs of handy bracket mappings
" Maintainer:   David O'Trakoun (@davidosomething)
" Version:      4.0

if exists("g:loaded_unimpaired") || &cp || v:version < 700
  finish
endif
let g:loaded_unimpaired = 1

let s:maps = []
function! s:map(...) abort
  call add(s:maps, a:000)
endfunction

function! s:maps() abort
  for [mode, head, rhs; rest] in s:maps
    let flags = get(rest, 0, '') . (rhs =~# '^<Plug>' ? '' : '<script>')
    let tail = ''
    let keys = get(g:, mode.'remap', {})
    if type(keys) != type({})
      continue
    endif
    while !empty(head)
      if has_key(keys, head)
        let head = keys[head]
        if empty(head)
          return
        endif
        break
      endif
      let tail = matchstr(head, '<[^<>]*>$\|.$') . tail
      let head = substitute(head, '<[^<>]*>$\|.$', '', '')
    endwhile
    exe mode.'map' flags head.tail rhs
  endfor
endfunction

" Section: Next and previous

function! s:MapNextFamily(map,cmd) abort
  let map = '<Plug>unimpaired'.toupper(a:map)
  let cmd = '".(v:count ? v:count : "")."'.a:cmd
  let end = '"<CR>'.(a:cmd ==# 'l' || a:cmd ==# 'c' ? 'zv' : '')
  execute 'nnoremap <silent> '.map.'Previous :<C-U>exe "'.cmd.'previous'.end
  execute 'nnoremap <silent> '.map.'Next     :<C-U>exe "'.cmd.'next'.end
  execute 'nnoremap <silent> '.map.'First    :<C-U>exe "'.cmd.'first'.end
  execute 'nnoremap <silent> '.map.'Last     :<C-U>exe "'.cmd.'last'.end
  call s:map('n', '['.        a:map , map.'Previous')
  call s:map('n', ']'.        a:map , map.'Next')
  call s:map('n', '['.toupper(a:map), map.'First')
  call s:map('n', ']'.toupper(a:map), map.'Last')
endfunction

call s:MapNextFamily('b','b')
call s:MapNextFamily('t','t')

call s:map('n', '[n', '<Plug>unimpairedContextPrevious')
call s:map('n', ']n', '<Plug>unimpairedContextNext')
call s:map('o', '[n', '<Plug>unimpairedContextPrevious')
call s:map('o', ']n', '<Plug>unimpairedContextNext')

nnoremap <silent> <Plug>unimpairedContextPrevious :call <SID>Context(1)<CR>
nnoremap <silent> <Plug>unimpairedContextNext     :call <SID>Context(0)<CR>
onoremap <silent> <Plug>unimpairedContextPrevious :call <SID>ContextMotion(1)<CR>
onoremap <silent> <Plug>unimpairedContextNext     :call <SID>ContextMotion(0)<CR>

function! s:Context(reverse) abort
  call search('^\(@@ .* @@\|[<=>|]\{7}[<=>|]\@!\)', a:reverse ? 'bW' : 'W')
endfunction

function! s:ContextMotion(reverse) abort
  if a:reverse
    -
  endif
  call search('^@@ .* @@\|^diff \|^[<=>|]\{7}[<=>|]\@!', 'bWc')
  if getline('.') =~# '^diff '
    let end = search('^diff ', 'Wn') - 1
    if end < 0
      let end = line('$')
    endif
  elseif getline('.') =~# '^@@ '
    let end = search('^@@ .* @@\|^diff ', 'Wn') - 1
    if end < 0
      let end = line('$')
    endif
  elseif getline('.') =~# '^=\{7\}'
    +
    let end = search('^>\{7}>\@!', 'Wnc')
  elseif getline('.') =~# '^[<=>|]\{7\}'
    let end = search('^[<=>|]\{7}[<=>|]\@!', 'Wn') - 1
  else
    return
  endif
  if end > line('.')
    execute 'normal! V'.(end - line('.')).'j'
  elseif end == line('.')
    normal! V
  endif
endfunction

" Section: Activation

augroup unimpaired
  autocmd!
  autocmd VimEnter * call s:maps()
augroup END

if !has('vim_starting')
  call s:maps()
endif

" vim:set sw=2 sts=2:
