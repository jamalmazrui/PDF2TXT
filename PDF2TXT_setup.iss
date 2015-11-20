[Setup]
AppName=PDF to TXT
AppVerName=PDF2TXT 4.0
AppPublisher=Jamal Mazrui
AppPublisherURL=https://github.com/JamalMazrui
DefaultDirName=c:\PDF2TXT
;CreateAppDir=no
OutputDir=c:\PDF2TXT
OutputBaseFilename=PDF2TXT_setup
;DisableDirPage=yes
DefaultGroupName=PDF to TXT
DisableProgramGroupPage=yes
DisableReadyPage=yes
;DisableFinishedPage=yes
Compression=lzma
SolidCompression=yes

[Files]
Source: "c:\pdf2txt\source\*.*"; DestDir: "{app}\source"; Flags: RecurseSubdirs IgnoreVersion
Source: "c:\pdf2txt\docs\*.*"; DestDir: "{app}\docs"; Flags: RecurseSubdirs IgnoreVersion
Source: "c:\pdf2txt\pdf2txt.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\pdf2txt\pdf2parts.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\pdf2txt\pdf2parts.tlb"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\pdf2txt\pdf2parts.ini"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\pdf2txt\pdf2meta.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\pdf2txt\pdf2ocr.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\pdf2txt\pdf2tag.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\pdf2txt\pdf2text.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\pdf2txt\pdf2urls.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\pdf2txt\tesseract.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\pdf2txt\RunTesseract.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\pdf2txt\tessdata\*.*"; DestDir: "{app}\tessdata"; Flags: RecurseSubdirs IgnoreVersion
Source: "c:\pdf2txt\SayLine.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\pdf2txt\nvdaControllerClient32.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\pdf2txt\SAAPI32.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\pdf2txt\gettext.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\pdf2txt\filters\*.*"; DestDir: "{app}\filters"; Flags: RecurseSubdirs IgnoreVersion
Source: "c:\pdf2txt\pdftotext.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\pdf2txt\utf8b.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\pdf2txt\ezgui30.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\pdf2txt\pdf2txt.ini"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\pdf2txt\p2t.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\pdf2txt\GrabURL.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\pdf2txt\assocon.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "c:\pdf2txt\assocoff.exe"; DestDir: "{app}"; Flags: ignoreversion

[Dirs]
Name: "{app}\pdf"
Name: "{app}\txt"
Name: "{app}\done"

[Run]
FileName: "cmd.exe"; parameters: "/c"; Description: "Set PDF2TXT Shortcut Key to Alt+Control+P"; Flags: PostInstall RunAsCurrentUser WaitUntilTerminated; AfterInstall: PostHotkey        
FileName:"{app}\docs\pdf2txt.htm"; Description: "Read Documentation for PDF2TXT"; Flags: shellexec skipifdoesntexist postinstall skipifsilent

[UninstallRun]
FileName:"{app}\assocoff.exe"; Parameters: "/silent"; Flags: skipifdoesntexist

[Icons]
Name: "{group}\Launch PDF2TXT"; Filename: "{app}\pdf2txt.exe";
Name: "{group}\Read Documentation for PDF2TXT"; Filename: "{app}\docs\pdf2txt.htm"; Flags: RunMaximized
Name: "{group}\Set .pdf Extension to Open with PDF2TXT"; Filename: "{app}\assocon.exe"
Name: "{group}\Turn off Association between .pdf Extension and PDF2TXT"; Filename: "{app}\assocoff.exe"
Name: "{group}\Uninstall PDF2TXT"; Filename: "{uninstallexe}"
Name: "{group}\View Log File for PDF2TXT"; Filename: "{app}\done\log.txt"; Flags: RunMaximized
Name: "{app}\PDF2TXT"; Filename: "{app}\pdf2txt.exe"; Parameters: ""; WorkingDir: "{app}";
Name: "{userdesktop}\PDF2TXT"; HotKey: Alt+Ctrl+P; Filename: "{app}\pdf2txt.exe"; Parameters: ""; WorkingDir: "{app}";
Name: "{sendto}\PDF to TXT"; HotKey: Alt+Ctrl+Shift+P; Filename: "{app}\pdf2txt.exe";

