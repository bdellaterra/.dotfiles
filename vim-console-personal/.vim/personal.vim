
" Disable conceal syntax that is redundant with font ligatures
let g:font_ligatures_enabled = 1

" Add personal notes
call insert(g:nv_search_paths, '~/compendium')

" Dictionary
let g:localDictionary = '~/compendium/eBooks/Reference/Dictionary/index.txt'
if File(g:localDictionary) != ''
  map <leader>\d :call SearchFile(g:localDictionary, '^\C' . toupper(input('Dictionary Search: ')))<CR>
endif

" Thesaurus
let g:localThesaurus = '~/compendium/eBooks/Reference/Thesaurus/index.txt'
if File(g:localThesaurus) != ''
  map <leader>\t :call SearchFile(g:localThesaurus, '^' . input('Thesaurus Search: '))<CR>
endif

" Computing Dictionary
let g:localComputingDictionary = '~/compendium/eBooks/Reference/FOLDOC/index.txt'
if File(g:localComputingDictionary) != ''
  map <leader>\f :call SearchFile(g:localComputingDictionary, input('FOLDOC Search: '))<CR>
endif

" Etymology
let g:onlineSearch = 'https://www.etymonline.com/search?q='
map <silent> <leader>ve :exe "call ReadUrl('" . g:onlineEtymology . input('Online Etymology Search: ') . "')"<CR>
map <silent> <leader>VE :exe "call GoToUrl('" . g:onlineEtymology . input('Online Etymology Search: ') . "')"<CR>

" Web Development
let g:onlineDevSearch = 'https://developer.mozilla.org/en-US/search?q='
map <silent> <leader>vd :exe "call ReadUrl('" . g:onlineDevSearch . input('Online Dev Search: ') . "')"<CR>
map <silent> <leader>VD :exe "call GoToUrl('" . g:onlineDevSearch . input('Online Dev Search: ') . "')"<CR>

