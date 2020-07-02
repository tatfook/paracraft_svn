# Author: LiXizhi
# Company: ParaEngine
# Date: 2008.10.16

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
  ;!define MUI_WELCOMEPAGE_TEXT  "This wizard will guide you through the installation of ParaWorld.It is recommended that you close all other applications before starting Setup.Note to Win2k/XP users: You may require administrator privileges to install ParaWorld successfully."
  !define MUI_WELCOMEFINISHPAGE_BITMAP "Texture\3DMapSystem\brand\installer.bmp"
  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP  "Texture\3DMapSystem\brand\header.bmp"
  !define MUI_FINISHPAGE_RUN "$INSTDIR\ParaWorld.exe"

;--------------------------------
;Language Selection Dialog Settings

  ;Remember the installer language
  !define MUI_LANGDLL_REGISTRY_ROOT "HKCU" 
  !define MUI_LANGDLL_REGISTRY_KEY "Software\ParaEngine\Pala5" 
  !define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"
  !define MUI_LANGDLL_WINDOWTITLE $(LangSelectWinTitle)
  !define MUI_LANGDLL_INFO $(LangSelectWinInfo)
  
;--------------------------------
;Pages

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE $(myLicenseData)
  ;!insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  
  ;Start Menu Folder Page Configuration
  !define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU" 
  !define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\ParaEngine\Pala5" 
  !define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Pala5"
  
  !insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder
  
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH
  
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
;--------------------------------
;Languages
  !insertmacro MUI_LANGUAGE "English" ;first language is the default language
  !insertmacro MUI_LANGUAGE "SimpChinese"
    
;--------------------------------
;Reserve Files
  
  ;If you are using solid compression, files that are required before
  ;the actual installation should be stored first in the data block,
  ;because this will make your installer start faster.
  
  !insertmacro MUI_RESERVEFILE_LANGDLL
  
;-----------------------------------------------------------------------------------------------------  
!define PROGRAM_NAME "Pala5"
!define VERSION "1.0.0.0"

;-------------------------------
; define installer descriptions

LangString LangSelectWinTitle ${LANG_ENGLISH} "Product Language"
LangString LangSelectWinTitle ${LANG_SIMPCHINESE} "产品语言"  
LangString LangSelectWinInfo ${LANG_ENGLISH} "Please select a language."
LangString LangSelectWinInfo ${LANG_SIMPCHINESE} "请选择一个语言" 
LicenseLangString myLicenseData ${LANG_ENGLISH} "script\apps\Aquarius\Installer\License_enUS.txt"
LicenseLangString myLicenseData ${LANG_SIMPCHINESE} "script\apps\Aquarius\Installer\License_zhCN.txt"

LangString Name ${LANG_ENGLISH} "ParaWorld (update)"
LangString Name ${LANG_SIMPCHINESE} "帕拉巫 (升级)"
Name $(Name)
LangString Caption ${LANG_ENGLISH} "ParaWorld - social web 3d platform - (update)"
LangString Caption ${LANG_SIMPCHINESE} "帕拉巫-3D社交创作平台-(升级)"
Caption $(Caption) 
OutFile "Release/${PROGRAM_NAME}_${VERSION}_updater_installer.exe"
BrandingText "http://www.pala5.com"
Icon "Texture\3DMapSystem\brand\installer.ico"
UninstallIcon "Texture\3DMapSystem\brand\installer.ico"

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

;-------------------------------
; Test if Visual Studio Redistributables 2008 installed
; Returns -1 if there is no VC redistributables installed
Function CheckVCRedist
   Push $R0
   ClearErrors
   # guid for vc++ 2005 SP1 
   # ReadRegDword $R0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{7299052b-02a4-4627-81f2-1818da5d550d}" "Version"
   # guid for vc++ 2008
   ReadRegDword $R0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{FF66E9F6-83E7-3A3E-AF14-8DE9A809A6A4}" "Version"

   ; if vc++ redist not installed, install it
   IfErrors 0 VSRedistInstalled
   StrCpy $R0 "-1"
   Goto +2
