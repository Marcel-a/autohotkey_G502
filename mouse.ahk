wheelingSensitivity := 80 ; sensitivity to mouse movement higher is less sensitive-
wheelingPeriod := 50 ; timer period

MButton::
	StartWheeling()
	Keywait MButton
	StopWheeling()
Return
    
WatchCursor()
	{
	global
	MouseGetPos, wheelingNewMouseX, wheelingNewMouseY
	clicks := Round((abs(wheelingNewMouseY - wheelingMouseY)**1.5)/wheelingSensitivity)
	if (clicks == 0)
		{
		clicks := 1
		}
	if ((wheelingNewMouseY - wheelingMouseY) < 0)
		{
		MouseClick WheelDown,,,clicks
		}
	else if ((wheelingNewMouseY - wheelingMouseY) > 0)
		{
		MouseClick WheelUp,,,clicks
		}
	MouseGetPos, wheelingMouseX, wheelingMouseY
	totalclicks += clicks
	return
	}
StartWheeling()
	{
	global
	MouseGetPos, wheelingMouseX, wheelingMouseY
	SetTimer WatchCursor, %wheelingPeriod%
	totalclicks := 0
	return
	}
StopWheeling()
	{
	global
	SetTimer WatchCursor, Off
	if (totalclicks < 4)
		{
		Send {MButton}
		}
	return
	}