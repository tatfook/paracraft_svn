# Author: LiXizhi
# Company: ParaEngine
# Date: 2008.7.1

!include LogicLib.nsh
!include WinVer.nsh
!include "script\installer\DotNET.nsh"
!define DOTNET_VERSION "2"
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
  !define MUI_LANGDLL_REGISTRY_KEY "Software\ParaEngine\ParaWorld" 
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
  !define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\ParaEngine\ParaWorld" 
  !define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "ParaWorld"
  
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
!define PROGRAM_NAME "ParaWorld"
!define VERSION "1.0.0.0"

;-------------------------------
; define installer descriptions

LangString LangSelectWinTitle ${LANG_ENGLISH} "Product Language"
LangString LangSelectWinTitle ${LANG_SIMPCHINESE} "产品语言"  
LangString LangSelectWinInfo ${LANG_ENGLISH} "Please select a language."
LangString LangSelectWinInfo ${LANG_SIMPCHINESE} "请选择一个语言" 
LicenseLangString myLicenseData ${LANG_ENGLISH} "script\installer\License_enUS.txt"
LicenseLangString myLicenseData ${LANG_SIMPCHINESE} "script\installer\License_zhCN.txt"

LangString Name ${LANG_ENGLISH} "ParaWorld"
LangString Name ${LANG_SIMPCHINESE} "帕拉巫"
Name $(Name)
LangString Caption ${LANG_ENGLISH} "ParaWorld - social web 3d platform"
LangString Caption ${LANG_SIMPCHINESE} "帕拉巫-3D社交创作平台"
Caption $(Caption) 
OutFile "Release/${PROGRAM_NAME}_${VERSION}_installer.exe"
BrandingText "http://www.pala5.com"
Icon "Texture\3DMapSystem\brand\installer.ico"
UninstallIcon "Texture\3DMapSystem\brand\installer.ico"

