#SingleInstance ForceIgnorePromptOff

gestureSensitivity := 600
startSensitivity:= 20
pollingPeriod := 30 ; timer period

SendMode Input

F14::
	StartGesture()
    Keywait F14
    StopGesture()
Return

WatchCursor()
	{
	global
	MouseGetPos, posX, posY
    MouseMove firstX, firstY

    deltaX := (posX - firstX)
    deltaY := (posY - firstY)

    tabScroll += deltaX

    if (firstTabScroll) {
        ; MsgBox, 64, Debug , First
        sensitivity := startSensitivity
    } else {
        sensitivity := gestureSensitivity
    }
    if (tabScroll > sensitivity) {
        ; next tab
        SendInput ^{PgDn}
        tabScroll -= sensitivity
        firstTabScroll := false
    }
    if (tabScroll < 0 - sensitivity) {
        ; next tab
        SendInput ^{PgUp}
        tabScroll += sensitivity
        firstTabScroll := false
    }
    
	;MouseGetPos, lastX, lastY
	return
	}

StartGesture()
	{
	global
    tabScroll := 0
    firstTabScroll := true

    ;BlockInput, MouseMove

	MouseGetPos, lastX, lastY
	MouseGetPos, firstX, firstY
	SetTimer WatchCursor, %pollingPeriod%
    
	return
	}

StopGesture()
	{
	global

	SetTimer WatchCursor, Off
    ;BlockInput, MouseMoveOff

    if (firstTabScroll) {
        SendInput ^w
    }
    
	return
	}