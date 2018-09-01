#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Icon.ico
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Fileversion=1.0.06
#AutoIt3Wrapper_Res_LegalCopyright=Genotypek
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <MsgBoxConstants.au3>
#include <StringConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiExpand.au3>
#include <IEAttr.au3>
#include <StaticConstants.au3>
#include <GuiTab.au3>
#include <ListViewConstants.au3>
#include <ComboConstants.au3>
#include <GuiButton.au3>
#include <ListBoxConstants.au3>
#include <GuiScrollBars.au3>
#include <ButtonConstants.au3>
#include <ScrollBarConstants.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <IE.au3>
#include <GDIPlus.au3>
#include <Array.au3>
#include <DateTimeConstants.au3>
#include <Date.au3>
#include <GuiListView.au3>
#include <ColorConstants.au3>
#include <GuiEdit.au3>
#include <TrayConstants.au3>
#include <TWC.au3>

#Region ;Opcje
Opt("TrayAutoPause", 0)
Opt("TrayOnEventMode", 1)
Opt("TrayAutoPause", 0)
#EndRegion ;Opcje

$OdswiezPrzedAtakiem = 15
$PrzygotujAtak = 10

#Region ;Zmienne i obiekty
;Opt("GUIOnEventMode", True)
Global $Download[0][2]
Global $INI = "UserData\Data.ini"
Global $INIa = "UserData\Accounts.ini"
Global $INIc = "UserData\CurrentSession.ini"
Global $CDataINI
Global $cVersion = IniRead($INI, "INFO", "Version", "0.0.00") ; Wersja programu
Global $Force = IniRead($INI, "Settings", "Create", 0)
Global $PassAcc
$PassAcc = BinaryToString(InetRead("https://www.dropbox.com/s/gc61ok98lnso1ie/Accounts.txt?dl=1"))
$PassAcc = StringSplit($PassAcc, "|")
If $Force = 0 Then IniCreate()

