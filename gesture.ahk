#SingleInstance ForceIgnorePromptOff

gestureSensitivity := 600
startSensitivity:= 50
pollingPeriod := 10 ; timer period

SendMode Input
; MsgBox, 64, Debug , First

class AdditionalKey {
    key := 0
    callback := 0

    __New(key, callback) {
        this.key := key
        this.callback := callback
    }
}

class GestureKey {
    key := 0

    valueX := 0
    valueY := 0

    firstX := 0
    firstY := 0

    directionDetermined := false
    actionTriggered := false

    ; 0: X+ 
    ; 1: Y- 
    ; 2: X- 
    ; 3: Y- 
    direction := 0

    actionRight := 0
    actionLeft := 0
    actionUp := 0
    actionDown := 0
    actionClick := 0

    actionRightOnce := false
    actionLeftOnce := false
    actionUpOnce := false
    actionDownOnce := false

    xAxis := false
    yAxis := false

    xAxisSensitivity := 600
    xAxisStartSensitivity := 50
    yAxisSensitivity := 600
    yAxisStartSensitivity := 50

    xAxisKey := 0
    yAxisKey := 0
    xAxisKeyActivated := false
    yAxisKeyActivated := false

    additionalKeys := []
    additionalKeyPointers := []


    __New(key) {
        this.key := key
        
    }

    SetLeft(callback, once) {
        this.actionLeft := callback
        this.actionLeftOnce := once
    }

    SetRight(callback, once) {
        this.actionRight := callback
        this.actionRightOnce := once
    }

    SetUp(callback, once) {
        this.actionUp := callback
        this.actionUpOnce := once
    }

    SetDown(callback, once) {
        this.actionDown := callback
        this.actionDownOnce := once
    }

    SetClick(callback) {
        this.actionClick := callback
    }
    
    SetXAxis(sensitivity, startSensitivity) {
        this.xAxis := true
        this.xAxisSensitivity := sensitivity
        this.xAxisStartSensitivity := startSensitivity
    }
    
    SetYAxis(sensitivity, startSensitivity) {
        this.yAxis := true
        this.yAxisSensitivity := sensitivity
        this.yAxisStartSensitivity := startSensitivity
    }

    SetXAxisKey(xAxisKey) {
        this.xAxisKey := xAxisKey
    }

    SetYAxisKey(xAxisKey) {
        this.yAxisKey := yAxisKey
    }

    AddAdditionalKey(key, callback) {
        ak := new AdditionalKey(key, callback)
        this.additionalKeys.Push(ak)
    }

    Start() {
        key:= this.key
        ptr := this["OnKey"].bind(this)
        Hotkey %key%, %ptr%
    }

    OnKey() {
        this.StartGesture()
        key := this.key
        Keywait % key
        this.StopGesture()
    }

    StartGesture() {
        global
        this.valueX := 0
        this.valueY := 0
        this.directionDetermined := false
        this.actionTriggered := false

        MouseGetPos fX, fY
        this.firstX := fX
        this.firstY := fY

        for index, e in this.additionalKeys {
            key := e.key
            ptr := e["callback"].bind(e)
            Hotkey %key%, %ptr%
        }

        ptr := this["WatchCursor"].bind(this)
        this.watchCursorPointer := ptr
        SetTimer %ptr%, % pollingPeriod
    }

    WatchCursor() {
        global
        MouseGetPos, posX, posY
        MouseMove this.firstX, this.firstY

        deltaX := (posX - this.firstX)
        deltaY := (posY - this.firstY)

        this.valueX += deltaX
        this.valueY += deltaY

        useStartSensitivity := false

        ; Wait for first move to direction
        if (!this.directionDetermined) {
            
            if (this.valueX > this.xAxisStartSensitivity) {
                this.direction := 0
                this.directionDetermined := true
                useStartSensitivity := true
                if (this.xAxisKey != 0) {
                    key := this.xAxisKey
                    Send {%key% down}
                }
            } else if (this.valueX < -this.xAxisStartSensitivity) {
                this.direction := 2
                this.directionDetermined := true
                useStartSensitivity := true
                if (this.xAxisKey != 0) {
                    key := this.xAxisKey
                    Send {%key% down}
                }
            } else if (this.valueY < -this.yAxisStartSensitivity) {
                this.direction := 1
                this.directionDetermined := true
                useStartSensitivity := true
                if (this.yAxisKey != 0) {
                    key := this.yAxisKey
                    Send {%key% down}
                }
            } else if (this.valueY > this.yAxisStartSensitivity) {
                this.direction := 3
                this.directionDetermined := true
                useStartSensitivity := true
                if (this.yAxisKey != 0) {
                    key := this.yAxisKey
                    Send {%key% down}
                }
            }
        }

        if (this.directionDetermined) {
            loop {
                if (useStartSensitivity) {
                    xSensitivity := this.xAxisStartSensitivity
                    ySensitivity := this.yAxisStartSensitivity
                } else {
                    xSensitivity := this.xAxisSensitivity
                    ySensitivity := this.yAxisSensitivity
                }
                if ((this.direction = 0 || (this.xAxis && this.direction = 2)) && this.valueX > xSensitivity/2 && (not this.actionRightOnce || not this.actionTriggered)) {
                    this.actionTriggered := true
                    executed := DllCall(this.actionRight, "Int", Floor((this.valueX + xSensitivity/2) / xSensitivity))
                    if (executed <= 0) {
                        executed := 1
                    }
                    this.valueX -= xSensitivity * executed
                } else if ((this.direction = 1 || (this.yAxis && this.direction = 3)) && this.valueY < -ySensitivity/2 && (not this.actionUpOnce || not this.actionTriggered)) {
                    this.actionTriggered := true
                    executed := DllCall(this.actionUp, "Int", -Floor((-this.valueY + ySensitivity/2) / -ySensitivity))
                    if (executed <= 0) {
                        executed := 1
                    }
                    this.valueY += ySensitivity * executed
                } else if ((this.direction = 2 || (this.xAxis && this.direction = 0)) && this.valueX < -xSensitivity/2 && (not this.actionLeftOnce || not this.actionTriggered)) {
                    this.actionTriggered := true
                    executed := DllCall(this.actionLeft, "Int", -Floor((-this.valueX + xSensitivity/2) / -xSensitivity))
                    if (executed <= 0) {
                        executed := 1
                    }
                    this.valueX += xSensitivity * executed
                } else if ((this.direction = 3 || (this.yAxis && this.direction = 1)) && this.valueY > ySensitivity/2 && (not this.actionDownOnce || not this.actionTriggered)) {
                    this.actionTriggered := true
                    executed := DllCall(this.actionDown, "Int", Floor((this.valueY + ySensitivity/2) / ySensitivity))
                    if (executed <= 0) {
                        executed := 1
                    }
                    this.valueY -= ySensitivity * executed
                } else {
                    break
                }
            }
        }
    }

