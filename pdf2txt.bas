' PDF2TXT
' Version 4.0
' November 20, 2015
' Copyright 2005 - 2015 by Jamal Mazrui
' GNU Lesser General Public License (LGPL)

#Compile Exe
#Dim All
'       #Resource "sample.pbr"
%USEMACROS = 1
#Include "private.inc"
#Include "win32api.inc"
' #Include "C:\SayTools\SayTools.inc"
#Include "CommCtrl.inc"
#Include "ShLwApi.inc"
#Include "RichEdit.inc"
#Include "EOIni.inc"
#Include "funcky.inc"
#Include "MyLib.inc"
#Include "fn.inc"
#Include "ezgui30.inc"
'#Include "iSQP0511PB.inc"

'                         Application Constants and Declares
%id_Elevate = 90
$id_Elevate = "90"
%id_pdflabel=91
%id_pdf=92
%id_open=93
%id_select=94
%ID_GRAB=95
%ID_PASSWORDLabel =96
%ID_PASSWORD =97
%ID_imageFormat =98
%ID_ExtraOutputs =99
%id_viewlabel=106
%id_view=107
%id_txtlabel=108
%id_txt=109
%id_browse=110
%id_subfolders=111
%id_move=112
%id_replace=113
%ID_APPEND=114
%id_convert=1
%id_look=116
%id_defaults=117
%ID_EXPLORER=118
%id_quit=119
$id_quit="119"
%id_help=120
$id_help="120"
%id_statusbar=121
%id_forwardfind=122
$id_forwardfind="122"
%id_reversefind=123
%id_forwardagain=124
$id_forwardagain="124"
%id_reverseagain=125
%ID_ESCAPE = 126
$ID_ESCAPE = "126"
%ID_SETBOOKMARK=127
$ID_SETBOOKMARK="127"
%ID_CLEARBOOKMARK=128
$ID_CLEARBOOKMARK="128"
%ID_GOTOBOOKMARK=129
$ID_GOTOBOOKMARK="129"
%ID_GOTOPERCENT=130
$ID_GOTOPERCENT="130"
%ID_STARTSELECT=131
$ID_STARTSELECT="131"
%ID_CompleteSELECT=132
$ID_CompleteSELECT="132"
%ID_COPYALL=133
$ID_COPYALL="133"
%ID_COPYAPPEND=134
$ID_COPYAPPEND="134"
%Form1FILE                                   = 500
%Form1NEWFILE                                = 505
%Form1OPENFILE                               = 510
%Form1SAVEFILE                               = 515
%Form1SAVEAS                                 = 520
%Form1SEPARATOR_525                          = 525
%Form1EXIT                                   = 530

%Form1EDIT                                   = 600
%Form1CUT                                    = 605
%Form1COPY                                   = 610
%Form1PASTE                                  = 615

%Form1HELP                                   = 700
%Form1HELP1                                  = 705
%Form1BUTTON1            = 100
%Form1Convert            = 105
%Form1CHECK1             = 110
%Form1CHECK2             = 115
%Form1CHECK3             = 120
%Form1RADIO1             = 125
%Form1RADIO2             = 130
%Form1TEXT1              = 135
%Form1LISTBOX1           = 140
%Form1COMBOBOX1          = 145
%Form1LABEL1             = 150
%Form1FRAME1             = 155

Declare Sub Form1FILE_Select()
Declare Sub Form1NEWFILE_Select()
Declare Sub Form1OPENFILE_Select()
Declare Sub Form1SAVEFILE_Select()
Declare Sub Form1SAVEAS_Select()
Declare Sub Form1EXIT_Select()
Declare Sub Form1EDIT_Select()
Declare Sub Form1CUT_Select()
Declare Sub Form1COPY_Select()
Declare Sub Form1PASTE_Select()
Declare Sub Form1HELP_Select()
Declare Sub Form1HELP1_Select()
Declare Sub Form1CHECK1_Click()
Declare Sub Form1CHECK2_Click()
Declare Sub Form1CHECK3_Click()
Declare Sub Form1RADIO1_Click()
Declare Sub Form1RADIO2_Click()
Declare Sub Form1TEXT1_Change()
Declare Sub Form1LISTBOX1_Change(ByVal CVal&)
Declare Sub Form1COMBOBOX1_Change(ByVal CVal&)
Declare Sub Form1LABEL1_Click()

'                         Application Global Variables and Types
Global hLib As Long
Global i_external As Long
Global sAnalysisLog As String
Global initForm&, SingleConvert&
Global a$(), download&, url$
Global id&, x&, y&, w&, h&, text$, prop$
Global hwin&, parent$, title$, folder$, filter$, file$, source$, IncludeFiles&
Global rtf&, sel&
Global i&, pdf&, page&, PageCount&, pdfSize&
Global s$, body$
Global class_ctl$, style&, exstyle&
Global cr As CharRange
Global appPath$, appPathShort$, iniFile$, logFile$, tempFile$, doneDir$, pdfDir$, txtDir$, password$, imageFormat&, ExtraOutputs&, includeSubfolders&, movePdf&, replaceTxt&, appendLog&, aborting&, abortFile$
Global Find_my$, direction&
Global logTrail$, logging&
Global toggling&, toggleFind_my$, toggleDirection&
Global commandLine&

' Global Handles for menus
Global Form1hMenu0&
Global Form1hMenu1&
Global Form1hMenu2&
Global Form1hMenu3&

#Include "ezwmain.inc"                          ' EZGUI Include file for WinMain

'                               EZGUI Program Control Functions
Sub EZ_Main(VerNum&)
EZ_Reg %EZGUI_CustomerID, %EZGUI_RegistrationNumber
'InitCommonControls
EventsOn

abortFile$ = ez_appPath & "abort.tmp"
StringToFile("Aborting OCR", abortFile$)

Form1Display ""
End Sub

Sub EZ_DesignWindow(FormName$)
Select Case FormName$
Case "FORM1"
Form1Design
Case Else
End Select
End Sub

Sub EZ_Events(FormName$, CID&, CMsg&, CVal&, Cancel&)
'   CID&      =     Control ID or %EZ_Window (0) if Window event
'   CMsg&     =     Control Event Message (Type)
'   CVal&     =     Value:  (ie. Scrollbar value)
'   Cancel&   =     is for Closing a Window. Set Cancel& to -1
'                   (True) to stop close

Select Case FormName$
Case "FORM1"
Form1Events CID&, CMsg&, CVal&, Cancel&
Case Else
End Select
End Sub

'                                 Put Your Code Here
Sub Form1Display(ByVal Parent$)
'Form1hMenu0&=EZ_DefMainMenu( %Form1FILE, "&File", "")
EZ_Color -1, -1
SetDefaults
IniLoad
If 0 Then
Local RV&, MKey$, SKey$, VName$, VText$, VNum???
MKey$ = "U"
SKey$ = "S-1-5-21-2437207488-1676788297-2797829045-1003\Software\Novatix\ExplorerPlus\CurrentVersion\ExplorerPlus\LayoutTabs"
VName$ = "0"
'RV& = EZ_ReadReg ( MKey$,  SKey$,  VName$, VText$, VNum???)
'RV& = EZ_ReadReg(ByVal MKey$, ByVal SKey$, ByVal VName$, VText$, VNum???)
rv& = ez_regexist(mkey$, skey$)
MsgBox Format$(RV&)
End If
If commandLine& Then
Form1Convert
IniSave
Else
EZ_Form "FORM1", Parent$, "PDF to TXT", 0, 0, 100, 30, "CMN"
End If
End Sub

Sub Form1Design()
Local FF&
FF& =  9              '          -  Offset for Font Numbers
If %FALSE Then
EZ_AddMenuItem Form1hMenu0&, %Form1EDIT, 0, "&Edit", ""
EZ_AddMenuItem Form1hMenu0&, %Form1HELP, 0, "&Help", ""
Form1hMenu1&=EZ_DefSubMenu( %Form1NEWFILE, "&New File", "")
EZ_SetSubMenu Form1hMenu0& , %Form1FILE, Form1hMenu1&
EZ_AddMenuItem Form1hMenu1&, %Form1OPENFILE, 0, "&Open File", ""
EZ_AddMenuItem Form1hMenu1&, %Form1SAVEFILE, 0, "&Save File", ""
EZ_AddMenuItem Form1hMenu1&, %Form1SAVEAS, 0, "Save File &As",""
EZ_AddMenuItem Form1hMenu1&, %Form1SEPARATOR_525, 0, "-", ""
EZ_AddMenuItem Form1hMenu1&, %Form1EXIT, 0, "E&xit", ""
Form1hMenu2&=EZ_DefSubMenu( %Form1CUT, "Cu&t", "")
EZ_SetSubMenu Form1hMenu0& , %Form1EDIT, Form1hMenu2&
EZ_AddMenuItem Form1hMenu2&, %Form1COPY, 0, "&Copy", ""
EZ_AddMenuItem Form1hMenu2&, %Form1PASTE, 0, "&Paste", ""
Form1hMenu3&=EZ_DefSubMenu( %Form1HELP1, "&Contents", "")
EZ_SetSubMenu Form1hMenu0& , %Form1HELP, Form1hMenu3&
End If

EZ_Color-1,-1
EZ_UseFont -1
EZ_UseFont 4
' id& = 100
id& = 90
x& = 0
y& = 0
w& = 0
h& = 0
'remove Escape hot key
EZ_DefAccel "FORM1", "F1,"+$id_help+"|F11,"+$id_Elevate+"|^f,"+$id_forwardfind+"|F3,"+$id_forwardagain+"|^k,"+$ID_setBOOKMARK+"|%k,"+$ID_GOTOBOOKMARK+"|^g,"+$ID_GOTOPERCENT+"|F8,"+$ID_STARTSELECT+"|^F8,"+$ID_COPYALL+"|%F8,"+$ID_COPYAPPEND+"|"
'EZ_DefAccel "FORM1", "^f,"+$id_forwardfind+"|F3,"+$id_forwardagain+"|"


id& = id& + 1
x& = 1
y& = y& + h& + 1
text$ = "&PDF file, folder, or URL:"
w& = Len(text$) - 3
h& = 1
prop$ = "A"
'EZ_Label id&, x&, y&, w&, h&, text$, prop$
class_ctl$ = "STATIC"
style& = %SS_RIGHT Or %WS_CHILD Or %WS_VISIBLE
exstyle& = 0
EZ_ControlEX("FORM1", id&, x&, y&, w&, h&, class_ctl$, text$, style&, exstyle&)

id& = id& + 1
x& = x& + w& + .5
y& = y&
text$ = pdfDir$
w& = 25
h& = 1.5
prop$ = "ET"
EZ_Text id&, x&, y&, w&, h&, text$, prop$

id& = id& + 1
x& = x& +w + 1
y& = y&
text$ = "&Open file"
w& = Len(text$)
h& = 2
prop$ = "T"
EZ_Button id&, x&, y&, w&, h&, text$, prop$

id& = id& + 1
x& = x& +w + 1
y& = y&
text$ = "&Select Source Folder"
w& = Len(text$)
h& = 2
prop$ = "T"
EZ_Button id&, x&, y&, w&, h&, text$, prop$

