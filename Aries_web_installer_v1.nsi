# Author: LiXizhi
# Company: ParaEngine
# Date: 2009.11.5
# Desc: it will generate a small file AriesWebInstallerV1.exe file(<100KB), upload this file to web server 
# and put the actual installer files listed below to their actual position. 
#	- Currently, only ARIES_INSTALLER_URL is used
# @Note: modify the URL as necessary and use CDN at production time. 
# @see http://pedn/Main/AriesWebInstallTest for example of deploy page. 
# @Note: external plugin http://nsis.sourceforge.net/Inetc_plug-in is used for downloading with auto resume

;------------------------------------------------------------------------
; Aries is the internal codename of the Online Kids Theme Community
;------------------------------------------------------------------------

!define ARIES_INSTALLER_URL "http://update.61.com/haqi/web/Haqi_0.0.2.28_installer.exe"

!include LogicLib.nsh

; The file to write
OutFile "Release/HaqiWebInstaller_0.0.2.28.exe"

;Request application privileges for Windows Vista
  RequestExecutionLevel admin

;--------------------------------
; UI
; The name of the installer
LoadLanguageFile "${NSISDIR}\Contrib\Language files\SimpChinese.nlf"
LangString Name ${LANG_ENGLISH} "Haqi Town"
LangString Name ${LANG_SIMPCHINESE} "哈奇小镇 --3D儿童创想乐园"
Name $(Name)
LangString Caption ${LANG_ENGLISH} "Haqi Town - game world for kids"
LangString Caption ${LANG_SIMPCHINESE} "哈奇小镇 --3D儿童创想乐园 (内部测试版-M4)"
Caption $(Caption) 
BrandingText "http://haqi.61.com"
Icon "Texture\Aries\brand\installer.ico"

;--------------------------------
;Installer Functions

LangString InstallerAlreadyRunning ${LANG_ENGLISH} "The installer is already running."
LangString InstallerAlreadyRunning ${LANG_SIMPCHINESE} "安装程序已经在运行"

LangString AlreadyInstalledString ${LANG_ENGLISH} "You already installed a copy of the application. Do you want to install it again?"
LangString AlreadyInstalledString ${LANG_SIMPCHINESE} "您已经安装了本产品的一个版本. 你是否要重新安装?"

;-------------------------------
; CheckMSIVersion
Function CheckMSIVersion
  GetDllVersion "$SYSDIR\MSI.dll" $R0 $R1
  IntOp $R2 $R0 / 0x00010000
  IntOp $R3 $R0 & 0x0000FFFF
 
  IntCmp $R2 3 0 InstallMSI RightMSI
  IntCmp $R3 1 RightMSI InstallMSI RightMSI
 
  RightMSI:
    Push 0
    Goto ExitFunction
 
  InstallMSI:
    MessageBox MB_OK|MB_ICONEXCLAMATION \
"您需要先安装Windows安装驱动3.1以上版本才能继续; 请参见官网http://haqi.61.com"
    ; Push 1
    quit
    Goto ExitFunction
  ExitFunction:
FunctionEnd

Function .onInit
	;----------------------
	;prevent multiple runs
	System::Call 'kernel32::CreateMutexA(i 0, i 0, t "myMutex_viewer") i .r1 ?e'
	Pop $R0
	
	StrCmp $R0 0 +3
	 MessageBox MB_OK|MB_ICONEXCLAMATION $(InstallerAlreadyRunning)
	 Abort
	
	ReadRegStr $0 HKCR "paraenginearies" ""
	${If} $0 == "URL:ParaEngine"
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
; The download and install
Section "" 

	;----------------------
	; check msi version
	; Call CheckMSIVersion
	
  ;----------------------------
  ; Download Aries:
  DetailPrint "正在下载: 哈奇小镇 初始资源文件"

  ;----------------------------
  ; method1: use inetc plug-in to download
  ; uncomment to use inetc plug-in, which supports resume/retry.
  inetc::get \
	/CAPTION "哈奇小镇 安装程序" \
	/CANCELTEXT "退出安装"\
	/QUESTION "你是否要终止哈奇小镇的安装?"\
	/RESUME "你的网络连接断开了!请点击重试(R)按钮重新连接并继续下载..." \
	/TRANSLATE "正在下载 %s" "链接中..." "秒" "分" "小时" "" "%dkB (%d%%) of %dkB @ %d.%01dkB/s" "(还剩下 %d %s%s)" \
	${ARIES_INSTALLER_URL} "$TEMP\AriesInstaller.exe" /END
  Pop $0
  ${If} $0 != "OK"
	MessageBox MB_OK|MB_ICONEXCLAMATION  "下载失败了, 请重新安装或查看官网帮助. $\n$0" IDOK GiveUp
  ${EndIf}
  goto Download_OK
  
  ;---------------------------- 
  ; method2: use default downloader
  ; uncomment to use default nsis downloader: No resume/retry is supported. 
  ; NSISDL::download  /TRANSLATE2 "正在下载 %s" "链接中..." " (还剩下 1 秒钟)"	" (还剩下 1 分钟)"	" (还剩下 1 小时)"	" (还剩下 %u 秒钟)"	" (还剩下 %u 分钟)"	" (还剩下 %u 小时)"	"%skB (%d%%) of %skB @ %u.%01ukB/s" ${ARIES_INSTALLER_URL} "$TEMP\AriesInstaller.exe" 
  DetailPrint "下载完毕"
  Pop $0
  ${If} $0 == "cancel"
    goto GiveUp
  ${ElseIf} $0 != "success"
    MessageBox MB_OK|MB_ICONEXCLAMATION  "下载失败了, 请重新安装或查看官网帮助. $\n$0" IDOK GiveUp
  ${EndIf}

Download_OK:  
  DetailPrint "等待 安装程序结束。"
  ExecWait '$TEMP\AriesInstaller.exe' $0
  DetailPrint "安装/升级完成. 退出代码 = '$0'. 删除临时文件"
  Delete "$TEMP\AriesInstaller.exe"
  DetailPrint "安装完成"
  goto Install_complete

GiveUp:
  DetailPrint "安装被用户终止了"
  Quit
  
Install_complete:
  DetailPrint "继续安装"
  Quit
  
SectionEnd