VIProductVersion ${VERSION}
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "ProductName" "${PROGRAM_NAME}"
VIAddVersionKey "FileDescription" "3D content creation and social platform for everyone"
VIAddVersionKey "LegalCopyright" "Copyright 2004-2008 ParaEngine Corporation"
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
LangString StringExeName ${LANG_ENGLISH} "ParaWorld Tech Demo"
LangString StringExeName ${LANG_SIMPCHINESE} "帕拉巫-技术演示"
LangString StringUnInstall ${LANG_ENGLISH} "uninstall"
LangString StringUnInstall ${LANG_SIMPCHINESE} "卸载"
LangString StringIMClient ${LANG_ENGLISH} "IM client"
LangString StringIMClient ${LANG_SIMPCHINESE} "即时通讯"
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
	
	# install windows installer 3.1 and .network framework 2.0
	!insertmacro CheckDotNET ${DOTNET_VERSION}
	
	# install visual c++ redistributable as shared assembly
	Call CheckVCRedist
		Pop $0
		strCmp  $0 "-1" pre_vc_redist pre_vc_redist_skipped
		pre_vc_redist:
			SetOutPath $INSTDIR\Prerequisites
			File "Prerequisites\vcredist_x86.exe"
			ExecWait "$INSTDIR\Prerequisites\vcredist_x86.exe"
		pre_vc_redist_skipped:
	
	# Install DirectX update
	Call GetDXVersion
	  Pop $R3
	  IntCmp $R3 900 +3 0 +3
		MessageBox "MB_OK" "Requires DirectX 9.0 or later."
		Abort
	SetOutPath $INSTDIR\Prerequisites\DirectX
	File "Prerequisites\DirectX\*.*"
	;${If} ${IsWinVista}
	;   ExecWait "$INSTDIR\Prerequisites\DirectX\DXSETUP.exe"
	;${Else}
       ExecWait "$INSTDIR\Prerequisites\DirectX\DXSETUP.exe /silent"
    ;${EndIf}

	# Install PhysX
	Call CheckPhysXRedist
		Pop $0
		strCmp  $0 "-1" pre_physx_redist pre_physx_redist_skipped
		pre_physx_redist:
			SetOutPath $INSTDIR\Prerequisites
			File "Prerequisites\PhysX_Game_installer_281.msi"
			;${If} ${IsWinVista}
			;   ExecWait '"msiexec" /i "$INSTDIR\Prerequisites\PhysX_Game_installer_281.msi"'
			;${Else}
			   ExecWait '"msiexec" /quiet /i "$INSTDIR\Prerequisites\PhysX_Game_installer_281.msi"'
			;${EndIf}
		pre_physx_redist_skipped:
		
	# -------------------------------------
	# Core ParaWorld Files Here
	# -------------------------------------
	
	;ADD PARAWORLD FILES HERE...
	
	;----------------------- Core files ------------------------
	SetOutPath $INSTDIR
	File ParaWorld.exe
	File ParaEngine.sig
	File ParaAllInOne.dll
	File NPLWebServiceClient.dll
	File NPLWebServiceClientLib.dll
	File ParaEngineManaged.dll
	File ParaIDE.dll
	File jabber-net.dll
	File MozHTMLRenderer.dll
	File PhysXLoader.dll
	File zlib1.dll
	;-- File FreeImage.dll
	;-- File SQLite3.dll
	;-- File SQLite.dll
	;-- File SQLite.NET.dll
	File copyright.txt
	File copyright_product.txt
	File readme.txt
	
	;----------------------- Config files ------------------------
	SetOutPath $INSTDIR\config
	;---- turn on full screen mode and set default languages
	StrCmp $LANGUAGE ${LANG_ENGLISH} 0 +2
		File /oname=config.txt "script\installer\config_paraworld_release_enUS.txt"
	StrCmp $LANGUAGE ${LANG_SIMPCHINESE} 0 +2
		File /oname=config.txt "script\installer\config_paraworld_release_zhCN.txt"	
		
	File config\local.ini
	File config\npl.syntax
	File config\bootstrapper_gameserver.xml

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
	
	;----------------------- Mozilla HTML renderer----------------
	SetOutPath $INSTDIR
		File xul.dll
		File xpcom.dll
		File plds4.dll
		File plc4.dll
		File nspr4.dll
		File js3250.dll
	SetOutPath $INSTDIR\chrome
		File chrome\*.*
	SetOutPath $INSTDIR\components
		File components\*.*
	SetOutPath $INSTDIR\greprefs
		File greprefs\*.*
	SetOutPath $INSTDIR\plugins
		File plugins\*.*
	SetOutPath $INSTDIR\res
		File /r res\*.*
	
	;------------------------ fonts -----------------------
	SetOutPath $INSTDIR\fonts
	File fonts\ThereChat2.ttf
	
	;------------------------ databases	-----------------------
	SetOutPath $INSTDIR\database
	File database\Account.db
	File database\Kids.db
	File database\characters.db
	File database\NameSpaceBinding.db
	File database\localMarks.db
	File database\mapplayers.db
	File database\mapmark.db
	File database\mapworldid.db
	File database\mapModel.db
	File database\mapWorldID.db
	File database\mapTileInfo.db
	File database\apps.db
	
	;------------------------- audio -----------------------
	SetOutPath $INSTDIR\Audio
		File Audio\Global.xgs
	SetOutPath $INSTDIR\Audio\Kids
		File Audio\Kids\Kids.xsb
		File Audio\Kids\Kids-Stream.xwb
		File Audio\Kids\Kids-InMemory.xwb
 	SetOutPath $INSTDIR\Audio\animals
		File /r Audio\animals\*.wav
	
	;------------------------- Temp -----------------------
	SetOutPath $INSTDIR\temp
	SetOutPath $INSTDIR\temp\worlds
	SetOutPath $INSTDIR\temp\textures
	SetOutPath $INSTDIR\temp\apps
	SetOutPath $INSTDIR\temp\tempdatabase
	SetOutPath $INSTDIR\temp\webcache
	SetOutPath $INSTDIR\temp\apps\AssetsGUID
		File temp\apps\AssetsGUID\*.asset
	SetOutPath $INSTDIR\temp\apps\BlueprintGUID
		File temp\apps\BlueprintGUID\villa_bcs_one_floor.bom
		File temp\apps\BlueprintGUID\villa_two_floor.bom
		
	;------------------------- Texture -----------------------
	SetOutPath $INSTDIR\Texture\advertisement
	File Texture\advertisement\paraenginelogo.swf
	
	;------------------------- Ebook  -----------------------
	SetOutPath $INSTDIR\EBooks
	StrCmp $LANGUAGE ${LANG_ENGLISH} 0 +2
		File EBooks\tutorial1.zip
	StrCmp $LANGUAGE ${LANG_SIMPCHINESE} 0 +2
		File EBooks\新手指南.zip
	
	;------------------------- script -----------------------
	SetOutPath $INSTDIR\script
	File /oname=mainstate.lua script\installer\mainstate_paraworld_zhCN.lua
	
	;------------------------- SDK related files ------------
	SetOutPath $INSTDIR\script\ide\ProjectTemplates
		File script\ide\ProjectTemplates\Template.xml
	SetOutPath $INSTDIR\script\ide\ProjectTemplates\Templates
		File /r /x *.scc script\ide\ProjectTemplates\Templates\*.*
	SetOutPath $INSTDIR\script\ide\UnitTest
		File script\ide\UnitTest\sample_test_file.lua
	
	;------------------------- worlds -----------------------
	SetOutPath $INSTDIR\worlds
	SetOutPath $INSTDIR\worlds\MyWorlds
	SetOutPath $INSTDIR\worlds\MyWorlds\LoginWorld
		File /r /x *.bak worlds\MyWorlds\LoginWorld\*.*
	SetOutPath $INSTDIR\worlds\MyWorlds\极地狂奔
		File /r /x *.bak worlds\MyWorlds\极地狂奔\*.*
	SetOutPath $INSTDIR\worlds\MyWorlds\群岛
		File /r /x *.bak worlds\MyWorlds\群岛\*.*	
	SetOutPath $INSTDIR\worlds\MyWorlds\LoginWorld2
		File /r /x *.bak worlds\MyWorlds\LoginWorld2\*.*	
	SetOutPath $INSTDIR\worlds\MyWorlds\PE颁奖岛
		File /r /x *.bak worlds\MyWorlds\PE颁奖岛\*.*
	SetOutPath $INSTDIR\worlds\MyWorlds\新手镇
		File /r /x *.bak worlds\MyWorlds\新手镇\*.*	
	SetOutPath $INSTDIR\worlds\MyWorlds\野人部落
		File /r /x *.bak worlds\MyWorlds\野人部落\*.*
	SetOutPath $INSTDIR\worlds\MyWorlds\赛车场1
		File /r /x *.bak worlds\MyWorlds\赛车场1\*.*	
		
	SetOutPath $INSTDIR\worlds\downloads
	SetOutPath $INSTDIR\worlds\Templates
		File worlds\Templates\*.*
	SetOutPath $INSTDIR\worlds\Templates\Empty
		File /r /x *.db /x *.bak worlds\Templates\Empty\*.*
	SetOutPath $INSTDIR\worlds\Official
		File /r /x *.bak /x *.zip worlds\Official\*.*
	
	;------------------------- Main & startup zip files  ---------------
	SetOutPath $INSTDIR
	File installer\main.pkg
	SetOutPath $INSTDIR\packages\startup
	File installer\art_model_char-1.0.pkg
	; File installer\map_model-1.0.pkg

	# -------------------------------------
	# Post setup: short cut menus, desktop menu, registry etc. 
	# -------------------------------------
	;Store installation folder
	WriteRegStr HKCU "Software\ParaEngine\ParaWorld" "" $INSTDIR
	
	# define uninstaller name
	SetOutPath $INSTDIR
	File script\installer\website.html
	writeUninstaller $INSTDIR\uninstaller.exe
	
	# create a shortcuts in the start menu programs directory
    
    !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
	;Create shortcuts
		CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
		CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(StringExeName).lnk" "$INSTDIR\ParaWorld.exe"
		CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(StringIMClient).lnk" "$INSTDIR\ParaChat\ParaChat.exe"
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
	# RMDir /r "$INSTDIR\Screen Shots"
	delete "$INSTDIR\*.*"
		
 	RMDir "$INSTDIR" 
	
	# second, remove the link from the start menu
	delete "$DESKTOP\$(StringExeName).lnk"

	!insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
	RMDir /r "$SMPROGRAMS\$StartMenuFolder"
	
	DeleteRegKey /ifempty HKCU "Software\ParaEngine\ParaWorld"
sectionEnd

;--------------------------------
;Uninstaller Functions

Function un.onInit
  !insertmacro MUI_UNGETLANGUAGE
FunctionEnd