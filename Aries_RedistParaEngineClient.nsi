# Author: LiXizhi, Spring
# Company: ParaEngine
# Date: 2010.4.15, Modified on 2010.7.27

;------------------------------------------------------------------------
; Aries is the internal codename of the Online Kids Theme Community
;------------------------------------------------------------------------
SetCompressor /SOLID lzma
; SetOverwrite 	on|off|try|ifnewer

!include LogicLib.nsh
!include WinVer.nsh
!include "FileFunc.nsh"
;--------------------------------
;Include Modern UI
  !include "MUI2.nsh"

;Request application privileges for Windows Vista
!ifndef CacheFolderPath
	# only request user when it is web version install. 
	RequestExecutionLevel user
!else
	RequestExecutionLevel user
!endif

;--------------------------------
;Variables

Var StartMenuFolder

Var ShortCutLinkPath
Var DesktopIconName

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING
  ;!define MUI_WELCOMEPAGE_TEXT  "This wizard will guide you through the installation of Aries. It is recommended that you close all other applications before starting Setup.Note to Win2k/XP users: You may require administrator privileges to install Aries successfully."
  !define MUI_WELCOMEFINISHPAGE_BITMAP "Texture\Aries\brand\installer.bmp"
  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP  "Texture\Aries\brand\header.bmp"

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
	Page directory dir_pre "" dir_leave
	# set to fixed local app data directory, to be compatible with the web edition. 
	!define INSTDIR "$LOCALAPPDATA\ParaEngine\Redist"
  
  ;Start Menu Folder Page Configuration
  !define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU" 
  !define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\ParaEngine\Aries" 
  !define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Aries"
  
  !insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder
  
  !insertmacro MUI_PAGE_INSTFILES

    !define MUI_FINISHPAGE_AUTOCLOSE
    #!define MUI_FINISHPAGE_NOAUTOCLOSE
	!ifdef CacheFolderPath
		#!define MUI_FINISHPAGE_RUN_NOTCHECKED
		!define MUI_FINISHPAGE_RUN
		!define MUI_FINISHPAGE_RUN_TEXT $(LaunchApp)
		!define MUI_FINISHPAGE_RUN_FUNCTION "LaunchLink"
	!else
		!define MUI_FINISHPAGE_TEXT $(LaunchText)
	!endif
	
	!insertmacro MUI_PAGE_FINISH
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
!define REDIST_VERSION "1003"
!define VERSION "1.0.0.2"
!define PluginVersion "1.0.2.1"
!define ParaEnginePluginSrcPath  "..\Client\trunk\FireBreathGit\build\bin\ParaEngineWebPlugin\Release\npParaEngineWebPlugin.dll"
;-------------------------------
; define installer descriptions

LangString LangSelectWinTitle ${LANG_ENGLISH} "Product Language"
LangString LangSelectWinTitle ${LANG_SIMPCHINESE} "产品语言"  
LangString LangSelectWinTitle ${LANG_TRADCHINESE} "產品語言"  
LangString LangSelectWinInfo ${LANG_ENGLISH} "Please select a language."
LangString LangSelectWinInfo ${LANG_SIMPCHINESE} "请选择一个语言" 
LangString LangSelectWinInfo ${LANG_TRADCHINESE} "請選擇一個語言" 
LicenseLangString myLicenseData ${LANG_ENGLISH} "script\installer\License_enUS.txt"
LicenseLangString myLicenseData ${LANG_SIMPCHINESE} "script\installer\License_zhCN.txt"


LangString Name ${LANG_ENGLISH} "Haqi Kids"
LangString Name ${LANG_SIMPCHINESE} "魔法哈奇"
LangString Name ${LANG_TRADCHINESE} "魔法哈奇"

Name $(Name)
LangString LaunchApp ${LANG_ENGLISH} "Launch $(Name)"
LangString LaunchApp ${LANG_SIMPCHINESE} "运行$(Name)"
LangString LaunchApp ${LANG_TRADCHINESE} "啟動$(Name)"

