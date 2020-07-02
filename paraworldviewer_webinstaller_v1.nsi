# Author: LiXizhi
# Company: ParaEngine
# Date: 2008.10.16
# Desc: it will generate a small file SetupPWV.exe, upload this file to web server 
# and put the actual installer files listed blow to their actual position. 
#	- Currently, only PWVIEWER_URL is used
# @Note: modify the URL as necessary and use CDN at production time. 
# @see the testdownload.htm for an example of user experience. 

!define PWVIEWER_URL "http://pedn/ParaWorldViewer_1.0.0.0_installer.exe"
!define PW_URL "http://pedn/ParaWorld_1.0.0.0_installer.exe"

!define DOTNET_URL "http://www.microsoft.com/downloads/info.aspx?na=90&p=&SrcDisplayLang=en&SrcCategoryId=&SrcFamilyId=0856eacb-4362-4b0d-8edd-aab15c5e04f5&u=http%3a%2f%2fdownload.microsoft.com%2fdownload%2f5%2f6%2f7%2f567758a3-759e-473e-bf8f-52154438565a%2fdotnetfx.exe"
!define MSI31_URL "http://download.microsoft.com/download/1/4/7/147ded26-931c-4daf-9095-ec7baf996f46/WindowsInstaller-KB893803-v2-x86.exe"
 
!include LogicLib.nsh

; The file to write
OutFile "Release/SetupPWV.exe"
 
; First is default
LoadLanguageFile "${NSISDIR}\Contrib\Language files\English.nlf"
LoadLanguageFile "${NSISDIR}\Contrib\Language files\SimpChinese.nlf"

; Request application privileges for Windows Vista
RequestExecutionLevel user

;--------------------------------
; UI
; The name of the installer
LangString Name ${LANG_ENGLISH} "ParaWorld Viewer"
LangString Name ${LANG_SIMPCHINESE} "帕拉巫 -- 迷你播放器"
Name $(Name)
LangString Caption ${LANG_ENGLISH} "ParaWorld - social web 3d platform"
LangString Caption ${LANG_SIMPCHINESE} "帕拉巫-3D社交创作平台"
Caption $(Caption) 
BrandingText "http://www.pala5.com"

;--------------------------------
;Installer Functions

LangString InstallerAlreadyRunning ${LANG_ENGLISH} "The installer is already running."
LangString InstallerAlreadyRunning ${LANG_SIMPCHINESE} "安装程序已经在运行"

LangString AlreadyInstalledString ${LANG_ENGLISH} "You already installed a copy of the application. Do you want to install it again?"
LangString AlreadyInstalledString ${LANG_SIMPCHINESE} "您已经安装了本产品的一个版本. 你是否要重新安装?"

Function .onInit
	;----------------------
	;prevent multiple runs
	System::Call 'kernel32::CreateMutexA(i 0, i 0, t "myMutex_viewer") i .r1 ?e'
	Pop $R0
	
	StrCmp $R0 0 +3
	 MessageBox MB_OK|MB_ICONEXCLAMATION $(InstallerAlreadyRunning)
	 Abort
	
	ReadRegStr $0 HKCR "paraworldviewer" ""
	${If} $0 == "URL:ParaEngine"
		MessageBox MB_YESNO|MB_ICONEXCLAMATION \
			$(AlreadyInstalledString)  \
			IDYES FinishInit IDNO QuitInit
    ${EndIf}
    goto FinishInit

QuitInit:
	quit
FinishInit:	
 
FunctionEnd

;--------------------------------
; The download and install
Section "" 

  ;----------------------------
  ; DownloadParaWorld:
  DetailPrint "Beginning download of ParaWorld viewer"
  NSISDL::download ${PWVIEWER_URL} "$TEMP\paraworldviewer.exe"
  DetailPrint "Completed download."
  Pop $0
  ${If} $0 == "cancel"
    goto GiveUp
  ${ElseIf} $0 != "success"
    MessageBox MB_YESNO|MB_ICONEXCLAMATION \
    "Download failed:$\n$0$\n$\nContinue Installation?" \
    IDYES FinishDownload IDNO GiveUp
  ${EndIf}
  DetailPrint "Pausing installation while downloaded ParaWorldViewer installer runs."
  ExecWait '$TEMP\paraworldviewer.exe' $0
  DetailPrint "Completed ParaWorldViewer install/update. Exit code = '$0'. Removing ParaWorldViewer installer."
  Delete "$TEMP\paraworldviewer.exe"
  DetailPrint "ParaWorldViewer installer removed."
  goto FinishDownload

GiveUp:
  DetailPrint "Installation cancelled by user."
  Quit
  
FinishDownload:
  DetailPrint "Proceeding with remainder of installation."

  Quit
  
SectionEnd