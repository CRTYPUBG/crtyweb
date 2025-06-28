#NoEnv
#Persistent
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2

; 🔫 Makro Aktif Tuşu - F1
F1::
Toggle := !Toggle
SoundBeep, 750
return

; 🎯 Ana Makro - Q tuşu ile Eğil + Zıpla + Ateş Et
~q::
If (Toggle && WinActive("ahk_exe AndroidEmulatorEn.exe")) {
    Send, {c down}    ; Eğil
    Sleep, 50
    Send, {Space down} ; Zıpla
    Sleep, 50
    Send, {LButton down} ; Ateş Et
    Sleep, 300
    Send, {LButton up}
    Send, {c up}
    Send, {Space up}
}
return

; 🎮 Geri Tepme Azaltma (Recoil Control) – Mouse Aşağı Çeker
~LButton::
If (Toggle && WinActive("ahk_exe AndroidEmulatorEn.exe")) {
    Loop
    {
        If !GetKeyState("LButton", "P")
            break
        MoveMouse(0, 3)
        Sleep, 15
    }
}
return

; 🖱 Mouse Aşağı Çekme Fonksiyonu
MoveMouse(x, y) {
    DllCall("mouse_event", uint, 0x0001, int, x, int, y, uint, 0, int, 0)
}
