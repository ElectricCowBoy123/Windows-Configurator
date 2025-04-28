#SingleInstance Force
SendMode("Input")
SetWorkingDir(A_ScriptDir)
#NoTrayIcon     ; Hide the tray icon
; AutoHotkey v2 - Media Keys
^!Space:: {
    Send("{Media_Play_Pause}")
}
^!Left:: {
    Send("{Media_Prev}")
}
^!Right:: {
    Send("{Media_Next}")
}
^!NumpadMult:: {
    Send("{Volume_Mute}")
}
^!NumpadAdd:: {
    Send("{Volume_Up}")
}
^!NumpadSub:: {
    Send("{Volume_Down}")
}
~!Tab::return  ; Let Alt+Tab pass through