VSRedistInstalled:
   DetailPrint "Visual C++ Redistributables 2008 already installed"
   Exch $R0
FunctionEnd


;-------------------------------
; Test if Nvidia PhysX installed, modify version "2.8.1" to the one you used.
; Returns -1 if there is no PhysX installed
Function CheckPhysXRedist
   Push $R0
   ClearErrors
   ReadRegDword $R0 HKLM "SOFTWARE\AGEIA Technologies\PhysX_A32_Engines" "2.8.1"

   ; if not installed, install it
   IfErrors 0 PhysXRedistInstalled
   StrCpy $R0 "-1"
   Goto +2
PhysXRedistInstalled:
   DetailPrint "PhysXRedist already installed"
   Exch $R0
FunctionEnd

;-------------------------------
; get DirectX version
Function GetDXVersion
    Push $0
    Push $1
 
    ReadRegStr $0 HKLM "Software\Microsoft\DirectX" "Version"
    IfErrors noDirectX
 
    StrCpy $1 $0 2 5    ; get the minor version
    StrCpy $0 $0 2 2    ; get the major version
    IntOp $0 $0 * 100   ; $0 = major * 100 + minor
    IntOp $0 $0 + $1
    Goto done
 
    noDirectX:
      StrCpy $0 0
 
    done:
      Pop $1
      Exch $0
FunctionEnd
  

;--------------------------------
;General

  ;Default installation folder
  InstallDir "$PROGRAMFILES\ParaEngine\${PROGRAM_NAME}"
  # set desktop as install directory for testing purposes
  ;installDir "$DESKTOP\pala5"
  
  ;Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\ParaEngine\ParaWorld\${PROGRAM_NAME}" ""


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
	!insertmacro MUI_LANGDLL_DISPLAY
	
FunctionEnd

