#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#NoTrayIcon     ; Hide the tray icon
; Define a variable to track the toggle state
toggleState := 0  ; 0 means ADB lock mode, 1 means perform ADB actions mode
~!Tab::return  ; Let Alt+Tab pass through
; Define hotkey Alt + `
!`::
    if (toggleState = 0) {
        Run, cmd.exe /c adb shell input keyevent 26, , Hide
        
        ; Optional: Show a tooltip
        Tooltip, ADB lock command sent
        Sleep, 1000
        Tooltip

        ; Set toggle state to 1 (perform ADB actions mode)
        toggleState := 1
    }
    else {
        ; Directly use the passcode (replace "1234" with your actual passcode)
        PASSCODE := "0219"
        
        Run, cmd.exe /c adb shell input swipe 900 1900 900 200, , Hide

        ; Wait for a moment to ensure the passcode is entered
        Sleep, 500

        ; Send the passcode using ADB input text command
        Run, cmd.exe /c adb shell input text %PASSCODE%, , Hide
        
        ; Wait for a moment to ensure the passcode is entered
        Sleep, 500
        
        ; Press the OK button (keyevent 66 is the Enter key)
        Run, cmd.exe /c adb shell input keyevent 66, , Hide
        
        ; Optional: Show a tooltip
        Tooltip, ADB unlock command sent
        Sleep, 1000
        Tooltip
        
        ; Set toggle state to 0 (ADB lock mode)
        toggleState := 0
    }
return
