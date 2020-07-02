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
LangString Name ${LANG_SIMPCHINESE} "����С�� --3D��ͯ������԰"
Name $(Name)
LangString Caption ${LANG_ENGLISH} "Haqi Town - game world for kids"
LangString Caption ${LANG_SIMPCHINESE} "����С�� --3D��ͯ������԰ (�ڲ����԰�-M4)"
Caption $(Caption) 
BrandingText "http://haqi.61.com"
Icon "Texture\Aries\brand\installer.ico"

;--------------------------------
;Installer Functions

LangString InstallerAlreadyRunning ${LANG_ENGLISH} "The installer is already running."
LangString InstallerAlreadyRunning ${LANG_SIMPCHINESE} "��װ�����Ѿ�������"

LangString AlreadyInstalledString ${LANG_ENGLISH} "You already installed a copy of the application. Do you want to install it again?"
LangString AlreadyInstalledString ${LANG_SIMPCHINESE} "���Ѿ���װ�˱���Ʒ��һ���汾. ���Ƿ�Ҫ���°�װ?"

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
"����Ҫ�Ȱ�װWindows��װ����3.1���ϰ汾���ܼ���; ��μ�����http://haqi.61.com"
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
  DetailPrint "��������: ����С�� ��ʼ��Դ�ļ�"

  ;----------------------------
  ; method1: use inetc plug-in to download
  ; uncomment to use inetc plug-in, which supports resume/retry.
  inetc::get \
	/CAPTION "����С�� ��װ����" \
	/CANCELTEXT "�˳���װ"\
	/QUESTION "���Ƿ�Ҫ��ֹ����С��İ�װ?"\
	/RESUME "����������ӶϿ���!��������(R)��ť�������Ӳ���������..." \
	/TRANSLATE "�������� %s" "������..." "��" "��" "Сʱ" "" "%dkB (%d%%) of %dkB @ %d.%01dkB/s" "(��ʣ�� %d %s%s)" \
	${ARIES_INSTALLER_URL} "$TEMP\AriesInstaller.exe" /END
  Pop $0
  ${If} $0 != "OK"
	MessageBox MB_OK|MB_ICONEXCLAMATION  "����ʧ����, �����°�װ��鿴��������. $\n$0" IDOK GiveUp
  ${EndIf}
  goto Download_OK
  
  ;---------------------------- 
  ; method2: use default downloader
  ; uncomment to use default nsis downloader: No resume/retry is supported. 
  ; NSISDL::download  /TRANSLATE2 "�������� %s" "������..." " (��ʣ�� 1 ����)"	" (��ʣ�� 1 ����)"	" (��ʣ�� 1 Сʱ)"	" (��ʣ�� %u ����)"	" (��ʣ�� %u ����)"	" (��ʣ�� %u Сʱ)"	"%skB (%d%%) of %skB @ %u.%01ukB/s" ${ARIES_INSTALLER_URL} "$TEMP\AriesInstaller.exe" 
  DetailPrint "�������"
  Pop $0
  ${If} $0 == "cancel"
    goto GiveUp
  ${ElseIf} $0 != "success"
    MessageBox MB_OK|MB_ICONEXCLAMATION  "����ʧ����, �����°�װ��鿴��������. $\n$0" IDOK GiveUp
  ${EndIf}

Download_OK:  
  DetailPrint "�ȴ� ��װ���������"
  ExecWait '$TEMP\AriesInstaller.exe' $0
  DetailPrint "��װ/�������. �˳����� = '$0'. ɾ����ʱ�ļ�"
  Delete "$TEMP\AriesInstaller.exe"
  DetailPrint "��װ���"
  goto Install_complete

GiveUp:
  DetailPrint "��װ���û���ֹ��"
  Quit
  
Install_complete:
  DetailPrint "������װ"
  Quit
  
SectionEnd