id& = id& + 1
x& = x& +w + 1
y& = y&
text$ = "&Grab URL"
w& = Len(text$)
h& = 2
prop$ = "T"
EZ_Button id&, x&, y&, w&, h&, text$, prop$

id& = id& + 1
x& = 1
y& = y& + h& + 1
text$ = "Pass&word:"
w& = Len(text$)
h& = 1
prop$ = "A"
class_ctl$ = "STATIC"
style& = %SS_RIGHT Or %WS_CHILD Or %WS_VISIBLE
exstyle& = 0
EZ_ControlEX("FORM1", id&, x&, y&, w&, h&, class_ctl$, text$, style&, exstyle&)

id& = id& + 1
x& = x& + w& + .5
y& = y&
text$ = password$
w& = 25
h& = 1.5
prop$ = "ET"
EZ_Text id&, x&, y&, w&, h&, text$, prop$

id& = id& + 1
x& = x& + w& + 1
y& = y&
text$ = "Image &Format"
w& = Len(text$)
w& = 19
h& = 2
prop$ = "T"
EZ_Checkbox id&, x&, y&, w&, h&, text$, prop$

id& = id& + 1
x& = x& + w& + 1
y& = y&
text$ = "E&xtra outputs"
w& = Len(text$)
w& = 19
h& = 2
prop$ = "T"
EZ_Checkbox id&, x&, y&, w&, h&, text$, prop$

' id& = id& + 1
id& = 106
x& = 1
y& = y& + h& + 1
text$ = "&View results:"
w& = Len(text$)
text$ = "&View:"
h& = 1
prop$ = ""
class_ctl$ = "STATIC"
style& = %SS_RIGHT Or %WS_CHILD Or %WS_VISIBLE
exstyle& = 0
EZ_ControlEX("FORM1", id&, x&, y&, w&, h&, class_ctl$, text$, style&, exstyle&)

id& = id& + 1
x& = x& + w& + .5
y& = y&
text$ = ""
w& = 65
h& = 15
prop$ = "TV"
EZ_AppendStyle %ES_SAVESEL
'try richtext1 for speed
EZ_RichText2 id&, x&, y&, w&, h&, prop$
'EZ_RichText1 id&, x&, y&, w&, h&, prop$
'Pdf2RichText

id& = id& + 1
x& = 1
y& = y& + h& + 1
text$ = "&TXT folder:"
w& = Len(text$)
h& = 1
prop$ = "A"
'EZ_Label id&, x&, y&, w&, h&, text$, prop$
class_ctl$ = "STATIC"
style& = %SS_RIGHT Or %WS_CHILD Or %WS_VISIBLE
exstyle& = 0
EZ_ControlEX("FORM1", id&, x&, y&, w&, h&, class_ctl$, text$, style&, exstyle&)

id& = id& + 1
x& = x& + w& + .5
y& = y&
text$ = txtDir$
w& = 25
h& = 1.5
prop$ = "ET"
EZ_Text id&, x&, y&, w&, h&, text$, prop$

id& = id& + 1
x& = x& +w + 1
y& = y&
text$ = "&Browse for Target Folder"
w& = Len(text$)
h& = 2
prop$ = "T"
EZ_Button id&, x&, y&, w&, h&, text$, prop$

id& = id& + 1
x& = 1 + 10
y& = y& + h& + 1
text$ = "&Include subfolders"
w& = Len(text$)
w& = 19
h& = 2
prop$ = "T"
EZ_Checkbox id&, x&, y&, w&, h&, text$, prop$

id& = id& + 1
x& = x& + w& + 1
y& = y&
text$ = "&Move PDF when done"
w& = Len(text$)
w& = 19
h& = 2
prop$ = "T"
EZ_Checkbox id&, x&, y&, w&, h&, text$, prop$

id& = id& + 1
x& = x& +w& + 1 + 3
y& = y&
text$ = "&Replace TXT if found"
w& = Len(text$)
w& = 19
h& = 2
prop$ = "T"
EZ_Checkbox id&, x&, y&, w&, h&, text$, prop$

id& = id& + 1
x& = x& +w& + 1 + 3
y& = y&
text$ = "&Append to log file"
w& = Len(text$)
w& = 19
h& = 2
prop$ = "T"
EZ_Checkbox id&, x&, y&, w&, h&, text$, prop$

id& = id& + 1
x& = 1 + 20
y& = y& + h& + 1
text$ = "&Convert"
w& = Len(text$)
h& = 2
prop$ = "@T"
EZ_Button 1, x&, y&, w&, h&, text$, prop$

id& = id& + 1
x& = x& +w& + 1
y& = y&
text$ = "&Look"
w& = Len(text$)
h& = 2
prop$ = "T"
EZ_Button id&, x&, y&, w&, h&, text$, prop$

id& = id& + 1
x& = x& + w& + 1
y& = y&
text$ = "&Defaults"
w& = Len(text$)
h& = 2
prop$ = "T"
EZ_Button id&, x&, y&, w&, h&, text$, prop$

id& = id& + 1
x& = x& + w& + 3
y& = y&
text$ = "&Explorer"
w& = Len(text$)
h& = 2
prop$ = "T"
EZ_Button id&, x&, y&, w&, h&, text$, prop$

id& = id& + 1
x& = x& + w& + 1
y& = y&
text$ = "&Quit"
w& = Len(text$)
h& = 2
prop$ = "T"
EZ_Button id&, x&, y&, w&, h&, text$, prop$

id& = id& + 1
x& = x& + w& + 1
y& = y&
text$ = "&Help"
w& = Len(text$)
h& = 2
prop$ = "T"
EZ_Button id&, x&, y&, w&, h&, text$, prop$

id& = id& + 1
EZ_StatusBar id&, "Ready", ""

x& = x& + w& + 1
y& = y& + h& + 1
SetControls
End Sub

Sub Form1Events(CID&, CMsg&, CVal&, Cancel&)
If CMsg& = %EZ_NOFOCUS Then
hwin& = EZ_Handle("FORM1", %id_view)
End If
Select Case CID&
Case %EZ_Window
If InitForm& = -1 And CMsg& = %EZ_FOCUS Then
initForm& = 1
If IsFalse commandLine& Then
file$ = pdfDir$
Pdf2RichText
End If
End If
If CMsg&=%EZ_Close Then
If CMsg& = %EZ_KEYUP And Cval& = 27 Then Cancel& = 1
End If
Case %Form1FILE
Form1FILE_Select
Case %Form1NEWFILE
Form1NEWFILE_Select
Case %Form1OPENFILE
Form1OPENFILE_Select
Case %Form1SAVEFILE
Form1SAVEFILE_Select
Case %Form1SAVEAS
Form1SAVEAS_Select
Case %Form1SEPARATOR_525
Case %Form1EXIT
Form1EXIT_Select
Case %Form1EDIT
Form1EDIT_Select
Case %Form1CUT
Form1CUT_Select
Case %Form1COPY
Form1COPY_Select
Case %Form1PASTE
Form1PASTE_Select
Case %Form1HELP
Form1HELP_Select
Case %Form1HELP1
Form1HELP1_Select
Case %id_forwardfind 'find
direction& = 1
Form1Find
FindText_my

Case %id_forwardagain 'Find again
SayString "Forward again"
direction& = 1
FindText_my