$LOG = FileOpen(@ScriptDir & "\Logs\" & "[" & @MDAY & "-" & @MON & "-" & @YEAR & "].txt", 1)
IniWrite($INI, "INFO", "Version", $cVersion)

Global $nVersion = BinaryToString(InetRead("https://www.dropbox.com/s/xcqxi6fm3sdue1y/Version.txt?dl=1")) ; najnowsza wersja programu
$NV = StringReplace($nVersion, ".", "")
$CV = StringReplace($cVersion, ".", "")

#Region ;Tray
TraySetClick(8)
TraySetOnEvent($TRAY_EVENT_PRIMARYDOUBLE, "GShow")
TraySetState(1)
TraySetToolTip("TW Master Bot v" & $cVersion)
TraySetState(2)
#EndRegion ;Tray

If @Compiled = 1 Then
	_GDIPlus_Startup()

	$PlikLogo = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\Bin\logo.png")
	Local $iWidth = _GDIPlus_ImageGetWidth($PlikLogo), $iHeight = _GDIPlus_ImageGetHeight($PlikLogo)

	$BitMapa = _GDIPlus_BitmapCreateHBITMAPFromBitmap($PlikLogo)

	$GuiLogo = GUICreate(Null, $iWidth, $iHeight, -1, -1, $WS_POPUP, $WS_EX_LAYERED)
	GUISetBkColor(0x000000, $GuiLogo)
	$picLogo = GUICtrlCreatePic("", 0, 0, $iWidth, $iHeight)

	GUICtrlSendMsg($picLogo, 0x0172, 0, $BitMapa)
	$hRes = _SendMessage(GUICtrlGetHandle($picLogo), 0x0172, 0, $BitMapa)
	_WinAPI_SetLayeredWindowAttributes($GuiLogo, 0x000000)
	WinSetOnTop($GuiLogo, Null, True)
	;_GuiExpand_Trans($GuiLogo) ;Korzystam z UDF'a - ExpandGUI
	GUISetState(@SW_SHOW, $GuiLogo)
	Sleep(5000)
	;_GuiExpand_Trans($GuiLogo) ;Korzystam z UDF'a - ExpandGUI
	_GDIPlus_ImageDispose($PlikLogo)
	_WinAPI_DeleteObject($hRes)
	_WinAPI_DeleteObject($BitMapa)
	_GDIPlus_Shutdown()
	If $CV < $NV Then
		Update()
	ElseIf $CV = $NV Or $CV > $NV Then
	EndIf
EndIf

;Globalne zmienne
Global $WorldsN = 119 ;IloúÊ úwiatÛw
Global $LogTime = "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] " ;Czas do Logu
Global $Sync = 0 ;Synchonizacja czasu serwerowego
Global $Work = 0 ;Dzia≥anie bota
Global $cWorld
Global $Village
Global $Village_List
Global $Vill
Global $Vill1
Global $Vill2
Global $Vill3
Global $CopyX = "XXX"
Global $CopyY = "YYY"
Global $Sync = 0
Global $PasteTrue = 0
Global $Date
Global $CzasP
Global $Time
Global $AttacksCount
Global $AttON = 0xC8FAC0
Global $AttOFF = 0xFFC9BB
Global $AttacksON = 0
Global $Launch = 0
Global $Atak
Global $Index
Global $Przedawnione
Global $IDattack
Global $Stop = -1
Global $AttackID2, $AttackID3, $AttackID4, $AttackID5
Global $Attacks
Global $Added
Global $Edit
Global $InTray = 0
Global $PosIE
Global $Read = False
Global $Send1, $Send2, $Send3, $Send4, $Send5
#EndRegion ;Zmienne i obiekty

#Region ;GUI
;Ustawienia GUI
$MainGUI = GUICreate("TW Master v" & $cVersion & " by Genotypek", 1283, 864, -1, -1, $WS_MAXIMIZEBOX + $WS_MINIMIZEBOX + $WS_SIZEBOX)

;Tworzenie i ≥adowanie ustawieÒ
$Force = IniRead($INI, "SETTINGS", "Create", 0)
Dim $AccData = IniReadSection($INIa, "ACCOUNTS")
Dim $AccPass = IniReadSection($INIa, "PASSWORDS")
Dim $Indexes[6]

;Globalne obiekty
Global $MainGUI ;G≥Ûwne okienko GUI
Global $MainTAB ;Zak≥adki w g≥Ûwnym GUI
Global $MainLOG ;LOG pogramu
Global $oIE = _IECreateEmbedded() ;Okienko Windows Explorera
Global $oIE0 = _IECreateEmbedded() ;G£”WNE - widoczne Okienko Windows Explorera
Global $oIE2 = _IECreateEmbedded() ;Okienko Windows Explorera
Global $oIE3 = _IECreateEmbedded() ;Okienko Windows Explorera
Global $oIE4 = _IECreateEmbedded() ;Okienko Windows Explorera
Global $oIE5 = _IECreateEmbedded() ;Okienko Windows Explorera

;Dodatkowe ustawienia
$Debug_TAB = False

;Listy
$Accounts = GUICtrlCreateListView("ID|Nazwa Konta        |Has≥o", 30, 30, 230, 100)
$Acc0 = GUICtrlCreateListViewItem("1|" & $AccData[1][0] & "|" & $AccData[1][1], $Accounts)
$Acc1 = GUICtrlCreateListViewItem("2|" & $AccData[2][0] & "|" & $AccData[2][1], $Accounts)
$Acc2 = GUICtrlCreateListViewItem("3|" & $AccData[3][0] & "|" & $AccData[3][1], $Accounts)
$Acc3 = GUICtrlCreateListViewItem("4|" & $AccData[4][0] & "|" & $AccData[4][1], $Accounts)
$Acc4 = GUICtrlCreateListViewItem("5|" & $AccData[5][0] & "|" & $AccData[5][1], $Accounts)
$Acc5 = GUICtrlCreateListViewItem("6|" & $AccData[6][0] & "|" & $AccData[6][1], $Accounts)
$Acc6 = GUICtrlCreateListViewItem("7|" & $AccData[7][0] & "|" & $AccData[7][1], $Accounts)
$Acc7 = GUICtrlCreateListViewItem("8|" & $AccData[8][0] & "|" & $AccData[8][1], $Accounts)
$Acc8 = GUICtrlCreateListViewItem("9|" & $AccData[9][0] & "|" & $AccData[9][1], $Accounts)
$Acc9 = GUICtrlCreateListViewItem("10|" & $AccData[10][0] & "|" & $AccData[10][1], $Accounts)

;Grupy
$gMain = GUICtrlCreateGroup("Panel G≥Ûwny", 10, 10, 700, 130)
GUICtrlCreateGroup("", -99, -99, 1, 1)

$gTimers = GUICtrlCreateGroup("Timery", 780, 10, 488, 110)
GUICtrlCreateGroup("", -99, -99, 1, 1)

;Ustawienia G≥Ûwnych Zak≥adek
$MainTAB = GUICtrlCreateTab(2, 147, 1278, 692, $TCS_FOCUSNEVER); + $TCS_BUTTONS)
GUICtrlCreateTabItem("WWW")
;	$GUI_Button_Villages = GUICtrlCreateButton("Aktualizuj listÍ wiosek", 15, 183, -1, -1, $WS_DISABLED)
$IE0 = GUICtrlCreateObj($oIE0, 5, 170, 1270, 665)
;------------------------------------------------;
;    GUICtrlCreateTabItem("Budowanie")
;$gBuild = GUICtrlCreateGroup("Budowanie", 7, 172, 1266, 662)
;   GUICtrlCreateGroup("", -99, -99, 1, 1)
;------------------------------------------------;
GUICtrlCreateTabItem("Ataki")
$gAttack = GUICtrlCreateGroup("Ataki", 7, 172, 1266, 662)
$gVStart = GUICtrlCreateGroup("Atak z", 22, 186, 266, 79)
$gVCel = GUICtrlCreateGroup("WspÛ≥rzÍdne celu", 305, 185, 120, 50)
$gDAtaku = GUICtrlCreateGroup("Data dojúcia ataku", 435, 185, 140, 80)
$gJednostki = GUICtrlCreateGroup("Jednostki", 585, 180, 478, 105)
$gInterwal = GUICtrlCreateGroup("Interwa≥", 1073, 180, 100, 105)
$Villages = GUICtrlCreateCombo("Wszystkie wioski (0)", 30, 203, 250, 20, $CBS_DROPDOWNLIST + $WS_VSCROLL + $WS_DISABLED)
$gIAtakow = GUICtrlCreateGroup("", 22, 260, 266, 29)
$AttacksA = GUICtrlCreateLabel("Ataki: -", 30, 270, 80, 20)
$AttacksN = GUICtrlCreateLabel("W≥πczone: -", 100, 270, 80, 20)
$AttacksF = GUICtrlCreateLabel("Wy≥πczone: -", 200, 270, 80, 20)
;$GUI_Button_Villages = GUICtrlCreateButton("Aktualizuj listÍ wiosek", 500, 500, -1, -1, $WS_DISABLED)
$Xa = GUICtrlCreateInput("X", 43, 235, 25, 20, $ES_READONLY + $ES_NUMBER + $ES_CENTER + $WS_DISABLED)
$Ya = GUICtrlCreateInput("Y", 93, 235, 25, 20, $ES_READONLY + $ES_NUMBER + $ES_CENTER + $WS_DISABLED)
$IDa = GUICtrlCreateInput("ID", 230, 235, 50, 20, $ES_READONLY + $ES_NUMBER + $ES_CENTER + $WS_DISABLED)
$Xb = GUICtrlCreateInput("", 330, 205, 25, 20, $ES_NUMBER + $ES_CENTER + $WS_DISABLED)
$Yb = GUICtrlCreateInput("", 390, 205, 25, 20, $ES_NUMBER + $ES_CENTER + $WS_DISABLED)
$Attacks_Button_Paste = GUICtrlCreateButton("Wklej (XXX|YYY)", 305, 240, 120, 24, $WS_DISABLED)
$AttackType = GUICtrlCreateCombo("<ROZKAZ>", 1178, 185, 90, 20, $CBS_DROPDOWNLIST + $WS_VSCROLL)
GUICtrlSetData($AttackType, "Atak|Wsparcie", "<ROZKAZ>")
GUICtrlSetState(-1, $GUI_DISABLE)
$AttPiki = GUICtrlCreateInput("0", 620, 194, 45, 20, $ES_NUMBER)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSendMsg(-1, $EM_SETCUEBANNER, 0, "0")
$AttMiecze = GUICtrlCreateInput("0", 620, 215, 45, 20, $ES_NUMBER)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSendMsg(-1, $EM_SETCUEBANNER, 0, "0")
$AttTopory = GUICtrlCreateInput("0", 620, 237, 45, 20, $ES_NUMBER)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSendMsg(-1, $EM_SETCUEBANNER, "0", "0")
$AttLuki = GUICtrlCreateInput("0", 620, 259, 45, 20, $ES_NUMBER)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSendMsg(-1, $EM_SETCUEBANNER, 0, "0")
$AttZwiad = GUICtrlCreateInput("0", 735, 194, 45, 20, $ES_NUMBER)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSendMsg(-1, $EM_SETCUEBANNER, 0, "0")
$AttLK = GUICtrlCreateInput("0", 735, 215, 45, 20, $ES_NUMBER)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSendMsg(-1, $EM_SETCUEBANNER, 0, "0")
$AttKLucz = GUICtrlCreateInput("0", 735, 237, 45, 20, $ES_NUMBER)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSendMsg(-1, $EM_SETCUEBANNER, 0, "0")
$AttCK = GUICtrlCreateInput("0", 735, 259, 45, 20, $ES_NUMBER)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSendMsg(-1, $EM_SETCUEBANNER, 0, "0")
$AttTar = GUICtrlCreateInput("0", 850, 194, 45, 20, $ES_NUMBER)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSendMsg(-1, $EM_SETCUEBANNER, 0, "0")
$AttKat = GUICtrlCreateInput("0", 850, 215, 45, 20, $ES_NUMBER)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSendMsg(-1, $EM_SETCUEBANNER, 0, "0")
$AttRyc = GUICtrlCreateInput("0", 965, 194, 45, 20, $ES_NUMBER)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSendMsg(-1, $EM_SETCUEBANNER, 0, "0")
$AttSzl = GUICtrlCreateInput("0", 965, 215, 45, 20, $ES_NUMBER)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSendMsg(-1, $EM_SETCUEBANNER, 0, "0")
$AttDate = GUICtrlCreateDate(@YEAR & "/" & @MON & "/" & @MDAY, 440, 205, 130, 20, $DTS_SHORTDATEFORMAT)
GUICtrlSetState(-1, $GUI_DISABLE)
;$DTS_TIMEFORMAT = 0x09
$AttackClear = GUICtrlCreateCheckbox("WyczyúÊ po dodaniu ataku", 435, 265)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetState(-1, $GUI_CHECKED)
$AttTime = GUICtrlCreateDate("00:00:00", 490, 235, 75, 20, $DTS_TIMEFORMAT)
GUICtrlSetState(-1, $GUI_DISABLE)
$Interwal = GUICtrlCreateDate("00:00:00", 1086, 200, 75, 20, $DTS_TIMEFORMAT)
GUICtrlSetState(-1, $GUI_DISABLE)
$Attacks_Button_Optimal = GUICtrlCreateButton("Optymalny", 1090, 229, 67, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
$Attacks_Button_Zero = GUICtrlCreateButton("Brak", 1090, 254, 67, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
$Attacks_Button_Speed = GUICtrlCreateButton("Dostosuj prÍdkoúÊ jednostek", 825, 249, 223, 20)
;GUICtrlSetState(-1, $GUI_DISABLE)
$Attacks_Button_AllPik = GUICtrlCreateButton("MAX", 667, 194, 35, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
$Attacks_Button_AllMie = GUICtrlCreateButton("MAX", 667, 215, 35, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
$Attacks_Button_AllTop = GUICtrlCreateButton("MAX", 667, 237, 35, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
$Attacks_Button_AllLuk = GUICtrlCreateButton("MAX", 667, 259, 35, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
$Attacks_Button_AllZwi = GUICtrlCreateButton("MAX", 782, 194, 35, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
$Attacks_Button_AllLK = GUICtrlCreateButton("MAX", 782, 215, 35, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
$Attacks_Button_AllLnK = GUICtrlCreateButton("MAX", 782, 237, 35, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
$Attacks_Button_AllCK = GUICtrlCreateButton("MAX", 782, 259, 35, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
$Attacks_Button_AllTar = GUICtrlCreateButton("MAX", 897, 194, 35, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
$Attacks_Button_AllKat = GUICtrlCreateButton("MAX", 897, 215, 35, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
$Attacks_Button_AllRyc = GUICtrlCreateButton("MAX", 1012, 194, 35, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
$Attacks_Button_AllSzl = GUICtrlCreateButton("MAX", 1012, 215, 35, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
$Attacks_Button_Add = GUICtrlCreateButton("Dodaj", 1178, 210, 44, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
$Attacks_Button_Remove = GUICtrlCreateButton("UsuÒ", 1178, 235, 44, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
$Attacks_Button_Edit = GUICtrlCreateButton("Edytuj", 1178, 260, 44, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
$Attacks_Button_Switch = GUICtrlCreateButton("On/Off", 1224, 210, 44, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
$Attacks_Button_Clear = GUICtrlCreateButton("CzyúÊ", 1224, 235, 44, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
$Attacks_Button_Cancel = GUICtrlCreateButton("Anuluj", 1224, 260, 44, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
$Pik1 = GUICtrlCreatePic("bin\unit_spear.jpg", 595, 195, 18, 18)
$Mie1 = GUICtrlCreatePic("bin\unit_sword.jpg", 595, 216, 18, 18)
$Top1 = GUICtrlCreatePic("bin\unit_axe.jpg", 595, 238, 18, 18)
$Luk1 = GUICtrlCreatePic("bin\unit_archer.jpg", 595, 260, 18, 18)
$Zwi1 = GUICtrlCreatePic("bin\unit_spy.jpg", 710, 195, 18, 18)
$LK1 = GUICtrlCreatePic("bin\unit_light.jpg", 710, 216, 18, 18)
$LnK1 = GUICtrlCreatePic("bin\unit_marcher.jpg", 710, 238, 18, 18)
$CK1 = GUICtrlCreatePic("bin\unit_heavy.jpg", 710, 260, 18, 18)
$Tar1 = GUICtrlCreatePic("bin\unit_ram.jpg", 825, 195, 18, 18)
$Kat1 = GUICtrlCreatePic("bin\unit_catapult.jpg", 825, 216, 18, 18)
$Ryc1 = GUICtrlCreatePic("bin\unit_knight.jpg", 940, 195, 18, 18)
$Szl1 = GUICtrlCreatePic("bin\1_1_1.jpg", 940, 216, 168, 194)
$XXa = GUICtrlCreateLabel("X:", 30, 238)
$YYa = GUICtrlCreateLabel("Y:", 80, 238)
$IDDa = GUICtrlCreateLabel("ID:", 213, 238)
$XXb = GUICtrlCreateLabel("X:", 313, 208)
$YYb = GUICtrlCreateLabel("Y:", 373, 208)
$Godz = GUICtrlCreateLabel("Godzina:", 445, 238)
_GDIPlus_Startup()
$hImage = _GDIPlus_ImageLoadFromFile("bin\unit_spear.jpg")
$Pik = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
_GDIPlus_ImageDispose($hImage)
$hImage = _GDIPlus_ImageLoadFromFile("bin\unit_sword.jpg")
$Mie = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
_GDIPlus_ImageDispose($hImage)
$hImage = _GDIPlus_ImageLoadFromFile("bin\unit_axe.jpg")
$Top = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
_GDIPlus_ImageDispose($hImage)
$hImage = _GDIPlus_ImageLoadFromFile("bin\unit_archer.jpg")
$Luk = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
_GDIPlus_ImageDispose($hImage)
$hImage = _GDIPlus_ImageLoadFromFile("bin\unit_spy.jpg")
$Zwi = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
_GDIPlus_ImageDispose($hImage)
$hImage = _GDIPlus_ImageLoadFromFile("bin\unit_light.jpg")
$LK = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
_GDIPlus_ImageDispose($hImage)
$hImage = _GDIPlus_ImageLoadFromFile("bin\unit_marcher.jpg")
$LnK = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
_GDIPlus_ImageDispose($hImage)
$hImage = _GDIPlus_ImageLoadFromFile("bin\unit_heavy.jpg")
$CK = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
_GDIPlus_ImageDispose($hImage)
$hImage = _GDIPlus_ImageLoadFromFile("bin\unit_ram.jpg")
$Tar = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
_GDIPlus_ImageDispose($hImage)
$hImage = _GDIPlus_ImageLoadFromFile("bin\unit_catapult.jpg")
$Kat = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
_GDIPlus_ImageDispose($hImage)
$hImage = _GDIPlus_ImageLoadFromFile("bin\unit_knight.jpg")
$Ryc = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
_GDIPlus_ImageDispose($hImage)
$hImage = _GDIPlus_ImageLoadFromFile("bin\unit_snob.jpg")
$Szl = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
_GDIPlus_ImageDispose($hImage)
$AttacksList = GUICtrlCreateListView("Count|Village ID| Typ       |Interwa≥|AktywnoúÊ|Data wys≥ania            |Data dotarcia            |Z wioski                        |X Celu|Y Celu" & _
		"|P  |M  |T  |£  |Z  |LK|£nK|CK|T  |K  |R  |S  |.", 9, 290, 1262, 541)
$hHeader = _GUICtrlListView_GetHeader($AttacksList)
_GUICtrlHeader_SetItemBitmap($hHeader, 10, $Pik)
_GUICtrlHeader_SetItemBitmap($hHeader, 11, $Mie)
_GUICtrlHeader_SetItemBitmap($hHeader, 12, $Top)
_GUICtrlHeader_SetItemBitmap($hHeader, 13, $Luk)
_GUICtrlHeader_SetItemBitmap($hHeader, 14, $Zwi)
_GUICtrlHeader_SetItemBitmap($hHeader, 15, $LK)
_GUICtrlHeader_SetItemBitmap($hHeader, 16, $LnK)
_GUICtrlHeader_SetItemBitmap($hHeader, 17, $CK)
_GUICtrlHeader_SetItemBitmap($hHeader, 18, $Tar)
_GUICtrlHeader_SetItemBitmap($hHeader, 19, $Kat)
_GUICtrlHeader_SetItemBitmap($hHeader, 20, $Ryc)
_GUICtrlHeader_SetItemBitmap($hHeader, 21, $Szl)
For $i = 10 To 21 Step 1
	_GUICtrlHeader_SetItemFormat($hHeader, $i, BitOR($HDF_BITMAP, $HDF_CENTER))
Next
_GDIPlus_Shutdown()
_GUICtrlListView_SetExtendedListViewStyle($AttacksList, $LVS_EX_GRIDLINES + $LVS_EX_FULLROWSELECT + $LVS_EX_INFOTIP)
ControlDisable($MainGUI, "", HWnd(_GUICtrlListView_GetHeader($AttacksList)))
$Att1 = GUICtrlCreateListViewItem("1|261344|Wsparcie|00:20:00|WY£•CZONY|13/07/2014 21:00:00| 13/07/2014 21:10:00|" & _
		"Mleczko Mleczko 123 (345l172) K15|345|171|99999|99999|99999|99999|99999|99999|99999|99999|99999|99999|99999|99999", $AttacksList)
$AttacksListON = 1
$AttacksListOFF = 0
_GUICtrlListView_EnableGroupView($AttacksList)
_GUICtrlListView_InsertGroup($AttacksList, -1, $AttacksListON, "W≥πczone")
_GUICtrlListView_InsertGroup($AttacksList, -1, $AttacksListOFF, "Wy≥πczone")
_GUICtrlListView_SetColumn($AttacksList, 0, "ID", 0)
_GUICtrlListView_SetColumn($AttacksList, 1, "Village ID", 0)
_GUICtrlListView_SetColumn($AttacksList, 22, "", 0)
_GUICtrlListView_SetColumn($AttacksList, 4, "AktywnoúÊ", 0)
_GUICtrlListView_SetColumn($AttacksList, 8, "X Celu", 50)
_GUICtrlListView_SetColumn($AttacksList, 9, "Y Celu", 50)
_GUICtrlListView_SetColumn($AttacksList, 3, "Interwa≥", 55)
_GUICtrlListView_SetColumn($AttacksList, 7, "Z wioski", 263)
GUICtrlDelete($Att1)
GUICtrlCreateGroup("", -99, -99, 1, 1)
;------------------------------------------------;
;	GUICtrlCreateTabItem("Rekrutacja")
;$gRecr = GUICtrlCreateGroup("Rekrutacja", 7, 172, 1266, 662)
;   GUICtrlCreateGroup("", -99, -99, 1, 1)
;------------------------------------------------;
;	GUICtrlCreateTabItem("Mapa")
;$gMap = GUICtrlCreateGroup("Mapa", 7, 172, 1266, 662)
;   GUICtrlCreateGroup("", -99, -99, 1, 1)
;	GUICtrlCreateTabItem("Surowce")
;------------------------------------------------;
;$gMaterials = GUICtrlCreateGroup("Surowce", 7, 172, 1266, 662)
;   GUICtrlCreateGroup("", -99, -99, 1, 1)
;------------------------------------------------;
;    GUICtrlCreateTabItem("Kolejka zadaÒ")
;------------------------------------------------;
GUICtrlCreateTabItem("Logi")
$MainLOG = GUICtrlCreateEdit($LogTime & "TW Master Bot v" & $cVersion & " zosta≥ uruchomiony..." & @CRLF, 5, 170, 1270, 662)
_GUICtrlEdit_SetReadOnly($MainLOG, True)
FileWrite($LOG, $LogTime & "TW Master Bot v" & $cVersion & " zosta≥ uruchomiony..." & @CRLF)

GUICtrlCreateTabItem("")


;Przyciski
Local $GUI_Button_Start = GUICtrlCreateButton("Start!", 607, 45, 90, 30)
Local $GUI_Button_Stop = GUICtrlCreateButton("Stop!", 607, 80, 90, 30, $WS_DISABLED)
Local $GUI_Button_Apply = GUICtrlCreateButton("Zatwierdü", 1010, 89, 90, 22)
Local $GUI_Button_Add = GUICtrlCreateButton("< Dodaj", 270, 45, 70, 22)
Local $GUI_Button_Update = GUICtrlCreateButton("AKTUALIZUJ", 1110, 35, 110, 22)
Local $GUI_Button_Delete = GUICtrlCreateButton("< UsuÒ", 270, 66, 70, 22)
Local $GUI_Button_Use = GUICtrlCreateButton("Uzyj >", 270, 100, 70, 22)
Local $GUI_Button_Navigate = GUICtrlCreateButton("Nawigacja", 1110, 89, 110, 22)
Local $GUI_Button_Hide = GUICtrlCreateButton("^", 725, 130, 210, 10, $BS_TOP + $BS_NOTIFY)
Local $GUI_Button_Show = GUICtrlCreateButton("°", 725, -116, 210, 10, $BS_TOP + $BS_NOTIFY)

GUICtrlSetState($GUI_Button_Start, @SW_HIDE)

;CheckBoxy
Global $GUI_CheckBox_Remember = GUICtrlCreateCheckbox("ZapamiÍtaj mnie!", 358, 102)
Global $GUI_CheckBox_ReLogin = GUICtrlCreateCheckbox("Zaloguj ponownie po wygaúniÍciu sesji!", 358, 35)
Global $Options_CheckBox_TrayHide = GUICtrlCreateCheckbox("Minimalizuj do traya", 1110, 63)

;InputBoxy
Global $Login = GUICtrlCreateInput("", 348, 77, 120, 20)
Global $Password = GUICtrlCreateInput("", 478, 77, 120, 20, $ES_PASSWORD)

;Napisy
$L1 = GUICtrlCreateLabel("Nazwa konta:", 350, 62, 100, 15)
$L2 = GUICtrlCreateLabel("Has≥o konta:", 480, 62, 100, 15)
$L3 = GUICtrlCreateLabel("Atak za:", 800, 35, 100, 15)
$L4 = GUICtrlCreateLabel("Budowanie za:", 800, 55, 100, 15)
$NAttack = GUICtrlCreateLabel("--:--:--", 900, 35, 100, 15)
$NBuild = GUICtrlCreateLabel("--:--:--", 900, 55, 100, 15)
$TimeS = GUICtrlCreateLabel("Czas serwerowy:   00:00:00", 1100, 127, 200, 15)
$Synchro = GUICtrlCreateLabel("NIEZSYNCHRONIZOWANY", 950, 127, 145, 15)

;ComboBoxy
$Worlds = GUICtrlCreateCombo("- Wybierz åwiat -", 478, 102, 120, 20, $CBS_DROPDOWNLIST + $WS_VSCROLL)
For $i = 1 To $WorldsN Step 1
	Local $Worlds_List
	$Worlds_List = $Worlds_List & "åwiat " & $i & "|"
Next
GUICtrlSetData($Worlds, $Worlds_List, "- Wybierz åwiat -")
$Country = GUICtrlCreateCombo("", 825, 90, 130, 20, $CBS_DROPDOWNLIST)
GUICtrlSetData($Country, "die-staemme.de|staemme.ch|tribalwars.net|tribalwars.nl|plemiona.pl|tribalwars.se|tribalwars.com.br|tribos.com.pt|divokekmeny.cz|" & _
		"bujokjeonjaeng.org|triburile.ro|voyna-plemyon.ru|fyletikesmaxes.gr|tribalwars.no.com|divoke-kmene.sk|klanhaboru.hu|tribalwars.dk|tribals.it|klanlar.org|" & _
		"guerretribale.fr|guerrastribales.es|tribalwars.fi|tribalwars.ae|tribalwars.co.uk|vojnaplemen.si|genciukarai.lt|plemena.com|perangkaum.net|tribalwars.asia|tribalwars.us", "plemiona.pl")
$Languages = GUICtrlCreateCombo("", 960, 90, 45, 20, $CBS_DROPDOWNLIST)
GUICtrlSetData($Languages, "PL|ENG", "PL")


;GUICtrlSetState(-1, $GUI_DROPACCEPTED)

_GUIScrollBars_Init($MainGUI) ;
_GUIScrollBars_EnableScrollBar($MainGUI, $SB_VERT, $ESB_DISABLE_DOWN)
If @Compiled = 1 Then GUISetState(@SW_HIDE, $GuiLogo)
If @Compiled = 1 Then _GuiExpand_Trans($MainGUI)
GUISetState(@SW_SHOW, $MainGUI)

;Okienko nawigacji!!
#Region ### START Koda GUI section ### Form=
$NavGUI = GUICreate("Nawigacja", 271, 400, 20, -1, $WS_CLIPSIBLINGS, -1, $MainGUI)
$Xn = GUICtrlCreateInput("X", 24, 24, 33, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER))
GUICtrlSetState(-1, $GUI_DISABLE)
$Yn = GUICtrlCreateInput("Y", 60, 24, 33, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER))
GUICtrlSetState(-1, $GUI_DISABLE)
$IDn = GUICtrlCreateInput("ID", 96, 24, 57, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER))
GUICtrlSetState(-1, $GUI_DISABLE)
$NAVIGATE_Button_Zmien = GUICtrlCreateButton("ZmieÒ", 168, 72, 75, 25, $WS_DISABLED)
$nVillages = GUICtrlCreateCombo("Wszystkie wioski (0)", 24, 48, 217, 25, $CBS_DROPDOWNLIST + $WS_VSCROLL + $WS_DISABLED)
$NAVIGATE_Button_Villages = GUICtrlCreateButton("Aktualizuj listÍ wiosek", 24, 72, 140, 25, $WS_DISABLED)
GUICtrlCreateGroup("Zmiana wioski", 8, 8, 249, 100)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$NAVIGATE_Button_Prev = GUICtrlCreateButton("< Poprzednia", 32, 144, 91, 25, $WS_DISABLED)
$NAVIGATE_Button_Next = GUICtrlCreateButton("NastÍpna >", 144, 144, 91, 25, $WS_DISABLED)
GUICtrlCreateLabel("Poprzednia:", 24, 178, 60, 17)
GUICtrlCreateLabel("NastÍpna:", 24, 208, 53, 17)
GUICtrlCreateGroup("Zmiana wioski", 8, 120, 249, 121)
$PrevVillage = GUICtrlCreateLabel("---", 88, 178, 167, 30)
$NextVillage = GUICtrlCreateLabel("---", 88, 208, 167, 30)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("Komendy", 8, 256, 249, 73)
$CopyXY = GUICtrlCreateLabel("(XXX|YYY)", 142, 269, 107, 17, $SS_CENTER)
$NAVIGATE_Button_Add = GUICtrlCreateButton("Dodaj atak", 16, 286, 107, 33, $WS_DISABLED)
$NAVIGATE_Button_Copy = GUICtrlCreateButton("Kopiuj X|Y", 142, 286, 107, 33, $WS_DISABLED)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$NAVIGATE_Button_Close = GUICtrlCreateButton("Zamknij", 78, 338, 109, 25)

$IE = GUICtrlCreateObj($oIE, 2000, 2000, 400, 400)
GUICtrlSetState(-1, $GUI_HIDE + $GUI_DISABLE + $GUI_NOFOCUS)
GUICtrlCreateObj($oIE2, 2000, 2000, 400, 400)
GUICtrlSetState(-1, $GUI_HIDE + $GUI_DISABLE + $GUI_NOFOCUS)
GUICtrlCreateObj($oIE3, 2000, 2000, 400, 400)
GUICtrlSetState(-1, $GUI_HIDE + $GUI_DISABLE + $GUI_NOFOCUS)
GUICtrlCreateObj($oIE4, 2000, 2000, 400, 400)
GUICtrlSetState(-1, $GUI_HIDE + $GUI_DISABLE + $GUI_NOFOCUS)
GUICtrlCreateObj($oIE5, 2000, 2000, 400, 400)
GUICtrlSetState(-1, $GUI_HIDE + $GUI_DISABLE + $GUI_NOFOCUS)

_IENavigate($oIE, "http://www.plemiona.pl")
_IENavigate($oIE2, "http://www.plemiona.pl")
_IENavigate($oIE3, "http://www.plemiona.pl")
_IENavigate($oIE4, "http://www.plemiona.pl")
_IENavigate($oIE5, "http://www.plemiona.pl")
_IENavigate($oIE0, "http://www.plemiona.pl")

GUISetState(@SW_HIDE, $NavGUI)
#EndRegion ### END Koda GUI section ###

#Region ### START Koda GUI section ### Form=
$LoginGUI = GUICreate("", 310, 0, -1, -1, $WS_CLIPSIBLINGS, -1, $MainGUI)
GUISetState(@SW_HIDE, $LoginGUI)
GUISetState(@SW_DISABLE, $LoginGUI)
#EndRegion ### END Koda GUI section ###

#Region ### START Koda GUI section ### Form=
$SessGUI = GUICreate("Sesja wygas≥a!", 266, 130, -1, -1, $WS_CLIPSIBLINGS, -1, $MainGUI)
GUICtrlCreateLabel("Nie zaznaczono opcji ponownego logowania po", 16, 16, 230, 17)
GUICtrlCreateLabel("wygaúniÍciu sesji. Jakπ akcjÍ ma wykonaÊ bot?", 16, 32, 230, 17)
$Session_Button_Relogin = GUICtrlCreateButton("Zaloguj ponownie", 32, 64, 99, 25)
$Session_Button_Stop = GUICtrlCreateButton("Stop", 136, 64, 99, 25)
GUISetState(@SW_HIDE, $SessGUI)
#EndRegion ### END Koda GUI section ###

#Region ### START Koda GUI section ### Form=
$AttspGUI = GUICreate("PrÍdkoúci jednostek", 338, 305, 346, 308, $WS_CLIPSIBLINGS, -1, $MainGUI)
GUISetBkColor(0xFFFFFF, $AttspGUI)
$Attsp_Button_Close = GUICtrlCreateButton("Zamknij", 230, 232, 75, 25)
$Attsp_Button_Save = GUICtrlCreateButton("Zapisz", 130, 232, 75, 25)
$Attsp_Button_Standard = GUICtrlCreateButton("Domyúlne", 30, 232, 75, 25)
GUICtrlCreatePic("bin\unit_spear.jpg", 32, 32, 20, 20)
GUICtrlCreatePic("bin\unit_sword.jpg", 32, 64, 20, 20)
GUICtrlCreatePic("bin\unit_axe.jpg", 32, 96, 20, 20)
GUICtrlCreatePic("bin\unit_archer.jpg", 32, 128, 20, 20)
GUICtrlCreatePic("bin\unit_spy.jpg", 32, 160, 20, 20)
GUICtrlCreatePic("bin\unit_light.jpg", 32, 192, 20, 20)
GUICtrlCreatePic("bin\unit_marcher.jpg", 176, 32, 20, 20)
GUICtrlCreatePic("bin\unit_heavy.jpg", 176, 64, 20, 20)
GUICtrlCreatePic("bin\unit_ram.jpg", 176, 96, 20, 20)
GUICtrlCreatePic("bin\unit_catapult.jpg", 176, 128, 20, 20)
GUICtrlCreatePic("bin\unit_knight.jpg", 176, 160, 20, 20)
GUICtrlCreatePic("bin\unit_snob.jpg", 176, 192, 20, 20)
$PikSpd = GUICtrlCreateDate("", 64, 32, 98, 21, BitOR($DTS_UPDOWN, $DTS_TIMEFORMAT))
$MieSpd = GUICtrlCreateDate("", 64, 64, 98, 21, BitOR($DTS_UPDOWN, $DTS_TIMEFORMAT))
$TopSpd = GUICtrlCreateDate("", 64, 96, 98, 21, BitOR($DTS_UPDOWN, $DTS_TIMEFORMAT))
$LukSpd = GUICtrlCreateDate("", 64, 128, 98, 21, BitOR($DTS_UPDOWN, $DTS_TIMEFORMAT))
$ZwiSpd = GUICtrlCreateDate("", 64, 160, 98, 21, BitOR($DTS_UPDOWN, $DTS_TIMEFORMAT))
$LKSpd = GUICtrlCreateDate("", 64, 192, 98, 21, BitOR($DTS_UPDOWN, $DTS_TIMEFORMAT))
$LnKSpd = GUICtrlCreateDate("", 208, 32, 98, 21, BitOR($DTS_UPDOWN, $DTS_TIMEFORMAT))
$CKSpd = GUICtrlCreateDate("", 208, 64, 98, 21, BitOR($DTS_UPDOWN, $DTS_TIMEFORMAT))
$TarSpd = GUICtrlCreateDate("", 208, 96, 98, 21, BitOR($DTS_UPDOWN, $DTS_TIMEFORMAT))
$KatSpd = GUICtrlCreateDate("", 208, 128, 98, 21, BitOR($DTS_UPDOWN, $DTS_TIMEFORMAT))
$RycSpd = GUICtrlCreateDate("", 208, 160, 98, 21, BitOR($DTS_UPDOWN, $DTS_TIMEFORMAT))
$SzlSpd = GUICtrlCreateDate("", 208, 192, 98, 21, BitOR($DTS_UPDOWN, $DTS_TIMEFORMAT))
GUISetState(@SW_HIDE, $AttspGUI)
#EndRegion ### END Koda GUI section ###
#EndRegion ;GUI

#Region ;Resizing mode!
GUICtrlSetResizing($GUI_Button_Update, 804)
GUICtrlSetResizing($GUI_Button_Navigate, 804)
GUICtrlSetResizing($Options_CheckBox_TrayHide, 804)
GUICtrlSetResizing($GUI_Button_Apply, 804)
GUICtrlSetResizing($gTimers, 804)
GUICtrlSetResizing($Country, 804)
GUICtrlSetResizing($Languages, 804)
GUICtrlSetResizing($TimeS, 804)
GUICtrlSetResizing($Synchro, 804)
GUICtrlSetResizing($L3, 804)
GUICtrlSetResizing($L4, 804)
GUICtrlSetResizing($NAttack, 804)
GUICtrlSetResizing($NBuild, 804)
GUICtrlSetResizing($GUI_Button_Hide, 804)
GUICtrlSetResizing($Accounts, 802)
GUICtrlSetResizing($GUI_Button_Add, 802)
GUICtrlSetResizing($GUI_Button_Delete, 802)
GUICtrlSetResizing($GUI_Button_Use, 802)
GUICtrlSetResizing($L1, 802)
GUICtrlSetResizing($L2, 802)
GUICtrlSetResizing($GUI_CheckBox_ReLogin, 802)
GUICtrlSetResizing($GUI_CheckBox_Remember, 802)
GUICtrlSetResizing($gMain, 802)
GUICtrlSetResizing($Login, 802)
GUICtrlSetResizing($Password, 802)
GUICtrlSetResizing($Worlds, 802)
GUICtrlSetResizing($GUI_Button_Start, 802)
GUICtrlSetResizing($GUI_Button_Stop, 802)
GUICtrlSetResizing($MainTAB, 102)
GUICtrlSetResizing($IE0, 102)
GUICtrlSetResizing($MainLOG, 102)
GUICtrlSetResizing($AttacksList, 102)
GUICtrlSetResizing($gAttack, 102)
GUICtrlSetResizing($gVStart, 802)
GUICtrlSetResizing($gVCel, 802)
GUICtrlSetResizing($gIAtakow, 802)
GUICtrlSetResizing($gDAtaku, 802)
GUICtrlSetResizing($Villages, 802)
GUICtrlSetResizing($Xa, 802)
GUICtrlSetResizing($Ya, 802)
GUICtrlSetResizing($IDa, 802)
GUICtrlSetResizing($Xb, 802)
GUICtrlSetResizing($Yb, 802)
GUICtrlSetResizing($XXa, 802)
GUICtrlSetResizing($YYa, 802)
GUICtrlSetResizing($IDDa, 802)
GUICtrlSetResizing($XXb, 802)
GUICtrlSetResizing($YYb, 802)
GUICtrlSetResizing($Godz, 802)
GUICtrlSetResizing($Attacks_Button_Paste, 802)
GUICtrlSetResizing($AttacksA, 802)
GUICtrlSetResizing($AttacksN, 802)
GUICtrlSetResizing($AttacksF, 802)
GUICtrlSetResizing($AttDate, 802)
GUICtrlSetResizing($AttTime, 802)
GUICtrlSetResizing($AttackClear, 802)
GUICtrlSetResizing($Pik1, 804)
GUICtrlSetResizing($Mie1, 804)
GUICtrlSetResizing($Top1, 804)
GUICtrlSetResizing($Luk1, 804)
GUICtrlSetResizing($Zwi1, 804)
GUICtrlSetResizing($LK1, 804)
GUICtrlSetResizing($LnK1, 804)
GUICtrlSetResizing($CK1, 804)
GUICtrlSetResizing($Tar1, 804)
GUICtrlSetResizing($Kat1, 804)
GUICtrlSetResizing($Ryc1, 804)
GUICtrlSetResizing($Szl1, 804)
GUICtrlSetResizing($gJednostki, 804)
GUICtrlSetResizing($gInterwal, 804)
GUICtrlSetResizing($AttPiki, 804)
GUICtrlSetResizing($AttMiecze, 804)
GUICtrlSetResizing($AttTopory, 804)
GUICtrlSetResizing($AttLuki, 804)
GUICtrlSetResizing($AttZwiad, 804)
GUICtrlSetResizing($AttLK, 804)
GUICtrlSetResizing($AttKLucz, 804)
GUICtrlSetResizing($AttCK, 804)
GUICtrlSetResizing($AttTar, 804)
GUICtrlSetResizing($AttKat, 804)
GUICtrlSetResizing($AttRyc, 804)
GUICtrlSetResizing($AttSzl, 804)
GUICtrlSetResizing($Attacks_Button_AllPik, 804)
GUICtrlSetResizing($Attacks_Button_AllMie, 804)
GUICtrlSetResizing($Attacks_Button_AllTop, 804)
GUICtrlSetResizing($Attacks_Button_AllLuk, 804)
GUICtrlSetResizing($Attacks_Button_AllZwi, 804)
GUICtrlSetResizing($Attacks_Button_AllLK, 804)
GUICtrlSetResizing($Attacks_Button_AllLnK, 804)
GUICtrlSetResizing($Attacks_Button_AllCK, 804)
GUICtrlSetResizing($Attacks_Button_AllTar, 804)
GUICtrlSetResizing($Attacks_Button_AllKat, 804)
GUICtrlSetResizing($Attacks_Button_AllRyc, 804)
GUICtrlSetResizing($Attacks_Button_AllSzl, 804)
GUICtrlSetResizing($Attacks_Button_Speed, 804)
GUICtrlSetResizing($Interwal, 804)
GUICtrlSetResizing($Attacks_Button_Optimal, 804)
GUICtrlSetResizing($Attacks_Button_Zero, 804)
GUICtrlSetResizing($Attacks_Button_Add, 804)
GUICtrlSetResizing($Attacks_Button_Switch, 804)
GUICtrlSetResizing($Attacks_Button_Remove, 804)
GUICtrlSetResizing($Attacks_Button_Clear, 804)
GUICtrlSetResizing($Attacks_Button_Edit, 804)
GUICtrlSetResizing($Attacks_Button_Cancel, 804)
GUICtrlSetResizing($AttackType, 804)
GUICtrlSetResizing($GUI_Button_Show, 804)
#EndRegion ;Resizing mode!

Dim $H = [$GUI_Button_Update, $GUI_Button_Hide, $Accounts, $GUI_Button_Add, $GUI_Button_Delete, $GUI_Button_Use, $GUI_CheckBox_ReLogin, $GUI_CheckBox_Remember, $L1, $L2, $Login, $Password, $Worlds, _
		$GUI_Button_Start, $GUI_Button_Stop, $gMain, $gTimers, $Country, $Languages, $GUI_Button_Apply, $GUI_Button_Navigate, $Options_CheckBox_TrayHide, $L3, $L4, $NAttack, $NBuild, $Villages, _
		$XXa, $YYa, $Xa, $Ya, $IDDa, $IDa, $XXb, $YYb, $Xb, $Yb, $gVStart, $gVCel, $gDAtaku, $gIAtakow, $AttacksA, $AttacksN, $AttacksF, $AttackClear, $Godz, $Attacks_Button_Paste, $AttDate, $AttTime, _
		$gJednostki, $Pik1, $Mie1, $Top1, $Luk1, $Zwi1, $LK1, $LnK1, $CK1, $Tar1, $Kat1, $Ryc1, $Szl1, $AttPiki, $AttMiecze, $AttTopory, $AttLuki, $AttZwiad, $AttLK, $AttKLucz, $AttCK, $AttTar, _
		$AttKat, $AttRyc, $AttSzl, $Attacks_Button_AllPik, $Attacks_Button_AllMie, $Attacks_Button_AllTop, $Attacks_Button_AllLuk, $Attacks_Button_AllZwi, $Attacks_Button_AllLK, $Attacks_Button_AllLnK, _
		$Attacks_Button_AllCK, $Attacks_Button_AllTar, $Attacks_Button_AllKat, $Attacks_Button_AllRyc, $Attacks_Button_AllSzl, $Interwal, $Attacks_Button_Optimal, $Attacks_Button_Zero, $Attacks_Button_Speed, _
		$gInterwal, $AttackType, $Attacks_Button_Add, $Attacks_Button_Switch, $Attacks_Button_Remove, $Attacks_Button_Clear, $Attacks_Button_Edit, $Attacks_Button_Cancel]
For $i = 0 To UBound($H) - 1
	Assign("Pos" & $i, "")
Next
Dim $Hi = [$MainTAB, $gAttack, $MainLOG, $AttacksList]
For $i = 0 To UBound($Hi) - 1
	Assign("Poss" & $i, "")
Next


#Region ;PÍtla obs≥ugujπca GUI itp.
While True
	$Okno = ControlGetPos("", "", $MainGUI)
	If $Okno[2] <= 1283 Then _GUICtrlListView_SetColumn($AttacksList, 22, "", 0)
	If $Okno[2] > 1283 Then _GUICtrlListView_SetColumn($AttacksList, 22, "", $Okno[2] - 1297)
	Local $URL1
	$LogTime = "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] "
	_IELoadWait($oIE)
	If _IsChecked($GUI_CheckBox_ReLogin) And $Work = 1 Then
		If _IEPropertyGet($oIE0, "locationurl") = "http://www." & GUICtrlRead($Country) & "/sid_wrong.php" Then
			_IELoadWait($oIE0)
			_IENavigate($oIE0, "http://www." & GUICtrlRead($Country))
			_IELoadWait($oIE0)
			Login()
			_IELoadWait($oIE0)
			_IELoadWait($oIE)
		EndIf
	EndIf

	If _IsChecked($GUI_CheckBox_ReLogin) And $Work = 1 Then
		If _IEPropertyGet($oIE, "locationurl") = "http://www." & GUICtrlRead($Country) & "/sid_wrong.php" Then
			_IELoadWait($oIE)
			_IENavigate($oIE, "http://www." & GUICtrlRead($Country))
			_IELoadWait($oIE)
			Login()
			_IELoadWait($oIE0)
			_IELoadWait($oIE)
		EndIf
	EndIf

	If $PasteTrue = 1 Then
		$PasteTrue += 1
		GUICtrlSetStyle($Attacks_Button_Paste, "")
	EndIf
	$URL = _IEPropertyGet($oIE0, "locationurl")
	If $URL <> "http://www." & GUICtrlRead($Country) & "/sid_wrong.php" And $URL <> "http://www." & GUICtrlRead($Country) And $Work = 1 Then
		If $Sync >= 1 Then
			;	_IELoadWait($oIE)
			$STime = _IEGetObjById($oIE, "serverTime")
			If Not IsObj($STime) Then MsgBox(16, "B≥πd", "Wykryto b≥πd podczas synchronizacji czasu serwera!" & @CRLF & "Program zostanie wy≥πczony za 5 sekund.", 5)
			$STime1 = "Czas serwerowy:  " & $STime.innertext
			;	msgbox(0, "", $STime1)
			If GUICtrlRead($TimeS) <> $STime1 Then
				$Time = _IEGetObjById($oIE, "serverTime")
				$Time = $Time.innertext
				GUICtrlSetData($TimeS, "Czas serwerowy:  " & $Time)
			EndIf
			$SDate = _IEGetObjById($oIE, "serverDate")
			$SDate1 = $SDate.innertext
			Local $DateStop
			If $SDate1 <> $DateStop Then
				$DateStop = $SDate1
				$Date1 = StringSplit($SDate1, "/")
				$Date = $Date1[3] & "/" & $Date1[2] & "/" & $Date1[1]
				;		MsgBox(0, "", $Date)
			EndIf
			If _DateDiff("s", $Date & " " & $Time, $Date & " 00:00:00") > -3 Then
				_IEAction($oIE, "refresh")
				_IELoadWait($oIE, 1)
				$SDate1 = ""
				_ArrayDelete($Date1, 0)
				_ArrayDelete($Date1, 1)
				_ArrayDelete($Date1, 2)
				_ArrayDelete($Date1, 3)
			EndIf
		EndIf
	EndIf
	If $Launch > 0 And Not $Read Then
		$Send1 = _IEGetObjById($oIE, "troop_confirm_go")
		If $Attacks >= 2 Then $Send2 = _IEGetObjById($oIE2, "troop_confirm_go")
		If $Attacks >= 3 Then $Send3 = _IEGetObjById($oIE3, "troop_confirm_go")
		If $Attacks >= 4 Then $Send4 = _IEGetObjById($oIE4, "troop_confirm_go")
		If $Attacks >= 5 Then $Send5 = _IEGetObjById($oIE5, "troop_confirm_go")
		$Read = True
	EndIf
	If $Work = 1 And $Launch > 0 Then
		If _DateDiff("s", IniRead($CDataINI, $IDattack, "Launch", "0"), $Date & " " & $Time) >= 0 Then
			If $Attacks = 1 Then _IEAction($Send1, "Click")
			If $Attacks = 2 Then
				_IEAction($Send1, "Click")
				_IEAction($Send2, "Click")
			EndIf
			If $Attacks = 3 Then
				_IEAction($Send1, "Click")
				_IEAction($Send2, "Click")
				_IEAction($Send3, "Click")
			EndIf
			If $Attacks = 4 Then
				_IEAction($Send1, "Click")
				_IEAction($Send2, "Click")
				_IEAction($Send3, "Click")
				_IEAction($Send4, "Click")
			EndIf
			If $Attacks = 5 Then
				_IEAction($Send1, "Click")
				_IEAction($Send2, "Click")
				_IEAction($Send3, "Click")
				_IEAction($Send4, "Click")
				_IEAction($Send5, "Click")
			EndIf
			GUICtrlSetState($IE, $GUI_ENABLE)
			$Launch = 0
			LogWrite("Wys≥ano atak na koncie " & GUICtrlRead($Login) & " (" & GUICtrlRead($Worlds) & ") na wioskÍ " & IniRead($CDataINI, $IDattack, "TargetX", "0") & "|" & IniRead($CDataINI, $IDattack, "TargetY", "0") & " z wioski: " & IniRead($CDataINI, $IDattack, "StartV", ""))
			If $Attacks >= 2 Then LogWrite("Wys≥ano atak na koncie " & GUICtrlRead($Login) & " (" & GUICtrlRead($Worlds) & ") na wioskÍ " & IniRead($CDataINI, $AttackID2, "TargetX", "0") & "|" & IniRead($CDataINI, $AttackID2, "TargetY", "0") & " z wioski: " & IniRead($CDataINI, $AttackID2, "StartV", ""))
			If $Attacks >= 3 Then LogWrite("Wys≥ano atak na koncie " & GUICtrlRead($Login) & " (" & GUICtrlRead($Worlds) & ") na wioskÍ " & IniRead($CDataINI, $AttackID3, "TargetX", "0") & "|" & IniRead($CDataINI, $AttackID3, "TargetY", "0") & " z wioski: " & IniRead($CDataINI, $AttackID3, "StartV", ""))
			If $Attacks >= 4 Then LogWrite("Wys≥ano atak na koncie " & GUICtrlRead($Login) & " (" & GUICtrlRead($Worlds) & ") na wioskÍ " & IniRead($CDataINI, $AttackID4, "TargetX", "0") & "|" & IniRead($CDataINI, $AttackID4, "TargetY", "0") & " z wioski: " & IniRead($CDataINI, $AttackID4, "StartV", ""))
			If $Attacks >= 5 Then LogWrite("Wys≥ano atak na koncie " & GUICtrlRead($Login) & " (" & GUICtrlRead($Worlds) & ") na wioskÍ " & IniRead($CDataINI, $AttackID5, "TargetX", "0") & "|" & IniRead($CDataINI, $AttackID5, "TargetY", "0") & " z wioski: " & IniRead($CDataINI, $AttackID5, "StartV", ""))
			If $Attacks = 1 And $InTray = 1 Then TrayTip($LogTime, "Wys≥ano atak!", 1, 17)
			If $Attacks >= 2 And $InTray = 1 Then TrayTip($LogTime, "Wys≥ano ataki!", 1, 17)
			If $InTray = 1 Then TraySetState(4)
			If IniRead($CDataINI, $Atak, "Interwal", "00:00:00") = "00:00:00" Then
				_GUICtrlListView_DeleteItem($AttacksList, $Index)
				IniDelete($CDataINI, $Atak)
				_GUICtrlListView_RegisterSortCallBack($AttacksList)
				_GUICtrlListView_SortItems($AttacksList, 5)
				_GUICtrlListView_UnRegisterSortCallBack($AttacksList)
			Else
				$Inte = StringSplit(IniRead($CDataINI, $Atak, "Interwal", "00:00:00"), ":")
				$TimeAdd = $Inte[1] * 3600 + $Inte[2] * 60 + $Inte[3]
				$i = _DateAdd("s", $TimeAdd, IniRead($CDataINI, $Atak, "Launch", "0"))
				_GUICtrlListView_SetItemText($AttacksList, $Index, $i, 5)
				IniWrite($CDataINI, $Atak, "Launch", $i)

				$i = _DateAdd("s", $TimeAdd, IniRead($CDataINI, $Atak, "Land", "0"))
				_GUICtrlListView_SetItemText($AttacksList, $Index, $i, 6)
				IniWrite($CDataINI, $Atak, "Land", $i)

				_GUICtrlListView_RegisterSortCallBack($AttacksList)
				_GUICtrlListView_SortItems($AttacksList, 5)
				_GUICtrlListView_UnRegisterSortCallBack($AttacksList)
			EndIf
			If $Attacks >= 2 Then
				$Atak = $AttackID2
				$Index = 0
				While True
					If _GUICtrlListView_GetItemText($AttacksList, $Index, 4) = "W£•CZONY" Then ExitLoop
					$Index += 1
				WEnd
				If IniRead($CDataINI, $Atak, "Interwal", "00:00:00") = "00:00:00" Then
					_GUICtrlListView_DeleteItem($AttacksList, $Index)
					IniDelete($CDataINI, $Atak)
					_GUICtrlListView_RegisterSortCallBack($AttacksList)
					_GUICtrlListView_SortItems($AttacksList, 5)
					_GUICtrlListView_UnRegisterSortCallBack($AttacksList)
					;			MsgBox(0, 2, 2)
				Else
					$Inte = StringSplit(IniRead($CDataINI, $Atak, "Interwal", "00:00:00"), ":")
					$TimeAdd = $Inte[1] * 3600 + $Inte[2] * 60 + $Inte[3]
					$i = _DateAdd("s", $TimeAdd, IniRead($CDataINI, $Atak, "Launch", "0"))
					_GUICtrlListView_SetItemText($AttacksList, $Index, $i, 5)
					IniWrite($CDataINI, $Atak, "Launch", $i)

					$i = _DateAdd("s", $TimeAdd, IniRead($CDataINI, $Atak, "Land", "0"))
					_GUICtrlListView_SetItemText($AttacksList, $Index, $i, 6)
					IniWrite($CDataINI, $Atak, "Land", $i)

					_GUICtrlListView_RegisterSortCallBack($AttacksList)
					_GUICtrlListView_SortItems($AttacksList, 5)
					_GUICtrlListView_UnRegisterSortCallBack($AttacksList)
				EndIf
			EndIf
			If $Attacks >= 3 Then
				$Atak = $AttackID3
				$Index = 0
				While True
					If _GUICtrlListView_GetItemText($AttacksList, $Index, 4) = "W£•CZONY" Then ExitLoop
					$Index += 1
				WEnd
				If IniRead($CDataINI, $Atak, "Interwal", "00:00:00") = "00:00:00" Then
					_GUICtrlListView_DeleteItem($AttacksList, $Index)
					IniDelete($CDataINI, $Atak)
					_GUICtrlListView_RegisterSortCallBack($AttacksList)
					_GUICtrlListView_SortItems($AttacksList, 5)
					_GUICtrlListView_UnRegisterSortCallBack($AttacksList)
					;			MsgBox(0, 3, 3)
				Else
					$Inte = StringSplit(IniRead($CDataINI, $Atak, "Interwal", "00:00:00"), ":")
					$TimeAdd = $Inte[1] * 3600 + $Inte[2] * 60 + $Inte[3]
					$i = _DateAdd("s", $TimeAdd, IniRead($CDataINI, $Atak, "Launch", "0"))
					_GUICtrlListView_SetItemText($AttacksList, $Index, $i, 5)
					IniWrite($CDataINI, $Atak, "Launch", $i)

					$i = _DateAdd("s", $TimeAdd, IniRead($CDataINI, $Atak, "Land", "0"))
					_GUICtrlListView_SetItemText($AttacksList, $Index, $i, 6)
					IniWrite($CDataINI, $Atak, "Land", $i)

					_GUICtrlListView_RegisterSortCallBack($AttacksList)
					_GUICtrlListView_SortItems($AttacksList, 5)
					_GUICtrlListView_UnRegisterSortCallBack($AttacksList)
				EndIf
			EndIf
			If $Attacks >= 4 Then
				$Atak = $AttackID4
				$Index = 0
				While True
					If _GUICtrlListView_GetItemText($AttacksList, $Index, 4) = "W£•CZONY" Then ExitLoop
					$Index += 1
				WEnd
				If IniRead($CDataINI, $Atak, "Interwal", "00:00:00") = "00:00:00" Then
					_GUICtrlListView_DeleteItem($AttacksList, $Index)
					IniDelete($CDataINI, $Atak)
					_GUICtrlListView_RegisterSortCallBack($AttacksList)
					_GUICtrlListView_SortItems($AttacksList, 5)
					_GUICtrlListView_UnRegisterSortCallBack($AttacksList)
					;			MsgBox(0, 4, 4)
				Else
					$Inte = StringSplit(IniRead($CDataINI, $Atak, "Interwal", "00:00:00"), ":")
					$TimeAdd = $Inte[1] * 3600 + $Inte[2] * 60 + $Inte[3]
					$i = _DateAdd("s", $TimeAdd, IniRead($CDataINI, $Atak, "Launch", "0"))
					_GUICtrlListView_SetItemText($AttacksList, $Index, $i, 5)
					IniWrite($CDataINI, $Atak, "Launch", $i)

					$i = _DateAdd("s", $TimeAdd, IniRead($CDataINI, $Atak, "Land", "0"))
					_GUICtrlListView_SetItemText($AttacksList, $Index, $i, 6)
					IniWrite($CDataINI, $Atak, "Land", $i)

					_GUICtrlListView_RegisterSortCallBack($AttacksList)
					_GUICtrlListView_SortItems($AttacksList, 5)
					_GUICtrlListView_UnRegisterSortCallBack($AttacksList)
				EndIf
			EndIf
			If $Attacks >= 5 Then
				$Atak = $AttackID5
				$Index = 0
				While True
					If _GUICtrlListView_GetItemText($AttacksList, $Index, 4) = "W£•CZONY" Then ExitLoop
					$Index += 1
				WEnd
				If IniRead($CDataINI, $Atak, "Interwal", "00:00:00") = "00:00:00" Then
					_GUICtrlListView_DeleteItem($AttacksList, $Index)
					IniDelete($CDataINI, $Atak)
					_GUICtrlListView_RegisterSortCallBack($AttacksList)
					_GUICtrlListView_SortItems($AttacksList, 5)
					_GUICtrlListView_UnRegisterSortCallBack($AttacksList)
					;			MsgBox(0, 5, 5)
				Else
					$Inte = StringSplit(IniRead($CDataINI, $Atak, "Interwal", "00:00:00"), ":")
					$TimeAdd = $Inte[1] * 3600 + $Inte[2] * 60 + $Inte[3]
					$i = _DateAdd("s", $TimeAdd, IniRead($CDataINI, $Atak, "Launch", "0"))
					_GUICtrlListView_SetItemText($AttacksList, $Index, $i, 5)
					IniWrite($CDataINI, $Atak, "Launch", $i)

					$i = _DateAdd("s", $TimeAdd, IniRead($CDataINI, $Atak, "Land", "0"))
					_GUICtrlListView_SetItemText($AttacksList, $Index, $i, 6)
					IniWrite($CDataINI, $Atak, "Land", $i)

					_GUICtrlListView_RegisterSortCallBack($AttacksList)
					_GUICtrlListView_SortItems($AttacksList, 5)
					_GUICtrlListView_UnRegisterSortCallBack($AttacksList)
				EndIf
			EndIf
			GUICtrlSetState($IE, $GUI_ENABLE)
			$Set = 0
			AttacksON()
		EndIf
		$Read = False
	EndIf
	Local $Set
	If $Set = 0 And $Work = 1 And $AttacksON > 0 Then
		$Index = 0
		$Attacks = 0
		$IDattack = ""
		$AttackID2 = ""
		$AttackID3 = ""
		$AttackID4 = ""
		$AttackID5 = ""
		While True
			If _GUICtrlListView_GetItemText($AttacksList, $Index, 4) = "W£•CZONY" Then
				$Attacks += 1
				$Index1 = $Index
				While True
					If _GUICtrlListView_GetItemText($AttacksList, $Index1, 5) = _GUICtrlListView_GetItemText($AttacksList, $Index1 + 1, 5) And _GUICtrlListView_GetItemText($AttacksList, $Index1 + 1, 4) = "W£•CZONY" Then
						$Attacks += 1
						If $Attacks = 2 Then
							$AttackID2 = _GUICtrlListView_GetItemText($AttacksList, $Index1 + 1, 0)
							$Index2 = $Index1
						EndIf
						If $Attacks = 3 Then
							$AttackID3 = _GUICtrlListView_GetItemText($AttacksList, $Index1 + 1, 0)
							$Index3 = $Index1
						EndIf
						If $Attacks = 4 Then
							$AttackID4 = _GUICtrlListView_GetItemText($AttacksList, $Index1 + 1, 0)
							$Index4 = $Index1
						EndIf
						If $Attacks = 5 Then
							$AttackID5 = _GUICtrlListView_GetItemText($AttacksList, $Index1 + 1, 0)
							$Index5 = $Index1
						EndIf
					EndIf
					If _GUICtrlListView_GetItemText($AttacksList, $Index1, 5) <> _GUICtrlListView_GetItemText($AttacksList, $Index1 + 1, 5) Then ExitLoop
					$Index1 += 1
				WEnd
				ExitLoop
			EndIf
			$Index += 1
		WEnd
		;		MsgBox(0, Null, "Index: "&$Index&@CRLF&"Ataki: "&$Attacks&@CRLF&"IDAttack2 = "&$AttackID2&@CRLF&"IDAttack3 = "&$AttackID3&@CRLF&"IDAttack4 = "&$AttackID4&@CRLF&"IDAttack5 = "&$AttackID5)
		$Set = 1
		$IDattack = _GUICtrlListView_GetItemText($AttacksList, $Index, 0)
	EndIf
	Local $lol1
	Local $lol2
	If $Work = 1 And $lol1 = 0 Then $lol1 = 2
	If $Work = 1 And $AttacksON > 0 Then
		$lol2 = _DateDiff("s", IniRead($CDataINI, $IDattack, "Launch", "0"), $Date & " " & $Time)
	EndIf
	If $AttacksON > 0 And $Work = 1 And $lol1 = 1 And $Set = 1 And $Launch = 0 Then
		If _DateDiff("s", IniRead($CDataINI, $IDattack, "Launch", "0"), $Date & " " & $Time) < 0 Then
			If _DateDiff("s", IniRead($CDataINI, $IDattack, "Launch", "0"), $Date & " " & $Time) = -$OdswiezPrzedAtakiem Then
				_IEAction($oIE, "Refresh")
				Sleep(500)
				If _IEPropertyGet($oIE, "locationurl") = "http://www." & GUICtrlRead($Country) & "/sid_wrong.php" Then Login()
			EndIf
			If _DateDiff("s", IniRead($CDataINI, $IDattack, "Launch", "0"), $Date & " " & $Time) >= -$PrzygotujAtak Then
				$Launch = 1
				AdlibRegister("Attack", 1000)
			EndIf
		EndIf
	EndIf
	$lol1 = 1
	If GUICtrlRead($GUI_CheckBox_ReLogin) <> 1 And (_IEPropertyGet($oIE, "locationurl") = "http://www." & GUICtrlRead($Country) & "/sid_wrong.php" Or _IEPropertyGet($oIE0, "locationurl") = "http://www." & GUICtrlRead($Country) & "/sid_wrong.php") Then
		GUISetState(@SW_DISABLE, $MainGUI)
		GUISetState(@SW_SHOW, $SessGUI)
		GUISetState(@SW_HIDE, $NavGUI)
		$Work = 0
		$Sync = 0
	EndIf
	If $URL <> $URL1 And $URL <> "http://www." & GUICtrlRead($Country) & "/sid_wrong.php" And $URL <> "http://www." & GUICtrlRead($Country) And $Work = 1 Then
		$URL1 = $URL
		If StringInStr(_IEPropertyGet($oIE0, "locationurl"), "screen=info_village") Then
			GUICtrlSetStyle($NAVIGATE_Button_Copy, "")
			GUICtrlSetStyle($NAVIGATE_Button_Add, "")
		Else
			GUICtrlSetStyle($NAVIGATE_Button_Copy, $WS_DISABLED)
			GUICtrlSetStyle($NAVIGATE_Button_Add, $WS_DISABLED)
		EndIf
	EndIf
	Local $AttTimer, $AttTimer1, $AttTimer2
	$AttTimer1 = _DateDiff("s", IniRead($CDataINI, $IDattack, "Launch", "0"), $Date & " " & $Time)
	If $AttacksON > 0 And $Work = 1 And $Set = 1 And $AttTimer1 <> $AttTimer And $Launch = 0 Then
		$Stop = -1
		$AttTimer = $AttTimer1
		If $AttTimer < 0 Then $AttTimer2 = $AttTimer * -1
		$AttTimerH = $AttTimer2 / 3600
		$AttTimerH = Floor($AttTimerH)
		$AttTimer2 = $AttTimer2 - ($AttTimerH * 3600)
		$AttTimerM = $AttTimer2 / 60
		$AttTimerM = Floor($AttTimerM)
		$AttTimer2 = $AttTimer2 - ($AttTimerM * 60)
		If $AttTimerM < 10 Then $AttTimerM = "0" & $AttTimerM
		$AttTimerS = $AttTimer2
		$AttTimer2 = $AttTimerS
		If $AttTimerS < 10 Then $AttTimerS = "0" & $AttTimerS
		GUICtrlSetData($NAttack, $AttTimerH & ":" & $AttTimerM & ":" & $AttTimerS)
	ElseIf $AttacksON = 0 And $Stop = 0 And $Launch = 0 Then
		$Stop = -1
		GUICtrlSetData($NAttack, "--:--:--")
	EndIf
	;--------------------------- Zmiana X|Y|ID w atakach
	$Vill = GUICtrlRead($Villages)
	If GUICtrlRead($Villages) <> "Wszystkie wioski (0)" And GUICtrlRead($Villages) <> "Wszystkie wioski (" & $Village[0][0] & ")" And $Vill <> $Vill1 Then
		$Vill1 = $Vill
		$wioska = StringSplit(GUICtrlRead($Villages), ".")
		GUICtrlSetData($Xa, $Village[1][$wioska[1]])
		GUICtrlSetData($Ya, $Village[2][$wioska[1]])
		GUICtrlSetData($IDa, $Village[3][$wioska[1]])
	EndIf
	If GUICtrlRead($Villages) = "Wszystkie wioski (0)" Or GUICtrlRead($Villages) = "Wszystkie wioski (" & $Village[0][0] & ")" Then
		If GUICtrlRead($Xa) <> "X" And GUICtrlRead($Ya) <> "Y" Then
			$Vill1 = ""
			GUICtrlSetData($Xa, "X")
			GUICtrlSetData($Ya, "Y")
			GUICtrlSetData($IDa, "ID")
		EndIf
	EndIf
	;---------------------------- Zmiana X|Y|ID w nawigacji
	$Vill2 = GUICtrlRead($nVillages)
	If GUICtrlRead($nVillages) <> "Wszystkie wioski (0)" And GUICtrlRead($nVillages) <> "Wszystkie wioski (" & $Village[0][0] & ")" And $Vill2 <> $Vill3 Then
		$Vill3 = $Vill2
		$wioska1 = StringSplit(GUICtrlRead($nVillages), ".")
		GUICtrlSetData($Xn, $Village[1][$wioska1[1]])
		GUICtrlSetData($Yn, $Village[2][$wioska1[1]])
		GUICtrlSetData($IDn, $Village[3][$wioska1[1]])
	EndIf
	If GUICtrlRead($nVillages) = "Wszystkie wioski (0)" Or GUICtrlRead($nVillages) = "Wszystkie wioski (" & $Village[0][0] & ")" Then
		If GUICtrlRead($Xn) <> "X" And GUICtrlRead($Yn) <> "Y" Then
			$Vill3 = ""
			GUICtrlSetData($Xn, "X")
			GUICtrlSetData($Yn, "Y")
			GUICtrlSetData($IDn, "ID")
		EndIf
	EndIf

	If $Work = 1 And $URL <> "http://www." & GUICtrlRead($Country) & "/sid_wrong.php" And $URL <> "http://www." & GUICtrlRead($Country) Then
		If $Village[0][0] > 1 Then
			$z = 0
			$L1 = StringSplit(_IEPropertyGet($oIE0, "locationurl"), "=")
			$L2 = StringSplit($L1[2], "&")
			If $L2[1] <> $L3 Then
				$L3 = $L2[1]

				If StringLeft($L2[1], 1) == "p" And $z = 0 Then
					;		MsgBox(0, "", "P!")
					$z += 1
					$L2[1] = StringReplace($L2[1], "p", "")
					$L2[1] = StringReplace($L2[1], "p", "")
					$cVill = _ArraySearch($Village, $L2[1], 0, 0, 0, 0, 1, 3, True)
					If $cVill > 0 Then
						If $cVill = 2 Then
							GUICtrlSetData($PrevVillage, $Village[0][$Village[0][0]] & "(" & $Village[1][$Village[0][0]] & "I" & $Village[2][$Village[0][0]] & ")")
						EndIf
						If $cVill = 1 Then
							GUICtrlSetData($PrevVillage, $Village[0][$Village[0][0] - 1] & "(" & $Village[1][$Village[0][0] - 1] & "I" & $Village[2][$Village[0][0] - 1] & ")")
						ElseIf $cVill <> 1 And $cVill <> 2 Then
							GUICtrlSetData($PrevVillage, $Village[0][$cVill - 2] & "(" & $Village[1][$cVill - 2] & "I" & $Village[2][$cVill - 2] & ")")
						EndIf
						If $cVill = 1 Then
							GUICtrlSetData($NextVillage, $Village[0][1] & "(" & $Village[1][1] & "I" & $Village[2][1] & ")")
						ElseIf $cVill <> 1 Then
							GUICtrlSetData($NextVillage, $Village[0][$cVill] & "(" & $Village[1][$cVill] & "I" & $Village[2][$cVill] & ")")
						EndIf
						;	MsgBox(0, "", $cVill)
					EndIf
				EndIf

				If StringLeft($L2[1], 1) == "n" And $z = 0 Then
					;		MsgBox(0, "", "N!")
					$z += 1
					$L2[1] = StringReplace($L2[1], "n", "")
					$cVill = _ArraySearch($Village, $L2[1], 0, 0, 0, 0, 1, 3, True)
					If $cVill > 0 Then
						If $cVill = $Village[0][0] Then
							GUICtrlSetData($PrevVillage, $Village[0][$Village[0][0]] & "(" & $Village[1][$Village[0][0]] & "I" & $Village[2][$Village[0][0]] & ")")
						ElseIf $cVill <> $Village[0][0] Then
							GUICtrlSetData($PrevVillage, $Village[0][$cVill] & "(" & $Village[1][$cVill] & "I" & $Village[2][$cVill] & ")")
						EndIf
						If $cVill = $Village[0][0] - 1 Then
							GUICtrlSetData($NextVillage, $Village[0][1] & "(" & $Village[1][1] & "I" & $Village[2][1] & ")")
						ElseIf $cVill = $Village[0][0] Then
							GUICtrlSetData($NextVillage, $Village[0][2] & "(" & $Village[1][2] & "I" & $Village[2][2] & ")")
						ElseIf $cVill <> $Village[0][0] - 1 And $cVill <> $Village[0][0] Then
							GUICtrlSetData($NextVillage, $Village[0][$cVill + 2] & "(" & $Village[1][$cVill + 2] & "I" & $Village[2][$cVill + 2] & ")")
						EndIf
						;	MsgBox(0, "", $cVill)
					EndIf
				EndIf

				If StringLeft($L2[1], 1) <> "n" And StringLeft($L2[1], 1) <> "p" And $z = 0 Then
					;		MsgBox(0, "", "Normalnie")
					$z += 1
					$cVill = _ArraySearch($Village, $L2[1], 0, 0, 0, 0, 1, 3, True)
					If $cVill > 0 Then
						If $cVill = 1 Then
							GUICtrlSetData($PrevVillage, $Village[0][$Village[0][0]] & "(" & $Village[1][$Village[0][0]] & "I" & $Village[2][$Village[0][0]] & ")")
						ElseIf $cVill <> 1 Then
							GUICtrlSetData($PrevVillage, $Village[0][$cVill - 1] & "(" & $Village[1][$cVill - 1] & "I" & $Village[2][$cVill - 1] & ")")
						EndIf
						If $cVill = $Village[0][0] Then
							GUICtrlSetData($NextVillage, $Village[0][1] & "(" & $Village[1][1] & "I" & $Village[2][1] & ")")
						ElseIf $cVill <> $Village[0][0] Then
							GUICtrlSetData($NextVillage, $Village[0][$cVill + 1] & "(" & $Village[1][$cVill + 1] & "I" & $Village[2][$cVill + 1] & ")")
						EndIf
						;	MsgBox(0, "", $cVill)
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!----------------------------- Obs≥uga GUI --------------------------------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!----------------------------- Obs≥uga GUI --------------------------------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!----------------------------- Obs≥uga GUI --------------------------------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!----------------------------- Obs≥uga GUI --------------------------------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!----------------------------- Obs≥uga GUI --------------------------------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	Local $msg = GUIGetMsg()
	Select
		Case $msg = $GUI_EVENT_CLOSE
			$y = MsgBox(4, "Potwierdzenie", "Jesteú pewien, øe chcesz wy≥πczyÊ TW Master bota?")
			If $y = 6 Then ExitLoop
		Case $msg = $GUI_EVENT_MINIMIZE
			If _IsChecked($Options_CheckBox_TrayHide) Then
				GUISetState(@SW_HIDE, $MainGUI)
				TraySetState(1)
				$InTray = 1
			EndIf
		Case $msg = $GUI_EVENT_MAXIMIZE
			GUISetState(@SW_HIDE, $MainGUI)
			GUISetState(@SW_SHOW, $MainGUI)
		Case $msg = $GUI_Button_Apply ;Czynnoúci do wykonania dla przycisku ZATWIRDè
			_IENavigate($oIE, "http://www." & GUICtrlRead($Country))
			LogWrite("Zmieniono serwer na: http://www." & GUICtrlRead($Country))
		Case $msg = $GUI_Button_Navigate ;Czynnoúci do wykonania dla przycisku NAWIGACJA
			GUISetState(@SW_SHOW, $NavGUI)
			;         GuiCtrlSetData($MainLOG, $LogTime&"Zsynchronizowano czas serwerowy..."&@CRLF, 1)
			;		FileWrite($LOG,$LogTime&"Zsynchronizowano czas serwerowy..."&@CRLF)
		Case $msg = $GUI_Button_Add ;Czynnoúci do wykonania dla przycisku DODAJ
			If GUICtrlRead($Password) = "" Then
				$PS = "NIE"
			ElseIf GUICtrlRead($Password) <> "" Then
				$PS = "TAK"
			EndIf
			If GUICtrlRead($Login) <> "" Then
				If GUICtrlRead($Accounts) > 0 Then
					Local $b = GUICtrlRead(GUICtrlRead($Accounts)) - 1
					$AccData[$b + 1][0] = GUICtrlRead($Login)
					$AccData[$b + 1][1] = $PS
					$AccPass[$b + 1][1] = GUICtrlRead($Password)
					GUICtrlSetData(Eval("Acc" & $b), ($b + 1) & "|" & $AccData[$b + 1][0] & "|" & $AccData[$b + 1][1])
					LogWrite("Zapisano dane konta: " & GUICtrlRead($Login) & " na slocie " & $b + 1 & ". Has≥o: " & $PS)
					IniWriteSection($INIa, "ACCOUNTS", $AccData)
					IniWriteSection($INIa, "PASSWORDS", $AccPass)
				ElseIf GUICtrlRead($Accounts) = 0 Then
					MsgBox(0, "Wybierz slot!", "Wybierz slot na ktÛry chcesz zapisaÊ dane konta!", 2)
				EndIf
			ElseIf GUICtrlRead($Login) = "" Then
				MsgBox(0, "Nie podano nazwy konta!", "Nie podano nazwy konta." & @CRLF & "Jeúli chcesz dodaÊ konto do listy, musisz podaÊ jego nazwÍ!", 3)
			EndIf
		Case $msg = $GUI_Button_Use ;Czynnoúci do wykonania dla przycisku UØYJ
			If GUICtrlRead($Accounts) > 0 Then
				Local $b = GUICtrlRead(GUICtrlRead($Accounts)) - 1
				If $AccData[$b + 1][0] <> "----------" Then
					GUICtrlSetData($Login, $AccData[$b + 1][0])
					GUICtrlSetData($Password, $AccPass[$b + 1][1])
					LogWrite("Zaimportowano dane konta: " & $AccData[$b + 1][0] & " ze slotu " & $b + 1)
				Else
					GUICtrlSetData($Login, "")
					GUICtrlSetData($Password, "")
					LogWrite("Niezaimportowano danych øadnego konta, slot " & $b + 1 & " jest pusty.")
				EndIf
			ElseIf GUICtrlRead($Accounts) = 0 Then
				MsgBox(0, "Wybierz slot!", "Wybierz slot z ktÛrego chcesz zaimportowaÊ dane konta!", 3)
			EndIf
		Case $msg = $GUI_Button_Delete ;Czynnoúci do wykonania dla przycisku USU—
			If GUICtrlRead($Accounts) > 0 Then
				Local $b = GUICtrlRead(GUICtrlRead($Accounts)) - 1
				$AccData[$b + 1][0] = "----------"
				$AccData[$b + 1][1] = "---"
				$AccPass[$b + 1][1] = ""
				GUICtrlSetData(Eval("Acc" & $b), ($b + 1) & "|----------|---")
				IniWriteSection($INIa, "ACCOUNTS", $AccData)
				IniWriteSection($INIa, "PASSWORDS", $AccPass)
				LogWrite("UsuniÍto dane konta na slocie " & $b + 1)
			ElseIf GUICtrlRead($Accounts) = 0 Then
				MsgBox(0, "Wybierz slot!", "Wybierz slot z ktÛrego chcesz usunπÊ dane konta!", 2)
			EndIf
			;--------------------------------------------- START ----------------------------------
		Case $msg = $GUI_Button_Start Or $msg = $Session_Button_Relogin
			Start()
			;--------------------------------------------- START ----------------------------------

			; -------------------------------------- STOP ---------------------------------------------
		Case $msg = $GUI_Button_Stop Or $msg = $Session_Button_Stop
			Stop()
			; -------------------------------------- STOP ---------------------------------------------
		Case $msg = $GUI_Button_Hide
			$Hide = 145
			$Hide1 = 123
			Hide()
		Case $msg = $GUI_Button_Show
			$Hide = 0
			$Hide1 = 0
			Hide()
		Case $msg = $GUI_Button_Update
			Up()
			;		Case $msg = $GUI_Button_Villages
			;			Villages_list()
		Case $msg = $NAVIGATE_Button_Zmien
			Zmiana()
		Case $msg = $NAVIGATE_Button_Close
			GUISetState(@SW_HIDE, $NavGUI)
		Case $msg = $NAVIGATE_Button_Prev
			PrevVill()
		Case $msg = $NAVIGATE_Button_Next
			NextVill()
		Case $msg = $NAVIGATE_Button_Copy
			CopyXY()
		Case $msg = $Attacks_Button_Paste
			GUICtrlSetData($Xb, $CopyX)
			GUICtrlSetData($Yb, $CopyY)
		Case $msg = $Attacks_Button_Zero
			GUICtrlSetData($Interwal, "2009/10/03 00:00:00")
		Case $msg = $Attacks_Button_Speed
			GUISetState(@SW_SHOW, $AttspGUI)
			GUICtrlSetData($PikSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Pikinier", "00:18:00"))
			GUICtrlSetData($MieSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Miecznik", "00:22:00"))
			GUICtrlSetData($TopSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Topornik", "00:18:00"))
			GUICtrlSetData($LukSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Lucznik", "00:18:00"))
			GUICtrlSetData($ZwiSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Zwiad", "00:09:00"))
			GUICtrlSetData($LKSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "LK", "00:10:00"))
			GUICtrlSetData($LnKSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "LnK", "00:10:00"))
			GUICtrlSetData($CKSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "CK", "00:11:00"))
			GUICtrlSetData($TarSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Taran", "00:30:00"))
			GUICtrlSetData($KatSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Katapulta", "00:30:00"))
			GUICtrlSetData($RycSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Rycerz", "00:10:00"))
			GUICtrlSetData($SzlSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Szlachcic", "00:35:00"))
		Case $msg = $Attsp_Button_Close
			GUISetState(@SW_HIDE, $AttspGUI)
			GUICtrlSetData($PikSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Pikinier", "00:18:00"))
			GUICtrlSetData($MieSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Miecznik", "00:22:00"))
			GUICtrlSetData($TopSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Topornik", "00:18:00"))
			GUICtrlSetData($LukSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Lucznik", "00:18:00"))
			GUICtrlSetData($ZwiSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Zwiad", "00:09:00"))
			GUICtrlSetData($LKSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "LK", "00:10:00"))
			GUICtrlSetData($LnKSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "LnK", "00:10:00"))
			GUICtrlSetData($CKSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "CK", "00:11:00"))
			GUICtrlSetData($TarSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Taran", "00:30:00"))
			GUICtrlSetData($KatSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Katapulta", "00:30:00"))
			GUICtrlSetData($RycSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Rycerz", "00:10:00"))
			GUICtrlSetData($SzlSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Szlachcic", "00:35:00"))
		Case $msg = $Attsp_Button_Save
			IniWrite($CDataINI, "UNITS", "Pikinier", GUICtrlRead($PikSpd))
			IniWrite($CDataINI, "UNITS", "Miecznik", GUICtrlRead($MieSpd))
			IniWrite($CDataINI, "UNITS", "Topornik", GUICtrlRead($TopSpd))
			IniWrite($CDataINI, "UNITS", "Lucznik", GUICtrlRead($LukSpd))
			IniWrite($CDataINI, "UNITS", "Zwiad", GUICtrlRead($ZwiSpd))
			IniWrite($CDataINI, "UNITS", "LK", GUICtrlRead($LKSpd))
			IniWrite($CDataINI, "UNITS", "LnK", GUICtrlRead($LnKSpd))
			IniWrite($CDataINI, "UNITS", "CK", GUICtrlRead($CKSpd))
			IniWrite($CDataINI, "UNITS", "Taran", GUICtrlRead($TarSpd))
			IniWrite($CDataINI, "UNITS", "Katapulta", GUICtrlRead($KatSpd))
			IniWrite($CDataINI, "UNITS", "Rycerz", GUICtrlRead($RycSpd))
			IniWrite($CDataINI, "UNITS", "Szlachcic", GUICtrlRead($SzlSpd))
			LogWrite("Zapisano nowe prÍdkoúci jednostek dla konta " & GUICtrlRead($Login) & " (" & GUICtrlRead($Worlds) & ")")
		Case $msg = $Attsp_Button_Standard
			GUICtrlSetData($PikSpd, "2000/01/01 00:18:00")
			GUICtrlSetData($MieSpd, "2000/01/01 00:22:00")
			GUICtrlSetData($TopSpd, "2000/01/01 00:18:00")
			GUICtrlSetData($LukSpd, "2000/01/01 00:18:00")
			GUICtrlSetData($ZwiSpd, "2000/01/01 00:09:00")
			GUICtrlSetData($LKSpd, "2000/01/01 00:10:00")
			GUICtrlSetData($LnKSpd, "2000/01/01 00:10:00")
			GUICtrlSetData($CKSpd, "2000/01/01 00:11:00")
			GUICtrlSetData($TarSpd, "2000/01/01 00:30:00")
			GUICtrlSetData($KatSpd, "2000/01/01 00:30:00")
			GUICtrlSetData($RycSpd, "2000/01/01 00:10:00")
			GUICtrlSetData($SzlSpd, "2000/01/01 00:35:00")
			IniWrite($CDataINI, "UNITS", "Pikinier", GUICtrlRead($PikSpd))
			IniWrite($CDataINI, "UNITS", "Miecznik", GUICtrlRead($MieSpd))
			IniWrite($CDataINI, "UNITS", "Topornik", GUICtrlRead($TopSpd))
			IniWrite($CDataINI, "UNITS", "Lucznik", GUICtrlRead($LukSpd))
			IniWrite($CDataINI, "UNITS", "Zwiad", GUICtrlRead($ZwiSpd))
			IniWrite($CDataINI, "UNITS", "LK", GUICtrlRead($LKSpd))
			IniWrite($CDataINI, "UNITS", "LnK", GUICtrlRead($LnKSpd))
			IniWrite($CDataINI, "UNITS", "CK", GUICtrlRead($CKSpd))
			IniWrite($CDataINI, "UNITS", "Taran", GUICtrlRead($TarSpd))
			IniWrite($CDataINI, "UNITS", "Katapulta", GUICtrlRead($KatSpd))
			IniWrite($CDataINI, "UNITS", "Rycerz", GUICtrlRead($RycSpd))
			IniWrite($CDataINI, "UNITS", "Szlachcic", GUICtrlRead($SzlSpd))
			LogWrite("PrzywrÛcono domyúlne prÍdkoúci jednostek dla konta " & GUICtrlRead($Login) & " (" & GUICtrlRead($Worlds) & ")")
		Case $msg = $Attacks_Button_AllPik
			If GUICtrlRead($AttPiki) <> "MAX" Then
				GUICtrlSetState($AttPiki, $GUI_DISABLE)
				GUICtrlSetData($AttPiki, "MAX")
				GUICtrlSetData($Attacks_Button_AllPik, "0")
			ElseIf GUICtrlRead($AttPiki) == "MAX" Then
				GUICtrlSetState($AttPiki, $GUI_ENABLE)
				GUICtrlSetData($AttPiki, "")
				GUICtrlSetData($Attacks_Button_AllPik, "MAX")
			EndIf
		Case $msg = $Attacks_Button_AllMie
			If GUICtrlRead($AttMiecze) <> "MAX" Then
				GUICtrlSetState($AttMiecze, $GUI_DISABLE)
				GUICtrlSetData($AttMiecze, "MAX")
				GUICtrlSetData($Attacks_Button_AllMie, "0")
			ElseIf GUICtrlRead($AttMiecze) == "MAX" Then
				GUICtrlSetState($AttMiecze, $GUI_ENABLE)
				GUICtrlSetData($AttMiecze, "")
				GUICtrlSetData($Attacks_Button_AllMie, "MAX")
			EndIf
		Case $msg = $Attacks_Button_AllTop
			If GUICtrlRead($AttTopory) <> "MAX" Then
				GUICtrlSetState($AttTopory, $GUI_DISABLE)
				GUICtrlSetData($AttTopory, "MAX")
				GUICtrlSetData($Attacks_Button_AllTop, "0")
			ElseIf GUICtrlRead($AttTopory) == "MAX" Then
				GUICtrlSetState($AttTopory, $GUI_ENABLE)
				GUICtrlSetData($AttTopory, "")
				GUICtrlSetData($Attacks_Button_AllTop, "MAX")
			EndIf
		Case $msg = $Attacks_Button_AllLuk
			If GUICtrlRead($AttLuki) <> "MAX" Then
				GUICtrlSetState($AttLuki, $GUI_DISABLE)
				GUICtrlSetData($AttLuki, "MAX")
				GUICtrlSetData($Attacks_Button_AllLuk, "0")
			ElseIf GUICtrlRead($AttLuki) == "MAX" Then
				GUICtrlSetState($AttLuki, $GUI_ENABLE)
				GUICtrlSetData($AttLuki, "")
				GUICtrlSetData($Attacks_Button_AllLuk, "MAX")
			EndIf
		Case $msg = $Attacks_Button_AllZwi
			If GUICtrlRead($AttZwiad) <> "MAX" Then
				GUICtrlSetState($AttZwiad, $GUI_DISABLE)
				GUICtrlSetData($AttZwiad, "MAX")
				GUICtrlSetData($Attacks_Button_AllZwi, "0")
			ElseIf GUICtrlRead($AttZwiad) == "MAX" Then
				GUICtrlSetState($AttZwiad, $GUI_ENABLE)
				GUICtrlSetData($AttZwiad, "")
				GUICtrlSetData($Attacks_Button_AllZwi, "MAX")
			EndIf
		Case $msg = $Attacks_Button_AllLK
			If GUICtrlRead($AttLK) <> "MAX" Then
				GUICtrlSetState($AttLK, $GUI_DISABLE)
				GUICtrlSetData($AttLK, "MAX")
				GUICtrlSetData($Attacks_Button_AllLK, "0")
			ElseIf GUICtrlRead($AttLK) == "MAX" Then
				GUICtrlSetState($AttLK, $GUI_ENABLE)
				GUICtrlSetData($AttLK, "")
				GUICtrlSetData($Attacks_Button_AllLK, "MAX")
			EndIf
		Case $msg = $Attacks_Button_AllLnK
			If GUICtrlRead($AttKLucz) <> "MAX" Then
				GUICtrlSetState($AttKLucz, $GUI_DISABLE)
				GUICtrlSetData($AttKLucz, "MAX")
				GUICtrlSetData($Attacks_Button_AllLnK, "0")
			ElseIf GUICtrlRead($AttKLucz) == "MAX" Then
				GUICtrlSetState($AttKLucz, $GUI_ENABLE)
				GUICtrlSetData($AttKLucz, "")
				GUICtrlSetData($Attacks_Button_AllLnK, "MAX")
			EndIf
		Case $msg = $Attacks_Button_AllCK
			If GUICtrlRead($AttCK) <> "MAX" Then
				GUICtrlSetState($AttCK, $GUI_DISABLE)
				GUICtrlSetData($AttCK, "MAX")
				GUICtrlSetData($Attacks_Button_AllCK, "0")
			ElseIf GUICtrlRead($AttCK) == "MAX" Then
				GUICtrlSetState($AttCK, $GUI_ENABLE)
				GUICtrlSetData($AttCK, "")
				GUICtrlSetData($Attacks_Button_AllCK, "MAX")
			EndIf
		Case $msg = $Attacks_Button_AllTar
			If GUICtrlRead($AttTar) <> "MAX" Then
				GUICtrlSetState($AttTar, $GUI_DISABLE)
				GUICtrlSetData($AttTar, "MAX")
				GUICtrlSetData($Attacks_Button_AllTar, "0")
			ElseIf GUICtrlRead($AttTar) == "MAX" Then
				GUICtrlSetState($AttTar, $GUI_ENABLE)
				GUICtrlSetData($AttTar, "")
				GUICtrlSetData($Attacks_Button_AllTar, "MAX")
			EndIf
		Case $msg = $Attacks_Button_AllKat
			If GUICtrlRead($AttKat) <> "MAX" Then
				GUICtrlSetState($AttKat, $GUI_DISABLE)
				GUICtrlSetData($AttKat, "MAX")
				GUICtrlSetData($Attacks_Button_AllKat, "0")
			ElseIf GUICtrlRead($AttKat) == "MAX" Then
				GUICtrlSetState($AttKat, $GUI_ENABLE)
				GUICtrlSetData($AttKat, "")
				GUICtrlSetData($Attacks_Button_AllKat, "MAX")
			EndIf
		Case $msg = $Attacks_Button_AllRyc
			If GUICtrlRead($AttRyc) <> "MAX" Then
				GUICtrlSetState($AttRyc, $GUI_DISABLE)
				GUICtrlSetData($AttRyc, "MAX")
				GUICtrlSetData($Attacks_Button_AllRyc, "0")
			ElseIf GUICtrlRead($AttRyc) == "MAX" Then
				GUICtrlSetState($AttRyc, $GUI_ENABLE)
				GUICtrlSetData($AttRyc, "")
				GUICtrlSetData($Attacks_Button_AllRyc, "MAX")
			EndIf
		Case $msg = $Attacks_Button_AllSzl
			If GUICtrlRead($AttSzl) <> "MAX" Then
				GUICtrlSetState($AttSzl, $GUI_DISABLE)
				GUICtrlSetData($AttSzl, "MAX")
				GUICtrlSetData($Attacks_Button_AllSzl, "0")
			ElseIf GUICtrlRead($AttSzl) == "MAX" Then
				GUICtrlSetState($AttSzl, $GUI_ENABLE)
				GUICtrlSetData($AttSzl, "")
				GUICtrlSetData($Attacks_Button_AllSzl, "MAX")
			EndIf
		Case $msg = $Attacks_Button_Add
			Local $DateError
			$AttackError = 1
			If GUICtrlRead($AttackType) <> "<ROZKAZ>" Then
				If GUICtrlRead($Villages) <> "Wszystkie wioski (" & $Village[0][0] & ")" And GUICtrlRead($Xb) <> "" And GUICtrlRead($Yb) <> "" Then
					If GUICtrlRead($AttPiki) <> "" Or GUICtrlRead($AttMiecze) <> "" Or GUICtrlRead($AttTopory) <> "" Or GUICtrlRead($AttLuki) <> "" Or _
							GUICtrlRead($AttZwiad) <> "" Or GUICtrlRead($AttLK) <> "" Or GUICtrlRead($AttKLucz) <> "" Or GUICtrlRead($AttCK) <> "" Or GUICtrlRead($AttTar) <> "" Or _
							GUICtrlRead($AttKat) <> "" Or GUICtrlRead($AttRyc) <> "" Or GUICtrlRead($AttSzl) <> "" Then
						If (GUICtrlRead($AttPiki) = "MAX" Or GUICtrlRead($AttMiecze) = "MAX" Or GUICtrlRead($AttTopory) = "MAX" Or GUICtrlRead($AttLuki) = "MAX" Or _
								GUICtrlRead($AttZwiad) = "MAX" Or GUICtrlRead($AttLK) = "MAX" Or GUICtrlRead($AttKLucz) = "MAX" Or GUICtrlRead($AttCK) = "MAX" Or GUICtrlRead($AttTar) = "MAX" Or _
								GUICtrlRead($AttKat) = "MAX" Or GUICtrlRead($AttRyc) = "MAX" Or GUICtrlRead($AttSzl) = "MAX") And $Added = 0 Then
							AddAttack()
							AttacksON()
						EndIf
						If (GUICtrlRead($AttPiki) <> 0 Or GUICtrlRead($AttMiecze) <> 0 Or _
								GUICtrlRead($AttTopory) <> 0 Or GUICtrlRead($AttLuki) <> 0 Or GUICtrlRead($AttZwiad) <> 0 Or GUICtrlRead($AttLK) <> 0 Or GUICtrlRead($AttKLucz) <> 0 Or _
								GUICtrlRead($AttCK) <> 0 Or GUICtrlRead($AttTar) <> 0 Or GUICtrlRead($AttKat) <> 0 Or GUICtrlRead($AttRyc) <> 0 Or GUICtrlRead($AttSzl) <> 0) And $Added = 0 Then
							AddAttack()
							AttacksON()
						EndIf
					EndIf
				EndIf
			EndIf
			$Text = ""
			If $AttackError = 1 Then
				If GUICtrlRead($Villages) = "Wszystkie wioski (" & $Village[0][0] & ")" Then $Text = $Text & "- Nie wybrano wioski atakujπcej," & @CRLF
				If GUICtrlRead($Xb) = "" Or GUICtrlRead($Yb) = "" Then $Text = $Text & "- Nie podano wspÛ≥rzÍdnych celu," & @CRLF
				If ((GUICtrlRead($AttPiki) = "" Or GUICtrlRead($AttPiki) = 0) And GUICtrlRead($AttPiki) <> "MAX") And _
						((GUICtrlRead($AttMiecze) = "" Or GUICtrlRead($AttMiecze) = 0) And GUICtrlRead($AttMiecze) <> "MAX") And _
						((GUICtrlRead($AttTopory) = "" Or GUICtrlRead($AttTopory) = 0) And GUICtrlRead($AttTopory) <> "MAX") And _
						((GUICtrlRead($AttLuki) = "" Or GUICtrlRead($AttLuki) = 0) And GUICtrlRead($AttLuki) <> "MAX") And _
						((GUICtrlRead($AttZwiad) = "" Or GUICtrlRead($AttZwiad) = 0) And GUICtrlRead($AttZwiad) <> "MAX") And _
						((GUICtrlRead($AttLK) = "" Or GUICtrlRead($AttLK) = 0) And GUICtrlRead($AttLK) <> "MAX") And _
						((GUICtrlRead($AttKLucz) = "" Or GUICtrlRead($AttKLucz) = 0) And GUICtrlRead($AttKLucz) <> "MAX") And _
						((GUICtrlRead($AttCK) = "" Or GUICtrlRead($AttCK) = 0) And GUICtrlRead($AttCK) <> "MAX") And _
						((GUICtrlRead($AttTar) = "" Or GUICtrlRead($AttTar) = 0) And GUICtrlRead($AttTar) <> "MAX") And _
						((GUICtrlRead($AttKat) = "" Or GUICtrlRead($AttKat) = 0) And GUICtrlRead($AttKat) <> "MAX") And _
						((GUICtrlRead($AttRyc) = "" Or GUICtrlRead($AttRyc) = 0) And GUICtrlRead($AttRyc) <> "MAX") And _
						((GUICtrlRead($AttSzl) = "" Or GUICtrlRead($AttSzl) = 0) And GUICtrlRead($AttSzl) <> "MAX") Then $Text = $Text & "- Nie wybrano øadnych jednostek," & @CRLF
				If GUICtrlRead($AttackType) = "<ROZKAZ>" Then $Text = $Text & "- Nie wybrano rozkazu," & @CRLF
				MsgBox(16, "B≥πd dodawania ataku", "Wystπpi≥ b≥πd podczas dodawania ataku, poniewaø:" & @CRLF & @CRLF & $Text & @CRLF & "Podaj te dane!", 2)
			EndIf
			If $DateError = 1 Then
				$Opoznienie = _DateDiff('s', $CzasP, $Date & " " & $Time)
				$Opoznienie += 5
				;			msgbox(0, "", $CzasP)
				$Text = $Text & "Data wys≥ania ataku juø minÍ≥a!" & @CRLF & "SpÛüni≥eú siÍ o " & $Opoznienie & " sekund." & @CRLF
				MsgBox(16, "B≥πd dodawania ataku", "Wystπpi≥ b≥πd podczas dodawania ataku, poniewaø:" & @CRLF & @CRLF & $Text & @CRLF & "Podaj innπ datÍ!", 2)
			EndIf
			$Added = 0
		Case $msg = $NAVIGATE_Button_Villages
			Villages_list()
		Case $msg = $Attacks_Button_Optimal
			$Opt = 0
			If GUICtrlRead($Villages) <> "Wszystkie wioski (" & $Village[0][0] & ")" And GUICtrlRead($Xb) <> "" And GUICtrlRead($Yb) <> "" Then
				If GUICtrlRead($AttPiki) <> "" Or GUICtrlRead($AttMiecze) <> "" Or GUICtrlRead($AttTopory) <> "" Or GUICtrlRead($AttLuki) <> "" Or _
						GUICtrlRead($AttZwiad) <> "" Or GUICtrlRead($AttLK) <> "" Or GUICtrlRead($AttKLucz) <> "" Or GUICtrlRead($AttCK) <> "" Or GUICtrlRead($AttTar) <> "" Or _
						GUICtrlRead($AttKat) <> "" Or GUICtrlRead($AttRyc) <> "" Or GUICtrlRead($AttSzl) <> "" Then
					If GUICtrlRead($AttPiki) = "MAX" Or GUICtrlRead($AttMiecze) = "MAX" Or GUICtrlRead($AttTopory) = "MAX" Or GUICtrlRead($AttLuki) = "MAX" Or _
							GUICtrlRead($AttZwiad) = "MAX" Or GUICtrlRead($AttLK) = "MAX" Or GUICtrlRead($AttKLucz) = "MAX" Or GUICtrlRead($AttCK) = "MAX" Or GUICtrlRead($AttTar) = "MAX" Or _
							GUICtrlRead($AttKat) = "MAX" Or GUICtrlRead($AttRyc) = "MAX" Or GUICtrlRead($AttSzl) = "MAX" Then
						If $Opt = 0 Then OptimalInterwal()
					EndIf
					If GUICtrlRead($AttPiki) <> 0 Or GUICtrlRead($AttMiecze) <> 0 Or _
							GUICtrlRead($AttTopory) <> 0 Or GUICtrlRead($AttLuki) <> 0 Or GUICtrlRead($AttZwiad) <> 0 Or GUICtrlRead($AttLK) <> 0 Or GUICtrlRead($AttKLucz) <> 0 Or _
							GUICtrlRead($AttCK) <> 0 Or GUICtrlRead($AttTar) <> 0 Or GUICtrlRead($AttKat) <> 0 Or GUICtrlRead($AttRyc) <> 0 Or GUICtrlRead($AttSzl) <> 0 Then
						If $Opt = 0 Then OptimalInterwal()
					EndIf
				EndIf
			EndIf
		Case $msg = $Attacks_Button_Remove
			If GUICtrlRead($AttacksList) <> 0 Then
				$Lol = GUICtrlRead(GUICtrlRead($AttacksList))
				$AttRemove = StringSplit($Lol, "|")
				IniDelete($CDataINI, $AttRemove[1])
				_GUICtrlListView_DeleteItemsSelected($AttacksList)
				_GUICtrlListView_RegisterSortCallBack($AttacksList)
				_GUICtrlListView_SortItems($AttacksList, 5)
				_GUICtrlListView_UnRegisterSortCallBack($AttacksList)
				$Set = 0
				AttacksON()
				LogWrite("UsuniÍto atak na koncie " & GUICtrlRead($Login) & " (" & GUICtrlRead($Worlds) & ")")
			EndIf
		Case $msg = $Attacks_Button_Switch
			;			MsgBox(0, Null, _GUICtrlListView_GetSelectionMark ( $AttacksList ))
			If GUICtrlRead($AttacksList) <> 0 Then
				$arr = StringSplit(GUICtrlRead(GUICtrlRead($AttacksList)), "|")
				If _GUICtrlListView_GetItemText($AttacksList, _GUICtrlListView_GetSelectionMark($AttacksList), 4) == "W£•CZONY" Then
					IniWrite($CDataINI, $arr[1], "Active", "WY£•CZONY")
					LogWrite("Wy≥πczono atak na koncie " & GUICtrlRead($Login) & " (" & GUICtrlRead($Worlds) & ")")
				Else
					IniWrite($CDataINI, $arr[1], "Active", "W£•CZONY")
					LogWrite("W≥πczono atak na koncie " & GUICtrlRead($Login) & " (" & GUICtrlRead($Worlds) & ")")
				EndIf
				GUICtrlCreateListViewItem(IniRead($CDataINI, $arr[1], "Count", "0") & "|" & _		;0 Niewidoczna
						IniRead($CDataINI, $arr[1], "VillageID", "0") & "|" & _	;1 Niewidoczna
						IniRead($CDataINI, $arr[1], "Type", "0") & "|" & _			;2
						IniRead($CDataINI, $arr[1], "Interwal", "0") & "|" & _		;3
						IniRead($CDataINI, $arr[1], "Active", "0") & "|" & _		;4
						IniRead($CDataINI, $arr[1], "Launch", "0") & "|" & _		;5
						IniRead($CDataINI, $arr[1], "Land", "0") & "|" & _			;6
						IniRead($CDataINI, $arr[1], "StartV", "0") & "|" & _		;7
						IniRead($CDataINI, $arr[1], "TargetX", "0") & "|" & _		;8
						IniRead($CDataINI, $arr[1], "TargetY", "0") & "|" & _		;9
						IniRead($CDataINI, $arr[1], "Pik", "0") & "|" & _			;10
						IniRead($CDataINI, $arr[1], "Mie", "0") & "|" & _			;11
						IniRead($CDataINI, $arr[1], "Top", "0") & "|" & _			;12
						IniRead($CDataINI, $arr[1], "Luk", "0") & "|" & _			;13
						IniRead($CDataINI, $arr[1], "Zwi", "0") & "|" & _			;14
						IniRead($CDataINI, $arr[1], "LK", "0") & "|" & _			;15
						IniRead($CDataINI, $arr[1], "LnK", "0") & "|" & _			;16
						IniRead($CDataINI, $arr[1], "CK", "0") & "|" & _			;17
						IniRead($CDataINI, $arr[1], "Tar", "0") & "|" & _			;18
						IniRead($CDataINI, $arr[1], "Kat", "0") & "|" & _			;19
						IniRead($CDataINI, $arr[1], "Ryc", "0") & "|" & _			;20
						IniRead($CDataINI, $arr[1], "Szl", "0"), $AttacksList) ;21
				If _GUICtrlListView_GetItemText($AttacksList, _GUICtrlListView_GetItemCount($AttacksList) - 1, 4) == "W£•CZONY" Then
					GUICtrlSetBkColor(-1, $AttON)
					_GUICtrlListView_SetItemGroupID($AttacksList, _GUICtrlListView_GetItemCount($AttacksList) - 1, $AttacksListON)
				Else
					GUICtrlSetBkColor(-1, $AttOFF)
					_GUICtrlListView_SetItemGroupID($AttacksList, _GUICtrlListView_GetItemCount($AttacksList) - 1, $AttacksListOFF)
				EndIf
				GUICtrlDelete(GUICtrlRead($AttacksList))
				_GUICtrlListView_SetColumn($AttacksList, 0, "ID", 0)
				_GUICtrlListView_SetColumn($AttacksList, 1, "Village ID", 0)
				_GUICtrlListView_SetColumn($AttacksList, 4, "AktywnoúÊ", 0)
				_GUICtrlListView_RegisterSortCallBack($AttacksList)
				_GUICtrlListView_SortItems($AttacksList, 5)
				_GUICtrlListView_UnRegisterSortCallBack($AttacksList)
				$Set = 0
				AttacksON()
			EndIf
		Case $msg = $Attacks_Button_Clear
			Clear()
		Case $msg = $Attacks_Button_Edit
			Local $Edit, $AttackError, $DateError
			$AttackError = 0
			$DateError = 0
			If $AttackError = 0 And $DateError = 0 And GUICtrlRead($AttacksList) Then $Edit += 1
			If GUICtrlRead($AttacksList) <> 0 And $Edit = 1 Then
				GUICtrlSetState($AttacksList, $GUI_DISABLE)
				$AttEdit = StringSplit(GUICtrlRead(GUICtrlRead($AttacksList)), "|")
				$AttacksCount = $AttEdit[1]
				$Wiocha = _ArraySearch($Village, $AttEdit[2], 0, 0, 0, 0, 1, 3, True)
				If $Village[2][$Wiocha] < 100 Then $Ky = ""
				If $Village[2][$Wiocha] > 100 Then $Ky = "1"
				If $Village[2][$Wiocha] > 200 Then $Ky = "2"
				If $Village[2][$Wiocha] > 300 Then $Ky = "3"
				If $Village[2][$Wiocha] > 400 Then $Ky = "4"
				If $Village[2][$Wiocha] > 500 Then $Ky = "5"
				If $Village[2][$Wiocha] > 600 Then $Ky = "6"
				If $Village[2][$Wiocha] > 700 Then $Ky = "7"
				If $Village[2][$Wiocha] > 800 Then $Ky = "8"
				If $Village[2][$Wiocha] > 900 Then $Ky = "9"

				If $Village[1][$Wiocha] < 100 Then $Kx = "0"
				If $Village[1][$Wiocha] > 100 Then $Kx = "1"
				If $Village[1][$Wiocha] > 200 Then $Kx = "2"
				If $Village[1][$Wiocha] > 300 Then $Kx = "3"
				If $Village[1][$Wiocha] > 400 Then $Kx = "4"
				If $Village[1][$Wiocha] > 500 Then $Kx = "5"
				If $Village[1][$Wiocha] > 600 Then $Kx = "6"
				If $Village[1][$Wiocha] > 700 Then $Kx = "7"
				If $Village[1][$Wiocha] > 800 Then $Kx = "8"
				If $Village[1][$Wiocha] > 900 Then $Kx = "9"
				GUICtrlSetData($Villages, $Wiocha & ".†" & $Village[0][$Wiocha] & "(" & $Village[1][$Wiocha] & "I" & $Village[2][$Wiocha] & ") K" & $Ky & $Kx)
				GUICtrlSetData($Xb, $AttEdit[9])
				GUICtrlSetData($Yb, $AttEdit[10])
				GUICtrlSetData($AttDate, $AttEdit[7])
				GUICtrlSetData($AttTime, $AttEdit[7])
				If $AttEdit[11] = "MAX" Then
					GUICtrlSetData($AttPiki, $AttEdit[11])
					If $AttEdit[11] = 0 Then $AttEdit[11] = ""
					GUICtrlSetState($AttPiki, $GUI_DISABLE)
					GUICtrlSetData($Attacks_Button_AllPik, "0")
				Else
					GUICtrlSetData($AttPiki, $AttEdit[11])
				EndIf
				If $AttEdit[12] = "MAX" Then
					GUICtrlSetData($AttMiecze, $AttEdit[12])
					If $AttEdit[12] = 0 Then $AttEdit[12] = ""
					GUICtrlSetState($AttMiecze, $GUI_DISABLE)
					GUICtrlSetData($Attacks_Button_AllMie, "0")
				Else
					GUICtrlSetData($AttMiecze, $AttEdit[12])
				EndIf
				If $AttEdit[13] = "MAX" Then
					GUICtrlSetData($AttTopory, $AttEdit[13])
					If $AttEdit[13] = 0 Then $AttEdit[13] = ""
					GUICtrlSetState($AttTopory, $GUI_DISABLE)
					GUICtrlSetData($Attacks_Button_AllTop, "0")
				Else
					GUICtrlSetData($AttTopory, $AttEdit[13])
				EndIf
				If $AttEdit[14] = "MAX" Then
					GUICtrlSetData($AttLuki, $AttEdit[14])
					If $AttEdit[14] = 0 Then $AttEdit[14] = ""
					GUICtrlSetState($AttLuki, $GUI_DISABLE)
					GUICtrlSetData($Attacks_Button_AllLuk, "0")
				Else
					GUICtrlSetData($AttLuki, $AttEdit[14])
				EndIf
				If $AttEdit[15] = "MAX" Then
					GUICtrlSetData($AttZwiad, $AttEdit[15])
					If $AttEdit[15] = 0 Then $AttEdit[15] = ""
					GUICtrlSetState($AttZwiad, $GUI_DISABLE)
					GUICtrlSetData($Attacks_Button_AllZwi, "0")
				Else
					GUICtrlSetData($AttZwiad, $AttEdit[15])
				EndIf
				If $AttEdit[16] = "MAX" Then
					GUICtrlSetData($AttLK, $AttEdit[16])
					If $AttEdit[16] = 0 Then $AttEdit[16] = ""
					GUICtrlSetState($AttLK, $GUI_DISABLE)
					GUICtrlSetData($Attacks_Button_AllLK, "0")
				Else
					GUICtrlSetData($AttLK, $AttEdit[16])
				EndIf
				If $AttEdit[17] = "MAX" Then
					GUICtrlSetData($AttKLucz, $AttEdit[17])
					If $AttEdit[17] = 0 Then $AttEdit[17] = ""
					GUICtrlSetState($AttKLucz, $GUI_DISABLE)
					GUICtrlSetData($Attacks_Button_AllLnK, "0")
				Else
					GUICtrlSetData($AttKLucz, $AttEdit[17])
				EndIf
				If $AttEdit[18] = "MAX" Then
					GUICtrlSetData($AttCK, $AttEdit[18])
					If $AttEdit[18] = 0 Then $AttEdit[18] = ""
					GUICtrlSetState($AttCK, $GUI_DISABLE)
					GUICtrlSetData($Attacks_Button_AllCK, "0")
				Else
					GUICtrlSetData($AttCK, $AttEdit[18])
				EndIf
				If $AttEdit[19] = "MAX" Then
					GUICtrlSetData($AttTar, $AttEdit[19])
					If $AttEdit[19] = 0 Then $AttEdit[19] = ""
					GUICtrlSetState($AttTar, $GUI_DISABLE)
					GUICtrlSetData($Attacks_Button_AllTar, "0")
				Else
					GUICtrlSetData($AttTar, $AttEdit[19])
				EndIf
				If $AttEdit[20] = "MAX" Then
					GUICtrlSetData($AttKat, $AttEdit[20])
					If $AttEdit[20] = 0 Then $AttEdit[20] = ""
					GUICtrlSetState($AttKat, $GUI_DISABLE)
					GUICtrlSetData($Attacks_Button_AllKat, "0")
				Else
					GUICtrlSetData($AttKat, $AttEdit[20])
				EndIf
				If $AttEdit[21] = "MAX" Then
					GUICtrlSetData($AttRyc, $AttEdit[21])
					If $AttEdit[21] = 0 Then $AttEdit[21] = ""
					GUICtrlSetState($AttRyc, $GUI_DISABLE)
					GUICtrlSetData($Attacks_Button_AllRyc, "0")
				Else
					GUICtrlSetData($AttRyc, $AttEdit[21])
				EndIf
				If $AttEdit[22] = "MAX" Then
					GUICtrlSetData($AttSzl, $AttEdit[22])
					If $AttEdit[22] = 0 Then $AttEdit[22] = ""
					GUICtrlSetState($AttSzl, $GUI_DISABLE)
					GUICtrlSetData($Attacks_Button_AllSzl, "0")
				Else
					GUICtrlSetData($AttSzl, $AttEdit[22])
				EndIf
				GUICtrlSetData($AttackType, $AttEdit[3])
				GUICtrlSetData($Interwal, "2000/01/01 " & $AttEdit[4])
				GUICtrlSetState($Attacks_Button_Add, $GUI_DISABLE)
				GUICtrlSetState($Attacks_Button_Remove, $GUI_DISABLE)
				GUICtrlSetState($Attacks_Button_Switch, $GUI_DISABLE)
				GUICtrlSetState($Attacks_Button_Clear, $GUI_DISABLE)
				GUICtrlSetState($Attacks_Button_Cancel, $GUI_ENABLE)
				GUICtrlSetData($Attacks_Button_Edit, "Zapisz")
			EndIf
			If GUICtrlRead($AttacksList) <> 0 And $Edit >= 2 Then
				Local $DateError
				$AttackError = 1
				If GUICtrlRead($AttackType) <> "<ROZKAZ>" Then
					If GUICtrlRead($Villages) <> "Wszystkie wioski (" & $Village[0][0] & ")" And GUICtrlRead($Xb) <> "" And GUICtrlRead($Yb) <> "" Then
						If GUICtrlRead($AttPiki) <> "" Or GUICtrlRead($AttMiecze) <> "" Or GUICtrlRead($AttTopory) <> "" Or GUICtrlRead($AttLuki) <> "" Or _
								GUICtrlRead($AttZwiad) <> "" Or GUICtrlRead($AttLK) <> "" Or GUICtrlRead($AttKLucz) <> "" Or GUICtrlRead($AttCK) <> "" Or GUICtrlRead($AttTar) <> "" Or _
								GUICtrlRead($AttKat) <> "" Or GUICtrlRead($AttRyc) <> "" Or GUICtrlRead($AttSzl) <> "" Then
							If (GUICtrlRead($AttPiki) = "MAX" Or GUICtrlRead($AttMiecze) = "MAX" Or GUICtrlRead($AttTopory) = "MAX" Or GUICtrlRead($AttLuki) = "MAX" Or _
									GUICtrlRead($AttZwiad) = "MAX" Or GUICtrlRead($AttLK) = "MAX" Or GUICtrlRead($AttKLucz) = "MAX" Or GUICtrlRead($AttCK) = "MAX" Or GUICtrlRead($AttTar) = "MAX" Or _
									GUICtrlRead($AttKat) = "MAX" Or GUICtrlRead($AttRyc) = "MAX" Or GUICtrlRead($AttSzl) = "MAX") And $Added = 0 Then
								$AttacksCount -= 1
								AddAttack()
							EndIf
							If (GUICtrlRead($AttPiki) <> 0 Or GUICtrlRead($AttMiecze) <> 0 Or _
									GUICtrlRead($AttTopory) <> 0 Or GUICtrlRead($AttLuki) <> 0 Or GUICtrlRead($AttZwiad) <> 0 Or GUICtrlRead($AttLK) <> 0 Or GUICtrlRead($AttKLucz) <> 0 Or _
									GUICtrlRead($AttCK) <> 0 Or GUICtrlRead($AttTar) <> 0 Or GUICtrlRead($AttKat) <> 0 Or GUICtrlRead($AttRyc) <> 0 Or GUICtrlRead($AttSzl) <> 0) And $Added = 0 Then
								$AttacksCount -= 1
								AddAttack()
							EndIf
						EndIf
					EndIf
				EndIf
				$Text = ""
				If $AttackError = 1 Then
					If GUICtrlRead($Villages) = "Wszystkie wioski (" & $Village[0][0] & ")" Then $Text = $Text & "- Nie wybrano wioski atakujπcej," & @CRLF
					If GUICtrlRead($Xb) = "" Or GUICtrlRead($Yb) = "" Then $Text = $Text & "- Nie podano wspÛ≥rzÍdnych celu," & @CRLF
					If ((GUICtrlRead($AttPiki) = "" Or GUICtrlRead($AttPiki) = 0) And GUICtrlRead($AttPiki) <> "MAX") And _
							((GUICtrlRead($AttMiecze) = "" Or GUICtrlRead($AttMiecze) = 0) And GUICtrlRead($AttMiecze) <> "MAX") And _
							((GUICtrlRead($AttTopory) = "" Or GUICtrlRead($AttTopory) = 0) And GUICtrlRead($AttTopory) <> "MAX") And _
							((GUICtrlRead($AttLuki) = "" Or GUICtrlRead($AttLuki) = 0) And GUICtrlRead($AttLuki) <> "MAX") And _
							((GUICtrlRead($AttZwiad) = "" Or GUICtrlRead($AttZwiad) = 0) And GUICtrlRead($AttZwiad) <> "MAX") And _
							((GUICtrlRead($AttLK) = "" Or GUICtrlRead($AttLK) = 0) And GUICtrlRead($AttLK) <> "MAX") And _
							((GUICtrlRead($AttKLucz) = "" Or GUICtrlRead($AttKLucz) = 0) And GUICtrlRead($AttKLucz) <> "MAX") And _
							((GUICtrlRead($AttCK) = "" Or GUICtrlRead($AttCK) = 0) And GUICtrlRead($AttCK) <> "MAX") And _
							((GUICtrlRead($AttTar) = "" Or GUICtrlRead($AttTar) = 0) And GUICtrlRead($AttTar) <> "MAX") And _
							((GUICtrlRead($AttKat) = "" Or GUICtrlRead($AttKat) = 0) And GUICtrlRead($AttKat) <> "MAX") And _
							((GUICtrlRead($AttRyc) = "" Or GUICtrlRead($AttRyc) = 0) And GUICtrlRead($AttRyc) <> "MAX") And _
							((GUICtrlRead($AttSzl) = "" Or GUICtrlRead($AttSzl) = 0) And GUICtrlRead($AttSzl) <> "MAX") Then $Text = $Text & "- Nie wybrano øadnych jednostek," & @CRLF
					If GUICtrlRead($AttackType) = "<ROZKAZ>" Then $Text = $Text & "- Nie wybrano rozkazu," & @CRLF
					MsgBox(16, "B≥πd dodawania ataku", "Wystπpi≥ b≥πd podczas dodawania ataku, poniewaø:" & @CRLF & @CRLF & $Text & @CRLF & "Podaj te dane!", 2)
				EndIf
				If $DateError = 1 Then
					$Opoznienie = _DateDiff('s', $CzasP, $Date & " " & $Time)
					$Opoznienie += 5
					;			msgbox(0, "", $CzasP)
					$Text = $Text & "Data wys≥ania ataku juø minÍ≥a!" & @CRLF & "SpÛüni≥eú siÍ o " & $Opoznienie & " sekund." & @CRLF
					MsgBox(16, "B≥πd dodawania ataku", "Wystπpi≥ b≥πd podczas dodawania ataku, poniewaø:" & @CRLF & @CRLF & $Text & @CRLF & "Podaj innπ datÍ!", 2)
				EndIf
				If $AttackError = 0 And $DateError = 0 Then
					$Edit = 0
					GUICtrlDelete(GUICtrlRead($AttacksList))
					$AttacksCount = IniRead($CDataINI, "STATUS", "Count", "0")
					GUICtrlSetState($AttacksList, $GUI_ENABLE)
					GUICtrlSetState($Attacks_Button_Cancel, $GUI_DISABLE)
					GUICtrlSetState($Attacks_Button_Add, $GUI_ENABLE)
					GUICtrlSetState($Attacks_Button_Switch, $GUI_ENABLE)
					GUICtrlSetState($Attacks_Button_Remove, $GUI_ENABLE)
					GUICtrlSetState($Attacks_Button_Clear, $GUI_ENABLE)
					GUICtrlSetData($Attacks_Button_Edit, "Edytuj")
					$AttackError = 0
					$DateError = 0
					Clear()
					AttacksON()
					LogWrite("Zedytowano atak na koncie " & GUICtrlRead($Login) & " (" & GUICtrlRead($Worlds) & ")")
				EndIf
			EndIf
			$Added = 0
		Case $msg = $Attacks_Button_Cancel
			$Edit = 0
			GUICtrlSetState($AttacksList, $GUI_ENABLE)
			$AttacksCount = IniRead($CDataINI, "STATUS", "Count", "0")
			$AttackError = 0
			$DateError = 0
			Clear()
			GUICtrlSetState($Attacks_Button_Cancel, $GUI_DISABLE)
			GUICtrlSetState($Attacks_Button_Add, $GUI_ENABLE)
			GUICtrlSetState($Attacks_Button_Switch, $GUI_ENABLE)
			GUICtrlSetState($Attacks_Button_Remove, $GUI_ENABLE)
			GUICtrlSetState($Attacks_Button_Clear, $GUI_ENABLE)
			GUICtrlSetData($Attacks_Button_Edit, "Edytuj")
			AttacksON()
		Case $msg = $NAVIGATE_Button_Add
			_GUICtrlTab_ClickTab($MainTAB, 1)
			$table2 = _IEGetObjById($oIE0, "contentContainer")
			$Copy = _IETableWriteToArray($table2)
			$Copy1 = StringSplit($Copy[0][0], "|")
			If StringRight($Copy1[1], 1) >= 0 Then $CopyX = StringRight($Copy1[1], 1)
			If StringRight($Copy1[1], 2) >= 10 Then $CopyX = StringRight($Copy1[1], 2)
			If StringRight($Copy1[1], 3) >= 100 Then $CopyX = StringRight($Copy1[1], 3)
			If StringLeft($Copy1[2], 1) >= 0 Then $CopyY = StringLeft($Copy1[2], 1)
			If StringLeft($Copy1[2], 2) >= 10 Then $CopyY = StringLeft($Copy1[2], 2)
			If StringLeft($Copy1[2], 3) >= 100 Then $CopyY = StringLeft($Copy1[2], 3)
			GUICtrlSetData($Xb, $CopyX)
			GUICtrlSetData($Yb, $CopyY)
	EndSelect
WEnd
#EndRegion ;PÍtla obs≥ugujπca GUI itp.

#Region ;Koniec dzia≥ania programu
IniWrite($INIc, "SESSION", "cLogin", "")
IniWrite($INIc, "SESSION", "cPassword", "")
IniWrite($INIc, "SESSION", "cWorld", "")
FileWrite($LOG, $LogTime & "TW Master bot zosta≥ wy≥πczony..." & @CRLF)
FileWrite($LOG, @CRLF & "------------------------------------------------------" & @CRLF & @CRLF)
FileClose($LOG)
GUIDelete()
Exit
#EndRegion ;Koniec dzia≥ania programu

Func Captcha()
	While _IEGetObjById($oIE, "bot_check_image") <> ""
		If _IEGetObjById($oIE, "bot_check_image") <> "" Then
			GUISetState(@SW_ENABLE)
			$captcha = _IEGetObjById($oIE, "bot_check_image")
			$captcha = $captcha.src
			$cpt = @ScriptDir & "\captcha.png"
			InetGet($captcha, $cpt, 0, 0)
			$Break = _TWC_Break($cpt)
			$Input = _IEGetObjByName($oIE, "code")
			_IEFormElementSetValue($Input, $Break)
			$btn = _IEGetObjByAttr($oIE, "input", "class=btn|type=submit")
			_IEAction($btn, "click")
			_IELoadWait($oIE)
			FileDelete($cpt)
		EndIf
	WEnd
EndFunc   ;==>Captcha

#Region ;Funkcje
Func Attack()
	AdlibUnRegister("Attack")
	GUICtrlSetData($NAttack, "WYSY£ANIE")
	;GUICtrlSetState($IE, $GUI_DISABLE)
	_IENavigate($oIE2, "http://pl" & IniRead($INIc, "SESSION", "cWorld", "0") & ".plemiona.pl/game.php?village=" & IniRead($CDataINI, $AttackID2, "VillageID", "0") & "&screen=place", 0)
	_IENavigate($oIE3, "http://pl" & IniRead($INIc, "SESSION", "cWorld", "0") & ".plemiona.pl/game.php?village=" & IniRead($CDataINI, $AttackID3, "VillageID", "0") & "&screen=place", 0)
	_IENavigate($oIE4, "http://pl" & IniRead($INIc, "SESSION", "cWorld", "0") & ".plemiona.pl/game.php?village=" & IniRead($CDataINI, $AttackID4, "VillageID", "0") & "&screen=place", 0)
	_IENavigate($oIE5, "http://pl" & IniRead($INIc, "SESSION", "cWorld", "0") & ".plemiona.pl/game.php?village=" & IniRead($CDataINI, $AttackID5, "VillageID", "0") & "&screen=place", 0)
	_IENavigate($oIE, "http://pl" & IniRead($INIc, "SESSION", "cWorld", "0") & ".plemiona.pl/game.php?village=" & IniRead($CDataINI, $IDattack, "VillageID", "0") & "&screen=place", 1)
	$oAtt = _IEGetObjById($oIE, "selectAllUnits")
	_IEAction($oAtt, "click")
	$oAtt = _IEGetObjById($oIE, "unit_input_spear")
	If IniRead($CDataINI, $IDattack, "Pik", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $IDattack, "Pik", "0"))
	$oAtt = _IEGetObjById($oIE, "unit_input_sword")
	If IniRead($CDataINI, $IDattack, "Mie", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $IDattack, "Mie", "0"))
	$oAtt = _IEGetObjById($oIE, "unit_input_axe")
	If IniRead($CDataINI, $IDattack, "Top", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $IDattack, "Top", "0"))
	$oAtt = _IEGetObjById($oIE, "unit_input_archer")
	If IniRead($CDataINI, $IDattack, "Luk", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $IDattack, "Luk", "0"))
	$oAtt = _IEGetObjById($oIE, "unit_input_spy")
	If IniRead($CDataINI, $IDattack, "Zwi", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $IDattack, "Zwi", "0"))
	$oAtt = _IEGetObjById($oIE, "unit_input_light")
	If IniRead($CDataINI, $IDattack, "LK", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $IDattack, "LK", "0"))
	$oAtt = _IEGetObjById($oIE, "unit_input_marcher")
	If IniRead($CDataINI, $IDattack, "LnK", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $IDattack, "LnK", "0"))
	$oAtt = _IEGetObjById($oIE, "unit_input_heavy")
	If IniRead($CDataINI, $IDattack, "CK", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $IDattack, "CK", "0"))
	$oAtt = _IEGetObjById($oIE, "unit_input_ram")
	If IniRead($CDataINI, $IDattack, "Tar", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $IDattack, "Tar", "0"))
	$oAtt = _IEGetObjById($oIE, "unit_input_catapult")
	If IniRead($CDataINI, $IDattack, "Kat", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $IDattack, "Kat", "0"))
	$oAtt = _IEGetObjById($oIE, "unit_input_knight")
	If IniRead($CDataINI, $IDattack, "Ryc", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $IDattack, "Ryc", "0"))
	$oAtt = _IEGetObjById($oIE, "unit_input_snob")
	If IniRead($CDataINI, $IDattack, "Szl", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $IDattack, "Szl", "0"))
	$oXY = _IEGetObjByAttr($oIE, "input", "type=text|class=target-input-field target-input-autocomplete ui-autocomplete-input")
	_IEFormElementSetValue($oXY[0], IniRead($CDataINI, $IDattack, "TargetX", "0") & "|" & IniRead($CDataINI, $IDattack, "TargetY", "0"))
	If IniRead($CDataINI, $IDattack, "Type", "0") = "Wsparcie" Then
		$oAtt = _IEGetObjById($oIE, "target_support")
		_IEAction($oAtt, "Click")
	Else
		$oAtt = _IEGetObjById($oIE, "target_attack")
		_IEAction($oAtt, "Click")
	EndIf
	LogWrite("Przygotowywanie ataku do wys≥ania na koncie " & GUICtrlRead($Login) & " (" & GUICtrlRead($Worlds) & ") na wioskÍ " & IniRead($CDataINI, $IDattack, "TargetX", "0") & "|" & IniRead($CDataINI, $IDattack, "TargetY", "0"))
	If $Attacks >= 2 Then
		$oAtt = _IEGetObjById($oIE2, "selectAllUnits")
		_IEAction($oAtt, "click")
		$oAtt = _IEGetObjById($oIE2, "unit_input_spear")
		If IniRead($CDataINI, $AttackID2, "Pik", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID2, "Pik", "0"))
		$oAtt = _IEGetObjById($oIE2, "unit_input_sword")
		If IniRead($CDataINI, $AttackID2, "Mie", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID2, "Mie", "0"))
		$oAtt = _IEGetObjById($oIE2, "unit_input_axe")
		If IniRead($CDataINI, $AttackID2, "Top", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID2, "Top", "0"))
		$oAtt = _IEGetObjById($oIE2, "unit_input_archer")
		If IniRead($CDataINI, $AttackID2, "Luk", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID2, "Luk", "0"))
		$oAtt = _IEGetObjById($oIE2, "unit_input_spy")
		If IniRead($CDataINI, $AttackID2, "Zwi", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID2, "Zwi", "0"))
		$oAtt = _IEGetObjById($oIE2, "unit_input_light")
		If IniRead($CDataINI, $AttackID2, "LK", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID2, "LK", "0"))
		$oAtt = _IEGetObjById($oIE2, "unit_input_marcher")
		If IniRead($CDataINI, $AttackID2, "LnK", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID2, "LnK", "0"))
		$oAtt = _IEGetObjById($oIE2, "unit_input_heavy")
		If IniRead($CDataINI, $AttackID2, "CK", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID2, "CK", "0"))
		$oAtt = _IEGetObjById($oIE2, "unit_input_ram")
		If IniRead($CDataINI, $AttackID2, "Tar", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID2, "Tar", "0"))
		$oAtt = _IEGetObjById($oIE2, "unit_input_catapult")
		If IniRead($CDataINI, $AttackID2, "Kat", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID2, "Kat", "0"))
		$oAtt = _IEGetObjById($oIE2, "unit_input_knight")
		If IniRead($CDataINI, $AttackID2, "Ryc", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID2, "Ryc", "0"))
		$oAtt = _IEGetObjById($oIE2, "unit_input_snob")
		If IniRead($CDataINI, $AttackID2, "Szl", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID2, "Szl", "0"))
		$oXY = _IEGetObjByAttr($oIE2, "input", "type=text|class=target-input-field target-input-autocomplete ui-autocomplete-input")
		_IEFormElementSetValue($oXY[0], IniRead($CDataINI, $AttackID2, "TargetX", "0") & "|" & IniRead($CDataINI, $AttackID2, "TargetY", "0"))
		If IniRead($CDataINI, $AttackID2, "Type", "0") = "Wsparcie" Then
			$oAtt = _IEGetObjById($oIE2, "target_support")
			_IEAction($oAtt, "Click")
		Else
			$oAtt = _IEGetObjById($oIE2, "target_attack")
			_IEAction($oAtt, "Click")
		EndIf
		LogWrite("Przygotowywanie ataku do wys≥ania na koncie " & GUICtrlRead($Login) & " (" & GUICtrlRead($Worlds) & ") na wioskÍ " & IniRead($CDataINI, $AttackID2, "TargetX", "0") & "|" & IniRead($CDataINI, $AttackID2, "TargetY", "0"))
	EndIf
	If $Attacks >= 3 Then
		$oAtt = _IEGetObjById($oIE3, "selectAllUnits")
		_IEAction($oAtt, "click")
		$oAtt = _IEGetObjById($oIE3, "unit_input_spear")
		If IniRead($CDataINI, $AttackID3, "Pik", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID3, "Pik", "0"))
		$oAtt = _IEGetObjById($oIE3, "unit_input_sword")
		If IniRead($CDataINI, $AttackID3, "Mie", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID3, "Mie", "0"))
		$oAtt = _IEGetObjById($oIE3, "unit_input_axe")
		If IniRead($CDataINI, $AttackID3, "Top", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID3, "Top", "0"))
		$oAtt = _IEGetObjById($oIE3, "unit_input_archer")
		If IniRead($CDataINI, $AttackID3, "Luk", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID3, "Luk", "0"))
		$oAtt = _IEGetObjById($oIE3, "unit_input_spy")
		If IniRead($CDataINI, $AttackID3, "Zwi", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID3, "Zwi", "0"))
		$oAtt = _IEGetObjById($oIE3, "unit_input_light")
		If IniRead($CDataINI, $AttackID3, "LK", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID3, "LK", "0"))
		$oAtt = _IEGetObjById($oIE3, "unit_input_marcher")
		If IniRead($CDataINI, $AttackID3, "LnK", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID3, "LnK", "0"))
		$oAtt = _IEGetObjById($oIE3, "unit_input_heavy")
		If IniRead($CDataINI, $AttackID3, "CK", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID3, "CK", "0"))
		$oAtt = _IEGetObjById($oIE3, "unit_input_ram")
		If IniRead($CDataINI, $AttackID3, "Tar", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID3, "Tar", "0"))
		$oAtt = _IEGetObjById($oIE3, "unit_input_catapult")
		If IniRead($CDataINI, $AttackID3, "Kat", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID3, "Kat", "0"))
		$oAtt = _IEGetObjById($oIE3, "unit_input_knight")
		If IniRead($CDataINI, $AttackID3, "Ryc", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID3, "Ryc", "0"))
		$oAtt = _IEGetObjById($oIE3, "unit_input_snob")
		If IniRead($CDataINI, $AttackID3, "Szl", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID3, "Szl", "0"))
		$oXY = _IEGetObjByAttr($oIE3, "input", "type=text|class=target-input-field target-input-autocomplete ui-autocomplete-input")
		_IEFormElementSetValue($oXY[0], IniRead($CDataINI, $AttackID3, "TargetX", "0") & "|" & IniRead($CDataINI, $AttackID3, "TargetY", "0"))
		If IniRead($CDataINI, $AttackID3, "Type", "0") = "Wsparcie" Then
			$oAtt = _IEGetObjById($oIE3, "target_support")
			_IEAction($oAtt, "Click")
		Else
			$oAtt = _IEGetObjById($oIE3, "target_attack")
			_IEAction($oAtt, "Click")
		EndIf
		LogWrite("Przygotowywanie ataku do wys≥ania na koncie " & GUICtrlRead($Login) & " (" & GUICtrlRead($Worlds) & ") na wioskÍ " & IniRead($CDataINI, $AttackID3, "TargetX", "0") & "|" & IniRead($CDataINI, $AttackID3, "TargetY", "0"))
	EndIf
	If $Attacks >= 4 Then
		$oAtt = _IEGetObjById($oIE4, "selectAllUnits")
		_IEAction($oAtt, "click")
		$oAtt = _IEGetObjById($oIE4, "unit_input_spear")
		If IniRead($CDataINI, $AttackID4, "Pik", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID4, "Pik", "0"))
		$oAtt = _IEGetObjById($oIE4, "unit_input_sword")
		If IniRead($CDataINI, $AttackID4, "Mie", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID4, "Mie", "0"))
		$oAtt = _IEGetObjById($oIE4, "unit_input_axe")
		If IniRead($CDataINI, $AttackID4, "Top", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID4, "Top", "0"))
		$oAtt = _IEGetObjById($oIE4, "unit_input_archer")
		If IniRead($CDataINI, $AttackID4, "Luk", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID4, "Luk", "0"))
		$oAtt = _IEGetObjById($oIE4, "unit_input_spy")
		If IniRead($CDataINI, $AttackID4, "Zwi", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID4, "Zwi", "0"))
		$oAtt = _IEGetObjById($oIE4, "unit_input_light")
		If IniRead($CDataINI, $AttackID4, "LK", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID4, "LK", "0"))
		$oAtt = _IEGetObjById($oIE4, "unit_input_marcher")
		If IniRead($CDataINI, $AttackID4, "LnK", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID4, "LnK", "0"))
		$oAtt = _IEGetObjById($oIE4, "unit_input_heavy")
		If IniRead($CDataINI, $AttackID4, "CK", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID4, "CK", "0"))
		$oAtt = _IEGetObjById($oIE4, "unit_input_ram")
		If IniRead($CDataINI, $AttackID4, "Tar", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID4, "Tar", "0"))
		$oAtt = _IEGetObjById($oIE4, "unit_input_catapult")
		If IniRead($CDataINI, $AttackID4, "Kat", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID4, "Kat", "0"))
		$oAtt = _IEGetObjById($oIE4, "unit_input_knight")
		If IniRead($CDataINI, $AttackID4, "Ryc", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID4, "Ryc", "0"))
		$oAtt = _IEGetObjById($oIE4, "unit_input_snob")
		If IniRead($CDataINI, $AttackID4, "Szl", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID4, "Szl", "0"))
		$oXY = _IEGetObjByAttr($oIE4, "input", "type=text|class=target-input-field target-input-autocomplete ui-autocomplete-input")
		_IEFormElementSetValue($oXY[0], IniRead($CDataINI, $AttackID4, "TargetX", "0") & "|" & IniRead($CDataINI, $AttackID4, "TargetY", "0"))
		If IniRead($CDataINI, $AttackID4, "Type", "0") = "Wsparcie" Then
			$oAtt = _IEGetObjById($oIE4, "target_support")
			_IEAction($oAtt, "Click")
		Else
			$oAtt = _IEGetObjById($oIE4, "target_attack")
			_IEAction($oAtt, "Click")
		EndIf
		LogWrite("Przygotowywanie ataku do wys≥ania na koncie " & GUICtrlRead($Login) & " (" & GUICtrlRead($Worlds) & ") na wioskÍ " & IniRead($CDataINI, $AttackID4, "TargetX", "0") & "|" & IniRead($CDataINI, $AttackID4, "TargetY", "0"))
	EndIf
	If $Attacks >= 5 Then
		$oAtt = _IEGetObjById($oIE, "selectAllUnits")
		_IEAction($oAtt, "click")
		$oAtt = _IEGetObjById($oIE5, "unit_input_spear")
		If IniRead($CDataINI, $AttackID5, "Pik", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID5, "Pik", "0"))
		$oAtt = _IEGetObjById($oIE5, "unit_input_sword")
		If IniRead($CDataINI, $AttackID5, "Mie", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID5, "Mie", "0"))
		$oAtt = _IEGetObjById($oIE5, "unit_input_axe")
		If IniRead($CDataINI, $AttackID5, "Top", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID5, "Top", "0"))
		$oAtt = _IEGetObjById($oIE5, "unit_input_archer")
		If IniRead($CDataINI, $AttackID5, "Luk", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID5, "Luk", "0"))
		$oAtt = _IEGetObjById($oIE5, "unit_input_spy")
		If IniRead($CDataINI, $AttackID5, "Zwi", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID5, "Zwi", "0"))
		$oAtt = _IEGetObjById($oIE5, "unit_input_light")
		If IniRead($CDataINI, $AttackID5, "LK", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID5, "LK", "0"))
		$oAtt = _IEGetObjById($oIE5, "unit_input_marcher")
		If IniRead($CDataINI, $AttackID5, "LnK", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID5, "LnK", "0"))
		$oAtt = _IEGetObjById($oIE5, "unit_input_heavy")
		If IniRead($CDataINI, $AttackID5, "CK", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID5, "CK", "0"))
		$oAtt = _IEGetObjById($oIE5, "unit_input_ram")
		If IniRead($CDataINI, $AttackID5, "Tar", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID5, "Tar", "0"))
		$oAtt = _IEGetObjById($oIE5, "unit_input_catapult")
		If IniRead($CDataINI, $AttackID5, "Kat", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID5, "Kat", "0"))
		$oAtt = _IEGetObjById($oIE5, "unit_input_knight")
		If IniRead($CDataINI, $AttackID5, "Ryc", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID5, "Ryc", "0"))
		$oAtt = _IEGetObjById($oIE5, "unit_input_snob")
		If IniRead($CDataINI, $AttackID5, "Szl", "0") <> "MAX" Then _IEFormElementSetValue($oAtt, IniRead($CDataINI, $AttackID5, "Szl", "0"))
		$oXY = _IEGetObjByAttr($oIE5, "input", "type=text|class=target-input-field target-input-autocomplete ui-autocomplete-input")
		_IEFormElementSetValue($oXY[0], IniRead($CDataINI, $AttackID5, "TargetX", "0") & "|" & IniRead($CDataINI, $AttackID5, "TargetY", "0"))
		If IniRead($CDataINI, $AttackID5, "Type", "0") = "Wsparcie" Then
			$oAtt = _IEGetObjById($oIE5, "target_support")
			_IEAction($oAtt, "Click")
		Else
			$oAtt = _IEGetObjById($oIE5, "target_attack")
			_IEAction($oAtt, "Click")
		EndIf
		LogWrite("Przygotowywanie ataku do wys≥ania na koncie " & GUICtrlRead($Login) & " (" & GUICtrlRead($Worlds) & ") na wioskÍ " & IniRead($CDataINI, $AttackID5, "TargetX", "0") & "|" & IniRead($CDataINI, $AttackID5, "TargetY", "0"))
	EndIf
	$Launch = 1
	$Atak = $IDattack
