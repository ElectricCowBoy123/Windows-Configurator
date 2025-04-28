#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%
#NoTrayIcon  ; Hide the tray icon

SetKeyDelay, 160, 120  ; Set key delay for reliable typing

; Allow Alt+Tab to pass through without interference
~!Tab::Return

; Custom paste hotkey (Ctrl+Shift+V) to paste clipboard content as raw text
^+v::SendRaw %Clipboard%

; Script Notes:
; Improved to ensure consistent typing with same keyboard layout.
; Use Ctrl+Shift+C to exit the script.
