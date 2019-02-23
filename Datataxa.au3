; #Info# ======================================================================================================================
; Title .........: Datataxa
; Version .......: U
; AutoIt Version : 3.3.14.2
; Language ......: English
; Description ...: Extract information and classify it from GenBank for a list of species, using Entrez API
; Author ........: Carlos Alonso Maya-Lastra
; Date ..........: March 2016 - Feb 2019
; =============================================================================================================================


;USER AREA
; =============================================================================================================================

; Switches
$doExtraction = True;<== Switch to True to do the extraction of genbank. False when extraction is finished.
$doMetasearch = False ;<== Switch to True to do the meta search, only when the entire extraction is completed. False when extraction is in progress.

;Input and output files
$oFileSp = "NAMEOFYOURFILEHERE.txt" ;<== File name (file formated Genus+species one species per line)
$fResultFile = "RESULTFILE.csv" ;<== Define output file name

;Create punctual.searches
Local $aS[6] ; <== Define number searches, this number is independent to the $aE[Number]
$aS[0] = "Phylogenetic studies"
$aS[1] = "Phylogeographic studies"
$aS[2] = "Phylogenomics studies"
$aS[3] = "Barcoding studies"
$aS[4] = "Diversity studies"
$aS[5] = "Biogeography studies"

;Create Regex patterns to search for each punctual.searches, please see regex documentation in: https://www.autoitscript.com/autoit3/docs/functions/StringRegExp.htm
Local $aRegex[6] ; <== Same as punctual.searches AND IN THE SAME ORDER!
$aRegex[0] = "(?i)phylogen|filogen|monop|monof|systemat|relationsh|sistemat|relacio"
$aRegex[1] = "(?i)filogeog|phylogeog"
$aRegex[2] = "(?i)phylogenom|genome-scale|plastid genome|filogenóm"
$aRegex[3] = "(?i)barcod|barra"
$aRegex[4] = "(?i)genetic diversity|diversidad genética|population genetic|genética pobla|genética de pobla"
$aRegex[5] = "(?i)biogeog"


;ADVANCE USER AREA
; =============================================================================================================================


;XML nodes from Genbank results
Local $aE[6] ;<== Define number of element to obtain from the FlatFile and below define which element ("//parentnode/childnode/childnode/...")
$aE[0] = "//GBSet/GBSeq/GBSeq_organism"
$aE[1] = "//GBSet/GBSeq/GBSeq_locus"
$aE[2] = "//GBSet/GBSeq/GBSeq_length"
$aE[3] = "//GBSet/GBSeq/GBSeq_references/GBReference/GBReference_title"
$aE[4] = "//GBSet/GBSeq/GBSeq_references/GBReference/GBReference_journal"
$aE[5] = "//GBSet/GBSeq/GBSeq_create-date"

;Create file and define headings
Local $aT[7] ; <== Define number of titles for each column (Final must be extras)
$aT[0] = "Species after GB analysis"
$aT[1] = "GB Number"
$aT[2] = "Length"
$aT[3] = "Paper titles" ; <== This number is important in the next definition $arrayofPaperTitles
$aT[4] = "Paper Journals"
$aT[5] = "Create date"
$aT[6] = "Searched name"

;Define the array element when the paper titles is saved $aT[__This Number__]
$arrayofPaperTitles = 3


;DO NOT MODIFY BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING
; =============================================================================================================================

#include <MsgBoxConstants.au3>
#include <Array.au3>
#include <File.au3>

;EXTRACTION PART

;Define variables and objects
$oXML = ObjCreate("Microsoft.XMLDOM")
$oHTTP = ObjCreate("Msxml2.XMLHTTP.6.0")

if $doExtraction = True then

;Count species in file
$nFileSpLines = _FileCountLines($oFileSp)

;Resume function
if FileExists("continue.txt") then
   $cont = FileRead("continue.txt")
Else
   $cont = 1 ;put 1 to start from first line
   ;Create headers
   For $T in $aT
	  FileWrite($fResultFile, Chr(34) & $T & Chr(34) & ",")
   Next
   FileWrite($fResultFile, @CRLF)
EndIf

