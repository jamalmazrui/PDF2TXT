#Include "richedit.inc"

Function FileSize(ByVal f As String) As Long
 On Error Resume Next
  Local FindData As WIN32_FIND_DATA
  Local hDir As Long
  hDir = FindFirstFile(ByVal StrPtr(f), FindData)
  If hDir = %INVALID_HANDLE_VALUE Then
    Function = -1
    Exit Function
  End If
  FindClose hDir
  Function = FindData.nFileSizeLow
End Function

Function RichEditBottom(ByVal hRichEdit As Dword) As Long
Local ch As CHARRANGE
ch.cpMax = SendMessage(hRichEdit, %WM_GETTEXTLENGTH, 0, 0)
ch.cpMin = ch.cpMax
'Function = SendMessage hRichEdit, %EM_EXSETSEL, 0, VarPtr(ch)
End Function

Function RichEditTop(ByVal hRichEdit As Dword) As Long
Local ch As CHARRANGE
'Function = SendMessage hRichEdit, %EM_EXSETSEL, 0, VarPtr(ch)
End Function

Function EditLineEnd(h As Dword) As Long
Function = SendMessage(h, %WM_KEYDOWN, %VK_END, 0)
End Function

Function EditLineStart(h As Dword) As Long
Function = SendMessage(h, %WM_KEYDOWN, %VK_HOME, 0)
End Function

Function URL2File(ByVal z_URL As Asciiz * %MAX_PATH, ByVal z_file As Asciiz * %MAX_PATH) As Long
Function = IsFalse URLDownloadToFile(ByVal 0&, z_url, z_file, ByVal 0&, ByVal 0&)
End Function

Function STDOUT (Z As String) As Long
 ' returns TRUE (non-zero) on success
   Local hStdOut As Long, nCharsWritten As Long
   Local w As String
   Static CSInitialized As Long, CS As CRITICAL_SECTION
   If IsFalse CSInitialized Then
       InitializeCriticalSection CS
       CSInitialized  =  1
   End If
   EntercriticalSection Cs
   hStdOut      = GetStdHandle (%STD_OUTPUT_HANDLE)
   If hSTdOut   = -1& Or hStdOut = 0&   Then     ' invalid handle value, coded in line to avoid
                                                 ' casting differences in Win32API.INC
                                                 ' test for %NULL added 8.26.04 for Win/XP
     AllocConsole
     hStdOut  = GetStdHandle (%STD_OUTPUT_HANDLE)
   End If
   LeaveCriticalSection CS
   w = Z & $CrLf
   Function = WriteFile(hStdOut, ByVal StrPtr(W), Len(W),  nCharsWritten, ByVal %NULL)
 End Function

Function EnumMainWindows(ByVal hWnd As Long, lParam As Dword) As Long
   Global gsEnumWNResults  As String   'store list of windows
   Local iRet              As Long
   Local sEnumBuffer       As String
   If ISWINDOWVISIBLE(hWnd) And (GETPARENT(hWnd) = 0) And ISWINDOWENABLED(hWnd) Then   'Get only visible/parent/enabled windows
      iRet = SENDMESSAGE(hWnd, %WM_GETTEXTLENGTH, 0, 0)
      If iRet Then
         sEnumBuffer = Space$(iRet + 1)
         If SENDMESSAGE(hWnd, %WM_GETTEXT, Len(sEnumBuffer), StrPtr(sEnumBuffer)) Then
            gsEnumWNResults = gsEnumWNResults + $CrLf + Trim$(sEnumBuffer,Any " " + Chr$(0))
         End If
      End If
   End If
   Function = %TRUE      ' continue top-level enumeration...
End Function

Function FindWindowName(ByVal sFindThis As String) As String
   Local iCounter    As Long
   Local sEachName   As String
   gsEnumWNResults = ""
   If ENUMWINDOWS(CodePtr(EnumMainWindows), 0) Then            'retrieve top level window names
      For iCounter = 1 To ParseCount(gsEnumWNResults, $CrLf)   'loop through all top level window names
         sEachName = Parse$(gsEnumWNResults, $CrLf, iCounter)  'parse window name from our buffer string
         If InStr(UCase$(sEachName), UCase$(sFindThis)) Then   'search for any case match
            Function = sEachName                               'found correct window so return that name
            Exit For
         End If
      Next iCounter
   End If
End Function

