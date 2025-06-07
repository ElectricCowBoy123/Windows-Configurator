#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#NoTrayIcon     ; Hide the tray icon

; Define variables
global scrcpyPID := 0  ; Process ID for scrcpy
toggleState := false   ; Initialize a variable to track the toggle state

~!Tab::return  ; Let Alt+Tab pass through

; Define hotkey Alt + 4 to start or stop scrcpy
!4::  ; Alt + 4
{
    ; Check if scrcpy is already running
    if (scrcpyPID = 0) {
        ; scrcpy is not running, so start it
        cmd := "scrcpy --no-playback --window-borderless --window-title='' --always-on-top --window-x=1 --window-y=1 --window-width 100 --window-height 100 -M"
        Run, %ComSpec% /c %cmd%, , Hide, scrcpyPID

        ; Optional: Show a tooltip
        Sleep, 1000
        Tooltip, scrcpy started
    }
    else {
        cmd := "taskkill /F /IM scrcpy.exe"
        ; scrcpy is running, so close it
        Run, cmd.exe /c %cmd%, , Hide
        ; Reset the PID variable
        scrcpyPID := 0
        
        ; Optional: Show a tooltip
        Sleep, 1000
        Tooltip, scrcpy closed
    }

    ; Toggle the ADB command state
    toggleState := !toggleState  ; Toggle the state
    if (toggleState) {
        ; Command to execute when toggled ON
        cmd := "adb shell ime set io.github.visnkmr.nokeyboard/.IMEService"
        Run, cmd.exe /c %cmd%, , Hide
        ToolTip, scrcpy started
    } else {
        ; Command to execute when toggled OFF
        cmds := "adb shell ime set com.google.android.inputmethod.latin/com.android.inputmethod.latin.LatinIME"
        Run, cmd.exe /c %cmds%, , Hide
        ToolTip, scrcpy closed
    }
    ; Display the tooltip for 1 second
    Sleep, 1000
    ToolTip  ; Clear the tooltip
}
return
