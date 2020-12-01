
colo custom_base16

" Disable conceal syntax that is redundant with font ligatures
let g:font_ligatures_enabled = 1

" Add personal notes
call insert(g:nv_search_paths, '~/compendium')

" Dictionary
let g:localDictionary = '~/compendium/eBooks/Reference/Dictionary/index.txt'
if rc#File(g:localDictionary) != ''
  map <leader>\d :call rc#SearchFile(g:localDictionary, '^\C' . toupper(input('Dictionary Search: ')))<CR>
endif

" Thesaurus
let g:localThesaurus = '~/compendium/eBooks/Reference/Thesaurus/index.txt'
if rc#File(g:localThesaurus) != ''
  map <leader>\t :call rc#SearchFile(g:localThesaurus, '^' . input('Thesaurus Search: '))<CR>
endif

" Computing Dictionary
let g:localComputingDictionary = '~/compendium/eBooks/Reference/FOLDOC/index.txt'
if rc#File(g:localComputingDictionary) != ''
  map <leader>\f :call rc#SearchFile(g:localComputingDictionary, input('FOLDOC Search: '))<CR>
endif

" Web Development
let g:onlineDevSearch = 'https://developer.mozilla.org/en-US/search?q='
map <silent> <leader>vm :exe "call rc_vue#ReadUrl('" . g:onlineDevSearch . input('Online Dev Search: ') . "')"<CR>
map <silent> <leader>VM :exe "call rc_vue#GoToUrl('" . g:onlineDevSearch . input('Online Dev Search: ') . "')"<CR>

" BZB
let g:BZB_Command=expand('$HOME') . '/bin/b'
