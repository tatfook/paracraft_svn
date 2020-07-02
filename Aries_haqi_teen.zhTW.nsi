﻿# Author: LiXizhi
# Company: ParaEngine
# Date: 2011.12.25

;------------------------------------------------------------------------
; Aries is the internal codename of the Online Teen Theme Community
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
    
;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING
  ;!define MUI_WELCOMEPAGE_TEXT  "This wizard will guide you through the installation of Aries. It is recommended that you close all other applications before starting Setup.Note to Win2k/XP users: You may require administrator privileges to install Aries successfully."
  !define MUI_WELCOMEFINISHPAGE_BITMAP "Texture\Aries\brand\installer.teen.zhTW.bmp"
  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP  "Texture\Aries\brand\header.teen.zhTW.bmp"

;--------------------------------
;Language Selection Dialog Settings

  ;Remember the installer language
  !define MUI_LANGDLL_REGISTRY_ROOT "HKCU" 
  !define MUI_LANGDLL_REGISTRY_KEY "Software\ParaEngine\MagicCardzhTW" 
  !define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"
  !define MUI_LANGDLL_WINDOWTITLE $(LangSelectWinTitle)
  !define MUI_LANGDLL_INFO $(LangSelectWinInfo)
  
;--------------------------------
;Pages


  !insertmacro MUI_PAGE_WELCOME
  ;!insertmacro MUI_PAGE_LICENSE $(myLicenseData)
  ;!insertmacro MUI_PAGE_COMPONENTS
  ;!insertmacro MUI_PAGE_DIRECTORY

!ifdef CacheFolderPath
  Page directory dir_pre "" dir_leave
!endif

	# set to fixed local app data directory, to be compatible with the web edition. 
	!define INSTDIR "$LOCALAPPDATA\ParaEngine\Redist"
	
  ;Start Menu Folder Page Configuration
  !define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU" 
  !define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\ParaEngine\MagicCardzhTW" 
  !define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "AriesTeen"
  
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
!ifdef CacheFolderPath
!define MUI_LANGDLL_ALLLANGUAGES
!endif
  !insertmacro MUI_LANGUAGE "TradChinese" ;first language is the default language
  !insertmacro MUI_LANGUAGE "SimpChinese" 
  !insertmacro MUI_LANGUAGE "English" 
    
;--------------------------------
;Reserve Files
  
  ;If you are using solid compression, files that are required before
  ;the actual installation should be stored first in the data block,
  ;because this will make your installer start faster.
  
  !insertmacro MUI_RESERVEFILE_LANGDLL
  
;-----------------------------------------------------------------------------------------------------  
!define PROGRAM_NAME "MagicCard"
!define REDIST_VERSION "1003"
!define VERSION "1.0.0.2"
!define PluginVersion "1.0.2.1"
!define ParaEnginePluginSrcPath  "..\Client\trunk\FireBreathGit\build\bin\ParaEngineWebPlugin\Release\npParaEngineWebPlugin.dll"
!define WEBFOLDER "Haqi2zhTW"
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

LangString Name ${LANG_ENGLISH} "MagicCard"
LangString Name ${LANG_SIMPCHINESE} "魔卡大乱斗"
LangString Name ${LANG_TRADCHINESE} "魔卡大亂鬥"
Name $(Name)
LangString LaunchApp ${LANG_ENGLISH} "Launch $(Name)"
LangString LaunchApp ${LANG_SIMPCHINESE} "运行$(Name)"
LangString LaunchApp ${LANG_TRADCHINESE} "啟動$(Name)"
LangString LaunchText ${LANG_ENGLISH} "Click the icon on desktop to launch $(Name)"
LangString LaunchText ${LANG_SIMPCHINESE} "点击桌面图标运行$(Name)"
LangString LaunchText ${LANG_TRADCHINESE} "點擊桌面圖標運行$(Name)"
LangString Caption ${LANG_ENGLISH} "MagicCard"
LangString Caption ${LANG_SIMPCHINESE} "魔卡大乱斗"
LangString Caption ${LANG_TRADCHINESE} "魔卡大亂鬥"
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
	!define OutputFileName  "Release/MagicCard.zhTW.exe"
!endif
OutFile "${OutputFileName}"