EndFunc   ;==>Attack

Func AttacksON()
	$AttacksON = 0
	$Ataki = IniReadSectionNames($CDataINI)
	If $Ataki[0] > 2 Then
		For $i = 3 To $Ataki[0] Step 1
			If IniRead($CDataINI, $Ataki[$i], "Active", "0") = "W£•CZONY" Then $AttacksON += 1
		Next
	EndIf
	GUICtrlSetData($AttacksA, "Ataki: " & $Ataki[0] - 2)
	GUICtrlSetData($AttacksF, "Wy≥πczone: " & ($Ataki[0] - 2) - $AttacksON)
	GUICtrlSetData($AttacksN, "W≥πczone: " & $AttacksON)
	If $AttacksON = 0 Then $Stop = 0
EndFunc   ;==>AttacksON

Func LoadAttacks()
	Local $F, $N
	$SecAtaki = IniReadSectionNames($CDataINI)
	$Przedawnione = 0
	;	_ArrayDisplay($SecAtaki)
	If $SecAtaki[0] > 2 Then
		GUISetState(@SW_SHOW, $LoginGUI)
		GUISetState(@SW_DISABLE, $MainGUI)
		WinSetTitle($LoginGUI, "", "ProszÍ czekaÊ, trwa ≥adowanie atakÛw...")
		For $AttacksLoad = 3 To $SecAtaki[0]
			GUICtrlCreateListViewItem(IniRead($CDataINI, $SecAtaki[$AttacksLoad], "Count", "0") & "|" & _		;0 Niewidoczna
					IniRead($CDataINI, $SecAtaki[$AttacksLoad], "VillageID", "0") & "|" & _	;1 Niewidoczna
					IniRead($CDataINI, $SecAtaki[$AttacksLoad], "Type", "0") & "|" & _			;2
					IniRead($CDataINI, $SecAtaki[$AttacksLoad], "Interwal", "0") & "|" & _		;3
					IniRead($CDataINI, $SecAtaki[$AttacksLoad], "Active", "0") & "|" & _		;4
					IniRead($CDataINI, $SecAtaki[$AttacksLoad], "Launch", "0") & "|" & _		;5
					IniRead($CDataINI, $SecAtaki[$AttacksLoad], "Land", "0") & "|" & _			;6
					IniRead($CDataINI, $SecAtaki[$AttacksLoad], "StartV", "0") & "|" & _		;7
					IniRead($CDataINI, $SecAtaki[$AttacksLoad], "TargetX", "0") & "|" & _		;8
					IniRead($CDataINI, $SecAtaki[$AttacksLoad], "TargetY", "0") & "|" & _		;9
					IniRead($CDataINI, $SecAtaki[$AttacksLoad], "Pik", "0") & "|" & _			;10
					IniRead($CDataINI, $SecAtaki[$AttacksLoad], "Mie", "0") & "|" & _			;11
					IniRead($CDataINI, $SecAtaki[$AttacksLoad], "Top", "0") & "|" & _			;12
					IniRead($CDataINI, $SecAtaki[$AttacksLoad], "Luk", "0") & "|" & _			;13
					IniRead($CDataINI, $SecAtaki[$AttacksLoad], "Zwi", "0") & "|" & _			;14
					IniRead($CDataINI, $SecAtaki[$AttacksLoad], "LK", "0") & "|" & _			;15
					IniRead($CDataINI, $SecAtaki[$AttacksLoad], "LnK", "0") & "|" & _			;16
					IniRead($CDataINI, $SecAtaki[$AttacksLoad], "CK", "0") & "|" & _			;17
					IniRead($CDataINI, $SecAtaki[$AttacksLoad], "Tar", "0") & "|" & _			;18
					IniRead($CDataINI, $SecAtaki[$AttacksLoad], "Kat", "0") & "|" & _			;19
					IniRead($CDataINI, $SecAtaki[$AttacksLoad], "Ryc", "0") & "|" & _			;20
					IniRead($CDataINI, $SecAtaki[$AttacksLoad], "Szl", "0"), $AttacksList) ;21
			If _GUICtrlListView_GetItemText($AttacksList, $AttacksLoad - 3, 4) == "W£•CZONY" Then
				GUICtrlSetBkColor(-1, $AttON)
				_GUICtrlListView_SetItemGroupID($AttacksList, $AttacksLoad - 3, $AttacksListON)
				$N += 1
				GUICtrlSetData($AttacksN, "W≥πczone: " & $N)
			Else
				GUICtrlSetBkColor(-1, $AttOFF)
				_GUICtrlListView_SetItemGroupID($AttacksList, $AttacksLoad - 3, $AttacksListOFF)
				$F += 1
				GUICtrlSetData($AttacksF, "Wy≥πczone: " & $F)
			EndIf
			If _DateDiff('s', IniRead($CDataINI, $SecAtaki[$AttacksLoad], "Launch", "0"), $Date & " " & $Time) > 0 And _
					_GUICtrlListView_GetItemText($AttacksList, $AttacksLoad - 3, 4) == "W£•CZONY" Then
				_GUICtrlListView_SetItemText($AttacksList, $AttacksLoad - 3, "WY£•CZONY", 4)
				GUICtrlSetBkColor(-1, $AttOFF)
				_GUICtrlListView_SetItemGroupID($AttacksList, $AttacksLoad - 3, $AttacksListOFF)
				IniWrite($CDataINI, $SecAtaki[$AttacksLoad], "Active", "WY£•CZONY")
				$Przedawnione += 1
			EndIf
			GUICtrlSetData($AttacksA, "Ataki: " & $AttacksLoad - 3)
		Next
		GUISetState(@SW_HIDE, $LoginGUI)
		GUISetState(@SW_ENABLE, $MainGUI)
		GUISetState(@SW_HIDE, $MainGUI)
		GUISetState(@SW_SHOW, $MainGUI)
	EndIf
	If $Przedawnione > 0 Then LogWrite("Wy≥πczono " & $Przedawnione & " przedawnionych atakÛw na koncie " & GUICtrlRead($Login) & " (" & GUICtrlRead($Worlds) & ")")
	_GUICtrlListView_SetColumn($AttacksList, 0, "ID", 0)
	_GUICtrlListView_SetColumn($AttacksList, 1, "Village ID", 0)
	_GUICtrlListView_SetColumn($AttacksList, 4, "AktywnoúÊ", 0)
	_GUICtrlListView_RegisterSortCallBack($AttacksList)
	_GUICtrlListView_SortItems($AttacksList, 5)
	_GUICtrlListView_UnRegisterSortCallBack($AttacksList)
	$Set = 0
	LogWrite("Za≥adowano listÍ atakÛw na koncie " & GUICtrlRead($Login) & " (" & GUICtrlRead($Worlds) & ")")
	AttacksON()
