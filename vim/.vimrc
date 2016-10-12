
" TODO: Documentation on how to make a custom .vimrc like this when using
" Vimbad. Also adding your own custom submodules. (like YouCompleteMe)


" Initialize local dictionary if it doesn't exist
if !exists('g:local')
    let g:local = {}
end

" Set local data
let g:local.author         = "Brian Dellaterra"
let g:local.email          = "bdellaterra@voodooglobe.com"
let g:local.github_user    = "bdellaterra"
let g:local.project_name   = "Manhattan"
let g:local.project_slug   = "manhattan"
let g:local.package_slug   = "manhattan"
let g:local.project_brief  = "The Manhattan Project"
let g:local.version        = "0.1.0"
let g:local.year           = "2016"
let g:local.license_name   = "Copyright Act of 1976, Pub.L. 94-553, 90 Stat. 2541, Section 401(a) (October 19, 1976)"
let g:local.license_brief  = "All rights reserved. This body of work or any portion thereof may not be reproduced or used in any manner whatsoever without the express written permission of the author."

" Add personal customizations to the runtimepath
set runtimepath+=~/.dotfiles/vim/after

" Source vimrc from distribution
source ~/.vim/vimrc

