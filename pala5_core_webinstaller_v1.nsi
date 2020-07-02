# Author: LiXizhi
# Company: ParaEngine
# Date: 2008.10.16
# Desc: it will generate a small file pala5_core_web_installer.exe, upload this file to web server 
# and put the actual installer files listed below to their actual position. 
# @Note: modify the URL as necessary and use CDN at production time. 
# @see the testdownload.htm for an example of user experience. 

!define PW_URL "http://www.pala5.com/download/Pala5_1.0.0.0_core_installer.exe"
!define PW_TEMP "$TEMP\Pala5_1.0.0.0_core_installer.exe"

 
!include LogicLib.nsh

; The file to write
OutFile "Release/pala5_core_web_installer.exe"
 
; First is default
LoadLanguageFile "${NSISDIR}\Contrib\Language files\English.nlf"
LoadLanguageFile "${NSISDIR}\Contrib\Language files\SimpChinese.nlf"

; Request application privileges for Windows Vista
RequestExecutionLevel user

;--------------------------------
; UI
; The name of the installer
LangString Name ${LANG_ENGLISH} "ParaWorld"
LangString Name ${LANG_SIMPCHINESE} "帕拉巫"
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
 
FunctionEnd

;--------------------------------
; The download and install
Section "" 

  ;----------------------------
  ; Download ParaWorld core component:
  DetailPrint "Beginning download of ParaWorld core"
  NSISDL::download ${PW_URL} ${PW_TEMP}
  DetailPrint "Completed download."
  Pop $0
  ${If} $0 == "cancel"
    goto GiveUp
  ${ElseIf} $0 != "success"
    MessageBox MB_YESNO|MB_ICONEXCLAMATION \
    "下载失败了:$\n$0$\n$\是否继续?" \
    IDYES FinishDownload IDNO GiveUp
  ${EndIf}
  DetailPrint "Pausing installation while downloaded ParaWorld installer runs."
  ExecWait ${PW_TEMP} $0
  DetailPrint "Completed ParaWorld  install/update. Exit code = '$0'. Removing ParaWorld installer."
  Delete ${PW_TEMP}
  DetailPrint "ParaWorldViewer installer removed."
  goto FinishDownload

GiveUp:
  DetailPrint "Installation cancelled by user."
  Quit
  
FinishDownload:
  DetailPrint "Proceeding with remainder of installation."

  Quit
  
SectionEnd