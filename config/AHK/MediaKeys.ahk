#SingleInstance Force
#NoTrayIcon  ; Hide the tray icon
; AutoHotkey v1.1 - Media Keys
^!Space::
    Send {Media_Play_Pause}
return
^!Left::
    Send {Media_Prev}
return
^!Right::
    Send {Media_Next}
return
^!NumpadMult::
    Send {Volume_Mute}
return
^!NumpadAdd::
    Send {Volume_Up}
return
^!NumpadSub::
    Send {Volume_Down}
return
~!Tab:: return  ; Let Alt+Tab pass through