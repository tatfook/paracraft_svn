# Author: WangTian, LiXizhi, SpringYan
# Company: ParaEngine
# Date: 2010.7.26

;------------------------------------------------------------------------
; Aries is the internal codename of the Online Kids Theme Community
;------------------------------------------------------------------------
SetCompressor /SOLID lzma

!include LogicLib.nsh
!include WinVer.nsh
!include "FileFunc.nsh"
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
  !define MUI_FINISHPAGE_RUN "$INSTDIR\ParaEngineClient.exe"

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
  ;!insertmacro MUI_PAGE_DIRECTORY
  
  # set to fixed local app data directory, to be compatible with the web edition
  !define INSTDIR "$LOCALAPPDATA\TaoMee\Haqi"
  
  ;Start Menu Folder Page Configuration
  !define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU" 
  !define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\ParaEngine\Aries" 
  !define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Aries"
  
  !insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder
  Page directory dir_pre "" dir_leave
  	  
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
!define PROGRAM_NAME "Haqi"
!define VERSION "0.0.3.40"

;-------------------------------
; define installer descriptions

LangString LangSelectWinTitle ${LANG_ENGLISH} "Product Language"
LangString LangSelectWinTitle ${LANG_SIMPCHINESE} "产品语言"  
LangString LangSelectWinInfo ${LANG_ENGLISH} "Please select a language."
LangString LangSelectWinInfo ${LANG_SIMPCHINESE} "请选择一个语言" 
LicenseLangString myLicenseData ${LANG_ENGLISH} "script\installer\License_enUS.txt"
LicenseLangString myLicenseData ${LANG_SIMPCHINESE} "script\installer\License_zhCN.txt"

LangString Name ${LANG_ENGLISH} "Aries"
LangString Name ${LANG_SIMPCHINESE} "哈奇小镇 --3D儿童创想乐园"
Name $(Name)
LangString Caption ${LANG_ENGLISH} "Aries M4"
LangString Caption ${LANG_SIMPCHINESE} "哈奇小镇 --3D儿童创想乐园 (内部测试版-M4)"
LangString DskCText ${LANG_ENGLISH} "The available space in your Disk C isnot enough, we recommend you install $(NAME) to other disk. Press Yes to continue, press NO to quit this install and clear your Disk C" 
LangString DskCText ${LANG_SIMPCHINESE} "您的C盘空间可能不足，建议安装《$(NAME)》到其他盘。按【是】继续安装，按【否】退出/清理C盘。" 
LangString DskText ${LANG_ENGLISH} "The available space in your target disk isnot enough, we recommend you install $(NAME) to other disk. Please select your installing path!" 
LangString DskText ${LANG_SIMPCHINESE} "您的目标安装盘空间可能不足，建议安装《$(NAME)》到其他盘。请选择新的安装路径!" 
Caption $(Caption) 
OutFile "Release/${PROGRAM_NAME}_${VERSION}_installer.exe"
BrandingText "http://haqi.61.com"
Icon "Texture\Aries\brand\installer.ico"
UninstallIcon "Texture\Aries\brand\uninstaller.ico"

VIProductVersion ${VERSION}
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "ProductName" "${PROGRAM_NAME}"
VIAddVersionKey "FileDescription" "3D content creation and social platform for everyone"
VIAddVersionKey "LegalCopyright" "Copyright 2004-2010 ParaEngine Corporation"
#VIAddVersionKey "CompanyName" "ParaEngine"
#VIAddVersionKey "Comments" ""
#VIAddVersionKey "LegalTrademarks" "ParaEngine and NPL are registered trade marks of ParaEngine Corporation"

# uncomment the following line to make the installer silent by default.
;SilentInstall silent