LangString LaunchText ${LANG_ENGLISH} "Click the icon on desktop to launch $(Name)"
LangString LaunchText ${LANG_SIMPCHINESE} "点击桌面图标运行$(Name)"
LangString LaunchText ${LANG_TRADCHINESE} "點擊桌面圖標運行$(Name)"
LangString Caption ${LANG_ENGLISH} "Haqi Kids v1"
LangString Caption ${LANG_SIMPCHINESE} "魔法哈奇 --3D创想乐园"
LangString Caption ${LANG_TRADCHINESE} "魔法哈奇"
LangString StringUnInstallWeb ${LANG_ENGLISH} "Uninstall"
LangString StringUnInstallWeb ${LANG_SIMPCHINESE} "卸载"
LangString StringUnInstallWeb ${LANG_TRADCHINESE} "卸載"

LangString DskCText ${LANG_ENGLISH} "The available space in your Disk C is not enough, we recommend you keep 1GB available space on Disk C. You can download $(NAME) client installer package to reinstall again ,or quit this installer and clear your Disk C!" 
LangString DskCText ${LANG_SIMPCHINESE} "您的C盘空间可能不足，本程序建议C盘可用空间大于1GB。建议退出并清理C盘空间, 或者在官网下载客户端安装包，重新安装《$(NAME)》到其他盘。" 
LangString DskCText ${LANG_TRADCHINESE} "您的C盤空間可能不足，本程序建議C盤可用空間大於1GB。建議退出並清理C盤空間, 或者在官網下載客戶端安裝包，重新安裝《$(NAME)》到其他盤。" 
LangString DskText ${LANG_ENGLISH} "The available space in your target disk isnot enough, we recommend you install $(NAME) to other disk. Please select your installing path!" 
LangString DskText ${LANG_SIMPCHINESE} "您的目标安装盘空间可能不足，建议安装《$(NAME)》到其他盘。请选择新的安装路径!" 
LangString DskText ${LANG_TRADCHINESE} "您的目標安裝盤空間可能不足，建議安裝《$(NAME)》到其他盤。請選擇新的安裝路徑!" 

LangString FolderNoPermission ${LANG_ENGLISH} "you do not have write permission to the folder you selected, please use the default install directory." 
LangString FolderNoPermission ${LANG_SIMPCHINESE} "您选择的目录没有写权限，请使用默认目录安装！" 
LangString FolderNoPermission ${LANG_TRADCHINESE} "您選擇的目錄沒有寫權限，請使用默認目錄安裝！" 


Caption $(Caption) 
!ifndef OutputFileName
	!define OutputFileName  "Release/RedistParaEngineClient${REDIST_VERSION}.exe"
!endif
OutFile "${OutputFileName}"

BrandingText "http://haqi.61.com"
!define ProgramIcon "Texture\Aries\brand\installer.ico"
Icon ${ProgramIcon}
UninstallIcon "Texture\Aries\brand\uninstaller.ico"

VIProductVersion ${VERSION}
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "ProductName" "${PROGRAM_NAME}"
VIAddVersionKey "FileDescription" "3D content creation and social platform for everyone"
VIAddVersionKey "LegalCopyright" "Copyright 2007-2010 ParaEngine Corporation"
#VIAddVersionKey "CompanyName" "ParaEngine"
#VIAddVersionKey "Comments" ""
#VIAddVersionKey "LegalTrademarks" "ParaEngine and NPL are registered trade marks of ParaEngine Corporation"

Var ShortCutName

# uncomment the following line to make the installer silent by default.
;SilentInstall silent
;-------------------------------
; Test if Disk C free space is more than 1GB, if yes, donot disply directory choose page, if no give user the choice
Function dir_pre
 
 Var /GLOBAL  NeedSpace
 ;Var /GLOBAL  DskCEnough

 StrCpy $NeedSpace "1024" 
 ${DriveSpace} "C:\" "/D=F /S=M" $R0
 IntCmp $R0 $NeedSpace is1024 lessthan1024 morethan1024
	
 is1024:
	Goto diskCIsnotEnough

 lessthan1024:
	Goto diskCIsnotEnough

 morethan1024:
	Goto diskCIsEnough

 diskCIsEnough:
	;StrCpy $DskCEnough "1"
	## enable  following line to show directory page, otherwise it will skip the dir page. 
	goto done
	abort
		
 diskCIsnotEnough:
	;StrCpy $DskCEnough "0"
	;MessageBox MB_YESNO|MB_ICONEXCLAMATION "$(DskCText)" IDYES gogoInst IDNO quitInst
	MessageBox MB_OK|MB_ICONEXCLAMATION "$(DskCText)"
	goto done
	;Quit

 ;gogoInst:	
	;Goto done
		
 ;quitInst:
	;Quit
		
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

	# checking if we have write/delete permission on the folder selected by the user
	ClearErrors
	SetOutPath "$INSTDIR\"
	FileOpen $R0 $INSTDIR\tmp.dat w
	FileClose $R0
	Delete $INSTDIR\tmp.dat
	${If} ${Errors}
		 MessageBox MB_OK|MB_ICONEXCLAMATION "$(FolderNoPermission)"
		 Abort
	${EndIf}
		
