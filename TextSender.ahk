#Requires Autohotkey v2
#NoTrayIcon

mainWindow := Gui()
mainWindow.Title := "TextSender"
mainWindow.BackColor := "0x1f1f1f"
mainWindow.SetFont("cWhite", "Segoe UI")
mainWindow.OnEvent('Close', (*) => ExitApp())

; Text Input
mainWindow.Add("GroupBox", "x10 y10 w420 h102")
textInputLabel := mainWindow.Add("Text", "x205 y5 w30 h20", "Text:")
textInputLabel.SetFont("s12")

customTextEdit1 := mainWindow.Add("Edit", "x20 y30 w330 h20 Limit1000 +Background0x2c2e33 -E0x200")
enterKeyCheckbox := mainWindow.Add("CheckBox", "x355 y30 w70 h20", "Enter Key")
copyPasteCheckbox := mainWindow.Add("CheckBox", "x355 y66 w54 h22", "Copy/Paste")

enableCheckbox1 := mainWindow.Add("Checkbox", "x20 y54 w15 h20 +Disabled")
customTextEdit2 := mainWindow.Add("Edit", "x40 y54 w310 h20 Limit1000 +Disabled +Background0x2c2e33 -E0x200")
enableCheckbox2 := mainWindow.Add("Checkbox", "x20 y78 w15 h20 +Disabled")
customTextEdit3 := mainWindow.Add("Edit", "x40 y78 w310 h20 Limit1000 +Disabled +Background0x2c2e33 -E0x200")

customTextEdit1.OnEvent("Change", CheckEnableCheckbox1)
enableCheckbox1.OnEvent("Click", ToggleTextEdit2)
enableCheckbox2.OnEvent("Click", ToggleTextEdit3)
customTextEdit2.OnEvent("Change", CheckEnableCheckbox2)


; Repeat Settings
mainWindow.Add("GroupBox", "x445 y10 w210 h102")
repeatCountLabel := mainWindow.Add("Text", "x489 y5 w122 h20", "Number of times:")
repeatCountLabel.SetFont("s12")

repeatCountEditBox := mainWindow.Add("Edit", "x500 y44 w100 h20 Number +Background0x2c2e33 -E0x200")
repeatCountUpDown := mainWindow.Add("UpDown", "x580 y44 w18 h18 Range1-1000", 10)
infiniteRepeatCheckbox := mainWindow.Add("CheckBox", "x500 y68 w58 h20", "Infinite")

infiniteRepeatCheckbox.OnEvent("Click", ToggleRepeatControls)


; Speed Settings
mainWindow.Add("GroupBox", "x10 y122 w420 h102")
speedLabel := mainWindow.Add("Text", "x196 y117 w48 h20", "Speed:")
speedLabel.SetFont("s12")

intervalLabel := mainWindow.Add("Text", "x182 y142 w100 h20", "Interval: 1s")
speedSlider := mainWindow.Add("Slider", "x20 y164 w400 h30 Range1-31 AltSubmit", 22)

customSpeedCheckbox := mainWindow.Add("CheckBox", "x20 y196 w60 h20", "Custom")

customSpeedEditBox := mainWindow.Add("Edit", "x170 y164 w100 h20 Number +Background0x2c2e33 -E0x200")
customSpeedUpDown := mainWindow.Add("UpDown", "x250 y164 w18 h18 Range1-1000000", 1000)
customSpeedEditBox.Visible := false
customSpeedUpDown.Visible := false

speedSlider.OnEvent("Change", UpdateIntervalSlider)
customSpeedCheckbox.OnEvent("Click", EnableCustomSpeed)
customSpeedUpDown.OnEvent('Change', UpdateIntervalUpDown)


; Start Delay
mainWindow.Add("GroupBox", "x445 y122 w210 h51")
startDelayLabel := mainWindow.Add("Text", "x486 y117 w127 h20", "Delay before start:")
startDelayLabel.SetFont("s12")

startDelayEditBox := mainWindow.Add("Edit", "x500 y140 w100 h20 Number +Background0x2c2e33 -E0x200")
startDelayUpDown := mainWindow.Add("UpDown", "x580 y140 w18 h18  Range1-1000", 3)
startDelayUnitLabel := mainWindow.Add("Text", "x605 y142 w10 h20", "s")


; Start Button
startButton := mainWindow.Add("Button", "x445 y178 w210 h46 -Theme", "&Start")
startButton.SetFont("s16 Bold")
startButton.OnEvent("Click", ToggleProcess)


