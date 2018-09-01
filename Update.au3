#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#Include <WindowsConstants.au3>
#Include <Array.au3>

Global $Download[0][2]
Global $i

#Region Linki do pobierania
;Download($Link[, $Dir = @ScriptDir])
Download("https://www.dropbox.com/s/2r7mlamkzkhsfs7/Icon.ico?dl=1")
Download("https://www.dropbox.com/s/afvmn829yfd5lk9/Logo.png?dl=1", "Bin")
Download("https://www.dropbox.com/s/u69x5ktmb9ul72o/unit_spear.jpg?dl=1", "Bin")
Download("https://www.dropbox.com/s/9ljvt78f44s5q4w/unit_sword.jpg?dl=1", "Bin")
Download("https://www.dropbox.com/s/bvndvkcx650dtgi/unit_axe.jpg?dl=1", "Bin")
Download("https://www.dropbox.com/s/dwvdgto3mkbrlo9/unit_archer.jpg?dl=1", "Bin")
Download("https://www.dropbox.com/s/wgqwsdhk07hx2yw/unit_spy.jpg?dl=1", "Bin")
Download("https://www.dropbox.com/s/3lon40qps8kiy30/unit_light.jpg?dl=1", "Bin")
Download("https://www.dropbox.com/s/izrwtzajt6dpisr/unit_marcher.jpg?dl=1", "Bin")
Download("https://www.dropbox.com/s/0slcoiasc49ldlq/unit_heavy.jpg?dl=1", "Bin")
Download("https://www.dropbox.com/s/yrt7vp84qzfxoo1/unit_ram.jpg?dl=1", "Bin")
Download("https://www.dropbox.com/s/l1882n1y3lh57hv/unit_catapult.jpg?dl=1", "Bin")
Download("https://www.dropbox.com/s/vdamjtqz65o48l1/unit_knight.jpg?dl=1", "Bin")
Download("https://www.dropbox.com/s/76osqrak8wldnmv/unit_snob.jpg?dl=1", "Bin")
Download("https://www.dropbox.com/s/pwgca635a9drstg/TWMB.exe?dl=1")
Download("https://www.dropbox.com/s/86led4ozce9ofmj/ChangeLog.txt?dl=1")
Download("https://www.dropbox.com/s/aifpjwd1062b1ul/LastChange.txt?dl=1")
#EndRegion

Global $INI = "UserData\Data.ini"
If IniRead($INI, "INFO", "Up", 0) = 0 Then
MsgBox(16, "B³¹d!", "Patcher mo¿e byæ nieaktualny!"&@CRLF&"Zaktualizuj bota z poziomu GUI!")
Exit
EndIf
Global $cVersion = IniRead($INI, "INFO", "Version", "0")

$nVersion = BinaryToString(InetRead("https://www.dropbox.com/s/xcqxi6fm3sdue1y/Version.txt?dl=1"))

$NV = StringReplace($nVersion, ".", "")
$CV = StringReplace($cVersion, ".", "")

If $CV < $NV Or IniRead($INI, "INFO", "Up", 0) = 1 Then autoupdate()
If $CV = $NV Then MsgBox(16, "Program jest aktualny!", "Bot nie wymaga aktualizacji!")

Func autoupdate()
Local $AutoUpdateForm
DirCreate("UserData")
DirCreate("Logs")
DirCreate("Bin")
Update()

$cVersion = $nVersion
IniWrite($INI, "INFO", "Version", $cVersion)
GUISetState(@SW_HIDE, $AutoUpdateForm)
MsgBox(64, "Aktualizacja ukoñczona", "TW Master bot jest teraz aktualny!"&@CRLF&"Obecnie posiadana wersja to: "&$cVersion&@CRLF&@CRLF&"Za 5 sekund nast¹pi automatyczne uruchomienie TW Master bota.", 5)
IniWrite($INI, "INFO", "Up", 0)
Run ("TWMB.exe")
MsgBox(64, "Version "&$nVersion&" changes", BinaryToString(InetRead("https://www.dropbox.com/s/aifpjwd1062b1ul/LastChange.txt?dl=1")))
Exit
EndFunc ;==> Autoupdate()


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
	   $aProgress = Int((($All + InetGetInfo($aulink, 0)) / $AllSize) * 100)
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
EndFunc ;==> Update

Func Download($Link, $Dir = @ScriptDir)
If $Dir <> @ScriptDir Then $Dir = @ScriptDir&"\"&$Dir&"\"
If $Dir = @ScriptDir Then $Dir = @ScriptDir&"\"
$i = _ArrayAdd($Download, $Link&"|"&$Dir)
EndFunc ;==> Download