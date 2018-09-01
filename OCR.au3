#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include "TWC.au3"

Global Const $STM_SETIMAGE = 0x0172
Global $idPic[7]
Global $iImagesCount = 0

GUICreate("TWC", 500, 560)

For $i = 0 To UBound($idPic) - 1
   $idPic[$i] = GUICtrlCreatePic("", 10, $i * 90 + 10, 330, 80)
Next
$idButton = GUICtrlCreateButton("Wybierz plik...", 350, 10, 140, 30)
$idInput = GUICtrlCreateEdit("", 350, 50, 140, 70, $ES_READONLY)
GUISetState()

_TWC_Debug(SetImage)

While 1
   Switch GUIGetMsg()
      Case $GUI_EVENT_CLOSE
         Exit
      Case $idButton
         For $i = 0 To UBound($idPic) - 1
            GUICtrlSetImage($idPic[$i], "")
         Next
         GUICtrlSetData($idInput, "")

         $iImagesCount = 0
         $sFile = FileOpenDialog("Wybierz...", @ScriptDir, "Captcha (*.png)")
         If FileExists($sFile) Then
            SetImage($sFile)
            $sCaptcha = _TWC_Break($sFile)
            If @error Then
               GUICtrlSetData($idInput, $sCaptcha & @CRLF & "Jest to nieprawid³owa odpowiedŸ.")
            Else
               GUICtrlSetData($idInput, $sCaptcha)
            EndIf
         Else
            MsgBox(0, "", "Gdy wybierzesz plik, program bêdzie dzia³a³ znacznie lepiej!")
         EndIf
   EndSwitch
WEnd

Func SetImage($sImage)
   Local $idCtrl = $idPic[$iImagesCount]
   $iImagesCount += 1

   ConsoleWrite($sImage & @LF)

   _GDIPlus_Startup()
   Local $hImage = _GDIPlus_ImageLoadFromFile($sImage)
   Local $hBmp = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
   _GDIPlus_ImageDispose($hImage)
   _GDIPlus_Shutdown()
   GUICtrlSendMsg($idCtrl, $STM_SETIMAGE, 0, $hBmp)
   _WinAPI_DeleteObject($hBmp)
EndFunc   ;==>SetImage