BrandingText "http://www.primo168.tw/";
!define ProgramIcon "Texture\Aries\brand\haqi2.zhTW.ico"
Icon ${ProgramIcon}
UninstallIcon "Texture\Aries\brand\haqi2.zhTW.ico"

VIProductVersion ${VERSION}
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "ProductName" "${PROGRAM_NAME}"
VIAddVersionKey "FileDescription" "3D content creation and social platform for everyone"
VIAddVersionKey "LegalCopyright" "Copyright 2007-2013 ParaEngine Corporation"
#VIAddVersionKey "CompanyName" "ParaEngine"
#VIAddVersionKey "Comments" ""
#VIAddVersionKey "LegalTrademarks" "ParaEngine and NPL are registered trade marks of ParaEngine Corporation"

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
	InstallDir $PROGRAMFILES\${PROGRAM_NAME}
!else
	InstallDir "$LOCALAPPDATA\ParaEngine\Redist\ParaEngineClient\"
!endif

;--------------------------------
;Installer Functions

LangString InstallerAlreadyRunning ${LANG_ENGLISH} "The installer is already running."
LangString InstallerAlreadyRunning ${LANG_SIMPCHINESE} "安装程序已经在运行"
LangString InstallerAlreadyRunning ${LANG_TRADCHINESE} "安裝程序已經在運行"

LangString InstallerAlreadyRunningExit ${LANG_ENGLISH} "The game is running. Please close it first"
LangString InstallerAlreadyRunningExit ${LANG_SIMPCHINESE} "魔卡大乱斗已在运行,请将其关闭并重新安装!"
LangString InstallerAlreadyRunningExit ${LANG_TRADCHINESE} "魔卡大亂鬥已在運行,請將其關閉並重新安裝!"

LangString PluginAlreadyInUse ${LANG_ENGLISH} "The ParaEngine 3d plugin is in use. Please close any browser window first"
LangString PluginAlreadyInUse ${LANG_SIMPCHINESE} "3D播放器正在被使用; 请先关闭浏览器和其他程序, 然后点击'重试'(如果你不想升级请点击‘取消’)"
LangString PluginAlreadyInUse ${LANG_TRADCHINESE} "3D播放器正在被使用; 請先關閉瀏覽器和其他程序, 然後點擊'重試'(如果你不想升級請點擊'取消')"

LangString UnInstallerAlreadyRunningExit ${LANG_ENGLISH} "The game is running. Please close it first"
LangString UnInstallerAlreadyRunningExit ${LANG_SIMPCHINESE} "魔卡大乱斗正在运行,请先退出，再执行卸载!"
LangString UnInstallerAlreadyRunningExit ${LANG_TRADCHINESE} "魔卡大亂鬥正在運行,請先退出，再執行卸載!"



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

	# using the default installation location instead
#!ifndef CacheFolderPath
		${GetDrives} HDD FindHDD
#!endif
	
FunctionEnd

Function FindHDD
  ${DriveSpace} $9 "/D=F /S=M" $R0
  ${If} $R0 > $R1
    StrCpy $R1 $R0
    StrCpy $INSTDIR "$9${PROGRAM_NAME}"
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
	MessageBox  MB_ICONSTOP  $(InstallerAlreadyRunningExit)
	Quit
notrun:	

FunctionEnd

;-----------------------
;Handle Plugin in use
Function HandlePluginInUse
	DetailPrint "3D播放器正在被使用"
	IfSilent ignore_plugin_in_use

	MessageBox MB_RETRYCANCEL|MB_ICONQUESTION \
		$(PluginAlreadyInUse) \
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
	ExecShell "" "$DESKTOP\$(StringPCShortCutName).lnk"
	Quit
SkipLaunch:
FunctionEnd

; short cuts
LangString StringExeName ${LANG_ENGLISH} "MagicCard"
LangString StringExeName ${LANG_SIMPCHINESE} "魔卡大乱斗"
LangString StringExeName ${LANG_TRADCHINESE} "魔卡大亂鬥"

LangString StringExeStandloneName ${LANG_ENGLISH} "MagicCard"
LangString StringExeStandloneName ${LANG_SIMPCHINESE} "魔卡大乱斗"
LangString StringExeStandloneName ${LANG_TRADCHINESE} "魔卡大亂鬥"