; Functions and Events
SliderToMilliseconds(value) {
	if (value > 21) {
		return (value - 21) * 1000
	}
	else if (value > 2) {
		return (value - 2) * 50
	}
	else if (value = 2) {
		return 25
	}
	else if (value = 1) {
		return 10
	}
}

UpdateIntervalSlider(ctrl, info) {
	value := ctrl.Value
	interval := SliderToMilliseconds(value)
	
	if (value > 21) {
		intervalLabel.Text := "Interval: " Integer(interval/1000) "s"
	}
	else {
		intervalLabel.Text := "Interval: " interval "ms"
	}
}

UpdateIntervalUpDown(ctrl, info) {
	intervalLabel.Value := "Interval: " ctrl.value "ms"
}

EnableCustomSpeed(ctrl, info) {
	if (ctrl.value) {
		speedSlider.Visible := false
		customSpeedEditBox.Visible := true
		customSpeedUpDown.Visible := true
		intervalLabel.Text := "Interval: " customSpeedUpDown.Value "ms"
	} else {
		speedSlider.Visible := true
		customSpeedEditBox.Visible := false
		customSpeedUpDown.Visible := false
		UpdateIntervalSlider(speedSlider, "")
	}
}

CheckEnableCheckbox1(ctrl, info) {
	if (ctrl.Value) {
		enableCheckbox1.Enabled := true
	} else {
		enableCheckbox1.Enabled := false
		enableCheckbox1.Value := false
		enableCheckbox2.Enabled := false
		enableCheckbox2.Value := false
		customTextEdit2.Enabled := false
		customTextEdit3.Enabled := false
	}
}

ToggleTextEdit2(ctrl, info) {
	if (ctrl.Value) {
		customTextEdit2.Enabled := true
	} else {
		customTextEdit2.Enabled := false
		enableCheckbox2.Enabled := false
		customTextEdit3.Enabled := false
		enableCheckbox2.Value := false
	}
	CheckEnableCheckbox2(customTextEdit2, "")
}

ToggleTextEdit3(ctrl, info) {
	customTextEdit3.Enabled := ctrl.Value
}

CheckEnableCheckbox2(ctrl, info) {
	if (enableCheckbox1.Value && ctrl.Value != "") {
		enableCheckbox2.Enabled := true
	} else {
		enableCheckbox2.Enabled := false
		enableCheckbox2.Value := false
		customTextEdit3.Enabled := false
	}
}

ToggleRepeatControls(ctrl, info) {
	repeatCountEditBox.Enabled := !ctrl.Value
	repeatCountUpDown.Enabled := !ctrl.Value
}

ToggleProcess(ctrl, info) {
    static isRunning := false
    
    if (ctrl.Text = "&Start") {
        if (customTextEdit1.Value = "") {
            MsgBox("Please enter at least one text to send.", "Error", "Icon!")
            return
        }
        
        ctrl.Text := "&Stop"
        isRunning := true
        SetTimer(ProcessLoop.Bind(ctrl), -startDelayUpDown.Value * 1000)
    } else {
        isRunning := false
        ctrl.Text := "&Start"
    }
}

ProcessLoop(startButton) {
    static currentIteration := 0
    
    if (startButton.Text = "&Start") {
        return
    }

    SendText(customTextEdit1.Value, enterKeyCheckbox.Value)
    
    delay := customSpeedCheckbox.Value ? customSpeedUpDown.Value : SliderToMilliseconds(speedSlider.Value)
    
    if (enableCheckbox1.Value && customTextEdit2.Value != "") {
        Sleep(delay)
        SendText(customTextEdit2.Value, enterKeyCheckbox.Value)
        
        if (enableCheckbox2.Value && customTextEdit3.Value != "") {
            Sleep(delay)
            SendText(customTextEdit3.Value, enterKeyCheckbox.Value)
        }
    }
    
    currentIteration++
    
    if (!infiniteRepeatCheckbox.Value && currentIteration >= repeatCountUpDown.Value) {
        startButton.Text := "&Start"
        currentIteration := 0
        return
    }
    
    SetTimer(ProcessLoop.Bind(startButton), -delay)
}

SendText(text, sendEnter := false) {
	if (copyPasteCheckbox.Value) {
		A_Clipboard := text
		SendInput("^v")
	} else {
		loop parse text {
			SendInput("{Raw}" A_LoopField)
			Sleep(1)
		}
	}
    
    if (sendEnter) {
        Send("{Enter}")
    }
}

mainWindow.Show("w665 h240")