Functionend

;--------------------------------
;General

;Default installation folder
!ifdef CacheFolderPath
	InstallDir $PROGRAMFILES\$(Name)
!else
	InstallDir "$LOCALAPPDATA\ParaEngine\Redist\ParaEngineClient\"
!endif
  
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

#!ifndef CacheFolderPath
	 ${GetDrives} HDD FindHDD
#!endif
	
FunctionEnd

Function FindHDD
  ${DriveSpace} $9 "/D=F /S=M" $R0
  ${If} $R0 > $R1
    StrCpy $R1 $R0
    StrCpy $INSTDIR "$9$(Name)"
  ${EndIf}
  Push $0
FunctionEnd

;-----------------------
;prevent installed program already runs
Function CheckRunningClient
	FindProcDLL::FindProc "ParaEngineClient.exe"
	Pop $R0
	StrCmp $R0 "1" running notrun

running:
	MessageBox  MB_ICONSTOP  "魔法哈奇已在运行,请将其关闭并重新安装!"
	Quit
notrun:	

FunctionEnd


Function InstallParaEngineWebPlayer
	;----------------------- the plugin dll and registry settings ------------------------
	SetOutPath "$APPDATA\ParaEngine\ParaEngineWebPlugin\${PluginVersion}"
	; here we will just try to remove it first, just in case it works. This may set the error flag if file in use, but no user interface is displayed. 
	; hence, if the brower is not running while installing, it will update the plugin using the default name. 
	ClearErrors
	delete "$APPDATA\ParaEngine\ParaEngineWebPlugin\${PluginVersion}\npParaEngineWebPlugin.dll"
	IfErrors 0 +2
		Call HandlePluginInUse

	${If} ${FileExists} '$APPDATA\ParaEngine\ParaEngineWebPlugin\${PluginVersion}\npParaEngineWebPlugin.dll'
		# we will loop until we find a file name that is not in use and use it for registration. 
		StrCpy $0 0
loop_find_file:
			IntOp $0 $0 + 1
			${If} ${FileExists} '$APPDATA\ParaEngine\ParaEngineWebPlugin\${PluginVersion}\npParaEngineWebPlugin$0.dll'
				goto loop_find_file
			${Else}
				File /oname=npParaEngineWebPlugin$0.dll ${ParaEnginePluginSrcPath}
				RegDLL "$APPDATA\ParaEngine\ParaEngineWebPlugin\${PluginVersion}\npParaEngineWebPlugin$0.dll"
				DetailPrint "注册npParaEngineWebPlugin$0.dll"
				goto done_find_file
			${EndIf}
done_find_file:
	${Else}
		File ${ParaEnginePluginSrcPath}
		RegDLL "$APPDATA\ParaEngine\ParaEngineWebPlugin\${PluginVersion}\npParaEngineWebPlugin.dll"
	${EndIf}
	
	
	# we need to elevate the ParaEngineClient.exe to medium IL in order to run without prompt in protected mode IE in vista and win7
	WriteRegStr HKLM "SOFTWARE\Microsoft\Internet Explorer\Low Rights\ElevationPolicy\{F8941242-F623-4702-85E8-D376BC36B215}" \
                 "AppName" "ParaEngineClient.exe"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Internet Explorer\Low Rights\ElevationPolicy\{F8941242-F623-4702-85E8-D376BC36B215}" \
                 "AppPath" "$LOCALAPPDATA\ParaEngine\Redist\ParaEngineClient"
	WriteRegDWORD HKLM "SOFTWARE\Microsoft\Internet Explorer\Low Rights\ElevationPolicy\{F8941242-F623-4702-85E8-D376BC36B215}" \
                 "Policy" 0x00000003
