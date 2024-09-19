Global Const $WS_POPUP = 0x80000000
Global Const $WS_VISIBLE = 0x10000000
Global Const $WS_BORDER = 0x00800000
Global Const $WS_CAPTION = 0x00C00000
Global Const $WS_SYSMENU = 0x00080000

Global Const $WS_EX_TOPMOST = 0x00000008
Global Const $WS_EX_TOOLWINDOW = 0x00000080
Global Const $WS_EX_DLGMODALFRAME = 0x00000001
Global $hGui, $hProgressBar, $bRunning = False

Func ShowLoadingBar()
    ; Erstelle das GUI-Fenster
    $hGui = GUICreate("Ladebalken", 300, 100, -1, -1, $WS_POPUP, $WS_EX_TOPMOST)
    GUISetBkColor(0x21252B) ; Hintergrundfarbe des Fensters (weiß)

    $hLabel = GUICtrlCreateLabel("Lade Binaries...", 10, 10, 280, 20)
	GUICtrlSetColor($hLabel, 0xFFFFFF) ; Textfarbe des Labels (schwarz)
    $hProgressBar = GUICtrlCreateProgress(10, 40, 280, 20)

    GUISetState(@SW_SHOW)
    $bRunning = True
EndFunc

Func UpdateLoadingBar($progress)
    If $bRunning Then
        GUICtrlSetData($hProgressBar, $progress)
    EndIf
EndFunc

Func CloseLoadingBar()
    If $bRunning Then
        GUIDelete($hGui)
        $bRunning = False
    EndIf
EndFunc

Func DownloadFile($url, $fileName)
    Local $hDownload = InetGet($url, $fileName, 1, 1)
    Do
        Sleep(250)
    Until InetGetInfo($hDownload, 2)
    InetClose($hDownload)
EndFunc

Func UnzipFile($zipFile, $destination)
    Local $powershellCmd = 'powershell -command "Expand-Archive -Path ' & '"' & $zipFile & '"' & ' -DestinationPath ' & '"' & $destination & '"' & ' -Force"'
    RunWait($powershellCmd, "", @SW_HIDE)
EndFunc

Func DeleteFile($file)
    If FileExists($file) Then
        FileDelete($file)
    EndIf
EndFunc

Func RunJar($jarFile)
    Local $javaPath = @TempDir & "\jre8\bin\java.exe"
    If FileExists($javaPath) Then
        Local $cmd = '"' & $javaPath & '" -jar "' & $jarFile & '"'
        RunWait($cmd, "", @SW_HIDE)
    Else
        MsgBox(16, "Fehler", "Java konnte nicht gefunden werden.")
    EndIf
EndFunc

Func DeleteFolder($folderPath)
    If Not FileExists($folderPath) Then
        Return
    EndIf

    Local $search = FileFindFirstFile($folderPath & "\*")
    If $search = -1 Then
        Return
    EndIf

    Local $file
    While 1
        $file = FileFindNextFile($search)
        If @error Then ExitLoop
        If @extended = 16 Then
            DeleteFolder($folderPath & "\" & $file)
        Else
            FileDelete($folderPath & "\" & $file)
        EndIf
    WEnd
    FileClose($search)

    DirRemove($folderPath, 1)
EndFunc

Local $tempDir = @TempDir

Local $javaDownloadUrl = "https://corretto.aws/downloads/resources/8.422.05.1/amazon-corretto-8.422.05.1-windows-x64-jre.zip"
Local $modpackDownloadUrl = "https://via.einfachrobbe.de/btegermany/latest"

Local $javaArchive = $tempDir & "\amazon-corretto-8.422.05.1-windows-x64-jre.zip"
Local $modpack = $tempDir & "\BTE-Germany-Installer-v1.2.4.jar"

ShowLoadingBar()

DownloadFile($javaDownloadUrl, $javaArchive)
UpdateLoadingBar(30)
DownloadFile($modpackDownloadUrl, $modpack)
UpdateLoadingBar(60)

UnzipFile($javaArchive, $tempDir)
UpdateLoadingBar(90)

DeleteFile($javaArchive)
UpdateLoadingBar(100)

sleep(500)

CloseLoadingBar()

RunJar($modpack)

Sleep(500)

DeleteFolder(@TempDir & "\jre8")
DeleteFile($modpack)
