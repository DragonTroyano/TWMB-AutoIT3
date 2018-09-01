#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#Include <WindowsConstants.au3>
#Include <Array.au3>

Global $INI = "UserData\Data.ini"
Global $cVersion = IniRead($INI, "INFO", "Version", "0")
Global $Download[0][2]
Global $i

Download("https://www.dropbox.com/s/q4gop1iy21t6b81/Update.exe?dl=1")
$nVersion = BinaryToString(InetRead("https://www.dropbox.com/s/xcqxi6fm3sdue1y/Version.txt?dl=1"))

$NV = StringReplace($nVersion, ".", "")
$CV = StringReplace($cVersion, ".", "")

If IniRead($INI, "INFO", "Up", "0") = 1 Then Update()
If $CV < $NV Then Update()
If $CV = $NV or $CV > $NV Then
	$z = MsgBox(4, "Force Update", "Bot nie wymaga aktualizacji!"&@CRLF&@CRLF&"Czy mimo to chcesz go zaktualizowaæ?")
EndIf

If $z = 6 Then Update()
If $z = 7 Then Exit

Func Update()
$AutoUpdateForm = GUICreate("TW Master Bot UPDATE", 400, 155, -1, -1, $WS_CLIPSIBLINGS)
$updlabel1 = GUICtrlCreateLabel("Pobieranie TW Master Bot version: "&$nVersion, 24, 16, 342, 19)
GUICtrlSetFont(-1, 11, 800, 0, "Arial Black")
$Pobieranie = GUICtrlCreateLabel("Proszê czekaæ...", 24, 45, 500, 15)
$auprogress1 = GUICtrlCreateProgress(24, 60, 313, 20)
$auprogress2 = GUICtrlCreateProgress(24, 85, 313, 20)
$pProgress1 = GUICtrlCreateLabel("0%", 350, 63, 100, 20)
$aProgress1 = GUICtrlCreateLabel("0%", 350, 88, 100, 20)
GUISetState(@SW_SHOW, $AutoUpdateForm)
Local $AllSize
Local $All
Local $pProgress
Local $aProgress
For $a = 0 To $i Step 1
	$AllSize += InetGetSize($Download[$a][0], 1)
Next
For $a = 0 To $i Step 1
$Name = StringSplit($Download[$a][0], "/")
$Name = StringSplit($Name[6], "?")
$Name1 = StringReplace($Name[1], "%20", " ")

GUICtrlSetData($Pobieranie, "Pobieranie "&$Name1&" ...")

$aulink = InetGet($Download[$a][0], $Download[$a][1] & $Name1, 1, 1)
$ausize = InetGetSize($Download[$a][0], 1)

While InetGetInfo($aulink, 2) = False
   GUICtrlSetData($auprogress1, Int((InetGetInfo($aulink, 0) / $ausize) * 100))
   If Int((InetGetInfo($aulink, 0) / $ausize) * 100) <> $pProgress Then
	   $pProgress = Int((InetGetInfo($aulink, 0) / $ausize) * 100)
	   GUICtrlSetData($pProgress1, $pProgress&"%")
	EndIf
   GUICtrlSetData($auprogress2, Int((($All + InetGetInfo($aulink, 0)) / $AllSize) * 100))
   If Int((($All + InetGetInfo($aulink, 0)) / $AllSize) * 100) <> $aProgress Then
	   $aProgress = Int((InetGetInfo($aulink, 0) / $ausize) * 100)
	   GUICtrlSetData($aProgress1, $aProgress&"%")
	EndIf
WEnd
$All += InetGetInfo($aulink, 0)
If InetGetInfo($aulink, 3) <> True Then
         MsgBox(266256, "B£¥D PO£¥CZENIA", "Po³¹czenie ze zdalnym serwerem zosta³o przerwane." & @CRLF & @CRLF & "Do mo¿liwych przyczyn nale¿¹:" & _
		 @CRLF & "Nieprawid³owe odwo³anie do pliku." & @CRLF & "Zerwane po³¹czenie z internetem." & @CRLF & "Chwilowe problemy z serwerem." & _
		 @CRLF & @CRLF & "Proszê spróbowaæ ponownie. Jeœli problem siê powtarza zg³oœ to na adres tartar6@o2.pl")
         Exit
EndIf
Next
IniWrite($INI, "INFO", "Up", 1)
Run("Update.exe")
Exit
EndFunc ;==> Update

Func Download($Link, $Dir = @ScriptDir)
If $Dir <> @ScriptDir Then $Dir = @ScriptDir&"\"&$Dir&"\"
If $Dir = @ScriptDir Then $Dir = @ScriptDir&"\"
$i = _ArrayAdd($Download, $Link&"|"&$Dir)
EndFunc ;==> Download