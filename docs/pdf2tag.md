# pdf2tag
Version 1.0
November 10, 2015
By Jamal Mazrui
Adapted from the py2txt.py utility that is included with the Python module called PDFMiner

## Description

pdf2tag is a command-line utility that converts one or more files from PDF to a choice of four formats: tag, text, HTML, or XML.  The tag format distinguishes this tool from others.  It is a text version of the PDF that includes markup indicating the structure or "tag tree" of the PDF.  A PDF is made accessible to users of assistive technology (e.g., a blind person using a screen reader program) by adding tags that denote structural elements of the document, e.g., a heading or a footnote.  The official definition of Tagged PDF is part of the PDF 1.7 Specification on the [Adobe website](http://www.adobe.com/content/dam/Adobe/en/devnet/acrobat/pdfs/pdf_reference_1-7.pdf).  The pdf2tag utility may be useful in analyzing whether PDFs are being properly tagged for accessibility.

## Operation

The syntax of pdf2tag is `pdf2tag.exe FileSpec`.

The File Spec parameter may be either a single file path or a wildcard pattern like `*.pdf`.  Surround it with quotes if it contains a space character.  Each target file has the same path and name, differing only in the extension.

pdf2tag will produce output on the console indicating how many files are to be converted to what format, followed by the name of each target file as it is created.

pdf2tag generally retains the capability of the Python script file from which it adapted:  pdf2txt.py distributed with the PDFMiner package.  The complete list of parameters may be shown by executing pdf2tag with no parameters.  The included file, pdf2txt_help.txt` is a capture of that help text.

Using the same command-line syntax, three batch files facilitate conversions to the other formats besides tag:  pdf2txt.bat, pdf2htm.bat, and pdf2xml.bat.  Thus, for example, all PDFS in a directory could be converted to HTML with the command `pdf2htm *.pdf`.

## Development Notes

I developed pdf2tag with Python 2.7 and the packages PDFMiner and py2exe.  The top-level script, pdf2tag.py, is an adaptation of the PDFMiner tool called pdf2txt.py.  The batch file, RunSetup.bat, runs the py2exe script, setup.py, to create the stand-alone executable, pdf2tag.exe.

Note that the results of pdf2htm do not meet accessibility guidelines.  All aspects of the HTML format are determined by underlying PDFMinor routines, not within the control of the pdf2tag code.  Visual aspects such as fonts are present in the resulting files, but structural aspects such as headings do not seem to be converted, unfortunately.  Other programmers interested in this project may wish to work on improving the HTML structure of target files.
