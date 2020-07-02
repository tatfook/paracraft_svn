# Author: LiXizhi
# Company: ParaEngine
# Date: 2009.11.15

;------------------------------------------------------------------------
; Aries is the internal codename of the Online Kids Theme Community
;------------------------------------------------------------------------

!include LogicLib.nsh
!include WinVer.nsh
!include "script\installer\MSI.nsh"
;--------------------------------
;Include Modern UI
  !include "MUI2.nsh"

;Request application privileges for Windows Vista
  RequestExecutionLevel admin

;--------------------------------
;Variables

  Var StartMenuFolder
    
;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING
  ;!define MUI_WELCOMEPAGE_TEXT  "This wizard will guide you through the installation of Aries. It is recommended that you close all other applications before starting Setup.Note to Win2k/XP users: You may require administrator privileges to install Aries successfully."
  !define MUI_WELCOMEFINISHPAGE_BITMAP "Texture\Aries\brand\installer.bmp"
  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP  "Texture\Aries\brand\header.bmp"
  !define MUI_FINISHPAGE_RUN "$INSTDIR\ParaChat\ParaChat.exe"

;--------------------------------
;Language Selection Dialog Settings

  ;Remember the installer language
  !define MUI_LANGDLL_REGISTRY_ROOT "HKCU" 
  !define MUI_LANGDLL_REGISTRY_KEY "Software\ParaEngine\Aries" 
  !define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"
  !define MUI_LANGDLL_WINDOWTITLE $(LangSelectWinTitle)
  !define MUI_LANGDLL_INFO $(LangSelectWinInfo)
  
;--------------------------------
;Pages

  !insertmacro MUI_PAGE_WELCOME
  ;!insertmacro MUI_PAGE_LICENSE $(myLicenseData)
  ;!insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  
  ;Start Menu Folder Page Configuration
  !define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU" 
  !define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\ParaEngine\Aries" 
  !define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Aries"
  
  !insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder
  
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH
  
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
;--------------------------------
;Languages
  !insertmacro MUI_LANGUAGE "SimpChinese" ;first language is the default language
  !insertmacro MUI_LANGUAGE "English" 
    
;--------------------------------
;Reserve Files
  
  ;If you are using solid compression, files that are required before
  ;the actual installation should be stored first in the data block,
  ;because this will make your installer start faster.
  
  !insertmacro MUI_RESERVEFILE_LANGDLL
  
;-----------------------------------------------------------------------------------------------------  
!define PROGRAM_NAME "Aries"
!define VERSION "0.0.2.10"

;-------------------------------
; define installer descriptions

LangString LangSelectWinTitle ${LANG_ENGLISH} "Product Language"
LangString LangSelectWinTitle ${LANG_SIMPCHINESE} "产品语言"  
LangString LangSelectWinInfo ${LANG_ENGLISH} "Please select a language."
LangString LangSelectWinInfo ${LANG_SIMPCHINESE} "请选择一个语言" 
LicenseLangString myLicenseData ${LANG_ENGLISH} "script\installer\License_enUS.txt"
LicenseLangString myLicenseData ${LANG_SIMPCHINESE} "script\installer\License_zhCN.txt"

LangString Name ${LANG_ENGLISH} "Aries"
LangString Name ${LANG_SIMPCHINESE} "哈奇小镇 -- 客服IM系统"
Name $(Name)
LangString Caption ${LANG_ENGLISH} "Aries M1"
LangString Caption ${LANG_SIMPCHINESE} "哈奇小镇 (客服IM系统)"
Caption $(Caption) 
OutFile "Release/${PROGRAM_NAME}_IM_installer.exe"
BrandingText "http://haqi.61.com"
Icon "Texture\Aries\brand\installer.ico"
UninstallIcon "Texture\Aries\brand\uninstaller.ico"

VIProductVersion ${VERSION}
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "ProductName" "${PROGRAM_NAME}"
VIAddVersionKey "FileDescription" "3D content creation and social platform for everyone"
VIAddVersionKey "LegalCopyright" "Copyright 2004-2009 ParaEngine Corporation"
#VIAddVersionKey "CompanyName" "ParaEngine"
#VIAddVersionKey "Comments" ""
#VIAddVersionKey "LegalTrademarks" "ParaEngine and NPL are registered trade marks of ParaEngine Corporation"

# uncomment the following line to make the installer silent by default.
;SilentInstall silent

;--------------------------------
;General

  ;Default installation folder
  InstallDir "$PROGRAMFILES\ParaEngine\${PROGRAM_NAME}"
  # set desktop as install directory for testing purposes
  ;installDir "$DESKTOP\pala5"
  
  ;Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\ParaEngine\Aries\${PROGRAM_NAME}" ""


;--------------------------------
;Installer Functions

LangString InstallerAlreadyRunning ${LANG_ENGLISH} "The installer is already running."
LangString InstallerAlreadyRunning ${LANG_SIMPCHINESE} "安装程序已经在运行"

Function .onInit
	;----------------------
	;prevent multiple runs
	System::Call 'kernel32::CreateMutexA(i 0, i 0, t "myMutex") i .r1 ?e'
	Pop $R0
	
	StrCmp $R0 0 +3
	 MessageBox MB_OK|MB_ICONEXCLAMATION $(InstallerAlreadyRunning)
	 Abort
	;-----------------------
	;Language selection dialog
	;!insertmacro MUI_LANGDLL_DISPLAY
	