;Line by line in the file
For $i = $cont To $nFileSpLines
   ;Show progress
   ;ToolTip($i &" of "& $nFileSpLines, 0,0)
   TraySetToolTip($i &" of "& $nFileSpLines)
   ;ControlSetText('', '', 'Scintilla2', '')
   ;ControlSend("[CLASS:SciTEWindow]", "", "Scintilla2", "+{F5}")
   ConsoleWrite($i &" of "& $nFileSpLines & @CRLF)

   ;Mark line in progress for restart process (script start from this point if stop exe happens)
   FileDelete("continue.txt")
   FileWrite("continue.txt", $i)

   ;Clear main variable for final step array to file
   Local $finalRow = ""

   ;Get species from file
   $sSp = FileReadLine($oFileSp,$i)

   ;Verify is sp is not empty
   if $sSp <> "" Then

	  ;Search for the name of species in the GB database and correct it if necesary
	  Local $sSpSpace = StringReplace($sSp, "+", " ") ;Replace + by space in the name of sp
	  Local $sErroneousSp = ""
	  ;Local $sXML = HttpPost("http://eutils.ncbi.nlm.nih.gov/entrez/eutils/espell.fcgi?db=taxonomy&term=%22" & $sSp & "%22") ;Access to Espell database to correct

	  $oHTTP.Open("GET", "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/espell.fcgi?db=taxonomy&term=%22" & $sSp & "%22", False)
	  $oHTTP.Send()




	  $oXML.loadXML($oHTTP.ResponseText)
	  Local $correctedSp = $oXML.SelectSingleNode("//eSpellResult/CorrectedQuery")
	  if $sSpSpace <> $correctedSp.text Then
		 $sErroneousSp = $sSpSpace
		 $sSp = $correctedSp.text
	  EndIf

	  ;sleep(400) ;Insert delay to respect GenBank Entrez limitation

	  ;Get XML from Eserch utility of Entrez API
	  ;Local $sXML = HttpPost("http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=nucleotide&term=%22" & $sSp & "%22[Organism]&retmax=1000") ;Remember this search can look syns.

	  $oHTTP.Open("POST", "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=nucleotide&term=%22" & $sSp & "%22[Organism]&retmax=1000", False)
	  $oHTTP.Send()


	  ;Get IdList elements (aka GI number)
	  $oXML.loadXML($oHTTP.ResponseText)

	  ; Verify if the species has some nucleotide registry in GB, else go to the next species
	  If $oXML.SelectSingleNode("//eSearchResult/Count").text > 0 Then

		 ;Get ID numbers for the species
		 $oIDList = $oXML.SelectSingleNode("//eSearchResult/IdList")
		 $aIds = StringReplace($oIDList.text, " ", ",") ;formating changing spaces by commas to put in URL of API

		 ;Start searching in GenBank for  ID numbers in batch

			;Get detailed flatfile from GenBank in XML format for multiple accessions
			;Local  $sXML = HttpPost("http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=" & $aIds & "&retmode=xml")


			$oHTTP.Open("POST", "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=" & $aIds & "&retmode=xml", False)
			$oHTTP.Send()


			$oXML.loadXML($oHTTP.ResponseText) ;load xml in the object
			$GBSeq = $oXML.SelectNodes("//GBSet/GBSeq") ; select each node (correspond to each accs. number)

			;Make a loop exploring all elements in the array E
			For $nE In $aE
			   Local $UnificationNode = "" ;clean variable where is written each node from each accs.
			   ;Check each element looking for multiples nodes
			   $x = $oXML.SelectNodes($nE)
			   For $node In $x
				  $UnificationNode &= $node.text & "|" ;add each node info separated by | for each node
			   Next
			   Local $aUniNode = StringSplit($UnificationNode, "|") ;Convert the object into an array splitting the string
			   Local $UnificationNodeUnique = _ArrayUnique($aUniNode) ;Due multiple repetitive data into diferente accs. I filter each node-group (only uniques)
			   $UnificationNodeReport = StringTrimRight(_ArrayToString($UnificationNodeUnique, "|", 2),1) ;Delete the extra_separator at the end
			   $finalRow &= Chr(34) & $UnificationNodeReport & Chr(34) & "," ;add to $finalRow the info

			Next

			;Add XML extracted information to each row
			FileWrite($fResultFile, $finalRow)

			;Add extras to each row (finals columns)
			FileWrite($fResultFile, Chr(34) & $sSpSpace& Chr(34) & @CRLF)

			;sleep(400) ;Insert delay to respect GenBank Entrez limitation


	  EndIf
   EndIf


next

For $beep = 1 To 7
Beep(Random(350, 1000, 1), 200)
next

   ConsoleWrite("Extraction finished" & @CRLF)


Else
   ConsoleWrite("Extraction skipped" & @CRLF)
Endif

;METASEARCH PART

;Avoid overwrite the metasearch results
if FileExists("Metasearch_in_" & $fResultFile ) And $doMetasearch = True then
$doMetasearch = False
ConsoleWrite("The file " & "Metasearch_in_" & $fResultFile & " already exists, to perform a new metasearch delete or move the file" & @CRLF)
EndIf


If $doMetasearch = True Then

;Count species in file
$nFileResultLines = _FileCountLines($fResultFile)

;Indicates the Metasearch file result
Local $fMetaResult = "Metasearch_in_" & $fResultFile

;Create headers of the Metasearch file result
For $T in $aT
	  FileWrite($fMetaResult, Chr(34) & $T & Chr(34) & ",")
Next
For $S in $aS
	  FileWrite($fMetaResult, Chr(34) & $S & Chr(34) & ",")
Next
FileWrite($fMetaResult, @CRLF)


;Extract line by line from the 2nd row (excluding headers)
   For $i = 2 To $nFileResultLines
	  ;clean previous result or declare variable
	  Local $metaseachResultPerLine = ""


   ;Get the line from file
   $sLine = FileReadLine($fResultFile,$i)
   ;Return the field where is located the paper titles
   Local $aField = StringSplit($sLine,Chr(34) & "," & Chr(34), 1)

   ;Perform the metasearch
   For $R in $aRegex
	  $search = StringRegExp($aField[$arrayofPaperTitles+1], $R)
	  If $search = 1 Then
	  $metaseachResultPerLine = $metaseachResultPerLine & Chr(34) & "TRUE" & Chr(34) & ","
	  Else
	  $metaseachResultPerLine = $metaseachResultPerLine & Chr(34) & "FALSE" & Chr(34) & ","
	  Endif

   Next

;Add results to result file (delete the las ,)
FileWrite($fMetaResult, $sLine & "," & StringTrimRight($metaseachResultPerLine,1) & @CRLF)



ConsoleWrite($i-1 & " of " & $nFileResultLines-1 & @CRLF)



   Next


For $beep = 1 To 7
Beep(Random(350, 1000, 1), 200)
next

   ConsoleWrite("Metasearch finished" & @CRLF)


Else
   ConsoleWrite("Metasearch skipped" & @CRLF)
EndIf

if $doExtraction = False And $doMetasearch = False then
      ConsoleWrite("Turn on the desired function using the switches in the script code to run the proper function" & @CRLF)
   EndIf