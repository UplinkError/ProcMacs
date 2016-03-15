#SingleInstance Force
#UseHook On
#NoEnv  
SendMode Input  

Recording=0
Menu, Tray, Icon, %A_WorkingDir%\stop-blue.ico,0
;Menu, Tray, Tip, ScrollLock:Toggle Recording | Pause:Playback | Win+Pause:PlaybackNumtimes | Win+ScrollLock:ExitApp


LAlt & F1::

	If(Recording=0) {
	Goto, RecordingOn
} Else {
	Goto, RecordingOff
}
Return


NumpadMult::
	;Send {Down }
	Send {enter}
	Sleep, 800
	
	Send {Alt Down}{Tab}
    Sleep, 200
    Send {Alt Up}
	
If(Recording=0) {
	Goto, RecordingOn
} Else {
	Goto, RecordingOff
}
Return

RecordingOff:
	Recording=0
	Menu, Tray, Icon, %A_WorkingDir%\stop-blue.ico,0
	UnhookWindowsHookEx(hHookKeybd)
	Exit
Return

RecordingOn:
	Recording=1
	Menu, Tray, Icon, %A_WorkingDir%\recording.ico,0
	Keystrokes=
	LastKey=
	hHookKeybd := SetWindowsHookEx(WH_KEYBOARD_LL:=13, RegisterCallback("Keyboard", "Fast"))
	Exit
Return

				;;;;;	KeyInputs	;;;;;;;;
				

RAlt & F10::
{
	Gui,+AlwaysOnTop
	gui, Color, 000000
	gui, add, edit, number w100 vtxtDue, Due date
	gui, add, edit, number w100 vtxtBill, Bill date
	gui, add, edit, number w100 vtxtStart, Start date
	gui, add, edit, number w100 vtxtEnd, End date
	gui, add, button, gDates, % "Submit All"
	gui, add, button, gDates2, % "Submit Due/Bill"
	
	gui, show,, Bill Dates

}
return


Dates:
{	
  		guiControlGet, txtVar1,, txtDue
  		date1 = % ( txtVar1)
		
		guiControlGet, txtVar2,, txtBill
  		date2 = % ( txtVar2)
		
		guiControlGet, txtVar3,, txtStart
  		date3 = % ( txtVar3)
		
		guiControlGet, txtVar4,, txtEnd
  		date4 = % ( txtVar4)
}		
return		

Dates2:
{
		guiControlGet, txtVar1,, txtDue
  		date1 = % ( txtVar1)
		
		guiControlGet, txtVar2,, txtBill
  		date2 = % ( txtVar2)
}		
Return	
	
+Printscreen::												
{
		
	SendInput, %date1%				;due date
		Send {Enter}
		
	SendInput, %date2%				;bill date
		Send {Enter}
		
	SendInput, %date3%				;start date
		Send {Enter}
		
	SendInput, %date4%				;end date
		Send {Enter}
		
		;SendInput 55.5
		;Sleep, 2000
		;Send {Enter 6}
		;SendInput 2846
		;Send {enter 2}
		
}
Return

Rcontrol & Printscreen::
{
		SendInput, %date1%				;due date
			Send {Enter}
		
		SendInput, %date2%				;bill date
			Send {Enter}
}
Return 


F9::
{
	Send {Right 10}
	Send {enter}
	SendInput 25.25
	Sleep, 400
	Send {NumpadAdd}
	
}
Return

F10::
{
	Send {Alt Down}{Tab}
    Sleep, 200
    Send {Alt Up}
	Sleep, 400
	
	Send {Space}
	Sleep, 400
	
	Send {Alt Down}{Tab}
    Sleep, 200
    Send {Alt Up}
	
}
Return


LAlt & F9::
{
	SendInput 
	Send {Tab}
	SendInput 
	
}
Return

;;;;;;;;	ERROR MESSAGES		;;;;;;;;


RControl & NumpadAdd::
{
	Send {TAB 7}
	Send {Enter}
}
Return

RControl & Numpad0::
{
	SendInput ^a
	SendInput [DUPLICATE] - 
	Send {Space}
	;SendInput ^v
}
Return

RControl & Numpad1::
{
	SendInput ^a
	SendInput [SETUP]
}
Return

RControl & Numpad2::
{
	SendInput aja16031102
}
Return

RControl & Numpad3::
{
	SendInput ^a
	SendInput [FIX] 
}
Return

RControl & Numpad4::
{
	SendInput ^a
	SendInput [FIX] Blank Vacant Screen
}
Return

RControl & Numpad5::
{
	SendInput ^a
	SendInput [FIX] No Vacant Utilities
}
Return

RControl & Numpad6::
{
	SendInput ^a
	SendInput [FIX] Account Blocked
}
Return

RControl & Numpad7::
{
	SendInput ^a
	SendInput [FIX] Tenant Moved In
}
Return

RControl & Numpad8::
{
	SendInput ^a
	SendInput [ACTIVATIONS]
}
Return


RControl & Numpad9::
{
	SendInput ^a
	SendInput [Image]
}
Return



Printscreen::
If(Recording=1) {
	Goto, RecordingOff
}
SendInput %Keystrokes%
Return

#Pause::
If(Recording=1) {
	Goto, RecordingOff
}
	
#ScrollLock::
ExitApp
Return

; Function called on each keyboard event during macro recording
Keyboard(nCode, wParam, lParam)
{
   Global Keystrokes
   Global LastKey

   ; 
   If !nCode
   {
       ; Get the virtual key code and the scan code from the key event.
       vk:=NumGet(lParam+0,0)
       ; 27 <=> 1B <=> Escape
	   ; 222 <=> DE <=>²
       If ( (vk != 145) && (vk != 19) )  ;Ignore, 145 is ScrollLock and 19 is Pause
       {
           vk0:=HexDigit(vk,0)
           vk1:=HexDigit(vk,1)

           sc:=NumGet(lParam+0,4)
           sc0:=HexDigit(sc,0)
           sc1:=HexDigit(sc,1)
           sc2:=HexDigit(sc,2)

           ext:=NumGet(lParam+0,8)
           If ext & 128
               upDown=Up
           Else
               upDown=Down

           key={vk%vk1%%vk0%sc%sc2%%sc1%%sc0% %upDown%}
           If ( LastKey != key )
           {
               Keystrokes=%Keystrokes%%key%
               LastKey:=key
           }
       }
   }
   Return CallNextHookEx(nCode, wParam, lParam)
}

; Extract an hexadecimal digit from a number
HexDigit( number, position )
{
    If position=0
        number := Mod(number,16)
    Else If position=1
        number := Mod(number//16,16)
    Else If position=2
        number := Mod(number//256,16)

    If number<10
        Return Chr(48+number)

    Return Chr(55+number)
}

SetWindowsHookEx(idHook, pfn)
{
   Return DllCall("SetWindowsHookEx", "int", idHook, "Uint", pfn, "Uint", DllCall("GetModuleHandle", "Uint", 0), "Uint", 0)
}

UnhookWindowsHookEx(hHook)
{
   Return DllCall("UnhookWindowsHookEx", "Uint", hHook)
}

CallNextHookEx(nCode, wParam, lParam, hHook = 0)
{
   Return DllCall("CallNextHookEx", "Uint", hHook, "int", nCode, "Uint", wParam, "Uint", lParam)
}

Unhook:
If Recording=1
    UnhookWindowsHookEx(hHookKeybd)
ExitApp