; short cuts
LangString StringExeName ${LANG_ENGLISH} "ParaWorld_v1"
LangString StringExeName ${LANG_SIMPCHINESE} "帕拉巫_v1"
LangString StringUnInstall ${LANG_ENGLISH} "uninstall"
LangString StringUnInstall ${LANG_SIMPCHINESE} "卸载"
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
	# Prerequisites files here: windows installer 3.1, vc8 sp1, DirectX 9, DX Update, Nvidia PhysX
	# -------------------------------------
	
	# install windows installer 3.1
	!insertmacro CheckMSI "3.1"
	
	# install visual c++ redistributable as shared assembly
	# Call CheckVCRedist
	#	Pop $0
	#	strCmp  $0 "-1" pre_vc_redist pre_vc_redist_skipped
	#	pre_vc_redist:
	#		SetOutPath $INSTDIR\Prerequisites
	#		File "Prerequisites\vcredist_x86.exe"
	#		ExecWait "$INSTDIR\Prerequisites\vcredist_x86.exe"
	#	pre_vc_redist_skipped:
	
	# Install DirectX update
	#Call GetDXVersion
	# Pop $R3
	#  IntCmp $R3 900 +3 0 +3
	#	MessageBox "MB_OK" "Requires DirectX 9.0 or later."
	#	Abort
	#SetOutPath $INSTDIR\Prerequisites\DirectX
	#File "Prerequisites\DirectX\*.*"
	#;${If} ${IsWinVista}
	#;   ExecWait "$INSTDIR\Prerequisites\DirectX\DXSETUP.exe"
	#;${Else}
    #   ExecWait "$INSTDIR\Prerequisites\DirectX\DXSETUP.exe /silent"
    #;${EndIf}

	# Install PhysX
	#Call CheckPhysXRedist
	#	Pop $0
	#	strCmp  $0 "-1" pre_physx_redist pre_physx_redist_skipped
	#	pre_physx_redist:
	#		SetOutPath $INSTDIR\Prerequisites
	#		File "Prerequisites\PhysX_Game_installer_281.msi"
	#		;${If} ${IsWinVista}
	#		;   ExecWait '"msiexec" /i "$INSTDIR\Prerequisites\PhysX_Game_installer_281.msi"'
	#		;${Else}
	#		   ExecWait '"msiexec" /quiet /i "$INSTDIR\Prerequisites\PhysX_Game_installer_281.msi"'
	#		;${EndIf}
	#	pre_physx_redist_skipped:
		
	# -------------------------------------
	# Core ParaWorld Files Here
	# -------------------------------------
	
	;ADD PARAWORLD FILES HERE...
	
	;----------------------- Core files ------------------------
	SetOutPath $INSTDIR
	File ParaWorld.exe
	File ParaEngine.sig
	File PhysXLoader.dll
	File zlib1.dll
	File copyright.txt
	File copyright_product.txt
	File readme.txt
	
	;----------------------- Config files ------------------------
	SetOutPath $INSTDIR\config
	;---- turn on full screen mode and set default languages
	StrCmp $LANGUAGE ${LANG_ENGLISH} 0 +2
		File /oname=config.txt "script\apps\Aquarius\Installer\config_zhCN.txt"
	StrCmp $LANGUAGE ${LANG_SIMPCHINESE} 0 +2
		File /oname=config.txt "script\apps\Aquarius\Installer\config_zhCN.txt"	
		
	File config\local.ini
	File config\npl.syntax
	File config\jgsl.config.xml
	File config\bootstrapper_gameserver.xml
	File /oname=bootstrapper.xml "script\apps\Aquarius\bootstrapper.xml"
	File config\paraworld.ver

	;------------------------ fonts -----------------------
	SetOutPath $INSTDIR\fonts
	;--File fonts\ThereChat2.ttf
	
	;------------------------ databases	-----------------------
	SetOutPath $INSTDIR\database
	File database\characters.db
	File database\NameSpaceBinding.db
	File database\apps.db

	;------------------------- Texture -----------------------
	SetOutPath $INSTDIR\Texture\advertisement
	
	
	;------------------------- script -----------------------
	SetOutPath $INSTDIR\script
	File /oname=mainstate.lua script\apps\Aquarius\Installer\mainstate.lua
	
	;------------------------- SDK related files ------------
	
	;------------------------- worlds -----------------------
	SetOutPath $INSTDIR\worlds
	SetOutPath $INSTDIR\worlds\MyWorlds
	
	#RMDir /r "$INSTDIR\worlds\MyWorlds\AlphaWorld"
	#SetOutPath $INSTDIR\worlds\MyWorlds\AlphaWorld
	#	File /r /x QuestStatus.db /x *.bak worlds\MyWorlds\AlphaWorld\*.*
		
	#SetOutPath $INSTDIR\worlds\MyWorlds\DoodleWorld
	#	File /r /x QuestStatus.db /x *.bak worlds\MyWorlds\DoodleWorld\*.*	
	
		
	SetOutPath $INSTDIR\worlds\downloads
	SetOutPath $INSTDIR\worlds\Templates
		File worlds\Templates\*.*
	SetOutPath $INSTDIR\worlds\Templates\Empty
		File /r /x *.db /x *.bak worlds\Templates\Empty\*.*
	
	;--SetOutPath $INSTDIR\worlds\Official
	;--	File /r /x *.bak /x *.zip worlds\Official\*.*
		
	#SetOutPath $INSTDIR\Audio
	#	File Audio\Global.xgs
	#SetOutPath $INSTDIR\Audio\Kids
	#	File Audio\Kids\Kids.xsb
	#	File Audio\Kids\Kids-Stream.xwb
	#	File Audio\Kids\Kids-InMemory.xwb
 	# SetOutPath $INSTDIR\Audio\animals
	# 	File /r Audio\animals\*.wav
	
	;------------------------- Temp -----------------------
	SetOutPath $INSTDIR\temp
	SetOutPath $INSTDIR\temp\worlds
	SetOutPath $INSTDIR\temp\textures
	RMDir /r "$INSTDIR\temp\apps"
	SetOutPath $INSTDIR\temp\apps
	RMDir /r "$INSTDIR\temp\composeface"
	RMDir /r "$INSTDIR\temp\composeskin"
	SetOutPath $INSTDIR\temp\tempdatabase
	SetOutPath $INSTDIR\temp\webcache
	SetOutPath $INSTDIR\temp\apps\AssetsGUID
		File temp\apps\AssetsGUID\*.asset
	SetOutPath $INSTDIR\temp\apps\BlueprintGUID
		File temp\apps\BlueprintGUID\villa_two_floor.bom
	
		
	SetOutPath $INSTDIR\script\ide\ProjectTemplates
		File script\ide\ProjectTemplates\Template.xml
	SetOutPath $INSTDIR\script\ide\ProjectTemplates\Templates
		File /r /x *.scc script\ide\ProjectTemplates\Templates\*.*
	SetOutPath $INSTDIR\script\ide\UnitTest
		File script\ide\UnitTest\sample_test_file.lua
				
	
	;------------------------- Main & startup zip files  ---------------
	SetOutPath $INSTDIR
	File /oname=main.pkg "installer\main.pkg"
	#File /oname=main_texture.pkg "installer\main_texture.pkg"
	#SetOutPath $INSTDIR\packages\startup
	#File installer\art_model_char-1.0.pkg
	

	;------------------------- Web browser ActiveX ---------------
	SetOutPath $INSTDIR
	File "..\ParaEngine plugins\PEDetectActiveX\PEDetectActiveX\Release\PEDetectActiveX.dll"
	RegDLL "$INSTDIR\PEDetectActiveX.dll"


	# -------------------------------------
	# Post setup: short cut menus, desktop menu, registry etc. 
	# -------------------------------------
	;Store installation folder
	WriteRegStr HKCU "Software\ParaEngine\Pala5" "" $INSTDIR
	
	;run the application using our own protocol. i.e. paraworldviewer://
	ReadRegStr $R0 HKCR "paraworldviewer\shell\open\command" ""
	; only install if not installed
	IfErrors 0 ProtocolInstalled
		WriteRegStr HKCR "paraworldviewer" "" "URL:ParaEngine"
		WriteRegStr HKCR "paraworldviewer" "URL Protocol" ""
		WriteRegStr HKCR "paraworldviewer\shell\open\command" "" '"$INSTDIR\ParaWorld.exe" single="true" fullscreen="false" %1'
	Goto +2
