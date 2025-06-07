#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#NoTrayIcon     ; Hide the tray icon
~!Tab::return  ; Let Alt+Tab pass through
!1::
Run, cmd.exe /c adb shell input keyevent 85, , Hide
return

!2::
Run, cmd.exe /c adb shell settings put system screen_brightness_mode 0, , Hide
Run, cmd.exe /c adb shell settings put system screen_brightness 25, , Hide
return

!3::
Run, cmd.exe /c adb shell settings put system screen_brightness_mode 1, , Hide
Run, cmd.exe /c adb shell settings put system screen_brightness 200, , Hide
return

!5::
Run, cmd.exe /c adb shell input keyevent KEYCODE_POWER, , Hide
return

!NumpadAdd::
Run, cmd.exe /c adb shell input keyevent 24, , Hide
return

!NumpadSub::
Run, cmd.exe /c adb shell input keyevent 25, , Hide
return