;-------------------------------
; Test if Disk C free space is more than 1GB, if yes, donot disply directory choose page, if no give user the choice
Function dir_pre
 Var /GLOBAL  NeedSpace
 StrCpy $NeedSpace "2048" 
 ${DriveSpace} "C:\" "/D=F /S=M" $R0
 IntCmp $R0 $NeedSpace is1024 lessthan1024 morethan1024
	
 is1024:
	Goto diskCIsnotEnough

 lessthan1024:
	Goto diskCIsnotEnough

 morethan1024:
	Goto diskCIsEnough

 diskCIsEnough:
	abort
		
 diskCIsnotEnough:
	MessageBox MB_YESNO|MB_ICONEXCLAMATION "$(DskCText)" IDYES gogoInst IDNO quitInst
	
 gogoInst:	
	Goto done
		
 quitInst:
	Quit
		
 done:		
Functionend

Function dir_leave
 ${GetRoot} $INSTDIR $R1
 ${DriveSpace} $R1 "/D=F /S=M" $R0
 IntCmp $R0 $NeedSpace is1024 lessthan1024 morethan1024
	
 is1024:
	Goto diskCIsnotEnough

 lessthan1024:
	Goto diskCIsnotEnough

 morethan1024:
	Goto diskCIsEnough
		
 diskCIsnotEnough:				
	MessageBox MB_OK|MB_ICONEXCLAMATION "$(DskText)"
	Abort

 diskCIsEnough:		
		
Functionend

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
; CheckMSIVersion
Function CheckMSIVersion
  Push $R0
  
  GetDllVersion "$SYSDIR\MSI.dll" $R0 $R1
  IntOp $R2 $R0 / 0x00010000
  IntOp $R3 $R0 & 0x0000FFFF
 
  IntCmp $R2 3 0 InstallMSI RightMSI
  IntCmp $R3 0 RightMSI InstallMSI RightMSI
 
  RightMSI:
    Push 0
    Goto ExitFunction
 
  InstallMSI:
    StrCpy $R0 "-1" 
    Goto ExitFunction
  ExitFunction:
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
  InstallDir "$LOCALAPPDATA\TaoMee\Haqi"
  ;InstallDir "$PROGRAMFILES\taomee\Haqi"
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
	;prevent installed program already runs
  FindProcDLL::FindProc "ParaEngineClient.exe"
  Pop $R0
  StrCmp $R0 "1" running notrun
 running:
  MessageBox  MB_ICONSTOP  "哈奇小镇正在运行,请先退出，再执行本安装程序!"
  Quit
 notrun:	

	;-----------------------
	;Language selection dialog
	;!insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

; short cuts
LangString StringExeName ${LANG_ENGLISH} "3D Kids Online"
LangString StringExeName ${LANG_SIMPCHINESE} "哈奇小镇:3D儿童创想乐园"

LangString StringExeSafeModeName ${LANG_ENGLISH} "3D Kids Online - SafeMode"
LangString StringExeSafeModeName ${LANG_SIMPCHINESE} "哈奇小镇 - 安全模式"

LangString StringShortCutName ${LANG_ENGLISH} "3D Kids Online"
LangString StringShortCutName ${LANG_SIMPCHINESE} "哈奇小镇"