ProtocolInstalled:   
	
	# define uninstaller name
	SetOutPath $INSTDIR
	File script\installer\website.html
	writeUninstaller $INSTDIR\uninstaller.exe
	
	# create a shortcuts in the start menu programs directory
    
    !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
	;Create shortcuts
		CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
		CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(StringExeName).lnk" "$INSTDIR\ParaWorld.exe"
		CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(StringOfficialWeb).lnk" "$INSTDIR\website.html"
		CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(StringUnInstall).lnk" "$INSTDIR\uninstaller.exe"
		; Create desktop icon
		CreateShortCut "$DESKTOP\$(StringExeName).lnk" "$INSTDIR\ParaWorld.exe"
	!insertmacro MUI_STARTMENU_WRITE_END

# default section end
sectionEnd
 

# create a section to define what the uninstaller does.
# the section will always be named "Uninstall"
section "Uninstall"
	;To Unregister a DLL
	UnregDLL "$INSTDIR\PEDetectActiveX.dll"
	
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
	RMDir /r "$INSTDIR\worlds\MyWorlds\AlphaWorld"
	
	# RMDir /r "$INSTDIR\Screen Shots"
	delete "$INSTDIR\*.*"
		
 	RMDir "$INSTDIR" 
	
	# second, remove the link from the start menu
	delete "$DESKTOP\$(StringExeName).lnk"

	!insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
	RMDir /r "$SMPROGRAMS\$StartMenuFolder"
	
	DeleteRegKey /ifempty HKCU "Software\ParaEngine\Pala5"
	DeleteRegKey HKCR "Pala5"
	
sectionEnd

;--------------------------------
;Uninstaller Functions

Function un.onInit
  !insertmacro MUI_UNGETLANGUAGE
FunctionEnd