let s:data_dir = expand('<sfile>:h:h') . '/data'

function! s:gui2cui(rgb)
  let rgb = map(matchlist(a:rgb, '#\(..\)\(..\)\(..\)')[1:3], '0 + ("0x".v:val)')
  let rgb = [rgb[0] > 127 ? 4 : 0, rgb[1] > 127 ? 2 : 0, rgb[2] > 127 ? 1 : 0]
  return rgb[0] + rgb[1] + rgb[2]
endfunction

function! yamada2#Yamada()
  let images = []
  for f in sort(split(glob(s:data_dir . '/*.xpm'), "\n"))
    let lines = readfile(f)
    let pos1 = index(lines, '/* columns rows colors chars-per-pixel */')
    let pos2 = index(lines, '/* pixels */')
    let colors = []
    for line in lines[pos1+2:pos2-1]
      let s = split(line[1:-3], ' c ')
      call add(colors, printf('syntax match yamada%s /%s/', s[1][1:], join(map(split(s[0], '\zs'), 'printf("[\\x%02x]",char2nr(v:val))'), '')))
      exe printf("highlight yamada%s guifg='%s' guibg='%s' ctermfg=%d ctermbg=%d", s[1][1:], s[1], s[1], s:gui2cui(s[1]), s:gui2cui(s[1]))
    endfor
    call add(images, {
    \ "colors" : colors,
    \ "data" : map(lines[pos2+1 :], 'matchstr(v:val, ''^"\zs.\+\ze",\?$'')')
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
    silent! syntax clear
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
