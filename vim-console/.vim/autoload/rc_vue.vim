if &cp || exists("g:loaded_rc_vue_plugin")
 finish
endif
let g:loaded_rc_vue_plugin = "v01"
let s:keepcpo        = &cpo
set cpo&vim


" Regex Patterns
let g:rgx = {}
let g:rgx.urlProtocol = '[a-zA-Z]*:\/\/'
let g:rgx.urlPathChar = '[^][ <>,;()]'
let g:rgx.urlQuery = '?' . g:rgx.urlPathChar . '*'
let g:rgx.url = '\(' . g:rgx.urlProtocol . g:rgx.urlPathChar . '*\)'
let g:rgx.urlFile = g:rgx.urlPathChar . '\{-}\([^/]\{-}\)' . '\%( . g:rgx.urlQuery . \)\?'
let g:rgx.mdLabel = '\['. '\([^]]*\)' . '\]' " 'md' for 'markdown'
let g:rgx.mdTargetName = '\([^)]\{-}\)'
let g:rgx.mdTargetAnchor = '\%(' . '#' . '\([^)]*\)' . '\)\?'
let g:rgx.mdTargetExtra = '\%(\s\+"[^"]*"\)\?'
let g:rgx.mdTarget = '(' . '\('
  \ . g:rgx.mdTargetName
  \ . g:rgx.mdTargetAnchor
  \ . g:rgx.mdTargetExtra
  \ . '\)' . ')'
let g:rgx.mdUrlTarget = '(' . '\('
  \ . g:rgx.url
  \ . g:rgx.mdTargetAnchor
  \ . g:rgx.mdTargetExtra
  \ . '\)' . ')'
let g:rgx.mdLinkPre = '\%([-•#]*\s*\)\?' " Possible bullet/heading marker
let g:rgx.mdLink = g:rgx.mdLinkPre . g:rgx.mdLabel . g:rgx.mdTarget
let g:rgx.mdLinkNoLabel =
  \ g:rgx.mdLinkPre
  \ . '<' . '\('
  \ . g:rgx.mdTargetName
  \ . g:rgx.mdTargetAnchor
  \ . '\)' . '>'
let g:rgx.mdUrlLink = g:rgx.mdLinkPre . g:rgx.mdLabel . g:rgx.mdUrlTarget
let g:rgx.mdUrlLinkNoLabel =
  \ g:rgx.mdLinkPre
  \ . '<' . '\('
  \ . g:rgx.url
  \ . g:rgx.mdTargetAnchor
  \ . '\)' . '>'
let g:rgx.mdRefLink = '\%(' . g:rgx.mdLabel . '\)\?' . g:rgx.mdLabel
let g:rgx.mdAfterLinkStart = '\%(<[^>]*\|([^)]*\|\[[^]]*\)'
let g:rgx.mdAnyLink = '\%('.g:rgx.mdLink.'\|'.g:rgx.mdLinkNoLabel.'\)'
let g:rgx.classNames = '\(\s*\.[a-z-]\+\)\{-}'
let g:rgx.styles = '\S\zs{'.g:rgx.classNames.'}'


function rc_vue#MatchUnderCursor(regex, ...)
  let outerRegex = a:regex
  let innerRegex = get(a:000, 1, a:regex)

  let cursorPos = getcurpos()[1:2]
  let startPos = searchpos(a:regex, 'ncb')
  let endPos = searchpos(a:regex, 'nce')

  let cursorOnLine = cursorPos[0] == startPos[0] && startPos[0] == endPos[0]
  let cursorInPattern = cursorPos[1] >= startPos[1] && cursorPos[1] <= endPos[1]

  if (cursorOnLine && cursorInPattern)
    let startPos = searchpos(outerRegex, 'bnc')[1]-1
    return matchlist(getline('.'), innerRegex, startPos)
  else
    return []
  endif
endfunction

function rc_vue#CursorIsOn(regex)
  return rc_vue#MatchUnderCursor(a:regex) != []
endfunction

