# MSI version checking macro.
# Written by AnarkiNet(AnarkiNet@gmail.com) originally, modified by eyal0 (for use in http://www.sourceforge.net/projects/itwister)
# MSI check code based on http://www.codeproject.com/useritems/NSIS.asp
# Downloads the MSI version 3.1 and runs it if the user does not have the correct version.
# To use, call the macro with a string:
# Example: non real version numbers
# !insertmacro CheckMSI "3.1"
# All register variables are saved and restored by CheckMSI
# No output
 
!macro CheckMSI MSIReqVer
  !define MSI31_URL "http://download.microsoft.com/download/1/4/7/147ded26-931c-4daf-9095-ec7baf996f46/WindowsInstaller-KB893803-v2-x86.exe"
 
  DetailPrint "Checking your MSI version..."
  ;callee register save
  Push $0
  Push $1
  Push $2
  Push $3
  Push $4
  Push $5
  Push $6 ;backup of installed ver
  Push $7 ;backup of MSIReqVer
 
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;                               MSI                                          ;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  GetDLLVersion "$SYSDIR\msi.dll" $R0 $R1
  IntOp $R2 $R0 / 0x00010000 ; $R2 now contains major version
  IntOp $R3 $R0 & 0x0000FFFF ; $R3 now contains minor version
  IntOp $R4 $R1 / 0x00010000 ; $R4 now contains release
  IntOp $R5 $R1 & 0x0000FFFF ; $R5 now contains build
  StrCpy $0 "$R2.$R3.$R4.$R5" ; $0 now contains string like "1.2.0.192"
 
  ${If} $R2 < '3'
    ;options
    SetOutPath "$TEMP"
    SetOverwrite on
 
    MessageBox MB_YESNOCANCEL|MB_ICONEXCLAMATION \
    "Your MSI version: $0.$\nRequired Version: 3 or greater.$\nDownload MSI version from www.microsoft.com?" \
    /SD IDYES IDYES DownloadMSI IDNO NewMSI
    goto GiveUpDotNET ;IDCANCEL
 
  ${Else}
 
    DetailPrint "MSI3.1 already installed"
    goto NewMSI
  ${EndIf}
 
DownloadMSI:
  DetailPrint "Beginning download of MSI3.1."
  NSISDL::download ${MSI31_URL} "$TEMP\WindowsInstaller-KB893803-v2-x86.exe"
  DetailPrint "Completed download."
  Pop $0
  ${If} $0 == "cancel"
    MessageBox MB_YESNO|MB_ICONEXCLAMATION \
    "Download cancelled.  Continue Installation?" \
    IDYES NewMSI IDNO GiveUpDotNET
  ${ElseIf} $0 != "success"
    MessageBox MB_YESNO|MB_ICONEXCLAMATION \
    "Download failed:$\n$0$\n$\nContinue Installation?" \
    IDYES NewMSI IDNO GiveUpDotNET
  ${EndIf}
  DetailPrint "Pausing installation while downloaded MSI3.1 installer runs."
  ExecWait '$TEMP\WindowsInstaller-KB893803-v2-x86.exe /quiet /norestart' $0
  DetailPrint "Completed MSI3.1 install/update. Exit code = '$0'. Removing MSI3.1 installer."
  Delete "$TEMP\WindowsInstaller-KB893803-v2-x86.exe"
  DetailPrint "MSI3.1 installer removed."
  goto NewMSI

GiveUpDotNET:
	Abort "Installation cancelled by user." 
	
NewMSI:
  DetailPrint "MSI3.1 installation done. Proceeding with remainder of installation."
 
  Pop $7
  Pop $6
  Pop $5
  Pop $4
  Pop $3
  Pop $2
  Pop $1
  Pop $0
!macroend