FunctionEnd

;-----------------------
;Handle Plugin in use
Function HandlePluginInUse
	DetailPrint "3D播放器正在被使用"
	IfSilent ignore_plugin_in_use

	MessageBox MB_RETRYCANCEL|MB_ICONQUESTION \
		"3D播放器正在被使用; 请先关闭浏览器和其他程序, 然后点击'重试'(如果你不想升级请点击‘取消’)" \
		IDCANCEL ignore_plugin_in_use
	
	; now try again to see if we can delete the plugin
	ClearErrors
	delete "$APPDATA\ParaEngine\ParaEngineWebPlugin\${PluginVersion}\npParaEngineWebPlugin.dll"
	IfErrors 0 +2
		Call HandlePluginInUse

ignore_plugin_in_use:
	delete "$APPDATA\ParaEngine\ParaEngineWebPlugin\${PluginVersion}\*.dll"
FunctionEnd

Function LaunchLink
  IfSilent SkipLaunch
	ExecShell "" $ShortCutName
	Quit
SkipLaunch:
FunctionEnd

; short cuts
LangString StringExeName ${LANG_ENGLISH} "Haqi Town"
LangString StringExeName ${LANG_SIMPCHINESE} "魔法哈奇"
LangString StringExeName ${LANG_TRADCHINESE} "魔法哈奇"

LangString StringExeStandloneName ${LANG_ENGLISH} "Haqi Town"
LangString StringExeStandloneName ${LANG_SIMPCHINESE} "魔法哈奇-3D创想乐园"
LangString StringExeStandloneName ${LANG_TRADCHINESE} "魔法哈奇"

LangString StringExeSafeModeName ${LANG_ENGLISH} "Haqi Town  - SafeMode"
LangString StringExeSafeModeName ${LANG_SIMPCHINESE} "魔法哈奇(安全模式)"

LangString StringShortCutName ${LANG_ENGLISH} "Haqi Town Online(Web)"
LangString StringShortCutName ${LANG_SIMPCHINESE} "魔法哈奇(Web版)"

LangString StringOfficialSite ${LANG_ENGLISH} "official web site"
LangString StringOfficialSite ${LANG_SIMPCHINESE} "官网"

LangString StringPCShortCutName ${LANG_ENGLISH} "Haqi Town Online"
LangString StringPCShortCutName ${LANG_SIMPCHINESE} "魔法哈奇"
LangString StringPCShortCutName ${LANG_TRADCHINESE} "魔法哈奇"

;--------------------------------
; Installer Sections
section
	
	Call CheckRunningClient

	# -------------------------------------
	# Delete all files in Update to prevent old files disturbing normal files
	RMDir /r "$LOCALAPPDATA\TaoMee\Haqi\Update"
	delete "$LOCALAPPDATA\TaoMee\Haqi\version.txt"
	delete "$LOCALAPPDATA\TaoMee\Haqi\config\gameclient.config.xml"
	delete "$LOCALAPPDATA\TaoMee\Haqi\*.pkg"

	# this file is only used for dll unregistration, since it uses the same class id. 
	SetOutPath "$LOCALAPPDATA\ParaEngine\Redist\"
	${If} ${FileExists} '$LOCALAPPDATA\ParaEngine\Redist\npParaEngineWebPlugin.dll'
	${Else}
		File ${ParaEnginePluginSrcPath}
	${EndIf}
	
	SetOutPath "$LOCALAPPDATA\ParaEngine\Redist\ParaEngineClient\"
	File "ParaEngineClient.exe"
	File "..\Client\trunk\ParaEngineClientApp\version.txt"
	File AutoUpdater.dll
	
	SetOutPath "$LOCALAPPDATA\TaoMee\Haqi\"
	File "ParaEngineClient.exe"
	File AutoUpdater.dll
	File script\installer\website.html
	#File "bin\StartHaqi.bat"
	
	#-----------------------------
	# we will create different shortcut for third parties according to commandline
	#-----------------------------

	StrCpy $ShortCutLinkPath  "$INSTDIR\$(Name).exe"
	StrCpy $DesktopIconName $(StringPCShortCutName)

${GetOptions} $CMDLINE "/shortcutname" $R0 
IfErrors 0 FoundShortCut

	goto EndShortcut