Function Equiv(ByVal s1 As String, ByVal s2 As String) As Long
Function = LCase$(Trim$(s1)) = LCase$(Trim$(s2))
End Function

FUNCTION FileToString(BYVAL s_file AS ASCIIZ * 256) AS STRING
LOCAL i_size AS LONG, h_file AS LONG, s_return AS STRING

IF IsFalse IsFile(s_File) THEN
s_return =""
ELSE
h_file =FREEFILE
OPEN s_file FOR BINARY AS h_file
i_size =LOF(h_file)
GET$ h_file, i_size, s_return
CLOSE h_file
END IF
FUNCTION =s_return
END FUNCTION

FUNCTION StringToFile(BYVAL s_text AS STRING, BYVAL s_file AS ASCIIZ * 256) AS LONG
LOCAL i_size AS LONG, h_file AS LONG, i_return AS LONG

IF ISTRUE ISFILE(s_file) THEN KILL s_File
'msgbox format$(len(s_text))
IF LEN(s_text) =0 THEN
'If IsFalse Then
i_return =0
ELSE
h_file =FREEFILE
OPEN s_file FOR BINARY AS h_file
i_size =LEN(s_text)
PUT$ h_file, s_text
CLOSE h_file
i_return =1
END IF
FUNCTION =i_return
END FUNCTION

CallBack Function BrowseForFolderProc
    If CbMsg = %BFFM_INITIALIZED Then
        Dialog Send CbHndl, %BFFM_SETSELECTION, %TRUE, CbLParam
End If
Exit Function
    If CbMsg = %BFFM_SELCHANGED Then
        Dim zBuffer As Asciiz * %MAX_PATH
        Call SHGetPathFromIDList(ByVal CbWParam, zBuffer)
        If IsFalse CbWParam Or _                        ' No id number
          IsFalse Len(zBuffer) Or _                     ' No name
          IsFalse (GetAttr(zBuffer) And %SUBDIR) Or _   ' Not a real subdir
          Mid$(zBuffer,2,1) <> ":" Then                 ' Not a local or mapped drive
            Dialog Send CbHndl, %BFFM_ENABLEOK, %FALSE, %FALSE
            Beep
        ElseIf (GetAttr(zBuffer) And %SYSTEM) And Right$(zBuffer,2) <> ":\" Then ' exclude system folders, allow root directories
            Dialog Send CbHndl, %BFFM_ENABLEOK, %FALSE, %FALSE
            Beep
        End If
    End If
End Function

Function BrowseForFolder(hWnd As Long, Title As String, StartFolder As String, IncludeFiles As Long) As String
    Local zBuffer    As Asciiz * %MAX_PATH
    Local bi         As BROWSEINFO
    Local lpIDList   As Long
    Local result     As Long

    bi.hWndOwner    = hWnd
    bi.lpszTitle    = StrPtr(Title)
'    bi.ulFlags      = %BIF_RETURNONLYFSDIRS Or %BIF_DONTGOBELOWDOMAIN Or %BIF_RETURNFSANCESTORS Or %BIF_EDITBOX Or IIf(IncludeFiles, %BIF_BROWSEINCLUDEFILES, 0)
'for Susan, broaden to network
'    bi.ulFlags      = %BIF_VALIDATE Or %BIF_RETURNONLYFSDIRS Or %BIF_DONTGOBELOWDOMAIN Or %BIF_RETURNFSANCESTORS Or %BIF_EDITBOX Or IIf(IncludeFiles, %BIF_BROWSEINCLUDEFILES, 0)
    bi.ulFlags      = %BIF_VALIDATE Or %BIF_RETURNONLYFSDIRS Or %BIF_RETURNFSANCESTORS Or %BIF_EDITBOX Or IIf(IncludeFiles, %BIF_BROWSEINCLUDEFILES, 0)
    bi.lpfnCallback = CodePtr(BrowseForFolderProc)
    bi.lParam       = StrPtr(StartFolder)
    lpIDList        = SHBrowseForFolder(bi)

    If IsTrue lpIDList And SHGetPathFromIDList(ByVal lpIDList, zBuffer) Then
        Function = zBuffer
        CoTaskMemFree lpIDList
Else
'        CoTaskMemFree lpIDList
    End If
End Function


#Include "ShLwApi.inc"
'PathIsHTMLFile
'PathIsLFNFileSpec

Function Path_AddBackslash(ByVal sPath As String) As String
Local z As Asciiz * %MAX_PATH
z = sPath
PathAddBackslash(z)
Function = z
End Function

