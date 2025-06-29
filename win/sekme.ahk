#NoEnv
#SingleInstance force
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2

Toggle := false
PublisherMode := false
targetProcess := "AndroidEmulatorEn.exe"

; GUI Overlay oluştur
Gui, Overlay:New
Gui, Overlay:+AlwaysOnTop -Caption +ToolWindow +E0x20 +LastFound  ; Tıklamayı engellemez
Gui, Overlay:Color, 000000
Gui, Overlay:Font, s12 cWhite Bold, Segoe UI
Gui, Overlay:Add, Text, vOverlayText Center w350 h50, ❌ Macro Disabled
Gui, Overlay:Hide  ; Başlangıçta gizli
hwnd := WinExist()
WinSet, Transparent, 200, ahk_id %hwnd%

SetTimer, UpdateOverlayPos, 200

; F1: Makro toggle
F1::
if WinExist("ahk_exe " . targetProcess) {
    Toggle := !Toggle
    UpdateOverlayText()
    ShowOverlayBrief()
}
return

; F9: Yayıncı Modu toggle (OBS’den gizlemek için)
F9::
PublisherMode := !PublisherMode
if (PublisherMode) {
    Gui, Overlay:Hide
} else {
    UpdateOverlayText()
    ShowOverlayBrief()
}
return

; Overlay konumunu GameLoop’a sabitle
UpdateOverlayPos:
if (PublisherMode)
{
    Gui, Overlay:Hide
    return
}

if WinExist("ahk_exe " . targetProcess) {
    WinGetPos, X, Y, W, H, ahk_exe %targetProcess%
    xpos := X + (W // 2) - 175
    ypos := Y + H - 60
    Gui, Overlay:Show, x%xpos% y%ypos% NoActivate
} else {
    Gui, Overlay:Hide
}
return

; 3 saniyelik gösterim
ShowOverlayBrief() {
    Gui, Overlay:Show, NoActivate
    SetTimer, HideOverlay, -3000
}

HideOverlay:
Gui, Overlay:Hide
return

; Güncellenmiş yazıyı hazırla
UpdateOverlayText() {
    global Toggle, PublisherMode
    macroStatus := Toggle ? "✅ Macro Enabled" : "❌ Macro Disabled"
    pubStatus := PublisherMode ? "`n🎥 Publisher Mode ON" : ""
    fullText := macroStatus . pubStatus
    GuiControl, Overlay:, OverlayText, %fullText%
}

; Q ile eğil/zıpla/ateş
~q::
if (Toggle && WinActive("ahk_exe " . targetProcess)) {
    Send, {c down}
    Sleep, 50
    Send, {Space down}
    Sleep, 50
    Send, {LButton down}
    Sleep, 300
    Send, {LButton up}
    Send, {c up}
    Send, {Space up}
}
return

; LButton recoil
~LButton::
if (Toggle && WinActive("ahk_exe " . targetProcess)) {
    while GetKeyState("LButton", "P") {
        DllCall("mouse_event", "UInt", 0x0001, "Int", 0, "Int", 4, "UInt", 0, "Ptr", 0)
        Sleep, 15
    }
}
return

; RButton recoil
~RButton::
if (Toggle && WinActive("ahk_exe " . targetProcess)) {
    while GetKeyState("RButton", "P") {
        DllCall("mouse_event", "UInt", 0x0001, "Int", 0, "Int", 2, "UInt", 0, "Ptr", 0)
        Sleep, 20
    }
}
return

GuiClose:
ExitApp