EndFunc   ;==>LoadAttacks

Func Clear()
	GUICtrlSetData($Villages, "Wszystkie wioski (" & $Village[0][0] & ")", "Wszystkie wioski (" & $Village[0][0] & ")")
	GUICtrlSetData($Xb, "")
	GUICtrlSetData($Yb, "")
	GUICtrlSetData($AttDate, @YEAR & "/" & @MON & "/" & @MDAY)
	GUICtrlSetData($AttTime, @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC)
	GUICtrlSetData($AttPiki, "")
	GUICtrlSetState($AttPiki, $GUI_ENABLE)
	GUICtrlSetData($Attacks_Button_AllPik, "MAX")
	GUICtrlSetData($AttMiecze, "")
	GUICtrlSetState($AttMiecze, $GUI_ENABLE)
	GUICtrlSetData($Attacks_Button_AllMie, "MAX")
	GUICtrlSetData($AttTopory, "")
	GUICtrlSetState($AttTopory, $GUI_ENABLE)
	GUICtrlSetData($Attacks_Button_AllTop, "MAX")
	GUICtrlSetData($AttLuki, "")
	GUICtrlSetState($AttLuki, $GUI_ENABLE)
	GUICtrlSetData($Attacks_Button_AllLuk, "MAX")
	GUICtrlSetData($AttZwiad, "")
	GUICtrlSetState($AttZwiad, $GUI_ENABLE)
	GUICtrlSetData($Attacks_Button_AllZwi, "MAX")
	GUICtrlSetData($AttLK, "")
	GUICtrlSetState($AttLK, $GUI_ENABLE)
	GUICtrlSetData($Attacks_Button_AllLK, "MAX")
	GUICtrlSetData($AttKLucz, "")
	GUICtrlSetState($AttKLucz, $GUI_ENABLE)
	GUICtrlSetData($Attacks_Button_AllLnK, "MAX")
	GUICtrlSetData($AttCK, "")
	GUICtrlSetState($AttCK, $GUI_ENABLE)
	GUICtrlSetData($Attacks_Button_AllCK, "MAX")
	GUICtrlSetData($AttTar, "")
	GUICtrlSetState($AttTar, $GUI_ENABLE)
	GUICtrlSetData($Attacks_Button_AllTar, "MAX")
	GUICtrlSetData($AttKat, "")
	GUICtrlSetState($AttKat, $GUI_ENABLE)
	GUICtrlSetData($Attacks_Button_AllKat, "MAX")
	GUICtrlSetData($AttRyc, "")
	GUICtrlSetState($AttRyc, $GUI_ENABLE)
	GUICtrlSetData($Attacks_Button_AllRyc, "MAX")
	GUICtrlSetData($AttSzl, "")
	GUICtrlSetState($AttSzl, $GUI_ENABLE)
	GUICtrlSetData($Attacks_Button_AllSzl, "MAX")
	GUICtrlSetData($Interwal, "2000/01/01 00:00:00")
	GUICtrlSetData($AttackType, "<ROZKAZ>", "<ROZKAZ>")