" Create a list of alternate file paths based on (1) base file name
" (2) automatic extensions (3) index filenames for directory paths
function rc_vue#FilePattern(...)
  let name = get(a:000, 0, 'index')
  let extensions = get(a:000, 1, [])
  let indexes = get(a:000, 2, ['index'])
  let link = name
  let attempts = [link]
  if link !~ '^\.'
    let attempts += [ProjectRootGuess() . link]
  endif
  let attempts += map(copy(indexes), 'rc#DirSlashes(link).v:val')
  for a in copy(attempts)
    let attempts += map(copy(extensions), 'a.v:val')
  endfor
  return attempts
endfunction

function rc_vue#MarkdownHeadingJump(...)
  let headingCount = get(a:000, 0, 1)
  return 'normal gg' . string(headingCount) . ']]zt'
endfunction

function s:CleanPDFToMarkdown()
  " Add additional headings 
  silent! keepjumps %s@\v^(\*\*)((\w+\s?)?[^:)])(\([^)]*\))?\.(\*\*)@####### \2\r\r@g
  " Join headings that are split across multiple lines
  silent! keepjumps %s@\v^(#+)(.*)\n\_S*\1(.*)@\1\2\3@g
  " Capitalize headings
  silent! keepjumps %g@^#\+@s/\v\W\zs(\w)((\w|[’'-_])*)/\u\1\L\2/gI
  " Fix wonky mix of uppercase and lowercase
  silent! keepjumps %s/\v<([a-z])((\w|[’'-_])[A-Z]+(\w|[’'-_])*)/\u\1\L\2/gI
  silent! keepjumps %s/\v<([A-Z]+)((\w|[’'-_])[a-z](\w|[’'-_]))/\u\1\L\2/gI
  " Preceed headings and verbatim text with a blank line
  silent! keepjumps %s@\v(^```)\n(^```)@\1\r\r\2@g
  silent! keepjumps %s@\v.*\S.*\n\zs\ze#+.*@\r@g
  " Remove page numbers
  silent! keepjumps %s@^```\_s*\d\+\_s*```\_s*@@g
  " Just remove verbatim markers?
  silent! keepjumps %s#^```$##
endfunction

function s:CleanHtmlToMarkdown(...)
  let g:baseUrl = get(a:000, 0, '')
  let g:baseUrl = g:baseUrl =~ '^\w\+://' ? g:baseUrl : 'https://' . g:baseUrl
  let g:baseDomain = matchstr(g:baseUrl, '\w\+:\/\/\zs.*')
  let g:baseRegex = '\%(\%(\%(\%(\w\+:\)\?//\)\?www\.\)\?'.g:baseDomain.'[/\\]\?\)'

  " Preserve ids
  silent! keepjumps %s~{\(#[^ }]*\)\_[^}]\{-}}~[\1]~g

  " Strip CSS
  silent! keepjumps %s~\([])]\){\_[^}]\{-}}~\1~g
  silent! keepjumps %s~:::\s*\({\_[^}]\{-}}\)\?~~g "

  " Strip HTML
  silent! keepjumps %s~<!--\_.\{-}-->~~g " html comment
  silent! keepjumps %s~```{=[^}]*}\(\s*\n\)*```~~ " empty html code
  silent! keepjumps %s~\_s*<\/\?div\/\?>\_s*~\r~gi " div tags
  silent! keepjumps %s~\<\/\?span\/\?>~\r~gi " span tags

  " Mark used ref ids 
  silent! keepjumps %s~\(#\(\f\+\)\)\@>\_.*\zs\[\1\]\ze~[# \2]~g
  " Delete unused ref ids
  silent! keepjumps %s~\[#\S\f\+\]~~g
  
  " Remove unwanted line breaks
  silent! keepjumps %s~\[\zs\([^]]*\n\_[^]]*\)\ze\]~\=substitute(submatch(0), '\n\_s*', ' ', 'g')~g
  silent! keepjumps %s~<\zs\([^>]*\n\_[^>]*\)\ze>~\=substitute(submatch(0), '\n\_s*', ' ', 'g')~g
  silent! keepjumps %s~(\zs\([^)]*\n\_[^)]*\)\ze)~\=substitute(submatch(0), '\n\_s*', ' ', 'g')~g

  " Extract nested links
  silent! keepjumps %s~\[\(\[\_[^]]*\]\)\((\_[^)]\+)\)\?\]~\1\2~g
  silent! keepjumps %s~\[\(<\_[^>]*>\)\]~\1~g

  " Use alt text for labels
  silent! keepjumps %s~\[\%(\[\]\)\?\](\(\_[^)]\{-}\)\s*"\(\_[^"]*\)")~[\2](\1)~g
  silent! keepjumps %s~\[.\{-}\](\(\_[^)]\{-}\)\s*"\(\_[^"]*\)")~[\2](\1)~g
  
  " Convert remaining links with no label
  silent! keepjumps %s~\[\%(!\?\[\]\)\?\](\(\_[^)]\{-}\))~<\1>~g
  
  " Unescape characters
  silent! keepjumps %s~\\\?$~~g " newlines
  silent! keepjumps %s~\\\([-^@$'"._|\[\]]\)~\1~g " other characters

  " Remove empty brackets
  silent! keepjumps %s~\[\_s*\%(\[\_s*\]\)\?\_s*\]~~g
  silent! keepjumps %s~<\_s*[/\\#]\?\_s*>~~g

  " Excessively long dividers or wide tables
  silent! keepjumps %s~\_s*\_^\_s*\(\(-\|=\|+\)\{80}\)\2*\_s*\_$\_s*~\r\r\1\r\r~

  " Remove styling
  exe 'silent! keepjumps %s~'.g:rgx.styles.'~~gi'
  
  " Remove Advertisements
  silent! keepjumps %s~\[ad\%(vertisement\)\?\]\%(([^)]*)\)\?\s*\n~~gi

  " " Remove extra space around bullets
  silent! keepjumps %s~^\s*-\_s*\ze[^-]~- ~

  " Fix highlighting glitches
  silent! keepjumps %s~^\(-\s\)\?\zs\s\+\ze[[<*-\#]~\1~g " whitespace before links/headings/bullets
  silent! keepjumps %s~^\s*#~\r#~ " '#' headings must be at start of line and have a blank line above

  " add base url to links
  if g:baseUrl != ''
    exe 'silent! keepjumps %s~[(<]\zs'.g:baseRegex.'\ze~'.g:baseUrl.'/~gi'
    exe 'silent! keepjumps %s~[(<]\@>\%(#\|\w\+://\)\@!\zs[/\\]\ze~'.g:baseUrl.'/~gi'
  endif

  " add brackets around un-linked urls
  exe 'silent! keepjumps %s~\%(^\|\s\)\('.g:rgx.url.'\)\%($\|\s\)~<\1>~g' 

  " Remove whitespace
  silent! keepjumps %s~\(\_^[-*]\?\s*\n\)\+~\r~g " repeated empty lines (possibly just bullets)

  " Remove non-printable characters
  silent! keepjumps %s~​\|‎\|﻿~~gi
endfunction

let g:defaultPreHtmlToMdCleanup = executable('readability') ? "| readability '%s'" : ''
function rc_vue#ReadUrl(link, ...)
  let g:wwwDisableClean = a:link =~ '!$' ? 1 : 0
  let url = substitute(a:link, '!$', '', 'g')
  let url = substitute(url, ' ', '+', 'g')
  let url = url =~ '^\w\+://' ? url : 'https://' . url
  let g:url = url
  let jumpId = get(a:000, 0, '')
  let g:urlFilename = get(a:000, 1, '')
  if g:urlFilename == ''
    let safeUrl = matchstr(url, '\w\+:\/\/\zs.*') 
    let g:urlFilename = g:wwwDir . fnameescape(safeUrl)
    if safeUrl !~ '[/\\]'
      let g:urlFilename .= '/'
    endif
  endif
  let g:urlSaveDir = rc#MakeDir(fnamemodify(g:urlFilename, ':h'))
  exe 'cd ' . g:urlSaveDir
  try
    let g:urlSaveFile = rc#MakeFile(substitute(g:urlFilename, '[/\\]\zs\ze$', 'index', '')) . '.md'
    exe 'edit ' . g:urlSaveFile
  catch /E482/
    let g:urlSaveDir = rc#MakeDir(fnamemodify(g:urlFilename))
    exe 'cd ' . g:urlSaveDir
    let g:urlSaveFile = rc#MakeFile(g:urlFilename . '/index.md')
    exe 'edit ' . g:urlSaveFile
  catch /E484/
  endtry
  set modifiable
  set noreadonly
  keepjumps normal ggVGx
  if executable('chromium') && executable('pandoc')
    " Site-specific pre-cleanup, with readability as default
    let clean = ''
    for [siteRegex, syscmd] in g:preHtmlToMdCleanup
      if url =~ siteRegex
        " Adding space for truthiness so syscmd set to '' will clear default cleanup command
        silent! let clean .= ' ' . printf(syscmd, url)
      endif
    endfor
    silent! let clean = !g:wwwDisableClean && clean != '' ? clean : printf(g:defaultPreHtmlToMdCleanup, url)
    let browse = '2>/dev/null chromium --silent-launch --no-startup-window --headless --incognito --minimal --dump-dom "'.url.'"'
    let convert = ' | pandoc -f html -t markdown --columns=999'
    silent! exe 'r ! ' . browse . clean . convert
  elseif executable('curl') && executable('pandoc')
    silent! exe 'r ! curl -s ' . url . ' | pandoc -f html -t markdown'
  else
    throw "Error: Need pandoc and chromium/curl to browse web urls"
  endif
  let g:baseUrl = matchstr(a:link, '\(^\w\+:\/\/\)\?[^\/]*')
  silent! call s:CleanHtmlToMarkdown(g:baseUrl)
  " Add original source url to bottom
  exe "silent! keepjumps normal Go\<CR>Source: <" . url . ">"
  keepjumps normal gg
  " Site-specific post-cleanup
  for [siteRegex, cmd] in g:postHtmlToMdCleanup
    if url =~ siteRegex
      exe 'keepjumps ' . cmd
    endif
  endfor
  keepjumps call search('\%(' . '\%(<[^<]*\|([^(]*\)' . '\)\@<!' . '#\s*' . jumpId == '' ? 'main' : jumpId, 'c')
  set ft=pandoc
endfunction

function rc_vue#GoToUrl(...)
  let url = matchstr(get(a:000, 0, ''), g:rgx.url)
  let jumpId = get(a:000, 1, 0)
  let altEnter = get(a:000, 2, 0)
  let targetFile = ''
  if altEnter == 1
    " From https://github.com/plasticboy/vim-markdown/blob/master/ftplugin/markdown.vim
    if has('patch-7.4.567')
      call netrw#BrowseX(url, 0)
    else
      call netrw#NetrwBrowseX(url, 0)
    endif
    return
  elseif altEnter == 2
    call search(g:rgx.mdAnyLink, 'ce')
    let label = substitute(rc_vue#MatchUnderCursor(g:rgx.mdLink)[1], '^[^.]\+$', '&.md', '')
    let targetFile = input('Target File: ', label, 'file')
    if rc_vue#CursorIsOn(g:rgx.mdLink)
      exe 'normal vi)c' . targetFile
    elseif rc_vue#CursorIsOn(g:rgx.mdLinkNoLabel)
      exe 'normal vi>c' . targetFile
    endif
  endif
  normal m'
  call rc_vue#ReadUrl(url, jumpId, targetFile)
endfunction

function rc_vue#GoToMarkdownLink(...)
  let link = get(a:000, 0, '')
  let jumpId = get(a:000, 1, '')
  let altEnter = get(a:000, 2, 0)
  if link =~ g:rgx.url
    call rc_vue#GoToUrl(link, jumpId, altEnter)
  else
    " Save current location in the jump list
    normal m'
    let foundFile = 0
    if link != ''
      for f in rc_vue#FilePattern(link, ['.md', '.txt'])
        if filereadable(f)
          call pandoc#hypertext#OpenLocal(f, g:pandoc#hypertext#edit_open_cmd)
          let foundFile = 1
          break
        endif
      endfor
      if !foundFile
        " create and open new file with name found in link, adding default extension if necessary
        let isDirectory = link =~ '[/\\]$' || filewritable(link) == 2
        let needsExtension = link == fnamemodify(link, ':r')
        let newFile = isDirectory
              \ ? rc#DirSlashes(link) . 'index.md' 
              \ : (needsExtension ? link . '.md' : link)
        let newFile = rc#MakeFile(input('New File: ', newFile))
        call pandoc#hypertext#OpenLocal(newFile, g:pandoc#hypertext#edit_open_cmd)
        let foundFile = 1
      endif
    endif
    " Jump to first anchor id not inside a link. Can be anchor within current file
    if jumpId != ''
      " echo "GO TO anchor: " . jumpId
      let g:notInLink = '\%(' . '\%(<[^<]*\|([^(]*\)' . '\)\@<!'
      let g:jumpSearch = '#\s*\[\?' . substitute(jumpId, '[-_ ]', escape('[-_ ]\?', '\'), 'g')
      call search(g:notInLink . g:jumpSearch, 'c')
    endif
  endif
endfunction

function rc_vue#GoToMarkdownReference(...)
  let link = get(a:000, 0, '')
  if link != ''
    " Add current position to the jumplist
    normal m'
    " Jump to markdown reference
    let refTargetRegex = '\_.*\[' . link . '\]\s*\S'
    call search(refTargetRegex, 'e')
  endif
endfunction

" Overload behavior of the enter key
function rc_vue#EnterHelper(...)
  let altEnter = get(a:000, 0, 0)
  try
    if rc_vue#CursorIsOn(g:rgx.url)
      let link = rc_vue#MatchUnderCursor(g:rgx.url)[0]
      " echo "GO TO URL: " . link
      call rc_vue#GoToUrl(link, '', altEnter)
    elseif rc_vue#CursorIsOn(g:rgx.mdLink)
      let [link, jumpId] = rc_vue#MatchUnderCursor(g:rgx.mdLink)[3:4]
      " echo "GO TO MARKDOWN LINK: " . link . (jumpId != '' ? ' -> ' . jumpId . '' : '')
      call rc_vue#GoToMarkdownLink(link, jumpId, altEnter)
    elseif rc_vue#CursorIsOn(g:rgx.mdLinkNoLabel)
      let [link, jumpId] = rc_vue#MatchUnderCursor(g:rgx.mdLinkNoLabel)[2:3]
      " echo "GO TO MARKDOWN LINK: " . link . (jumpId != '' ? ' -> ' . jumpId . '' : '')
      call rc_vue#GoToMarkdownLink(link, jumpId, altEnter)
    elseif rc_vue#CursorIsOn(g:rgx.mdRefLink)
      let link = rc_vue#MatchUnderCursor(g:rgx.mdRefLink)[2]
      " echo "GO TO MARKDOWN REFERENCE: " . link
      call rc_vue#GoToMarkdownReference(link)
    else
      if altEnter
        " echo "CREATE AND GO TO FILE"
        exe 'edit ' . rc#MakeFile(expand('<cfile>'))
      else
        " echo "GO TO FILE"
        normal! gf
      endif
    endif
  catch
    echo "GO TO TAG" v:exception
    " exe "normal \<C-]>"
  catch
    if b:lspBufferEnabled == 1
      " echo "GO TO DEFINITION"
      LspDefinition
    endif
  catch
    if b:lspBufferEnabled == 1
      " echo "GO TO DECLARATION"
      LspDeclaration
    endif
  catch
    if b:lspBufferEnabled == 1
      " echo "GO TO IMPLEMENTATION"
      LspImplementation
    endif
  endtry
endfunction

" Join selected lines as markdown table row
function rc_vue#JoinLinesAsTableRow()
  '<,'>:s~\n\_s*~\|~
  normal I|
  normal A|
endfunction
