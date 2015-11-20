'File Name 1.0 function library 
'September 13, 2007
'Public Domain by Jamal Mazrui

#Include "shlwapi.inc"

Function FN_AddSlash(ByVal sPath As String) As String
'Returns path with trailing backslash

Local s As String * 1

sPath = Trim$(sPath, Any $Spc + $Nul + $Dq)
s = IIf$(InStr(sPath, "/"), "/", "\")
Function = RTrim$(sPath, s) + s
End Function

Function FN_AddExt(ByVal sPath As String, ByVal sExt As String) As String
'Returns path with extension added.

sPath = Trim$(sPath, Any $Spc + $Nul + $Dq)
                                        sExt = Trim$(sExt, Any $Spc + $Nul + $Dq)
Function = RTrim$(sPath, ".") + "." + LTrim$(sExt, ".")
End Function

Function FN_GetExt(ByVal sPath As String) As String
'Returns extension in path including leading period
Local i As Long

sPath = Trim$(sPath, Any $Spc + $Nul + $Dq)
                                                      i = InStr(-1, sPath, ".")
If i Then Function = Mid$(sPath, i)
End Function

Function FN_GetName(ByVal sPath As String) As String
'Returns file name in path, i.e., base name and extension.

Local i As Long

sPath = Trim$(sPath, Any $Spc + $Nul + $Dq)
i = InStr(-1, sPath, Any ":\/")
If i Then
Function = Mid$(sPath, i + 1)
Else

Function = sPath
End If
End Function

Function FN_GetFull(ByVal sPath As String) As String
'Returns fully qualified name of file if found on Windows search path.

Local z As Asciiz * %MAX_PATH

sPath = Trim$(sPath, Any $Spc + $Nul + $Dq)
z = sPath
'PathFindOnPath(z, ByVal 0)
GetFullPathName(z, SizeOf(z), z, ByVal 0)
Function = Trim$(z, Any $Spc + $Nul)
End Function

Function FN_SetCase(ByVal sPath As String) As String
'Returns path converted to lower case if only upper case letters found.

Local z As Asciiz * %MAX_PATH

sPath = Trim$(sPath, Any $Spc + $Nul + $Dq)
z = sPath
PathMakePretty(z)
Function = Trim$(z, Any $Spc + $Nul)
               End Function

Function FN_Quote(ByVal sPath As String) As String
'Returns path with quotes added if space found.

sPath = Trim$(sPath, Any $Spc + $Nul + $Dq)
Function = $Dq + sPath + $Dq
End Function

Function FN_DelSh(ByVal sPath As String) As String
'Returns path with trailing backslash removed.

sPath = Trim$(sPath, Any $Spc + $Nul + $Dq)

Function = RTrim$(sPath, Any "\/")
End Function

Function FN_DelExt(ByVal sPath As String) As String
'Returns path with extension removed.

Local i As Long

i = InStr(-1, sPath, ".")
If i Then
Function = Mid$(sPath, 1, i - 1)
Else
Function = sPath
End If
End Function

Function FN_RenExt(ByVal sPath As String, ByVal sExt As String) As String
'Returns path with another extension, added if not found.

Function = FN_AddExt(FN_DelExt(sPath), sExt)
End Function

Function FN_DelQuote(ByVal sPath As String) As String
'Returns path with enclosing quotes removed.

Function = Trim$(sPath, Any $Spc + $Nul + $Dq)
End Function


'Additional functions using same naming conventions.

Function FN_GetBase(ByVal sPath As String) As String
'Returns base name in path, i.e., file name without extension.

Local i As Long

Function = FN_DelExt(Fn_GetName(sPath))
End Function

Function FN_GetDrive(ByVal sPath As String) As String
'Returns drive letter (A-Z) in path.  Similar to PathGetDriveNumber.

Local s As String * 1

sPath = Trim$(sPath, Any $Spc + $Nul + $Dq)
s = UCase$(Mid$(sPath, 1, 1))
If Mid$(sPath, 2, 1) = ":" And s <> LCase$(s) Then Function = s
End Function

Function FN_GetDir(ByVal sPath As String) As String
'Returns folder in path.

Local i As Long

sPath = Trim$(sPath, Any $Spc + $Nul + $Dq)
i = InStr(-1, sPath, Any "\/")
If i Then Function = Mid$(sPath, 1, i - 1)
End Function

Function FN_GetPath(ByVal sPath As String) As String
'Returns path with file name removed, i.e., folder and trailing backslash.

Local i As Long
Local s As String * 1

sPath = Trim$(sPath, Any $Spc + $Nul + $Dq)
s = IIf$(InStr(sPath, "/"), "/", "\")
sPath = FN_GetDir(sPath)
If Len(sPath) > 0 Then Function = RTrim$(sPath, Any "\/") + s
End Function

Function FN_GetRoot(ByVal sPath As String) As String
'Returns root information in path.

Local i As Long, j As Long, k As Long
Local s As String * 1

sPath = Trim$(sPath, Any $Spc + $Nul + $Dq)
s = UCase$(Mid$(sPath, 1, 1))
If Mid$(sPath, 2, 1) = ":" And s <> LCase$(s) Then
s = Mid$(s, 3, 1)
s = IIf$(InStr("\/", s), s, IIf$(InStr(sPath, "/"), "/", "\"))
Function = Mid$(sPath, 1, 2) + s
ElseIf Mid$(sPath, 1, 2) = "\\" Then
i = InStr(4, sPath, "\")
If i Then Function = Mid$(sPath, 1, i)
Else
i = InStr(sPath, "://")
j = InStr(i + 4, sPath, ".")
k = InStr(j + 2, sPath, Any "\/")
'If (i > 1) And (j > i) And ((k = 0) Or (k > j)) Then Function = Mid$(sPath, 1, Iif(k, k, "/")
End If
End Function

Function FN_IsDir(ByVal sPath As String) As Long
'Returns True if path refers to an existing folder.

sPath = Trim$(sPath, Any $Spc + $Nul + $Dq)
Function = PathIsDirectory(ByVal StrPtr(sPath))
End Function

Function FN_IsFile(ByVal sPath As String) As Long
'Returns True if path refers to an existing file, False otherwise.  Analagous to PathIsDirectory for a folder.

sPath = Trim$(sPath, Any $Spc + $Nul + $Dq)
Function = PathFileExists(ByVal StrPtr(sPath)) And IsFalse PathIsDirectory(ByVal StrPtr(sPath))
End Function

Function FN_RenBase(ByVal sPath As String, ByVal sBase As String) As String
'Returns path with another base name.

sBase = Trim$(sBase, Any $Spc + $Nul + $Dq + "\/")
Function = FN_GetPath(sPath) + RTrim$(sBase, ".") + FN_GetExt(sPath)
End Function

Function FN_RenName(ByVal sPath As String, ByVal sName As String) As String
'Returns path with another file name.

sName = Trim$(sPath, Any $Spc + $Nul + $Dq + "\/")
Function = FN_GetPath(sPath) + RTrim$(sName, ".")
End Function


                                                 Function FN_GetApp() As String
Local z As Asciiz * %MAX_PATH

GetModuleFileName(%NULL, z, SizeOf(z))
Function = z
End Function
Function FN_IsSamePath(ByVal sPath1 As String, ByVal sPath2 As String) As Long
Local z1 As Asciiz * %MAX_PATH, z2 As Asciiz * %MAX_PATH

sPath1 = Trim$(sPath1, Any $Nul + $Spc + $Dq)
sPath2 = Trim$(sPath2, Any $Nul + $Spc + $Dq)
GetShortPathName(ByVal StrPtr(sPath1), z1, SizeOf(z1))
GetShortPathName(ByVal StrPtr(sPath2), z2, SizeOf(z2))
Function = (LCase$(z1) = LCase$(z2))
End Function

Function FN_GetUNC(ByVal sPath As String) As String
Local u As UNIVERSAL_NAME_INFO Ptr
Local z As Asciiz * 1024

u = VarPtr(z)
WNetGetUniversalName(ByVal StrPtr(sPath), %UNIVERSAL_NAME_INFO_LEVEL, ByVal u, 1024)
Function = @u.@lpUniversalName
End Function

Function FN_GetLFN(ByVal sPath As String) As String
Local z As Asciiz * %MAX_PATH

sPath = Trim$(sPath, $Nul + $Spc + $Dq)
z = sPath
GetLongPathName(z, z, SizeOf(z))
Function = Trim$(z, Any $Nul + $Spc)
End Function

Function FN_GetSFN(ByVal sPath As String) As String
Local z As Asciiz * %MAX_PATH

sPath = Trim$(sPath, $Nul + $Spc + $Dq)
z = sPath
GetShortPathName(z, z, SizeOf(z))
Function = Trim$(z, Any $Nul + $Spc)
End Function

Function FN_GetWinPath() As String
Local z As Asciiz * %MAX_PATH

GetWindowsDirectory(z, SizeOf(z))
Function = FN_AddSlash(Trim$(z, Any $Nul + $Spc))
End Function

Function FN_GetSysPath() As String
Local z As Asciiz * %MAX_PATH

GetSystemDirectory(z, SizeOf(z))
Function = FN_AddSlash(Trim$(z, Any $Nul + $Spc))
End Function

Function FN_GetTempPath() As String
Local z As Asciiz * %MAX_PATH

GetTempPath(SizeOf(z), z)
Function = Trim$(z, Any $Nul + $Spc)
End Function

Function FN_MakeTempFile(Optional ByVal sPath As String) As String
Local z As Asciiz * %MAX_PATH

If Len(sPath) = 0 Then sPath = FN_GetTempPath()
GetTempFilename(ByVal StrPtr(sPath), "fn_", 0, z)
Function = Trim$(z, Any $Nul + $Spc)
End Function

Function FN_MakeTempDir(Optional ByVal sPath As String) As String
Local s As String

s = FN_MakeTempFile(sPath)
If FN_IsFile(s) Then
Kill s
MkDir s
End If
Function = s
End Function

Function FN_GetSpecialPath(ByVal iFolder As Long) As String
Local z As Asciiz * %MAX_PATH

SHGetSpecialFolderPath(0, z, iFolder, 0)
Function = z
End Function
Function FN_GetTime(ByVal sPath As String) As String
Local iYear As Long, iMonth  As Long, iDay  As Long, iHour As Long, iMinute As Long, iSecond As Long
Local CreationTime As FILETIME, LastAccessTime As FILETIME, LastWriteTime  As FILETIME, LT  As FILETIME, ST As SYSTEMTIME
Local ReOpenBuff As OFSTRUCT, nFile  As Long, hFile  As Dword

Try
nFile = FreeFile
Open sPath For Input Access Read Lock Shared As #nFile
Catch
Exit Function
Finally
hFile = FileAttr(nFile, 2)
GetFileTime hFile, CreationTime, LastAccessTime, LastWriteTime
Close #nFile
FileTimeToLocalFileTime LastWriteTime, LT
FileTimeToSystemTime LT, ST
iYear   = ST.wYear
iMonth  = ST.wMonth
iDay    = ST.wDay
iHour   = ST.wHour
iMinute = ST.wMinute
iSecond = ST.wSecond
' Function = Format$(iYear, "0000") + Format$(iMonth, "00") + Format$(iDay, "00") + Format$(iHour, "00") + Format$(iMinute, "00") + Format$(iSecond, "00")
Function = Format$(iYear, "0000") & "-" & Format$(iMonth, "00") & "-" & Format$(iDay, "00") & " " & Format$(iHour, "00") & ":" & Format$(iMinute, "00") & ":" & Format$(iSecond, "00")
End Try
End Function

Function FN_SetTime(sPath As String, sTime As String) As Long
Local iYear As Long, iMonth As Long, iDay As Long, iHour As Long, iMinute As Long, iSecond As Long
Local nFile As Long, hFile As Dword, lpReOpenBuff As OFSTRUCT
Local CreationTime As FILETIME, LastAccessTime As FILETIME, LastWriteTime As FILETIME, ST As SYSTEMTIME, LT As FILETIME

iYear = Val(Mid$(sTime, 1, 4))
iMonth = Val(Mid$(sTime, 5, 2))
iDay = Val(Mid$(sTime, 7, 2))
iHour = Val(Mid$(sTime, 9, 2))
iMinute = Val(Mid$(sTime, 11, 2))
iSecond = Val(Mid$(sTime, 13, 2))

Try
nFile = FreeFile
'Open sPath For Binary As #nFile
Open sPath For Append Access Read Write Lock Shared As #nFile
Catch
Exit Function
Finally
hFile = FileAttr(nFile,2)
GetFileTime hFile, CreationTime, LastAccessTime, LastWriteTime
FileTimeToLocalFileTime LastWriteTime, LT
FileTimeToSystemTime LT, ST

ST.wYear   = iYear
ST.wMonth  = iMonth
ST.wDay    = iDay
ST.wHour   = iHour
ST.wMinute = iMinute
ST.wSecond = iSecond

SystemTimeToFileTime ST, LT
LocalFileTimeToFileTime LT, LastWriteTime
SetFileTime hFile, CreationTime, LastAccessTime, LastWriteTime
Close #nFile
End Try
End Function