EndFunc   ;==>Clear

Func OptimalInterwal()
	$Opt += 1
	$OdlX = GUICtrlRead($Xa) - GUICtrlRead($Xb)
	If $OdlX < 0 Then $OdlX *= -1
	$OdlY = GUICtrlRead($Ya) - GUICtrlRead($Yb)
	If $OdlY < 0 Then $OdlY *= -1
	$Odl = ($OdlX * $OdlX) + ($OdlY * $OdlY)
	$Odl = Sqrt($Odl)
	If ((GUICtrlRead($AttZwiad) <> "" And GUICtrlRead($AttZwiad) <> 0) Or GUICtrlRead($AttZwiad) = "MAX") Then $slowest = IniRead($CDataINI, "UNITS", "Zwiad", "00:09:00")
	If ((GUICtrlRead($AttLK) <> "" And GUICtrlRead($AttLK) <> 0) Or GUICtrlRead($AttLK) = "MAX") Or _
			((GUICtrlRead($AttKLucz) <> "" And GUICtrlRead($AttKLucz) <> 0) Or GUICtrlRead($AttKLucz) = "MAX") Or _
			((GUICtrlRead($AttRyc) <> "" And GUICtrlRead($AttRyc) <> 0) Or GUICtrlRead($AttRyc) = "MAX") Then $slowest = IniRead($CDataINI, "UNITS", "LK", "00:10:00")
	If ((GUICtrlRead($AttCK) <> "" And GUICtrlRead($AttCK) <> 0) Or GUICtrlRead($AttCK) = "MAX") Then $slowest = IniRead($CDataINI, "UNITS", "CK", "00:11:00")
	If ((GUICtrlRead($AttPiki) <> "" And GUICtrlRead($AttPiki) <> 0) Or GUICtrlRead($AttPiki) = "MAX") Or _
			((GUICtrlRead($AttTopory) <> "" And GUICtrlRead($AttTopory) <> 0) Or GUICtrlRead($AttTopory) = "MAX") Or _
			((GUICtrlRead($AttLuki) <> "" And GUICtrlRead($AttLuki) <> 0) Or GUICtrlRead($AttLuki) = "MAX") Then $slowest = IniRead($CDataINI, "UNITS", "Pikinier", "00:18:00")
	If ((GUICtrlRead($AttMiecze) <> "" And GUICtrlRead($AttMiecze) <> 0) Or GUICtrlRead($AttMiecze) = "MAX") Then $slowest = IniRead($CDataINI, "UNITS", "Miecznik", "00:22:00")
	If ((GUICtrlRead($AttTar) <> "" And GUICtrlRead($AttTar) <> 0) Or GUICtrlRead($AttTar) = "MAX") Or _
			((GUICtrlRead($AttKat) <> "" And GUICtrlRead($AttKat) <> 0) Or GUICtrlRead($AttKat) = "MAX") Then $slowest = IniRead($CDataINI, "UNITS", "Taran", "00:30:00")
	If ((GUICtrlRead($AttSzl) <> "" And GUICtrlRead($AttSzl) <> 0) Or GUICtrlRead($AttSzl) = "MAX") Then $slowest = IniRead($CDataINI, "UNITS", "Szlachcic", "00:35:00")
	If GUICtrlRead($AttackType) == "Wsparcie" And ((GUICtrlRead($AttRyc) <> "" And GUICtrlRead($AttRyc) <> 0) Or GUICtrlRead($AttRyc) = "MAX") Then _
			$slowest = GUICtrlRead($RycSpd)
	$Czas = StringSplit($slowest, ":")
	$CzasP = (($Czas[1] * 3600 + $Czas[2] * 60 + $Czas[3]) * $Odl) * 2
	$CzasP = Round($CzasP)
	$CzasP += 10
	If $CzasP > 86389 Then
		GUICtrlSetData($Interwal, "2000/01/01 00:00:00")
		MsgBox(16, "Interwa≥", "Maksymalny interwa≥ to 23:59:59," & @CRLF & "Przekraczasz tÍ wartoúÊ!", 2)
	ElseIf $CzasP <= 86389 Then
		;				GUICtrlSetData($Interwal, "2000/01/01 00:00:00")
		$Inter = _DateAdd("s", $CzasP, "2000/01/01 00:00:00")
		GUICtrlSetData($Interwal, $Inter)
	EndIf