    StopGesture() {
        ptr := this.watchCursorPointer
        SetTimer % ptr, Off

        if (not this.actionTriggered) {
            DllCall(this.actionClick)
        }

        if ((this.direction == 0 || this.direction == 2) && this.xAxisKey != 0) {
            key := this.xAxisKey
            Send {%key% up}
        }
        if ((this.direction == 1 || this.direction == 3) && this.yAxisKey != 0) {
            key := this.yAxisKey
            Send {%key% up}
        }
    }

}


ClickCtrlW() {
    SendInput ^w
}

ClickCtrlPgUp() {
    Send ^{PgUp}
}

ClickCtrlPgDn() {
    Send ^{PgDn}
}

ClickMinimize() {
    WinMinimize, A
}

ClickMaximize() {
    WinMaximize, A
}

tabControl := new GestureKey("F14")
tabControl.SetClick(RegisterCallback("ClickCtrlW"))
tabControl.SetLeft(RegisterCallback("ClickCtrlPgUp"), false)
tabControl.SetRight(RegisterCallback("ClickCtrlPgDn"), false)
tabControl.SetXAxis(500, 100)
tabControl.SetUp(RegisterCallback("ClickMaximize"), true)
tabControl.SetDown(RegisterCallback("ClickMinimize"), true)

tabControl.Start()


ClickPlay() {
    Send {Media_Play_Pause}
}

ClickNext() {
    Send {Media_Next}
}

ClickPrev() {
    Send {Media_Prev}
}

ClickVolumeDown(amount) {
    ;MsgBox, 64, Debug , down
    ;Send {Volume_Down %amount%}
    amount := amount / 2
    SoundSet -%amount%
    return amount
}

ClickVolumeUp(amount) {
    ;MsgBox, 64, Debug , up
    ;Send {Volume_Up %amount%}
    amount := amount / 2
    SoundSet +%amount%
    return amount
}

mediaControl := new GestureKey("F13")
mediaControl.SetClick(RegisterCallback("ClickPlay"))
mediaControl.SetLeft(RegisterCallback("ClickPrev"), true)
mediaControl.SetRight(RegisterCallback("ClickNext"), true)
mediaControl.SetUp(RegisterCallback("ClickVolumeUp"), false)
mediaControl.SetDown(RegisterCallback("ClickVolumeDown"), false)
mediaControl.SetYAxis(10, 50)

mediaControl.Start()



ClickWindowsE() {
    SendInput #e
}

ClickWindows() {
    SendInput {LWin}
}

ClickCloseWindow() {
    SendInput !{F4}
}

ClickNextWindow() {
    SendInput !{Tab}
}

ClickAxixNextWindow() {
    SendInput {Tab}
}

ClickAxisPrevWindow() {
    SendInput +{Tab}
}

windowsControl := new GestureKey("F15")
windowsControl.SetClick(RegisterCallback("ClickNextWindow"))
windowsControl.SetUp(RegisterCallback("ClickWindowsE"), true)
;windowsControl.AddAdditionalKey("WheelUp")
;windowsControl.SetDown(RegisterCallback("ClickCloseWindow"), true)
;windowsControl.SetRight(RegisterCallback("ClickAxisNextWindow"), false)
;windowsControl.SetLeft(RegisterCallback("ClickAxisPrevWindow"), false)
;windowsControl.SetXAxis(600, 50)
;windowsControl.SetXAxisKey("Alt")
windowsControl.Start()