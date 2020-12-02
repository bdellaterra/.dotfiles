if !get(g:, 'disableSessionManager', 0)
  augroup SessionManager
    au!
    " save session on exit
    autocmd QuitPre * SaveSession

    " reestablish settings that can't be reloaded from session
    autocmd SessionLoadPost * let b:isRestoredSession=1
    autocmd VimEnter * call rc#OnSessionLoaded()
  augroup END
endif

if !get(g:, 'disableToggleConceal', 0)
  augroup ToggleConceal
    autocmd!
    autocmd FileType * call rc#ReinforceConcealSyntax()
    autocmd CursorHold * call rc#UpdateTime()
    autocmd CursorMoved * call rc#RevealLine(0)
    autocmd TextChanged * call rc#RevealLine(1)
    autocmd InsertLeave * call rc#RevealLine(0)
  augroup END
endif