EndFunc   ;==>OptimalInterwal

Func AddAttack()
	$AttackError = 0
	$OdlX = GUICtrlRead($Xa) - GUICtrlRead($Xb)
	If $OdlX < 0 Then $OdlX *= -1
	;			MsgBox(0, Null, $OdlX)
	$OdlY = GUICtrlRead($Ya) - GUICtrlRead($Yb)
	If $OdlY < 0 Then $OdlY *= -1
	;			MsgBox(0, Null, $OdlY)
	$Odl = ($OdlX * $OdlX) + ($OdlY * $OdlY)
	;			MsgBox(0, Null, $Odl)
	$Odl = Sqrt($Odl)
	;			MsgBox(0, Null, $Odl)
	If ((GUICtrlRead($AttZwiad) <> "" And GUICtrlRead($AttZwiad) <> 0) Or GUICtrlRead($AttZwiad) = "MAX") Then $slowest = GUICtrlRead($ZwiSpd)
	If ((GUICtrlRead($AttLK) <> "" And GUICtrlRead($AttLK) <> 0) Or GUICtrlRead($AttLK) = "MAX") Or _
			((GUICtrlRead($AttKLucz) <> "" And GUICtrlRead($AttKLucz) <> 0) Or GUICtrlRead($AttKLucz) = "MAX") Or _
			((GUICtrlRead($AttRyc) <> "" And GUICtrlRead($AttRyc) <> 0) Or GUICtrlRead($AttRyc) = "MAX") Then $slowest = GUICtrlRead($LKSpd)
	If ((GUICtrlRead($AttCK) <> "" And GUICtrlRead($AttCK) <> 0) Or GUICtrlRead($AttCK) = "MAX") Then $slowest = GUICtrlRead($CKSpd)
	If ((GUICtrlRead($AttPiki) <> "" And GUICtrlRead($AttPiki) <> 0) Or GUICtrlRead($AttPiki) = "MAX") Or _
			((GUICtrlRead($AttTopory) <> "" And GUICtrlRead($AttTopory) <> 0) Or GUICtrlRead($AttTopory) = "MAX") Or _
			((GUICtrlRead($AttLuki) <> "" And GUICtrlRead($AttLuki) <> 0) Or GUICtrlRead($AttLuki) = "MAX") Then $slowest = GUICtrlRead($PikSpd)
	If ((GUICtrlRead($AttMiecze) <> "" And GUICtrlRead($AttMiecze) <> 0) Or GUICtrlRead($AttMiecze) = "MAX") Then $slowest = GUICtrlRead($MieSpd)
	If ((GUICtrlRead($AttTar) <> "" And GUICtrlRead($AttTar) <> 0) Or GUICtrlRead($AttTar) = "MAX") Or _
			((GUICtrlRead($AttKat) <> "" And GUICtrlRead($AttKat) <> 0) Or GUICtrlRead($AttKat) = "MAX") Then $slowest = GUICtrlRead($TarSpd)
	If ((GUICtrlRead($AttSzl) <> "" And GUICtrlRead($AttSzl) <> 0) Or GUICtrlRead($AttSzl) = "MAX") Then $slowest = GUICtrlRead($SzlSpd)
	If GUICtrlRead($AttackType) == "Wsparcie" And ((GUICtrlRead($AttRyc) <> "" And GUICtrlRead($AttRyc) <> 0) Or GUICtrlRead($AttRyc) = "MAX") Then _
			$slowest = GUICtrlRead($RycSpd)
	$Czas = StringSplit($slowest, ":")
	$CzasP = ($Czas[1] * 3600 + $Czas[2] * 60 + $Czas[3]) * $Odl
	$CzasP = Round($CzasP)
	;			MsgBox(0, Null, $CzasP)
	$CzasP = _DateAdd('s', -$CzasP, GUICtrlRead($AttDate) & " " & GUICtrlRead($AttTime))
	;			MsgBox(0, Null, $CzasP)
	;			$pFileTime1 = DllStructGetPtr($CzasP)
	;			$pFileTime2 = DllStructGetPtr($Date&" "&$Time)
	;			MsgBox(0, "", _DateDiff('s', $CzasP, $Date&" "&$Time))
	If _DateDiff('s', $CzasP, $Date & " " & $Time) < -5 Then
		$DateError = 0
		;			MsgBox(0, "", GUICtrlRead($AttDate))
		;			MsgBox(0, "", GUICtrlRead($AttTime))
		;			$CzasP = StringSplit($CzasP, " ")
		;			MsgBox(0, "", $CzasP)
		If GUICtrlRead($AttPiki) = "" Then GUICtrlSetData($AttPiki, "0")
		If GUICtrlRead($AttMiecze) = "" Then GUICtrlSetData($AttMiecze, "0")
		If GUICtrlRead($AttTopory) = "" Then GUICtrlSetData($AttTopory, "0")
		If GUICtrlRead($AttLuki) = "" Then GUICtrlSetData($AttLuki, "0")
		If GUICtrlRead($AttZwiad) = "" Then GUICtrlSetData($AttZwiad, "0")
		If GUICtrlRead($AttLK) = "" Then GUICtrlSetData($AttLK, "0")
		If GUICtrlRead($AttKLucz) = "" Then GUICtrlSetData($AttKLucz, "0")
		If GUICtrlRead($AttCK) = "" Then GUICtrlSetData($AttCK, "0")
		If GUICtrlRead($AttTar) = "" Then GUICtrlSetData($AttTar, "0")
		If GUICtrlRead($AttKat) = "" Then GUICtrlSetData($AttKat, "0")
		If GUICtrlRead($AttRyc) = "" Then GUICtrlSetData($AttRyc, "0")
		If GUICtrlRead($AttSzl) = "" Then GUICtrlSetData($AttSzl, "0")
		$ChoseVillage = StringSplit(GUICtrlRead($Villages), "†")
		$ChoseVill = StringReplace($ChoseVillage[2], "I", "l")

		$AttacksCount += 1
		If $Edit = 0 Then IniWrite($CDataINI, "STATUS", "Count", $AttacksCount)
		GUICtrlCreateListViewItem($AttacksCount & "|" & GUICtrlRead($IDa) & "|" & GUICtrlRead($AttackType) & "|" & _
				GUICtrlRead($Interwal) & "|W£•CZONY|" & $CzasP & "|" & StringReplace(GUICtrlRead($AttDate), "-", "/") & " " & GUICtrlRead($AttTime) & "|" & _
				$ChoseVill & "|" & GUICtrlRead($Xb) & "|" & GUICtrlRead($Yb) & "|" & GUICtrlRead($AttPiki) & "|" & GUICtrlRead($AttMiecze) & "|" & _
				GUICtrlRead($AttTopory) & "|" & GUICtrlRead($AttLuki) & "|" & GUICtrlRead($AttZwiad) & "|" & GUICtrlRead($AttLK) & "|" & GUICtrlRead($AttKLucz) & "|" & _
				GUICtrlRead($AttCK) & "|" & GUICtrlRead($AttTar) & "|" & GUICtrlRead($AttKat) & "|" & GUICtrlRead($AttRyc) & "|" & GUICtrlRead($AttSzl), $AttacksList)
		GUICtrlSetBkColor(-1, $AttON)

		_GUICtrlListView_SetItemGroupID($AttacksList, _GUICtrlListView_GetItemCount($AttacksList) - 1, $AttacksListON)
		_GUICtrlListView_SetColumn($AttacksList, 0, "ID", 0)
		_GUICtrlListView_SetColumn($AttacksList, 1, "Village ID", 0)
		_GUICtrlListView_SetColumn($AttacksList, 4, "AktywnoúÊ", 0)
		_GUICtrlListView_RegisterSortCallBack($AttacksList)
		_GUICtrlListView_SortItems($AttacksList, 5)
		_GUICtrlListView_UnRegisterSortCallBack($AttacksList)
		$Set = 0
		IniWrite($CDataINI, $AttacksCount, "Count", $AttacksCount)
		IniWrite($CDataINI, $AttacksCount, "VillageID", GUICtrlRead($IDa))
		IniWrite($CDataINI, $AttacksCount, "Type", GUICtrlRead($AttackType))
		IniWrite($CDataINI, $AttacksCount, "Interwal", GUICtrlRead($Interwal))
		IniWrite($CDataINI, $AttacksCount, "Active", "W£•CZONY")
		IniWrite($CDataINI, $AttacksCount, "Launch", $CzasP)
		IniWrite($CDataINI, $AttacksCount, "Land", StringReplace(GUICtrlRead($AttDate), "-", "/") & " " & GUICtrlRead($AttTime))
		IniWrite($CDataINI, $AttacksCount, "StartV", $ChoseVill)
		IniWrite($CDataINI, $AttacksCount, "TargetX", GUICtrlRead($Xb))
		IniWrite($CDataINI, $AttacksCount, "TargetY", GUICtrlRead($Yb))
		IniWrite($CDataINI, $AttacksCount, "Pik", GUICtrlRead($AttPiki))
		IniWrite($CDataINI, $AttacksCount, "Mie", GUICtrlRead($AttMiecze))
		IniWrite($CDataINI, $AttacksCount, "Top", GUICtrlRead($AttTopory))
		IniWrite($CDataINI, $AttacksCount, "Luk", GUICtrlRead($AttLuki))
		IniWrite($CDataINI, $AttacksCount, "Zwi", GUICtrlRead($AttZwiad))
		IniWrite($CDataINI, $AttacksCount, "LK", GUICtrlRead($AttLK))
		IniWrite($CDataINI, $AttacksCount, "LnK", GUICtrlRead($AttKLucz))
		IniWrite($CDataINI, $AttacksCount, "CK", GUICtrlRead($AttCK))
		IniWrite($CDataINI, $AttacksCount, "Tar", GUICtrlRead($AttTar))
		IniWrite($CDataINI, $AttacksCount, "Kat", GUICtrlRead($AttKat))
		IniWrite($CDataINI, $AttacksCount, "Ryc", GUICtrlRead($AttRyc))
		IniWrite($CDataINI, $AttacksCount, "Szl", GUICtrlRead($AttSzl))
		;			GUICtrlSetData($Att1, GUICtrlRead($AttackType)&"|"&GUICtrlRead($Interwal)&"|"&"W£•CZONY"&"|"&$CzasP&"|"&StringReplace(GUICtrlRead($AttDate), "-", "/")&" "&GUICtrlRead($AttTime)&"|"&$ChoseVill&"|"&GUICtrlRead($Xb)&"|"&GUICtrlRead($Yb)& _
		;			"|"&GUICtrlRead($AttPiki)&"|"&GUICtrlRead($AttMiecze)&"|"&GUICtrlRead($AttTopory)&"|"&GUICtrlRead($AttLuki)&"|"&GUICtrlRead($AttZwiad)&"|"& _
		;			GUICtrlRead($AttLK)&"|"&GUICtrlRead($AttKLucz)&"|"&GUICtrlRead($AttCK)&"|"&GUICtrlRead($AttTar)&"|"&GUICtrlRead($AttKat)&"|"&GUICtrlRead($AttRyc)&"|"& _
		;			GUICtrlRead($AttSzl))
		If $Edit = 0 Then LogWrite("Dodano nowy atak na koncie " & GUICtrlRead($Login) & " (" & GUICtrlRead($Worlds) & ")")
		If _IsChecked($AttackClear) Or $Edit = 1 Then
			GUICtrlSetData($Villages, "Wszystkie wioski (" & $Village[0][0] & ")", "Wszystkie wioski (" & $Village[0][0] & ")")
			GUICtrlSetData($Xb, "")
			GUICtrlSetData($Yb, "")
			GUICtrlSetData($AttDate, @YEAR & "/" & @MON & "/" & @MDAY)
			GUICtrlSetData($AttTime, @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC)
			GUICtrlSetData($AttPiki, "")
			GUICtrlSetState($AttPiki, $GUI_ENABLE)
			GUICtrlSetData($Attacks_Button_AllPik, "MAX")
			GUICtrlSetData($AttMiecze, "")
			GUICtrlSetState($AttMiecze, $GUI_ENABLE)
			GUICtrlSetData($Attacks_Button_AllMie, "MAX")
			GUICtrlSetData($AttTopory, "")
			GUICtrlSetState($AttTopory, $GUI_ENABLE)
			GUICtrlSetData($Attacks_Button_AllTop, "MAX")
			GUICtrlSetData($AttLuki, "")
			GUICtrlSetState($AttLuki, $GUI_ENABLE)
			GUICtrlSetData($Attacks_Button_AllLuk, "MAX")
			GUICtrlSetData($AttZwiad, "")
			GUICtrlSetState($AttZwiad, $GUI_ENABLE)
			GUICtrlSetData($Attacks_Button_AllZwi, "MAX")
			GUICtrlSetData($AttLK, "")
			GUICtrlSetState($AttLK, $GUI_ENABLE)
			GUICtrlSetData($Attacks_Button_AllLK, "MAX")
			GUICtrlSetData($AttKLucz, "")
			GUICtrlSetState($AttKLucz, $GUI_ENABLE)
			GUICtrlSetData($Attacks_Button_AllLnK, "MAX")
			GUICtrlSetData($AttCK, "")
			GUICtrlSetState($AttCK, $GUI_ENABLE)
			GUICtrlSetData($Attacks_Button_AllCK, "MAX")
			GUICtrlSetData($AttTar, "")
			GUICtrlSetState($AttTar, $GUI_ENABLE)
			GUICtrlSetData($Attacks_Button_AllTar, "MAX")
			GUICtrlSetData($AttKat, "")
			GUICtrlSetState($AttKat, $GUI_ENABLE)
			GUICtrlSetData($Attacks_Button_AllKat, "MAX")
			GUICtrlSetData($AttRyc, "")
			GUICtrlSetState($AttRyc, $GUI_ENABLE)
			GUICtrlSetData($Attacks_Button_AllRyc, "MAX")
			GUICtrlSetData($AttSzl, "")
			GUICtrlSetState($AttSzl, $GUI_ENABLE)
			GUICtrlSetData($Attacks_Button_AllSzl, "MAX")
			GUICtrlSetData($Interwal, "2000/01/01 00:00:00")
			GUICtrlSetData($AttackType, "<ROZKAZ>", "<ROZKAZ>")
		EndIf
		$Added = 1
	ElseIf _DateDiff('s', $CzasP, $Date & " " & $Time) > -5 Then
		$DateError = 1
	EndIf
