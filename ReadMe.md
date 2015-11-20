# PDF2TXT

Version 4.0
November 20, 2015  
Copyright 2005 - 2015 by Jamal Mazrui  
GNU Lesser General Public License (LGPL)

## Contents

- [Description](#description)
- [Installation](#installation)
- [Choosing PDF Source and TXT Target](#choosing-pdf-source-and-txt-target)
- [Text Extraction Settings](#text-extraction-settings)
- [Viewing Area](#viewing-area)
- [Toggling between a File and Folder List](#toggling-between-a-file-and-folder List)
- [Configuration Check Boxes](#configuration-check Boxes)
- [Action Buttons](#action-buttons)
- [URL Source,](#url-source,)
- [Hot Keys](#hot-keys)
- [The Log File](#the-log-file)
- [Command Line Operation](#command-line-operation)
- [File Association](#file-association)
- [Change Log](#change-log)
- [Development Notes](#development-notes)

## Description

PDF to TXT -- also written as PDF2TXT -- is a free program for converting files in Portable Document Format (.pdf extension) to plain text(.txt extension).  The program lets you convert multiple files in a single, batch operation, either from a GUI dialog or a console-mode command line.  The resulting text files can be read in almost any editing or viewing program.  PDF2TXT, itself, also includes a plain text view for reading PDF files.  The program should work on any version of Windows.

# Installation

The installation program for PDF2TXT is called PDF2TXT_setup.exe.  When executed, it prompts for an installation folder for the program.  The default folder is `c:\PDF2TXT`.  Although this is not a standard location for programs on a Windows computer, benefits include fewer keystrokes to type when entering paths to .pdf source or .txt target files, as well as the ability to put files in subfolders of the program without needing administrative rights.  If you want a standard installation folder, however, respond to the prompt by entering `c:\Program Files (x86)\PDF2TXT`.

The installation process creates a program group for PDF2TXT on the Windows start menu, containing choices to launch PDF2TXT, read Documentation for PDF2TXT, and uninstall PDF2TXT.  Also created is a desktop shortcut with an associated hot key, enabling PDF2TXT to be conveniently launched by pressing Control+Alt+Shift+P.  Another shortcut is placed in the Send To folder so that a PDF may be viewed in PDF2TXT via the context menu in Windows Explorer.

## Choosing PDF Source and TXT Target

After PDF2TXT is installed, launching it activates a main dialog with several capabilities and settings.  First, it prompts you to select a PDF source.  This can be either a single PDF file or a folder containing multiple PDF files (another section explains how it can also be an Internet URL).  In the initial edit box, you can type the full path to the file or folder desired.  Alternatively, you can tab to buttons that invoke different sub dialogs depending on whether you want to choose a file or folder as the PDF source.  (Yet another option, described later, is to pass the path to the PDF source as a parameter on the command line when pdf2txt.exe is launched.)

By default, the PDF source is the folder `c:\PDF2TXT\pdf`.  Any source may be chosen, however, and the program remembers the last one used.

Similarly, an edit box and associated button let you specify the target folder for converted files.  These will have the same base name, but an extension of .txt instead of .pdf.  The default target folder is `c:\PDF2TXT\txt`.  Note that the PDF source may be either a file or folder, but the TXT target is always a folder.

## Text Extraction Settings

Two settings fundamentally affect how text is extracted from a PDF.  If the PDF requires a password to unlock its content, type it in the edit box provided.  If the PDF is an image format without textual characters -- e.g., the result of a scan -- mark the checkbox so that optical character recognition (OCR) is performed instead of the usual techniques of extracting text.  This OCR technique is also separately available at <https://github.com/JamalMazrui/pdf2ocr>.

OCR is a much slower and more error-prone process, but it may be the best option when the usual methods do not work.  This technique uses Google Tesseract, the best open source OCR available, which is not as good as commercial OCR packages.  Due to technical issues, there is not a simple way of aborting an OCR process that has already started -- you have to close the PDF2TXT program.

Another checkbox lets you produce several more text files as output, corresponding to the following where text.pdf is the input:

* test_meta.txt = metadata about the PDF such as the authoring tool, page count, image-only status, and Tagged status for accessibility

* test_urls.txt = URLs extracted from the PDF, listed one per line

* test_gettext.txt = text version produced by the gettext.exe utility

* test_xpdf.txt = text version produced by the pdftotext.exe utility

text_miner.txt = text version produced by the PDFMinor library in the pdf2tag.exe utility

test_tag.txt = text version with markup of accessibility tags, produced by the pdf2tag.exe utility

test.htm = HTML version produced by the pdf2tag.exe utility

The Extra Outputs choice is primarily intended for diagnostic purposes, e.g., determining whether a PDF was produced with accessibility in mind or determining which text version is the most readable if the default test.txt result is unsatisfactory.  A webmaster could post an HTML alternative to a PDF.  The conversion translates visual aspects of the PDF such as fonts, but not structural elements such as headings, unfortunately.  

## Viewing Area

Within the main dialog, a read-only, multi-line edit control serves as a viewing area between the source and target controls just discussed.  This scrollable view can show one of three kinds of information:  (1) the text of a PDF, 2) a list of PDF files, or (3) the results of a batch conversion.  The label for the viewing area changes to indicate the kind of information being shown:  "View file," "View folder," or "View results."

You can navigate the viewing area with standard windows keystrokes, e.g., Control+Home or Control+End to go to the top or bottom of text.  Control+F lets you search forward for a string of characters, and Control+Shift+F lets you search backward.  F3 searches for the same string again in the forward direction, and Shift+F3 searches again backward.  Control+G lets you go to a percent completion point through the file being viewed.  Control+K sets a bookmark for the file, Control+Shift+K clears it, and Alt+K goes to it.

You can press Shift with arrow keys to select text or Control+A to select all.  Alternatively, you can press F8 to set the starting point of a selection, navigate to the ending point desired, and then press Shift+F8 to select the text between these points.  

Press Control+C to copy selected text to the clipboard.  Alternatively, press Control+Shift+C, or Alt+F8, to copy and append to the clipboard, adding to rather than replacing its existing text.  A form feed or page break character (ASCII code 12) will separate each clip copied there.  Control+F8 is a shortcut that copies all text in the viewing area without having to select it first, equivalent to Control+A followd by Control+C.

If you invoke the Open button and choose a PDF from its sub dialog, the text of the PDF will be placed in the viewing area, and keyboard focus will go there.  If you invoke the Select button to choose a PDF folder instead of a file, its list of PDFs will be shown.  A status bar at the bottom of the dialog indicates the current position in the viewing area.

## Toggling between a File and Folder List

The Look button behaves in a special way when the viewing area has focus.  If you press Alt+L when in the viewing area, PDF2TXT will toggle between a folder and file view.  If viewing a folder, PDF2TXT will switch to a view of the file that was on the line containing the caret.  If viewing a file, PDF2TXT will switch to a view of the folder that contained the file.  In addition, PDF2TXT will automatically search for the name of the file last viewed and place the caret just after it if found.

This feature lets you easily explore the PDFs in a folder, one after another.  Initially, You might display a list of files by pressing Alt+L when the PDF source is a folder.  You can then arrow down through the list until you find a PDF you want to view.  At that point, press Alt+L to view the file.  When you want to continue exploring the folder list again,  press Alt+L to return to it at the position of the file you last viewed.

## Configuration Check Boxes

Four check boxes let you configure PDF2TXT.  The one labeled "Include subfolders," will look for PDF files not only in the specified folder, but in subfolders under it.  For example, you could probably convert many PDF files on your computer by checking this setting and specifying the c:\ root folder as the PDF source!  This setting is unchecked by default.

The check box labeled "Move PDF when done" will transfer a PDF to a subfolder called "Done" after a successful conversion.  This is a subfolder of the PDF2TXT program folder, with a default location of `c:\PDF2TXT\done`.  The benefit of this check box is that PDF files are stored away for backup after they have been converted to text.  This setting is unchecked by default.

The checkbox labeled "Replace TXT if found" determines whether to skip a conversion if a corresponding target file already exists.  If you do not check the  setting to move source files when done, you may want to check this setting so that unnecessary time is not spent on repeatedly converting PDF files left in the source folder, since they then will be skipped if corresponding target files already exist.  This setting is checked by default.

The Append check box determines whether a detailed conversion log file is newly created each time a conversion is run.  This setting is checked by default so that previous information is not lost.  A section below further describes the log file.

## Action Buttons

The remaining controls of the main dialog are buttons that perform various actions.  The Convert button is the default:  the one that will be activated by pressing Enter on any control except another button.  The viewing area will show the results of a batch conversion.  This information includes the number of pages in each PDF converted.  It also indicates when a conversion was either not possible or was skipped because the target file already existed and you chose not to replace files.

Press Escape if you need to abort a batch conversion of many files that is taking too long!  Note that this program is relatively quick, however, compared to other available methods of converting PDF files to text.  Moreover, its batch mode feature lets you run conversions unattended.

The source for a conversion is treated differently if the viewing area has focus.  If viewing a list of PDFs in a folder or on a web page, then PDF2TXT regards the source as the file name on the current line (the one containing the caret).  Thus, you can cursor to a PDF of interest and press Enter to convert it to text.  If successfully converted, PDF2TXT assumes you may also want to examine its content in the viewing area, so a Look command is automatically performed as well (see below).  If there is a conversion error, however, PDF2TXT leaves the error message in the viewing area.  If you have been examining a list of PDFs and decide you want to convert them all rather than a single file, navigate to the top line of the viewing area that lists the number of PDFs in the list, and then press Enter.

If the source edit box already specifies what you want to view, or a path is easy to type into it, then the Look button is quicker to use than the Open or Select sub dialog.  Activating the Look button takes the current source specification and goes to a view of either the text of a source file or the list of a source folder, putting focus in the view area so you can read the information.  If viewing a PDF, its metadata is displayed before the body.

The Defaults button restores the default configuration settings of PDF2TXT.  You can use it to return to the initial folders and checkbox settings.  

The Explorer button lets you browse the source, target, or done folder with Windows Explorer.  It allows you to examine files that either have been converted or would not convert--thus needing other approaches to access their content.

The Quit button closes PDF2TXT.  Alt+F4 does the same thing.

The Help button displays this complete documentation in the default web browser.  For context-sensitive help on a particular control, press F1 when it has focus.  Hence, you can tab through the dialog and press F1 on each control to learn how to use it.

## URL Source,

If you are connected to the Internet, you can specify a URL as a PDF source instead of a file or folder on your local computer.  The URL can be the complete download path to a PDF on the Internet.  Alternatively, the URL can be the path to a web page containing one or more links to PDF files.  You can use Internet Explorer to navigate to such a web page and then invoke the "Grab URL" button to put its URL into the source edit box of PDF2TXT.

The Look button works with a URL source similarly to a local file or folder.  For example, you can press Alt+L to view a list of PDFs on a web page.  The toggling feature, described above, is also supported, allowing you to consecutively examine the PDFs linked to a web page.  If you view a PDF on the Internet, PDF2TXT  will automatically download a copy to the PDF subfolder of the program folder, e.g., to `c:\PDF2TXT\pdf`.

The Convert button also works with a URL source.  Thus, you can easily convert all PDFs on a web page with a single batch operation.

## Hot Keys

Almost all controls of PDF2TXT are directly usable with unique, mnemonic Alt key combinations based on the initial letter of the control's label.  Thus, as you become familiar with the controls, you can operate them more quickly with hot keys rather than navigating to them with the tab key or mouse.  For example, press Alt+P to go to the edit box for typing a PDF source, or Alt+S to select a source folder from a tree view of your computer.  Press Alt+L to look at a file or folder, or Alt+V to red what is already in the viewing area.  Press Alt+I to toggle the "Include subfolders" setting, or Alt+D to restore all defaults.  The text extraction settings in the second row of controls use a letter corresponding to the second syllable or word, i.e., Alt+W for the Password edit box and Alt+F for the Image Format checkbox.

## The Log File

The conversion log file is named log.txt and located in the Done subfolder of the PDF2TXT program folder.  It records information about each attempt to convert a PDF2TXT file.  It indicates whether the conversion succeeded (meaning any resulting text), and then lists metadata of the PDF, including security settings that could explain a failed conversion.  

There is a choice to view the log file in the PDF2TXT program group off the Start Menu.  You can also get to the file via the Explore button of the PDF2TXT program, choosing the Done folder to navigate with Windows Explorer.  Additionally, you can open the file in another application through its direct path (default settings):  
`c:\PDF2TXT\done\log.txt`

If the log file grows larger than you want, simply delete it or uncheck the setting that configures PDF2TXT to append to an existing log file.  Each use of the Convert button would then generate a new log file.  This information is more detailed than the results placed in the viewing area.

## Command Line Operation

The pdf2txt.exe executable may be run with various command line parameters.  The parameters can set values for controls in the main dialog.  Parameters can also cause PDF2TXT to run in an automatic, console mode--without a dialog box or further user intervention involved.  

When the .pdf extension is associated with the PDF2TXT program (explained in another section), Windows Explorer or Internet Explorer will open a PDF file by launching PDF2TXT with the name of the PDF passed as a parameter on the command line.  If PDF2TXT is launched with more than one command line parameter, however, the program will assume you want to run it in console rather than GUI mode.  The syntax for parameters is described as follows.  If a PDF source file, folder, or URL is specified, it must be the first parameter.  If a TXT target folder is specified, it must be the second parameter.  The source or target must be enclosed in quotes if its name contains spaces.  

All parameters besides source and target names begin with a space and forward slash (/), followed by the hot key letter in the dialog corresponding to the setting affected.  A trailing plus (+) sign in the parameter indicates a status of On, and a minus (-) sign indicates Off.  The plus sign can also be omitted to indicate On.  Capitalization does not matter.  Here is a list of parameters:

* a = Automatic, console mode (use /a- to force GUI mode with multiple parameters)
* i = Include subfolders
* m = Move PDF when done
* r = Replace TXT if found
* d = Default settings (no /d- is defined)
* g = Grab URL as source from Internet Explorer (no /g- is defined)

For example, to convert all files using default settings except for the Move setting, you could enter:  
`PDF2TXT /d /m`

To use current settings except grab a URL as source, enter:  
`PDF2TXT /a /g`

To convert files from a temporary folder to the current folder, enter:  
`PDF2TXT "c:\temp files" .`

To do the same, but in GUI rather than console mode, enter:  
`PDF2TXT "c:\temp files" . /a-`

For greater console mode convenience, another version of PDF2TXT, having the abbreviated name p2t.exe, is also available in the program folder.  This version only runs in console mode, whether zero, one, or more parameters are specified.  It uses "standard output" to display conversion results.  The shorter executable name means less characters to type on the command line.  For example, to run a batch conversion in console mode using the current settings of PDF2TXT, you could simply enter  
`p2t`

Like DOS commands generally, the above assumes that you have either made c:\PDF2TXT the current directory or included it in a PATH statement.

## File Association

The PDF2TXT group on the Start Menu contains shortcuts for changing what program automatically opens a file with a .pdf extension in Windows Explorer.  If you decide that you like the interface of PDF2TXT enough to make it the default program for PDF files, you can set the file association accordingly.  Later, if you decide you want to return to the conventional association, you can do that, too.  

When the .pdf extension is associated with PDF2TXT, an application such as Windows Explorer when opening a file, or Internet Explorer after downloading a file, will pass the name of the PDF as a command-line parameter to pdf2txt.exe.  When the program is launched in this way, it automatically invokes the Look button, placing text of the PDF in the viewing area and putting keyboard focus there.


## Change Log

Version 3.6 on November 15, 2015
Recompiled with later versions of PowerBASIC, QuickPDF, and Tesseract.  Changed source documentation to Markdown.

Version 3.5 on February 6, 2012
Updated Tesseract utility for OCR.  Updated QuickPDF library.  Used that library rather than GhostScript to convert from PDF to .tif files for Tesseract.  The result is considerably better OCR quality.
----------

Development Notes

I welcome comments and suggestions on PDF2TXT.  For the technically curious, I developed it with the PowerBASIC programming language from <http://PowerBASIC.com> and a couple of third party libraries:  EZGUI from <http://cwsof.com> and QuickPDF from <http://QuickPDF.com>.

Some free, third-party utilities are included in the PDF2TXT program folder:

* pdftotext.exe in the [xpdf package](http://www.foolabs.com/xpdf/home.html)

* gettext.exe from [kryltech.com](http://www.kryltech.com).  Since that website may be down, the license for the program is included in the docs subfolder of the PDF2TXT program folder.

* pdf2tag.exe, an adaptation of the pdf2txt.py script included with the [PDFMiner library](https://github.com/euske/pdfminer)

Some status messages are spoken with the Windows (SAPI) speech engine or with the JAWS, System Access, or Window-Eyes screen reader if active.  These direct speech messages are produced with APIs via a component of the SayIt distribution, which is also available seperately at <https://github.com/JamalMazrui/SayIt>.

The PowerBASIC code to PDF2TXT, itself (but not commercial libraries used), is open source under the GNU Lesser General Public License (LGPL), documented at <http://gnu.org>.  Source code files are located in the source subfolder of the PDF2TXT program folder.

Ideas and feedbak from the discussion list <program-l@FreeLists.org> aided the original design and testing of PDF2TXT.  The latest installer is available at <http://EmpowermentZone.com/PDF2TXT_setup.exe>.

You can download it with the Elevate Version hotkey, F11.  This checks whether a newer version is available, and offers to install it.

