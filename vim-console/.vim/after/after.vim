if !get(g:, 'disableSessionManager', 0)
  augroup SessionManager
    au!
    " save session on exit
    autocmd QuitPre * SaveSession

    " reestablish settings that can't be reloaded from session
    autocmd SessionLoadPost * ++once let b:isRestoredSession=1
    autocmd SafeState * ++once call s:OnSessionLoaded()
  augroup END
endif

if !get(g:, 'disableToggleConceal', 0)
  augroup ToggleConceal
    autocmd!
    autocmd FileType * call <SID>ReinforceConcealSyntax()
    autocmd CursorHold * call <SID>UpdateTime()
    autocmd CursorMoved * call <SID>RevealLine(0)
    autocmd TextChanged * call <SID>RevealLine(1)
    autocmd InsertLeave * call <SID>RevealLine(0)
  augroup END
endif