LangString StringOfficialSite ${LANG_ENGLISH} "official web site"
LangString StringOfficialSite ${LANG_SIMPCHINESE} "官网"
LangString StringOfficialSite ${LANG_TRADCHINESE} "官網"

LangString StringPCShortCutName ${LANG_ENGLISH} "MagicCard"
LangString StringPCShortCutName ${LANG_SIMPCHINESE} "魔卡大乱斗"
LangString StringPCShortCutName ${LANG_TRADCHINESE} "魔卡大亂鬥"

LangString AskIfRemoveAssetFile ${LANG_ENGLISH} "Remove all asset file?"
LangString AskIfRemoveAssetFile ${LANG_SIMPCHINESE} "是否移除所有的资源文件? (如果你希望保留美术资源文件的缓存请点击‘否’)"
LangString AskIfRemoveAssetFile ${LANG_TRADCHINESE} "是否移除所有的資源文件? (如果你希望保留美術資源文件的緩存請點擊'否')"

;--------------------------------
; Installer Sections
section

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
	
	Call CheckRunningClient

	# -------------------------------------
	# Delete all files in Update to prevent old files disturbing normal files
	RMDir /r "$LOCALAPPDATA\ParaEngine\${WEBFOLDER}\Update"
	delete "$LOCALAPPDATA\ParaEngine\${WEBFOLDER}\version.txt"
	delete "$LOCALAPPDATA\ParaEngine\${WEBFOLDER}\config\gameclient.config.xml"
	delete "$LOCALAPPDATA\ParaEngine\${WEBFOLDER}\*.pkg"
	
	# this file is only used for dll unregistration, since it uses the same class id. 
	SetOutPath "$LOCALAPPDATA\ParaEngine\Redist\"
	${If} ${FileExists} '$LOCALAPPDATA\ParaEngine\Redist\npParaEngineWebPlugin.dll'
	${Else}
		File ${ParaEnginePluginSrcPath}
	${EndIf}
	
	SetOutPath "$LOCALAPPDATA\ParaEngine\Redist\ParaEngineClient\"
	File /oname=ParaEngineClient.exe "ParaEngineClient.zhTW.exe"
	File "..\Client\trunk\ParaEngineClientApp\version.txt"
	File AutoUpdater.dll
	#File "bin\StartHaqi.bat"
	
	SetOutPath "$LOCALAPPDATA\ParaEngine\${WEBFOLDER}\"
	File /oname=ParaEngineClient.exe "ParaEngineClient.zhTW.exe"
	File /oname=$(Name).exe "HaqiLauncherTeen.zhTW.exe"
	File AutoUpdater.dll
	
	!ifdef CacheFolderPath
		SetOutPath "$LOCALAPPDATA\ParaEngine\${WEBFOLDER}\temp\cache"
		File /x "*.???" "${CacheFolderPath}\*.*"
	!endif

	# Installing PC version to $INSTDIR
	# Delete all files in Update to prevent old files disturbing normal files
	RMDir /r "$INSTDIR\Update"
	delete "$INSTDIR\version.txt"
	delete "$INSTDIR\config\gameclient.config.xml"
	delete "$INSTDIR\*.pkg"
		
	SetOutPath "$INSTDIR\Shell"
	File /oname=ParaEngineClient.exe "ParaEngineClient.zhTW.exe"
	File bin\ParaEngineClient.exe.manifest
	SetOutPath "$INSTDIR"
	File AutoUpdater.dll
	File /oname=${PROGRAM_NAME}.exe HaqiLauncherTeen.zhTW.exe
	File /oname=icon.ico ${ProgramIcon}

	${If} ${FileExists} '$LOCALAPPDATA\ParaEngine\${WEBFOLDER}\config\LocalUsers.table'
		${If} ${FileExists} '$INSTDIR\config\LocalUsers.table'
		${else}
			# we will copy old user table from web location to current location, for back compatible with old users
			CopyFiles '$LOCALAPPDATA\ParaEngine\${WEBFOLDER}\config\LocalUsers.table' '$INSTDIR\config\LocalUsers.table'
		${EndIf}
	${EndIf}
	${If} ${FileExists} '$LOCALAPPDATA\ParaEngine\${WEBFOLDER}\worlds\DesignHouse'
		${If} ${FileExists} '$INSTDIR\worlds\DesignHouse'
		${else}
			# we will copy old user table from web location to current location, for back compatible with old users
			CopyFiles '$LOCALAPPDATA\ParaEngine\${WEBFOLDER}\worlds\DesignHouse' '$INSTDIR\worlds\DesignHouse'
		${EndIf}
	${EndIf}

	!ifdef CacheFolderPath
		SetOutPath "$INSTDIR\temp\cache"
		File /x "*.???" "${CacheFolderPath}\*.*"
	!endif

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

	
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\MagicCardzhTW" \
                 "DisplayName" "$(Name)"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\MagicCardzhTW" \
				"DisplayVersion" "${VERSION}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\MagicCardzhTW" \
				"Publisher" "SNS Plus"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\MagicCardzhTW" \
				"URLInfoAbout" "http://www.primo168.tw/"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\MagicCardzhTW" \
                 "UninstallString" '"$INSTDIR\uninstaller.exe"'

	# create a shortcuts in the start menu programs directory
    
	!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
	;Create shortcuts
		; this should be the working directory for all shortcuts below
		SetOutPath "$LOCALAPPDATA\ParaEngine\Redist\ParaEngineClient\"
		CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
		## PC ver shortcut
		SetOutPath "$INSTDIR"
		CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(StringExeStandloneName).lnk" "$INSTDIR\${PROGRAM_NAME}.exe" "" "$INSTDIR\icon.ico"
		CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(StringUnInstallWeb).lnk" "$INSTDIR\uninstaller.exe"
	
	; Create desktop icon.
		;StrCmp $DskCEnough "0" +1
		
		SetOutPath "$INSTDIR"
		CreateShortCut "$DESKTOP\$(StringPCShortCutName).lnk" "$INSTDIR\${PROGRAM_NAME}.exe" "" "$INSTDIR\icon.ico"
			
	!insertmacro MUI_STARTMENU_WRITE_END
	

# default section end
sectionEnd
 

# create a section to define what the uninstaller does.
# the section will always be named "Uninstall"
section "Uninstall"
	delete "$LOCALAPPDATA\ParaEngine\Redist\ParaEngineClient\version.txt"
	
	# Unregister DLL
	UnRegDLL "$APPDATA\ParaEngine\ParaEngineWebPlugin\${PluginVersion}\npParaEngineWebPlugin.dll"
	
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\MagicCardzhTW"

MessageBox MB_YESNO|MB_ICONQUESTION \
    $(AskIfRemoveAssetFile) \
    IDNO NoRemoveLabel
	
	# removes all files
	RMDir /r "$LOCALAPPDATA\ParaEngine\${WEBFOLDER}\temp"
	RMDir /r "$LOCALAPPDATA\ParaEngine\${WEBFOLDER}\log"
		#### uninstall PC version files
		RMDir /r "$INSTDIR\temp"
		RMDir /r "$INSTDIR\log"
	
NoRemoveLabel:
	RMDir /r "$LOCALAPPDATA\ParaEngine\Redist\ParaEngineClient"
	RMDir /r "$LOCALAPPDATA\ParaEngine\${WEBFOLDER}\update"
	RMDir /r "$LOCALAPPDATA\ParaEngine\${WEBFOLDER}\database"
	RMDir /r "$LOCALAPPDATA\ParaEngine\${WEBFOLDER}\script"
	RMDir /r "$LOCALAPPDATA\ParaEngine\${WEBFOLDER}\fonts"
	delete "$LOCALAPPDATA\ParaEngine\${WEBFOLDER}\version.txt"
	delete "$LOCALAPPDATA\ParaEngine\${WEBFOLDER}\*.pkg"
	delete "$LOCALAPPDATA\ParaEngine\${WEBFOLDER}\*.*"
		
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
	delete "$DESKTOP\$(StringPCShortCutName).lnk"
	delete "$DESKTOP\$(StringOfficialSite).lnk"
	
	# remove start menu but not the folder, because there may be other files in it. 
	!insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
	delete "$SMPROGRAMS\$StartMenuFolder\$(StringExeName).lnk"
	delete "$SMPROGRAMS\$StartMenuFolder\$(StringExeStandloneName).lnk"
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
	MessageBox  MB_ICONSTOP  $(UnInstallerAlreadyRunningExit)
	Quit

notrun:	

  !insertmacro MUI_UNGETLANGUAGE
FunctionEnd