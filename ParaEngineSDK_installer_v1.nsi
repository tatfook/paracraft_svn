# Author: LiXizhi
# Company: ParaEngine
# Date: 2008.10.21
# Desc: It installs NPL language service

!define PROGRAM_NAME "ParaEngineSDK"
!define VERSION "1.0.0.0"

!define PWVIEWER_URL "http://pedn.paraengine.com/ParaWorldViewer_1.0.0.0_installer.exe"
!define PW_URL "http://pedn.paraengine.com/ParaWorld_1.0.0.0_installer.exe"

!define DOTNET_URL "http://www.microsoft.com/downloads/info.aspx?na=90&p=&SrcDisplayLang=en&SrcCategoryId=&SrcFamilyId=0856eacb-4362-4b0d-8edd-aab15c5e04f5&u=http%3a%2f%2fdownload.microsoft.com%2fdownload%2f5%2f6%2f7%2f567758a3-759e-473e-bf8f-52154438565a%2fdotnetfx.exe"
!define MSI31_URL "http://download.microsoft.com/download/1/4/7/147ded26-931c-4daf-9095-ec7baf996f46/WindowsInstaller-KB893803-v2-x86.exe"
 
!include LogicLib.nsh


; First is default
LoadLanguageFile "${NSISDIR}\Contrib\Language files\English.nlf"
LoadLanguageFile "${NSISDIR}\Contrib\Language files\SimpChinese.nlf"

; Request application privileges for Windows Vista
RequestExecutionLevel user

;--------------------------------
; UI
; The name of the installer
LangString Name ${LANG_ENGLISH} "ParaEngine SDK"
LangString Name ${LANG_SIMPCHINESE} "ParaEngine SDK"
Name $(Name)
LangString Caption ${LANG_ENGLISH} "ParaEngine SDK - social web 3d platform"
LangString Caption ${LANG_SIMPCHINESE} "ParaEngine SDK"
Caption $(Caption) 
BrandingText "http://www.pala5.com"
; The file to write
OutFile "Release/${PROGRAM_NAME}_${VERSION}_installer.exe"
LicenseLangString license  ${LANG_ENGLISH} "script\installer\License_enUS.txt"
LicenseLangString license  ${LANG_SIMPCHINESE} "script\installer\License_zhCN.txt"
LicenseData $(license)

;--------------------------------
; Pages
Page license
Page components
Page directory
Page instfiles

;--------------------------------
;Installer Functions

LangString InstallerAlreadyRunning ${LANG_ENGLISH} "The installer is already running."
LangString InstallerAlreadyRunning ${LANG_SIMPCHINESE} "安装程序已经在运行"

LangString AlreadyInstalledString ${LANG_ENGLISH} "You already installed a copy of the application. Do you want to install it again?"
LangString AlreadyInstalledString ${LANG_SIMPCHINESE} "您已经安装了本产品的一个版本. 你是否要重新安装?"

Function .onInit
	;----------------------
	;prevent multiple runs
	System::Call 'kernel32::CreateMutexA(i 0, i 0, t "myMutex_PESDK") i .r1 ?e'
	Pop $R0
	
	StrCmp $R0 0 +3
	 MessageBox MB_OK|MB_ICONEXCLAMATION $(InstallerAlreadyRunning)
	 Abort
	
	; set install directory according to previous paraworld installation. 
	ReadRegStr $0 HKCU "Software\ParaEngine\ParaWorld" ""
	${If} $0 != ""
		StrCpy $INSTDIR $0
	${EndIf}
	
	ReadRegStr $0 HKCU "Software\ParaEngine\ParaEngineSDK" "version"
	${If} $0 == ${VERSION}
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
; Default Installer Sections
Section "- Core Components"

	# -------------------------------------
	# script files:
	# -------------------------------------
	SetOutPath $INSTDIR
	File installer\SDK\MyApp.vcproj
	File installer\SDK\script.vcproj
	File installer\SDK\script.sln
	File installer\SDK\changes.txt
	
	SetOutPath $INSTDIR\script
	File /r installer\SDK\script\*.*
	
	# -------------------------------------
	# Post setup: short cut menus, desktop menu, registry etc. 
	# -------------------------------------
	;Store installation folder
	WriteRegStr HKCU "Software\ParaEngine\ParaEngineSDK" "" $INSTDIR
	WriteRegStr HKCU "Software\ParaEngine\ParaEngineSDK" "version" ${VERSION}
  
SectionEnd

;--------------------------------
; VsNPL component section
Section "NPL Language Service"

	DetailPrint "Copying VsNPL installer."
	SetOutPath $TEMP
	File ..\VsNPL\SetupVsNPL\Release\SetupVsNPL.msi
	ExecWait '"msiexec" /i "$TEMP\SetupVsNPL.msi"' $0
	DetailPrint "Completed VsNPL install/update. Exit code = '$0'. Removing VsNPL installer."
	Delete "$TEMP\SetupVsNPL.msi"
	
SectionEnd