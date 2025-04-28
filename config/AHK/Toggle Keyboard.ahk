; Initialize a variable to track the toggle state
toggleState := false

; Define the hotkey Alt + Q
!q::
    toggleState := !toggleState  ; Toggle the state
    if (toggleState) {
        ; Command to execute when toggled ON
        cmd := "adb shell ime set io.github.visnkmr.nokeyboard/.IMEService"
        Run, cmd.exe /c %cmd%, , Hide
        ToolTip, Command is ON
    } else {
        ; Command to execute when toggled OFF (if needed)
		cmds := "adb shell ime set com.google.android.inputmethod.latin/com.android.inputmethod.latin.LatinIME"
        Run, cmd.exe /c %cmds%, , Hide
		ToolTip, Command is OFF
    }
    ; Display the tooltip for 1 second
    Sleep, 1000
    ToolTip  ; Clear the tooltip
return