[Registry]
Root: HKCR; Subkey: ".pdf"; ValueType: string; ValueName: ""; ValueData: "MyExplorerFile"; Flags: uninsdeletevalue
Root: HKCR; Subkey: "PDF2TXTFile"; ValueType: string; ValueName: ""; ValueData: "Portable Document Format"; Flags: uninsdeletekey
;Root: HKCR; Subkey: "PDF2TXTFile\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\Bin\MCSEXPLORER.EXE,0"
Root: HKCR; Subkey: "PDF2TXTFile\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}pdf2txt.EXE"" ""%1"""

[Code]
Const
X86 = '\Program Files (x86)\';

var
aJavaVersions, aJavaVersions32, aJavaVersions64: TArrayOfString;
bHotkey, bSetupInitialized, bLogDisplay: boolean;
sJavaDir, sJavaDir32, sJavaDir64: string;
sJAVA_HOME, sJavaHome, sJavaHome32, sJavaHome64: string;
sNgenExe, sNetDir, sNet20Dir, sNet20Dir32, sNet20Dir64, sNet40Dir, sNet40Dir32, sNet40Dir64: string;

function Show(sText: string): integer;
begin
result := SuppressibleMsgBox(sText, mbInformation, MB_OK, MB_OK);
end; // Show function

function Confirm(sText: string): integer;
begin
result := SuppressibleMsgBox(sText, mbConfirmation, MB_YESNO, MB_DEFBUTTON1);
end; // Confirm function

function JavaDir(param: string): string;
var
sVersion: string;

begin
if bSetupInitialized then begin
result := sJavaDir;
exit;
end;

