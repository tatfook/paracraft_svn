# Author: WangTian
# Company: ParaEngine
# Date: 2009.4.30

;----------------------------------------------------------------
; Taurus is the internal codename of the ParaEngine SDK project
;----------------------------------------------------------------

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
  ;!define MUI_WELCOMEPAGE_TEXT  "This wizard will guide you through the installation of ParaEngineSDK. It is recommended that you close all other applications before starting Setup.Note to Win2k/XP users: You may require administrator privileges to install ParaEngineSDK successfully."
  !define MUI_WELCOMEFINISHPAGE_BITMAP "Texture\3DMapSystem\brand\installer.bmp"
  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP  "Texture\3DMapSystem\brand\header.bmp"
  !define MUI_FINISHPAGE_RUN "$INSTDIR\ParaEngineClient.exe"

;--------------------------------
;Language Selection Dialog Settings

  ;Remember the installer language
  !define MUI_LANGDLL_REGISTRY_ROOT "HKCU" 
  !define MUI_LANGDLL_REGISTRY_KEY "Software\ParaEngine\Taurus" 
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
  !define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\ParaEngine\Taurus" 
  !define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Taurus"
  
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
!define PROGRAM_NAME "ParaEngineSDK"
!define VERSION "1.0.1.0"

;-------------------------------
; define installer descriptions

LangString LangSelectWinTitle ${LANG_ENGLISH} "Product Language"
LangString LangSelectWinTitle ${LANG_SIMPCHINESE} "产品语言"  
LangString LangSelectWinInfo ${LANG_ENGLISH} "Please select a language."
LangString LangSelectWinInfo ${LANG_SIMPCHINESE} "请选择一个语言" 
LicenseLangString myLicenseData ${LANG_ENGLISH} "script\installer\License_enUS.txt"
LicenseLangString myLicenseData ${LANG_SIMPCHINESE} "script\installer\License_zhCN.txt"