Case %ID_SETBOOKMARK 'Set bookmark
Form1SetBookmark
Case %ID_GOTOBOOKMARK
Form1GoToBookmark
Case %ID_STARTSELECT
Form1StartSelect
Case %ID_GOTOPERCENT
Form1GoToPercent
Case %ID_COPYALL
Form1CopyAll
Case %ID_COPYAPPEND
Form1CopyAppend
Case %id_open 'Select source file
If CMsg&=%EZ_Click Then
Form1Open
End If
Case %id_select 'Select source folder
If CMsg&=%EZ_Click Then
Form1Select
End If
Case %id_GRAB 'Grab URL
If CMsg&=%EZ_Click Then
Form1Grab
End If
Case %id_view 'rich text
If CMsg&=%EZ_FOCUS Then
'If Not Equiv(pdfDir$, EZ_GetText("FORM1", %id_pdf)) Or Len(EZ_GetRichText("FORM1", %id_view, 0, 0)) =0 Then PDF2RichText
End If
Case %id_browse 'Browse for Txt
If CMsg&=%EZ_Click Then
Form1Browse
End If
Case %id_convert
'if Cmsg& = %EZ_FOCUS then saystring "focusing"
If CMsg&=%EZ_Click Then
GetControls
IniSave
'hwin& = EZ_Handle "FORM1", %id_view
'If GetFocus()' = hwin& Then
' If hwin& = EZ_Handle("FORM1", %id_view) Then
hwin& = EZ_Handle("FORM1", %id_view)
If IsTrue hwin& Then
toggling& = 1
s$ = EZ_GetText("FORM1", %id_viewlabel)
If s$ = "&View folder:" Then
i& = Edit_LineFromChar(hwin&, -1)
If i& = 0 Then
file$ = pdfDir$
Else
file$ = Trim$(my_edit_getLine(hwin&, i&), Any $CrLf)
file$ = pdfDir$ + "\" +file$
EZ_SetText "FORM1", %id_pdf, file$
End If
ElseIf s$ = "&View URL:" Then
i& = Edit_LineFromChar(hwin&, -1)
If i& = 0 Then
file$ = pdfDir$
Else
file$ = a$(i&)
End If
ElseIf s$ = "&View file:" Then
file$ = pdfDir$
If 0 Then 'do not toggle to convert folder
If Path_IsURL(file$) And Equiv(Path_FindExtension(file$), ".pdf") And LBound(a$()) <> -1 Then
file$ =a$(0)
Else
file$ = Path_FindPath(file$)
If Len(file$) >3 Then File$ = Trim$(file$, "\")
End If
EZ_SetText "FORM1", %id_pdf, file$
End If
Else 'nothing in viewing area
file$ = pdfDir$
End If
Else
file$ = pdfDir$
End If
pdfDir$ = file$
If Form1Convert Then
If toggling& Then
toggling& = 0
If GetFocus() <> EZ_Handle("FORM1", %ID_VIEW) Then EZ_SetFocus("FORM1", %ID_VIEW)
End If
End If
IniSave
End If
Case %id_look 'Look
If CMsg&=%EZ_Click Then
SayString "Look"
GetControls
hwin& = EZ_Handle("FORM1", %id_view)
If GetFocus() = hwin& Then
toggling& = 1
s$ = EZ_GetText("FORM1", %id_viewlabel)
If s$ = "&View folder:" Then
i& = Edit_LineFromChar(hwin&, -1)
If i& = 0 Then
file$ = pdfDir$
Else
file$ = Trim$(my_edit_getLine(hwin&, i&), Any $CrLf)
file$ = pdfDir$ + "\" +file$
End If
ElseIf s$ = "&View URL:" Then
i& = Edit_LineFromChar(hwin&, -1)
If i& = 0 Then
file$ = pdfDir$
Else
file$ = a$(i&)
End If
ElseIf s$ = "&View file:" Or IsSourceFile() Then
file$ = pdfDir$
If Path_IsURL(file$) And Equiv(Path_FindExtension(file$), ".pdf") And LBound(a$()) <> -1 Then
file$ =a$(0)
Else
file$ = Path_FindPath(file$)
If Len(file$) >3 Then File$ = Trim$(file$, "\")
End If
EZ_SetText "FORM1", %id_pdf, file$
Else 'nothing in viewing area
toggling& = 0
file$ = pdfDir$
End If
Else
toggling& = 0
file$ = pdfDir$
End If
'no more because convert button also togglines in a way
'If toggling& Then SayString "Toggling"
Form1Look
IniSave
End If
Case %id_quit 'quit
If CMsg&=%EZ_Click Then
IniSave
Form1Quit
End If
Case %id_defaults 'Defaults
If CMsg&=%EZ_Click Then
Form1Defaults
End If
Case %id_EXPLORER 'Explorer
If CMsg&=%EZ_Click Then
Form1Explorer
End If
Case %id_Elevate 'Elevate
If CMsg&=%EZ_Click Then
Form1Elevate
End If
Case %id_help 'help
If CMsg&=%EZ_Click Then
Form1Help
End If
Case %ID_ESCAPE
Cancel& = 1
Case  %Form1CHECK1
If CMsg&=%EZ_Click Then
Form1CHECK1_Click
End If
Case  %Form1CHECK2
If CMsg&=%EZ_Click Then
Form1CHECK2_Click
End If
Case  %Form1CHECK3
If CMsg&=%EZ_Click Then
Form1CHECK3_Click
End If
Case  %Form1RADIO1
If CMsg&=%EZ_Click Then
Form1RADIO1_Click
End If
Case  %Form1RADIO2
If CMsg&=%EZ_Click Then
Form1RADIO2_Click
End If
Case  %Form1TEXT1
If CMsg&=%EZ_Change Then
Form1TEXT1_Change
End If
Case  %Form1LISTBOX1
If CMsg&=%EZ_Change Then
Form1LISTBOX1_Change CVal&
End If
Case  %Form1COMBOBOX1
If CMsg&=%EZ_Change Then
Form1COMBOBOX1_Change CVal&
End If
Case  %Form1LABEL1
If CMsg&=%EZ_Click Then
Form1LABEL1_Click
End If
Case Else
End Select
If CMsg& = %EZ_KEYDOWN And Cval& = %VK_F1 Then
i& = GetDlgCtrlID(GetFocus())
Select Case i&
Case %id_pdf
s$ = "Use this edit box to type the path and name of a PDF, or a folder containing one or more PDFs.  "
s$ = s$ + "You can press Enter or Alt+C to convert this PDF source to plain text in the target folder.  "
s$ = s$ + "You can press Alt+L to look at the file text or folder list."
Case %id_open
s$ = "Use this button to open a PDF.  "
s$ = s$ + "The path and name of the PDF will be put in the source edit box.  "
s$ = s$ + "The text of the PDF will be put in the viewing area, and focus will go there so you can read the file."
Case %id_select
s$ = "Use this button to select a PDF folder.  "
s$ = s$ + "The path and name of the folder will be put in the source edit box.  "
s$ = s$ + "The list of PDFs in the folder will be put in the viewing area, and focus will go there so you can read the list."
Case %ID_GRAB
s$ = "Use this button to grab the URL of a web page displayed in Internet Explorer.  "
s$ = s$ + "The URL will be put in the source edit box.  "
Case %id_password
s$ = "Input the password to unlock the PDF, if any."
Case %id_imageFormat
s$ = "If checked, a much slower method, involving optical character recognition, will be used to obtain text."
Case %id_ExtraOutputs
s$ = "If checked, additional text files will be generated corresponding to metadata about the PDF, URLs it contains, an HTML format, and a text format that includes markup indicating the document structure."
Case %id_view
s$ = "Use this scrollable, read-only edit box to read a block of information presented by the program.  "
s$ = s$ + "This could be the text of a PDF, or the list of PDFs in a folder.  "
s$ = s$ +"It could also be the results of a batch conversion, or the complete documentation for this program.  "
s$ = s$ + "You can use standard navigation keys, e.g., Control+Home or Control+End to go to the top or bottom of text.  "
s$ = s$ + "Standard keys also work for selecting and copying text to the clipboard.  "
s$ = s$ + "Other hot keys include the following:" + $CrLf + $CrLf
s$ = s$ + "Alt+L = Toggle between looking at a file or folder" + $CrLf + $CrLf
s$ = s$ + "Control+F = Forward find" + $CrLf + $CrLf
s$ = s$ + "Control+Shift+F = Reverse Find" + $CrLf + $CrLf
s$ = s$ + "F3 = Forward again" + $CrLf + $CrLf
s$ = s$ + "Shift+F3 = Reverse again" + $CrLf + $CrLf
s$ = s$ + "Control+G = Go to percent position" + $CrLf + $CrLf
s$ = s$ + "Control+K = Set bookmark" + $CrLf + $CrLf
s$ = s$ + "Control+Shift+K = Clear bookmark" + $CrLf + $CrLf
s$ = s$ + "Alt+K = Go to bookmark" + $CrLf + $CrLf
s$ = s$ + "F8 = Start selection" + $CrLf + $CrLf
s$ = s$ + "Shift+F8 = Complete selection" + $CrLf + $CrLf
s$ = s$ + "Control+F8 = Copy all text to clipboard" + $CrLf + $CrLf
s$ = s$ + "Control+Shift+C = Copy append selection to clipboard, also Alt+F8"
Case %id_txt
s$ = "Use this edit box to type the path and name of a folder to store text files converted from PDFs.  "
s$ = s$ + "You can press Enter or Alt+C to convert the PDF source to text in this target folder.  "
Case %id_browse
s$ = "Use this button to browse for a target folder.  "
s$ = s$ + "The path and name of the folder will be put in the target edit box.  "
Case %id_subfolders
s$ = "Use this check box to specify that batch conversions look for PDF files not only in the source folder, but in subfolders of it as well.  "
s$ = s$ + "The setting is unchecked by default."
Case %id_move
s$ = "Use this check box to specify that a PDF is to be moved to the Done folder after being successfully converted.  "
s$ = s$ + "The setting is unchecked by default."
Case %id_replace
s$ = "Use this check box to specify that a conversion will replace any existing text file by the same name in the target folder.  "
s$ = s$ + "The setting is checked by default."
Case %id_append
s$ = "Use this check box to specify whether to append the conversion log to previous information or create a new file."
s$ = s$ + "The setting is checked by default."
Case %id_convert
s$ = "Use this button to convert the PDF source to text.  A single file, or multiple files from a folder or web page, will be converted.  "
s$ = s$ + "Information about conversion results will be placed in the viewing area, and focus will go there so you can read the results.  You can abort a long conversion by pressing Escape."
Case %id_look
s$ = "Use this button to look at the PDF source.  If it is a file, its content will be shown in the viewing area.  If a folder or web page, its list of PDFs will be shown.  "
s$ = s$ +"Focus will go to the viewing area so yu can read the information."
Case %id_quit
s$ = "Use this button to quit the program.  Alt+Q or Alt+F4 do the same thing.  "
S$ = s$ + "Current settings will be remembered next time."
Case %id_defaults
s$ = "Use this button to restore the initial, default settings of the program.  "
s$ = s$ + "These settings include the source folder, target folder, and whether to include subfolders move a PDF after conversion, or replace existing target files."
Case %id_help
s$ = "Use this button to show the complete documentation for this program in your web browser.  "
End Select
Msg_Box "Help", s$
Cancel& = 1
End If
If logging& And CMsg& = %EZ_KEYUP And Cval& = 27 Then
SayString "Abort!"
logging& = 0
End If
If CMsg& = %EZ_KEYUP And Cval& = %VK_K And (EZ_GetKeyState(%EZK_SHIFT, 0) And 1) And (EZ_GetKeyState(%EZK_CTRL, 0) And 1) Then
Form1ClearBookmark
End If
If CMsg& = %EZ_KEYUP And (Cval& = 70 Or Cval& = 102) And (EZ_GetKeyState(%EZK_SHIFT, 0) And 1) And (EZ_GetKeyState(%EZK_CTRL, 0) And 1) Then
direction& = 0
Form1Find
FindText_my
End If
If CMsg& = %EZ_KEYUP And Cval& = %VK_F8 And (EZ_GetKeyState(%EZK_SHIFT, 0) And 1) Then
Form1CompleteSelect
End If
If CMsg& = %EZ_KEYUP And (Cval& = 67 Or Cval& = 99) And (EZ_GetKeyState(%EZK_SHIFT, 0) And 1) And (EZ_GetKeyState(%EZK_CTRL, 0) And 1) Then
Form1CopyAppend
End If
If CMsg& = %EZ_KEYUP And (Cval& = 114) And (EZ_GetKeyState(%EZK_SHIFT, 0) And 1) Then
SayString "Reverse again"
direction& = 0
FindText_my
End If
If CMsg& = %EZ_KEYUP Then
Static p1&, p2&
EZ_GetRichSel "FORM1", %id_view, p1&, p2&
s$ = "Viewing " + Trim$(Str$(100 * (p1& / pdfSize&), 3)) + "%"
If (EZ_GetText("FORM1", %id_viewlabel) = "&View file:") Then s$ = s$ +" of " +Format$(pageCount&) + " page" +IIf$(pageCount = 1, "", "s")
EZ_SetSBText "Form1", %id_statusbar, 1, s$, ""
End If
End Sub

Sub Form1FILE_Select()
End Sub

Sub Form1NEWFILE_Select()
End Sub

Sub Form1OPENFILE_Select()
End Sub

Sub Form1SAVEFILE_Select()
End Sub

Sub Form1SAVEAS_Select()
End Sub

Sub Form1EXIT_Select()
End Sub


Sub Form1EDIT_Select()
End Sub

Sub Form1CUT_Select()
End Sub

Sub Form1COPY_Select()
End Sub

Sub Form1PASTE_Select()
End Sub

Sub Form1HELP_Select()
End Sub

Sub Form1HELP1_Select()
End Sub

Sub Form1CHECK1_Click()
End Sub

Sub Form1CHECK2_Click()
End Sub

Sub Form1CHECK3_Click()
End Sub

Sub Form1RADIO1_Click()
End Sub

Sub Form1RADIO2_Click()
End Sub

Sub Form1TEXT1_Change()
End Sub

Sub Form1LISTBOX1_Change(ByVal CVal&)
End Sub

Sub Form1COMBOBOX1_Change(ByVal CVal&)
End Sub

Sub Form1LABEL1_Click()
End Sub

Function IsBlank(sText as string) as long
function = %false
if len(TrimBlank(sText)) = 0 then function = %true
End Function

Function TrimBlank(sText as string) as string
function = Trim$(sText, any $CrLf + $spc + $nul + $ff)
End Function

function StringToUniFile(s_body as string, s_file as string) as long
StringToFile(s_body, s_file)
SetEncoding(s_file)
end function

Function SetEncoding(sTxt as string) as long
Local sExe as string

sExe = Exe.path$ + "utf8b.exe"
shell StringQuote(sExe) + " " + StringQuote(sTxt)
end function

Function GetMiner(sPdf As String) As String
Local sCommand, sCurDir, sExe, sReturn, sTempDir, sTempPdf, sTempTxt As String

sExe = Exe.Path$ + "pdf2tag.exe"
sTempDir = GetTempDir()
sTempPdf = sTempDir + PathName$(NameX, sPdf)
sTempTxt = sTempDir + PathName$(Name, sPdf) + ".txt"
FileCopy sPdf, sTempPdf
sCommand = StringQuote(sExe) + " -t text " + StringQuote(sTempPdf)
sCurDir = CurDir$
ChDir sTempDir
Shell sCommand, 0
ChDir sCurDir
sReturn = FileToString(sTempTxt)
Kill sTempPdf
Kill sTempTxt
Function = sReturn
End Function

Function GetXpdf(sPdf As String) As String
Local sCommand, sCurDir, sExe, sReturn, sTempDir, sTempPdf, sTempTxt As String

sExe = Exe.Path$ + "pdftotext.exe"
sTempDir = GetTempDir()
sTempPdf = sTempDir + PathName$(NameX, sPdf)
sTempTxt = sTempDir + PathName$(Name, sPdf) + ".txt"
FileCopy sPdf, sTempPdf
sCommand = StringQuote(sExe) + " " + StringQuote(sTempPdf) + " " + StringQuote(sTempTxt)
sCurDir = CurDir$
ChDir sTempDir
Shell sCommand, 0
ChDir sCurDir
sReturn = FileToString(sTempTxt)
Kill sTempPdf
Kill sTempTxt
Function = sReturn
End Function

Function GetText(sPdf As String) As String
Local sCommand, sCurDir, sExe, sReturn, sTempDir, sTempPdf, sTempTxt As String

sExe = Exe.Path$ + "gettext.exe"
sTempDir = GetTempDir()
sTempPdf = sTempDir + PathName$(NameX, sPdf)
sTempTxt = sTempDir + PathName$(Name, sPdf) + ".txt"
FileCopy sPdf, sTempPdf
sCommand = StringQuote(sExe) + " " + StringQuote(sTempPdf) + " " + StringQuote(sTempTxt)
sCurDir = CurDir$
ChDir sTempDir
Shell sCommand, 0
ChDir sCurDir
sReturn = FileToString(sTempTxt)
Kill sTempPdf
Kill sTempTxt
Function = sReturn
End Function

Function GetPdf2ocr(sPdf As String) As String
Local sCommand, sCurDir, sExe, sReturn, sTempDir, sTempPdf, sTempTxt As String

sExe = Exe.Path$ + "pdf2ocr.exe"
sTempDir = GetTempDir()
sTempPdf = sTempDir + PathName$(NameX, sPdf)
sTempTxt = sTempDir + PathName$(Name, sPdf) + ".txt"
FileCopy sPdf, sTempPdf
sCommand = StringQuote(sExe) + " " + StringQuote(sTempPdf)
sCurDir = CurDir$
ChDir sTempDir
Shell sCommand, 0
ChDir sCurDir
sReturn = FileToString(sTempTxt)
Kill sTempPdf
Kill sTempTxt
Function = sReturn
End Function

Function GetPdf2htm(sPdf As String) As String
Local sCommand, sCurDir, sExe, sReturn, sTempDir, sTempPdf, sTempTxt As String

' sExe = Exe.Path$ + "pdf2htm.bat"
sExe = Exe.Path$ + "pdf2tag.exe"
sTempDir = GetTempDir()
sTempPdf = sTempDir + PathName$(NameX, sPdf)
sTempTxt = sTempDir + PathName$(Name, sPdf) + ".htm"
FileCopy sPdf, sTempPdf
sCommand = StringQuote(sExe) + " -t html " + StringQuote(sTempPdf)
sCurDir = CurDir$
ChDir sTempDir
Shell sCommand, 0
ChDir sCurDir
sReturn = FileToString(sTempTxt)
Kill sTempPdf
Kill sTempTxt
Function = sReturn
End Function

Function GetPdf2tag(sPdf As String) As String
Local sCommand, sCurDir, sExe, sReturn, sTempDir, sTempPdf, sTempTxt As String

sExe = Exe.Path$ + "pdf2tag.exe"
sTempDir = GetTempDir()
sTempPdf = sTempDir + PathName$(NameX, sPdf)
sTempTxt = sTempDir + PathName$(Name, sPdf) + ".tag"
FileCopy sPdf, sTempPdf
sCommand = StringQuote(sExe) + " " + StringQuote(sTempPdf)
sCurDir = CurDir$
ChDir sTempDir
Shell sCommand, 0
ChDir sCurDir
sReturn = FileToString(sTempTxt)
Kill sTempPdf
Kill sTempTxt
Function = sReturn
End Function

Function GetPdf2urls(sPdf As String) As String
Local sCommand, sExe, sReturn, sTempDir, sTempPdf, sTempTxt As String

sExe = Exe.Path$ + "pdf2urls.exe"
sTempDir = GetTempDir()
sTempPdf = sTempDir + PathName$(NameX, sPdf)
sTempTxt = sTempDir + PathName$(Name, sPdf) + "_urls.txt"
FileCopy sPdf, sTempPdf
sCommand = StringQuote(sExe) + " " + StringQuote(sTempPdf)
Shell sCommand, 0
sReturn = FileToString(sTempTxt)
Kill sTempPdf
Kill sTempTxt
Function = sReturn
End Function

Function GetPdf2meta(sPdf As String) As String
Local sCommand, sExe, sReturn, sTempDir, sTempPdf, sTempTxt As String

sExe = Exe.Path$ + "pdf2meta.exe"
sTempDir = GetTempDir()
sTempPdf = sTempDir + PathName$(NameX, sPdf)
sTempTxt = sTempDir + PathName$(Name, sPdf) + "_meta.txt"
FileCopy sPdf, sTempPdf
sCommand = StringQuote(sExe) + " " + StringQuote(sTempPdf)
Shell sCommand, 0
sReturn = FileToString(sTempTxt)
Kill sTempPdf
Kill sTempTxt
Function = sReturn
End Function

Function GetPdf2Text(sPdf As String) As String
Local sCommand, sExe, sReturn, sTempDir, sTempPdf, sTempTxt As String

sExe = Exe.Path$ + "pdf2text.exe"
sTempDir = GetTempDir()
sTempPdf = sTempDir + PathName$(NameX, sPdf)
sTempTxt = sTempDir + PathName$(Name, sPdf) + ".txt"
FileCopy sPdf, sTempPdf
sCommand = StringQuote(sExe) + " " + StringQuote(sTempPdf)
Shell sCommand, 0
sReturn = FileToString(sTempTxt)
Kill sTempPdf
Kill sTempTxt
Function = sReturn
End Function

Function GetTempDir() As String
Local zPath As ASCIIZ*%MAX_PATH
GetTempPath(%MAX_Path, zPath)
Function = zPath
End Function

FUNCTION my_Edit_GetLine (BYVAL hEdit AS DWORD, BYVAL which AS DWORD) AS STRING

LOCAL buffer AS STRING
LOCAL n      AS LONG

buffer = MKI$(32765) + STRING$(32765, 0)

n = SendMessage(hEdit, %EM_GETLINE, which, STRPTR(buffer))

FUNCTION = LEFT$(buffer, n)

END FUNCTION

Function Pdf2String(ByVal source$) As String
Local i_converting As Long, z As String
Local sMeta As String

If imageFormat& Then SayString("Using OCR")
IniSave
logging& = 1
logTrail$ = ""
EZ_SetText "FORM1", %ID_VIEWLABEL, "&View results:"
EZ_SetRichText "FORM1", %ID_VIEW, "", 0, 0

sMeta = TrimBlank(AnalyzePdf(source$))
body$ = TrimBlank(GetPDFText(source$))
If IsBlank(body$) then
' SayString("Cannot convert " + z + $CrLf + AnalyzePDF(source$))
End If
function = TrimBlank(sMeta + $Crlf + $Crlf + body$) 
End Function

Function Pdf2RichText() As Long
source$ = file$
If Path_FileExists(source$) Then
Text$ = Pdf2String(source$)
logging& = 0
s$ = "&View file:"
Else
text$ = ""
s$ = "&View:"
End If
If IsFalse IsBlank(text$) Then
EZ_SetText "FORM1", %id_viewlabel, s$
rtf& = 0
sel& = 0
EZ_SetRichText "FORM1", %id_view, text$, rtf&, sel&
End If
EZ_RedrawControl "FORM1", %id_view
EZ_SetFocus "FORM1", %id_view
EZ_SetRichSel "FORM1", %id_view, 0, 0
pdfDir$ = source$
'pdfSize& = Len(EZ_GetRichText("FORM1", %id_view, 0, 0))
RichEditBottom(Ez_handle("FORM1", %ID_VIEW))
EZ_GetRichSel "FORM1", %ID_VIEW, i&, pdfSize&
EZ_SetRichSel("FORM1", %ID_VIEW, 0, 0)
End Function

Function Form1Open() As Long
GetControls
parent$ ="FORM1"
title$ = "Open PDF file"
folder$ = pdfDir$
If IsFalse Path_IsDirectory(folder$) Then folder$ = EZ_GetPathText(folder$)
filter$ = "PDF files|*.pdf|"
prop$ = "SR"
EventsOff
file$ = EZ_OpenFile(parent$, title$, folder$, filter$, prop$)
If Len(Trim$(file$)) = 0 Then
'SayString("Abort!")
Exit Function
End If
EventsOn
EZ_SetText "FORM1", %id_pdf, file$
If IsFalse Equiv(folder$, file$) And Path_FileExists(file$) Then
If Path_IsDirectory(file$) Then
i& = PDFListFromFolder(body$)
body$ = Format$(i&) +" file" + IIf$(i& = 1, "", "s") + IIf$(i&, $CrLf + body$, "")
s$ = "&View folder:"
EZ_SetText "FORM1", %id_viewlabel, s$
EZ_SetRichText "FORM1", %id_view, body$, 0, 0
EZ_SetFocus "FORM1", %id_view
EZ_SetRichSel "FORM1", %id_view, 0, 0
ElseIf LCase$(Path_FindExtension(file$)) = ".pdf" Then
Pdf2RichText()
End If
Else
EZ_SetFocus "FORM1", %id_pdf
End If
GetControls
IniSave
End Function

Function Form1Select() As Long
GetControls
title$ = "Select Source"
Folder$ = pdfDir$
If IsFalse Path_IsDirectory(folder$) Then folder$ = EZ_GetPathText(folder$)
hwin& = EZ_Handle("FORM1", 0)
IncludeFiles& = %FALSE
EventsOff
file$ = BrowseForFolder(hwin&, title$, folder$, IncludeFiles&)
EventsOn
If Len(Trim$(file$)) = 0 Then
'SayString("Abort!")
Exit Function
End If
EZ_SetText "FORM1", %id_pdf, file$
If IsFalse Equiv(folder$, file$) And Path_FileExists(file$) Then
If Path_IsDirectory(file$) Then
i& = PDFListFromFolder(body$)
body$ = Format$(i&) +" file" + IIf$(i& = 1, "", "s") + IIf$(i&, $CrLf + body$, "")
s$ = "&View folder:"
EZ_SetText "FORM1", %id_viewlabel, s$
EZ_SetRichText "FORM1", %id_view, body$, 0, 0
EZ_SetFocus "FORM1", %id_view
EZ_SetRichSel "FORM1", %id_view, 0, 0
ElseIf LCase$(Path_FindExtension(file$)) = ".pdf" Then
Pdf2RichText()
End If
Else
EZ_SetFocus "FORM1", %id_pdf
End If
GetControls
IniSave
End Function

Function Form1Grab() As Long
' s$ = GrabURL
s$ = GetUrl
If s$ = "" Then
Msg_Box("Alert", "Cannot find URL in Internet Explorer")
Else
EZ_SetText "FORM1", %ID_PDF, s$
EZ_SetFocus "FORM1", %ID_PDF
End If
End Function
Function Form1Browse() As Long
title$ = "Choose Target"
folder$ = txtDir$
hwin& = EZ_Handle("FORM1", 0)
IncludeFiles& = %FALSE
file$ = BrowseForFolder(hwin&, title$, folder$, IncludeFiles&)
If Len(Trim$(file$)) = 0 Then
'SayString("Abort!")
Exit Function
End If
EZ_SetText "FORM1", %id_txt, file$
EZ_SetFocus "FORM1", %id_txt
GetControls
IniSave
End Function

Function Form1Convert() As Long
Function = 1
If IsFalse Path_IsUrl(pdfDir$) And IsFalse Path_FileExists(pdfDir$) Then
Msg_Box "Alert", "Cannot  find Pdf source" + $CrLf + pdfDir$
Function = 0
'ElseIf Path_IsDirectory(pdfDir$) Then
ElseIf 1 Then
BatchConvert
Else
Pdf2RichText
EZ_SetFocus "FORM1", %id_view
End If
End Function

Function Form1Look() As Long
If Path_IsURL(file$) And Equiv(Path_FindExtension(file$), ".pdf") Then
url$ = file$
s$ = appPath$ +"pdf"
If IsFalse Path_FileExists(s$) Then MkDir s$
s$ = s$ + "\" + Path_FindFileName(file$)
Url2File(file$, s$)
file$ = s$
Else
url$ = ""
End If
If Path_IsUrl(file$) Then
toggleFind_my$ = Find_my$
toggleDirection& = direction&
'Find_my$ = EZ_GetFileText(pdfDir$)
Find_my$ = Path_FindFileName(pdfDir$)
direction& = 1
body$ = file$
i& = PDFListFromWeb(body$)
body$ = Format$(i&) +" file" + IIf$(i& = 1, "", "s") + IIf$(i&, $CrLf + body$, "")
s$ = "&View URL:"
EZ_SetText "FORM1", %id_viewlabel, s$
EZ_SetRichText "FORM1", %id_view, body$, 0, 0
EZ_SetFocus "FORM1", %id_view
EZ_SetRichSel "FORM1", %id_view, 0, 0
If toggling& Then FindText_my
ElseIf Path_IsDirectory(file$) Then
toggleFind_my$ = Find_my$
toggleDirection& = direction&
Find_my$ = EZ_GetFileText(pdfDir$)
direction& = 1
i& = PDFListFromFolder(body$)
body$ = Format$(i&) +" file" + IIf$(i& = 1, "", "s") + IIf$(i&, $CrLf + body$, "")
s$ = "&View folder:"
EZ_SetText "FORM1", %id_viewlabel, s$
EZ_SetRichText "FORM1", %id_view, body$, 0, 0
EZ_SetFocus "FORM1", %id_view
EZ_SetRichSel "FORM1", %id_view, 0, 0
If toggling& Then FindText_my
ElseIf Path_FileExists(file$) And Equiv(Path_FindExtension(file$), ".pdf") Then
Pdf2RichText
If url$ <>"" Then file$ = url$
EZ_SetText "FORM1", %id_pdf, file$
Else
s$ = "&View:"
EZ_SetText "FORM1", %id_viewlabel, s$
MSG_Box "Alert", "Cannot find Pdf source" + $CrLf + file$
End If
End Function

Function Form1Quit() As Long
SayString("Quit PDF to TXT", %FALSE)
EZ_UnloadForm("FORM1")
End Function

Function Form1Defaults() As Long
SayString("Set defaults", %FALSE)
SetDefaults
IniSave
SetControls
End Function

Function Form1Explorer() As Long
Local title$, text$, pic$, prop$, button1$, button2$, button3$, font1&, font2&
GetControls
s$ = pdfDir$
If Equiv(Path_FindExtension(s$), ".pdf") Then
If Path_IsUrl(s$) And LBound(a$()) <> -1 Then
s$ = a$(0)
Else
s$ = Path_FindPath(s$)
s$ = Mid$(s$, 1, Len(s$) -1)
End If
End If
If Path_IsUrl(s$) Then
text$ = "Source URL: " + s$
Else
text$ = "Source folder: " + s$
End If
text$ = text$ + "|Target folder: " + txtDir$
text$ = text$ + "|Done folder: " + doneDir$
title$ = "Choose Location to Explore"
Button1$ = "&Source"
button2$ = "&Target"
button3$ = "&Done"
pic$ = ""
prop$ = "L"
font1& = 0
font2& = 0
i& = EZ_MSGBoxEx("FORM1", text$, title$, button1$, button2$, button3$, pic$, prop$, font1&, font2&)
Select Case i&
Case -1
'do nothing
Case 0
'do nothing
Case 1
Shell "explorer.exe " + s$
Case 2
Shell "explorer.exe " + txtDir$
Case 3
If IsFalse Path_IsDirectory(doneDir$) Then MkDir doneDir$
Shell "explorer.exe " +doneDir$
End Select
End Function

Function Form1Elevate() As Long
Dim s_url As String, s_file As String, s_localTime As String, s_ServerTime As String, s_ini As String, s_default As String, s_version as String, s_time As String, s_message As String

s_url = "http://EmpowermentZone.com/p2tsetup.exe"
s_file = fn_GetTempPath & "p2tsetup.exe"
s_LocalTime = fn_getTime(appPath$ & "pdf2txt.exe")
s_localTime = Left$(s_localTime, Len(s_localTime) - 3)
s_ini = fn_makeTempFile
Url2File "http://EmpowermentZone.com/appstamp.ini", s_ini
s_serverTime = Ini_GetKey(s_ini$, "Versions", "PDF2TXT", "")
Kill s_ini
s_version = Parse$(s_serverTime, "|", 1)
s_time = Parse$(s_serverTime, "|", 2)
s_serverTime = s_time
Replace " " with " at " in s_time
' Replace "-" with "" In s_serverTime
' Replace " " with "" in s_ServerTime
' Replace ":" with "" in s_ServerTime

' Msgbox s_serverTime, 0, s_localTime
If s_serverTime > s_localTime Then
s_default = "Y"
s_message = "Newer"
ElseIf s_serverTime = s_localTime Then
s_default = "N"
s_message = "Current"
Else
s_default = "N"
s_message = "Older"
End If

s_message = s_message & " PDF2TXT " & s_version & $CrLf & "released on " & s_time & $CrLf
s_message = s_message & "Download from " & $CrLf & "http://EmpowermentZone.com/p2tsetup.exe" & $CrLf & "to Temp folder, and run installer?"

If DialogConfirm("Confirm", s_message, s_default) <> "Y" Then
Exit Function
End If

SayString "Plese wait"
If IsFalse Url2File(s_url, s_file) Then
SayString "Error downloading file!"
Exit Function
End If

' Shell(StringQuote(s_file), 1)
ShellExecute ByVal 0&, ByVal 0&, ByCopy s_file, ByVal 0&, ByVal 0&, ByVal 1&
Form1Quit
End Function

Function Form1Help() As Long
s$ =appPath$ + "\docs\pdf2txt.htm"
ShellExecute 0, "open", ByCopy s$, "", "", %SW_SHOW
Exit Function
s$ = Chr$(34) + Environ$("COMSPEC") + Chr$(34) + " /c start " + Chr$(34) + Chr$(34) + " " + Chr$(34) + s$ + Chr$(34)
Shell(s$)
Exit Function
body$ = FileToString(s$)
s$ = "&View help:"
EZ_SetText "FORM1", %id_viewlabel, s$
EZ_SetRichText "FORM1", %id_view, body$, 0, 0
EZ_SetFocus "FORM1", %id_view
EZ_SetRichSel "FORM1", %id_view, 0, 0
End Function

Function SetDefaults() As Long
appPath$ = Ez_AppPath
appPathShort$ = fn_GetSFN(fn_DelSh(appPath$)) & "\"
iniFile$ = appPath$ + "pdf2txt.ini"
logFile$ = appPath$ + "done\log.txt"
tempFile$ = appPathShort$ + "pdf2txt.tmp"
doneDir$ = appPath$ + "done"
pdfDir$ = appPath$ + "pdf"
txtDir$ = appPath$ + "txt"
password$ = ""
imageFormat& = %FALSE
ExtraOutputs& = %FALSE
includeSubfolders& = %FALSE
movePdf& = %FALSE
replaceTxt& = %TRUE
appendLog& = %TRUE
If Len(Command$) > 0 Then
'If Equiv(Mid$(Command$, 1, 2), "/a") Then
If 0 Then
CommandLine& = 1
If Len(Command$) > 2 Then
pdfDir$ = Trim$(Mid$(Command$, 3, -1))
Else
pdfDir$ = ""
End If
Else
pdfDir$ = Command$
End If
i& = Len(pdfDir$)
If i& > 0 Then
s$ = Path_RemoveArgs(pdfDir$)
Local j&
j& = Len(s$)
If j& < i& Then
commandLine& = 1
txtDir$ = Trim$(Path_UnquoteSpaces(Mid$(pdfDir$, j& + 1, -1)))
pdfDir$ = Trim$(Path_UnquoteSpaces(s$))
If Len(txtDir$) > 0 And Mid$(txtDir$, 1, 1) <> "/" Then
Ini_SetKey(iniFile$, "Settings", "TxtDir", txtDir$)
Else
txtDir$ = appPath$ + "txt"
End If
Else
initForm& =-1
End If
If Len(pdfDir$) > 0 And Mid$(pdfDir$, 1, 1) <> "/" Then
Ini_SetKey(iniFile$, "Settings", "PdfDir", pdfDir$)
Else
pdfDir$ = appPath$ + "pdf"
End If
End If
End If

s$ = " " + LCase$(Command$) + " "
If InStr(s$, " /a ") Or InStr(s$, " /a+ ") Then
commandLine& = 1
End If
If InStr(s$, " /a- ") Then
commandLine& = 0
End If
If InStr(s$, " /d ") Or InStr(s$, " /d+ ") Then
pdfDir$ = appPath$ + "pdf"
txtDir$ = appPath$ + "txt"
password$ = ""
imageFormat = %False
ExtraOutputs = %False
includeSubfolders = %FALSE
MovePDF = %FALSE
ReplaceTxt = %TRUE
appendLog& = %TRUE
IniSave
End If
If InStr(s$, " /g ") Or InStr(s$, " /g+ ") Then
' pdfDir$ = GrabURL
pdfDir$ = GetUrl
Ini_SetKey(iniFile$, "Settings", "PDFDir", pdfDir$)
If pdfDir$ = "" Then Msg_Box("Alert", "Cannot find URL in Internet Explorer")
End If
' Ini_SetKey(iniFile$, "Settings", "Password", password$)
If InStr(s$, " /k ") Or InStr(s$, " /k+ ") Then
imageFormat& = %TRUE
Ini_SetKey(iniFile$, "Settings", "imageFormat", Format$(imageFormat&))
End If
If InStr(s$, " /k- ") Then
imageFormat& = %FALSE
Ini_SetKey(iniFile$, "Settings", "imageFormat", Format$(imageFormat&))
End If
If InStr(s$, " /x ") Or InStr(s$, " /x+ ") Then
ExtraOutputs& = %TRUE
Ini_SetKey(iniFile$, "Settings", "ExtraOutputs", Format$(ExtraOutputs&))
End If
If InStr(s$, " /x- ") Then
ExtraOutputs& = %FALSE
Ini_SetKey(iniFile$, "Settings", "ExtraOutputs", Format$(ExtraOutputs&))
End If
If InStr(s$, " /i ") Or InStr(s$, " /i+ ") Then
includeSubfolders& = %TRUE
Ini_SetKey(iniFile$, "Settings", "IncludeSubfolders", Format$(includeSubfolders&))
End If
If InStr(s$, " /i- ") Then
includeSubfolders& = %FALSE
Ini_SetKey(iniFile$, "Settings", "IncludeSubfolders", Format$(includeSubfolders&))
End If
If InStr(s$, " /m ") Or InStr(s$, " /m+ ") Then
MovePDF& = %TRUE
Ini_SetKey(iniFile$, "Settings", "MovePDF", Format$(MovePDF&))
End If
If InStr(s$, " /m- ") Then
MovePDF& = %FALSE
Ini_SetKey(iniFile$, "Settings", "MovePDF", Format$(MovePDF&))
End If
If InStr(s$, " /r ") Or InStr(s$, " /r+ ") Then
ReplaceTXT& = %TRUE
Ini_SetKey(iniFile$, "Settings", "ReplaceTXT", Format$(ReplaceTXT&))
End If
If InStr(s$, " /r- ") Then
ReplaceTXT& = %FALSE
Ini_SetKey(iniFile$, "Settings", "ReplaceTXT", Format$(ReplaceTXT&))
End If
If InStr(s$, " /a ") Or InStr(s$, " /a+ ") Then
appendLog& = %TRUE
Ini_SetKey(iniFile$, "Settings", "AppendLog", Format$(appendLog&))
End If
If Equiv(EZ_GetFileText(AppExeName()), "p2t.exe") Then CommandLine& = 1
End Function

Function IniSave() As Long
Ini_SetKey(iniFile$, "Settings", "PdfDir", pdfDir$)
Ini_SetKey(iniFile$, "Settings", "TxtDir", txtDir$)
Ini_SetKey(iniFile$, "Settings", "Password", password$)
Ini_SetKey(iniFile$, "Settings", "imageFormat", Format$(imageFormat&))
Ini_SetKey(iniFile$, "Settings", "ExtraOutputs", Format$(ExtraOutputs&))
Ini_SetKey(iniFile$, "Settings", "IncludeSubfolders", Format$(includeSubfolders&))
Ini_SetKey(iniFile$, "Settings", "MovePdf", Format$(movePdf&))
Ini_SetKey(iniFile$, "Settings", "ReplaceTxt", Format$(replaceTxt&))
Ini_SetKey(iniFile$, "Settings", "AppendLog", Format$(appendLog&))
End Function


Function IniLoad() As Long
pdfDir$ = Ini_GetKey(iniFile$, "Settings", "PdfDir", pdfDir$)
txtDir$ = Ini_GetKey(iniFile$, "Settings", "TxtDir", txtDir$)
' MsgBox "load: " + password$
password$ = Ini_GetKey(iniFile$, "Settings", "Password", password$)
imageFormat& = Val(Ini_GetKey(iniFile$, "Settings", "imageFormat", Format$(imageFormat&)))
ExtraOutputs& = Val(Ini_GetKey(iniFile$, "Settings", "ExtraOutputs", Format$(ExtraOutputs&)))
includeSubfolders& = Val(Ini_GetKey(iniFile$, "Settings", "IncludeSubfolders", Format$(includeSubfolders&)))
movePdf& = Val(Ini_GetKey(iniFile$, "Settings", "MovePdf", Format$(movePdf&)))
replaceTxt& = Val(Ini_GetKey(iniFile$, "Settings", "ReplaceTxt", Format$(replaceTxt&)))
appendLog& = Val(Ini_GetKey(iniFile$, "Settings", "AppendLog", Format$(appendLog&)))
End Function

Function GetControls() As Long
If CommandLine& Then Exit Function
pdfDir$ = Trim$(EZ_GetText("FORM1", %id_pdf))
txtDir$ = Trim$(EZ_GetText("FORM1", %id_txt))
password$ = Trim$(EZ_GetText("FORM1", %id_password))
imageFormat& = EZ_GetCheck("FORM1", %id_imageFormat)
ExtraOutputs& = EZ_GetCheck("FORM1", %id_ExtraOutputs)
includeSubfolders& = EZ_GetCheck("FORM1", %id_subfolders)
movePdf& = EZ_GetCheck("FORM1", %id_move)
replaceTxt& = EZ_GetCheck("FORM1", %id_replace)
appendLog& = EZ_GetCheck("FORM1", %id_append)
End Function

Function SetControls() As Long
EZ_SetText "FORM1", %id_pdf, pdfDir$
EZ_SetText "FORM1", %id_txt, txtDir$
EZ_SetText "FORM1", %id_password, password$
EZ_SetCheck "FORM1", %id_imageFormat, imageFormat&
EZ_SetCheck "FORM1", %id_ExtraOutputs, ExtraOutputs&
EZ_SetCheck "FORM1", %id_subfolders, includeSubfolders&
EZ_SetCheck "FORM1", %id_move, movePdf&
EZ_SetCheck "FORM1", %id_replace, replaceTxt&
EZ_SetCheck "FORM1", %id_append, appendLog&
End Function

Function BatchConvert() As Long
Local s_source As Asciiz * %MAX_PATH, s_target As Asciiz * %MAX_PATH, s_appPath As Asciiz * %MAX_PATH, z As Asciiz * %MAX_PATH
Local s_body As String, s_say As String
Local h_pdf As Long, i_page As Long, i_pageCount As Long, i As Long, i_pdfCount As Long, i_convertCount As Long, i_converting As Long
Local s_pdf As String, s_pdfList As String
Local i_pdf As Long

EZ_SetFocus "FORM1", %ID_VIEW
download& = 0
If Path_IsURL(pdfDir$) Then
download& = 1
s_pdfList = pdfDir$
i_pdfCount = PDFListFromWeb(s_pdfList)
ElseIf Path_IsDirectory(pdfDir$) Then
s_pdfList = pdfDir$
i_pdfCount = PDFListFromFolder(s_pdfList)
Else
i_pdfCount = 1
s_pdfList = pdfDir$
End If

singleConvert& = 0
If i_pdfCount = 1 And Equiv(Path_FindExtension(pdfDir$), ".pdf") And (Path_IsUrl(PdfDir$) Or (Path_FileExists(pdfDir$) And IsFalse Path_IsDirectory(pdfDir$))) Then singleConvert& = 1

logging& = 1
logTrail$ = ""
If IsFalse appendLog& And Path_FileExists(logFile$) Then Kill logFile$
If i_pdfCount Then sAnalysisLog = "Logging on " + Date$ + " at " + Time$ + $CrLf

aborting& = 0
If Path_FileExists(abortFile$) Then Kill abortFile$

s_say = "Converting"
If IsTrue imageFormat& Then s_say += " using OCR"
If IsTrue ExtraOutputs& Then s_say += " with extra outputs"
SayString(s_say)

For i_pdf = 1 To i_pdfCount
sAnalysisLog += $CrLf
s_pdf = Parse$(s_pdfList, $CrLf, i_pdf)
If download& Then
s$ = appPath$ + "pdf"
If IsFalse Path_FileExists(s$) Then MkDir s$
s_pdf = Path_FindFileName(a$(i_pdf))
s_pdf = s$ + "\" +s_pdf
Url2File(a$(i_pdf), s_pdf)
Else
s$ = CurDir$
If IsFalse InStr("/\", Mid$(s$, Len(s$), 1)) Then s$ = s$ + "\"
If IsFalse InStr(s_pdf, Any "/\:") Then s_pdf = s$ + s_pdf
End If

s_source = s_pdf
s_target = s_source
PathRenameExtension(s_target, ".txt")
s_target = txtDir$ + "\" + Path_FindFileName(s_target)
If IsFalse Path_IsDirectory(txtDir$) Then MkDir txtDir$

z = s_source
PathStripPath(z)
If IsFalse replaceTxt& And PathFileExists(s_target) Then
SayString("Skipping " +z)
Iterate For
End If

s_body = GetPDFText(s_source)
If IsTrue aborting& Then
SayString("Aborting")
Exit For
End If

if IsBlank(s_body) Then
s_say = "Cannot convert " + z + ", " + AnalyzePDF(s_source)
SayString(s_say)
sAnalysisLog = sAnalysisLog + s_say + $CrLf
iterate for
End If

i_convertCount = i_convertCount + 1
StringToUniFile(s_body, ByCopy s_target)

If IsTrue ExtraOutputs& then
Local s_output as string
s_output = Left$(s_target, -4) + "_meta.txt"
SayString(pathName$(namex, s_output))
s_body = GetPdf2meta(ByCopy s_source)
StringToUniFile(s_body, s_output)

s_output = Left$(s_target, -4) + "_urls.txt"
SayString(pathName$(namex, s_output))
s_body = GetPdf2urls(ByCopy s_source)
StringToUniFile(s_body, s_output)

s_output = Left$(s_target, -4) + "_gettext.txt"
SayString(pathName$(namex, s_output))
s_body = GetText(ByCopy s_source)
StringToUniFile(s_body, s_output)

s_output = Left$(s_target, -4) + "_xpdf.txt"
SayString(pathName$(namex, s_output))
s_body = GetXpdf(ByCopy s_source)
StringToUniFile(s_body, s_output)

s_output = Left$(s_target, -4) + "_miner.txt"
SayString(pathName$(namex, s_output))
s_body = GetMiner(ByCopy s_source)
StringToUniFile(s_body, s_output)

s_output = Left$(s_target, -4) + "_tag.txt"
SayString(pathName$(namex, s_output))
s_body = GetPdf2tag(ByCopy s_source)
StringToUniFile(s_body, s_output)

s_output = Left$(s_target, -4) + ".htm"
SayString(pathName$(namex, s_output))
s_body = GetPdf2htm(ByCopy s_source)
StringToUniFile(s_body, s_output)
End If

If movePdf& Then
If IsFalse Path_IsDirectory(doneDir$) Then MkDir doneDir$
s = doneDir$ + "\" + Path_FindFileName(s_source)
If IsFalse Equiv(s_source, s) Then
EZ_CopyFile(s_source, s)
If Path_FileExists(s) Then Kill s_source
If IsFalse Path_FileExists(s_source) Then EZ_SetText "FORM1", %ID_PDF, ""
End If
End If
sAnalysisLog += $CrLf
Next
download& = 0
If i_pdfCount = 0 Then
s = "No PDF files found in source!"
Else
s = IIf$((i_pdfCount = 1), "", "s")
' Say("Done")
s = $CrLf + Format$(i_convertCount) + " out of " + Format$(i_pdfCount) +" file" + s + " converted"
SayString(s)
sAnalysisLog = sAnalysisLog + s + $CrLf
End If
If singleConvert& And i_convertCount = 1 Then
logging& = 0
s$ = "&View file:"
EZ_SetText "FORM1", %id_viewlabel, s$
text$ = s_body
rtf& = 0
sel& = 0
EZ_SetRichText "FORM1", %id_view, text$, rtf&, sel&
EZ_SetFocus "FORM1", %id_view
EZ_SetRichSel "FORM1", %id_view, 0, 0
RichEditBottom(Ez_handle("FORM1", %ID_VIEW))
EZ_GetRichSel "FORM1", %ID_VIEW, i&, pdfSize&
EZ_SetRichSel("FORM1", %ID_VIEW, 0, 0)
Else
' If logging& And IsFalse singleConvert& Then SayString(s)
logging& = 0
EZ_SetFocus "FORM1", %id_view
EZ_SetRichSel "FORM1", %id_view, 0, -1
EZ_SetRichSel "FORM1", %id_view, -1, 0
End If
Replace ($CrLf + $CrLf + $CrLf) With ($CrLf + $CrLf) In sAnalysisLog
Replace ($CrLf + $CrLf + $CrLf) With ($CrLf + $CrLf) In sAnalysisLog
sAnalysisLog = Trim$(sAnalysisLog, Any $CrLf)
If Path_FileExists(logFile$) Then sAnalysisLog = FileToString(logFile$) + $Ff + $CrLf + sAnalysisLog
Replace Chr$(0) With "" In sAnalysisLog
StringToUniFile(sAnalysisLog, logFile$)
End Function

Function Form1Find() As Long
Find_my$ = ""
Find_my$ = Ini_GetKey(iniFile$, "Settings", "Find", Find_my$)
If direction& Then
Find_my$ = InputBox$("Text:", "Forward Find", Find_my$)
Else
Find_my$ = InputBox$("Text:", "Reverse Find", Find_my$)
End If
Ini_SetKey(iniFile$, "Settings", "Find", Find_my$)
End Function

Function FindText_my() As Long
Local findStruc As FINDTEXTEX
Local result As Long

If IsFalse toggling& Then Find_my$ = Ini_GetKey(iniFile$, "Settings", "Find", Find_my$)
If IsFalse direction& Then
Local p1&, p2&
EZ_GetRichSel "FORM1", %id_view, p1&, p2&
p1& = p1& - 1
p1& = Max(p1&, 0)
EZ_SetRichSel "FORM1", %id_view, p1&, p1&
End If

' Fill FINDTEXTEX udt with info for search operation
hwin& = EZ_Handle("form1", %id_view)
SendMessage hwin&, %EM_EXGETSEL, 0, VarPtr(findStruc.chrg)
findStruc.chrg.cpmax = -1
findStruc.lpstrText = StrPtr(Find_my$)

' Perform search
' CBWPARAM = 0, search upwards. CBWPARAM = 1, search downwards (%FR_DOWN).
' CBWPARAM can also be combined with %FR_WHOLEWORD and %FR_MATCHCASE, etc.
SENDMessage hwin&, %EM_FINDTEXTEX, direction&, VarPtr(findStruc) To result
If result > -1 Then
SENDMessage hwin&, %EM_EXSETSEL, 0, VarPtr(findStruc.chrgText)
EZ_SetFocus "FORM1", %id_view
EZ_SetRichSel "FORM1", %id_view, -1, 0
Else
If IsFalse toggling& Then SayString("Not found!", 0)
If IsFalse direction& Then EZ_SetRichSel "FORM1", %id_view, p2&, p2&
End If
SayString(my_edit_getLine(hwin&, Edit_LineFromChar(hwin&, -1)))
If toggling& Then
toggling& = 0
Find_my$ = toggleFind_my$
End If
End Function

Function PDFListFromFolder(ByRef s_pdfList As String) As Long
GetControls
ChDir pdfDir$
If Path_FileExists(tempFile$) Then Kill tempFile$
If includeSubfolders& Then
Shell Environ$("COMSPEC") + " /C DIR /b /s *.pdf > " + tempFile$, 0
Else
' MsgBox Environ$("COMSPEC") + " /C DIR /b *.pdf > " + tempFile$
Shell Environ$("COMSPEC") + " /C DIR /b *.pdf > " + tempFile$, 0
End If
s_pdfList = FileToString(tempFile$)
s_pdfList = Trim$(s_pdfList, Any $CrLf)
If Len(s_pdfList) = 0 Then
Function = 0
Else
Function = ParseCount(s_pdfList, $CrLf)
End If
End Function

Function SayString(s As String, Optional i As Long) As Long
If CommandLine& Then
' If IsFalse StdOut(s) Then Say(s) 
Exit Function
End If
Say(s)

If logging& Then
If Len(logTrail$) = 0 Then
logTrail$ = s
Else
LogTrail$ = logTrail$ + $CrLf + s
End If
's$ = "&View results:"
'EZ_SetText "FORM1", %id_viewlabel, s$
EZ_SetRichText "FORM1", %id_view, logTrail$, 0, 0
EZ_SetRichSel "FORM1", %id_view, -1, 0
EZ_RedrawControl "FORM1", %id_view
End If
End Function

Function EventsOff() As Long
EZ_AllowCommandEvents 0
EZ_AllowCursorEvents 0
EZ_AllowMouseMoveEvents 0
EZ_AllowKeyEvents 0
EZ_AllowNotifyEvents 0
End Function

Function EventsOn() As Long
EZ_AllowCommandEvents 1
EZ_AllowCursorEvents 1
EZ_AllowMouseMoveEvents %TRUE
EZ_AllowKeyEvents 2
EZ_AllowNotifyEvents 1
End Function

Function PDFListFromWeb(ByRef s_source As String) As Long
Local s_url As String, s_urlList As String, s_innerText As String
Local i As Long, i_link As Long, i_linkCount As Long
Local v As Variant, v1 As Variant, v2 As Variant
Local o_app As Dispatch, o_doc As Dispatch, o_links As Dispatch, o_link As Dispatch

If Path_IsUrl(s_source) And Equiv(Path_FindExtension(s_source), ".pdf") Then
i_LinkCount = 1
ReDim a$(i_linkCount + 1)
a$(0) = Path_FindPath(s_source)
a$(1) = s_source
Function = 1
Exit Function
End If
s_urlList = ""
o_app = NewCom "InternetExplorer.Application"
If IsObject(o_app) Then
v = %FALSE
Object Let o_app.Visible = v
Object Let o_app.Silent = v
v = s_source
Object Call o_app.navigate(v)
i = %TRUE
While i
Object Get o_app.Busy To v
i = Variant#(v)
Sleep 1
Wend
Object Get o_app.document To V
Set o_doc = v
If IsObject(o_doc) Then
Object Get o_doc.Links To V
Set o_links = v
If IsObject(o_links) Then
Object Get o_links.Length To v
i_linkCount = Variant#(v)
ReDim a$(i_linkCount + 1)
i& = 0
a$(0) = s_source
For i_link = 0 To i_linkCount - 1
v1 = i_link
Object Call o_links.item(v1) To v
Set o_link = v
If IsObject(o_link) Then
Object Get o_link.InnerText To V
s_innerText = Variant$(v)
Object Get o_link.Href To V
s_url = Variant$(v)
If Equiv(Path_FindExtension(s_url), ".pdf") Then
s$ = Trim$(s_innerText)
' If Equiv(s$, "acrobat") Or Equiv(s$, "pdf") Or Equiv(s$, "adobe pdf") Or Equiv(s$, "acrobat pdf") Then s$ = ""
If Len(s$) > 0 Then s$ = s$ +" = "
s$ = s$ + Path_FindFileName(s_url)
s_UrlList = s_urlList + s$ + $CrLf
i& = i& + 1
a$(i&) = s_url
End If
End If
Set o_link = Nothing
Next
s_urlList = Trim$(s_urlList, Any $CrLf)
Set o_links = Nothing
End If
Set o_doc = Nothing
End If
Object Call o_app.Quit()
Set o_app = Nothing
End If
s_source = s_urlList
If Len(s_urlList) = 0 Then
Function = 0
Else
Function = ParseCount(s_UrlList, $CrLf)
End If
End Function

Function OldGrabURL() As String
Local myShellWindowsClsid  As String, myShellWindowsKey  As String, s_url As String
Local i_windowCount As Long, i_windowMax As Long
Local o_window As Dispatch, o_shellWindows As Dispatch, o_shell As Dispatch
Local v As Variant, v1 As Variant

If 0 Then
'Check to see if ClassID installed
MyShellWindowsClsID = "{9BA05972-F6A8-11CF-A442-00A0C90A8F39}"
MyShellWindowsKey = "PDF2TXT.Shell\CLSID"
If IsFalse EZ_RegExist("CR", MyShellWindowsKey) Then
EZ_SaveRegString "CR", MyShellWindowsKey, "", "", MyShellWindowsClsID
If IsFalse EZ_RegExist("CR", MyShellWindowsKey) Then
Msg_Box "Alert", "Administrative access to computer needed to install this feature"
Exit Function
End If
End If
End If

o_shell = NewCom "Shell.Application"
Object Call o_shell.windows To v
Set o_shellWindows = v
Object Get o_shellwindows.count To v
i_windowcount = Variant#(v)
If i_windowcount = 0 Then
' Msg_Box "Alert", "No web page is open in Internet Explorer"
Exit Function
End If
i_windowmax = i_windowcount - 1
msgbox format$(i_windowmax)
v1 = i_windowMax
Object Call o_shellWindows.Item(v1) To v
Set o_window = v
msgbox format$(isobject(o_window))
Object Get o_window.LocationURL To v
s_url = Variant$(v)
Set o_window = Nothing
Set o_shellWindows = Nothing
Set o_shell = Nothing
Function = s_url
End Function

Function ChildCallBack (ByVal hWndChild As Long, lRaram As Long) As Long
Dim sTempStr            As Asciiz * 255
Dim sListText           As String
Dim lResult             As Long
Dim der As Long
der = GetClassName(hWndChild, sTempStr, 255)
If LCase$(Left$(sTempStr,4)) = "edit" Then
hWin& = hWndChild
Function = 0
Exit Function
End If
Function = 1
End Function

Function GetUrl() As String
Dim i As Long, iCount As Long
Dim oShell As Dispatch, oWindows As Dispatch, oWindow As Dispatch
Dim sUrl As String
Dim v As Variant, v1 As Variant

Shell appPath$ & "GrabURL.exe", 0
Function = FileToString(appPath$ & "GrabUrl.tmp")
Exit Function

GetUrl = ""
' Set oShell = New Dispatch In "Shell.Application"
oShell = NewCom "PDF2TXT.Application"
Object Call oShell.windows To v
Set oWindows = v
' iCount = oWindows.count
Object Get oWindows.count to v
ICount = Variant#(v)
If iCount = 0 Then
sUrl = ""
Else
i = iCount - 1
' msgbox format$(i)
v1 = i
' Object Call oWindows.Item(v1) To v
Object Call oWindows.Item(v1) To v
Set oWindow = v
msgbox format$(isobject(oWindow))
Object Get oWindow.LocationURL To v
SUrl = Variant$(v)
End If
GetUrl = sUrl
Set oWindow = Nothing
Set oWindows = Nothing
Set oShell = Nothing
End Function

%ADDRESS_BAR4=41477
Function GrabURL() As String
Local s_url As String
Local h_ie As Long, h_address As Long

h_ie = FindWindow("", FindWindowName("Microsoft Internet Explorer"))
EnumChildWindows(h_ie, CodePtr(ChildCallBack), 0&)
h_address = hwin&
Local i_length As Long
Local i_return As Long
Local z As Asciiz * 255
i_length = SendMessage(h_address, %WM_GETTEXTLENGTH, ByVal CLng(0), ByVal CLng(0)) + 1
z = String$(i_length,0)
i_return = SendMessage(h_address, %WM_GETTEXT, ByVal i_length, ByVal VarPtr(z))
Function = z
End Function

Function Msg_Box(ByVal s_title As String, ByVal s_text As String) As Long
If CommandLine& Then
If IsFalse StdOut(s_text) Then SayString s_text
Else
MsgBox s_text, (%MB_TASKMODAL Or %MB_ICONINFORMATION Or %MB_OK), s_title
End If
End Function

Function Form1SetBookmark() As Long
Local p1&, p2&
SayString "Set bookmark"
s$ = EZ_GetText("FORM1", %ID_VIEWLABEL)
If s$ = "&View file:" Then
GetControls
file$ = Path_FindFileName(pdfDir$)
EZ_GetRichSel "FORM1", %ID_VIEW, p1&, p2&
Ini_SetKey(iniFile$, "Bookmarks", file$, Format$(p2&))
Else
Msg_Box "Alert", "Cannot set bookmark unless viewing a file"
End If
End Function

Function Form1GoToBookmark() As Long
SayString "Go to bookmark"
Local p1&, p2&
s$ = EZ_GetText("FORM1", %ID_VIEWLABEL)
If s$ = "&View file:" Then
GetControls
file$ = Path_FindFileName(pdfDir$)
s$ = Ini_GetKey(iniFile$, "Bookmarks", file$, "")
If Len(Trim$(s$)) = 0 Then
Msg_Box "Alert", "Cannot find bookmark for file" + $CrLf + file$
Else
p1& = Val(s$)
p2& = p1&
EZ_SetRichSel "FORM1", %ID_VIEW, p1&, p2&
SayLine
End If
Else
Msg_Box "Alert", "Cannot set bookmark unless viewing a file"
End If
End Function

Function SayLine() As Long
hWin& = EZ_Handle("FORM1", %ID_VIEW)
SayString(my_edit_getLine(hwin&, Edit_LineFromChar(hwin&, -1)))
End Function

Function Form1ClearBookmark() As Long
SayString "Clear bookmark"
GetControls
file$ = Path_FindFileName(pdfDir$)
Ini_DeleteKey(iniFile$, "Bookmarks", file$)
End Function

Function Form1GoToPercent() As Long
Local go$, goPercent As Double, p1&, p2&
go$ = Ini_GetKey(iniFile$, "Settings", "Go", "")
go$ = InputBox$("Percent:", "Go To", go$)
Ini_SetKey(iniFile$, "Settings", "Go", go$)
goPercent = Max(0, Val(go$))
goPercent = Min(100, goPercent)
p1& = goPercent * pdfSize& / 100
p2& = p1&
EZ_SetRichSel "FORM1", %ID_VIEW, p1&, p2&
SaYLine
End Function

Function Form1StartSelect() As Long
Local p1&, p2&
SayString "Start selection"
EZ_GetRichSel "FORM1", %ID_VIEW, p1&, p2&
Ini_SetKey(iniFile$, "Settings", "StartSelect", Format$(p1&))
End Function

Function Form1CompleteSelect() As Long
Local p1&, p2&
SayString "Complete selection"
EZ_GetRichSel "FORM1", %ID_VIEW, p1&, p2&
s$ = Ini_GetKey(iniFile$, "Settings", "StartSelect", "")
If Len(Trim$(s$)) = 0 Then
Msg_Box "Alert", "No start of selection was set."
Else
p1& = Val(s$)
EZ_SetRichSel "FORM1", %ID_VIEW, p1&, p2&
End If
End Function

Function Form1CopyAll() As Long
SayString "Copy all"
EZ_SetClipboardFormat 0
EZ_SetClipboard EZ_GetRichText("FORM1", %ID_VIEW, 0, 0)
End Function

Function Form1CopyAppend() As Long
SayString "Copy append"
EZ_SetClipboard Ez_GetClipboard() + $CrLf + $Ff + $CrLf + EZ_GetRichText("FORM1", %ID_VIEW, 0, 1)
End Function

Function IsSourceFolder() As Long
s$ = Trim$(EZ_GetText("FORM1", %ID_PDF))
If (IsFalse Equiv(Path_FindExtension(s$), ".pdf") And Path_IsURL(s$)) Or Path_IsDirectory(s$) Then
Function = 1
Else
Function = 0
End If
End Function

Function IsSourceFile() As Long
s$ = Trim$(EZ_GetText("FORM1", %ID_PDF))
If Equiv(Path_FindExtension(s$), ".pdf") And (Path_IsURL(s$) Or (Path_FileExists(s$) And IsFalse Path_IsDirectory(s$))) Then
Function = 1
Else
Function = 0
End If
End Function

Function AnalyzePDF(ByVal sPDF As String) As String
Local sAnalysis As String

sAnalysis = GetPdf2meta(sPdf)
Replace $CrLf + $CrLf With $CrLf in sAnalysis
replace getTempDir() with PathName$(path, sPdf) in sAnalysis
Function = sAnalysis
End Function

Function GetPDFText(ByVal s_source As String) As String
Local i_pageCount as long
Local s_target as string, s_body as string, s_say As String, s_temp As String, s_command As String, s_oldDir As String

i_pageCount = GetPageCount(s_source)
if i_pageCount = 0 then
SayString("Cannot open " + fn_GetName(s_source))
else
SayString(fn_GetName(s_source) + " = " + StringPlural("page", i_PageCount))
If IsTrue imageFormat& Then
s_body = GetPdf2ocr(s_source)
else
s_body = GetPdf2text(s_source)
if IsBlank(s_body) then s_body = GetText(s_source)
end if
if IsBlank(s_body) then
SayString("No text")
function = AnalyzePdf(s_body)
else
function = s_body
end if
end if
End Function

Function GetPageCountText(ByVal sPDF As String) As String
local ipagecount as long

iPageCount = GetPageCount(sPdf)
Function = StringPlural("page", iPageCount)
end function

Function GetPageCount(ByVal sPDF As String) As long
Local hPdf As DWord
Local iPageCount, iResult As Long
Local oLib As Dispatch
Local sClsId, sLib, sPassword, sReturn, sUnlockKey As WString
Local vPdf, vUnlockKey As Variant

sLib = Exe.Path$ + "pdf2parts.dll"
sClsId = GUID$("{2E75DB15-9312-4902-8DA0-EAC34A6DD40C}")
oLib = NewCom ClsId sClsId Lib sLib
sUnlockKey = $QuickPDF_UnlockKey
vUnlockKey = sUnlockKey
Object Call oLib.UnlockKey(sUnlockKey) To iResult
vPdf = sPdf
Object Call oLib.LoadFromFile(vPdf, sPassword) To hPdf
Object Call oLib.PageCount() To iPageCount
function = iPageCount
Object Call oLib.CloseFile(hPdf) To iResult
Object Call oLib.ReleaseLibrary() To iResult
End Function

FUNCTION Say(sText AS STRING) AS LONG
DIM sExe AS STRING

' If GetForegroundWindow() <> FindWindow("", "PDF to TXT") Then Exit Function

sExe = Exe.Path$ + "SayLine.exe"
SHELL(StringQuote(sExe) & sText, 0)
END FUNCTION

FUNCTION PrintLine(Z AS STRING) AS LONG
Local sExe As String
sExe = Exe.Path$ + "SayLine.exe"
If IsFile(sExe) Then
Say(z)
Exit Function
End if

' returns TRUE (non-zero) on success
   LOCAL hStdOut AS LONG, nCharsWritten AS LONG
   LOCAL w AS STRING
   STATIC CSInitialized AS LONG, CS AS CRITICAL_SECTION
   IF ISFALSE CSInitialized THEN
       InitializeCriticalSection CS
       CSInitialized  =  1
   END IF
   EntercriticalSection Cs
   hStdOut      = GetStdHandle (%STD_OUTPUT_HANDLE)
   IF hSTdOut   = -1& OR hStdOut = 0&   THEN     ' invalid handle value, coded in line to avoid
                                                 ' casting differences in Win32API.INC
                                                 ' test for %NULL added 8.26.04 for Win/XP
     AllocConsole
     hStdOut  = GetStdHandle (%STD_OUTPUT_HANDLE)
   END IF
   LeaveCriticalSection CS
   w = Z & $CRLF
   FUNCTION = WriteFile(hStdOut, BYVAL STRPTR(W), LEN(W),  nCharsWritten, BYVAL %NULL)
 END FUNCTION

FUNCTION StringPlural(sText AS STRING, iCount AS LONG) AS STRING
LOCAL sReturn AS STRING

sReturn = Format$(iCount) + " " + sText
IF iCount <> 1 THEN sReturn = sReturn & "s"
FUNCTION = sReturn
END FUNCTION

Function StringQuote(ByVal s$) As String
Function = Chr$(34) & s$ & Chr$(34)
End Function

Function DialogConfirm(sTitle As String, sMessage As String, sDefault As String) As String
' Get choice from a standard Yes, No, or Cancel message box

Dim iFlags As Long, iChoice As Long

DialogConfirm = ""
iFlags = %mb_YesNoCancel
iFlags = iFlags or %mb_IconQuestion     ' 32 query icon
iFlags = iFlags Or %mb_SystemModal ' 4096   System modal
If sTitle = "" Then sTitle = "Confirm"
If sDefault = "N" Then iFlags = iFlags Or %mb_DefButton2
iChoice = MsgBox(sMessage, iFlags, sTitle)
If iChoice = %IDCancel Then Exit Function

If iChoice = %IDYes Then
DialogConfirm = "Y"
Else
DialogConfirm = "N"
End If
End Function