result := '';
if IsWin64() then exit;
try
if not RegQueryStringValue(HKLM, 'SOFTWARE\JavaSoft\Java Runtime Environment', 'CurrentVersion', sVersion) then exit;
if not RegQueryStringValue(HKLM, 'SOFTWARE\JavaSoft\Java Runtime Environment\' + sVersion, 'JavaHome', result) then exit;
except
end;
end; // JavaDir function

function JavaDir32(param: string): string;
var
sVersion: string;

begin
if bSetupInitialized then begin
result := sJavaDir32;
exit;
end;

result := '';
if not IsWin64() then exit;
try
if not RegQueryStringValue(HKLM32, 'SOFTWARE\JavaSoft\Java Runtime Environment', 'CurrentVersion', sVersion) then exit;
if not RegQueryStringValue(HKLM32, 'SOFTWARE\JavaSoft\Java Runtime Environment\' + sVersion, 'JavaHome', result) then exit;
except
end;
end; // JavaDir32 function

function JavaDir64(param: string): string;
var
sVersion: string;

begin
if bSetupInitialized then begin
result := sJavaDir64;
exit;
end;

result := '';
if not IsWin64() then exit;
try
if not RegQueryStringValue(HKLM64, 'SOFTWARE\JavaSoft\Java Runtime Environment', 'CurrentVersion', sVersion) then exit;
if not RegQueryStringValue(HKLM64, 'SOFTWARE\JavaSoft\Java Runtime Environment\' + sVersion, 'JavaHome', result) then exit;
except
end;
end; // JavaDir64 function

function JavaHome(param: string): string;
begin
if bSetupInitialized then begin
result := sJavaHome;
exit;
end;

result := '';
if IsWin64() then exit;
result := sJAVA_HOME;
end; // JavaHome function

function JavaHome32(param: string): string;
var
sDir: string;

begin
if bSetupInitialized then begin
result := sJavaHome32;
exit;
end;

result := '';
if not IsWin64() then exit;
sDir := ExtractFilePath(sJAVA_HOME);
if Pos(X86, sDir) > 0 then result := sJAVA_HOME;
end; // JavaHome32 function

function JavaHome64(param: string): string;
var
sDir: string;

begin
if bSetupInitialized then begin
result := sJavaHome64;
exit;
end;

result := '';
if not IsWin64() then exit;
sDir := ExtractFilePath(sJAVA_HOME);
if Pos(X86, sDir) = 0 then result := sJAVA_HOME;
end; // JavaHome64 function

function JavaVersions(): TArrayOfString;
begin
result := aJavaVersions;
if GetArrayLength(aJavaVersions) <> 0 then exit;

try
if not RegGetSubkeyNames(HKLM, 'SOFTWARE\JavaSoft\Java Runtime Environment', aJavaVersions) then exit;
except
end;
end; // JavaVersions function

function JavaVersions32(): TArrayOfString;
begin
result := aJavaVersions;
if GetArrayLength(aJavaVersions) <> 0 then exit;

try
if not RegGetSubkeyNames(HKLM32, 'SOFTWARE\JavaSoft\Java Runtime Environment', aJavaVersions) then exit;
except
end;
end; // JavaVersions32 function

function JavaVersions64(): TArrayOfString;
begin
result := aJavaVersions;
if GetArrayLength(aJavaVersions) <> 0 then exit;

try
if not RegGetSubkeyNames(HKLM64, 'SOFTWARE\JavaSoft\Java Runtime Environment', aJavaVersions) then exit;
except
end;
end; // JavaVersions64 function

function IsX64: Boolean;
begin
Result := Is64BitInstallMode and (ProcessorArchitecture = paX64);
end; // IsX64 function

function IsIA64: Boolean;
begin
Result := Is64BitInstallMode and (ProcessorArchitecture = paIA64);
end; // IsIA64 function

function IsOtherArch: Boolean;
begin
Result := not IsX64 and not IsIA64;
end; // IsOtherArch function

function NgenExe(param: string): string;
begin
if bSetupInitialized then begin
result := sNgenExe;
exit;
end;

sNgenExe := '';
If sNETDir <> '' Then begin
sNgenExe := sNetDir + '\ngen.exe';
end;
result := sNgenExe;
end; // NgenExe function

function Net20Dir32(param: string): string;
begin
if bSetupInitialized then begin
result := sNet20Dir32;
exit;
end;

try
result := ExpandConstant('{dotnet2032}');
except
result := ''
end;
end; // Net20Dir32 function

function Net20Dir64(param: string): string;
begin
if bSetupInitialized then begin
result := sNet20Dir64;
exit;
end;

try
result := ExpandConstant('{dotnet2064}');
except
result := ''
end;
end; // Net20Dir64 function

function Net40Dir32(param: string): string;
begin
if bSetupInitialized then begin
result := sNet40Dir32;
exit;
end;

try
result := ExpandConstant('{dotnet4032}');
except
result := ''
end;
end; // Net40Dir32 function

function Net40Dir64(param: string): string;
begin
if bSetupInitialized then begin
result := sNet40Dir64;
exit;
end;

try
result := ExpandConstant('{dotnet4064}');
except
result := ''
end;
end; // Net40Dir64 function

function IsJavaDir(): boolean;
begin
result := not IsWin64() and DirExists(ExpandConstant('{code:JavaDir}'));
end; // IsJavaDir function

function IsJavaDir32(): boolean;
begin
result := Is64BitInstallMode() and DirExists(ExpandConstant('{code:JavaDir32}'));
end; // IsJavaDir32 function

function IsJavaDir64(): boolean;
begin
result := Is64BitInstallMode() and DirExists(ExpandConstant('{code:JavaDir64}'));
end; // IsJavaDir64 function

function IsJavaHome(): boolean;
begin
result := not IsWin64() and DirExists(ExpandConstant('{code:JavaHome}'));
end; // IsJavaHome function

function IsJavaHome32(): boolean;
begin
result := Is64BitInstallMode() and DirExists(ExpandConstant('{code:JavaHome32}'));
end; // IsJavaHome32 function

function IsJavaHome64(): boolean;
begin
result := Is64BitInstallMode() and DirExists(ExpandConstant('{code:JavaHome64}'));
end; // IsJavaHome64 function

function GetDetection(): string;
var
sText: string;

begin
sText := 'Locations of Java Runtime Environment:' + Chr(10);
if sJavaDir <> '' then sText := sText + 'JavaDir=' + sJavaDir + Chr(10);
if sJavaDir32 <> '' then sText := sText + 'JavaDir32=' + sJavaDir32 + Chr(10);
if sJavaDir64 <> '' then sText := sText + 'JavaDir64=' + sJavaDir64 + Chr(10);
if sJAVA_HOME <> '' then sText := sText + 'JAVA_HOME=' + sJAVA_HOME + Chr(10);
result := sText;
end; // GetDetection function

function old_UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
var
sText: string;

begin
sText := '';
if MemoUserInfoInfo <> '' then sText := sText + MemoUserInfoInfo + NewLine + NewLine;
if MemoDirInfo <> '' then sText := sText + MemoDirInfo + NewLine + NewLine;
if MemoTypeInfo <> '' then sText := sText + MemoTypeInfo + NewLine + NewLine;
if MemoComponentsInfo <> '' then sText := sText + MemoComponentsInfo + NewLine + NewLine;
if MemoGroupInfo <> '' then sText := sText + MemoGroupInfo + NewLine + NewLine;
if MemoTasksInfo <> '' then sText := sText + MemoTasksInfo + NewLine + NewLine;
result := sText + GetDetection();
end; // UpdateReadyMemo function

function InitializeSetup(): boolean;
var
iChoice, iError: integer;
sText: string;

begin
bHotkey := false;
(*
sJavaDir := JavaDir('');
sJavaDir32 := JavaDir32('');
sJavaDir64 := JavaDir64('');

sJAVA_HOME := GetEnv('JAVA_HOME');
sJavaHome := JavaHome('');
sJavaHome32 := JavaHome32('');
sJavaHome64 := JavaHome64('');

// aJavaVersions := JavaVersions();
// aJavaVersions32 := JavaVersions32();
// aJavaVersions64 := JavaVersions64();

sNet20Dir32 := Net20Dir32();
sNet20Dir64 := Net20Dir64();
sNet40Dir32 := Net40Dir32();
sNet40Dir64 := Net40Dir64();
*)

sNetDir := Net40Dir32('');
sNgenExe := NgenExe('');

(*
if FileExists(ExpandConstant('{code:NgenExe}')) then Show('found')
else Show('missing');

if IsJavaDir() Then Show('IsJavaDir')
else Show('Not IsJavaDir');

if IsJavaDir32() Then Show('IsJavaDir32')
else Show('Not IsJavaDir32');

if IsJavaDir64() Then Show('IsJavaDir64')
else Show('Not IsJavaDir64');

Show(ExpandConstant('{code:JavaHome}'));
if IsJavaHome() Then Show('IsJavaHome')
else Show('Not IsJavaHome');

if IsJavaHome32() Then Show('IsJavaHome32')
else Show('Not IsJavaHome32');

if IsJavaHome64() Then Show('IsJavaHome64')
else Show('Not IsJavaHome64');
*)

bSetupInitialized := True;
result := true;

(*
if IsJavaDir() or IsJavaDir32() or IsJavaDir64() or (sJAVA_HOME <> '') then result := True
else begin
bSetupInitialized := False;
iChoice := Confirm('The Java Access Bridge cannot be installed because a Java Runtime Environment (JRE) is not found on this computer.  Get it now from java.com?');
if iChoice = IDYES then begin
Show('When the web site opens, click the link called "Free Java Download."  Afterward, rerun this installer.');
ShellExec('open',     'http://www.java.com/getjava/',     '','',SW_SHOWNORMAL,ewNoWait,iError);
end
result := False;
end
*)
end; // InitializeSetup function

procedure old_DeinitializeSetup();
var
bResult: boolean;
iResult: integer;
sSource, sTarget: string;

begin
sSource := ExpandConstant('{log}');
try
sTarget := ExpandConstant('{app}\') + ExtractFileName(sSource);
bResult := FileCopy(sSource, sTarget, False);
ShellExec('open', sTarget, '','',SW_SHOWNORMAL,ewNoWait,iResult);
except
finally
DeleteFile(sSource);
end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
bResult: boolean;
begin
if CurStep <> ssDone then exit;
if bHotkey then exit;
// Show('About to copy');
// Show(ExpandConstant('{app}\FileDir.lnk'));
// Show(ExpandConstant('{userdesktop}\FileDir.lnk'));
bResult := FileCopy(ExpandConstant('{app}\FileDir.lnk'), ExpandConstant('{userdesktop}\FileDir.lnk'), false);
// if bResult then Show('success')
// else Show('failed');
end; // CurStepChanged procedure

procedure PostHotkey();
begin
bHotkey := true;
// Show('PostHotkey');
end; // PostHotkey procedure