LangString Name ${LANG_ENGLISH} "ParaEngineSDK"
LangString Name ${LANG_SIMPCHINESE} "ParaEngine SDK"
Name $(Name)
LangString Caption ${LANG_ENGLISH} "ParaEngine - Distributed 3D Computer Game Engine"
LangString Caption ${LANG_SIMPCHINESE} "ParaEngine - 分布式3D游戏引擎"
Caption $(Caption) 
OutFile "Release/${PROGRAM_NAME}_Taurus_${VERSION}_installer.exe"
BrandingText "http://www.paraengine.com"
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
  InstallDir "C:\ParaEngine\${PROGRAM_NAME}"
  
  ;Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\ParaEngine\Taurus\${PROGRAM_NAME}" ""


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
LangString StringExeName ${LANG_ENGLISH} "ParaEngine SDK (Taurus)"
LangString StringExeName ${LANG_SIMPCHINESE} "ParaEngine SDK (Taurus)"
LangString StringUnInstall ${LANG_ENGLISH} "Uninstall"
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
	# Prerequisites files here: windows installer 3.1, .Net 2.0, vc8 sp1, DirectX 9, DX Update, Nvidia PhysX
	# -------------------------------------
	
	# install visual c++ redistributable as side by side assembly
	SetOutPath $INSTDIR\Microsoft.VC90.CRT
	File Microsoft.VC90.CRT\*.*
	
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
	# Core ParaEngine SDK Files Here
	# -------------------------------------
	
	;ADD FILES HERE...
	
	;----------------------- Core files ------------------------
	SetOutPath $INSTDIR
	File ParaEngineClient.exe
	File ParaEngine.sig
	File ParaAllInOne.dll
	File PhysXLoader.dll
	File f_in_box.dll
	File FreeImage.dll
	File copyright.txt
	File readme.txt
	
	;----------------------- Config files ------------------------
	SetOutPath $INSTDIR\config
	;---- turn on full screen mode and set default languages
	StrCmp $LANGUAGE ${LANG_ENGLISH} 0 +2
		File /oname=config.txt "script\installer\config_taurus_release_enUS.txt"
	StrCmp $LANGUAGE ${LANG_SIMPCHINESE} 0 +2
		File /oname=config.txt "script\installer\config_taurus_release_zhCN.txt"	
		
	File config\local.ini
	File config\npl.syntax
	File config\bootstrapper_gameserver.xml
	File /oname=bootstrapper.xml "script\apps\Taurus\bootstrapper.xml"
	
	;------------------------ fonts -----------------------
	SetOutPath $INSTDIR\fonts
	File fonts\ThereChat2.ttf
	
	;------------------------ databases	-----------------------
	SetOutPath $INSTDIR\database
	File database\characters.db
	
	;------------------------- Temp -----------------------
	SetOutPath $INSTDIR\temp
	SetOutPath $INSTDIR\temp\worlds
	SetOutPath $INSTDIR\temp\textures
	SetOutPath $INSTDIR\temp\apps
	SetOutPath $INSTDIR\temp\tempdatabase
	SetOutPath $INSTDIR\temp\webcache

	;------------------------- 3dsmax plugins  ---------------
	SetOutPath $INSTDIR\3dsmax_plugins\3dsmax9
		File "..\World Editor\3dsMaxExporter\releaseMax9\ParaXExporterMax9_32bits.gup"
		File "..\World Editor\3dsMaxExporter\releaseMax9\ParaXExporterMax9_32bits.gup.intermediate.manifest"
		File "..\World Editor\3dsMaxExporter\releaseMax9\dxcc.dll"
		File "..\World Editor\3dsMaxExporter\releaseMax9\readme.txt"
	SetOutPath $INSTDIR\3dsmax_plugins\3dsmax8
		File "..\World Editor\3dsMaxExporter\releaseMax8\ParaXExporterMax8_32bits.gup"
		File "..\World Editor\3dsMaxExporter\releaseMax8\ParaXExporterMax8_32bits.gup.intermediate.manifest"
		File "..\World Editor\3dsMaxExporter\releaseMax8\dxcc.dll"
		File "..\World Editor\3dsMaxExporter\releaseMax8\readme.txt"
				
	;------------------------- Texture -----------------------
	
	;------------------------- script -----------------------
	SetOutPath $INSTDIR\script
	File /oname=mainstate.lua script\installer\mainstate_paraworld_zhCN.lua
	
	;------------------------- Elf character -----------------------
	SetOutPath $INSTDIR\character\v3\Elf\Female
		File character\v3\Elf\Female\ElfFemale.x
		File character\v3\Elf\Female\ElfFemaleEyeAddon00_00.dds
		File character\v3\Elf\Female\ElfFemaleEyeAddon00_01.dds
		File character\v3\Elf\Female\ElfFemaleSkin00_00.dds
		File character\v3\Elf\Female\ElfFemaleSkin00_01.dds
		File character\v3\Elf\Female\ElfFemaleSkin00_02.dds
		File character\v3\Elf\Female\ElfFemaleSkin00_03.dds
		File character\v3\Elf\Female\ElfFemaleSkin00_04.dds
		
	SetOutPath $INSTDIR\character\v3\Elf	
		File character\v3\Elf\Hair01_01.dds	
		File character\v3\Elf\Hair01_02.dds	
		File character\v3\Elf\Hair01_03.dds
		
	SetOutPath $INSTDIR\character\v3\CartoonFace\face
		File character\v3\CartoonFace\face\face_00.dds
		File character\v3\CartoonFace\face\face_00.png
		File character\v3\CartoonFace\face\face_01.dds
	SetOutPath $INSTDIR\character\v3\CartoonFace\eye
		File character\v3\CartoonFace\eye\eye_00.png
		File character\v3\CartoonFace\eye\eye_01.png
	SetOutPath $INSTDIR\character\v3\CartoonFace\eyebrow
		File character\v3\CartoonFace\eyebrow\eyebrow_00.png
		File character\v3\CartoonFace\eyebrow\eyebrow_01.png
	SetOutPath $INSTDIR\character\v3\CartoonFace\mouth
		File character\v3\CartoonFace\mouth\mouth_00.png
		File character\v3\CartoonFace\mouth\mouth_01.png
	SetOutPath $INSTDIR\character\v3\CartoonFace\nose
		File character\v3\CartoonFace\nose\nose_00.png
		File character\v3\CartoonFace\nose\nose_01.png
	SetOutPath $INSTDIR\character\v3\CartoonFace\mark
		File character\v3\CartoonFace\mark\marks_10.png
		File character\v3\CartoonFace\mark\marks_11.png
	SetOutPath $INSTDIR\character\v3\CartoonFace\faceDeco
		File character\v3\CartoonFace\faceDeco\marks_00.png
		File character\v3\CartoonFace\faceDeco\marks_01.png

	SetOutPath $INSTDIR\character\v3\Item\TextureComponents\ArmLowerTexture
		File character\v3\Item\TextureComponents\ArmLowerTexture\10011_TigerSkin_01_AL_U.dds
		File character\v3\Item\TextureComponents\ArmLowerTexture\10015_Dress_02_AL_U.dds
		File character\v3\Item\TextureComponents\ArmLowerTexture\10019_Sport_03_AL_U.dds
	SetOutPath $INSTDIR\character\v3\Item\TextureComponents\ArmUpperTexture
		File character\v3\Item\TextureComponents\ArmUpperTexture\10001_Shirt02_02_AU_U.dds
		File character\v3\Item\TextureComponents\ArmUpperTexture\10005_Shirt03_03_AU_U.dds
		File character\v3\Item\TextureComponents\ArmUpperTexture\10011_TigerSkin_01_AU_U.dds
		File character\v3\Item\TextureComponents\ArmUpperTexture\10015_Dress_02_AU_U.dds
		File character\v3\Item\TextureComponents\ArmUpperTexture\10019_Sport_03_AU_U.dds
	SetOutPath $INSTDIR\character\v3\Item\TextureComponents\FootTexture
		File character\v3\Item\TextureComponents\FootTexture\10003_Boots02_02_FO_U.dds
		File character\v3\Item\TextureComponents\FootTexture\10007_Boots03_03_FO_U.dds
		File character\v3\Item\TextureComponents\FootTexture\10014_TigerSkin_01_FO_U.dds
	SetOutPath $INSTDIR\character\v3\Item\TextureComponents\HandTexture
		File character\v3\Item\TextureComponents\HandTexture\10002_Gloves02_02_HA_U.dds
		File character\v3\Item\TextureComponents\HandTexture\10006_Gloves03_03_HA_U.dds
	SetOutPath $INSTDIR\character\v3\Item\TextureComponents\LegLowerTexture
		File character\v3\Item\TextureComponents\LegLowerTexture\10004_Pants02_02_LL_U.dds
		File character\v3\Item\TextureComponents\LegLowerTexture\10012_TigerSkin_01_LL_U.dds
		File character\v3\Item\TextureComponents\LegLowerTexture\10016_Dress_02_LL_U.dds
		File character\v3\Item\TextureComponents\LegLowerTexture\10020_Sport_03_LL_U.dds
	SetOutPath $INSTDIR\character\v3\Item\TextureComponents\LegUpperTexture
		File character\v3\Item\TextureComponents\LegUpperTexture\10004_Pants02_02_LU_U.dds
		File character\v3\Item\TextureComponents\LegUpperTexture\10008_Pants03_03_LU_U.dds
		File character\v3\Item\TextureComponents\LegUpperTexture\10020_Sport_03_LU_U.dds
		File character\v3\Item\TextureComponents\LegUpperTexture\10016_Dress_02_LU_U.dds
		File character\v3\Item\TextureComponents\LegUpperTexture\10012_TigerSkin_01_LU_U.dds
	SetOutPath $INSTDIR\character\v3\Item\TextureComponents\TorsoLowerTexture
		File character\v3\Item\TextureComponents\TorsoLowerTexture\10001_Shirt02_02_TL_U.dds
		File character\v3\Item\TextureComponents\TorsoLowerTexture\10005_Shirt03_03_TL_U.dds
		File character\v3\Item\TextureComponents\TorsoLowerTexture\10011_TigerSkin_01_TL_U.dds
		File character\v3\Item\TextureComponents\TorsoLowerTexture\10015_Dress_02_TL_U.dds
		File character\v3\Item\TextureComponents\TorsoLowerTexture\10019_Sport_03_TL_U.dds
	SetOutPath $INSTDIR\character\v3\Item\TextureComponents\TorsoUpperTexture
		File character\v3\Item\TextureComponents\TorsoUpperTexture\10001_Shirt02_02_TU_U.dds
		File character\v3\Item\TextureComponents\TorsoUpperTexture\10005_Shirt03_03_TU_U.dds
		File character\v3\Item\TextureComponents\TorsoUpperTexture\10019_Sport_03_TU_U.dds
		File character\v3\Item\TextureComponents\TorsoUpperTexture\10011_TigerSkin_01_TU_U.dds
		File character\v3\Item\TextureComponents\TorsoUpperTexture\10015_Dress_02_TU_U.dds
	SetOutPath $INSTDIR\character\v3\Item\TextureComponents\WingTexture
		File character\v3\Item\TextureComponents\WingTexture\ElfFemaleWings00_00.dds
		File character\v3\Item\TextureComponents\WingTexture\ElfFemaleWings00_01.dds

	SetOutPath $INSTDIR\character\v3\Item\ObjectComponents\FaceAddon
		File character\v3\Item\ObjectComponents\FaceAddon\OverHead_01.x
		File character\v3\Item\ObjectComponents\FaceAddon\OverHead_01.dds
	SetOutPath $INSTDIR\character\v3\Item\ObjectComponents\Head
		File character\v3\Item\ObjectComponents\Head\witchfemaleHot.x
		File character\v3\Item\ObjectComponents\Head\WitchHot.DDS
	SetOutPath $INSTDIR\character\v3\Item\ObjectComponents\WEAPON
		File character\v3\Item\ObjectComponents\WEAPON\item_1H_Torch1.x
		File character\v3\Item\ObjectComponents\WEAPON\item_1H_Torch1.dds
		File character\v3\Item\ObjectComponents\Weapon\item_1H_Torch.x
		File character\v3\Item\ObjectComponents\Weapon\item_1H_Torch2.dds
	
	;------------------------- terrain tile textures -----------------------
	SetOutPath $INSTDIR\Texture\tileset\generic
	File Texture\tileset\generic\default.dds
	File Texture\tileset\generic\c_bigroad_dark_blue.dds
	File Texture\tileset\generic\c_bigroad_light_blue.dds
	File Texture\tileset\generic\c_mudroad_dark_yellow.dds
	
	;------------------------- sample models -----------------------
	SetOutPath $INSTDIR\model\05plants\v5\01tree\IcePinaster
		File model\05plants\v5\01tree\IcePinaster\*.*
	SetOutPath $INSTDIR\character\v1\01human\baru
		File character\v1\01human\baru\*.x
		File character\v1\01human\baru\*.dds
		File character\v1\01human\baru\*.tga
		File character\v1\01human\baru\baru(0).max
		File character\v1\01human\baru\baru(4,1.0).max
		File character\v1\01human\baru\baru(5,4).max
	
	;------------------------- unisex model -----------------------
	SetOutPath $INSTDIR\model\common\ccs_unisex
		File model\common\ccs_unisex\*.x
	
	;------------------------- worlds -----------------------
	SetOutPath $INSTDIR\worlds
	SetOutPath $INSTDIR\worlds\MyWorlds
	SetOutPath $INSTDIR\worlds\MyWorlds\flatgrassland
		File /r /x *.bak worlds\MyWorlds\flatgrassland\*.*

	;------------------------- Main & startup zip files  ---------------
	SetOutPath $INSTDIR
	File installer\main.pkg

	# -------------------------------------
	# Post setup: short cut menus, desktop menu, registry etc. 
	# -------------------------------------
	;Store installation folder
	WriteRegStr HKCU "Software\ParaEngine\Taurus" "" $INSTDIR
	
	# define uninstaller name
	SetOutPath $INSTDIR
	File script\installer\website.html
	writeUninstaller $INSTDIR\uninstaller.exe
	
	# create a shortcuts in the start menu programs directory
    
    !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
	;Create shortcuts
		CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
		CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(StringExeName).lnk" "$INSTDIR\ParaEngineClient.exe"
		CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(StringOfficialWeb).lnk" "$INSTDIR\website.html"
		CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(StringUnInstall).lnk" "$INSTDIR\uninstaller.exe"
		; Create desktop icon
		CreateShortCut "$DESKTOP\$(StringExeName).lnk" "$INSTDIR\ParaEngineClient.exe"
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
	
	DeleteRegKey /ifempty HKCU "Software\ParaEngine\Taurus"
sectionEnd

;--------------------------------
;Uninstaller Functions

Function un.onInit
  !insertmacro MUI_UNGETLANGUAGE
FunctionEnd