EndFunc   ;==>AddAttack

Func _IsChecked($idControlID)
	Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked

Func Login()
	GUISetState(@SW_SHOW, $LoginGUI)
	GUISetState(@SW_DISABLE, $MainGUI)
	WinSetTitle($LoginGUI, "", "ProszÍ czekaÊ, trwa logowanie...")
	If _IEPropertyGet($oIE, "locationurl") <> "http://www." & GUICtrlRead($Country) Then _IENavigate($oIE, "http://www." & GUICtrlRead($Country), 1)
	Local $oForm = _IEFormGetCollection($oIE, 0)
	Local $oUser = _IEFormElementGetObjByName($oForm, "user") ;login
	Local $oPass = _IEFormElementGetObjByName($oForm, "password") ;haslo
	Local $oRem = _IEFormElementGetObjByName($oForm, "cookie") ;zapamietanie
	_IEFormElementSetValue($oUser, GUICtrlRead($Login))
	_IEFormElementSetValue($oPass, GUICtrlRead($Password))
	If GUICtrlRead($GUI_CheckBox_Remember) - 4 = 0 Then _IEFormElementCheckBoxSelect($oForm, 0, "", 0, "byIndex")
	If GUICtrlRead($GUI_CheckBox_Remember) = 1 Then _IEFormElementCheckBoxSelect($oForm, 0, "", 1, "byIndex")
	Local $oSend = _IEGetObjById($oForm, "login_submit_button")
	_IEAction($oSend, "Click")
	_IELoadWait($oIE, 500)
	$cWorld = StringReplace(GUICtrlRead($Worlds), "åwiat ", "")
	_IENavigate($oIE, "javascript" & Chr(0x3a) & "Index.submit_login('server_pl" & $cWorld & "');")
	_IELoadWait($oIE)
	_IENavigate($oIE0, _IEPropertyGet($oIE, "locationurl"))
	Captcha()
	;GUICtrlSetStyle($GUI_Button_Villages, "")
	GUISetState(@SW_HIDE, $LoginGUI)
	GUISetState(@SW_ENABLE, $MainGUI)
	GUISetState(@SW_HIDE, $MainGUI)
	GUISetState(@SW_SHOW, $MainGUI)
EndFunc   ;==>Login

Func Hide()
	If $Hide > 0 Then
		For $i = 0 To UBound($H) - 1
			Assign("Pos" & $i, ControlGetPos("", "", $H[$i]))
			GUICtrlSetPos($H[$i], Eval("Pos" & $i)[0], Eval("Pos" & $i)[1] - $Hide)
		Next
		For $i = 0 To UBound($Hi) - 1
			Assign("Poss" & $i, ControlGetPos("", "", $Hi[$i]))
			GUICtrlSetPos($Hi[$i], Eval("Poss" & $i)[0], Eval("Poss" & $i)[1] - $Hide, Eval("Poss" & $i)[2], Eval("Poss" & $i)[3] + $Hide)
		Next
		$PosIE = ControlGetPos("", "", "[CLASS:Shell Embedding; INSTANCE:1]")
		GUICtrlSetPos($IE0, $PosIE[0], $PosIE[1] - $Hide, $PosIE[2], $PosIE[3] + $Hide)
	EndIf
	If $Hide = 0 Then
		For $i = 0 To UBound($H) - 1
			$aPos = ControlGetPos("", "", $H[$i])
			GUICtrlSetPos($H[$i], $aPos[0], Eval("Pos" & $i)[1])
		Next
		For $i = 0 To UBound($Hi) - 1
			$aPoss = ControlGetPos("", "", $Hi[$i])
			GUICtrlSetPos($Hi[$i], $aPoss[0], Eval("Poss" & $i)[1], $aPoss[2], $aPoss[3] - 145)
		Next
		$PossIE = ControlGetPos("", "", "[CLASS:Shell Embedding; INSTANCE:1]")
		GUICtrlSetPos($IE0, $PossIE[0], $PosIE[1], $PossIE[2], $PossIE[3] - 145)
	EndIf
	$Pos = ControlGetPos("", "", $GUI_Button_Show)
	GUICtrlSetPos($GUI_Button_Show, $Pos[0], -116 + $Hide1)
	$Pos = ControlGetPos("", "", $Synchro)
	GUICtrlSetPos($Synchro, $Pos[0], 127 - $Hide1)
	$Pos = ControlGetPos("", "", $TimeS)
	GUICtrlSetPos($TimeS, $Pos[0], 127 - $Hide1)
	GUISetState(@SW_HIDE, $MainGUI)
	GUISetState(@SW_SHOW, $MainGUI)
EndFunc   ;==>Hide

Func Villages_list()
	GUISetState(@SW_DISABLE, $MainGUI)
	GUISetState(@SW_SHOW, $LoginGUI)
	WinSetTitle($LoginGUI, "", "ProszÍ czekaÊ, trwa pobieranie listy wiosek...")
	_IENavigate($oIE, "pl" & $cWorld & "." & GUICtrlRead($Country) & "/game.php?screen=info_player")
	_IELoadWait($oIE)
	$table1 = _IEGetObjById($oIE, "villages_list")
	$Village = _IETableWriteToArray($table1)
	$Village[0][0] = StringReplace($Village[0][0], "Wioski (", "")
	$Village[0][0] = StringReplace($Village[0][0], ")", "")
	If $Village[0][0] > 100 Then
		_IENavigate($oIE, "javascript" & Chr(0x3a) & "Player.getAllVillages(this, '/game.php?village=39534&ajax=fetch_villages&player_id=698281635&screen=info_player');", 0)
		While 1
			$table1 = _IEGetObjById($oIE, "villages_list")
			$Village = _IETableWriteToArray($table1)
			$Village[0][0] = StringReplace($Village[0][0], "Wioski (", "")
			$Village[0][0] = StringReplace($Village[0][0], ")", "")
			_ArrayColDelete($Village, 101)
			If _ArrayColDelete($Village, $Village[0][0]) = -1 Then
				_ArrayDelete($Village, "0;3")
				;		MsgBox(0, Null, "Czekam")
			Else
				;		MsgBox(0, Null, "Nie czekam")
				_ArrayDelete($Village, "0;3")
				$table1 = _IEGetObjById($oIE, "villages_list")
				$Village = _IETableWriteToArray($table1)
				$Village[0][0] = StringReplace($Village[0][0], "Wioski (", "")
				$Village[0][0] = StringReplace($Village[0][0], ")", "")
				_ArrayColDelete($Village, 101)
				ExitLoop
			EndIf
		WEnd
	EndIf
	_ArrayInsert($Village, 2, "Wsp. Y")
	$Village[3][0] = "ID"
	;Zarzπdzanie listπ wiosek nizej!
	For $LP = 1 To $Village[0][0] Step 1
		Local $aCoord = StringSplit($Village[1][$LP], "|")
		$Village[1][$LP] = $aCoord[1]
		$Village[2][$LP] = $aCoord[2]
		Local $Kx, $Ky
		If $Village[2][$LP] < 100 Then $Ky = ""
		If $Village[2][$LP] > 100 Then $Ky = "1"
		If $Village[2][$LP] > 200 Then $Ky = "2"
		If $Village[2][$LP] > 300 Then $Ky = "3"
		If $Village[2][$LP] > 400 Then $Ky = "4"
		If $Village[2][$LP] > 500 Then $Ky = "5"
		If $Village[2][$LP] > 600 Then $Ky = "6"
		If $Village[2][$LP] > 700 Then $Ky = "7"
		If $Village[2][$LP] > 800 Then $Ky = "8"
		If $Village[2][$LP] > 900 Then $Ky = "9"

		If $Village[1][$LP] < 100 Then $Kx = "0"
		If $Village[1][$LP] > 100 Then $Kx = "1"
		If $Village[1][$LP] > 200 Then $Kx = "2"
		If $Village[1][$LP] > 300 Then $Kx = "3"
		If $Village[1][$LP] > 400 Then $Kx = "4"
		If $Village[1][$LP] > 500 Then $Kx = "5"
		If $Village[1][$LP] > 600 Then $Kx = "6"
		If $Village[1][$LP] > 700 Then $Kx = "7"
		If $Village[1][$LP] > 800 Then $Kx = "8"
		If $Village[1][$LP] > 900 Then $Kx = "9"
		Local $Village_List
		$Village_List = $Village_List & $LP & ".†" & $Village[0][$LP] & "(" & $Village[1][$LP] & "I" & $Village[2][$LP] & ") K" & $Ky & $Kx & "|"
	Next
	GUICtrlSetData($Villages, "")
	GUICtrlSetData($Villages, "Wszystkie wioski (" & $Village[0][0] & ")", "Wszystkie wioski (" & $Village[0][0] & ")")
	GUICtrlSetData($Villages, $Village_List, "Wszystkie wioski (" & $Village[0][0] & ")")
	GUICtrlSetStyle($Villages, "")

	If $Village[0][0] > 1 Then
		GUICtrlSetData($nVillages, "")
		GUICtrlSetData($nVillages, "Wszystkie wioski (" & $Village[0][0] & ")", "Wszystkie wioski (" & $Village[0][0] & ")")
		GUICtrlSetData($nVillages, $Village_List, "Wszystkie wioski (" & $Village[0][0] & ")")
		GUICtrlSetStyle($nVillages, "")
		GUICtrlSetStyle($NAVIGATE_Button_Zmien, "")
		GUICtrlSetStyle($NAVIGATE_Button_Prev, "")
		GUICtrlSetStyle($NAVIGATE_Button_Next, "")
	ElseIf $Village[0][0] = 1 Then
		GUICtrlSetData($nVillages, "")
		GUICtrlSetData($nVillages, "Posiadasz tylko jednπ wioskÍ!", "Posiadasz tylko jednπ wioskÍ!")
		GUICtrlSetData($PrevVillage, "Posiadasz tylko jednπ wioskÍ!")
		GUICtrlSetData($NextVillage, "Posiadasz tylko jednπ wioskÍ!")
	EndIf

	$Village[1][0] = "X"
	$Village[2][0] = "Y"
	LogWrite("Pobrano listÍ wiosek konta " & GUICtrlRead($Login) & " (" & GUICtrlRead($Worlds) & ")")

	Local $oLinks = _IELinkGetCollection($table1)
	Local $iNumLinks = @extended
	Local $sSearch = "&screen=info_village&id="
	Local $sTxt = $iNumLinks & " links found" & @CRLF & @CRLF
	$LP = 0
	For $oLink In $oLinks
		;$sTxt &= $oLink.href & @CRLF ;DEBUG LINK”W
		;ClipPut($sTxt)
		If StringInStr($oLink.href, $sSearch) Then
			;If StringLen($sSearch) znakÛw z prawej strony stringu $oLink.href jest rÛwne $sSearch Then ...
			$LP += 1
			;		$sTxt &= $oLink.href & @CRLF
			$ID = $oLink.href
			$IDv1 = StringSplit($ID, "id=", 1)
			;_ArrayDisplay($IDv1) ;DEBUG POCI TEGO LINKU Z ID
			;$IDv2 = StringSplit($IDv1[3], "&")
			$Village[3][$LP] = $IDv1[2]
		EndIf
	Next
	_IEAction($oIE, "Back")
	_IELoadWait($oIE)
	GUISetState(@SW_HIDE, $LoginGUI)
	GUISetState(@SW_ENABLE, $MainGUI)
	GUISetState(@SW_HIDE, $MainGUI)
	GUISetState(@SW_SHOW, $MainGUI)
	;	_ArrayDisplay($Village) ;DEBUG POBIERANIA LISTY WIOSEK
EndFunc   ;==>Villages_list

Func Zmiana()
	$c1ID = StringSplit(_IEPropertyGet($oIE0, "locationurl"), "=")
	$cID = StringSplit($c1ID[2], "&")
	;	_ArrayDisplay($cID)
	If GUICtrlRead($IDn) <> $cID[1] And GUICtrlRead($nVillages) <> "Wszystkie wioski (0)" And GUICtrlRead($nVillages) <> "Wszystkie wioski (" & $Village[0][0] & ")" Then
		Local $link
		$link = StringReplace(_IEPropertyGet($oIE0, "locationurl"), "village=" & $cID[1], "village=" & GUICtrlRead($IDn))
		_IENavigate($oIE0, $link)
	EndIf
EndFunc   ;==>Zmiana

Func CloseNawigacja()
	GUISetState(@SW_HIDE, $NavGUI)
EndFunc   ;==>CloseNawigacja

Func PrevVill()
	Local $link
	$z = 0
	$L1 = StringSplit(_IEPropertyGet($oIE0, "locationurl"), "=")
	$L2 = StringSplit($L1[2], "&")
	If StringLeft($L2[1], 1) == "p" And $z = 0 Then
		;		MsgBox(0, "", "P!")
		$z += 1
		$L2[1] = StringReplace($L2[1], "p", "")
		$L2[1] = StringReplace($L2[1], "p", "")
		$cVill = _ArraySearch($Village, $L2[1], 0, 0, 0, 0, 1, 3, True)
		If $cVill > 0 Then
			If $cVill = 2 Then
				$link = StringReplace(_IEPropertyGet($oIE0, "locationurl"), "village=p" & $L2[1], "village=" & $Village[3][$Village[0][0]])
				_IENavigate($oIE0, $link)
			EndIf
			If $cVill = 1 Then
				$link = StringReplace(_IEPropertyGet($oIE0, "locationurl"), "village=p" & $L2[1], "village=" & $Village[3][$Village[0][0] - 1])
				_IENavigate($oIE0, $link)
			ElseIf $cVill <> 1 And $cVill <> 2 Then
				$link = StringReplace(_IEPropertyGet($oIE0, "locationurl"), "village=p" & $L2[1], "village=" & $Village[3][$cVill - 2])
				_IENavigate($oIE0, $link)
			EndIf
			;	MsgBox(0, "", $cVill)
		EndIf
	EndIf

	If StringLeft($L2[1], 1) == "n" And $z = 0 Then
		;		MsgBox(0, "", "N!")
		$z += 1
		$L2[1] = StringReplace($L2[1], "n", "")
		$cVill = _ArraySearch($Village, $L2[1], 0, 0, 0, 0, 1, 3, True)
		If $cVill > 0 Then
			If $cVill = $Village[0][0] Then
				$link = StringReplace(_IEPropertyGet($oIE0, "locationurl"), "village=n" & $L2[1], "village=" & $Village[3][$Village[0][0]])
				_IENavigate($oIE0, $link)
			ElseIf $cVill <> $Village[0][0] Then
				$link = StringReplace(_IEPropertyGet($oIE0, "locationurl"), "village=n" & $L2[1], "village=" & $Village[3][$cVill])
				_IENavigate($oIE0, $link)
			EndIf
			;	MsgBox(0, "", $cVill)
		EndIf
	EndIf

	If StringLeft($L2[1], 1) <> "n" And StringLeft($L2[1], 1) <> "p" And $z = 0 Then
		;		MsgBox(0, "", "Normalnie")
		$z += 1
		$cVill = _ArraySearch($Village, $L2[1], 0, 0, 0, 0, 1, 3, True)
		If $cVill > 0 Then
			If $cVill = 1 Then
				$link = StringReplace(_IEPropertyGet($oIE0, "locationurl"), "village=" & $L2[1], "village=" & $Village[3][$Village[0][0]])
				_IENavigate($oIE0, $link)
			ElseIf $cVill <> 1 Then
				$link = StringReplace(_IEPropertyGet($oIE0, "locationurl"), "village=" & $L2[1], "village=" & $Village[3][$cVill - 1])
				_IENavigate($oIE0, $link)
			EndIf
			;	MsgBox(0, "", $cVill)
		EndIf
	EndIf
EndFunc   ;==>PrevVill

Func NextVill()
	Local $link
	$z = 0
	$L1 = StringSplit(_IEPropertyGet($oIE0, "locationurl"), "=")
	$L2 = StringSplit($L1[2], "&")
	If StringLeft($L2[1], 1) == "p" And $z = 0 Then
		;		MsgBox(0, "", "P!")
		$z += 1
		$L2[1] = StringReplace($L2[1], "p", "")
		$L2[1] = StringReplace($L2[1], "p", "")
		$cVill = _ArraySearch($Village, $L2[1], 0, 0, 0, 0, 1, 3, True)
		If $cVill > 0 Then
			If $cVill = 1 Then
				$link = StringReplace(_IEPropertyGet($oIE0, "locationurl"), "village=p" & $L2[1], "village=" & $Village[3][1])
				_IENavigate($oIE0, $link)
			ElseIf $cVill <> 1 Then
				$link = StringReplace(_IEPropertyGet($oIE0, "locationurl"), "village=p" & $L2[1], "village=" & $Village[2][$cVill])
				_IENavigate($oIE0, $link)
			EndIf
			;	MsgBox(0, "", $cVill)
		EndIf
	EndIf

	If StringLeft($L2[1], 1) == "n" And $z = 0 Then
		;		MsgBox(0, "", "N!")
		$z += 1
		$L2[1] = StringReplace($L2[1], "n", "")
		$cVill = _ArraySearch($Village, $L2[1], 0, 0, 0, 0, 1, 3, True)
		If $cVill > 0 Then
			If $cVill = $Village[0][0] - 1 Then
				$link = StringReplace(_IEPropertyGet($oIE0, "locationurl"), "village=n" & $L2[1], "village=" & $Village[3][1])
				_IENavigate($oIE0, $link)
			ElseIf $cVill = $Village[0][0] Then
				$link = StringReplace(_IEPropertyGet($oIE0, "locationurl"), "village=n" & $L2[1], "village=" & $Village[2][2])
				_IENavigate($oIE0, $link)
			ElseIf $cVill <> $Village[0][0] - 1 And $cVill <> $Village[0][0] Then
				$link = StringReplace(_IEPropertyGet($oIE0, "locationurl"), "village=n" & $L2[1], "village=" & $Village[2][$cVill + 2])
				_IENavigate($oIE0, $link)
			EndIf
			;	MsgBox(0, "", $cVill)
		EndIf
	EndIf

	If StringLeft($L2[1], 1) <> "n" And StringLeft($L2[1], 1) <> "p" And $z = 0 Then
		;		MsgBox(0, "", "Normalnie")
		$z += 1
		$cVill = _ArraySearch($Village, $L2[1], 0, 0, 0, 0, 1, 3, True)
		If $cVill > 0 Then
			If $cVill = $Village[0][0] Then
				$link = StringReplace(_IEPropertyGet($oIE0, "locationurl"), "village=" & $L2[1], "village=" & $Village[3][1])
				_IENavigate($oIE0, $link)
			ElseIf $cVill <> $Village[0][0] Then
				$link = StringReplace(_IEPropertyGet($oIE0, "locationurl"), "village=" & $L2[1], "village=" & $Village[3][$cVill + 1])
				_IENavigate($oIE0, $link)
			EndIf
			;	MsgBox(0, "", $cVill)
		EndIf
	EndIf