FoundShortCut:	
	${GetOptions} $CMDLINE "/cmdline" $R1

	StrCpy $DesktopIconName $R0
	StrCpy $ShortCutLinkPath  "$INSTDIR\$R0.bat"

	# TODO: creating a bat file with name $R0.bat and with command line $R1
	FileOpen  $9 $ShortCutLinkPath w ; Opens an Empty File an fills it
	FileWrite $9 "@echo off$\r$\n"
	FileWrite $9 "cd /d %~dp0$\r$\n"
	FileWrite $9 "start HaqiLauncherKids.exe $R1$\r$\n"
	FileClose $9 ;Closes the filled file
EndShortcut:



	!ifdef CacheFolderPath
		SetOutPath "$LOCALAPPDATA\TaoMee\Haqi\temp\cache"
		File /x "*.???" "${CacheFolderPath}\*.*"
	!endif

	# Installing PC version to $INSTDIR
	# Delete all files in Update to prevent old files disturbing normal files
	RMDir /r "$INSTDIR\Update"
	delete "$INSTDIR\version.txt"
	delete "$INSTDIR\config\gameclient.config.xml"
	delete "$INSTDIR\*.pkg"

	SetOutPath "$INSTDIR\Shell"
	File ParaEngineClient.exe
	File bin\ParaEngineClient.exe.manifest
	SetOutPath "$INSTDIR"
	File AutoUpdater.dll
	File script\installer\website.html
	File /oname=$(Name).exe HaqiLauncherKids.exe
	File HaqiLauncherKids.exe
	File /oname=icon.ico ${ProgramIcon}

	${If} ${FileExists} '$LOCALAPPDATA\TaoMee\Haqi\config\LocalUsers.table'
		${If} ${FileExists} '$INSTDIR\config\LocalUsers.table'
		${else}
			# we will copy old user table from web location to current location, for back compatible with old users
			CopyFiles '$LOCALAPPDATA\TaoMee\Haqi\config\LocalUsers.table' '$INSTDIR\config\LocalUsers.table'
		${EndIf}
	${EndIf}
	${If} ${FileExists} '$LOCALAPPDATA\TaoMee\Haqi\worlds\DesignHouse'
		${If} ${FileExists} '$INSTDIR\worlds\DesignHouse'
		${else}
			# we will copy old user table from web location to current location, for back compatible with old users
			CopyFiles '$LOCALAPPDATA\TaoMee\Haqi\worlds\DesignHouse' '$INSTDIR\worlds\DesignHouse'
		${EndIf}
	${EndIf}

	!ifdef CacheFolderPath
		SetOutPath "$INSTDIR\temp\cache"
		File /x "*.???" "${CacheFolderPath}\*.*"
	!endif

#	Following need to elevate to adiministrator, so we disabled it
#	# run the application using our own protocol. i.e. paraenginearies://
#	ReadRegStr $R0 HKCR "paraenginearies\shell\open\command" ""
#	; only install if not installed
#	IfErrors 0 ProtocolInstalled
#		WriteRegStr HKCR "paraenginearies" "" "URL:ParaEngine"
#		WriteRegStr HKCR "paraenginearies" "URL Protocol" ""
#		WriteRegStr HKCR "paraenginearies\shell\open\command" "" '"$INSTDIR\ParaEngineClient.exe" single="true" fullscreen="false" %1'
#	Goto +2
#ProtocolInstalled:   

	# define uninstaller name
	writeUninstaller "$INSTDIR\uninstaller.exe"

	
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ParaEngineWebPlayer" \
                 "DisplayName" "魔法哈奇Web播放器"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ParaEngineWebPlayer" \
				"DisplayVersion" "${VERSION}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ParaEngineWebPlayer" \
				"Publisher" "ParaEngine Corporation"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ParaEngineWebPlayer" \
				"URLInfoAbout" "http://www.paraengine.com"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ParaEngineWebPlayer" \
                 "UninstallString" '"$INSTDIR\uninstaller.exe"'
	
	# create a shortcuts in the start menu programs directory
    # SetShellVarContext all

	!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
	;Create shortcuts
		; this should be the working directory for all shortcuts below
		SetOutPath "$LOCALAPPDATA\ParaEngine\Redist\ParaEngineClient\"
		# SetOutPath "$LOCALAPPDATA\TaoMee\Haqi\"
		CreateDirectory "$SMPROGRAMS\$StartMenuFolder"

	#-----------------------------
	# we will create different shortcut for third parties according to commandline
	#-----------------------------
	# programe file shortcut
	SetOutPath "$INSTDIR"
	CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$DesktopIconName.lnk" "$ShortCutLinkPath" "" "$INSTDIR\icon.ico"
		
	# uninstaller shortcut
	CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(StringUnInstallWeb).lnk" "$INSTDIR\uninstaller.exe"

	#Create desktop icon.
	SetOutPath "$INSTDIR"
	CreateShortCut "$DESKTOP\$DesktopIconName.lnk" "$ShortCutLinkPath" "" "$INSTDIR\icon.ico"
	StrCpy $ShortCutName "$DESKTOP\$DesktopIconName.lnk"
			
	!insertmacro MUI_STARTMENU_WRITE_END

	Call InstallParaEngineWebPlayer

