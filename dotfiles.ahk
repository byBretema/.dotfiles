#NoEnv
SendMode Input
#SingleInstance force
SetWorkingDir %A_ScriptDir%

; Better vim.
capslock::esc
Return

; Run spotify without adds.
pause::
Run C:\Users\camba\AppData\Roaming\Spotify\Spotify.exe
Return

; Run spotify no adds.
+pause::
Run C:\Users\Public\_tools\portables\ezBlocker\EZBlocker.exe
Return

; Control+Alt++Shift+C color picker.
^!+s::
MouseGetPos, MouseX, MouseY
PixelGetColor, color, %MouseX%, %MouseY%
MsgBox Pixel RGB: %color%
Return

; On/off caps.
~LShift::
if (A_PriorHotkey != "~LShift" or A_TimeSincePriorHotkey > 400)
{
    KeyWait, LShift
    Return
}
status := !status
if status
    SetCapsLockState, On
else
    SetCapsLockState, Off
Return