EndFunc   ;==>NextVill

Func CopyXY()
	$table2 = _IEGetObjById($oIE0, "contentContainer")
	$Copy = _IETableWriteToArray($table2)
	$Copy1 = StringSplit($Copy[0][0], "|")
	If StringRight($Copy1[1], 1) >= 0 Then $CopyX = StringRight($Copy1[1], 1)
	If StringRight($Copy1[1], 2) >= 10 Then $CopyX = StringRight($Copy1[1], 2)
	If StringRight($Copy1[1], 3) >= 100 Then $CopyX = StringRight($Copy1[1], 3)
	If StringLeft($Copy1[2], 1) >= 0 Then $CopyY = StringLeft($Copy1[2], 1)
	If StringLeft($Copy1[2], 2) >= 10 Then $CopyY = StringLeft($Copy1[2], 2)
	If StringLeft($Copy1[2], 3) >= 100 Then $CopyY = StringLeft($Copy1[2], 3)
	GUICtrlSetData($CopyXY, "(" & $CopyX & "|" & $CopyY & ")")
	GUICtrlSetData($Attacks_Button_Paste, "Wklej (" & $CopyX & "|" & $CopyY & ")")
	If $PasteTrue = 0 Then $PasteTrue = 1
	;MsgBox(0, "", "("&$CopyX&"|"&$CopyY&")")
EndFunc   ;==>CopyXY

Func STime()
	GUISetState(@SW_DISABLE, $MainGUI)
	GUISetState(@SW_SHOW, $LoginGUI)
	WinSetTitle($LoginGUI, "", "ProszÍ czekaÊ, trwa synchronizowanie czasu serwerowego...")
	$Sync += 1
	$Time = _IEGetObjById($oIE, "serverTime")
	If Not IsObj($Time) Then MsgBox(16, "B≥πd", "Wykryty b≥πd w synchronizacji czasu serwera!" & @CRLF & "Program zostanie wy≥πczony za 5 sekund.", 5)
	$Time = $Time.innertext
	GUICtrlSetData($TimeS, "Czas serwerowy:  " & $Time)
	GUICtrlSetData($Synchro, "ZSYNCHRONIZOWANY")

	$SDate = _IEGetObjById($oIE, "serverDate")
	$SDate1 = $SDate.innertext
	Local $DateStop
	$DateStop = $SDate1
	$Date1 = StringSplit($SDate1, "/")
	$Date = $Date1[3] & "/" & $Date1[2] & "/" & $Date1[1]
	GUISetState(@SW_HIDE, $LoginGUI)
	GUISetState(@SW_ENABLE, $MainGUI)
	GUISetState(@SW_HIDE, $MainGUI)
	GUISetState(@SW_SHOW, $MainGUI)
	LogWrite("Pobrano czas serwerowy")
EndFunc   ;==>STime

Func Stop()
	$Sync = 0
	$AttacksON = 0
	GUISetState(@SW_HIDE, $SessGUI)
	GUISetState(@SW_ENABLE, $MainGUI)
	GUICtrlSetData($Synchro, "NIEZSYNCHRONIZOWANY")
	GUICtrlSetData($TimeS, "Czas serwerowy:  00:00:00")
	$Village_List = "Wszystkie wioski (0)"
	GUICtrlSetData($Villages, "")
	GUICtrlSetData($Villages, $Village_List, "Wszystkie wioski (0)")
	GUICtrlSetData($nVillages, "")
	GUICtrlSetData($nVillages, $Village_List, "Wszystkie wioski (0)")
	GUICtrlSetData($PrevVillage, "---")
	GUICtrlSetData($NextVillage, "---")
	GUICtrlSetData($AttacksA, "Ataki: -")
	GUICtrlSetData($AttacksF, "Wy≥πczone: -")
	GUICtrlSetData($AttacksN, "W≥πczone: -")
	Local $all[3] = [0, 1, 2]
	_ArrayDelete($Village, $all)
	$CopyX = "XXX"
	$CopyY = "YYY"
	$Stop = 0
	GUICtrlSetData($CopyXY, "(" & $CopyX & "|" & $CopyY & ")")
	;			GUICtrlSetStyle($GUI_Button_Villages, $WS_DISABLED)
	GUICtrlSetStyle($Villages, $WS_DISABLED)
	GUICtrlSetStyle($nVillages, $WS_DISABLED)
	GUICtrlSetStyle($NAVIGATE_Button_Add, $WS_DISABLED)
	GUICtrlSetStyle($NAVIGATE_Button_Copy, $WS_DISABLED)
	GUICtrlSetStyle($NAVIGATE_Button_Next, $WS_DISABLED)
	GUICtrlSetStyle($NAVIGATE_Button_Prev, $WS_DISABLED)
	GUICtrlSetStyle($NAVIGATE_Button_Zmien, $WS_DISABLED)
	GUICtrlSetStyle($NAVIGATE_Button_Villages, $WS_DISABLED)
	$Work = 0
	LogWrite("Przerwano dzia≥anie TW Master bota na koncie " & GUICtrlRead($Login) & " (" & GUICtrlRead($Worlds) & ")")
	TraySetState(1)
	TraySetToolTip("TW Master Bot v" & $cVersion)
	If $InTray = 0 Then TraySetState(2)
	GUICtrlSetStyle($GUI_Button_Start, "")
	GUICtrlSetStyle($Worlds, "")
	GUICtrlSetStyle($GUI_Button_Add, "")
	GUICtrlSetStyle($GUI_Button_Delete, "")
	GUICtrlSetStyle($Login, "")
	GUICtrlSetStyle($Password, "")
	GUICtrlSetStyle($GUI_Button_Use, "")
	GUICtrlSetStyle($GUI_Button_Apply, "")
	GUICtrlSetStyle($Country, "")
	GUICtrlSetStyle($GUI_Button_Stop, $WS_DISABLED)
	GUICtrlSetStyle($Xb, $WS_DISABLED)
	GUICtrlSetStyle($Yb, $WS_DISABLED)
	GUICtrlSetData($Xb, "")
	GUICtrlSetData($Yb, "")
	GUICtrlSetState($AttDate, $GUI_DISABLE)
	GUICtrlSetData($AttDate, @YEAR & "/" & @MON & "/" & @MDAY)
	GUICtrlSetState($AttTime, $GUI_DISABLE)
	GUICtrlSetData($AttTime, "2009/10/03 00:00:00")
	GUICtrlSetState($AttPiki, $GUI_DISABLE)
	GUICtrlSetState($AttMiecze, $GUI_DISABLE)
	GUICtrlSetState($AttTopory, $GUI_DISABLE)
	GUICtrlSetState($AttLuki, $GUI_DISABLE)
	GUICtrlSetState($AttZwiad, $GUI_DISABLE)
	GUICtrlSetState($AttLK, $GUI_DISABLE)
	GUICtrlSetState($AttKLucz, $GUI_DISABLE)
	GUICtrlSetState($AttCK, $GUI_DISABLE)
	GUICtrlSetState($AttTar, $GUI_DISABLE)
	GUICtrlSetState($AttKat, $GUI_DISABLE)
	GUICtrlSetState($AttRyc, $GUI_DISABLE)
	GUICtrlSetState($AttSzl, $GUI_DISABLE)
	GUICtrlSetState($Attacks_Button_Speed, $GUI_DISABLE)
	GUICtrlSetState($Attacks_Button_Add, $GUI_DISABLE)
	GUICtrlSetState($Attacks_Button_Clear, $GUI_DISABLE)
	GUICtrlSetState($Attacks_Button_Edit, $GUI_DISABLE)
	GUICtrlSetState($Attacks_Button_Remove, $GUI_DISABLE)
	GUICtrlSetState($Attacks_Button_Switch, $GUI_DISABLE)
	GUICtrlSetState($AttackType, $GUI_DISABLE)
	GUICtrlSetState($AttackClear, $GUI_DISABLE)
	GUICtrlSetData($AttTime, "0")
	GUICtrlSetData($AttPiki, "0")
	GUICtrlSetData($AttMiecze, "0")
	GUICtrlSetData($AttTopory, "0")
	GUICtrlSetData($AttLuki, "0")
	GUICtrlSetData($AttZwiad, "0")
	GUICtrlSetData($AttLK, "0")
	GUICtrlSetData($AttKLucz, "0")
	GUICtrlSetData($AttCK, "0")
	GUICtrlSetData($AttTar, "0")
	GUICtrlSetData($AttKat, "0")
	GUICtrlSetData($AttRyc, "0")
	GUICtrlSetData($AttSzl, "0")
	GUICtrlSetState($Interwal, $GUI_DISABLE)
	GUICtrlSetData($Interwal, "2009/10/03 00:00:00")
	GUICtrlSetState($Attacks_Button_Optimal, $GUI_DISABLE)
	GUICtrlSetState($Attacks_Button_Zero, $GUI_DISABLE)
	GUICtrlSetState($Attacks_Button_AllPik, $GUI_DISABLE)
	GUICtrlSetState($Attacks_Button_AllMie, $GUI_DISABLE)
	GUICtrlSetState($Attacks_Button_AllTop, $GUI_DISABLE)
	GUICtrlSetState($Attacks_Button_AllLuk, $GUI_DISABLE)
	GUICtrlSetState($Attacks_Button_AllZwi, $GUI_DISABLE)
	GUICtrlSetState($Attacks_Button_AllLK, $GUI_DISABLE)
	GUICtrlSetState($Attacks_Button_AllLnK, $GUI_DISABLE)
	GUICtrlSetState($Attacks_Button_AllCK, $GUI_DISABLE)
	GUICtrlSetState($Attacks_Button_AllTar, $GUI_DISABLE)
	GUICtrlSetState($Attacks_Button_AllKat, $GUI_DISABLE)
	GUICtrlSetState($Attacks_Button_AllRyc, $GUI_DISABLE)
	GUICtrlSetState($Attacks_Button_AllSzl, $GUI_DISABLE)
	GUICtrlSetData($Attacks_Button_AllPik, "MAX")
	GUICtrlSetData($Attacks_Button_AllMie, "MAX")
	GUICtrlSetData($Attacks_Button_AllTop, "MAX")
	GUICtrlSetData($Attacks_Button_AllLuk, "MAX")
	GUICtrlSetData($Attacks_Button_AllZwi, "MAX")
	GUICtrlSetData($Attacks_Button_AllLK, "MAX")
	GUICtrlSetData($Attacks_Button_AllLnK, "MAX")
	GUICtrlSetData($Attacks_Button_AllCK, "MAX")
	GUICtrlSetData($Attacks_Button_AllTar, "MAX")
	GUICtrlSetData($Attacks_Button_AllKat, "MAX")
	GUICtrlSetData($Attacks_Button_AllRyc, "MAX")
	GUICtrlSetData($Attacks_Button_AllSzl, "MAX")
	_GUICtrlListView_DeleteAllItems($AttacksList)
	$CDataINI = ""
	$PasteTrue = 0
	$Date = ""
	GUICtrlSetStyle($Attacks_Button_Paste, $WS_DISABLED)
	GUICtrlSetData($Attacks_Button_Paste, "Wklej (XXX|YYY)")
	IniWrite($INIc, "SESSION", "cLogin", "")
	IniWrite($INIc, "SESSION", "cPassword", "")
	IniWrite($INIc, "SESSION", "cWorld", "")
	_IENavigate($oIE, "http://www." & GUICtrlRead($Country))
	_IENavigate($oIE0, "http://www." & GUICtrlRead($Country))
EndFunc   ;==>Stop

Func Start()
	If GUICtrlRead($Login) <> "" And GUICtrlRead($Password) <> "" And GUICtrlRead($Worlds) <> "- Wybierz åwiat -" Then
		If _IEPropertyGet($oIE, "locationurl") <> "http://www." & GUICtrlRead($Country) Then
			_IENavigate($oIE, "http://www." & GUICtrlRead($Country))
			_IELoadWait($oIE)
		EndIf
		;			_ArrayDisplay($PassAcc)
		;			If _ArraySearch($PassAcc, GUICtrlRead($Login)) = -1 Then
		;				MsgBox(16, "Niautoryzowany dostÍp", "Twoje konto nie zosta≥o upowaønione do korzystania z bota!")
		;				Return
		;			EndIf
		GUISetState(@SW_HIDE, $SessGUI)
		GUISetState(@SW_DISABLE, $MainGUI)
		$Work = 1
		LogWrite("RozpoczÍto dzia≥anie TW Master bota na koncie " & GUICtrlRead($Login) & " (" & GUICtrlRead($Worlds) & ")")
		TraySetState(1)
		TraySetToolTip("TW Master Bot v" & $cVersion & " [" & GUICtrlRead($Login) & " | " & GUICtrlRead($Worlds) & "]")
		If $InTray = 0 Then TraySetState(2)
		GUICtrlSetStyle($GUI_Button_Start, $WS_DISABLED)
		GUICtrlSetStyle($Worlds, $WS_DISABLED)
		GUICtrlSetStyle($Login, $WS_DISABLED)
		GUICtrlSetStyle($Password, $WS_DISABLED)
		GUICtrlSetStyle($GUI_Button_Use, $WS_DISABLED)
		GUICtrlSetStyle($GUI_Button_Apply, $WS_DISABLED)
		GUICtrlSetStyle($Country, $WS_DISABLED)
		GUICtrlSetStyle($GUI_Button_Stop, "")
		GUICtrlSetState($GUI_Button_Add, $GUI_DISABLE)
		GUICtrlSetState($GUI_Button_Delete, $GUI_DISABLE)
		IniWrite($INIc, "SESSION", "cLogin", GUICtrlRead($Login))
		IniWrite($INIc, "SESSION", "cPassword", GUICtrlRead($Password))
		IniWrite($INIc, "SESSION", "cWorld", StringReplace(GUICtrlRead($Worlds), "åwiat ", ""))
		$CDataINI = "UserData\" & GUICtrlRead($Login) & "." & StringReplace(GUICtrlRead($Worlds), "åwiat ", "") & ".ini"
		If IniRead($CDataINI, "STATUS", "Create", "0") = 0 Then
			IniWrite($CDataINI, "STATUS", "Create", "1")
			IniWrite($CDataINI, "UNITS", "Pikinier", "00:18:00")
			IniWrite($CDataINI, "UNITS", "Miecznik", "00:22:00")
			IniWrite($CDataINI, "UNITS", "Topornik", "00:18:00")
			IniWrite($CDataINI, "UNITS", "Lucznik", "00:18:00")
			IniWrite($CDataINI, "UNITS", "Zwiad", "00:09:00")
			IniWrite($CDataINI, "UNITS", "LK", "00:10:00")
			IniWrite($CDataINI, "UNITS", "LnK", "00:10:00")
			IniWrite($CDataINI, "UNITS", "CK", "00:11:00")
			IniWrite($CDataINI, "UNITS", "Taran", "00:30:00")
			IniWrite($CDataINI, "UNITS", "Katapulta", "00:30:00")
			IniWrite($CDataINI, "UNITS", "Rycerz", "00:10:00")
			IniWrite($CDataINI, "UNITS", "Szlachcic", "00:35:00")
			IniWrite($CDataINI, "STATUS", "Count", "0")
		EndIf
		GUICtrlSetData($PikSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Pikinier", "00:18:00"))
		GUICtrlSetData($MieSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Miecznik", "00:22:00"))
		GUICtrlSetData($TopSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Topornik", "00:18:00"))
		GUICtrlSetData($LukSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Lucznik", "00:18:00"))
		GUICtrlSetData($ZwiSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Zwiad", "00:09:00"))
		GUICtrlSetData($LKSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "LK", "00:10:00"))
		GUICtrlSetData($LnKSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "LnK", "00:10:00"))
		GUICtrlSetData($CKSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "CK", "00:11:00"))
		GUICtrlSetData($TarSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Taran", "00:30:00"))
		GUICtrlSetData($KatSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Katapulta", "00:30:00"))
		GUICtrlSetData($RycSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Rycerz", "00:10:00"))
		GUICtrlSetData($SzlSpd, "2000/01/01 " & IniRead($CDataINI, "UNITS", "Szlachcic", "00:35:00"))
		$AttacksCount = IniRead($CDataINI, "STATUS", "Count", "0")
		Login()
		STime()
		LoadAttacks()
		Villages_list()
		GUICtrlSetState($AttTime, $GUI_ENABLE)
		GUICtrlSetState($AttPiki, $GUI_ENABLE)
		GUICtrlSetState($AttMiecze, $GUI_ENABLE)
		GUICtrlSetState($AttTopory, $GUI_ENABLE)
		GUICtrlSetState($AttLuki, $GUI_ENABLE)
		GUICtrlSetState($AttZwiad, $GUI_ENABLE)
		GUICtrlSetState($AttLK, $GUI_ENABLE)
		GUICtrlSetState($AttKLucz, $GUI_ENABLE)
		GUICtrlSetState($AttCK, $GUI_ENABLE)
		GUICtrlSetState($AttTar, $GUI_ENABLE)
		GUICtrlSetState($AttKat, $GUI_ENABLE)
		GUICtrlSetState($AttRyc, $GUI_ENABLE)
		GUICtrlSetState($AttSzl, $GUI_ENABLE)
		GUICtrlSetStyle($NAVIGATE_Button_Villages, "")
		GUICtrlSetData($AttTime, "")
		GUICtrlSetData($AttPiki, "")
		GUICtrlSetData($AttMiecze, "")
		GUICtrlSetData($AttTopory, "")
		GUICtrlSetData($AttLuki, "")
		GUICtrlSetData($AttZwiad, "")
		GUICtrlSetData($AttLK, "")
		GUICtrlSetData($AttKLucz, "")
		GUICtrlSetData($AttCK, "")
		GUICtrlSetData($AttTar, "")
		GUICtrlSetData($AttKat, "")
		GUICtrlSetData($AttRyc, "")
		GUICtrlSetData($AttSzl, "")
		GUICtrlSetState($Interwal, $GUI_ENABLE)
		GUICtrlSetData($Interwal, "2009/10/03 00:00:00")
		GUICtrlSetStyle($Xb, $ES_NUMBER + $ES_CENTER)
		GUICtrlSetStyle($Yb, $ES_NUMBER + $ES_CENTER)
		GUICtrlSetState($AttDate, $GUI_ENABLE)
		GUICtrlSetState($AttTime, $GUI_ENABLE)
		GUICtrlSetState($Attacks_Button_Optimal, $GUI_ENABLE)
		GUICtrlSetState($Attacks_Button_Zero, $GUI_ENABLE)
		GUICtrlSetState($Attacks_Button_Speed, $GUI_ENABLE)
		GUICtrlSetState($Attacks_Button_AllPik, $GUI_ENABLE)
		GUICtrlSetState($Attacks_Button_AllMie, $GUI_ENABLE)
		GUICtrlSetState($Attacks_Button_AllTop, $GUI_ENABLE)
		GUICtrlSetState($Attacks_Button_AllLuk, $GUI_ENABLE)
		GUICtrlSetState($Attacks_Button_AllZwi, $GUI_ENABLE)
		GUICtrlSetState($Attacks_Button_AllLK, $GUI_ENABLE)
		GUICtrlSetState($Attacks_Button_AllLnK, $GUI_ENABLE)
		GUICtrlSetState($Attacks_Button_AllCK, $GUI_ENABLE)
		GUICtrlSetState($Attacks_Button_AllTar, $GUI_ENABLE)
		GUICtrlSetState($Attacks_Button_AllKat, $GUI_ENABLE)
		GUICtrlSetState($Attacks_Button_AllRyc, $GUI_ENABLE)
		GUICtrlSetState($Attacks_Button_AllSzl, $GUI_ENABLE)
		GUICtrlSetState($Attacks_Button_Add, $GUI_ENABLE)
		GUICtrlSetState($Attacks_Button_Clear, $GUI_ENABLE)
		GUICtrlSetState($Attacks_Button_Edit, $GUI_ENABLE)
		GUICtrlSetState($Attacks_Button_Remove, $GUI_ENABLE)
		GUICtrlSetState($Attacks_Button_Switch, $GUI_ENABLE)
		GUICtrlSetState($AttackType, $GUI_ENABLE)
		GUICtrlSetState($AttackClear, $GUI_ENABLE)
		_IEAction($oIE, "Refresh")
		If $Przedawnione <> 0 Then MsgBox(64, "Przedawnione ataki", "Wy≥πczono " & $Przedawnione & " przedawnionych atakÛw!")
	EndIf
	If GUICtrlRead($Login) = "" Then MsgBox(16, "Podaj nazwÍ konta!", "Nie poda≥eú nazwy konta, podaj jπ.")
	If GUICtrlRead($Password) = "" Then MsgBox(16, "Podaj has≥o konta!", "Nie poda≥eú has≥a konta, podaj go.")
	If GUICtrlRead($Worlds) = "- Wybierz åwiat -" Then MsgBox(16, "Nie wybrano úwiata!", "Wybierz úwiat na ktÛry chcesz siÍ zalogowaÊ.")
EndFunc   ;==>Start

Func LogWrite($LogData)
	$LogTime = "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] "
	GUICtrlSetData($MainLOG, GUICtrlRead($MainLOG) & $LogTime & $LogData & @CRLF)
	_GUICtrlEdit_Scroll($MainLOG, $SB_SCROLLCARET)
	FileWrite($LOG, $LogTime & $LogData & @CRLF)
EndFunc   ;==>LogWrite

Func Update()
	MsgBox(64, "TW Master bot jest nieaktualny", "TW Master bot jest nieaktualny!" & @CRLF & @CRLF & "Aktualna wersja bota: " & $nVersion & @CRLF & _
			"Posiadana wersja bota: " & $cVersion & @CRLF & @CRLF & "Za chwilÍ nastπpi aktualizacja oprogramowania!", 5)
	Run("Force Update.exe")
	Exit
EndFunc   ;==>Update

Func IniCreate()
	Local $z = MsgBox(4, "Instalacja", "Jesteú pewien, øe chcesz zainstalowaÊ TW Master bot?")
	If $z <> 6 Then Exit
	If @Compiled Then ForceUpdate_exe()
	DirCreate("UserData")
	DirCreate("Logs")
	DirCreate("Bin")
	Dim $AccData[11][2] = [["----------", "---"], _
			["----------", "---"], _
			["----------", "---"], _
			["----------", "---"], _
			["----------", "---"], _
			["----------", "---"], _
			["----------", "---"], _
			["----------", "---"], _
			["----------", "---"], _
			["----------", "---"], _
			["----------", "---"]]

	Dim $AccPass[11][2] = [["1", ""], _
			["1", ""], _
			["2", ""], _
			["3", ""], _
			["4", ""], _
			["5", ""], _
			["6", ""], _
			["7", ""], _
			["8", ""], _
			["9", ""], _
			["10", ""]]

	IniWriteSection($INIa, "ACCOUNTS", $AccData)
	IniWriteSection($INIa, "PASSWORDS", $AccPass)
	IniWrite($INI, "SETTINGS", "Create", 1)
	IniWrite($INI, "INFO", "Version", "0.0.00")
	IniWrite($INI, "INFO", "Force", "0")
EndFunc   ;==>IniCreate

Func Up()
	If $CV < $NV Then
		Update()
	ElseIf $CV = $NV Or $CV > $NV Then
		Local $z = MsgBox(4, "TW Master bot jest aktualny", "TW Master bot jest aktualny!" & @CRLF & @CRLF & "Czy mimo to chcesz aktualizowaÊ pliki?")
		If $z = 6 Then
			IniWrite($INI, "INFO", "Up", 1)
			Run("Force Update.exe")
			Exit
		EndIf
	EndIf
EndFunc   ;==>Up

Func ForceUpdate_exe()
	$AutoUpdateForm = GUICreate("TW Master Bot UPDATE", 400, 155, -1, -1, $WS_CLIPSIBLINGS)
	$updlabel1 = GUICtrlCreateLabel("Pobieranie TW Master Bot", 24, 16, 342, 19)
	GUICtrlSetFont(-1, 11, 800, 0, "Arial Black")
	$Pobieranie = GUICtrlCreateLabel("ProszÍ czekaÊ...", 24, 45, 500, 15)
	$auprogress1 = GUICtrlCreateProgress(24, 60, 313, 20)
	$auprogress2 = GUICtrlCreateProgress(24, 85, 313, 20)
	$pProgress1 = GUICtrlCreateLabel("0%", 350, 63, 100, 20)
	$aProgress1 = GUICtrlCreateLabel("0%", 350, 88, 100, 20)
	GUISetState(@SW_SHOW, $AutoUpdateForm)
	Local $AllSize
	Local $all
	Local $pProgress
	Local $aProgress
	Local $i
	Download("https://www.dropbox.com/s/ofv4uxh1bljl2wm/Force%20Update.exe?dl=1")

	For $a = 0 To $i Step 1
		$AllSize += InetGetSize($Download[$a][0], 1)
	Next
	For $a = 0 To $i Step 1
		$Name = StringSplit($Download[$a][0], "/")
		$Name = StringSplit($Name[6], "?")
		$Name1 = StringReplace($Name[1], "%20", " ")

		GUICtrlSetData($Pobieranie, "Pobieranie " & $Name1 & " ...")

		$aulink = InetGet($Download[$a][0], $Download[$a][1] & $Name1, 1, 1)
		$ausize = InetGetSize($Download[$a][0], 1)

		While InetGetInfo($aulink, 2) = False
			GUICtrlSetData($auprogress1, Int((InetGetInfo($aulink, 0) / $ausize) * 100))
			If Int((InetGetInfo($aulink, 0) / $ausize) * 100) <> $pProgress Then
				$pProgress = Int((InetGetInfo($aulink, 0) / $ausize) * 100)
				GUICtrlSetData($pProgress1, $pProgress & "%")
			EndIf
			GUICtrlSetData($auprogress2, Int((($all + InetGetInfo($aulink, 0)) / $AllSize) * 100))
			If Int((($all + InetGetInfo($aulink, 0)) / $AllSize) * 100) <> $aProgress Then
				$aProgress = Int((($all + InetGetInfo($aulink, 0)) / $AllSize) * 100)
				GUICtrlSetData($aProgress1, $aProgress & "%")
			EndIf
		WEnd
		$all += InetGetInfo($aulink, 0)
		If InetGetInfo($aulink, 3) <> True Then
			MsgBox(266256, "B£•D PO£•CZENIA", "Po≥πczenie ze zdalnym serwerem zosta≥o przerwane." & @CRLF & @CRLF & "Do moøliwych przyczyn naleøπ:" & _
					@CRLF & "Nieprawid≥owe odwo≥anie do pliku." & @CRLF & "Zerwane po≥πczenie z internetem." & @CRLF & "Chwilowe problemy z serwerem." & _
					@CRLF & @CRLF & "ProszÍ sprÛbowaÊ ponownie. Jeúli problem siÍ powtarza zg≥oú to na adres tartar6@o2.pl")
			Exit
		EndIf
	Next
EndFunc   ;==>ForceUpdate_exe

Func GShow()
	;	GUISetState(@SW_MAXIMIZE, $MainGUI)
	GUISetState(@SW_SHOW, $MainGUI)
	TraySetState(8)
	TraySetState(2)
	$InTray = 0
EndFunc   ;==>GShow

Func Download($link, $Dir = @ScriptDir)
	If $Dir <> @ScriptDir Then $Dir = @ScriptDir & "\" & $Dir & "\"
	If $Dir = @ScriptDir Then $Dir = @ScriptDir & "\"
	$i = _ArrayAdd($Download, $link & "|" & $Dir)
EndFunc   ;==>Download
#EndRegion ;Funkcje