# default section end
sectionEnd
 

# create a section to define what the uninstaller does.
# the section will always be named "Uninstall"
section "Uninstall"
	delete "$LOCALAPPDATA\ParaEngine\Redist\ParaEngineClient\version.txt"
	
	# Unregister DLL
	UnRegDLL "$APPDATA\ParaEngine\ParaEngineWebPlugin\${PluginVersion}\npParaEngineWebPlugin.dll"
	
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ParaEngineWebPlayer"

MessageBox MB_YESNO|MB_ICONQUESTION \
    "是否移除所有的资源文件? (如果你希望保留美术资源文件的缓存请点击‘否’)" \
    IDNO NoRemoveLabel
	
	# removes all files
	RMDir /r "$LOCALAPPDATA\TaoMee\Haqi\temp"
	RMDir /r "$LOCALAPPDATA\TaoMee\Haqi\log"
		#### uninstall PC version files
		RMDir /r "$INSTDIR\temp"
		RMDir /r "$INSTDIR\log"
	
NoRemoveLabel:
	RMDir /r "$LOCALAPPDATA\ParaEngine\Redist\ParaEngineClient"
	RMDir /r "$LOCALAPPDATA\TaoMee\Haqi\update"
	RMDir /r "$LOCALAPPDATA\TaoMee\Haqi\database"
	RMDir /r "$LOCALAPPDATA\TaoMee\Haqi\script"
	RMDir /r "$LOCALAPPDATA\TaoMee\Haqi\fonts"
	delete "$LOCALAPPDATA\TaoMee\Haqi\version.txt"
	delete "$LOCALAPPDATA\TaoMee\Haqi\*.pkg"
	delete "$LOCALAPPDATA\TaoMee\Haqi\*.*"
		
		#### uninstall PC version files
		RMDir /r "$INSTDIR\Shell"
		RMDir /r "$INSTDIR\update"
		RMDir /r "$INSTDIR\database"
		RMDir /r "$INSTDIR\script"
		RMDir /r "$INSTDIR\fonts"
		delete "$INSTDIR\version.txt"
		delete "$INSTDIR\*.pkg"
		delete "$INSTDIR\*.*"

	
	# second, remove the link from the start menu
    # SetShellVarContext all

	delete "$DESKTOP\$(StringShortCutName).lnk"
	delete "$DESKTOP\$(StringPCShortCutName).lnk"
	delete "$DESKTOP\$(StringOfficialSite).lnk"
	
	# remove start menu but not the folder, because there may be other files in it. 
	!insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
	delete "$SMPROGRAMS\$StartMenuFolder\$(StringExeName).lnk"
	delete "$SMPROGRAMS\$StartMenuFolder\$(StringExeStandloneName).lnk"
	delete "$SMPROGRAMS\$StartMenuFolder\$(StringExeSafeModeName).lnk"
	delete "$SMPROGRAMS\$StartMenuFolder\$(StringUnInstallWeb).lnk"

	RMDir /r "$APPDATA\ParaEngine\ParaEngineWebPlugin\"
	RMDir /r "$LOCALAPPDATA\ParaEngine\ParaEngineWebPlugin"
	
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
	MessageBox  MB_ICONSTOP  "魔法哈奇正在运行,请先退出，再执行卸载!"
	Quit

notrun:	

  !insertmacro MUI_UNGETLANGUAGE
FunctionEnd