LangString StringEditorName ${LANG_ENGLISH} "3D Kids Movie Creator"
LangString StringEditorName ${LANG_SIMPCHINESE} "3D编辑器(儿童版)"
LangString StringUnInstall ${LANG_ENGLISH} "Uninstall"
LangString StringUnInstall ${LANG_SIMPCHINESE} "卸载"
; instant messaging client feature is not provided in Aries
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
	
	# install visual c++ redistributable as side by side assembly
	#SetOutPath $INSTDIR\Microsoft.VC90.CRT
	#File Microsoft.VC90.CRT\*.*
	
	# Install DirectX update
	Call GetDXVersion
	  Pop $R3
	  IntCmp $R3 900 +3 0 +3
		MessageBox "MB_OK" "Requires DirectX 9.0 or later."
		Abort
	#SetOutPath $INSTDIR\Prerequisites\DirectX
	#File "Prerequisites\DirectX\*.*"
	#;${If} ${IsWinVista}
	#;   ExecWait "$INSTDIR\Prerequisites\DirectX\DXSETUP.exe"
	#;${Else}
  #     ExecWait "$INSTDIR\Prerequisites\DirectX\DXSETUP.exe /silent"
  #  ;${EndIf}

	# windows installer 3.0
	# Call CheckMSIVersion
	#	Pop $7
		
	# Install PhysX
	# Call CheckPhysXRedist
	#	Pop $0
	#	strCmp  $0 "-1" pre_physx_redist pre_physx_redist_skipped
	#	pre_physx_redist:
	#		SetOutPath $INSTDIR\Prerequisites
	#		File "Prerequisites\PhysX_Game_installer_281.msi"
	#		${If} $7 == "-1"
	#		   ExecWait '"msiexec" /i "$INSTDIR\Prerequisites\PhysX_Game_installer_281.msi"'
	#		${Else}
	#		   ExecWait '"msiexec" /quiet /i "$INSTDIR\Prerequisites\PhysX_Game_installer_281.msi"'
	#		${EndIf}
	#	pre_physx_redist_skipped:

	# -------------------------------------
	# Delete all files in INSTDIR to prevent old files disturbing normal files
	delete "$INSTDIR\*.*"
	delete "$INSTDIR\config\*.xml"
	delete "$INSTDIR\config\*.txt"
	RMDir /r "$INSTDIR\script"
	RMDir /r "$INSTDIR\database"
	RMDir /r "$INSTDIR\Update"
	# -------------------------------------
	# Core ParaEngine SDK Files Here
	# -------------------------------------
	
	;ADD FILES HERE...
	
	;----------------------- Core files ------------------------
	SetOutPath $INSTDIR
	File ParaEngineClient.exe
	;File /oname=ParaEngineClient.exe.manifest "config\ParaEngineClient.exe.manifest"
	File ParaEngineClient.dll
	File physicsbt.dll
	File ParaEngine.sig
	;File PhysXLoader.dll
	File deletefile.list
	File f_in_box.dll
	File lua.dll		
	File FreeImage.dll
	File autoUpdater.dll
	File updateversion.exe
	File copyright.txt
	File readme.txt
	File version.txt	
	File libcurl.dll 
	File sqlite.dll 
	File /oname=Assets_manifest.txt "installer\Aries\Assets_manifest0.txt"

	;----------------------- Config files ------------------------
	SetOutPath $INSTDIR\config	
	File /oname=bootstrapper.xml "script\apps\Aries\bootstrapper.xml"
	File /oname=bootstrapper_safemode.xml "script\apps\Aries\bootstrapper_safemode.xml"
	File /oname=GameClient.config.xml "config\TaoMee.GameClient.config.xml"
	File /oname=commands.xml "config\Aries.commands.xml"	
	
	;------------------------ bin -----------------------
	;SetOutPath $INSTDIR\bin
	;File bin\Taurus.bat
	;File bin\Aries.bat
	;SetOutPath $INSTDIR\script\apps\Taurus
	;File script\apps\Taurus\bootstrapper.xml
	
	;------------------------ fonts -----------------------
	SetOutPath $INSTDIR\fonts
	File fonts\ThereChat2.ttf
	
	;------------------------- audio -----------------------
	SetOutPath $INSTDIR\Audio
	; File Audio\Global.xgs
		
	;------------------------ databases	-----------------------
	SetOutPath $INSTDIR\database
	File database\characters.db
	File database\extendedcost.db
	File database\globalstore.db
	
	;------------------------- Temp -----------------------
	SetOutPath $INSTDIR\temp
	SetOutPath $INSTDIR\temp\worlds
	SetOutPath $INSTDIR\temp\textures
	SetOutPath $INSTDIR\temp\apps
	SetOutPath $INSTDIR\temp\tempdatabase
	SetOutPath $INSTDIR\temp\webcache
	SetOutPath $INSTDIR\temp\composeskin
	SetOutPath $INSTDIR\temp\composeface	
		
	;------------------------- Texture -----------------------
	
	;------------------------- script -----------------------
	SetOutPath $INSTDIR\script
	File /oname=mainstate.lua installer\Aries\mainstate_Aries_zhCN.lua
	
	;------------------------- Main & startup zip files  ---------------
	SetOutPath $INSTDIR
	File /oname=main.pkg main.pkg
	File /oname=main100819.pkg main100819.pkg




	;------------------------- Web browser ActiveX ---------------
	SetOutPath $INSTDIR
	;File "..\Client\trunk\PEDetectActiveX\PEDetectActiveX\Release\PEDetectActiveX.dll"
	File PEDetectActiveX.dll
	RegDLL "$INSTDIR\PEDetectActiveX.dll"

	;---------- dx9 dll -------
	SetOutPath $INSTDIR
	File d3dx9_43.dll													
	;-----------Audio dll ---------
	;File x3daudio1_1.dll													
	;File xactengine2_7.dll													
	;RegDLL "$INSTDIR\xactengine2_7.dll"
	File openaL32.dll
	File wrap_oal.dll
	File caudioengine.dll
		
	# -------------------------------------
	# Post setup: short cut menus, desktop menu, registry etc. 
	# -------------------------------------
	
	SetOutPath $INSTDIR\temp\cache
	File temp\cache\*.*
	
	;----- remove updates ------------
	RMDir /r "$INSTDIR\Update"

	;----------------------- Config files ------------------------
	SetOutPath $INSTDIR\config
	;---- turn on full screen mode and set default languages
	StrCmp $LANGUAGE ${LANG_ENGLISH} 0 +2
		File /oname=config.txt "script\installer\config_aries_release_enUS.txt"
	StrCmp $LANGUAGE ${LANG_SIMPCHINESE} 0 +2
		File /oname=config.txt "script\installer\config_aries_release_zhCN.txt"	
	File config\config.safemode.txt
	
	# Store installation folder
	WriteRegStr HKCU "Software\ParaEngine\Aries" "" $INSTDIR

	# run the application using our own protocol. i.e. paraenginearies://
	ReadRegStr $R0 HKCR "paraenginearies\shell\open\command" ""
	; only install if not installed
	IfErrors 0 ProtocolInstalled
		WriteRegStr HKCR "paraenginearies" "" "URL:ParaEngine"
		WriteRegStr HKCR "paraenginearies" "URL Protocol" ""
		WriteRegStr HKCR "paraenginearies\shell\open\command" "" '"$INSTDIR\ParaEngineClient.exe" single="true" fullscreen="false" %1'
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
		CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(StringExeName).lnk" "$INSTDIR\ParaEngineClient.exe"
		CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(StringOfficialWeb).lnk" "$INSTDIR\website.html"
		; CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(StringEditorName).lnk" "$INSTDIR\bin\Taurus.bat"
		CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(StringExeSafeModeName).lnk" "$INSTDIR\ParaEngineClient.exe" 'bootstrapper="config/bootstrapper_safemode.xml"'
		CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(StringUnInstall).lnk" "$INSTDIR\uninstaller.exe"
		; Create desktop icon
		CreateShortCut "$DESKTOP\$(StringShortCutName).lnk" "$INSTDIR\ParaEngineClient.exe"
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
	RMDir /r "$INSTDIR\Update"
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
	;-----------------------
	;prevent installed program already runs
  FindProcDLL::FindProc "ParaEngineClient.exe"
  Pop $R0
  StrCmp $R0 "1" running notrun
 running:
  MessageBox  MB_ICONSTOP  "哈奇小镇正在运行,请先退出，再执行卸载!"
  Quit
 notrun:	
 
 !insertmacro MUI_UNGETLANGUAGE
FunctionEnd
