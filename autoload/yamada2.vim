let s:data_dir = expand('<sfile>:h:h') . '/data'

function! yamada2#Yamada()
  let images = []
  for f in split(glob(s:data_dir . '/*'), "\n")
    let lines = readfile(f)
    let pos = index(lines, '/* pixels */')
    let colors = []
    for line in lines[4:pos-1]
      let s = line[1:-3]
      call add(colors, printf('syntax match yamada%s /[\x%02X][\x%02X]/', s[6:], char2nr(s[0]), char2nr(s[1])))
      exe printf('highlight yamada%s guifg=''%s'' guibg=''%s''', s[6:], s[5:], s[5:])
    endfor
    call add(images, {
    \ "colors" : colors,
    \ "data" : map(lines[pos+1 :], 'matchstr(v:val, ''^"\zs.\+\ze",\?$'')')
    \})
  endfor

  silent edit `='==YAMADA=='`
  silent normal! gg0
  silent only!
  setlocal buftype=nowrite
  setlocal noswapfile
  setlocal bufhidden=wipe
  setlocal buftype=nofile
  setlocal nonumber
  setlocal nolist
  setlocal nowrap
  setlocal nocursorline
  setlocal nocursorcolumn

  let l = len(images)
  let i = 0
  redraw
  while getchar(0) == 0
    let image = images[i % l]
    silent! syntax clear yamada
    for c in image.colors
      exe c
    endfor
    call setline(1, image.data)
    let i += 1
    redraw
  endwhile
  bw!
endfunction

" vim:set et:
