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
	RequestExecutionLevel user

;--------------------------------
;Variables

   
;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING
  ;!define MUI_WELCOMEPAGE_TEXT  "This wizard will guide you through the installation of Aries. It is recommended that you close all other applications before starting Setup.Note to Win2k/XP users: You may require administrator privileges to install Aries successfully."
  ;!define MUI_WELCOMEFINISHPAGE_BITMAP "Texture\Aries\brand\installer.bmp"
  !define MUI_HEADERIMAGE
  ;!define MUI_HEADERIMAGE_BITMAP  "Texture\Aries\brand\header.bmp"

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

#  !insertmacro MUI_PAGE_WELCOME
#  !insertmacro MUI_PAGE_LICENSE $(myLicenseData)
#  !insertmacro MUI_PAGE_COMPONENTS
# !insertmacro MUI_PAGE_DIRECTORY
# 	Page directory dir_pre "" dir_leave
	# set to fixed local app data directory, to be compatible with the web edition. 
	!define INSTDIR "$LOCALAPPDATA\ParaEngine\Redist"
  
  !insertmacro MUI_PAGE_INSTFILES

    !define MUI_FINISHPAGE_AUTOCLOSE
	
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
!define PROGRAM_NAME "ParaEngineWebPlayer"
!define REDIST_VERSION "1003"
!define VERSION "1.0.0.2"
!define PluginVersion "1.0.2.1"
!define ParaEnginePluginSrcPath  "..\Client\trunk\FireBreathGit\build\bin\ParaEngineWebPlugin\Release\npParaEngineWebPlugin.dll"
;-------------------------------
; define installer descriptions

LangString LangSelectWinTitle ${LANG_ENGLISH} "Product Language"
LangString LangSelectWinTitle ${LANG_SIMPCHINESE} "产品语言"  
LangString LangSelectWinInfo ${LANG_ENGLISH} "Please select a language."
LangString LangSelectWinInfo ${LANG_SIMPCHINESE} "请选择一个语言" 
LicenseLangString myLicenseData ${LANG_ENGLISH} "script\installer\License_enUS.txt"
LicenseLangString myLicenseData ${LANG_SIMPCHINESE} "script\installer\License_zhCN.txt"

LangString Name ${LANG_ENGLISH} "ParaEngine Web3D Player"
LangString Name ${LANG_SIMPCHINESE} "ParaEngine Web 3D播放器"
Name $(Name)
LangString StringUnInstallWeb ${LANG_ENGLISH} "Uninstall ParaEngine Web Player"
LangString StringUnInstallWeb ${LANG_SIMPCHINESE} "卸载ParaEngine Web 3D播放器"

LangString DskCText ${LANG_ENGLISH} "The available space in your Disk C is not enough, we recommend you keep 1GB available space on Disk C. You can download $(NAME) client installer package to reinstall again ,or quit this installer and clear your Disk C!" 
LangString DskCText ${LANG_SIMPCHINESE} "您的C盘空间可能不足，本程序建议C盘可用空间大于1GB。建议退出并清理C盘空间, 或者在官网下载客户端安装包，重新安装《$(NAME)》到其他盘。" 
LangString DskText ${LANG_ENGLISH} "The available space in your target disk isnot enough, we recommend you install $(NAME) to other disk. Please select your installing path!" 
LangString DskText ${LANG_SIMPCHINESE} "您的目标安装盘空间可能不足，建议安装《$(NAME)》到其他盘。请选择新的安装路径!" 

Caption $(Caption) 
!ifndef OutputFileName
	!define OutputFileName  "Release/RedistParaEnginePlayer${REDIST_VERSION}.exe"
!endif
OutFile "${OutputFileName}"

BrandingText "http://www.paraengine.com"
Icon "Texture\Aries\brand\installer.ico"
UninstallIcon "Texture\Aries\brand\uninstaller.ico"

VIProductVersion ${VERSION}
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "ProductName" "${PROGRAM_NAME}"
VIAddVersionKey "FileDescription" "Web 3D player for IE, Chrome, Firefox, Safari, etc. "
VIAddVersionKey "LegalCopyright" "Copyright 2007-2013 ParaEngine Corporation"
VIAddVersionKey "CompanyName" "ParaEngine Corporation"
#VIAddVersionKey "Comments" ""
VIAddVersionKey "LegalTrademarks" "ParaEngine and NPL are registered trade marks of ParaEngine Corporation"

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
		
Functionend

;--------------------------------
;General

;Default installation folder
InstallDir "$LOCALAPPDATA\ParaEngine\Redist\ParaEngineClient\"
  
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

	${GetDrives} HDD FindHDD
	
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
	
	#Call CheckRunningClient


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
	
	
#	# run the application using our own protocol. i.e. paraengine://
#	ReadRegStr $R0 HKCR "paraengine\shell\open\command" ""
#	; only install if not installed
#	IfErrors 0 ProtocolInstalled
#		WriteRegStr HKCR "paraengine" "" "URL:ParaEngine"
#		WriteRegStr HKCR "paraengine" "URL Protocol" ""
#		WriteRegStr HKCR "paraengine\shell\open\command" "" '"$INSTDIR\ParaEngineClient.exe" single="true" fullscreen="false" %1'
#	Goto +2
#ProtocolInstalled:   

	# define uninstaller name
	writeUninstaller "$LOCALAPPDATA\ParaEngine\Redist\ParaEngineClient\uninstall paraengine player.exe"

	
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ParaEnginePlayer" \
                "DisplayName" "ParaEngine Web播放器"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ParaEnginePlayer" \
				"DisplayVersion" "${VERSION}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ParaEnginePlayer" \
				"Publisher" "ParaEngine Corporation"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ParaEnginePlayer" \
				"URLInfoAbout" "http://www.paraengine.com"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ParaEnginePlayer" \
                 "UninstallString" '"$LOCALAPPDATA\ParaEngine\Redist\ParaEngineClient\uninstall paraengine player.exe"'
	

# default section end
sectionEnd
 

# create a section to define what the uninstaller does.
# the section will always be named "Uninstall"
section "Uninstall"
	delete "$LOCALAPPDATA\ParaEngine\Redist\ParaEngineClient\version.txt"
	
	# Unregister DLL
	UnRegDLL "$APPDATA\ParaEngine\ParaEngineWebPlugin\${PluginVersion}\npParaEngineWebPlugin.dll"
	
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ParaEnginePlayer"

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
	MessageBox  MB_ICONSTOP  "关联程序正在运行,请先退出游戏并关闭浏览器，再执行卸载!"
	Quit

notrun:	
  !insertmacro MUI_UNGETLANGUAGE
FunctionEnd