#IF NOT %DEF(%EOIniINC)
  %EOIniINC = 1


  '---------------------------------------------------------------------------
  ' Determines if a line of text is a Comment Line (ex. "; Comment")
  ' Returns: %TRUE  if line is a comment line
  '          %FALSE if line is not a comment line
  '---------------------------------------------------------------------------
  FUNCTION INI_LineIsComment(BYVAL TextLine AS STRING) AS LONG
    FUNCTION = %FALSE
    IF TextLine = "" THEN EXIT FUNCTION
    TextLine = UCASE$(LTRIM$(TextLine))
    IF LEFT$(TextLine, 1) = ";" THEN
      FUNCTION = %TRUE
    END IF
  END FUNCTION

  '---------------------------------------------------------------------------
  ' Determines if a line of text is a valid section (ex. "[Section]")
  ' Returns: %TRUE  if line is a Section line
  '          %FALSE if line is not a Section line
  '---------------------------------------------------------------------------
  FUNCTION INI_LineIsSection(BYVAL TextLine AS STRING) AS LONG
    FUNCTION = %FALSE
    IF TextLine = "" THEN EXIT FUNCTION
    IF LEFT$(TextLine, 1) = "[" THEN
      IF RIGHT$(TextLine, 1) = "]" THEN
        FUNCTION = %TRUE
      END IF
    END IF
  END FUNCTION

  '---------------------------------------------------------------------------
  ' Determines if a line of text is a valid Key (ex. "KeyName=Key value")
  ' Returns: %TRUE  if line is a Key line
  '          %FALSE if line is not a Key line
  '---------------------------------------------------------------------------
  FUNCTION INI_LineIsKey(BYVAL TextLine AS STRING) AS LONG
    DIM Looper AS LONG

    FUNCTION = %FALSE
    IF INI_LineIsSection(TextLine) = %FALSE THEN
      FOR Looper = 1 TO LEN(TextLine)
        IF MID$(TextLine, Looper, 1) <> "=" THEN ITERATE FOR
        FUNCTION = %TRUE
        EXIT FOR
      NEXT Looper
    END IF
  END FUNCTION

  '---------------------------------------------------------------------------
  ' Determines if a section exists in a given INI file
  ' Returns: %TRUE  if lSection exists inside IniFile
  '          %FALSE if lSection does not exists inside IniFile
  '---------------------------------------------------------------------------
  FUNCTION INI_SectionExists(BYVAL IniFile AS STRING, BYVAL lSection AS STRING) AS LONG
    DIM InputData AS STRING
    DIM FileID AS LONG

    IF DIR$(IniFile) = "" THEN EXIT FUNCTION
    FUNCTION = %FALSE
    ON ERROR RESUME NEXT
    OPEN IniFIle FOR INPUT AS #FileID
    DO WHILE NOT EOF(FileID)
      LINE INPUT #FileID, InputData
      IF UCASE$(InputData) = "[" + UCASE$(lSection) + "]" THEN
        FUNCTION = %TRUE
        EXIT DO
      END IF
    LOOP
    CLOSE #FileID
  END FUNCTION

  '---------------------------------------------------------------------------
  ' Determines if a Key exists inside lSection in a given INI file
  ' Returns: %TRUE  if lKey exists inside lSection section
  '          %FALSE if lKey does not exists inside lSection section
  '---------------------------------------------------------------------------
  FUNCTION INI_KeyExists(BYVAL IniFile AS STRING, BYVAL lSection AS STRING, BYVAL lKey AS STRING) AS LONG
    DIM InputData AS STRING
    DIM FileID AS LONG
    DIM InsideSection AS LONG

    IF DIR$(IniFile) = "" THEN EXIT FUNCTION
    FUNCTION = %FALSE
    ON ERROR RESUME NEXT
    OPEN IniFIle FOR INPUT AS #FileID
    DO WHILE NOT EOF(FileID)
      LINE INPUT #FileID, InputData
      IF TRIM$(InputData) = "" THEN ITERATE DO
      IF ISFALSE(InsideSection) THEN
        IF UCASE$(InputData) = "[" & UCASE$(lSection) & "]" THEN
          InsideSection = %TRUE
        END IF
      ELSE
        IF ISTRUE(INI_LineIsSection(InputData)) THEN
          EXIT DO
        ELSE
          IF ISTRUE(INI_LineIsKey(InputData)) THEN
            IF LEFT$(InputData, LEN(lKey)) = lKey THEN
              FUNCTION = %TRUE
            END IF
          END IF
        END IF
      END IF
    LOOP
    CLOSE #FileID
  END FUNCTION

  '---------------------------------------------------------------------------
  ' Extract Section name without [ and ]
  ' Returns: a STRING containing the section name without [ and ]
  '---------------------------------------------------------------------------
  FUNCTION INI_SectionNameOnly(BYVAL lSection AS STRING) AS STRING
    FUNCTION = REMOVE$(TRIM$(lSection), ANY "[]")
  END FUNCTION

  '---------------------------------------------------------------------------
  ' Extract Key name from a line
  ' Returns: a STRING with only the Key name
  '---------------------------------------------------------------------------
  FUNCTION INI_KeyNameOnly(BYVAL lLine AS STRING) AS STRING
    DIM iPos AS LONG

    lLine = LTRIM$(lLine)
    iPos = INSTR(1,lLine,"=")
    IF iPos > 0 THEN
      FUNCTION = LEFT$(lLine, iPos - 1)
    END IF
  END FUNCTION

  '---------------------------------------------------------------------------
  ' Get a Key value from an INI file
  ' Returns: a STRING with the value of lKey inside lSection
  '          if lKey is not found, lDefault value is returned
  '---------------------------------------------------------------------------
  FUNCTION INI_GetKey (BYVAL IniFile AS STRING, BYVAL lSection AS STRING, BYVAL lKey AS STRING, BYVAL lDefault AS STRING) AS STRING
    DIM zText AS ASCIIZ * 512

    GetPrivateProfileString BYCOPY lSection, BYCOPY lKey, BYCOPY lDefault, zText, SIZEOF(zText), BYCOPY IniFile
    FUNCTION = zText
  END FUNCTION

  '---------------------------------------------------------------------------
  ' Set a Key value in an INI file
  '---------------------------------------------------------------------------
  FUNCTION INI_SetKey (BYVAL IniFile AS STRING, BYVAL lSection AS STRING, BYVAL lKey AS STRING, BYVAL Value AS STRING) AS LONG
    FUNCTION = WritePrivateProfileString(BYCOPY lSection, BYCOPY lKey, BYCOPY Value, BYCOPY IniFile)
  END FUNCTION

  '---------------------------------------------------------------------------
  ' Delete an entire section and all it's keys from a given INI file
  '---------------------------------------------------------------------------
  FUNCTION INI_DeleteSection(BYVAL IniFile AS STRING, BYVAL lSection AS STRING) AS LONG
    FUNCTION = %FALSE
    IF DIR$(IniFile) = "" THEN EXIT FUNCTION
    IF ISFALSE(INI_SectionExists(IniFile, lSection)) THEN
      EXIT FUNCTION
    END IF
    FUNCTION = WritePrivateProfileString(BYCOPY lSection, BYVAL %NULL, BYVAL %NULL, BYCOPY IniFile)
  END FUNCTION

  '---------------------------------------------------------------------------
  ' Delete a key from a given INI file
  '---------------------------------------------------------------------------
  FUNCTION INI_DeleteKey(BYVAL IniFile AS STRING, BYVAL lSection AS STRING, BYVAL lKeyName AS STRING) AS LONG
    FUNCTION = %FALSE
    IF DIR$(IniFile) = "" THEN EXIT FUNCTION
    FUNCTION = WritePrivateProfileString(BYCOPY lSection, BYCOPY lKeyName, BYVAL %NULL, BYCOPY IniFile)
  END FUNCTION

  '---------------------------------------------------------------------------
  ' Delete a key's value from an INI file
  '---------------------------------------------------------------------------
  FUNCTION INI_DeleteKeyValue(BYVAL IniFile AS STRING, BYVAL lSection AS STRING, BYVAL lKeyName AS STRING) AS LONG
    FUNCTION = %FALSE
    IF DIR$(IniFile) = "" THEN EXIT FUNCTION
    FUNCTION = WritePrivateProfileString(BYCOPY lSection, BYCOPY lKeyName, "", BYCOPY IniFile)
  END FUNCTION

  '---------------------------------------------------------------------------
  ' Returns the total number of sections in a given INI file
  '---------------------------------------------------------------------------
  FUNCTION INI_GetTotalSections(BYVAL IniFile AS STRING) AS LONG
    DIM FileID AS LONG
    DIM Counter AS LONG
    DIM InputData AS STRING

    IF DIR$(IniFile) = "" THEN EXIT FUNCTION
    ON ERROR RESUME NEXT
    FileID = FREEFILE
    OPEN IniFile FOR INPUT AS #FileID
    DO WHILE NOT EOF(FileID)
      LINE INPUT #FileID, InputData
      IF INI_LineIsSection(InputData) THEN Counter = Counter + 1
    LOOP
    CLOSE #FileID
    FUNCTION = Counter
  END FUNCTION

  '---------------------------------------------------------------------------
  ' Returns the total number of keys in a given INI file
  '---------------------------------------------------------------------------
  FUNCTION INI_GetTotalKeys(BYVAL IniFile AS STRING) AS LONG
    DIM FileID AS LONG
    DIM Counter AS LONG
    DIM InputData AS STRING

    IF DIR$(IniFile) = "" THEN EXIT FUNCTION
    ON ERROR RESUME NEXT
    FileID = FREEFILE
    OPEN IniFile FOR INPUT AS #FileID
    DO WHILE NOT EOF(FileID)
      LINE INPUT #FileID, InputData
      IF INI_LineIsKey(InputData) THEN INCR Counter
    LOOP
    CLOSE #FileID
    FUNCTION = Counter
  END FUNCTION

  '---------------------------------------------------------------------------
  ' Returns the total number of keys in 1 given section.
  '---------------------------------------------------------------------------
  FUNCTION INI_GetSectionTotalKeys(BYVAL IniFile AS STRING, BYVAL lSection AS STRING) AS LONG
    DIM FileID AS LONG
    DIM InputData AS STRING
    DIM InsideSection AS LONG
    DIM NumKeys AS LONG

    IF DIR$(IniFile) = "" THEN EXIT FUNCTION
    IF ISFALSE(INI_SectionExists(IniFile, lSection)) THEN EXIT FUNCTION
    InsideSection = %FALSE
    ON ERROR RESUME NEXT
    FileID = FREEFILE
    OPEN IniFile FOR INPUT AS #FileID
    DO WHILE NOT EOF(FileID)
      LINE INPUT #FileID, InputData
      IF TRIM$(InputData) = "" THEN ITERATE DO
      IF ISFALSE(InsideSection) THEN
        IF UCASE$(InputData) = "[" & UCASE$(lSection) & "]" THEN
          InsideSection = %TRUE
        END IF
      ELSE
        IF ISTRUE(INI_LineIsSection(InputData)) THEN
          EXIT DO
        ELSE
          IF ISTRUE(INI_LineIsKey(InputData)) THEN
            NumKeys = NumKeys + 1
          END IF
        END IF
      END IF
    LOOP
    CLOSE #FileID
    FUNCTION = NumKeys
  END FUNCTION

  '---------------------------------------------------------------------------
  ' Get the list of all Sections inside a INI File
  ' Names separated by CRLF
  '---------------------------------------------------------------------------
  FUNCTION INI_GetSectionsList(BYVAL IniFile AS STRING) AS STRING
    DIM FileID AS LONG
    DIM Counter AS LONG
    DIM InputData AS STRING
    DIM tmpList AS STRING

    IF DIR$(IniFile) = "" THEN EXIT FUNCTION
    ON ERROR RESUME NEXT
    FileID = FREEFILE
    OPEN IniFile FOR INPUT AS #FileID
    DO WHILE NOT EOF(FileID)
      LINE INPUT #FileID, InputData
      IF INI_LineIsSection(InputData) THEN
        InputData = INI_SectionNameOnly(InputData)
        INCR Counter
        IF Counter = 1 THEN
          tmpList = InputData
        ELSE
          tmpList = tmpList + $CRLF + InputData
        END IF
      END IF
    LOOP
    CLOSE #FileID
    FUNCTION = tmpList
  END FUNCTION

  '---------------------------------------------------------------------------
  ' Get the Index of a Section inside a INI File
  '---------------------------------------------------------------------------
  FUNCTION INI_GetSectionIndex(BYVAL IniFile AS STRING, BYVAL lSection AS STRING) AS LONG
    DIM tmpList AS STRING
    DIM SectionName AS STRING
    DIM Count AS LONG

    tmpList = UCASE$(INI_GetSectionsList(IniFile))
    lSection = UCASE$(lSection)
    FOR Count = 1 TO PARSECOUNT(tmpList, $CRLF)
      IF PARSE$(tmpList, $CRLF, Count) = lSection THEN
        FUNCTION = Count
        EXIT FOR
      END IF
    NEXT Count
  END FUNCTION

  '---------------------------------------------------------------------------
  ' Get the list of all Keys inside a Section
  ' Names separated by CRLF
  '---------------------------------------------------------------------------
  FUNCTION INI_GetSectionKeyList(BYVAL IniFile AS STRING, BYVAL lSection AS STRING) AS STRING
    DIM FileID AS LONG
    DIM InputData AS STRING
    DIM tmpList AS STRING
    DIM InsideSection AS LONG
    DIM Count AS LONG

    IF DIR$(IniFile) = "" THEN EXIT FUNCTION
    IF ISFALSE(INI_SectionExists(IniFile, lSection)) THEN EXIT FUNCTION
    InsideSection = %FALSE
    ON ERROR RESUME NEXT
    FileID = FREEFILE
    OPEN IniFile FOR INPUT AS #FileID
    DO WHILE NOT EOF(FileID)
      LINE INPUT #FileID, InputData
      IF TRIM$(InputData) = "" THEN ITERATE DO
      IF ISFALSE(InsideSection) THEN
        IF UCASE$(InputData) = "[" & UCASE$(lSection) & "]" THEN
          InsideSection = %TRUE
        END IF
      ELSE
        IF ISTRUE(INI_LineIsSection(InputData)) THEN
          EXIT DO
        ELSE
          IF ISTRUE(INI_LineIsKey(InputData)) THEN
            INCR Count
            InputData = INI_KeyNameOnly(InputData)
            IF Count = 1 THEN
              tmpList = InputData
            ELSE
              tmpList = tmpList + $CRLF + InputData
            END IF
          END IF
        END IF
      END IF
    LOOP
    CLOSE #FileID
    FUNCTION = tmpList
  END FUNCTION

  '---------------------------------------------------------------------------
  ' Get the Index of a Key inside a Section
  '---------------------------------------------------------------------------
  FUNCTION INI_GetSectionKeyIndex(BYVAL IniFile AS STRING, BYVAL lSection AS STRING, BYVAL lKey AS STRING) AS LONG
    DIM tmpList AS STRING
    DIM SectionName AS STRING
    DIM Count AS LONG

    tmpList = UCASE$(INI_GetSectionKeyList(IniFile, lSection))
    lKey = UCASE$(lKey)
    FOR Count = 1 TO PARSECOUNT(tmpList, $CRLF)
      IF PARSE$(tmpList, $CRLF, Count) = lKey THEN
        FUNCTION = Count
        EXIT FOR
      END IF
    NEXT Count
  END FUNCTION

#ENDIF