FunctionEnd

; short cuts
LangString StringExeName ${LANG_ENGLISH} "3D Kids Online"
LangString StringExeName ${LANG_SIMPCHINESE} "哈奇小镇:3D儿童创想乐园"
LangString StringShortCutName ${LANG_ENGLISH} "3D Kids Online"
LangString StringShortCutName ${LANG_SIMPCHINESE} "哈奇小镇"

LangString StringEditorName ${LANG_ENGLISH} "3D Kids Movie Creator"
LangString StringEditorName ${LANG_SIMPCHINESE} "3D编辑器(儿童版)"
LangString StringUnInstall ${LANG_ENGLISH} "Uninstall"
LangString StringUnInstall ${LANG_SIMPCHINESE} "卸载"
; instant messaging client feature is not provided in Aries
LangString StringIMClient ${LANG_ENGLISH} "IM client"
LangString StringIMClient ${LANG_SIMPCHINESE} "哈奇小镇-客服IM"
LangString StringOfficialWeb ${LANG_ENGLISH} "Web"
LangString StringOfficialWeb ${LANG_SIMPCHINESE} "网站"

;--------------------------------
; Installer Sections
section
	# check if it is administrator
		;userInfo::getAccountType
		;pop $0
		;strCmp $0 "Admin" +3
		;messageBox MB_OK "not admin: $0"
		;return
	
	# -------------------------------------
	# Prerequisites files here: windows installer 3.1, .Net 2.0, vc8 sp1, DirectX 9, DX Update, Nvidia PhysX
	# -------------------------------------

		
	# -------------------------------------
	# Core ParaEngine SDK Files Here
	# -------------------------------------
	
	;----------------------- ParaChat ----------------
	SetOutPath $INSTDIR\ParaChat
	File /x ParaWorldChat*.* ParaChat\*.*
	SetOutPath $INSTDIR\ParaChat\avatars
	File /r ParaChat\avatars\*.*
	SetOutPath $INSTDIR\ParaChat\emoticons
	File /r ParaChat\emoticons\*.*
	SetOutPath $INSTDIR\ParaChat\images
	File /r ParaChat\images\*.*
	SetOutPath $INSTDIR\ParaChat\languages
	File /r ParaChat\languages\*.*
	SetOutPath $INSTDIR\ParaChat\settings
	File /r ParaChat\settings\*.*
	SetOutPath $INSTDIR\ParaChat\sounds
	File /r ParaChat\sounds\*.*
	SetOutPath $INSTDIR\ParaChat\src
	File /r ParaChat\src\*.*	
	
	
	# Store installation folder
	WriteRegStr HKCU "Software\ParaEngine\Aries" "" $INSTDIR

	# create a shortcuts in the start menu programs directory
    
    !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
	;Create shortcuts
		CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
		CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(StringIMClient).lnk" "$INSTDIR\ParaChat\ParaChat.exe"
		; Create desktop icon
		CreateShortCut "$DESKTOP\$(StringIMClient).lnk" "$INSTDIR\ParaChat\ParaChat.exe"
	!insertmacro MUI_STARTMENU_WRITE_END

# default section end
sectionEnd
 

# create a section to define what the uninstaller does.
# the section will always be named "Uninstall"
section "Uninstall"
	# Unregister DLL
	UnRegDLL "$INSTDIR\PEDetectActiveX.dll"
	
	RMDir /r "$INSTDIR\Audio"
	RMDir /r "$INSTDIR\chrome"
	RMDir /r "$INSTDIR\components"
	RMDir /r "$INSTDIR\config"
	RMDir /r "$INSTDIR\database"
	RMDir /r "$INSTDIR\EBooks"
	RMDir /r "$INSTDIR\greprefs"
	RMDir /r "$INSTDIR\packages"
	RMDir /r "$INSTDIR\ParaChat"
	RMDir /r "$INSTDIR\plugins"
	RMDir /r "$INSTDIR\Prerequisites"
	RMDir /r "$INSTDIR\res"
	RMDir /r "$INSTDIR\temp"
	RMDir /r "$INSTDIR\script"
	RMDir /r "$INSTDIR\Texture"
	RMDir /r "$INSTDIR\worlds\downloads"
	RMDir /r "$INSTDIR\worlds\Templates"
	RMDir /r "$INSTDIR\worlds\Official"
	RMDir /r "$INSTDIR\worlds\MyWorlds"	
	
	# RMDir /r "$INSTDIR\Screen Shots"
	delete "$INSTDIR\*.*"
		
 	RMDir "$INSTDIR" 
	
	# second, remove the link from the start menu
	delete "$DESKTOP\$(StringShortCutName).lnk"
	delete "$DESKTOP\$(StringIMClient).lnk"

	!insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
	RMDir /r "$SMPROGRAMS\$StartMenuFolder"
	
	# delete reg key
	DeleteRegKey /ifempty HKCU "Software\ParaEngine\Aries"
	
	# remove protocol
	DeleteRegKey HKCR "paraenginearies"
sectionEnd

;--------------------------------
;Uninstaller Functions

Function un.onInit
  !insertmacro MUI_UNGETLANGUAGE
FunctionEnd