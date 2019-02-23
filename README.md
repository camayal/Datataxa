# Datataxa
This script allow extract information different than sequences from genbank for a list of species and classify the information based on the metadata found in each accession. In this version is preconfigured to extract titles of papers where the sequences were used.

## Requirements
To run the script a copy of AutoIt 3 need to be installed in the computer, please check the link to [download](https://www.autoitscript.com/site/autoit/downloads/) and install the software needed (AutoIt Full Installation is recommended).
https://www.autoitscript.com/site/autoit/downloads/

**Note**: Currently this script only works in Windows operative system, probably (if required) in future developments the script will be translate to a crossplatform language to run it in other operative systems.

## Usage
### Prepare data file
You need a list of species. The file is a simple text file and must be located in the same folder with the script.
The content of the file looks like:
```
Anisacanthus+pumilus
Anisacanthus+quadrifidus
Barleria+micans
Ruellia+blechum
Carlowrightia+arizonica
Carlowrightia+glandulosa
Carlowrightia+neesiana
Carlowrightia+parviflora
Carlowrightia+venturae
```
No heading, one species per line and genus and epithet separated by a `+`.


### Configure the script (to perform a search in the paper titles only)
1. Open the script with SciTE script editor (provided by AutoIt software).
2. Modify the following lines to be sure that the name of your file (with the list of species) are correct.
```Autoit
;Input and output files
$oFileSp = "NAMEOFYOURFILEHERE.txt" ;<== File name (file formated Genus+species one species per line)
$fResultFile = "RESULTFILE.csv" ;<== Define output file name
```
3. Configure the keywords
3.a. Define the titles for your columns (in the result file), modifying each name based on your interests:
```Autoit
;Create punctual.searches
Local $aS[6] ; <== Define number searches, this number is independent to the $aE[Number]
$aS[0] = "Phylogenetic studies"
$aS[1] = "Phylogeographic studies"
$aS[2] = "Phylogenomics studies"
$aS[3] = "Barcoding studies"
$aS[4] = "Diversity studies"
$aS[5] = "Biogeography studies"
```
For example in `$aS[0] = "Phylogenetic studies"` you can modify to Conservation studies resulting in a line like this: `$aS[0] = "Conservation studies"`

You can put the number of categories that you want, in this example there are 6 different searches (note that the counter start in 0). If you want add or delete some searches, you need to modify the first line from: `Local $aS[6] ; ` to `Local $aS[3] ; `. This parameter inform to the script that you have three searches. 

For example:
```Autoit
;Create punctual.searches
Local $aS[2] ; <== Define number searches, this number is independent to the $aE[Number]
$aS[0] = "Conservation studies"
$aS[1] = "Etnobotany studies"
```

3.b. Configure the patterns of your searches.
```Autoit
;Create Regex patterns to search for each punctual.searches, please see regex documentation in: https://www.autoitscript.com/autoit3/docs/functions/StringRegExp.htm
Local $aRegex[6] ; <== Same as punctual.searches AND IN THE SAME ORDER!
$aRegex[0] = "(?i)phylogen|filogen|monop|monof|systemat|relationsh|sistemat|relacio"
$aRegex[1] = "(?i)filogeog|phylogeog"
$aRegex[2] = "(?i)phylogenom|genome-scale|plastid genome|filogenóm"
$aRegex[3] = "(?i)barcod|barra"
$aRegex[4] = "(?i)genetic diversity|diversidad genética|population genetic|genética pobla|genética de pobla"
$aRegex[5] = "(?i)biogeog"
```
This can be a tricky part, you need to think in some keywords or fragments of keywords that match with your search. For th example the line: `$aRegex[0] = "(?i)phylogen|filogen|monop|monof|systemat|relationsh|sistemat|relacio"` will search a title like: 
Molecular **phylogen**etic analysis of uniovulate Euphorbiaceae (Euphorbiaceae sensu stricto) using plastid rbcL and trnL‐F DNA sequences. 
But will ignore titles like: 
Synopsis of the genera and suprageneric taxa of Euphorbiaceae.

*Do not modify the first part of the text* `(?i)` unless you know what are you doing.

You can include multiple keywords in your search using `|` like separator, as shown in the example. Also you can only leave one keyword.

**Note**: Be sure that the number after `$aRegex[` is the same that the number of your keyword title (configure in the step 3.a).

For example:
```Autoit
;Create Regex patterns to search for each punctual.searches, please see regex documentation in: https://www.autoitscript.com/autoit3/docs/functions/StringRegExp.htm
Local $aRegex[6] ; <== Same as punctual.searches AND IN THE SAME ORDER!
$aRegex[0] = "(?i)conserv"
$aRegex[1] = "(?i)etnobot|ethnobot"
``` 

With this the script will search any title with the words **Etnobot**ánica (in Spanish) and **Ethnobot**any (in English), also any titles that include **conserv**ation or **conserv**ación. Be sure that you select your keywords properly to avoid false positives. If you search only "Etno" you can get titles like etnozoología.

#### Run script in extraction mode


#### Run script in metasearch mode


### Configure the script in advance mode
You can extract the metadata that you want with the script, for example, adscription institution, authors, journal, depends of your interests, for that some changes need to be added in the script.  For that follow the commentaries in the script to modify the type of information that you want to extract.