Function Path_AddExtension(ByVal sPath As String, ByVal sExt As String) As String
Local z As Asciiz * %MAX_PATH
z = sPath
PathAddExtension(z, ByCopy sExt)
Function = z
End Function

Function Path_FileExists(ByVal sPath As String) As Long
Function = PathFileExists(ByCopy sPath)
End Function

Function Path_FindPath(ByVal sPath As String) As String
Local i As Long, j As Long, k As Long
sPath = Trim$(sPath, Any $CrLf)
k = Len(sPath)
i = InStr(-1, sPath, "\")
i = Max(i, InStr(-1, sPath, "/"))
Function = Mid$(sPath, 1, i)
End Function

Function Path_FindExtension(ByVal sPath As String) As String
Local i As Long, j As Long, k As Long
Local z As Asciiz * %MAX_PATH
z = Trim$(sPath, Any $CrLf)
k = Len(z)
If 1 Then
i = InStr(-1, z, ".")
If i Then
Function = Trim$(Mid$(z, i, k - i +1))
Else
Function = ""
End If
Else
i = VarPtr(z)
j = PathFindExtension(z)
Function = Peek$(j, k - (J -I))
End If
End Function

Function Path_FindFileName(ByVal sPath As String) As String
Local z As Asciiz * %MAX_PATH
Local i As Long, j As Long, k As Long
z = Trim$(sPath, Any $CrLf)
k = Len(z)
i = VarPtr(z)
j = PathFindFileName(z)
Function = Peek$(j, k - (J -I))
End Function

Function Path_GetCharType(ByVal sChar As Byte) As Long
Function = PathGetCharType(sChar)
End Function

Function Path_IsDirectory(ByVal sPath As String) As Long
Function = PathIsDirectory(ByCopy sPath)
End Function

Function Path_IsDirectoryEmpty(ByVal sPath As String) As Long
'Function = PathIsDirectoryEmpty(sPath)
End Function

Function Path_IsFileSpec(ByVal sPath As String) As Long
Function = PathIsFileSpec(ByCopy sPath)
End Function

Function Path_IsRoot(ByVal sPath As String) As Long
Function = PathIsRoot(ByCopy sPath)
End Function

Function Path_IsURL(ByVal sPath As String) As Long
Function = PathIsURL(ByCopy sPath)
End Function

Function Path_MatchSpec(ByVal sPath As String, ByVal sSpec As String) As Long
Function = PathMatchSpec(ByCopy sPath, ByCopy sSpec)
End Function

Function Path_QuoteSpaces(ByVal sPath As String) As String
Local z As Asciiz * %MAX_PATH
z = sPath
PathQuoteSpaces(z)
Function = z
End Function

Function Path_RemoveArgs(ByVal sPath As String) As String
Local z As Asciiz * %MAX_PATH
z = sPath
PathRemoveArgs(z)
Function = z
End Function

Function Path_RemoveBackslash(ByVal sPath As String) As String
Local z As Asciiz * %MAX_PATH
z = sPath
PathRemoveBackslash(z)
Function = z
End Function

Function Path_RemoveExtension(ByVal sPath As String) As String
Local z As Asciiz * %MAX_PATH
z = sPath
PathRemoveExtension(z)
Function = z
End Function

Function Path_RemoveFileSpec(ByVal sPath As String) As String
Local z As Asciiz * %MAX_PATH
z = sPath
PathRemoveFileSpec(z)
Function = z
End Function

Function Path_RenameExtension(ByVal sPath As String, ByVal sExt As String) As String
Local z As Asciiz * %MAX_PATH
z = sPath
PathRenameExtension(z, ByCopy sExt)
Function = z
End Function

Function Path_StripPath(ByVal sPath As String) As String
Local z As Asciiz * %MAX_PATH
z = sPath
PathStripPath(z)
Function = z
End Function

Function Path_UnquoteSpaces(ByVal sPath As String) As String
Local z As Asciiz * %MAX_PATH
z = sPath
PathUnquoteSpaces(z)
Function = z
End Function

'missing functions
'Function Path_
'End Function

Function AppExeName() As String
On Error Resume Next
  Local hModule As Long
  Local buffer  As Asciiz * 256
  hModule = GetModuleHandle(ByVal 0&)
  GetModuleFileName hModule, Buffer, 256
  Function = Buffer
End Function
