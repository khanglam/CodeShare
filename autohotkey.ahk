#Requires AutoHotkey v2.0
#SingleInstance Off
SendMode "Input"

; Global variables
isRunning := false
targetWindowID := 0
targetWindowTitle := ""
key1 := "8"  ; Default Dualblade key
key2 := "2"  ; Default Main Weapon key
MyGui := ""
ToggleBtn := ""
StatusText := ""
WindowDropdown := ""
RefreshBtn := ""
Key1Input := ""
Key2Input := ""

; Create the GUI
CreateGUI()

; Hotkey to toggle sequence
F2:: {
    ToggleSequence()
}

CreateGUI() {
    global MyGui, ToggleBtn, StatusText, WindowDropdown, RefreshBtn, Key1Input, Key2Input

    ; Create main window
    MyGui := Gui("", "Auto Dance")
    MyGui.SetFont("s12")

    ; Title section
    MyGui.Add("Text", "x30 y30 w640 Center", "Auto Dance")
    MyGui.SetFont("s10 cGray")
    MyGui.Add("Text", "x30 y65 w640 Center", "Switch Weapons to Buff Dance")
    MyGui.SetFont("s11")

    ; Target window section
    MyGui.Add("Text", "x30 y120 w640 Center", "Target Window:")

    ; Dropdown and refresh button
    WindowDropdown := MyGui.Add("DropDownList", "x30 y150 w520 r10", [])
    RefreshBtn := MyGui.Add("Button", "x560 y148 w110 h30", "Refresh")

    ; Populate dropdown
    RefreshWindowList()

    ; Key configuration section
    MyGui.Add("Text", "x30 y210 w300", "Dualblade Hotkey:")
    Key1Input := MyGui.Add("Edit", "x340 y208 w80 h25 Center", key1)

    MyGui.Add("Text", "x30 y250 w300", "Main Weapon Hotkey:")
    Key2Input := MyGui.Add("Edit", "x340 y248 w80 h25 Center", key2)

    ; Start button
    ToggleBtn := MyGui.Add("Button", "x235 y310 w230 h60", "Start Sequence (F2)")

    ; Status text
    StatusText := MyGui.Add("Text", "x30 y400 w640 Center", "Status: OFF")

    ; Event handlers
    ToggleBtn.OnEvent("Click", ToggleSequence)
    WindowDropdown.OnEvent("Change", OnWindowSelect)
    RefreshBtn.OnEvent("Click", RefreshWindowList)
    Key1Input.OnEvent("Change", UpdateKey1)
    Key2Input.OnEvent("Change", UpdateKey2)
    MyGui.OnEvent("Close", (*) => ExitApp())

    ; Show the GUI
    MyGui.Show("w700 h460")
}

; Refresh window list
RefreshWindowList(*) {
    global WindowDropdown

    ; Get all windows using v2.0 syntax
    windows := WinGetList()

    ; Clear dropdown
    WindowDropdown.Delete()

    ; Add windows to dropdown
    loop windows.Length {
        try {
            winID := windows[A_Index]
            winTitle := WinGetTitle("ahk_id " . winID)
            if (winTitle != "") {
                WindowDropdown.Add([winTitle . " (ID: " . winID . ")"])
            }
        } catch {
            ; Skip invalid windows
        }
    }

    ; Select first item if available
    if (WindowDropdown.Text = "") {
        WindowDropdown.Text := WindowDropdown.Text
    }
}

; Handle window selection
OnWindowSelect(*) {
    global WindowDropdown, targetWindowID, targetWindowTitle, MyGui

    selectedText := WindowDropdown.Text
    if (selectedText != "") {
        ; Extract window ID from selection
        RegExMatch(selectedText, "ID: (\d+)", &match)
        if (match) {
            targetWindowID := Integer(match[1])
            targetWindowTitle := WinGetTitle("ahk_id " . targetWindowID)

            ; Update GUI title with selected window name
            MyGui.Title := "Auto Dance - " . targetWindowTitle

            TrayTip "Window Selected", "Target: " . targetWindowTitle, 1
        }
    }
}

; Update key1 when user changes it
UpdateKey1(*) {
    global Key1Input, key1
    key1 := Key1Input.Value
}

; Update key2 when user changes it
UpdateKey2(*) {
    global Key2Input, key2
    key2 := Key2Input.Value
}

; Toggle sequence
ToggleSequence(*) {
    global isRunning, StatusText, ToggleBtn, targetWindowID

    if (targetWindowID = 0) {
        MsgBox("Please select a target window first!", "No Target", "IconX")
        return
    }

    isRunning := !isRunning

    if (isRunning) {
        SetTimer MainCycle, 300000  ; 5 minutes
        MainCycle()
        StatusText.Text := "Status: ON"
        ToggleBtn.Text := "Stop Sequence (F2)"
        TrayTip "AutoHotkey", "Auto sequence is ON", 1
    } else {
        SetTimer MainCycle, 0
        StatusText.Text := "Status: OFF"
        ToggleBtn.Text := "Start Sequence (F2)"
        TrayTip "AutoHotkey", "Auto sequence is OFF", 1
    }
}

; Main cycle
MainCycle() {
    global targetWindowID, key1

    ; Check if target window still exists
    try {
        WinGetTitle("ahk_id " . targetWindowID)
    } catch {
        MsgBox("Target window lost! Stopping sequence.", "Window Lost", "IconX")
        return
    }

    ; Send key 1 (Dualblade)
    ControlSend("{" . key1 . "}", , "ahk_id " . targetWindowID)

    ; Send key 2 after 5 seconds
    SetTimer MainWeapon, -5000
}

; Press key 2
MainWeapon() {
    global targetWindowID, key2

    ; Check if target window still exists
    try {
        WinGetTitle("ahk_id " . targetWindowID)
    } catch {
        return
    }

    ; Send key 2 (Main Weapon)
    ControlSend("{" . key2 . "}", , "ahk_id " . targetWindowID)
}
