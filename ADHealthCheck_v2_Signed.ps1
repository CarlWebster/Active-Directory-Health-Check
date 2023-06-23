﻿#Requires -Version 3.0
#This File is in Unicode format.  Do not edit in an ASCII editor.

<#
.SYNOPSIS
	Perform an Active Directory Health Check.
.DESCRIPTION
	Perform an Active Directory Health Check based on LDAP queries.
	These are originally based on Jeff Wouters personal best practices.
	No rights can be claimed by this report!

	Founding guidelines for all checks in this script:
	*) Must work for all domains in a forest tree.
	*) Must work without module dependencies, except for the PowerShell core modules.
	*) Must work without Administrator privileges.
	
	You will see a lot of redirection to streams in this script. i.e. 3>$Null, 4>$Null and 
	possibly *>$Null
	This is explained here: 
	https://blogs.technet.microsoft.com/heyscriptingguy/2014/03/30/understanding-streams-redirection-and-write-host-in-powershell/
	
	Includes support for the following language versions of Microsoft Word:
		Catalan
		Chinese
		Danish
		Dutch
		English
		Finnish
		French
		German
		Norwegian
		Portuguese
		Spanish
		Swedish
	
.PARAMETER CompanyAddress
	Company Address to use for the Cover page if the Cover Page has the Address field.
	
	The following Cover Pages have an Address field:
		Banded (Word 2013/2016)
		Contrast (Word 2010)
		Exposure (Word 2010)
		Filigree (Word 2013/2016)
		Ion (Dark) (Word 2013/2016)
		Retrospect (Word 2013/2016)
		Semaphore (Word 2013/2016)
		Tiles (Word 2010)
		ViewMaster (Word 2013/2016)
		
	This parameter is only valid with the MSWORD and PDF output parameters.
	This parameter has an alias of CA.
.PARAMETER CompanyEmail
	Company Email to use for the Cover page if the Cover Page has the Email field.  
	
	The following Cover Pages have an Email field:
		Facet (Word 2013/2016)
	
	This parameter is only valid with the MSWORD and PDF output parameters.
	This parameter has an alias of CE.
.PARAMETER CompanyFax
	Company Fax to use for the Cover page if the Cover Page has the Fax field.  
	
	The following Cover Pages have a Fax field:
		Contrast (Word 2010)
		Exposure (Word 2010)
	
	This parameter is only valid with the MSWORD and PDF output parameters.
	This parameter has an alias of CF.
.PARAMETER CompanyName
	Company Name to use for the Cover Page.  
	Default value is contained in 
	HKCU:\Software\Microsoft\Office\Common\UserInfo\CompanyName or
	HKCU:\Software\Microsoft\Office\Common\UserInfo\Company, whichever is populated 
	on the computer running the script.
	This parameter has an alias of CN.
	If either registry key does not exist and this parameter is not specified, the report 
	will not contain a Company Name on the cover page.
	This parameter is only valid with the MSWORD and PDF output parameters.
.PARAMETER CompanyPhone
	Company Phone to use for the Cover Page if the Cover Page has the Phone field.  
	
	The following Cover Pages have a Phone field:
		Contrast (Word 2010)
		Exposure (Word 2010)
	
	This parameter is only valid with the MSWORD and PDF output parameters.
	This parameter has an alias of CPh.
.PARAMETER CoverPage
	What Microsoft Word Cover Page to use.
	Only Word 2010, 2013 and 2016 are supported.
	(default cover pages in Word en-US)
	
	Valid input is:
		Alphabet (Word 2010. Works)
		Annual (Word 2010. Doesn't work well for this report)
		Austere (Word 2010. Works)
		Austin (Word 2010/2013/2016. Doesn't work in 2013 or 2016, mostly 
		works in 2010 but Subtitle/Subject & Author fields need to be moved 
		after title box is moved up)
		Banded (Word 2013/2016. Works)
		Conservative (Word 2010. Works)
		Contrast (Word 2010. Works)
		Cubicles (Word 2010. Works)
		Exposure (Word 2010. Works if you like looking sideways)
		Facet (Word 2013/2016. Works)
		Filigree (Word 2013/2016. Works)
		Grid (Word 2010/2013/2016. Works in 2010)
		Integral (Word 2013/2016. Works)
		Ion (Dark) (Word 2013/2016. Top date doesn't fit; box needs to be 
		manually resized or font changed to 8 point)
		Ion (Light) (Word 2013/2016. Top date doesn't fit; box needs to be 
		manually resized or font changed to 8 point)
		Mod (Word 2010. Works)
		Motion (Word 2010/2013/2016. Works if top date is manually changed to 
		36 point)
		Newsprint (Word 2010. Works but date is not populated)
		Perspective (Word 2010. Works)
		Pinstripes (Word 2010. Works)
		Puzzle (Word 2010. Top date doesn't fit; box needs to be manually 
		resized or font changed to 14 point)
		Retrospect (Word 2013/2016. Works)
		Semaphore (Word 2013/2016. Works)
		Sideline (Word 2010/2013/2016. Doesn't work in 2013 or 2016, works in 
		2010)
		Slice (Dark) (Word 2013/2016. Doesn't work)
		Slice (Light) (Word 2013/2016. Doesn't work)
		Stacks (Word 2010. Works)
		Tiles (Word 2010. Date doesn't fit unless changed to 26 point)
		Transcend (Word 2010. Works)
		ViewMaster (Word 2013/2016. Works)
		Whisp (Word 2013/2016. Works)
		
	The default value is Sideline.
	This parameter has an alias of CP.
	This parameter is only valid with the MSWORD and PDF output parameters.
.PARAMETER UserName
	Username to use for the Cover Page and Footer.
	Default value is contained in $env:username
	This parameter has an alias of UN.
	This parameter is only valid with the MSWORD and PDF output parameters.
.PARAMETER PDF
	SaveAs PDF file instead of DOCX file.
	This parameter is disabled by default.
	The PDF file is roughly 5X to 10X larger than the DOCX file.
.PARAMETER MSWord
	SaveAs DOCX file
	This parameter is set True if no other output format is selected.
.PARAMETER AddDateTime
	Adds a date timestamp to the end of the file name.
	The timestamp is in the format of yyyy-MM-dd_HHmm.
	June 1, 2020 at 6PM is 2020-06-01_1800.
	Output filename will be ReportName_2020-06-01_1800.docx (or .pdf).
	This parameter is disabled by default.
.PARAMETER Sites
	Only perform the checks related to Sites.
.PARAMETER OrganisationalUnit
	Only perform the checks related to OrganisationalUnits.
	This parameter has an alias of OU.
.PARAMETER Users
	Only perform the checks related to Users.
.PARAMETER Computers
	Only perform the checks related to Computers.
.PARAMETER Groups
	Only perform the checks related to Groups.
.PARAMETER All
	Perform all checks.
	This parameter is the default if no other selection parameters are used.
.PARAMETER Log
	Generates a log file for the purpose of troubleshooting.
.PARAMETER Mgmt
	Provides a page at the end of the PDF or DOCX file with information for your manager.
	Listed is the name of the check performed and the number of results found by the 
	check.
.PARAMETER CSV
	For each check, a separate CSV file will be created with the results.
.PARAMETER Folder
	Specifies the optional output folder to save the output report. 
.PARAMETER SmtpServer
	Specifies the optional email server to send the output report. 
.PARAMETER SmtpPort
	Specifies the SMTP port. 
	Default is 25.
.PARAMETER UseSSL
	Specifies whether to use SSL for the SmtpServer.
	Default is False.
.PARAMETER From
	Specifies the username for the From email address.
	If SmtpServer is used, this is a required parameter.
.PARAMETER To
	Specifies the username for the To email address.
	If SmtpServer is used, this is a required parameter.
.PARAMETER Dev
	Clears errors at the beginning of the script.
	Outputs all errors to a text file at the end of the script.
	
	This is used when the script developer requests more troubleshooting data.
	Text file is placed in the same folder from where the script is run.
	
	This parameter is disabled by default.
.PARAMETER ScriptInfo
	Outputs information about the script to a text file.
	Text file is placed in the same folder from where the script is run.
	
	This parameter is disabled by default.
	This parameter has an alias of SI.
.EXAMPLE
	PS C:\PSScript > .\ADHealthCheck_V2.ps1 -MSWord -Log -CSV

	This will generate a DOCX document with all the checks included.
	For each check, a separate CSV file will be created with the results.
	A log file is created for the purpose of troubleshooting.
	All files are created at the location of the script that is executed.
.EXAMPLE
	PS C:\PSScript > .\ADHealthCheck_V2.ps1 -MSWord -Sites -Users -Groups

	This will generate a DOCX document with the checks for Sites, Users, and Groups.
.EXAMPLE
	PS C:\PSScript > .\ADHealthCheck_V2.ps1 -Folder \\FileServer\ShareName

	This will generate a DOCX document with all the checks included.
	Output file will be saved in the path \\FileServer\ShareName
.EXAMPLE
	PS C:\PSScript >.\ADHealthCheck_V2.ps1 -Dev -ScriptInfo -Log
	
	Creates the default report.
	
	Creates a text file named ADHealthCheckScriptErrors_yyyyMMddTHHmmssffff.txt that 
	contains up to the last 250 errors reported by the script.
	
	Creates a text file named ADHealthCheckScriptInfo_yyyy-MM-dd_HHmm.txt that 
	contains all the script parameters and other basic information.
	
	Creates a text file for transcript logging named 
	ADHealthCheckTranscript_yyyyMMddTHHmmssffff.txt.
.EXAMPLE
	PS C:\PSScript > .\ADHealthCheck_V2.ps1 
	-SmtpServer mail.domain.tld
	-From XDAdmin@domain.tld 
	-To ITGroup@domain.tld	

	The script will use the email server mail.domain.tld, sending from XDAdmin@domain.tld, 
	sending to ITGroup@domain.tld.

	The script will use the default SMTP port 25 and will not use SSL.

	If the current user's credentials are not valid to send an email, 
	the user will be prompted to enter valid credentials.
.EXAMPLE
	PS C:\PSScript > .\ADHealthCheck_V2.ps1 
	-SmtpServer mailrelay.domain.tld
	-From Anonymous@domain.tld 
	-To ITGroup@domain.tld	

	***SENDING UNAUTHENTICATED EMAIL***

	The script will use the email server mailrelay.domain.tld, sending from 
	anonymous@domain.tld, sending to ITGroup@domain.tld.

	To send unauthenticated email using an email relay server requires the From email account 
	to use the name Anonymous.

	The script will use the default SMTP port 25 and will not use SSL.
	
	***GMAIL/G SUITE SMTP RELAY***
	https://support.google.com/a/answer/2956491?hl=en
	https://support.google.com/a/answer/176600?hl=en

	To send an email using a Gmail or g-suite account, you may have to turn ON
	the "Less secure app access" option on your account.
	***GMAIL/G SUITE SMTP RELAY***

	The script will generate an anonymous secure password for the anonymous@domain.tld 
	account.
.EXAMPLE
	PS C:\PSScript > .\ADHealthCheck_V2.ps1 
	-SmtpServer labaddomain-com.mail.protection.outlook.com
	-UseSSL
	-From SomeEmailAddress@labaddomain.com 
	-To ITGroupDL@labaddomain.com	

	***OFFICE 365 Example***

	https://docs.microsoft.com/en-us/exchange/mail-flow-best-practices/how-to-set-up-a-multifunction-device-or-application-to-send-email-using-office-3
	
	This uses Option 2 from the above link.
	
	***OFFICE 365 Example***

	The script will use the email server labaddomain-com.mail.protection.outlook.com, 
	sending from SomeEmailAddress@labaddomain.com, sending to ITGroupDL@labaddomain.com.

	The script will use the default SMTP port 25 and will use SSL.
.EXAMPLE
	PS C:\PSScript > .\ADHealthCheck_V2.ps1 
	-SmtpServer smtp.office365.com 
	-SmtpPort 587
	-UseSSL 
	-From Webster@CarlWebster.com 
	-To ITGroup@CarlWebster.com	

	The script will use the email server smtp.office365.com on port 587 using SSL, 
	sending from webster@carlwebster.com, sending to ITGroup@carlwebster.com.

	If the current user's credentials are not valid to send an email, 
	the user will be prompted to enter valid credentials.
.EXAMPLE
	PS C:\PSScript > .\ADHealthCheck_V2.ps1 
	-SmtpServer smtp.gmail.com 
	-SmtpPort 587
	-UseSSL 
	-From Webster@CarlWebster.com 
	-To ITGroup@CarlWebster.com	

	*** NOTE ***
	To send an email using a Gmail or g-suite account, you may have to turn ON
	the "Less secure app access" option on your account.
	*** NOTE ***
	
	The script will use the email server smtp.gmail.com on port 587 using SSL, 
	sending from webster@gmail.com, sending to ITGroup@carlwebster.com.

	If the current user's credentials are not valid to send an email, 
	the user will be prompted to enter valid credentials.
.INPUTS
	None.  You cannot pipe objects to this script.
.OUTPUTS
	No objects are output from this script.  This script creates a Word or PDF document.
.NOTES
	NAME        :   AD Health Check.ps1
	AUTHOR      :   Jeff Wouters [MVP Windows PowerShell], Carl Webster and Michael B. Smith
	VERSION     :   2.09
	LAST EDIT   :   7-Feb-2022

	The Word file generation part of the script is based upon the work done by:

	Carl Webster  | http://www.carlwebster.com | @CarlWebster
	Iain Brighton | http://virtualengine.co.uk | @IainBrighton
	Jeff Wouters  | http://www.jeffwouters.nl  | @JeffWouters

	The Active Directory checks were originally written by:

	Jeff Wouters  | http://www.jeffwouters.nl  | @JeffWouters
	
	Significant Active Directory changes have been implemented by:
	
	Michael B. Smith | http://TheEssentialExchange.com/ | @EssentialExchange
#>

[CmdletBinding( DefaultParameterSetName = 'All', SupportsShouldProcess = $false, ConfirmImpact = 'None' )]
Param(
    [Parameter( Mandatory = $false, ParameterSetName = 'Specific' )]
    [Parameter( Mandatory = $false, ParameterSetName = 'All' )]
	[Alias( 'CA' )]
	[ValidateNotNullOrEmpty()]
    [string]$CompanyAddress = '',

    [Parameter( Mandatory = $false, ParameterSetName = 'Specific' )]
    [Parameter( Mandatory = $false, ParameterSetName = 'All' )]
	[Alias( 'CE' )]
	[ValidateNotNullOrEmpty()]
    [string]$CompanyEmail = '',

    [Parameter( Mandatory = $false, ParameterSetName = 'Specific' )]
    [Parameter( Mandatory = $false, ParameterSetName = 'All' )]
	[Alias( 'CF' )]
	[ValidateNotNullOrEmpty()]
    [string]$CompanyFax = '',

    [Parameter( Mandatory = $false, ParameterSetName = 'Specific' )]
    [Parameter( Mandatory = $false, ParameterSetName = 'All' )]
	[Alias( 'CN' )]
	[ValidateNotNullOrEmpty()]
    [string]$CompanyName = '',

    [Parameter( Mandatory = $false, ParameterSetName = 'Specific' )]
    [Parameter( Mandatory = $false, ParameterSetName = 'All' )]
	[Alias( 'CPh' )]
	[ValidateNotNullOrEmpty()]
    [string]$CompanyPhone = '',

    [Parameter( Mandatory = $false, ParameterSetName = 'Specific' )]
    [Parameter( Mandatory = $false, ParameterSetName = 'All' )]
    [Alias( 'CP' )]
	[ValidateNotNullOrEmpty()]
    [string] $CoverPage = 'Sideline', 

    [Parameter( Mandatory = $false, ParameterSetName = 'Specific' )]
    [Parameter( Mandatory = $false, ParameterSetName = 'All' )]
    [Alias( 'UN' )]
	[ValidateNotNullOrEmpty()]
    [string] $UserName = $env:username,

    [Parameter( Mandatory = $false, ParameterSetName = 'Specific' )]
    [Parameter( Mandatory = $false, ParameterSetName = 'All' )]
    [Switch] $MSWord = $false,

    [Parameter( Mandatory = $false, ParameterSetName = 'Specific' )]
    [Parameter( Mandatory = $false, ParameterSetName = 'All' )]
    [Switch] $PDF = $false,

    [Parameter( Mandatory = $false, ParameterSetName = 'Specific' )]
    [Parameter( Mandatory = $false, ParameterSetName = 'All' )]
	[Alias( 'ADT' )]
    [Switch] $AddDateTime = $false,
	
    [Parameter( Mandatory = $false, ParameterSetName = 'Specific' )]
    [Switch] $Sites,

    [Parameter( Mandatory = $false, ParameterSetName = 'Specific' )]
	[Alias( 'OU' )]
	[Alias( 'OrganizationalUnit' )]
    [Switch] $OrganisationalUnit,

    [Parameter( Mandatory = $false, ParameterSetName = 'Specific' )]
    [Switch] $Users,

    [Parameter( Mandatory = $false, ParameterSetName = 'Specific' )]
    [Switch] $Computers,

    [Parameter( Mandatory = $false, ParameterSetName = 'Specific' )]
    [Switch] $Groups,

    [Parameter( Mandatory = $false, ParameterSetName = 'All' )]
    [Switch] $All = $true,

    [Parameter( Mandatory = $false, ParameterSetName = 'Specific' )]
    [Parameter( Mandatory = $false, ParameterSetName = 'All' )]
    [Switch] $Log = $false,

    [Parameter( Mandatory = $false, ParameterSetName = 'Specific' )]
    [Parameter( Mandatory = $false, ParameterSetName = 'All' )]
	[Alias( 'Management' )]
    [Switch] $Mgmt = $false,

    [Parameter( Mandatory = $false, ParameterSetName = 'Specific' )]
    [Parameter( Mandatory = $false, ParameterSetName = 'All' )]
    [Switch] $CSV = $false,

	[Parameter( Mandatory = $false )] 
	[string] $Folder = '',
	
	[Parameter( Mandatory = $false)] 
	[string] $SmtpServer = '',

	[Parameter( Mandatory = $false)] 
	[int]$SmtpPort = 25,

	[Parameter( Mandatory = $false)] 
	[Switch] $UseSSL = $false,

	[Parameter( Mandatory = $false)] 
	[string] $From = '',

	[Parameter( Mandatory = $false)] 
	[string] $To = '',

	[Parameter( Mandatory = $false )] 
	[Switch] $Dev = $false,
	
	[Parameter( Mandatory = $false )] 
	[Alias( 'SI' )]
	[Switch] $ScriptInfo = $false
)

#region script change log	
#originally written by Jeff Wouters | http://www.jeffwouters.nl | @JeffWouters
#Now maintained by Carl Webster and Michael B. Smith
#webster@carlwebster.com
#@carlwebster on Twitter
#https://www.CarlWebster.com
#
#michael@smithcons.com
#@essentialexch on Twitter
#https://www.essential.exchange/blog/
#
#Version 2.09 7-Feb-2022
#	Add missing variable $Script:ThisScriptPath
#	Changed all Write-Verbose statements from Get-Date to Get-Date -Format G as requested by Guy Leech
#	Changed the date format for the transcript and error log files from yyyy-MM-dd_HHmm format to the FileDateTime format
#		The format is yyyyMMddTHHmmssffff (case-sensitive, using a 4-digit year, 2-digit month, 2-digit day, 
#		the letter T as a time separator, 2-digit hour, 2-digit minute, 2-digit second, and 4-digit millisecond). 
#		For example: 20221225T0840107271.
#	Fixed the German Table of Contents (Thanks to Rene Bigler)
#		From 
#			'de-'	{ 'Automatische Tabelle 2'; Break }
#		To
#			'de-'	{ 'Automatisches Verzeichnis 2'; Break }
#	In Function AbortScript, add test for the winword process and terminate it if it is running
#		Added stopping the transcript log if the log was enabled and started
#	In Functions AbortScript and SaveandCloseDocumentandShutdownWord, add code from Guy Leech to test for the "Id" property before using it
#	Removed Function Stop-Winword
#	Replaced most script Exit calls with AbortScript to stop the transcript log if the log was enabled and started
#	Updated Functions CheckWordPrereq and SetupWord with the versions used in the other documentation scripts
#	Updated the help text
#	Updated the ReadMe file
#
#Version 2.08 8-May-2020
#	Add checking for a Word version of 0, which indicates the Office installation needs repairing
#	Change color variables $wdColorGray15 and $wdColorGray05 from [long] to [int]
#	Change location of the -Dev, -Log, and -ScriptInfo output files from the script folder to the -Folder location (Thanks to Guy Leech for the "suggestion")
#	Reformatted the terminating Write-Error messages to make them more visible and readable in the console
#	Update Function SetWordCellFormat to change parameter $BackgroundColor to [int]
#
#Version 2.07 21-Apr-2020
#	Remove the SMTP parameterset and manually verify the parameters
#	Update Function SendEmail to handle anonymous unauthenticated email
#		Update Help Text with examples
#		
#Version 2.06 17-Dec-2019
#	Fix Swedish Table of Contents (Thanks to Johan Kallio)
#		From 
#			'sv-'	{ 'Automatisk innehållsförteckning2'; Break }
#		To
#			'sv-'	{ 'Automatisk innehållsförteckn2'; Break }
#	Updated help text
#
#Version 2.05 1-Aug-2018
#	Fixed bug in WriteWordLine function reported by Steve Burkett
#
#Version 2.04 6-Apr-2018
#	Code clean up via Visual Code Studio
#
#Version 2.03 13-Jan-2018
#	Removed code that made sure all Parameters were set to default values if for some reason they did not exist or values were $Null
#	Removed the Visible parameter
#	Reordered the parameters in the help text and parameter list so they match and are grouped better
#	Replaced _SetDocumentProperty function with Jim Moyle's Set-DocumentProperty function
#	Updated Function ProcessScriptEnd for the new Cover Page properties and Parameters
#	Updated Function ShowScriptOptions for the new Cover Page properties and Parameters
#	Updated Function UpdateDocumentProperties for the new Cover Page properties and Parameters
#	Updated help text
#
#Version 2.02 13-Feb-2017
#	Fixed French wording for Table of Contents 2 (Thanks to David Rouquier)
#
#Version 2.01 7-Nov-2016
#	Added Chinese language support
#
#Version 2.0 9-May-2016
#	Added alias for AddDateTime of ADT
#	Added alias for CompanyName of CN
#	Added -Dev parameter to create a text file of script errors
#	Added more script information to the console output when script starts
#	Added -ScriptInfo (SI) parameter to create a text file of script information
#	Added support for emailing output report
#	Added support for output folder
#	Added word 2016 support
#	Fixed numerous issues discovered with the latest update to PowerShell V5
#	Fixed several incorrect variable names that kept PDFs from saving in Windows 10 and Office 2013
#	General code cleanup by Michael B. Smith
#	Output to CSV rewritten by Michael B. Smith
#	Removed the 10 second pauses waiting for Word to save and close
#	Removed unused parameters Text, HTML, ComputerName, Hardware
#	Significant Active Directory changes have been implemented by Michael B. Smith
#	Updated help text
#
# Version 1.0 released to the community on July 14, 2014
# http://jeffwouters.nl/index.php/2014/07/an-active-directory-health-check-powershell-script-v1-0/
#endregion

Function AbortScript
{
	If($MSWord -or $PDF)
	{
		Write-Verbose "$(Get-Date -Format G): System Cleanup"
		If(Test-Path variable:global:word)
		{
			$Script:Word.quit()
			[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Script:Word) | Out-Null
			Remove-Variable -Name word -Scope Global 4>$Null
		}
	}
	[gc]::collect() 
	[gc]::WaitForPendingFinalizers()

	If($MSWord -or $PDF)
	{
		#is the winword Process still running? kill it

		#find out our session (usually "1" except on TS/RDC or Citrix)
		$SessionID = (Get-Process -PID $PID).SessionId

		#Find out if winword running in our session
		$wordprocess = ((Get-Process 'WinWord' -ea 0) | Where-Object {$_.SessionId -eq $SessionID}) | Select-Object -Property Id 
		If( $wordprocess -and $wordprocess.Id -gt 0)
		{
			Write-Verbose "$(Get-Date -Format G): WinWord Process is still running. Attempting to stop WinWord Process # $($wordprocess.Id)"
			Stop-Process $wordprocess.Id -EA 0
		}
	}
	
	Write-Verbose "$(Get-Date -Format G): Script has been aborted"
	#stop transcript logging
	If($Log -eq $True) 
	{
		If($Script:StartLog -eq $True) 
		{
			try 
			{
				Stop-Transcript | Out-Null
				Write-Verbose "$(Get-Date -Format G): $Script:LogPath is ready for use"
			} 
			catch 
			{
				Write-Verbose "$(Get-Date -Format G): Transcript/log stop failed"
			}
		}
	}
	$ErrorActionPreference = $SaveEAPreference
	Exit
}

Set-StrictMode -Version 2

#force -verbose on
$PSDefaultParameterValues = @{"*:Verbose"=$True}
$SaveEAPreference = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'
$Script:ThisScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

If($Null -eq $MSWord)
{
	If($PDF)
	{
		$MSWord = $False
	}
	Else
	{
		$MSWord = $True
	}
}

If($MSWord -eq $False -and $PDF -eq $False)
{
	$MSWord = $True
}

Write-Verbose "$(Get-Date -Format G): Testing output parameters"

If($MSWord)
{
	Write-Verbose "$(Get-Date -Format G): MSWord is set"
}
ElseIf($PDF)
{
	Write-Verbose "$(Get-Date -Format G): PDF is set"
}
Else
{
	$ErrorActionPreference = $SaveEAPreference
	Write-Verbose "$(Get-Date -Format G): Unable to determine output parameter"
	If($Null -eq $MSWord)
	{
		Write-Verbose "$(Get-Date -Format G): MSWord is Null"
	}
	ElseIf($Null -eq $PDF)
	{
		Write-Verbose "$(Get-Date -Format G): PDF is Null"
	}
	Else
	{
		Write-Verbose "$(Get-Date -Format G): MSWord is " $MSWord
		Write-Verbose "$(Get-Date -Format G): PDF is " $PDF
	}
	Write-Error "
	`n`n
	`t`t
	Unable to determine output parameter.
	`n`n
	`t`t
	Script cannot continue.
	`n`n
	"
	AbortScript
}

If(![String]::IsNullOrEmpty($SmtpServer) -and [String]::IsNullOrEmpty($From) -and [String]::IsNullOrEmpty($To))
{
	Write-Error "
	`n`n
	`t`t
	You specified an SmtpServer but did not include a From or To email address.
	`n`n
	`t`t
	Script cannot continue.
	`n`n"
	AbortScript
}
If(![String]::IsNullOrEmpty($SmtpServer) -and [String]::IsNullOrEmpty($From) -and ![String]::IsNullOrEmpty($To))
{
	Write-Error "
	`n`n
	`t`t
	You specified an SmtpServer and a To email address but did not include a From email address.
	`n`n
	`t`t
	Script cannot continue.
	`n`n"
	AbortScript
}
If(![String]::IsNullOrEmpty($SmtpServer) -and [String]::IsNullOrEmpty($To) -and ![String]::IsNullOrEmpty($From))
{
	Write-Error "
	`n`n
	`t`t
	You specified an SmtpServer and a From email address but did not include a To email address.
	`n`n
	`t`t
	Script cannot continue.
	`n`n"
	AbortScript
}
If(![String]::IsNullOrEmpty($From) -and ![String]::IsNullOrEmpty($To) -and [String]::IsNullOrEmpty($SmtpServer))
{
	Write-Error "
	`n`n
	`t`t
	You specified From and To email addresses but did not include the SmtpServer.
	`n`n
	`t`t
	Script cannot continue.
	`n`n"
	AbortScript
}
If(![String]::IsNullOrEmpty($From) -and [String]::IsNullOrEmpty($SmtpServer))
{
	Write-Error "
	`n`n
	`t`t
	You specified a From email address but did not include the SmtpServer.
	`n`n
	`t`t
	Script cannot continue.
	`n`n"
	AbortScript
}
If(![String]::IsNullOrEmpty($To) -and [String]::IsNullOrEmpty($SmtpServer))
{
	Write-Error "
	`n`n
	`t`t
	You specified a To email address but did not include the SmtpServer.
	`n`n
	`t`t
	Script cannot continue.
	`n`n"
	AbortScript
}

If($Folder -ne "")
{
	Write-Verbose "$(Get-Date -Format G): Testing folder path"
	#does it exist
	If(Test-Path $Folder -EA 0)
	{
		#it exists, now check to see if it is a folder and not a file
		If(Test-Path $Folder -pathType Container -EA 0)
		{
			#it exists and it is a folder
			Write-Verbose "$(Get-Date -Format G): Folder path $Folder exists and is a folder"
		}
		Else
		{
			#it exists but it is a file not a folder
			Write-Error "
			`n`n
			`t`t
			Folder $Folder is a file, not a folder.
			`n`n
			`t`t
			Script cannot continue.
			`n`n
			"
			$ErrorActionPreference = $SaveEAPreference
			AbortScript
		}
	}
	Else
	{
		#does not exist
		Write-Error "
		`n`n
		`t`t
		Folder $Folder does not exist.
		`n`n
		`t`t
		Script cannot continue.
		`n`n
		"
		$ErrorActionPreference = $SaveEAPreference
		AbortScript
	}
}

If($Folder -eq "")
{
	$Script:pwdpath = $pwd.Path
}
Else
{
	$Script:pwdpath = $Folder
}

If($Script:pwdpath.EndsWith("\"))
{
	#remove the trailing \
	$Script:pwdpath = $Script:pwdpath.SubString(0, ($Script:pwdpath.Length - 1))
}

If($PSBoundParameters.ContainsKey('Log')) 
{
    $Script:LogPath = "$Script:pwdpath\ADHealthCheckTranscript_$(Get-Date -f FileDateTime).txt"
    If((Test-Path $Script:LogPath) -eq $true) 
	{
        Write-Verbose "$(Get-Date -Format G): Transcript/Log $Script:LogPath already exists"
        $Script:StartLog = $false
    } 
	Else 
	{
        try 
		{
            Start-Transcript -Path $Script:LogPath -Force -Verbose:$false | Out-Null
            Write-Verbose "$(Get-Date -Format G): Transcript/log started at $Script:LogPath"
            $Script:StartLog = $true
        } 
		catch 
		{
            Write-Verbose "$(Get-Date -Format G): Transcript/log failed at $Script:LogPath"
            $Script:StartLog = $false
        }
    }
}

If($Dev)
{
	$Error.Clear()
	[string] $Script:DevErrorFile = "$Script:pwdpath\ADHealthCheckScriptErrors_$(Get-Date -f FileDateTime).txt"
}

If($ScriptInfo)
{
	[string] $Script:SIFile = "$Script:pwdpath\ADHealthCheckScriptInfo_$(Get-Date -f yyyy-MM-dd_HHmm).txt"
}

[string]$Script:RunningOS = (Get-WmiObject -class Win32_OperatingSystem -EA 0).Caption

If($MSWord -or $PDF)
{
	#try and fix the issue with the $CompanyName variable
	$Script:CoName = $CompanyName
	Write-Verbose "$(Get-Date -Format G): CoName is $($Script:CoName)"
	
	#the following values were attained from 
	#http://groovy.codehaus.org/modules/scriptom/1.6.0/scriptom-office-2K3-tlb/apidocs/
	#http://msdn.microsoft.com/en-us/library/office/aa211923(v=office.11).aspx
	[int]$wdAlignPageNumberRight = 2
	[int]$wdColorGray15 = 14277081
	[int]$wdColorGray05 = 15987699 
	[int]$wdMove = 0
	[int]$wdSeekMainDocument = 0
	[int]$wdSeekPrimaryFooter = 4
	[int]$wdStory = 6
	[long]$wdColorRed = 255
	[int]$wdColorBlack = 0
	[int]$wdWord2007 = 12
	[int]$wdWord2010 = 14
	[int]$wdWord2013 = 15
	[int]$wdWord2016 = 16
	[int]$wdFormatDocumentDefault = 16
	[int]$wdFormatPDF = 17
	#http://blogs.technet.com/b/heyscriptingguy/archive/2006/03/01/how-can-i-right-align-a-single-column-in-a-word-table.aspx
	#http://msdn.microsoft.com/en-us/library/office/ff835817%28v=office.15%29.aspx
	[int]$wdAlignParagraphLeft = 0
	[int]$wdAlignParagraphCenter = 1
	[int]$wdAlignParagraphRight = 2
	#http://msdn.microsoft.com/en-us/library/office/ff193345%28v=office.15%29.aspx
	[int]$wdCellAlignVerticalTop = 0
	[int]$wdCellAlignVerticalCenter = 1
	[int]$wdCellAlignVerticalBottom = 2
	#http://msdn.microsoft.com/en-us/library/office/ff844856%28v=office.15%29.aspx
	[int]$wdAutoFitFixed = 0
	[int]$wdAutoFitContent = 1
	[int]$wdAutoFitWindow = 2
	#http://msdn.microsoft.com/en-us/library/office/ff821928%28v=office.15%29.aspx
	[int]$wdAdjustNone = 0
	[int]$wdAdjustProportional = 1
	[int]$wdAdjustFirstColumn = 2
	[int]$wdAdjustSameWidth = 3

	[int]$PointsPerTabStop = 36
	[int]$Indent0TabStops = 0 * $PointsPerTabStop
	[int]$Indent1TabStops = 1 * $PointsPerTabStop
	[int]$Indent2TabStops = 2 * $PointsPerTabStop
	[int]$Indent3TabStops = 3 * $PointsPerTabStop
	[int]$Indent4TabStops = 4 * $PointsPerTabStop

	# http://www.thedoctools.com/index.php?show=wt_style_names_english_danish_german_french
	[int]$wdStyleHeading1 = -2
	[int]$wdStyleHeading2 = -3
	[int]$wdStyleHeading3 = -4
	[int]$wdStyleHeading4 = -5
	[int]$wdStyleNoSpacing = -158
	[int]$wdTableGrid = -155

	#http://groovy.codehaus.org/modules/scriptom/1.6.0/scriptom-office-2K3-tlb/apidocs/org/codehaus/groovy/scriptom/tlb/office/word/WdLineStyle.html
	[int]$wdLineStyleNone = 0
	[int]$wdLineStyleSingle = 1

	[int]$wdHeadingFormatTrue = -1
	[int]$wdHeadingFormatFalse = 0 
}

Function SetWordHashTable
{
	Param([string]$CultureCode)

	#optimized by Michael B. SMith
	
	# DE and FR translations for Word 2010 by Vladimir Radojevic
	# Vladimir.Radojevic@Commerzreal.com

	# DA translations for Word 2010 by Thomas Daugaard
	# Citrix Infrastructure Specialist at edgemo A/S

	# CA translations by Javier Sanchez 
	# CEO & Founder 101 Consulting

	#ca - Catalan
	#da - Danish
	#de - German
	#en - English
	#es - Spanish
	#fi - Finnish
	#fr - French
	#nb - Norwegian
	#nl - Dutch
	#pt - Portuguese
	#sv - Swedish
	#zh - Chinese
	
	[string]$toc = $(
		Switch ($CultureCode)
		{
			'ca-'	{ 'Taula automática 2'; Break }
			'da-'	{ 'Automatisk tabel 2'; Break }
			#'de-'	{ 'Automatische Tabelle 2'; Break }
			'de-'	{ 'Automatisches Verzeichnis 2'; Break } #changed 7-feb-2022 rene bigler
			'en-'	{ 'Automatic Table 2'; Break }
			'es-'	{ 'Tabla automática 2'; Break }
			'fi-'	{ 'Automaattinen taulukko 2'; Break }
			'fr-'	{ 'Table automatique 2'; Break } #changed 13-feb-2017 david roquier and samuel legrand
			'nb-'	{ 'Automatisk tabell 2'; Break }
			'nl-'	{ 'Automatische inhoudsopgave 2'; Break }
			'pt-'	{ 'Sumário Automático 2'; Break }
			# fix in 2.06 thanks to Johan Kallio 'sv-'	{ 'Automatisk innehållsförteckning2'; Break }
			'sv-'	{ 'Automatisk innehållsförteckn2'; Break }
			'zh-'	{ '自动目录 2'; Break }
		}
	)

	$Script:myHash                      = @{}
	$Script:myHash.Word_TableOfContents = $toc
	$Script:myHash.Word_NoSpacing       = $wdStyleNoSpacing
	$Script:myHash.Word_Heading1        = $wdStyleheading1
	$Script:myHash.Word_Heading2        = $wdStyleheading2
	$Script:myHash.Word_Heading3        = $wdStyleheading3
	$Script:myHash.Word_Heading4        = $wdStyleheading4
	$Script:myHash.Word_TableGrid       = $wdTableGrid
}

Function GetCulture
{
	Param([int]$WordValue)
	
	#codes obtained from http://support.microsoft.com/kb/221435
	#http://msdn.microsoft.com/en-us/library/bb213877(v=office.12).aspx
	$CatalanArray = 1027
	$ChineseArray = 2052,3076,5124,4100
	$DanishArray = 1030
	$DutchArray = 2067, 1043
	$EnglishArray = 3081, 10249, 4105, 9225, 6153, 8201, 5129, 13321, 7177, 11273, 2057, 1033, 12297
	$FinnishArray = 1035
	$FrenchArray = 2060, 1036, 11276, 3084, 12300, 5132, 13324, 6156, 8204, 10252, 7180, 9228, 4108
	$GermanArray = 1031, 3079, 5127, 4103, 2055
	$NorwegianArray = 1044, 2068
	$PortugueseArray = 1046, 2070
	$SpanishArray = 1034, 11274, 16394, 13322, 9226, 5130, 7178, 12298, 17418, 4106, 18442, 19466, 6154, 15370, 10250, 20490, 3082, 14346, 8202
	$SwedishArray = 1053, 2077

	#ca - Catalan
	#da - Danish
	#de - German
	#en - English
	#es - Spanish
	#fi - Finnish
	#fr - French
	#nb - Norwegian
	#nl - Dutch
	#pt - Portuguese
	#sv - Swedish
	#zh - Chinese

	Switch ($WordValue)
	{
		{$CatalanArray -contains $_} {$CultureCode = "ca-"}
		{$ChineseArray -contains $_} {$CultureCode = "zh-"}
		{$DanishArray -contains $_} {$CultureCode = "da-"}
		{$DutchArray -contains $_} {$CultureCode = "nl-"}
		{$EnglishArray -contains $_} {$CultureCode = "en-"}
		{$FinnishArray -contains $_} {$CultureCode = "fi-"}
		{$FrenchArray -contains $_} {$CultureCode = "fr-"}
		{$GermanArray -contains $_} {$CultureCode = "de-"}
		{$NorwegianArray -contains $_} {$CultureCode = "nb-"}
		{$PortugueseArray -contains $_} {$CultureCode = "pt-"}
		{$SpanishArray -contains $_} {$CultureCode = "es-"}
		{$SwedishArray -contains $_} {$CultureCode = "sv-"}
		Default {$CultureCode = "en-"}
	}
	
	Return $CultureCode
}

Function ValidateCoverPage
{
	Param([int]$xWordVersion, [string]$xCP, [string]$CultureCode)
	
	$xArray = ""
	
	Switch ($CultureCode)
	{
		'ca-'	{
				If($xWordVersion -eq $wdWord2016)
				{
					$xArray = ("Austin", "En bandes", "Faceta", "Filigrana",
					"Integral", "Ió (clar)", "Ió (fosc)", "Línia lateral",
					"Moviment", "Quadrícula", "Retrospectiu", "Sector (clar)",
					"Sector (fosc)", "Semàfor", "Visualització principal", "Whisp")
				}
				ElseIf($xWordVersion -eq $wdWord2013)
				{
					$xArray = ("Austin", "En bandes", "Faceta", "Filigrana",
					"Integral", "Ió (clar)", "Ió (fosc)", "Línia lateral",
					"Moviment", "Quadrícula", "Retrospectiu", "Sector (clar)",
					"Sector (fosc)", "Semàfor", "Visualització", "Whisp")
				}
				ElseIf($xWordVersion -eq $wdWord2010)
				{
					$xArray = ("Alfabet", "Anual", "Austin", "Conservador",
					"Contrast", "Cubicles", "Diplomàtic", "Exposició",
					"Línia lateral", "Mod", "Mosiac", "Moviment", "Paper de diari",
					"Perspectiva", "Piles", "Quadrícula", "Sobri",
					"Transcendir", "Trencaclosques")
				}
			}

		'da-'	{
				If($xWordVersion -eq $wdWord2016)
				{
					$xArray = ("Austin", "BevægElse", "Brusen", "Facet", "Filigran", 
					"Gitter", "Integral", "Ion (lys)", "Ion (mørk)", 
					"Retro", "Semafor", "Sidelinje", "Stribet", 
					"Udsnit (lys)", "Udsnit (mørk)", "Visningsmaster")
				}
				ElseIf($xWordVersion -eq $wdWord2013)
				{
					$xArray = ("BevægElse", "Brusen", "Ion (lys)", "Filigran",
					"Retro", "Semafor", "Visningsmaster", "Integral",
					"Facet", "Gitter", "Stribet", "Sidelinje", "Udsnit (lys)",
					"Udsnit (mørk)", "Ion (mørk)", "Austin")
				}
				ElseIf($xWordVersion -eq $wdWord2010)
				{
					$xArray = ("BevægElse", "Moderat", "Perspektiv", "Firkanter",
					"Overskrid", "Alfabet", "Kontrast", "Stakke", "Fliser", "Gåde",
					"Gitter", "Austin", "Eksponering", "Sidelinje", "Enkel",
					"Nålestribet", "Årlig", "Avispapir", "Tradionel")
				}
			}

		'de-'	{
				If($xWordVersion -eq $wdWord2016)
				{
					$xArray = ("Austin", "Bewegung", "Facette", "Filigran", 
					"Gebändert", "Integral", "Ion (dunkel)", "Ion (hell)", 
					"Pfiff", "Randlinie", "Raster", "Rückblick", 
					"Segment (dunkel)", "Segment (hell)", "Semaphor", 
					"ViewMaster")
				}
				ElseIf($xWordVersion -eq $wdWord2013)
				{
					$xArray = ("Semaphor", "Segment (hell)", "Ion (hell)",
					"Raster", "Ion (dunkel)", "Filigran", "Rückblick", "Pfiff",
					"ViewMaster", "Segment (dunkel)", "Verbunden", "Bewegung",
					"Randlinie", "Austin", "Integral", "Facette")
				}
				ElseIf($xWordVersion -eq $wdWord2010)
				{
					$xArray = ("Alphabet", "Austin", "Bewegung", "Durchscheinend",
					"Herausgestellt", "Jährlich", "Kacheln", "Kontrast", "Kubistisch",
					"Modern", "Nadelstreifen", "Perspektive", "Puzzle", "Randlinie",
					"Raster", "Schlicht", "Stapel", "Traditionell", "Zeitungspapier")
				}
			}

		'en-'	{
				If($xWordVersion -eq $wdWord2013 -or $xWordVersion -eq $wdWord2016)
				{
					$xArray = ("Austin", "Banded", "Facet", "Filigree", "Grid",
					"Integral", "Ion (Dark)", "Ion (Light)", "Motion", "Retrospect",
					"Semaphore", "Sideline", "Slice (Dark)", "Slice (Light)", "ViewMaster",
					"Whisp")
				}
				ElseIf($xWordVersion -eq $wdWord2010)
				{
					$xArray = ("Alphabet", "Annual", "Austere", "Austin", "Conservative",
					"Contrast", "Cubicles", "Exposure", "Grid", "Mod", "Motion", "Newsprint",
					"Perspective", "Pinstripes", "Puzzle", "Sideline", "Stacks", "Tiles", "Transcend")
				}
			}

		'es-'	{
				If($xWordVersion -eq $wdWord2016)
				{
					$xArray = ("Austin", "Con bandas", "Cortar (oscuro)", "Cuadrícula", 
					"Whisp", "Faceta", "Filigrana", "Integral", "Ion (claro)", 
					"Ion (oscuro)", "Línea lateral", "Movimiento", "Retrospectiva", 
					"Semáforo", "Slice (luz)", "Vista principal", "Whisp")
				}
				ElseIf($xWordVersion -eq $wdWord2013)
				{
					$xArray = ("Whisp", "Vista principal", "Filigrana", "Austin",
					"Slice (luz)", "Faceta", "Semáforo", "Retrospectiva", "Cuadrícula",
					"Movimiento", "Cortar (oscuro)", "Línea lateral", "Ion (oscuro)",
					"Ion (claro)", "Integral", "Con bandas")
				}
				ElseIf($xWordVersion -eq $wdWord2010)
				{
					$xArray = ("Alfabeto", "Anual", "Austero", "Austin", "Conservador",
					"Contraste", "Cuadrícula", "Cubículos", "Exposición", "Línea lateral",
					"Moderno", "Mosaicos", "Movimiento", "Papel periódico",
					"Perspectiva", "Pilas", "Puzzle", "Rayas", "Sobrepasar")
				}
			}

		'fi-'	{
				If($xWordVersion -eq $wdWord2016)
				{
					$xArray = ("Filigraani", "Integraali", "Ioni (tumma)",
					"Ioni (vaalea)", "Opastin", "Pinta", "Retro", "Sektori (tumma)",
					"Sektori (vaalea)", "Vaihtuvavärinen", "ViewMaster", "Austin",
					"Kuiskaus", "Liike", "Ruudukko", "Sivussa")
				}
				ElseIf($xWordVersion -eq $wdWord2013)
				{
					$xArray = ("Filigraani", "Integraali", "Ioni (tumma)",
					"Ioni (vaalea)", "Opastin", "Pinta", "Retro", "Sektori (tumma)",
					"Sektori (vaalea)", "Vaihtuvavärinen", "ViewMaster", "Austin",
					"Kiehkura", "Liike", "Ruudukko", "Sivussa")
				}
				ElseIf($xWordVersion -eq $wdWord2010)
				{
					$xArray = ("Aakkoset", "Askeettinen", "Austin", "Kontrasti",
					"Laatikot", "Liike", "Liituraita", "Mod", "Osittain peitossa",
					"Palapeli", "Perinteinen", "Perspektiivi", "Pinot", "Ruudukko",
					"Ruudut", "Sanomalehtipaperi", "Sivussa", "Vuotuinen", "Ylitys")
				}
			}

		'fr-'	{
				If($xWordVersion -eq $wdWord2013 -or $xWordVersion -eq $wdWord2016)
				{
					$xArray = ("À bandes", "Austin", "Facette", "Filigrane", 
					"Guide", "Intégrale", "Ion (clair)", "Ion (foncé)", 
					"Lignes latérales", "Quadrillage", "Rétrospective", "Secteur (clair)", 
					"Secteur (foncé)", "Sémaphore", "ViewMaster", "Whisp")
				}
				ElseIf($xWordVersion -eq $wdWord2010)
				{
					$xArray = ("Alphabet", "Annuel", "Austère", "Austin", 
					"Blocs empilés", "Classique", "Contraste", "Emplacements de bureau", 
					"Exposition", "Guide", "Ligne latérale", "Moderne", 
					"Mosaïques", "Mots croisés", "Papier journal", "Perspective",
					"Quadrillage", "Rayures fines", "Transcendant")
				}
			}

		'nb-'	{
				If($xWordVersion -eq $wdWord2013 -or $xWordVersion -eq $wdWord2016)
				{
					$xArray = ("Austin", "BevegElse", "Dempet", "Fasett", "Filigran",
					"Integral", "Ion (lys)", "Ion (mørk)", "Retrospekt", "Rutenett",
					"Sektor (lys)", "Sektor (mørk)", "Semafor", "Sidelinje", "Stripet",
					"ViewMaster")
				}
				ElseIf($xWordVersion -eq $wdWord2010)
				{
					$xArray = ("Alfabet", "Årlig", "Avistrykk", "Austin", "Avlukker",
					"BevegElse", "Engasjement", "Enkel", "Fliser", "Konservativ",
					"Kontrast", "Mod", "Perspektiv", "Puslespill", "Rutenett", "Sidelinje",
					"Smale striper", "Stabler", "Transcenderende")
				}
			}

		'nl-'	{
				If($xWordVersion -eq $wdWord2013 -or $xWordVersion -eq $wdWord2016)
				{
					$xArray = ("Austin", "Beweging", "Facet", "Filigraan", "Gestreept",
					"Integraal", "Ion (donker)", "Ion (licht)", "Raster",
					"Segment (Light)", "Semafoor", "Slice (donker)", "Spriet",
					"Terugblik", "Terzijde", "ViewMaster")
				}
				ElseIf($xWordVersion -eq $wdWord2010)
				{
					$xArray = ("Aantrekkelijk", "Alfabet", "Austin", "Bescheiden",
					"Beweging", "Blikvanger", "Contrast", "Eenvoudig", "Jaarlijks",
					"Krantenpapier", "Krijtstreep", "Kubussen", "Mod", "Perspectief",
					"Puzzel", "Raster", "Stapels",
					"Tegels", "Terzijde")
				}
			}

		'pt-'	{
				If($xWordVersion -eq $wdWord2013 -or $xWordVersion -eq $wdWord2016)
				{
					$xArray = ("Animação", "Austin", "Em Tiras", "Exibição Mestra",
					"Faceta", "Fatia (Clara)", "Fatia (Escura)", "Filete", "Filigrana", 
					"Grade", "Integral", "Íon (Claro)", "Íon (Escuro)", "Linha Lateral",
					"Retrospectiva", "Semáforo")
				}
				ElseIf($xWordVersion -eq $wdWord2010)
				{
					$xArray = ("Alfabeto", "Animação", "Anual", "Austero", "Austin", "Baias",
					"Conservador", "Contraste", "Exposição", "Grade", "Ladrilhos",
					"Linha Lateral", "Listras", "Mod", "Papel Jornal", "Perspectiva", "Pilhas",
					"Quebra-cabeça", "Transcend")
				}
			}

		'sv-'	{
				If($xWordVersion -eq $wdWord2013 -or $xWordVersion -eq $wdWord2016)
				{
					$xArray = ("Austin", "Band", "Fasett", "Filigran", "Integrerad", "Jon (ljust)",
					"Jon (mörkt)", "Knippe", "Rutnät", "RörElse", "Sektor (ljus)", "Sektor (mörk)",
					"Semafor", "Sidlinje", "VisaHuvudsida", "Återblick")
				}
				ElseIf($xWordVersion -eq $wdWord2010)
				{
					$xArray = ("Alfabetmönster", "Austin", "Enkelt", "Exponering", "Konservativt",
					"Kontrast", "Kritstreck", "Kuber", "Perspektiv", "Plattor", "Pussel", "Rutnät",
					"RörElse", "Sidlinje", "Sobert", "Staplat", "Tidningspapper", "Årligt",
					"Övergående")
				}
			}

		'zh-'	{
				If($xWordVersion -eq $wdWord2010 -or $xWordVersion -eq $wdWord2013 -or $xWordVersion -eq $wdWord2016)
				{
					$xArray = ('奥斯汀', '边线型', '花丝', '怀旧', '积分',
					'离子(浅色)', '离子(深色)', '母版型', '平面', '切片(浅色)',
					'切片(深色)', '丝状', '网格', '镶边', '信号灯',
					'运动型')
				}
			}

		Default	{
					If($xWordVersion -eq $wdWord2013 -or $xWordVersion -eq $wdWord2016)
					{
						$xArray = ("Austin", "Banded", "Facet", "Filigree", "Grid",
						"Integral", "Ion (Dark)", "Ion (Light)", "Motion", "Retrospect",
						"Semaphore", "Sideline", "Slice (Dark)", "Slice (Light)", "ViewMaster",
						"Whisp")
					}
					ElseIf($xWordVersion -eq $wdWord2010)
					{
						$xArray = ("Alphabet", "Annual", "Austere", "Austin", "Conservative",
						"Contrast", "Cubicles", "Exposure", "Grid", "Mod", "Motion", "Newsprint",
						"Perspective", "Pinstripes", "Puzzle", "Sideline", "Stacks", "Tiles", "Transcend")
					}
				}
	}
	
	If($xArray -contains $xCP)
	{
		$xArray = $Null
		Return $True
	}
	Else
	{
		$xArray = $Null
		Return $False
	}
}

Function CheckWordPrereq
{
	If((Test-Path  REGISTRY::HKEY_CLASSES_ROOT\Word.Application) -eq $False)
	{
		$ErrorActionPreference = $SaveEAPreference
		
		If(($MSWord -eq $False) -and ($PDF -eq $True))
		{
			Write-Host "`n`n`t`tThis script uses Microsoft Word's SaveAs PDF function, please install Microsoft Word`n`n"
			AbortScript
		}
		Else
		{
			Write-Host "`n`n`t`tThis script directly outputs to Microsoft Word, please install Microsoft Word`n`n"
			AbortScript
		}
	}

	#find out our session (usually "1" except on TS/RDC or Citrix)
	$SessionID = (Get-Process -PID $PID).SessionId
	
	#Find out if winword is running in our session
	[bool]$wordrunning = $null –ne ((Get-Process 'WinWord' -ea 0) | Where-Object {$_.SessionId -eq $SessionID})
	If($wordrunning)
	{
		$ErrorActionPreference = $SaveEAPreference
		Write-Host "`n`n`tPlease close all instances of Microsoft Word before running this report.`n`n"
		AbortScript
	}
}

Function ValidateCompanyName
{
	[bool]$xResult = Test-RegistryValue "HKCU:\Software\Microsoft\Office\Common\UserInfo" "CompanyName"
	If($xResult)
	{
		Return Get-RegistryValue "HKCU:\Software\Microsoft\Office\Common\UserInfo" "CompanyName"
	}
	Else
	{
		$xResult = Test-RegistryValue "HKCU:\Software\Microsoft\Office\Common\UserInfo" "Company"
		If($xResult)
		{
			Return Get-RegistryValue "HKCU:\Software\Microsoft\Office\Common\UserInfo" "Company"
		}
		Else
		{
			Return ""
		}
	}
}

#http://stackoverflow.com/questions/5648931/test-if-registry-value-exists
# This Function just gets $True or $False
Function Test-RegistryValue($path, $name)
{
	$key = Get-Item -LiteralPath $path -EA 0
	$key -and $Null -ne $key.GetValue($name, $Null)
}

# Gets the specified registry value or $Null if it is missing
Function Get-RegistryValue($path, $name)
{
	$key = Get-Item -LiteralPath $path -EA 0
	If($key)
	{
		$key.GetValue($name, $Null)
	}
	Else
	{
		$Null
	}
}

Function WriteWordLine
#Function created by Ryan Revord
#@rsrevord on Twitter
#Function created to make output to Word easy in this script
#updated 27-Mar-2014 to include font name, font size, italics and bold options
{
	Param([int]$style=0, 
	[int]$tabs = 0, 
	[string]$name = '', 
	[string]$value = '', 
	[string]$fontName=$Null,
	[int]$fontSize=0,
	[bool]$italics=$False,
	[bool]$boldface=$False,
	[Switch]$nonewline)
	
	#Build output style
	[string]$output = ""
	Switch ($style)
	{
		0 {$Script:Selection.Style = $Script:MyHash.Word_NoSpacing}
		1 {$Script:Selection.Style = $Script:MyHash.Word_Heading1}
		2 {$Script:Selection.Style = $Script:MyHash.Word_Heading2}
		3 {$Script:Selection.Style = $Script:MyHash.Word_Heading3}
		4 {$Script:Selection.Style = $Script:MyHash.Word_Heading4}
		Default {$Script:Selection.Style = $Script:MyHash.Word_NoSpacing}
	}
	
	#build # of tabs
	While($tabs -gt 0)
	{ 
		$output += "`t"; $tabs--; 
	}
 
	If(![String]::IsNullOrEmpty($fontName)) 
	{
		$Script:Selection.Font.name = $fontName
	} 

	If($fontSize -ne 0) 
	{
		$Script:Selection.Font.size = $fontSize
	} 
 
	If($italics -eq $True) 
	{
		$Script:Selection.Font.Italic = $True
	} 
 
	If($boldface -eq $True) 
	{
		$Script:Selection.Font.Bold = $True
	} 

	#output the rest of the parameters.
	$output += $name + $value
	$Script:Selection.TypeText($output)
 
	#test for new WriteWordLine 0.
	If($nonewline)
	{
		# Do nothing.
	} 
	Else 
	{
		$Script:Selection.TypeParagraph()
	}
}

Function Set-DocumentProperty {
    <#
	.SYNOPSIS
	Function to set the Title Page document properties in MS Word
	.DESCRIPTION
	Long description
	.PARAMETER Document
	Current Document Object
	.PARAMETER DocProperty
	Parameter description
	.PARAMETER Value
	Parameter description
	.EXAMPLE
	Set-DocumentProperty -Document $Script:Doc -DocProperty Title -Value 'MyTitle'
	.EXAMPLE
	Set-DocumentProperty -Document $Script:Doc -DocProperty Company -Value 'MyCompany'
	.EXAMPLE
	Set-DocumentProperty -Document $Script:Doc -DocProperty Author -Value 'Jim Moyle'
	.EXAMPLE
	Set-DocumentProperty -Document $Script:Doc -DocProperty Subject -Value 'MySubjectTitle'
	.NOTES
	Function Created by Jim Moyle June 2017
	Twitter : @JimMoyle
	#>
    param (
        [object]$Document,
        [String]$DocProperty,
        [string]$Value
    )
    try {
        $binding = "System.Reflection.BindingFlags" -as [type]
        $builtInProperties = $Document.BuiltInDocumentProperties
        $property = [System.__ComObject].invokemember("item", $binding::GetProperty, $null, $BuiltinProperties, $DocProperty)
        [System.__ComObject].invokemember("value", $binding::SetProperty, $null, $property, $Value)
    }
    catch {
        Write-Warning "Failed to set $DocProperty to $Value"
    }
}

Function FindWordDocumentEnd
{
	#Return focus to main document    
	$Script:Doc.ActiveWindow.ActivePane.view.SeekView = $wdSeekMainDocument
	#move to the end of the current document
	$Script:Selection.EndKey($wdStory,$wdMove) | Out-Null
}

<#
.Synopsis
	Add a table to a Microsoft Word document
.DESCRIPTION
	This Function adds a table to a Microsoft Word document from either an array of
	Hashtables or an array of PSCustomObjects.

	Using this Function is quicker than setting each table cell individually but can
	only utilise the built-in MS Word table autoformats. Individual tables cells can
	be altered after the table has been appended to the document (a table reference
	is Returned).
.EXAMPLE
	AddWordTable -Hashtable $HashtableArray

	This example adds table to the MS Word document, utilising all key/value pairs in
	the array of hashtables. Column headers will display the key names as defined.
	Note: the columns might not be displayed in the order that they were defined. To
	ensure columns are displayed in the required order utilise the -Columns parameter.
.EXAMPLE
	AddWordTable -Hashtable $HashtableArray -List

	This example adds table to the MS Word document, utilising all key/value pairs in
	the array of hashtables. No column headers will be added, in a ListView format.
	Note: the columns might not be displayed in the order that they were defined. To
	ensure columns are displayed in the required order utilise the -Columns parameter.
.EXAMPLE
	AddWordTable -CustomObject $PSCustomObjectArray

	This example adds table to the MS Word document, utilising all note property names
	the array of PSCustomObjects. Column headers will display the note property names.
	Note: the columns might not be displayed in the order that they were defined. To
	ensure columns are displayed in the required order utilise the -Columns parameter.
.EXAMPLE
	AddWordTable -Hashtable $HashtableArray -Columns FirstName,LastName,EmailAddress

	This example adds a table to the MS Word document, but only using the specified
	key names: FirstName, LastName and EmailAddress. If other keys are present in the
	array of Hashtables they will be ignored.
.EXAMPLE
	AddWordTable -CustomObject $PSCustomObjectArray -Columns FirstName,LastName,EmailAddress -Headers "First Name","Last Name","Email Address"

	This example adds a table to the MS Word document, but only using the specified
	PSCustomObject note properties: FirstName, LastName and EmailAddress. If other note
	properties are present in the array of PSCustomObjects they will be ignored. The
	display names for each specified column header has been overridden to display a
	custom header. Note: the order of the header names must match the specified columns.
#>
Function AddWordTable
{
	[CmdletBinding()]
	Param
	(
		# Array of Hashtable (including table headers)
		[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='Hashtable', Position=0)]
		[ValidateNotNullOrEmpty()] [System.Collections.Hashtable[]] $Hashtable,
		# Array of PSCustomObjects
		[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='CustomObject', Position=0)]
		[ValidateNotNullOrEmpty()] [PSCustomObject[]] $CustomObject,
		# Array of Hashtable key names or PSCustomObject property names to include, in display order.
		# If not supplied then all Hashtable keys or all PSCustomObject properties will be displayed.
		[Parameter(ValueFromPipelineByPropertyName=$true)] [AllowNull()] [string[]] $Columns = $null,
		# Array of custom table header strings in display order.
		[Parameter(ValueFromPipelineByPropertyName=$true)] [AllowNull()] [string[]] $Headers = $null,
		# AutoFit table behavior.
		[Parameter(ValueFromPipelineByPropertyName=$true)] [AllowNull()] [int] $AutoFit = -1,
		# List view (no headers)
		[Switch] $List,
		# Grid lines
		[Switch] $NoGridLines=$false,
		# Built-in Word table formatting style constant
		# Would recommend only $wdTableFormatContempory for normal usage (possibly $wdTableFormatList5 for List view)
		[Parameter(ValueFromPipelineByPropertyName=$true)] [int] $Format = '-231'
	)

	Begin 
	{
		Write-Debug ("Using parameter set '{0}'" -f $PSCmdlet.ParameterSetName);
		## Check if -Columns wasn't specified but -Headers were (saves some additional parameter sets!)
		If(($Columns -eq $null) -and ($Headers -ne $null)) 
		{
			Write-Warning "No columns specified and therefore, specified headers will be ignored.";
			$Columns = $null;
		}
		ElseIf(($Columns -ne $null) -and ($Headers -ne $null)) 
		{
			## Check if number of specified -Columns matches number of specified -Headers
			If($Columns.Length -ne $Headers.Length) 
			{
				Write-Error "The specified number of columns does not match the specified number of headers.";
			}
		} ## end ElseIf
	} ## end Begin

	Process
	{
		## Build the Word table data string to be converted to a range and then a table later.
        [System.Text.StringBuilder] $WordRangeString = New-Object System.Text.StringBuilder;

		Switch ($PSCmdlet.ParameterSetName) 
		{
			'CustomObject' 
			{
				If($Columns -eq $null) 
				{
					## Build the available columns from all availble PSCustomObject note properties
					[string[]] $Columns = @();
					## Add each NoteProperty name to the array
					ForEach($Property in ($CustomObject | Get-Member -MemberType NoteProperty)) 
					{ 
						$Columns += $Property.Name; 
					}
				}

				## Add the table headers from -Headers or -Columns (except when in -List(view)
				If(-not $List) 
				{
					Write-Debug ("$(Get-Date -Format G): `t`tBuilding table headers");
					If($Headers -ne $null) 
					{
                        $WordRangeString.AppendFormat("{0}`n", [string]::Join("`t", $Headers));
					}
					Else 
					{ 
                        $WordRangeString.AppendFormat("{0}`n", [string]::Join("`t", $Columns));
					}
				}

				## Iterate through each PSCustomObject
				Write-Debug ("$(Get-Date -Format G): `t`tBuilding table rows");
				ForEach($Object in $CustomObject) 
				{
					$OrderedValues = @();
					## Add each row item in the specified order
					ForEach($Column in $Columns) 
					{ 
						$OrderedValues += $Object.$Column; 
					}
					## Use the ordered list to add each column in specified order
                    $WordRangeString.AppendFormat("{0}`n", [string]::Join("`t", $OrderedValues));
				} ## end ForEach
				Write-Debug ("$(Get-Date -Format G): `t`t`tAdded '{0}' table rows" -f ($CustomObject.Count));
			} ## end CustomObject

			Default 
			{   ## Hashtable
				If($Columns -eq $null) 
				{
					## Build the available columns from all available hashtable keys. Hopefully
					## all Hashtables have the same keys (they should for a table).
					$Columns = $Hashtable[0].Keys;
				}

				## Add the table headers from -Headers or -Columns (except when in -List(view)
				If(-not $List) 
				{
					Write-Debug ("$(Get-Date -Format G): `t`tBuilding table headers");
					If($Headers -ne $null) 
					{ 
                        $WordRangeString.AppendFormat("{0}`n", [string]::Join("`t", $Headers));
					}
					Else 
					{
                        $WordRangeString.AppendFormat("{0}`n", [string]::Join("`t", $Columns));
					}
				}
                
				## Iterate through each Hashtable
				Write-Debug ("$(Get-Date -Format G): `t`tBuilding table rows");
				ForEach($Hash in $Hashtable) 
				{
					$OrderedValues = @();
					## Add each row item in the specified order
					ForEach($Column in $Columns) 
					{ 
						$OrderedValues += $Hash.$Column; 
					}
					## Use the ordered list to add each column in specified order
                    $WordRangeString.AppendFormat("{0}`n", [string]::Join("`t", $OrderedValues));
				} ## end ForEach

				Write-Debug ("$(Get-Date -Format G): `t`t`tAdded '{0}' table rows" -f $Hashtable.Count);
			} ## end default
		} ## end Switch

		## Create a MS Word range and set its text to our tab-delimited, concatenated string
		Write-Debug ("$(Get-Date -Format G): `t`tBuilding table range");
		$WordRange = $Script:Doc.Application.Selection.Range;
		$WordRange.Text = $WordRangeString.ToString();

		## Create hash table of named arguments to pass to the ConvertToTable method
		$ConvertToTableArguments = @{ Separator = [Microsoft.Office.Interop.Word.WdTableFieldSeparator]::wdSeparateByTabs; }

		## Negative built-in styles are not supported by the ConvertToTable method
		If($Format -ge 0) 
		{
			$ConvertToTableArguments.Add("Format", $Format);
			$ConvertToTableArguments.Add("ApplyBorders", $true);
			$ConvertToTableArguments.Add("ApplyShading", $true);
			$ConvertToTableArguments.Add("ApplyFont", $true);
			$ConvertToTableArguments.Add("ApplyColor", $true);
			If(!$List) 
			{ 
				$ConvertToTableArguments.Add("ApplyHeadingRows", $true); 
			}
			$ConvertToTableArguments.Add("ApplyLastRow", $true);
			$ConvertToTableArguments.Add("ApplyFirstColumn", $true);
			$ConvertToTableArguments.Add("ApplyLastColumn", $true);
		}

		## Invoke ConvertToTable method - with named arguments - to convert Word range to a table
		## See http://msdn.microsoft.com/en-us/library/office/aa171893(v=office.11).aspx
		Write-Debug ("$(Get-Date -Format G): `t`tConverting range to table");
		## Store the table reference just in case we need to set alternate row coloring
		$WordTable = $WordRange.GetType().InvokeMember(
			"ConvertToTable",                               # Method name
			[System.Reflection.BindingFlags]::InvokeMethod, # Flags
			$null,                                          # Binder
			$WordRange,                                     # Target (self!)
			([Object[]]($ConvertToTableArguments.Values)),  ## Named argument values
			$null,                                          # Modifiers
			$null,                                          # Culture
			([String[]]($ConvertToTableArguments.Keys))     ## Named argument names
		);

		## Implement grid lines (will wipe out any existing formatting)
		If($Format -lt 0) 
		{
			Write-Debug ("$(Get-Date -Format G): `t`tSetting table format");
			$WordTable.Style = $Format;
		}

		## Set the table autofit behavior
		If($AutoFit -ne -1) 
		{ 
			$WordTable.AutoFitBehavior($AutoFit); 
		}

		#the next line causes the heading row to flow across page breaks
		$WordTable.Rows.First.Headingformat = $wdHeadingFormatTrue;

		If(!$NoGridLines) 
		{
			$WordTable.Borders.InsideLineStyle = $wdLineStyleSingle;
			$WordTable.Borders.OutsideLineStyle = $wdLineStyleSingle;
		}

		Return $WordTable;

	} ## end Process
}

<#
.Synopsis
	Sets the format of one or more Word table cells
.DESCRIPTION
	This Function sets the format of one or more table cells, either from a collection
	of Word COM object cell references, an individual Word COM object cell reference or
	a hashtable containing Row and Column information.

	The font name, font size, bold, italic , underline and shading values can be used.
.EXAMPLE
	SetWordCellFormat -Hashtable $Coordinates -Table $TableReference -Bold

	This example sets all text to bold that is contained within the $TableReference
	Word table, using an array of hashtables. Each hashtable contain a pair of co-
	ordinates that is used to select the required cells. Note: the hashtable must
	contain the .Row and .Column key names. For example:
	@ { Row = 7; Column = 3 } to set the cell at row 7 and column 3 to bold.
.EXAMPLE
	$RowCollection = $Table.Rows.First.Cells
	SetWordCellFormat -Collection $RowCollection -Bold -Size 10

	This example sets all text to size 8 and bold for all cells that are contained
	within the first row of the table.
	Note: the $Table.Rows.First.Cells Returns a collection of Word COM cells objects
	that are in the first table row.
.EXAMPLE
	$ColumnCollection = $Table.Columns.Item(2).Cells
	SetWordCellFormat -Collection $ColumnCollection -BackgroundColor 255

	This example sets the background (shading) of all cells in the table's second
	column to red.
	Note: the $Table.Columns.Item(2).Cells Returns a collection of Word COM cells objects
	that are in the table's second column.
.EXAMPLE
	SetWordCellFormat -Cell $Table.Cell(17,3) -Font "Tahoma" -Color 16711680

	This example sets the font to Tahoma and the text color to blue for the cell located
	in the table's 17th row and 3rd column.
	Note: the $Table.Cell(17,3) Returns a single Word COM cells object.
#>
Function SetWordCellFormat 
{
	[CmdletBinding(DefaultParameterSetName='Collection')]
	Param (
		# Word COM object cell collection reference
		[Parameter(Mandatory=$true, ValueFromPipeline=$true, ParameterSetName='Collection', Position=0)] [ValidateNotNullOrEmpty()] $Collection,
		# Word COM object individual cell reference
		[Parameter(Mandatory=$true, ParameterSetName='Cell', Position=0)] [ValidateNotNullOrEmpty()] $Cell,
		# Hashtable of cell co-ordinates
		[Parameter(Mandatory=$true, ParameterSetName='Hashtable', Position=0)] [ValidateNotNullOrEmpty()] [System.Collections.Hashtable[]] $Coordinates,
		# Word COM object table reference
		[Parameter(Mandatory=$true, ParameterSetName='Hashtable', Position=1)] [ValidateNotNullOrEmpty()] $Table,
		# Font name
		[Parameter()] [AllowNull()] [string] $Font = $null,
		# Font color
		[Parameter()] [AllowNull()] $Color = $null,
		# Font size
		[Parameter()] [ValidateNotNullOrEmpty()] [int] $Size = 0,
		# Cell background color
		[Parameter()] [AllowNull()] [int]$BackgroundColor = $null,
		# Force solid background color
		[Switch] $Solid,
		[Switch] $Bold,
		[Switch] $Italic,
		[Switch] $Underline
	)

	Begin 
	{
		Write-Debug ("Using parameter set '{0}'." -f $PSCmdlet.ParameterSetName);
	}

	Process 
	{
		Switch ($PSCmdlet.ParameterSetName) 
		{
			'Collection' 
			{
				ForEach($Cell in $Collection) 
				{
					If($BackgroundColor -ne $null) { $Cell.Shading.BackgroundPatternColor = $BackgroundColor; }
					If($Bold) { $Cell.Range.Font.Bold = $true; }
					If($Italic) { $Cell.Range.Font.Italic = $true; }
					If($Underline) { $Cell.Range.Font.Underline = 1; }
					If($Font -ne $null) { $Cell.Range.Font.Name = $Font; }
					If($Color -ne $null) { $Cell.Range.Font.Color = $Color; }
					If($Size -ne 0) { $Cell.Range.Font.Size = $Size; }
					If($Solid) { $Cell.Shading.Texture = 0; } ## wdTextureNone
				} # end ForEach
			} # end Collection
			'Cell' 
			{
				If($Bold) { $Cell.Range.Font.Bold = $true; }
				If($Italic) { $Cell.Range.Font.Italic = $true; }
				If($Underline) { $Cell.Range.Font.Underline = 1; }
				If($Font -ne $null) { $Cell.Range.Font.Name = $Font; }
				If($Color -ne $null) { $Cell.Range.Font.Color = $Color; }
				If($Size -ne 0) { $Cell.Range.Font.Size = $Size; }
				If($BackgroundColor -ne $null) { $Cell.Shading.BackgroundPatternColor = $BackgroundColor; }
				If($Solid) { $Cell.Shading.Texture = 0; } ## wdTextureNone
			} # end Cell
			'Hashtable' 
			{
				ForEach($Coordinate in $Coordinates) 
				{
					$Cell = $Table.Cell($Coordinate.Row, $Coordinate.Column);
					If($Bold) { $Cell.Range.Font.Bold = $true; }
					If($Italic) { $Cell.Range.Font.Italic = $true; }
					If($Underline) { $Cell.Range.Font.Underline = 1; }
					If($Font -ne $null) { $Cell.Range.Font.Name = $Font; }
					If($Color -ne $null) { $Cell.Range.Font.Color = $Color; }
					If($Size -ne 0) { $Cell.Range.Font.Size = $Size; }
					If($BackgroundColor -ne $null) { $Cell.Shading.BackgroundPatternColor = $BackgroundColor; }
					If($Solid) { $Cell.Shading.Texture = 0; } ## wdTextureNone
				}
			} # end Hashtable
		} # end Switch
	} # end process
}

<#
.Synopsis
	Sets alternate row colors in a Word table
.DESCRIPTION
	This Function sets the format of alternate rows within a Word table using the
	specified $BackgroundColor. This Function is expensive (in performance terms) as
	it recursively sets the format on alternate rows. It would be better to pick one
	of the predefined table formats (if one exists)? Obviously the more rows, the
	longer it takes :'(

	Note: this Function is called by the AddWordTable Function if an alternate row
	format is specified.
.EXAMPLE
	SetWordTableAlternateRowColor -Table $TableReference -BackgroundColor 255

	This example sets every-other table (starting with the first) row and sets the
	background color to red (wdColorRed).
.EXAMPLE
	SetWordTableAlternateRowColor -Table $TableReference -BackgroundColor 39423 -Seed Second

	This example sets every other table (starting with the second) row and sets the
	background color to light orange (weColorLightOrange).
#>
Function SetWordTableAlternateRowColor 
{
	[CmdletBinding()]
	Param (
		# Word COM object table reference
		[Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)] [ValidateNotNullOrEmpty()] $Table,
		# Alternate row background color
		[Parameter(Mandatory=$true, Position=1)] [ValidateNotNull()] [int] $BackgroundColor,
		# Alternate row starting seed
		[Parameter(ValueFromPipelineByPropertyName=$true, Position=2)] [ValidateSet('First','Second')] [string] $Seed = 'First'
	)

	Process 
	{
		$StartDateTime = Get-Date;
		Write-Debug ("{0}: `t`tSetting alternate table row colors.." -f $StartDateTime);

		## Determine the row seed (only really need to check for 'Second' and default to 'First' otherwise
		If($Seed.ToLower() -eq 'second') 
		{ 
			$StartRowIndex = 2; 
		}
		Else 
		{ 
			$StartRowIndex = 1; 
		}

		For($AlternateRowIndex = $StartRowIndex; $AlternateRowIndex -lt $Table.Rows.Count; $AlternateRowIndex += 2) 
		{ 
			$Table.Rows.Item($AlternateRowIndex).Shading.BackgroundPatternColor = $BackgroundColor;
		}

		## I've put verbose calls in here we can see how expensive this Functionality actually is.
		$EndDateTime = Get-Date;
		$ExecutionTime = New-TimeSpan -Start $StartDateTime -End $EndDateTime;
		Write-Debug ("{0}: `t`tDone setting alternate row style color in '{1}' seconds" -f $EndDateTime, $ExecutionTime.TotalSeconds);
	}
}

Function ShowScriptOptions
{
	Write-Verbose "$(Get-Date -Format G): "
	Write-Verbose "$(Get-Date -Format G): "
	Write-Verbose "$(Get-Date -Format G): Add DateTime       : $($AddDateTime)"
	Write-Verbose "$(Get-Date -Format G): All                : $($All)"
	If($MSWORD -or $PDF)
	{
		Write-Verbose "$(Get-Date -Format G): Company Name       : $($Script:CoName)"
	}
	Write-Verbose "$(Get-Date -Format G): Computers          : $($Computers)"
	If($MSWORD -or $PDF)
	{
		Write-Verbose "$(Get-Date -Format G): Company Address    : $CompanyAddress"
		Write-Verbose "$(Get-Date -Format G): Company Email      : $CompanyEmail"
		Write-Verbose "$(Get-Date -Format G): Company Fax        : $CompanyFax"
		Write-Verbose "$(Get-Date -Format G): Company Name       : $Script:CoName"
		Write-Verbose "$(Get-Date -Format G): Company Phone      : $CompanyPhone"
		Write-Verbose "$(Get-Date -Format G): Cover Page         : $CoverPage"
	}
	Write-Verbose "$(Get-Date -Format G): Dev                : $($Dev)"
	If($Dev)
	{
		Write-Verbose "$(Get-Date -Format G): DevErrorFile       : $($Script:DevErrorFile)"
	}
	Write-Verbose "$(Get-Date -Format G): Filename1          : $($Script:FileName1)"
	If($PDF)
	{
		Write-Verbose "$(Get-Date -Format G): Filename2          : $($Script:FileName2)"
	}
	Write-Verbose "$(Get-Date -Format G): Folder             : $($Folder)"
	Write-Verbose "$(Get-Date -Format G): From               : $($From)"
	Write-Verbose "$(Get-Date -Format G): Groups             : $($Groups)"
	Write-Verbose "$(Get-Date -Format G): Log                : $($Log)"
	Write-Verbose "$(Get-Date -Format G): Mgmt               : $($Mgmt)"
	Write-Verbose "$(Get-Date -Format G): Organisational Unit: $($OrganisationalUnit)"
	Write-Verbose "$(Get-Date -Format G): Save As PDF        : $($PDF)"
	Write-Verbose "$(Get-Date -Format G): Save As WORD       : $($MSWORD)"
	Write-Verbose "$(Get-Date -Format G): Script Info        : $($ScriptInfo)"
	Write-Verbose "$(Get-Date -Format G): Sites              : $($Sites)"
	Write-Verbose "$(Get-Date -Format G): Smtp Port          : $($SmtpPort)"
	Write-Verbose "$(Get-Date -Format G): Smtp Server        : $($SmtpServer)"
	Write-Verbose "$(Get-Date -Format G): To                 : $($To)"
	If($MSWORD -or $PDF)
	{
		Write-Verbose "$(Get-Date -Format G): User Name          : $($UserName)"
	}
	Write-Verbose "$(Get-Date -Format G): Users              : $($Users)"
	Write-Verbose "$(Get-Date -Format G): Use SSL            : $($UseSSL)"
	Write-Verbose "$(Get-Date -Format G): "
	Write-Verbose "$(Get-Date -Format G): OS Detected        : $($Script:RunningOS)"
	Write-Verbose "$(Get-Date -Format G): PoSH version       : $($Host.Version)"
	Write-Verbose "$(Get-Date -Format G): PSCulture          : $($PSCulture)"
	Write-Verbose "$(Get-Date -Format G): PSUICulture        : $($PSUICulture)"
	If($MSWORD -or $PDF)
	{
		Write-Verbose "$(Get-Date -Format G): Word language      : $($Script:WordLanguageValue)"
		Write-Verbose "$(Get-Date -Format G): Word version       : $($Script:WordProduct)"
	}
	Write-Verbose "$(Get-Date -Format G): "
	Write-Verbose "$(Get-Date -Format G): Script start       : $($Script:StartTime)"
	Write-Verbose "$(Get-Date -Format G): "
	Write-Verbose "$(Get-Date -Format G): "
}

Function validStateProp
{
	Param(
		[object] $object,
		[string] $topLevel,
		[string] $secondLevel 
	)

	#Function created 8-jan-2014 by Michael B. Smith
	If( $object )
	{
		If( ( Get-Member -Name $topLevel -InputObject $object ) )
		{
			If( ( Get-Member -Name $secondLevel -InputObject $object.$topLevel ) )
			{
				Return $True
			}
		}
	}
	Return $False
}

Function SetupWord
{
	Write-Verbose "$(Get-Date -Format G): Setting up Word"
    
	If(!$AddDateTime)
	{
		[string]$Script:WordFileName = "$($Script:pwdpath)\$($OutputFileName).docx"
		If($PDF)
		{
			[string]$Script:PDFFileName = "$($Script:pwdpath)\$($OutputFileName).pdf"
		}
	}
	ElseIf($AddDateTime)
	{
		[string]$Script:WordFileName = "$($Script:pwdpath)\$($OutputFileName)_$(Get-Date -f yyyy-MM-dd_HHmm).docx"
		If($PDF)
		{
			[string]$Script:PDFFileName = "$($Script:pwdpath)\$($OutputFileName)_$(Get-Date -f yyyy-MM-dd_HHmm).pdf"
		}
	}

	# Setup word for output
	Write-Verbose "$(Get-Date -Format G): Create Word comObject."
	$Script:Word = New-Object -comobject "Word.Application" -EA 0 4>$Null

#Do not indent the following write-error lines. Doing so will mess up the console formatting of the error message.
	If(!$? -or $Null -eq $Script:Word)
	{
		Write-Warning "The Word object could not be created. You may need to repair your Word installation."
		$ErrorActionPreference = $SaveEAPreference
		Write-Error "
		`n`n
	The Word object could not be created. You may need to repair your Word installation.
		`n`n
	Script cannot Continue.
		`n`n"
		AbortScript
	}

	Write-Verbose "$(Get-Date -Format G): Determine Word language value"
	If( ( validStateProp $Script:Word Language Value__ ) )
	{
		[int]$Script:WordLanguageValue = [int]$Script:Word.Language.Value__
	}
	Else
	{
		[int]$Script:WordLanguageValue = [int]$Script:Word.Language
	}

	If(!($Script:WordLanguageValue -gt -1))
	{
		$ErrorActionPreference = $SaveEAPreference
		Write-Error "
		`n`n
	Unable to determine the Word language value. You may need to repair your Word installation.
		`n`n
	Script cannot Continue.
		`n`n
		"
		AbortScript
	}
	Write-Verbose "$(Get-Date -Format G): Word language value is $($Script:WordLanguageValue)"
	
	$Script:WordCultureCode = GetCulture $Script:WordLanguageValue
	
	SetWordHashTable $Script:WordCultureCode
	
	[int]$Script:WordVersion = [int]$Script:Word.Version
	If($Script:WordVersion -eq $wdWord2016)
	{
		$Script:WordProduct = "Word 2016"
	}
	ElseIf($Script:WordVersion -eq $wdWord2013)
	{
		$Script:WordProduct = "Word 2013"
	}
	ElseIf($Script:WordVersion -eq $wdWord2010)
	{
		$Script:WordProduct = "Word 2010"
	}
	ElseIf($Script:WordVersion -eq $wdWord2007)
	{
		$ErrorActionPreference = $SaveEAPreference
		Write-Error "
		`n`n
	Microsoft Word 2007 is no longer supported.`n`n`t`tScript will end.
		`n`n
		"
		AbortScript
	}
	ElseIf($Script:WordVersion -eq 0)
	{
		Write-Error "
		`n`n
	The Word Version is 0. You should run a full online repair of your Office installation.
		`n`n
	Script cannot Continue.
		`n`n
		"
		AbortScript
	}
	Else
	{
		$ErrorActionPreference = $SaveEAPreference
		Write-Error "
		`n`n
	You are running an untested or unsupported version of Microsoft Word.
		`n`n
	Script will end.
		`n`n
	Please send info on your version of Word to webster@carlwebster.com
		`n`n
		"
		AbortScript
	}

	#only validate CompanyName if the field is blank
	If([String]::IsNullOrEmpty($CompanyName))
	{
		Write-Verbose "$(Get-Date -Format G): Company name is blank. Retrieve company name from registry."
		$TmpName = ValidateCompanyName
		
		If([String]::IsNullOrEmpty($TmpName))
		{
			Write-Host "
		Company Name is blank so Cover Page will not show a Company Name.
		Check HKCU:\Software\Microsoft\Office\Common\UserInfo for Company or CompanyName value.
		You may want to use the -CompanyName parameter if you need a Company Name on the cover page.
			" -ForegroundColor White
			$Script:CoName = $TmpName
		}
		Else
		{
			$Script:CoName = $TmpName
			Write-Verbose "$(Get-Date -Format G): Updated company name to $($Script:CoName)"
		}
	}
	Else
	{
		$Script:CoName = $CompanyName
	}

	If($Script:WordCultureCode -ne "en-")
	{
		Write-Verbose "$(Get-Date -Format G): Check Default Cover Page for $($WordCultureCode)"
		[bool]$CPChanged = $False
		Switch ($Script:WordCultureCode)
		{
			'ca-'	{
					If($CoverPage -eq "Sideline")
					{
						$CoverPage = "Línia lateral"
						$CPChanged = $True
					}
				}

			'da-'	{
					If($CoverPage -eq "Sideline")
					{
						$CoverPage = "Sidelinje"
						$CPChanged = $True
					}
				}

			'de-'	{
					If($CoverPage -eq "Sideline")
					{
						$CoverPage = "Randlinie"
						$CPChanged = $True
					}
				}

			'es-'	{
					If($CoverPage -eq "Sideline")
					{
						$CoverPage = "Línea lateral"
						$CPChanged = $True
					}
				}

			'fi-'	{
					If($CoverPage -eq "Sideline")
					{
						$CoverPage = "Sivussa"
						$CPChanged = $True
					}
				}

			'fr-'	{
					If($CoverPage -eq "Sideline")
					{
						If($Script:WordVersion -eq $wdWord2013 -or $Script:WordVersion -eq $wdWord2016)
						{
							$CoverPage = "Lignes latérales"
							$CPChanged = $True
						}
						Else
						{
							$CoverPage = "Ligne latérale"
							$CPChanged = $True
						}
					}
				}

			'nb-'	{
					If($CoverPage -eq "Sideline")
					{
						$CoverPage = "Sidelinje"
						$CPChanged = $True
					}
				}

			'nl-'	{
					If($CoverPage -eq "Sideline")
					{
						$CoverPage = "Terzijde"
						$CPChanged = $True
					}
				}

			'pt-'	{
					If($CoverPage -eq "Sideline")
					{
						$CoverPage = "Linha Lateral"
						$CPChanged = $True
					}
				}

			'sv-'	{
					If($CoverPage -eq "Sideline")
					{
						$CoverPage = "Sidlinje"
						$CPChanged = $True
					}
				}

			'zh-'	{
					If($CoverPage -eq "Sideline")
					{
						$CoverPage = "边线型"
						$CPChanged = $True
					}
				}
		}

		If($CPChanged)
		{
			Write-Verbose "$(Get-Date -Format G): Changed Default Cover Page from Sideline to $($CoverPage)"
		}
	}

	Write-Verbose "$(Get-Date -Format G): Validate cover page $($CoverPage) for culture code $($Script:WordCultureCode)"
	[bool]$ValidCP = $False
	
	$ValidCP = ValidateCoverPage $Script:WordVersion $CoverPage $Script:WordCultureCode
	
	If(!$ValidCP)
	{
		$ErrorActionPreference = $SaveEAPreference
		Write-Verbose "$(Get-Date -Format G): Word language value $($Script:WordLanguageValue)"
		Write-Verbose "$(Get-Date -Format G): Culture code $($Script:WordCultureCode)"
		Write-Error "
		`n`n
	For $($Script:WordProduct), $($CoverPage) is not a valid Cover Page option.
		`n`n
	Script cannot Continue.
		`n`n
		"
		AbortScript
	}

	$Script:Word.Visible = $False

	#http://jdhitsolutions.com/blog/2012/05/san-diego-2012-powershell-deep-dive-slides-and-demos/
	#using Jeff's Demo-WordReport.ps1 file for examples
	Write-Verbose "$(Get-Date -Format G): Load Word Templates"

	[bool]$Script:CoverPagesExist = $False
	[bool]$BuildingBlocksExist = $False

	$Script:Word.Templates.LoadBuildingBlocks()
	#word 2010/2013/2016
	$BuildingBlocksCollection = $Script:Word.Templates | Where-Object{$_.name -eq "Built-In Building Blocks.dotx"}

	Write-Verbose "$(Get-Date -Format G): Attempt to load cover page $($CoverPage)"
	$part = $Null

	$BuildingBlocksCollection | 
	ForEach-Object {
		If($_.BuildingBlockEntries.Item($CoverPage).Name -eq $CoverPage) 
		{
			$BuildingBlocks = $_
		}
	}        

	If($Null -ne $BuildingBlocks)
	{
		$BuildingBlocksExist = $True

		Try 
		{
			$part = $BuildingBlocks.BuildingBlockEntries.Item($CoverPage)
		}

		Catch
		{
			$part = $Null
		}

		If($Null -ne $part)
		{
			$Script:CoverPagesExist = $True
		}
	}

	If(!$Script:CoverPagesExist)
	{
		Write-Verbose "$(Get-Date -Format G): Cover Pages are not installed or the Cover Page $($CoverPage) does not exist."
		Write-Host "Cover Pages are not installed or the Cover Page $($CoverPage) does not exist." -ForegroundColor White
		Write-Host "This report will not have a Cover Page." -ForegroundColor White
	}

	Write-Verbose "$(Get-Date -Format G): Create empty word doc"
	$Script:Doc = $Script:Word.Documents.Add()
	If($Null -eq $Script:Doc)
	{
		Write-Verbose "$(Get-Date -Format G): "
		$ErrorActionPreference = $SaveEAPreference
		Write-Error "
		`n`n
	An empty Word document could not be created. You may need to repair your Word installation.
		`n`n
	Script cannot Continue.
		`n`n"
		AbortScript
	}

	$Script:Selection = $Script:Word.Selection
	If($Null -eq $Script:Selection)
	{
		Write-Verbose "$(Get-Date -Format G): "
		$ErrorActionPreference = $SaveEAPreference
		Write-Error "
		`n`n
	An unknown error happened selecting the entire Word document for default formatting options.
		`n`n
	Script cannot Continue.
		`n`n"
		AbortScript
	}

	#set Default tab stops to 1/2 inch (this line is not from Jeff Hicks)
	#36 =.50"
	$Script:Word.ActiveDocument.DefaultTabStop = 36

	#Disable Spell and Grammar Check to resolve issue and improve performance (from Pat Coughlin)
	Write-Verbose "$(Get-Date -Format G): Disable grammar and spell checking"
	#bug reported 1-Apr-2014 by Tim Mangan
	#save current options first before turning them off
	$Script:CurrentGrammarOption = $Script:Word.Options.CheckGrammarAsYouType
	$Script:CurrentSpellingOption = $Script:Word.Options.CheckSpellingAsYouType
	$Script:Word.Options.CheckGrammarAsYouType = $False
	$Script:Word.Options.CheckSpellingAsYouType = $False

	If($BuildingBlocksExist)
	{
		#insert new page, getting ready for table of contents
		Write-Verbose "$(Get-Date -Format G): Insert new page, getting ready for table of contents"
		$part.Insert($Script:Selection.Range,$True) | Out-Null
		$Script:Selection.InsertNewPage()

		#table of contents
		Write-Verbose "$(Get-Date -Format G): Table of Contents - $($Script:MyHash.Word_TableOfContents)"
		$toc = $BuildingBlocks.BuildingBlockEntries.Item($Script:MyHash.Word_TableOfContents)
		If($Null -eq $toc)
		{
			Write-Verbose "$(Get-Date -Format G): "
			Write-Host "Table of Content - $($Script:MyHash.Word_TableOfContents) could not be retrieved." -ForegroundColor White
			Write-Host "This report will not have a Table of Contents." -ForegroundColor White
		}
		Else
		{
			$toc.insert($Script:Selection.Range,$True) | Out-Null
		}
	}
	Else
	{
		Write-Host "Table of Contents are not installed." -ForegroundColor White
		Write-Host "Table of Contents are not installed so this report will not have a Table of Contents." -ForegroundColor White
	}

	#set the footer
	Write-Verbose "$(Get-Date -Format G): Set the footer"
	[string]$footertext = "Report created by $username"

	#get the footer
	Write-Verbose "$(Get-Date -Format G): Get the footer and format font"
	$Script:Doc.ActiveWindow.ActivePane.view.SeekView = $wdSeekPrimaryFooter
	#get the footer and format font
	$footers = $Script:Doc.Sections.Last.Footers
	ForEach($footer in $footers) 
	{
		If($footer.exists) 
		{
			$footer.range.Font.name = "Calibri"
			$footer.range.Font.size = 8
			$footer.range.Font.Italic = $True
			$footer.range.Font.Bold = $True
		}
	} #end ForEach
	Write-Verbose "$(Get-Date -Format G): Footer text"
	$Script:Selection.HeaderFooter.Range.Text = $footerText

	#add page numbering
	Write-Verbose "$(Get-Date -Format G): Add page numbering"
	$Script:Selection.HeaderFooter.PageNumbers.Add($wdAlignPageNumberRight) | Out-Null

	FindWordDocumentEnd
	#end of Jeff Hicks 
}

Function UpdateDocumentProperties
{
	Param([string]$AbstractTitle, [string]$SubjectTitle)
	#updated 8-Jun-2017 with additional cover page fields
	#Update document properties
	If($MSWORD -or $PDF)
	{
		If($Script:CoverPagesExist)
		{
			Write-Verbose "$(Get-Date -Format G): Set Cover Page Properties"
			#8-Jun-2017 put these 4 items in alpha order
            Set-DocumentProperty -Document $Script:Doc -DocProperty Author -Value $UserName
            Set-DocumentProperty -Document $Script:Doc -DocProperty Company -Value $Script:CoName
            Set-DocumentProperty -Document $Script:Doc -DocProperty Subject -Value $SubjectTitle
            Set-DocumentProperty -Document $Script:Doc -DocProperty Title -Value $Script:title

			#Get the Coverpage XML part
			$cp = $Script:Doc.CustomXMLParts | Where-Object {$_.NamespaceURI -match "coverPageProps$"}

			#get the abstract XML part
			$ab = $cp.documentelement.ChildNodes | Where-Object {$_.basename -eq "Abstract"}
			#set the text
			If([String]::IsNullOrEmpty($Script:CoName))
			{
				[string]$abstract = $AbstractTitle
			}
			Else
			{
				[string]$abstract = "$($AbstractTitle) for $($Script:CoName)"
			}
			$ab.Text = $abstract

			#added 8-Jun-2017
			$ab = $cp.documentelement.ChildNodes | Where-Object {$_.basename -eq "CompanyAddress"}
			#set the text
			[string]$abstract = $CompanyAddress
			$ab.Text = $abstract

			#added 8-Jun-2017
			$ab = $cp.documentelement.ChildNodes | Where-Object {$_.basename -eq "CompanyEmail"}
			#set the text
			[string]$abstract = $CompanyEmail
			$ab.Text = $abstract

			#added 8-Jun-2017
			$ab = $cp.documentelement.ChildNodes | Where-Object {$_.basename -eq "CompanyFax"}
			#set the text
			[string]$abstract = $CompanyFax
			$ab.Text = $abstract

			#added 8-Jun-2017
			$ab = $cp.documentelement.ChildNodes | Where-Object {$_.basename -eq "CompanyPhone"}
			#set the text
			[string]$abstract = $CompanyPhone
			$ab.Text = $abstract

			$ab = $cp.documentelement.ChildNodes | Where-Object {$_.basename -eq "PublishDate"}
			#set the text
			[string]$abstract = (Get-Date -Format d).ToString()
			$ab.Text = $abstract

			Write-Verbose "$(Get-Date -Format G): Update the Table of Contents"
			#update the Table of Contents
			$Script:Doc.TablesOfContents.item(1).Update()
			$cp = $Null
			$ab = $Null
			$abstract = $Null
		}
	}
}

Function SaveandCloseDocumentandShutdownWord
{
	#bug fix 1-Apr-2014
	#reset Grammar and Spelling options back to their original settings
	$Script:Word.Options.CheckGrammarAsYouType = $Script:CurrentGrammarOption
	$Script:Word.Options.CheckSpellingAsYouType = $Script:CurrentSpellingOption

	Write-Verbose "$(Get-Date -Format G): Save and Close document and Shutdown Word"
	If($Script:WordVersion -eq $wdWord2010)
	{
		#the $saveFormat below passes StrictMode 2
		#I found this at the following two links
		#http://msdn.microsoft.com/en-us/library/microsoft.office.interop.word.wdsaveformat(v=office.14).aspx
		If($PDF)
		{
			Write-Verbose "$(Get-Date -Format G): Saving as DOCX file first before saving to PDF"
		}
		Else
		{
			Write-Verbose "$(Get-Date -Format G): Saving DOCX file"
		}
		Write-Verbose "$(Get-Date -Format G): Running $($Script:WordProduct) and detected operating system $($Script:RunningOS)"
		$saveFormat = [Enum]::Parse([Microsoft.Office.Interop.Word.WdSaveFormat], "wdFormatDocumentDefault")
		$Script:Doc.SaveAs([REF]$Script:WordFileName, [ref]$SaveFormat)
		If($PDF)
		{
			Write-Verbose "$(Get-Date -Format G): Now saving as PDF"
			$saveFormat = [Enum]::Parse([Microsoft.Office.Interop.Word.WdSaveFormat], "wdFormatPDF")
			$Script:Doc.SaveAs([REF]$Script:PDFFileName, [ref]$saveFormat)
		}
	}
	ElseIf($Script:WordVersion -eq $wdWord2013 -or $Script:WordVersion -eq $wdWord2016)
	{
		If($PDF)
		{
			Write-Verbose "$(Get-Date -Format G): Saving as DOCX file first before saving to PDF"
		}
		Else
		{
			Write-Verbose "$(Get-Date -Format G): Saving DOCX file"
		}
		Write-Verbose "$(Get-Date -Format G): Running $($Script:WordProduct) and detected operating system $($Script:RunningOS)"
		$Script:Doc.SaveAs2([REF]$Script:WordFileName, [ref]$wdFormatDocumentDefault)
		If($PDF)
		{
			Write-Verbose "$(Get-Date -Format G): Now saving as PDF"
			$Script:Doc.SaveAs([REF]$Script:PDFFileName, [ref]$wdFormatPDF)
		}
	}

	Write-Verbose "$(Get-Date -Format G): Closing Word"
	$Script:Doc.Close()
	$Script:Word.Quit()
	Write-Verbose "$(Get-Date -Format G): System Cleanup"
	[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Script:Word) | Out-Null
	If(Test-Path variable:global:word)
	{
		Remove-Variable -Name word -Scope Global 4>$Null
	}
	$SaveFormat = $Null
	[gc]::collect() 
	[gc]::WaitForPendingFinalizers()
	
	#is the winword Process still running? kill it

	#find out our session (usually "1" except on TS/RDC or Citrix)
	$SessionID = (Get-Process -PID $PID).SessionId

	#Find out if winword running in our session
	$wordprocess = ((Get-Process 'WinWord' -ea 0) | Where-Object {$_.SessionId -eq $SessionID}) | Select-Object -Property Id 
	If( $wordprocess -and $wordprocess.Id -gt 0)
	{
		Write-Verbose "$(Get-Date -Format G): WinWord Process is still running. Attempting to stop WinWord Process # $($wordprocess.Id)"
		Stop-Process $wordprocess.Id -EA 0
	}
}

Function SetFileName1andFileName2
{
	Param(
		[string] $OutputFileName
	)

	#set $filename1 and $filename2 with no file extension
	If($AddDateTime)
	{
		[string] $Script:FileName1 = "$($Script:pwdpath)\$($OutputFileName)_$(Get-Date -f yyyy-MM-dd_HHmm).docx"
		If($PDF)
		{
			[string] $Script:FileName2 = "$($Script:pwdpath)\$($OutputFileName)_$(Get-Date -f yyyy-MM-dd_HHmm).pdf"
		}
	}

	If($MSWord -or $PDF)
	{
		CheckWordPreReq

		If(!$AddDateTime)
		{
			[string] $Script:FileName1 = "$($Script:pwdpath)\$($OutputFileName).docx"
			If($PDF)
			{
				[string] $Script:FileName2 = "$($Script:pwdpath)\$($OutputFileName).pdf"
			}
		}

		SetupWord
		ShowScriptOptions
	}
}

#region email function
Function SendEmail
{
	Param([string]$Attachments)
	Write-Verbose "$(Get-Date -Format G): Prepare to email"

	$emailAttachment = $Attachments
	$emailSubject = $Script:Title
	$emailBody = @"
Hello, <br />
<br />
$Script:Title is attached.

"@ 

	If($Dev)
	{
		Out-File -FilePath $Script:DevErrorFile -InputObject $error 4>$Null
	}

	$error.Clear()
	
	If($From -Like "anonymous@*")
	{
		#https://serverfault.com/questions/543052/sending-unauthenticated-mail-through-ms-exchange-with-powershell-windows-server
		$anonUsername = "anonymous"
		$anonPassword = ConvertTo-SecureString -String "anonymous" -AsPlainText -Force
		$anonCredentials = New-Object System.Management.Automation.PSCredential($anonUsername,$anonPassword)

		If($UseSSL)
		{
			Send-MailMessage -Attachments $emailAttachment -Body $emailBody -BodyAsHtml -From $From `
			-Port $SmtpPort -SmtpServer $SmtpServer -Subject $emailSubject -To $To `
			-UseSSL -credential $anonCredentials *>$Null 
		}
		Else
		{
			Send-MailMessage -Attachments $emailAttachment -Body $emailBody -BodyAsHtml -From $From `
			-Port $SmtpPort -SmtpServer $SmtpServer -Subject $emailSubject -To $To `
			-credential $anonCredentials *>$Null 
		}
		
		If($?)
		{
			Write-Verbose "$(Get-Date -Format G): Email successfully sent using anonymous credentials"
		}
		ElseIf(!$?)
		{
			$e = $error[0]

			Write-Verbose "$(Get-Date -Format G): Email was not sent:"
			Write-Warning "$(Get-Date -Format G): Exception: $e.Exception" 
		}
	}
	Else
	{
		If($UseSSL)
		{
			Write-Verbose "$(Get-Date -Format G): Trying to send an email using current user's credentials with SSL"
			Send-MailMessage -Attachments $emailAttachment -Body $emailBody -BodyAsHtml -From $From `
			-Port $SmtpPort -SmtpServer $SmtpServer -Subject $emailSubject -To $To `
			-UseSSL *>$Null
		}
		Else
		{
			Write-Verbose  "$(Get-Date -Format G): Trying to send an email using current user's credentials without SSL"
			Send-MailMessage -Attachments $emailAttachment -Body $emailBody -BodyAsHtml -From $From `
			-Port $SmtpPort -SmtpServer $SmtpServer -Subject $emailSubject -To $To *>$Null
		}

		If(!$?)
		{
			$e = $error[0]
			
			#error 5.7.57 is O365 and error 5.7.0 is gmail
			If($null -ne $e.Exception -and $e.Exception.ToString().Contains("5.7"))
			{
				#The server response was: 5.7.xx SMTP; Client was not authenticated to send anonymous mail during MAIL FROM
				Write-Verbose "$(Get-Date -Format G): Current user's credentials failed. Ask for usable credentials."

				If($Dev)
				{
					Out-File -FilePath $Script:DevErrorFile -InputObject $error -Append 4>$Null
				}

				$error.Clear()

				$emailCredentials = Get-Credential -UserName $From -Message "Enter the password to send email"

				If($UseSSL)
				{
					Send-MailMessage -Attachments $emailAttachment -Body $emailBody -BodyAsHtml -From $From `
					-Port $SmtpPort -SmtpServer $SmtpServer -Subject $emailSubject -To $To `
					-UseSSL -credential $emailCredentials *>$Null 
				}
				Else
				{
					Send-MailMessage -Attachments $emailAttachment -Body $emailBody -BodyAsHtml -From $From `
					-Port $SmtpPort -SmtpServer $SmtpServer -Subject $emailSubject -To $To `
					-credential $emailCredentials *>$Null 
				}

				If($?)
				{
					Write-Verbose "$(Get-Date -Format G): Email successfully sent using new credentials"
				}
				ElseIf(!$?)
				{
					$e = $error[0]

					Write-Verbose "$(Get-Date -Format G): Email was not sent:"
					Write-Warning "$(Get-Date -Format G): Exception: $e.Exception" 
				}
			}
			Else
			{
				Write-Verbose "$(Get-Date -Format G): Email was not sent:"
				Write-Warning "$(Get-Date -Format G): Exception: $e.Exception" 
			}
		}
	}
}
#endregion

#Script begins

$script:startTime = Get-Date

#The Function SetFileName1andFileName2 needs your script output filename
SetFileName1andFileName2 "ADHealthCheck"

#change title for your report
[string]$Script:Title = "Active Directory Health Check"

###REPLACE AFTER THIS SECTION WITH YOUR SCRIPT###

Function Split-IntoGroups 
{
    # Written by 'The Masked Avenger with the Cheetos'
    [CmdletBinding()]
    param (
        [parameter(mandatory=$true,position=0,valuefrompipeline=$true)][Object[]]$InputObject,
        [parameter(mandatory=$false,position=1)][ValidateRange(1, ([int]::MaxValue))][int]$Number=10000
    )

    begin 
	{
        $currentGroup = New-Object System.Collections.ArrayList($Number)
    } 
	process 
	{
        ForEach($object in $InputObject) {
            $index = $currentGroup.Add($object)
            If($index -ge $Number - 1) {
                ,$currentGroup.ToArray()
                $currentGroup.Clear()
            }
        }
    } 
	end 
	{
        If($currentGroup.Count -gt 0) {
            ,$currentGroup.ToArray()
        }
    }
}

Function Add-CheckListResults 
{
    [CmdletBinding()]
    Param(
        [Parameter()]
		$Name,
		
        [Parameter()]
		$Count
    )

    $Object = New-Object -TypeName PSObject
    $Object | Add-Member -MemberType NoteProperty -Name 'Check' -value $Name
    $Object | Add-Member -MemberType NoteProperty -Name 'Results' -value $Count
    $Object
}

$global:someCallers = 0

Function Write-ToCSV 
{
	[CmdletBinding()]
	Param(
		[Parameter( Mandatory = $true,  Position = 0, ValuefromPipeline = $true )]
		$Content,
		
		[Parameter( Mandatory = $true,  Position = 1 )]
		[string] $Name,
		
		[Parameter( Mandatory = $false, Position = 2 )]
		[string] $Path = $Script:ThisScriptPath
	)

	$global:someCallers++
	If( $null -eq $Content )
	{
		Write-Debug "***Write-ToCSV: Content is empty, for call count $($global:someCallers)"
		Return
	}

    ## This code makes some assumptions (which were true at the time that
    ## the code was written):
    ## 1. All entries in $Content are the same type of PSObject.
    ## 2. Each entry in $Content is a PSObject.
    ## 3. $Content contains at least one entry.
    ## 4. PowerShell version 3 or higher.
    ## 5. Each PSObject property value is represented in the PSObject
    ##    by a string or integer.
    ## 6. No property values contain a double quote ('"').
    ## MBS - 3-May-16

    $sample = $null
	$count  = 0
    If( $Content -is [Array] )
    {
        $sample = $Content[ 0 ]
		$count  = $Content.Count
    }
    Else 
    {
        $sample = $Content
		$count  = 1
    }
 
	Write-Debug "***Write-ToCSV: content count $count, call count $($global:someCallers), content type $($content.GetType().Fullname)"
 
    $output  = @()
    $headers = ''
    
    $properties = $sample.PSObject.Properties
    ForEach( $property in $properties )
    {
        $headers += '"' + $property.Name + '"' + ','
    }

    $output += $headers.SubString( 0, $headers.Length - 1 )
    
    ForEach( $item in $Content )
    {
        $properties = $item.PSObject.Properties
        $line = ''
        ForEach( $property in $properties )
        {
            $line += '"' + "$($property.Value)" + '"' + ','
        }
        $output += $line.SubString( 0, $line.Length - 1 )
    }
    
    ## $filename = Join-Path "." ( $i.ToString() + '.csv' )
	$filename = Join-Path $Path ( $Name + '.csv' )
    $output | Out-File $filename -Force -Encoding ascii 4>$Null
} 

Function Write-ToWord 
{
    [CmdletBinding()]
    Param(
        [Parameter( Mandatory = $true, Position = 0)]
		$TableContent,
		
        [Parameter( Mandatory = $true, Position = 1)]
		[string]$Name
    )

    Write-Debug "$(Get-Date -Format G):      Writing '$Name' to Word"
    WriteWordLine -Style 3 -Tabs 0 -Name $Name
    FindWordDocumentEnd
    $TableContent | Split-IntoGroups | ForEach-Object {
        AddWordTable -CustomObject ($TableContent) | Out-Null
        FindWordDocumentEnd
        WriteWordLine -Style 0 -Tabs 0 -Name ''
    }
    WriteWordLine -Style 0 -Tabs 0 -Name ''
}

Function ConvertTo-FQDN
{
	Param (
		[Parameter( Mandatory = $true )]
		[string] $DomainFQDN
	)

	$result = "DC=" + $DomainFQDN.Replace( ".", ",DC=" )
	Write-Debug "***ConvertTo-FQDN DomainFQDN='$DomainFQDN', result='$result'"
	Return $result
}

Function Get-Domains
{
	( [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest() ).Domains
}

Function Get-ADDomains
{
	$Domains = Get-Domains
	ForEach($Domain in $Domains) 
	{
		$DomainName = $Domain.Name
		$DomainFQDN = ConvertTo-FQDN $DomainName
		
		$ADObject   = [ADSI]"LDAP://$DomainName"
		$sidObject = New-Object System.Security.Principal.SecurityIdentifier( $ADObject.objectSid[ 0 ], 0 )

		Write-Debug "***Get-AdDomains DomName='$DomainName', sidObject='$($sidObject.Value)', name='$DomainFQDN'"

		$Object = New-Object -TypeName PSObject
		$Object | Add-Member -MemberType NoteProperty -Name 'Name'      -Value $DomainFQDN
		$Object | Add-Member -MemberType NoteProperty -Name 'FQDN'      -Value $DomainName
		$Object | Add-Member -MemberType NoteProperty -Name 'ObjectSID' -Value $sidObject.Value
		$Object
	}
}

Function Get-PrivilegedGroupsMemberCount 
{
	Param (
		[Parameter( Mandatory = $true, ValueFromPipeline = $true )]
		$Domains
	)

	## Jeff W. said this was original code, but until I got ahold of it and
	## rewrote it, it looked only slightly changed from:
	## https://gallery.technet.microsoft.com/scriptcenter/List-Membership-In-bff89703
	## So I give them both credit. :-)
	
	## the $Domains param is the output from Get-AdDomains above
	ForEach( $Domain in $Domains ) 
	{
		$DomainSIDValue = $Domain.ObjectSID
		$DomainName     = $Domain.Name
		$DomainFQDN     = $Domain.FQDN

		Write-Debug "***Get-PrivilegedGroupsMemberCount: domainName='$domainName', domainSid='$domainSidValue'"

		## Carefully chosen from a more complete list at:
		## https://support.microsoft.com/en-us/kb/243330
		## Administrator (not a group, just FYI)    - $DomainSidValue-500
		## Domain Admins                            - $DomainSidValue-512
		## Schema Admins                            - $DomainSidValue-518
		## Enterprise Admins                        - $DomainSidValue-519
		## Group Policy Creator Owners              - $DomainSidValue-520
		## BUILTIN\Administrators                   - S-1-5-32-544
		## BUILTIN\Account Operators                - S-1-5-32-548
		## BUILTIN\Server Operators                 - S-1-5-32-549
		## BUILTIN\Print Operators                  - S-1-5-32-550
		## BUILTIN\Backup Operators                 - S-1-5-32-551
		## BUILTIN\Replicators                      - S-1-5-32-552
		## BUILTIN\Network Configuration Operations - S-1-5-32-556
		## BUILTIN\Incoming Forest Trust Builders   - S-1-5-32-557
		## BUILTIN\Event Log Readers                - S-1-5-32-573
		## BUILTIN\Hyper-V Administrators           - S-1-5-32-578
		## BUILTIN\Remote Management Users          - S-1-5-32-580
		
		## FIXME - we report on all these groups for every domain, however
		## some of them are forest wide (thus the membership will be reported
		## in every domain) and some of the groups only exist in the
		## forest root.
		$PrivilegedGroups = "$DomainSidValue-512", "$DomainSidValue-518",
		                    "$DomainSidValue-519", "$DomainSidValue-520",
							"S-1-5-32-544", "S-1-5-32-548", "S-1-5-32-549",
							"S-1-5-32-550", "S-1-5-32-551", "S-1-5-32-552",
							"S-1-5-32-556", "S-1-5-32-557", "S-1-5-32-573",
							"S-1-5-32-578", "S-1-5-32-580"

		ForEach( $PrivilegedGroup in $PrivilegedGroups ) 
		{
			$source = New-Object DirectoryServices.DirectorySearcher( "LDAP://$DomainName" )
			$source.SearchScope = 'Subtree'
			$source.PageSize    = 1000
			$source.Filter      = "(objectSID=$PrivilegedGroup)"
			
			Write-Debug "***Get-PrivilegedGroupsMemberCount: LDAP://$DomainName, (objectSid=$PrivilegedGroup)"
			
			$Groups = $source.FindAll()
			ForEach( $Group in $Groups )
			{
				$DistinguishedName = $Group.Properties.Item( 'distinguishedName' )
				$groupName         = $Group.Properties.Item( 'Name' )

				Write-Debug "***Get-PrivilegedGroupsMemberCount: searching group '$groupName'"

				$Source.Filter = "(memberOf:1.2.840.113556.1.4.1941:=$DistinguishedName)"
				$Users = $null
				## CHECK: I don't think a try/catch is necessary here - MBS
				try 
				{
					$Users = $Source.FindAll()
				} 
				catch 
				{
					# nothing
				}
				If( $null -eq $users )
				{
					## Obsolete: F-I-X-M-E: we should probably Return a PSObject with a count of zero
					## Write-ToCSV and Write-ToWord understand empty Return results.

					Write-Debug "***Get-PrivilegedGroupsMemberCount: no members found in $groupName"
				}
				Else 
				{
					Function GetProperValue
					{
						Param(
							[Object] $object
						)

						If( $object -is [System.DirectoryServices.SearchResultCollection] )
						{
							Return $object.Count
						}
						If( $object -is [System.DirectoryServices.SearchResult] )
						{
							Return 1
						}
						If( $object -is [Array] )
						{
							Return $object.Count
						}
						If( $null -eq $object )
						{
							Return 0
						}

						Return 1
					}

					[int]$script:MemberCount = GetProperValue $Users

					Write-Debug "***Get-PrivilegedGroupsMemberCount: '$groupName' user count before first filter $MemberCount"

					$Object = New-Object -TypeName PSObject
					$Object | Add-Member -MemberType NoteProperty -Name 'Domain' -Value $DomainFQDN
					$Object | Add-Member -MemberType NoteProperty -Name 'Group'  -Value $groupName

					$Members = $Users | Where-Object { $_.Properties.Item( 'objectCategory' ).Item( 0 ) -like 'cn=person*' }
					$script:MemberCount = GetProperValue $Members

					Write-Debug "***Get-PrivilegedGroupsMemberCount: '$groupName' user count after first filter $MemberCount"

					Write-Debug "***Get-PrivilegedGroupsMemberCount: '$groupName' has $MemberCount members"

					$Object | Add-Member -MemberType NoteProperty -Name 'Members' -Value $MemberCount
					$Object
				}
			}
		}
	}
}

Function Get-AllADDomainControllers 
{
	[CmdletBinding()]
	Param (
		[Parameter( Mandatory = $true, ValueFromPipeline = $true )]
		$Domain
	)

	$DomainName = $Domain.Name
	$DomainFQDN = $Domain.FQDN
	
	$adsiSearcher        = New-Object DirectoryServices.DirectorySearcher( "LDAP://$DomainName" )
	$adsiSearcher.Filter = '(&(objectCategory=computer)(userAccountControl:1.2.840.113556.1.4.803:=8192))'
	$Servers             = $adsiSearcher.FindAll() 
	
	ForEach( $Server in $Servers ) 
	{
		$dcName = $Server.Properties.item( 'Name' )

		Write-Debug "***Get-AllAdDomainControllers DomainName='$DomainName', DomainFQDN='$($DomainFQDN)', DCname='$dcName'"

		$Object = New-Object -TypeName PSObject
		$Object | Add-Member -MemberType NoteProperty -Name 'Domain'      -Value $DomainFQDN
		$Object | Add-Member -MemberType NoteProperty -Name 'Name'        -Value $dcName
		$Object | Add-Member -MemberType NoteProperty -Name 'LastContact' -Value $Server.Properties.Item( 'whenchanged' )
		$Object
	}
}

Function Get-AllADMemberServers 
{
	[CmdletBinding()]
	Param (
		[Parameter( Mandatory = $true, ValueFromPipeline = $true )]
		$Domain
	)

	$DomainName = $Domain.Name
	$DomainFQDN = $Domain.FQDN

	Write-Debug "***Enter: Get-AllAdMemberServers DomainName='$domainName'"

	$adsiSearcher        = New-Object DirectoryServices.DirectorySearcher( "LDAP://$DomainName" )
	$adsiSearcher.Filter = '(&(objectCategory=computer)(operatingSystem=*server*)(!(userAccountControl:1.2.840.113556.1.4.803:=8192)))"'
	$Servers             = $adsiSearcher.FindAll()
	
	If( $null -eq $servers )
	{
		Write-Debug '***Get-AllAdMemberServers: no member servers were found'
		Return
	}

	ForEach( $Server in $Servers ) 
	{
		$serverName = $Server.Properties.Item( 'Name' )

		Write-Debug "***Get-AllAdMemberServers DomainName='$DomainName', DomainFQDN='$DomainFQDN', serverName='$serverName'"

		$Object = New-Object -TypeName PSObject
		$Object | Add-Member -MemberType NoteProperty -Name 'Domain'       -Value $DomainFQDN
		$Object | Add-Member -MemberType NoteProperty -Name 'ComputerName' -Value $serverName
		$Object
	}
}

Function Get-AllADMemberServerObjects 
{
	[CmdletBinding()]
	Param (
		[Parameter( Mandatory = $true, Parametersetname = 'PasswordNeverExpires' )]
		[Switch]$PasswordNeverExpires,

		[Parameter( Mandatory = $true, Parametersetname = 'PasswordExpiration' )]
		[int]$PasswordExpiration,

		[Parameter( Mandatory = $true, Parametersetname = 'AccountNeverExpires' )]
		[Switch]$AccountNeverExpires,

		[Parameter( Mandatory = $true, Parametersetname = 'Disabled' )]
		[Switch]$Disabled,

		[Parameter( Mandatory = $true, Position = 1, ValueFromPipeline = $true, Parametersetname = 'PasswordNeverExpires' )]
		[Parameter( Mandatory = $true, Position = 1, ValueFromPipeline = $true, Parametersetname = 'PasswordExpiration' )]
		[Parameter( Mandatory = $true, Position = 1, ValueFromPipeline = $true, Parametersetname = 'AccountNeverExpires' )]
		[Parameter( Mandatory = $true, Position = 1, ValueFromPipeline = $true, Parametersetname = 'Disabled' )]
		$Domain
	)

	$DomainName    = $Domain.Name
	$DomainFQDN    = $Domain.FQDN
	$localParamset = $PSCmdlet.ParameterSetName

	Write-Debug "***Enter Get-AllADMemberServerObjects, DomainName='$DomainName', ParamSet='$localParamset'"

	$source             = New-Object System.DirectoryServices.DirectorySearcher( "LDAP://$DomainName" )
	$source.SearchScope = 'Subtree'
	$source.PageSize    = 1000
	
	Switch ( $localParamset ) 
	{
		'PasswordNeverExpires'
		{
			$source.Filter = "(&(objectCategory=computer)(operatingSystem=*server*)(!(userAccountControl:1.2.840.113556.1.4.803:=8192))(userAccountControl:1.2.840.113556.1.4.803:=65536))"
		}
		'PasswordExpiration'
		{
			$source.Filter = "(&(objectCategory=computer)(operatingSystem=*server*)(!(userAccountControl:1.2.840.113556.1.4.803:=8192)))"
		}
		'AccountNeverExpires' 
		{
			$source.Filter = "(&(objectCategory=computer)(operatingSystem=*server*)(!(userAccountControl:1.2.840.113556.1.4.803:=8192))(|(accountExpires=0)(accountExpires=9223372036854775807)))"
		}
		'Disabled'
		{
			#$source.Filter = "(&(objectCategory=computer)(operatingSystem=*server*)(!(userAccountControl:1.2.840.113556.1.4.803:=8194)))"
			$source.Filter = "(&(&(objectCategory=computer)(objectClass=computer)(operatingSystem=*server*)(useraccountcontrol:1.2.840.113556.1.4.803:=2)))"
		}
	}
	
	If( $localParamset -eq 'PasswordExpiration' ) 
	{
		try 
		{
			$source.FindAll() | ForEach-Object {
				$fileTime = $null
				$passLast = $_.Properties[ 'PwdLastSet' ].Item( 0 )
				If( $null -ne $passLast )
				{
					$fileTime = [DateTime]::FromFileTime( $passLast )
				}
				
				If( $null -ne $passLast -and
				    $fileTime -lt ( [DateTime]::Now ).AddMonths( -$PasswordExpiration ) )
				{
					$serverName = $_.Properties.Item( 'Name' )

					Write-Debug "***Get-AllADMemberServerObjects, paramset='$localParamset', found server='$serverName'"

					$Object = New-Object -TypeName PSObject
					$Object | Add-Member -MemberType NoteProperty -Name 'Domain'          -Value $DomainFQDN
					$Object | Add-Member -MemberType NoteProperty -Name 'Name'            -Value $serverName
					$Object | Add-Member -MemberType NoteProperty -Name 'PasswordLastSet' -Value $fileTime
					$Object
				}
			}     
		}
		catch
		{
		}
	} 
	Else 
	{
		try 
		{
			$source.FindAll() | ForEach-Object {
				$serverName = $_.Properties.Item( 'Name' )

				Write-Debug "***Get-AllADMemberServerObjects, paramset='$localParamset', found server='$serverName'"

				$Object = New-Object -TypeName PSObject
				$Object | Add-Member -MemberType NoteProperty -Name 'Domain' -Value $DomainFQDN
				$Object | Add-Member -MemberType NoteProperty -Name 'Name'   -Value $serverName
				$Object
			}
		} 
		catch 
		{
		}
	}
}

Function Get-ADUserObjects 
{
	[CmdletBinding()]
	Param (
		[Parameter( Mandatory = $true, Parametersetname = 'PasswordNeverExpires')]
		[Switch]$PasswordNeverExpires,

		[Parameter( Mandatory = $true, Parametersetname = 'PasswordNotRequired')]
		[Switch]$PasswordNotRequired,

		[Parameter( Mandatory = $true, Parametersetname = 'PasswordChangeAtNextLogon')]
		[Switch]$PasswordChangeAtNextLogon,

		[Parameter( Mandatory = $true, Parametersetname = 'PasswordExpiration')]
		[int]$PasswordExpiration,

		[Parameter( Mandatory = $true, Parametersetname = 'NotRequireKerbereosAuthentication')]
		[Switch]$NotRequireKerbereosAuthentication,

		[Parameter( Mandatory = $true, Parametersetname = 'AccountNoExpire')]
		[Switch]$AccountNoExpire,

		[Parameter( Mandatory = $true, Parametersetname = 'Disabled')]
		[Switch]$Disabled,

		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true, Parametersetname = 'PasswordNeverExpires' )]
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true, Parametersetname = 'PasswordNotRequired' )]
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true, Parametersetname = 'PasswordChangeAtNextLogon' )]
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true, Parametersetname = 'PasswordExpiration' )]
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true, Parametersetname = 'NotRequireKerbereosAuthentication' )]
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true, Parametersetname = 'AccountNoExpire' )]
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true, Parametersetname = 'Disabled' )]
		$Domain
	)

	## this doesn't know how to process passwordSettingsObjects (fine-grained passwords) -- FIXME

	$DomainName    = $Domain.Name
	$DomainFQDN    = $Domain.FQDN
	$localParamset = $PSCmdlet.ParameterSetName

	Write-Debug "***Enter Get-ADUserObjects: domain='$DomainName', paramset='$localParamset'"

	$source             = New-Object System.Directoryservices.Directorysearcher( "LDAP://$DomainName" )
	$source.SearchScope = 'Subtree'
	$source.PageSize    = 1000
	
	Switch ( $localParamset )
	{
		'PasswordNeverExpires'
		{
			$source.filter = "(&(sAMAccountType=805306368)(userAccountControl:1.2.840.113556.1.4.803:=65536))"
		}
		'PasswordNotRequired' 
		{
			$source.filter = "(&(sAMAccountType=805306368)(userAccountControl:1.2.840.113556.1.4.803:=32))"
		}
		'PasswordChangeAtNextLogon' 
		{
			$source.filter = "(&(sAMAccountType=805306368)(pwdLastSet=0))"
		}
		'PasswordExpiration'
		{
			$source.filter = "(&(sAMAccountType=805306368)(pwdLastSet>=0))"
		}
		'NotRequireKerbereosAuthentication' 
		{
			$source.filter = "(&(sAMAccountType=805306368)(userAccountControl:1.2.840.113556.1.4.803:=4194304))"
		}
		'AccountNoExpire'
		{
			$source.filter = "(&(sAMAccountType=805306368)(|(accountExpires=0)(accountExpires=9223372036854775807)))"
		}
		'Disabled' 
		{
			$source.filter = "(&(sAMAccountType=805306368)(userAccountControl:1.2.840.113556.1.4.803:=2))"
		}
	}

	If( $localParamset -eq 'PasswordExpiration' ) 
	{
		try 
		{
			$source.FindAll() | ForEach-Object {
				$fileTime = $null
				$passLast = $_.Properties[ 'PwdLastSet' ].Item( 0 )
				If( $null -ne $passLast )
				{
					$fileTime = [DateTime]::FromFileTime( $passLast )
				}
				
				If( $null -ne $passLast -and
				    $fileTime -lt ( [DateTime]::Now ).AddMonths( -$PasswordExpiration ) )
				{
					$userName   = $_.Properties.Item( 'Name' )

					Write-Debug "***Get-ADUserObjects: domain='$DomainFQDN', paramset='$localParamset', username='$userName'"

					$Object = New-Object -TypeName PSObject
					$Object | Add-Member -MemberType NoteProperty -Name 'Domain'          -Value $DomainFQDN
					$Object | Add-Member -MemberType NoteProperty -Name 'Name'            -Value $userName
					$Object | Add-Member -MemberType NoteProperty -Name 'PasswordLastSet' -Value $fileTime
					$Object
				}
			}
		} 
		catch 
		{
		}
	}
	Else 
	{
		try 
		{
			$source.FindAll() | ForEach-Object {
				$userName = $_.Properties.Item( 'Name' )

				Write-Debug "***Get-ADUserObjects: domain='$DomainFQDN', paramset='$localParamset', username='$userName'"

				$Object = New-Object -TypeName PSObject
				$Object | Add-Member -MemberType NoteProperty -Name 'Domain' -Value $DomainFQDN
				$Object | Add-Member -MemberType NoteProperty -Name 'Name'   -Value $userName
				$Object
			}
		} 
		catch 
		{
		}
	}
}

Function Get-OUGPInheritanceBlocked 
{
	[CmdletBinding()]
	Param (
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
		$Domain
	)

	$DomainName = $Domain.Name
	$DomainFQDN = $Domain.FQDN
	
	Write-Debug "***Enter: Get-OUGPInheritanceBlocked, DomainName '$DomainName'"

	$source             = New-Object System.DirectoryServices.DirectorySearcher( "LDAP://$DomainName" )
	$source.SearchScope = 'Subtree'
	$source.PageSize    = 1000
	$source.filter      = '(&(objectclass=OrganizationalUnit)(gpoptions=1))'
	try 
	{
		$source.FindAll() | ForEach-Object {
			$ouName = $_.Properties.Item( 'Name' )

			Write-Debug "***Get-OuGpInheritanceBlocked: Inheritance blocked on OU '$ouName' in domain '$DomainName'"

			$Object = New-Object -TypeName PSObject
			$Object | Add-Member -MemberType NoteProperty -Name 'Domain' -Value $DomainFQDN
			$Object | Add-Member -MemberType NoteProperty -Name 'Name'   -Value $ouName 
			$Object
		}
	} 
	catch 
	{
	}
}

Function Get-ADSites 
{
	[CmdletBinding()]
	Param (
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
		$Domain
	)

	$DomainName = $Domain.Name
	$DomainFQDN = $Domain.FQDN
	$searchRoot = "LDAP://CN=Sites,CN=Configuration,$DomainName"

	Write-Debug "***Enter: Get-AdSites, DomainName='$($DomainName)', SearchRoot='$searchRoot'"

	$source             = New-Object System.DirectoryServices.DirectorySearcher
	$source.SearchScope = 'Subtree'
	$source.SearchRoot  = $searchRoot
	$source.PageSize    = 1000
	$source.Filter      = '(objectclass=site)'
	
	try 
	{
		$source.FindAll() | ForEach-Object {
			$siteName = $_.Properties.Item( 'Name' )
			$desc     = $_.Properties.Item( 'Description' )

			If( [String]::IsNullOrEmpty( $desc ) )
			{
				$desc = ' '
			}
			
			Write-Debug "***Get-AdSites: domainFQDN='$DomainFQDN', sitename='$sitename', desc='$desc'"

			$subnets = @()
			$siteBL  = $_.Properties.Item( 'siteObjectBL' )
			ForEach( $item in $siteBL )
			{
				$temp = $item.SubString( 0, $item.IndexOf( ',' ) )  ## up to first ","
				$temp = $temp.SubString( 3 )                        ## drop CN=

				Write-Debug "***Get-AdSites: sitename='$sitename', subnet='$temp'"

				$subnets += $temp
			}
			If( $subnets.Count -eq 0 )
			{
				$subnets = $null
			}

			$Object = New-Object -TypeName PSObject
			$Object | Add-Member -MemberType NoteProperty -Name 'Domain'      -Value $DomainFQDN
			$Object | Add-Member -MemberType NoteProperty -Name 'Site'        -Value $siteName
			$Object | Add-Member -MemberType NoteProperty -Name 'Description' -Value $desc
			$Object | Add-Member -MemberType NoteProperty -Name 'Subnets'     -Value $subnets
			$Object
		}
	} 
	catch 
	{
	}
}

Function Get-ADSiteServer 
{
	[CmdletBinding()]
	Param (
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		$Domain,

		[Parameter( Mandatory = $true )]
		$Site
	)

	$DomainName = $Domain.Name
	$DomainFQDN = $Domain.FQDN
	$searchRoot = "LDAP://CN=Servers,CN=$Site,CN=Sites,CN=Configuration,$DomainName"

	Write-Debug "***Enter: Get-AdSiteServer DomainName='$domainName', DomainFQDN='$domainFQDN', searchRoot='$searchRoot'"

	$source             = New-Object System.DirectoryServices.DirectorySearcher
	$source.SearchRoot  = $searchRoot 
	$source.SearchScope = 'Subtree'
	$source.PageSize    = 1000
	$source.Filter      = '(objectclass=server)'
	
	try 
	{
		$SiteServers = $source.FindAll()
		If( $null -ne $SiteServers ) 
		{
			ForEach( $SiteServer in $SiteServers ) 
			{
				$serverName = $SiteServer.Properties.Item( 'Name' )

				Write-Debug "***Get-AdSiteServer: serverName='$serverName' found in site '$site' in domain '$domainFQDN'"

				$Object = New-Object -TypeName PSObject
				$Object | Add-Member -MemberType NoteProperty -Name 'Domain' -Value $DomainFQDN
				$Object | Add-Member -MemberType NoteProperty -Name 'Site'   -Value $Site
				$Object | Add-Member -MemberType NoteProperty -Name 'Name'   -Value $serverName
				$Object
			}
		} 
		Else 
		{
			Write-Debug "***Get-AdSiteServer: No server found in site '$site' in domain '$domainFQDN'"

			$Object = New-Object -TypeName PSObject
			$Object | Add-Member -MemberType NoteProperty -Name 'Domain' -Value $DomainFQDN
			$Object | Add-Member -MemberType NoteProperty -Name 'Site'   -Value $Site
			$Object | Add-Member -MemberType NoteProperty -Name 'Name'   -Value ' '
			$Object            
		}
	} 
	catch 
	{
	}
}

Function Get-ADSiteConnection 
{
	[CmdletBinding()]
	Param (
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
		$Domain,

		[Parameter( Mandatory = $true )]
		$Site
	)

	$DomainName = $Domain.Name
	$DomainFQDN = $Domain.FQDN
	$searchRoot = "LDAP://CN=$Site,CN=Sites,CN=Configuration,$DomainName"

	Write-Debug "***Enter: Get-ADSiteConnection DomainName='$DomainName', DomainFQDN='$DomainFQDN', searchRoot='$searchRoot'"

	$source             = New-Object System.DirectoryServices.DirectorySearcher
	$source.SearchRoot  = $searchRoot 
	$source.SearchScope = 'Subtree'
	$source.PageSize    = 1000
	$source.Filter      = '(objectclass=nTDSConnection)'
	
	try 
	{
		$SiteConnections = $source.FindAll()
		If( $null -ne $SiteConnections ) 
		{
			ForEach( $SiteConnection in $SiteConnections ) 
			{
				$connectName   = $SiteConnection.Properties.Item( 'Name' )
				$connectServer = $SiteConnection.Properties.Item( 'FromServer' )

				Write-Debug "***Get-ADSiteConnection DomainFQDN='$DomainFQDN', site='$Site', connectionName='$connectName'"

				$Object = New-Object -TypeName PSObject
				$Object | Add-Member -MemberType NoteProperty -Name 'Domain'     -Value $DomainFQDN
				$Object | Add-Member -MemberType NoteProperty -Name 'Site'       -Value $Site
				$Object | Add-Member -MemberType NoteProperty -Name 'Name'       -Value $connectName
				$Object | Add-Member -MemberType NoteProperty -Name 'FromServer' -Value $($connectServer -split ',' -replace 'CN=','')[3]
				$Object
			}
		} 
		Else 
		{
			Write-Debug "***Get-ADSiteConnection DomainFQDN='$DomainFQDN', site='$Site', no connections"

			$Object = New-Object -TypeName PSObject
			$Object | Add-Member -MemberType NoteProperty -Name 'Domain'     -Value $DomainFQDN
			$Object | Add-Member -MemberType NoteProperty -Name 'Site'       -Value $Site
			$Object | Add-Member -MemberType NoteProperty -Name 'Name'       -Value ' '
			$Object | Add-Member -MemberType NoteProperty -Name 'FromServer' -Value ' '
			$Object        
		}
	} 
	catch 
	{
	}
}

Function Get-ADSiteLink 
{
	[CmdletBinding()]
	Param (
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
		$Domain
	)

	$DomainName = $Domain.Name
	$DomainFQDN = $Domain.FQDN
	$searchRoot = "LDAP://CN=Sites,CN=Configuration,$DomainName"

	Write-Debug "***Enter: Get-AdSiteLink DomainName='$DomainName', DomainFQDN='$DomainFQDN', searchRoot='$searchRoot'"

	$source             = New-Object System.DirectoryServices.DirectorySearcher
	$source.SearchRoot  = $searchRoot
	$source.SearchScope = 'Subtree'
	$source.PageSize    = 1000
	$source.Filter      = '(objectclass=sitelink)'
	
	try 
	{
		$SiteLinks = $source.FindAll()
		ForEach( $SiteLink in $SiteLinks ) 
		{
			$siteLinkName = $SiteLink.Properties.Item( 'Name' )
			$siteLinkDesc = $SiteLink.Properties.Item( 'Description' )
			$siteLinkRepl = $SiteLink.Properties.Item( 'replinterval' )
			$siteLinkSite = $SiteLink.Properties.Item( 'Sitelist' )
			$siteLinkCt   = 0

			If( $siteLinkSite )
			{
				$siteLinkCt = $siteLinkSite.Count
			}

			$sites = @()
			ForEach( $item in $siteLinkSite )
			{
				$temp  = $item.SubString( 0, $item.IndexOf( ',' ) )
				$temp  = $temp.SubString( 3 )
				$sites += $temp
			}
			If( $sites.Count -eq 0 )
			{
				$sites      = $null
				$siteLinkCt = 0
			}

			Write-Debug "***Get-AdSiteLink: Name='$siteLinkName', Desc='$siteLinkDesc', Repl='$siteLinkRepl', Count='$siteLinkCt'"

			If( [String]::IsNullOrEmpty( $siteLinkDesc ) )
			{
				$siteLinkDesc = ' '
			}

			If( $null -ne $sites ) 
			{
				ForEach( $Site in $Sites ) 
				{
					Write-Debug "***Get-AdSiteLink: siteLinkName='$siteLinkName', sitename='$site'"

					$Object = New-Object -TypeName PSObject
					$Object | Add-Member -MemberType NoteProperty -Name 'Domain'               -Value $DomainFQDN
					$Object | Add-Member -MemberType NoteProperty -Name 'Name'                 -Value $siteLinkName
					$Object | Add-Member -MemberType NoteProperty -Name 'Description'          -Value $siteLinkDesc
					$Object | Add-Member -MemberType NoteProperty -Name 'Replication Interval' -Value $siteLinkRepl
					$Object | Add-Member -MemberType NoteProperty -Name 'Site'                 -Value $site
					$Object | Add-Member -MemberType NoteProperty -Name 'Site Count'           -Value $siteLinkCt
					$Object
				}
			} 
			Else 
			{
				Write-Debug "***Get-AdSiteLink: siteLinkName='$siteLinkName', siteName='<empty>'"

				$Object = New-Object -TypeName PSObject
				$Object | Add-Member -MemberType NoteProperty -Name 'Domain'               -Value $DomainFQDN
				$Object | Add-Member -MemberType NoteProperty -Name 'Name'                 -Value $siteLinkName
				$Object | Add-Member -MemberType NoteProperty -Name 'Description'          -Value $siteLinkDesc
				$Object | Add-Member -MemberType NoteProperty -Name 'Replication Interval' -Value $siteLinkRepl
				$Object | Add-Member -MemberType NoteProperty -Name 'Site'                 -Value ' '
				$Object | Add-Member -MemberType NoteProperty -Name 'Site Count'           -Value '0'
				$Object
			}
		}
	} 
	catch 
	{
	}
}

Function Get-ADSiteSubnet 
{
	[CmdletBinding()]
	Param (
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
		$Domain
	)

	$DomainName = $Domain.Name
	$DomainFQDN = $Domain.FQDN
	$searchRoot = "LDAP://CN=Subnets,CN=Sites,CN=Configuration,$DomainName"

	Write-Debug "***Enter Get-AdSiteSubnet DomainName='$DomainName', DomainFQDN='$DomainFQDN', searchRoot='$searchRoot'"

	$source             = New-Object System.DirectoryServices.DirectorySearcher
	$source.SearchRoot  = $searchRoot
	$source.SearchScope = 'Subtree'
	$source.PageSize    = 1000
	$source.Filter      = '(objectclass=subnet)'
	
	try 
	{
		$source.FindAll() | ForEach-Object {
			$subnetSite = ($_.Properties.Item( 'SiteObject' ) -split ',' -replace 'CN=','')[0]
			$subnetName = $_.Properties.Item( 'Name' )
			$subnetDesc = $_.Properties.Item( 'Description' )

			Write-Debug "***Get-AdSiteSubnet: site='$subnetSite', name='$subnetName', desc='$subnetDesc'"

			$Object = New-Object -TypeName PSObject
			$Object | Add-Member -MemberType NoteProperty -Name 'Domain'      -Value $DomainFQDN
			$Object | Add-Member -MemberType NoteProperty -Name 'Site'        -Value $subnetSite
			$Object | Add-Member -MemberType NoteProperty -Name 'Name'        -Value $subnetName
			$Object | Add-Member -MemberType NoteProperty -Name 'Description' -Value $subnetDesc
			$Object
		}
	} 
	catch 
	{
	}
}

Function Get-ADEmptyGroups 
{
	[CmdletBinding()]
	Param (
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
		$Domain
	)

	## $exclude includes (punny, aren't I?) the list of groups commonly used as a 
	## 'Primary Group' in Active Directory. While, theoretically, ANY group can be
	## a primary group, that is quite rare. 
	$exclude = 'Domain Users', 'Domain Computers', 'Domain Controllers', 'Domain Guests'
	
	$DomainName = $Domain.Name
	$DomainFQDN = $Domain.FQDN

	Write-Debug "***Enter Get-AdEmptyGroups DomainName='$DomainName', DomainFQDN='$DomainFQDN'"

	$source             = New-Object DirectoryServices.DirectorySearcher( "LDAP://$DomainName" )
	$source.SearchScope = 'Subtree'
	$source.PageSize    = 1000
	$source.Filter      = '(&(objectCategory=Group)(!member=*))'

	try 
	{
		$groups = $source.FindAll()
		$groups = (($groups | Where-Object { $exclude -notcontains $_.Properties[ 'Name' ].Item( 0 ) } ) | ForEach-Object { $_.Properties[ 'Name' ].Item( 0 ) }) | Sort-Object
		ForEach( $group in $groups )
		{
			Write-Debug "***Get-AdEmptyGroups: DomainFQDN='$DomainFQDN', empty groupname='$group'"

			$Object = New-Object -TypeName PSObject
			$Object | Add-Member -MemberType NoteProperty -Name 'Domain' -Value $DomainFQDN
			$Object | Add-Member -MemberType NoteProperty -Name 'Name'   -Value $group
			$Object
		}
	}
	catch 
	{
	}
}

Function Get-ADDomainLocalGroups 
{
	[CmdletBinding()]
	Param (
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
		$Domain
	)

	$DomainName = $Domain.Name
	$DomainFQDN = $Domain.FQDN

	Write-Debug "***Enter Get-AdDomainLocalGroups DomainName='$DomainName', DomainFQDN='$DomainFQDN'"

	$search             = New-Object System.DirectoryServices.DirectorySearcher( "LDAP://$DomainName" )
	$search.SearchScope = 'Subtree'
	$search.PageSize    = 1000
	$search.Filter      = '(&(groupType:1.2.840.113556.1.4.803:=4)(!(groupType:1.2.840.113556.1.4.803:=1)))'
	
	try 
	{
		$search.FindAll() | ForEach-Object {
			$groupName = $_.Properties.Item( 'Name' )
			$groupDN   = $_.Properties.Item( 'Distinguishedname' )

			Write-Debug "***Get-AdDomainLocalGroups groupName='$groupName', dn='$groupDN'"

			$Object = New-Object -TypeName PSObject
			$Object | Add-Member -MemberType NoteProperty -Name 'Domain'            -Value $DomainFQDN
			$Object | Add-Member -MemberType NoteProperty -Name 'Name'              -Value $groupName
			$Object | Add-Member -MemberType NoteProperty -Name 'DistinguishedName' -Value $groupDN
			$Object
		}
	} 
	catch 
	{
	}
}

Function Get-ADUsersInDomainLocalGroups 
{
	[CmdletBinding()]
	Param (
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
		$Domain
	)

	$DomainName = $Domain.Name
	$DomainFQDN = $Domain.FQDN

	Write-Debug "***Enter Get-AdUsersInDomainLocalGroups DomainName='$DomainName', DomainFQDN='$DomainFQDN'"

	$search             = New-Object DirectoryServices.DirectorySearcher( "LDAP://$DomainName" )
	$search.SearchScope = 'Subtree'
	$search.PageSize    = 1000
	$search.Filter      = '(&(groupType:1.2.840.113556.1.4.803:=4)(!(groupType:1.2.840.113556.1.4.803:=1)))'
	
	try 
	{
		## $search was being used twice.
		$results = $search.FindAll() 
		$results | ForEach-Object {
			$groupName         = $_.Properties.Item( 'Name' )
			$DistinguishedName = $_.Properties.Item( 'DistinguishedName' )

			Write-Debug "***Get-AdUsersInDomainLocalGroups name='$groupName', dn='$distinguishedName'"

			$search.Filter = "(&(memberOf=$DistinguishedName)(objectclass=User))"
			$search.FindAll() | ForEach-Object {
				$userName = $_.Properties.Item( 'Name' )

				Write-Debug "***Get-AdUsersInDomainLocalGroups name='$groupName', user='$userName'" 

				$Object = New-Object -TypeName PSObject
				$Object | Add-Member -MemberType NoteProperty -Name 'Domain' -Value $DomainFQDN
				$Object | Add-Member -MemberType NoteProperty -Name 'Group'  -Value $groupName
				$Object | Add-Member -MemberType NoteProperty -Name 'Name'   -Value $userName
				$Object
			}
		}
	} 
	catch 
	{
	}
}

#region process document output
Function ProcessDocumentOutput
{
	If($MSWORD -or $PDF)
	{
		SaveandCloseDocumentandShutdownWord
	}

	Write-Verbose "$(Get-Date -Format G): Script has completed"
	Write-Verbose "$(Get-Date -Format G): "

	$GotFile = $False

	If($PDF)
	{
		If(Test-Path "$($Script:FileName2)")
		{
			Write-Verbose "$(Get-Date -Format G): $($Script:FileName2) is ready for use"
			Write-Verbose "$(Get-Date -Format G): "
			$GotFile = $True
		}
		Else
		{
			Write-Warning "$(Get-Date -Format G): Unable to save the output file, $($Script:FileName2)"
			Write-Error "Unable to save the output file, $($Script:FileName2)"
		}
	}
	Else
	{
		If(Test-Path "$($Script:FileName1)")
		{
			Write-Verbose "$(Get-Date -Format G): $($Script:FileName1) is ready for use"
			Write-Verbose "$(Get-Date -Format G): "
			$GotFile = $True
		}
		Else
		{
			Write-Warning "$(Get-Date -Format G): Unable to save the output file, $($Script:FileName1)"
			Write-Error "Unable to save the output file, $($Script:FileName1)"
		}
	}

	#email output file if requested
	If($GotFile -and ![System.String]::IsNullOrEmpty( $SmtpServer ))
	{
		If($PDF)
		{
			$emailAttachment = $Script:FileName2
		}
		Else
		{
			$emailAttachment = $Script:FileName1
		}
		SendEmail $emailAttachment
	}

	Write-Verbose "$(Get-Date -Format G): "
}
#endregion

#region end script
Function ProcessScriptEnd
{
	#http://poshtips.com/measuring-elapsed-time-in-powershell/
	Write-Verbose "$(Get-Date -Format G): Script started: $($Script:StartTime)"
	Write-Verbose "$(Get-Date -Format G): Script ended: $(Get-Date)"
	$runtime = $(Get-Date) - $Script:StartTime
	$Str = [string]::format("{0} days, {1} hours, {2} minutes, {3}.{4} seconds",
		$runtime.Days,
		$runtime.Hours,
		$runtime.Minutes,
		$runtime.Seconds,
		$runtime.Milliseconds)
	Write-Verbose "$(Get-Date -Format G): Elapsed time: $($Str)"

	If($Dev)
	{
		If($SmtpServer -eq "")
		{
			Out-File -FilePath $Script:DevErrorFile -InputObject $error 4>$Null
		}
		Else
		{
			Out-File -FilePath $Script:DevErrorFile -InputObject $error -Append 4>$Null
		}
	}
	
	If($ScriptInfo)
	{
		Out-File -FilePath $Script:SIFile -InputObject "" 4>$Null
		Out-File -FilePath $Script:SIFile -Append -InputObject "Add DateTime       : $($AddDateTime)" 4>$Null
		Out-File -FilePath $Script:SIFile -Append -InputObject "All                : $($All)" 4>$Null
		If($MSWORD -or $PDF)
		{
			Out-File -FilePath $SIFile -Append -InputObject "Company Address    : $CompanyAddress" 4>$Null		
			Out-File -FilePath $SIFile -Append -InputObject "Company Email      : $CompanyEmail" 4>$Null		
			Out-File -FilePath $SIFile -Append -InputObject "Company Fax        : $CompanyFax" 4>$Null		
			Out-File -FilePath $SIFile -Append -InputObject "Company Name       : $Script:CoName" 4>$Null		
			Out-File -FilePath $SIFile -Append -InputObject "Company Phone      : $CompanyPhone" 4>$Null		
			Out-File -FilePath $SIFile -Append -InputObject "Cover Page         : $CoverPage" 4>$Null
		}
		Out-File -FilePath $Script:SIFile -Append -InputObject "Computers          : $($computers)" 4>$Null
		Out-File -FilePath $Script:SIFile -Append -InputObject "Dev                : $($Dev)" 4>$Null
		If($Dev)
		{
			Out-File -FilePath $Script:SIFile -Append -InputObject "DevErrorFile       : $($Script:DevErrorFile)" 4>$Null
		}
		Out-File -FilePath $Script:SIFile -Append -InputObject "Filename1          : $($Script:FileName1)" 4>$Null
		If($PDF)
		{
			Out-File -FilePath $Script:SIFile -Append -InputObject "Filename2          : $($Script:FileName2)" 4>$Null
		}
		Out-File -FilePath $Script:SIFile -Append -InputObject "Folder             : $($Folder)" 4>$Null
		Out-File -FilePath $Script:SIFile -Append -InputObject "From               : $($From)" 4>$Null
		Out-File -FilePath $Script:SIFile -Append -InputObject "Groups             : $($groups)" 4>$Null
		Out-File -FilePath $Script:SIFile -Append -InputObject "Log                : $($Log)" 4>$Null
		Out-File -FilePath $Script:SIFile -Append -InputObject "Mgmt               : $($mgmt)" 4>$Null
		Out-File -FilePath $Script:SIFile -Append -InputObject "Organisational Unit: $($OrganisationalUnit)" 4>$Null
		Out-File -FilePath $Script:SIFile -Append -InputObject "Save As PDF        : $($PDF)" 4>$Null
		Out-File -FilePath $Script:SIFile -Append -InputObject "Save As WORD       : $($MSWORD)" 4>$Null
		Out-File -FilePath $Script:SIFile -Append -InputObject "Script Info        : $($ScriptInfo)" 4>$Null
		Out-File -FilePath $Script:SIFile -Append -InputObject "Sites              : $($Sites)" 4>$Null
		Out-File -FilePath $Script:SIFile -Append -InputObject "Smtp Port          : $($SmtpPort)" 4>$Null
		Out-File -FilePath $Script:SIFile -Append -InputObject "Smtp Server        : $($SmtpServer)" 4>$Null
		Out-File -FilePath $Script:SIFile -Append -InputObject "To                 : $($To)" 4>$Null
		Out-File -FilePath $Script:SIFile -Append -InputObject "Use SSL            : $($UseSSL)" 4>$Null
		If($MSWORD -or $PDF)
		{
			Out-File -FilePath $Script:SIFile -Append -InputObject "User Name          : $($UserName)" 4>$Null
		}
		Out-File -FilePath $Script:SIFile -Append -InputObject "Users              : $($users)" 4>$Null
		Out-File -FilePath $Script:SIFile -Append -InputObject "" 4>$Null
		Out-File -FilePath $Script:SIFile -Append -InputObject "OS Detected        : $($Script:RunningOS)" 4>$Null
		Out-File -FilePath $Script:SIFile -Append -InputObject "PoSH version       : $($Host.Version)" 4>$Null
		Out-File -FilePath $Script:SIFile -Append -InputObject "PSUICulture        : $($PSUICulture)" 4>$Null
		Out-File -FilePath $Script:SIFile -Append -InputObject "PSCulture          : $($PSCulture)" 4>$Null
		If($MSWORD -or $PDF)
		{
			Out-File -FilePath $Script:SIFile -Append -InputObject "Word language      : $($Script:WordLanguageValue)" 4>$Null
			Out-File -FilePath $Script:SIFile -Append -InputObject "Word version       : $($Script:WordProduct)" 4>$Null
		}
		Out-File -FilePath $Script:SIFile -Append -InputObject "" 4>$Null
		Out-File -FilePath $Script:SIFile -Append -InputObject "Script start       : $($Script:StartTime)" 4>$Null
		Out-File -FilePath $Script:SIFile -Append -InputObject "Elapsed time       : $($Str)" 4>$Null
	}
	
	$runtime = $Null
	$Str = $Null
	$ErrorActionPreference = $SaveEAPreference
}
#endregion

#region Content
$Script:MgmtPage = @()

Function Add-TableContent
{
	[CmdletBinding()]
	Param(
		$content,
		$hashParam,
		$title
	)

	$count = 0
	If( $null -eq $content )
	{
		## do not early-Return, because the MgmtPage needs to be updated
		Write-Debug "***Add-TableContent: empty for title='$title'"
	}
	Else
	{
		$count = 1
		If( $content -is [Array] )
		{
			$count = $content.Count
		}

		Write-Debug "***Add-TableContent: count=$count for title='$title'"

		If( $hashParam.ContainsKey( 'CSV' ) )
		{
			Write-ToCSV -Name $title -Content $content
		}
		Write-ToWord -Name $title -TableContent $content
	}
	
	If( $hashParam.ContainsKey( 'Mgmt' ) ) 
	{
		$script:MgmtPage += Add-CheckListResults -Name $title -Count $count
	}
}

Function IsInDomain
{
	$computerSystem = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue -verbose:$False
	If( !$? -or $null -eq $computerSystem )
	{
		$computerSystem = Get-WmiObject Win32_ComputerSystem -ErrorAction SilentlyContinue
		If( !$? -or $null -eq $computerSystem )
		{
			Write-Error 'IsInDomain: fatal error: cannot obtain Win32_ComputerSystem from CIM or WMI.'
			AbortScript
		}
	}
	
	Return $computerSystem.PartOfDomain
}

If( -not ( IsInDomain ) )
{
	Write-Error 'ADHealthCheck must be run from a computer that is a member of a domain.'
	AbortScript
}

FindWordDocumentEnd
$Script:Selection.InsertNewPage()
Write-Verbose "$(Get-Date -Format G): Get domains" 
$Domains = Get-ADDomains
If( $null -eq $Domains )
{
	Write-Error 'ADHealthCheck cannot obtain a list of domains in the forest.'
	AbortScript
}

$parameters = $PSBoundParameters
$paramset   = $PSCmdlet.ParameterSetName

ForEach( $Domain in $Domains ) 
{
	$DomainFQDN = $Domain.FQDN
	Write-Verbose "$(Get-Date -Format G): Domain $DomainFQDN"
	WriteWordLine -Style 1 -Tabs 0 -Name "Domain $DomainFQDN"
	FindWordDocumentEnd
	If(($parameters.ContainsKey('Sites')) -or ($paramset -eq 'All')) 
	{
		#Sites
		$Script:Selection.InsertNewPage()
		FindWordDocumentEnd
		Write-Verbose "$(Get-Date -Format G):  Sites"
		WriteWordLine -Style 2 -Tabs 0 -Name 'Sites'
		FindWordDocumentEnd
		$TableContentTemp = Get-ADSites -Domain $Domain
		
		#Sites - Description empty
		$CheckTitle = 'Sites - Without a description'
		Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
		If($TableContentTemp -ne $null) 
		{
			$TableContent = $TableContentTemp | Where-Object {$_.Description -eq $null}
			Add-TableContent $TableContent $PSBoundParameters $CheckTitle

			#Sites - No subnet
			$CheckTitle = 'Sites - Without one or more subnet(s)'
			Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
			$TableContent = $TableContentTemp | Where-Object {$_.Subnets -eq $null}
			Add-TableContent $TableContent $PSBoundParameters $CheckTitle

			#Sites - No server
			$CheckTitle = 'Sites - No server(s)'
			Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
			$TableContent = $TableContentTemp | ForEach-Object { Get-ADSiteServer -Site $_.Site -Domain $Domain } | Where-Object {$_.Name -eq $null}
			Add-TableContent $TableContent $PSBoundParameters $CheckTitle

			#Sites - No connection
			$CheckTitle = 'Sites - Without a connection'
			Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
			$TableContent = $TableContentTemp | ForEach-Object { Get-ADSiteConnection -Site $_.site -Domain $Domain } | Where-Object {$_.Name -eq $null}
			WriteWordLine -Style 3 -Tabs 0 -Name $CheckTitle
			FindWordDocumentEnd
			Add-TableContent $TableContent $PSBoundParameters $CheckTitle
			WriteWordLine -Style 0 -Tabs 0 -Name ''
			FindWordDocumentEnd
		}

		$allSiteLinks = Get-AdSiteLink -Domain $Domain
		
		#Sites - No sitelink
		$CheckTitle = 'Sites - No sitelink(s)'
		Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
		$TableContent = $allSiteLinks | Where-Object {$_.'Site Count' -eq '0'}
		Add-TableContent $TableContent $PSBoundParameters $CheckTitle

		#Sitelinks - One site
		$CheckTitle = 'Sites - With one sitelink'
		Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
		$TableContent = $allSiteLinks | Where-Object {$_.'Site Count' -eq '1'}
		Add-TableContent $TableContent $PSBoundParameters $CheckTitle

		#Sitelinks - More than two sites
		$CheckTitle = 'SiteLinks - More than two sitelinks'
		Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
		$TableContent = $allSiteLinks | Where-Object {$_.'Site Count' -gt '2'}
		Add-TableContent $TableContent $PSBoundParameters $CheckTitle

		#Sitelinks - No description
		$CheckTitle = 'SiteLinks - Without a description'
		Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
		$TableContent = $allSiteLinks | Where-Object {$_.Description -eq $null}
		Add-TableContent $TableContent $PSBoundParameters $CheckTitle

		#ADSubnets - Available but not in use
		$CheckTitle = 'Subnets in Sites - Not in use'
		Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
		$AvailableSubnets = Get-ADSiteSubnet -Domain $Domain | Select-Object -ExpandProperty 'name'
		$InUseSubnets = Get-ADSites -Domain $Domain | Select-Object -ExpandProperty 'subnets'
		If(($AvailableSubnets -ne $Null) -and ($InUseSubnets -ne $null)) 
		{
			$TableContent = Compare-Object -DifferenceObject $InUseSubnets -ReferenceObject $AvailableSubnets
			Add-TableContent $TableContent $parameters $CheckTitle
		}
	}
	If(($parameters.ContainsKey('OrganisationalUnit')) -or ($paramset -eq 'All')) 
	{
		#OrganisationalUnit
		$Script:Selection.InsertNewPage()
		FindWordDocumentEnd
		Write-Verbose "$(Get-Date -Format G):  OU"
		WriteWordLine -Style 2 -Tabs 0 -Name 'Organisational Units'
		## FIXME - no organizational units shown
		#OU - GPO inheritance blocked
		$CheckTitle = 'OU - GPO inheritance blocked'
		Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
		$TableContent = Get-OUGPInheritanceBlocked -Domain $Domain
		WriteWordLine -Style 3 -Tabs 0 -Name $CheckTitle
		FindWordDocumentEnd
		Add-TableContent $TableContent $parameters $CheckTitle
	}
	If(($parameters.ContainsKey('Computers')) -or ($paramset -eq 'All')) 
	{
		#Domain Controllers
		$Script:Selection.InsertNewPage()
		FindWordDocumentEnd
		Write-Verbose "$(Get-Date -Format G):  Domain Controllers"
		WriteWordLine -Style 2 -Tabs 0 -Name 'Domain Controllers'
		## FIXME - write all domain controller names? Domain? OS Version? Etc.
		FindWordDocumentEnd

		#Domain Controllers - No contact
		$CheckTitle = 'Domain Controllers - No contact in the last 3 months'
		Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
		$TableContent = Get-AllADDomainControllers -Domain $Domain | Where-Object {$_.LastContact -lt (([datetime]::Now).AddMonths(-6))} | Sort-Object -Property LastContact -Descending 
		WriteWordLine -Style 3 -Tabs 0 -Name $CheckTitle
		FindWordDocumentEnd
		Add-TableContent $TableContent $parameters $CheckTitle
		WriteWordLine -Style 0 -Tabs 0 -Name ''
		FindWordDocumentEnd

		#Member Servers
		Write-Verbose "$(Get-Date -Format G):  Member Servers"
		WriteWordLine -Style 2 -Tabs 0 -Name 'Member Servers'
		FindWordDocumentEnd

		#Member Servers - Password never expires
		$CheckTitle = 'Member Servers - Password never expires'
		Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
		$TableContent = Get-AllADMemberServerObjects -Domain $Domain -PasswordNeverExpires | Sort-Object -Property Name
		Add-TableContent $TableContent $parameters $CheckTitle

		#Computers - Password expired
		$CheckTitle = 'Member Servers - Password more than 6 months old'
		Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
		$TableContent = Get-AllADMemberServerObjects -Domain $Domain -PasswordExpiration '6' | Sort-Object -Property Name
		Add-TableContent $TableContent $parameters $CheckTitle

		#Member Servers - Account never expires
		$CheckTitle = 'Member Servers - Account never expires'
		Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
		$TableContent = Get-AllADMemberServerObjects -Domain $Domain -AccountNeverExpires | Sort-Object -Property Name 
		Add-TableContent $TableContent $parameters $CheckTitle

		#Member Servers - Account disabled
		$CheckTitle = 'Member Servers - Account disabled'
		Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
		$TableContent = Get-AllADMemberServerObjects -Domain $Domain -Disabled | Sort-Object -Property Name 
		Add-TableContent $TableContent $parameters $CheckTitle
	}

	If(($parameters.ContainsKey('Users')) -or ($paramset -eq 'All')) 
	{
		#Users
		$Script:Selection.InsertNewPage()
		FindWordDocumentEnd
		Write-Verbose "$(Get-Date -Format G):  Users"
		WriteWordLine -Style 2 -Tabs 0 -Name 'Users'
		FindWordDocumentEnd

		#Users in Domain Local Groups
		$CheckTitle = 'Users - Direct member of a Domain Local Group'
		Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
		$TableContent = Get-ADUsersInDomainLocalGroups -Domain $Domain | Sort-Object -Property Group, Name 
		Add-TableContent $TableContent $parameters $CheckTitle

		#Users - Password never expires
		$CheckTitle = 'Users - Password never expires'
		Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
		$TableContent = Get-ADUserObjects -Domain $Domain -PasswordNeverExpires | Sort-Object -Property Name 
		Add-TableContent $TableContent $parameters $CheckTitle

		#Users - Password not required
		$CheckTitle = 'Users - Password not required'
		Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
		$TableContent = Get-ADUserObjects -Domain $Domain -PasswordNotRequired | Sort-Object -Property Name 
		Add-TableContent $TableContent $parameters $CheckTitle

		#Users - Password needs to be changed at next logon
		$CheckTitle = 'Users - Change password at next logon'
		Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
		$TableContent = Get-ADUserObjects -Domain $Domain -PasswordChangeAtNextLogon | Sort-Object -Property Name 
		Add-TableContent $TableContent $parameters $CheckTitle

		#Users - Password not changed in last 12 months
		$CheckTitle = 'Users - Password not changed in last 12 months'
		Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
		$TableContent = Get-ADUserObjects -Domain $Domain -PasswordExpiration '12' | Sort-Object -Property Name 
		Add-TableContent $TableContent $parameters $CheckTitle

		#Users - Account without expiration date
		$CheckTitle = 'Users - Account without expiration date'
		Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
		$TableContent = Get-ADUserObjects -Domain $Domain -AccountNoExpire | Sort-Object -Property Name 
		Add-TableContent $TableContent $parameters $CheckTitle

		#Users - Do not require kerberos preauthentication
		$CheckTitle = 'Users - Do not require kerberos preauthentication'
		Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
		$TableContent = Get-ADUserObjects -Domain $Domain -NotRequireKerbereosAuthentication | Sort-Object -Property Name 
		Add-TableContent $TableContent $parameters $CheckTitle

		#Users - Disabled
		$CheckTitle = 'Users - Disabled'
		Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
		$TableContent = Get-ADUserObjects -Domain $Domain -Disabled | Sort-Object -Property Name 
		Add-TableContent $TableContent $parameters $CheckTitle
	}

	If(($parameters.ContainsKey('Groups')) -or ($paramset -eq 'All')) 
	{
		#Groups
		Write-Verbose "$(Get-Date -Format G):  Groups"
		$Script:Selection.InsertNewPage()
		FindWordDocumentEnd
		WriteWordLine -Style 2 -Tabs 0 -Name 'Groups'
		FindWordDocumentEnd
		#Privileged Groups
		Write-Verbose "$(Get-Date -Format G):   Groups - Privileged groups"
		$TableContentTemp = Get-PrivilegedGroupsMemberCount -Domains $Domain | Sort-Object -Property Group

		#Groups - Privileged with many members
		$CheckTitle = 'Groups - Privileged - More than 5 members'
		Write-Verbose "$(Get-Date -Format G):    $CheckTitle"
		If($TableContentTemp -ne $null) 
		{
			$TableContent = $TableContentTemp | Where-Object {$_.Members -gt '5'} | Sort-Object -Property Group 
			Add-TableContent $TableContent $parameters $CheckTitle
		}

		#Groups - Privileged with no members
		$CheckTitle = 'Groups - Privileged - No members'
		Write-Verbose "$(Get-Date -Format G):    $CheckTitle"
		If($TableContentTemp -ne $null) 
		{
			$TableContent = $TableContentTemp | Where-Object {$_.Members -eq '0'} | Sort-Object -Property Group 
			Add-TableContent $TableContent $parameters $CheckTitle
		}

		#Groups - Empty
		$CheckTitle = 'Groups - Primary - Empty (no members)'
		Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
		$TableContent = Get-ADEmptyGroups -Domain $Domain | Sort-Object -Property Name 
		Add-TableContent $TableContent $parameters $CheckTitle
	}
	
	$CheckTitle = 'Management'
	Write-Verbose "$(Get-Date -Format G):   $CheckTitle"
	If($parameters.ContainsKey('Mgmt')) 
	{
		If($parameters.ContainsKey('CSV')) 
		{
			Write-ToCSV -Name $CheckTitle -Content $MgmtPage         
		}
		$Script:Selection.InsertNewPage()
		FindWordDocumentEnd
		WriteWordLine -Style 2 -Tabs 0 -Name $CheckTitle
		FindWordDocumentEnd
		Write-ToWord -Name 'Management Table' -TableContent $MgmtPage
	}
}
#endregion Content

###REPLACE BEFORE THIS SECTION WITH YOUR SCRIPT###

Write-Verbose "$(Get-Date -Format G): Finishing up document"
#end of document processing

###Change the two lines below for your script
$AbstractTitle = "AD Health Check Report"
$SubjectTitle = "Active Directory Health Check Report"
UpdateDocumentProperties $AbstractTitle $SubjectTitle

ProcessDocumentOutput

ProcessScriptEnd

If($parameters.ContainsKey('Log')) 
{
	If($Script:StartLog -eq $true) 
	{
		try 
		{
			Stop-Transcript | Out-Null
			Write-Verbose "$(Get-Date -Format G): $Script:LogPath is ready for use"
		} 
		catch 
		{
			Write-Verbose "$(Get-Date -Format G): Transcript/log stop failed"
		}
	}
}

# SIG # Begin signature block
# MIIjkQYJKoZIhvcNAQcCoIIjgjCCI34CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUUJHGAmOWjTT1mEAkmxLfftaK
# vt2ggh3hMIIE/jCCA+agAwIBAgIQDUJK4L46iP9gQCHOFADw3TANBgkqhkiG9w0B
# AQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFz
# c3VyZWQgSUQgVGltZXN0YW1waW5nIENBMB4XDTIxMDEwMTAwMDAwMFoXDTMxMDEw
# NjAwMDAwMFowSDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMu
# MSAwHgYDVQQDExdEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMTCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBAMLmYYRnxYr1DQikRcpja1HXOhFCvQp1dU2UtAxQ
# tSYQ/h3Ib5FrDJbnGlxI70Tlv5thzRWRYlq4/2cLnGP9NmqB+in43Stwhd4CGPN4
# bbx9+cdtCT2+anaH6Yq9+IRdHnbJ5MZ2djpT0dHTWjaPxqPhLxs6t2HWc+xObTOK
# fF1FLUuxUOZBOjdWhtyTI433UCXoZObd048vV7WHIOsOjizVI9r0TXhG4wODMSlK
# XAwxikqMiMX3MFr5FK8VX2xDSQn9JiNT9o1j6BqrW7EdMMKbaYK02/xWVLwfoYer
# vnpbCiAvSwnJlaeNsvrWY4tOpXIc7p96AXP4Gdb+DUmEvQECAwEAAaOCAbgwggG0
# MA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsG
# AQUFBwMIMEEGA1UdIAQ6MDgwNgYJYIZIAYb9bAcBMCkwJwYIKwYBBQUHAgEWG2h0
# dHA6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzAfBgNVHSMEGDAWgBT0tuEgHf4prtLk
# YaWyoiWyyBc1bjAdBgNVHQ4EFgQUNkSGjqS6sGa+vCgtHUQ23eNqerwwcQYDVR0f
# BGowaDAyoDCgLoYsaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJl
# ZC10cy5jcmwwMqAwoC6GLGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFz
# c3VyZWQtdHMuY3JsMIGFBggrBgEFBQcBAQR5MHcwJAYIKwYBBQUHMAGGGGh0dHA6
# Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBPBggrBgEFBQcwAoZDaHR0cDovL2NhY2VydHMu
# ZGlnaWNlcnQuY29tL0RpZ2lDZXJ0U0hBMkFzc3VyZWRJRFRpbWVzdGFtcGluZ0NB
# LmNydDANBgkqhkiG9w0BAQsFAAOCAQEASBzctemaI7znGucgDo5nRv1CclF0CiNH
# o6uS0iXEcFm+FKDlJ4GlTRQVGQd58NEEw4bZO73+RAJmTe1ppA/2uHDPYuj1UUp4
# eTZ6J7fz51Kfk6ftQ55757TdQSKJ+4eiRgNO/PT+t2R3Y18jUmmDgvoaU+2QzI2h
# F3MN9PNlOXBL85zWenvaDLw9MtAby/Vh/HUIAHa8gQ74wOFcz8QRcucbZEnYIpp1
# FUL1LTI4gdr0YKK6tFL7XOBhJCVPst/JKahzQ1HavWPWH1ub9y4bTxMd90oNcX6X
# t/Q/hOvB46NJofrOp79Wz7pZdmGJX36ntI5nePk2mOHLKNpbh6aKLzCCBTEwggQZ
# oAMCAQICEAqhJdbWMht+QeQF2jaXwhUwDQYJKoZIhvcNAQELBQAwZTELMAkGA1UE
# BhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2lj
# ZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENBMB4X
# DTE2MDEwNzEyMDAwMFoXDTMxMDEwNzEyMDAwMFowcjELMAkGA1UEBhMCVVMxFTAT
# BgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEx
# MC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFtcGluZyBD
# QTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAL3QMu5LzY9/3am6gpnF
# OVQoV7YjSsQOB0UzURB90Pl9TWh+57ag9I2ziOSXv2MhkJi/E7xX08PhfgjWahQA
# OPcuHjvuzKb2Mln+X2U/4Jvr40ZHBhpVfgsnfsCi9aDg3iI/Dv9+lfvzo7oiPhis
# EeTwmQNtO4V8CdPuXciaC1TjqAlxa+DPIhAPdc9xck4Krd9AOly3UeGheRTGTSQj
# MF287DxgaqwvB8z98OpH2YhQXv1mblZhJymJhFHmgudGUP2UKiyn5HU+upgPhH+f
# MRTWrdXyZMt7HgXQhBlyF/EXBu89zdZN7wZC/aJTKk+FHcQdPK/P2qwQ9d2srOlW
# /5MCAwEAAaOCAc4wggHKMB0GA1UdDgQWBBT0tuEgHf4prtLkYaWyoiWyyBc1bjAf
# BgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzASBgNVHRMBAf8ECDAGAQH/
# AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcDCDB5BggrBgEF
# BQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBD
# BggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHoweDA6oDigNoY0aHR0cDovL2Ny
# bDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDA6oDig
# NoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNybDBQBgNVHSAESTBHMDgGCmCGSAGG/WwAAgQwKjAoBggrBgEFBQcCARYc
# aHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzALBglghkgBhv1sBwEwDQYJKoZI
# hvcNAQELBQADggEBAHGVEulRh1Zpze/d2nyqY3qzeM8GN0CE70uEv8rPAwL9xafD
# DiBCLK938ysfDCFaKrcFNB1qrpn4J6JmvwmqYN92pDqTD/iy0dh8GWLoXoIlHsS6
# HHssIeLWWywUNUMEaLLbdQLgcseY1jxk5R9IEBhfiThhTWJGJIdjjJFSLK8pieV4
# H9YLFKWA1xJHcLN11ZOFk362kmf7U2GJqPVrlsD0WGkNfMgBsbkodbeZY4UijGHK
# eZR+WfyMD+NvtQEmtmyl7odRIeRYYJu6DC0rbaLEfrvEJStHAgh8Sa4TtuF8QkIo
# xhhWz0E0tmZdtnR79VYzIi8iNrJLokqV2PWmjlIwggWQMIIDeKADAgECAhAFmxtX
# no4hMuI5B72nd3VcMA0GCSqGSIb3DQEBDAUAMGIxCzAJBgNVBAYTAlVTMRUwEwYD
# VQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAf
# BgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0xMzA4MDExMjAwMDBa
# Fw0zODAxMTUxMjAwMDBaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
# ZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsbhA3E
# MB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKy
# unWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGbNOsF
# xl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclPXuU1
# 5zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJB
# MtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFPObUR
# WBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTvkpI6
# nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWMcCxB
# YKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5S
# UUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+x
# q4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjQjBAMA8G
# A1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgGGMB0GA1UdDgQWBBTs1+OC0nFd
# ZEzfLmc/57qYrhwPTzANBgkqhkiG9w0BAQwFAAOCAgEAu2HZfalsvhfEkRvDoaIA
# jeNkaA9Wz3eucPn9mkqZucl4XAwMX+TmFClWCzZJXURj4K2clhhmGyMNPXnpbWvW
# VPjSPMFDQK4dUPVS/JA7u5iZaWvHwaeoaKQn3J35J64whbn2Z006Po9ZOSJTROvI
# XQPK7VB6fWIhCoDIc2bRoAVgX+iltKevqPdtNZx8WorWojiZ83iL9E3SIAveBO6M
# m0eBcg3AFDLvMFkuruBx8lbkapdvklBtlo1oepqyNhR6BvIkuQkRUNcIsbiJeoQj
# YUIp5aPNoiBB19GcZNnqJqGLFNdMGbJQQXE9P01wI4YMStyB0swylIQNCAmXHE/A
# 7msgdDDS4Dk0EIUhFQEI6FUy3nFJ2SgXUE3mvk3RdazQyvtBuEOlqtPDBURPLDab
# 4vriRbgjU2wGb2dVf0a1TD9uKFp5JtKkqGKX0h7i7UqLvBv9R0oN32dmfrJbQdA7
# 5PQ79ARj6e/CVABRoIoqyc54zNXqhwQYs86vSYiv85KZtrPmYQ/ShQDnUBrkG5Wd
# GaG5nLGbsQAe79APT0JsyQq87kP6OnGlyE0mpTX9iV28hWIdMtKgK1TtmlfB2/oQ
# zxm3i0objwG2J5VT6LaJbVu8aNQj6ItRolb58KaAoNYes7wPD1N1KarqE3fk3oyB
# Ia0HEEcRrYc9B9F1vM/zZn4wggawMIIEmKADAgECAhAIrUCyYNKcTJ9ezam9k67Z
# MA0GCSqGSIb3DQEBDAUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
# ZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMTA0MjkwMDAwMDBaFw0zNjA0MjgyMzU5
# NTlaMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8G
# A1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcgUlNBNDA5NiBT
# SEEzODQgMjAyMSBDQTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDV
# tC9C0CiteLdd1TlZG7GIQvUzjOs9gZdwxbvEhSYwn6SOaNhc9es0JAfhS0/TeEP0
# F9ce2vnS1WcaUk8OoVf8iJnBkcyBAz5NcCRks43iCH00fUyAVxJrQ5qZ8sU7H/Lv
# y0daE6ZMswEgJfMQ04uy+wjwiuCdCcBlp/qYgEk1hz1RGeiQIXhFLqGfLOEYwhrM
# xe6TSXBCMo/7xuoc82VokaJNTIIRSFJo3hC9FFdd6BgTZcV/sk+FLEikVoQ11vku
# nKoAFdE3/hoGlMJ8yOobMubKwvSnowMOdKWvObarYBLj6Na59zHh3K3kGKDYwSNH
# R7OhD26jq22YBoMbt2pnLdK9RBqSEIGPsDsJ18ebMlrC/2pgVItJwZPt4bRc4G/r
# JvmM1bL5OBDm6s6R9b7T+2+TYTRcvJNFKIM2KmYoX7BzzosmJQayg9Rc9hUZTO1i
# 4F4z8ujo7AqnsAMrkbI2eb73rQgedaZlzLvjSFDzd5Ea/ttQokbIYViY9XwCFjyD
# KK05huzUtw1T0PhH5nUwjewwk3YUpltLXXRhTT8SkXbev1jLchApQfDVxW0mdmgR
# QRNYmtwmKwH0iU1Z23jPgUo+QEdfyYFQc4UQIyFZYIpkVMHMIRroOBl8ZhzNeDhF
# MJlP/2NPTLuqDQhTQXxYPUez+rbsjDIJAsxsPAxWEQIDAQABo4IBWTCCAVUwEgYD
# VR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUaDfg67Y7+F8Rhvv+YXsIiGX0TkIw
# HwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGG
# MBMGA1UdJQQMMAoGCCsGAQUFBwMDMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcw
# AYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8v
# Y2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBD
# BgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRUcnVzdGVkUm9vdEc0LmNybDAcBgNVHSAEFTATMAcGBWeBDAEDMAgGBmeBDAEE
# ATANBgkqhkiG9w0BAQwFAAOCAgEAOiNEPY0Idu6PvDqZ01bgAhql+Eg08yy25nRm
# 95RysQDKr2wwJxMSnpBEn0v9nqN8JtU3vDpdSG2V1T9J9Ce7FoFFUP2cvbaF4HZ+
# N3HLIvdaqpDP9ZNq4+sg0dVQeYiaiorBtr2hSBh+3NiAGhEZGM1hmYFW9snjdufE
# 5BtfQ/g+lP92OT2e1JnPSt0o618moZVYSNUa/tcnP/2Q0XaG3RywYFzzDaju4Imh
# vTnhOE7abrs2nfvlIVNaw8rpavGiPttDuDPITzgUkpn13c5UbdldAhQfQDN8A+KV
# ssIhdXNSy0bYxDQcoqVLjc1vdjcshT8azibpGL6QB7BDf5WIIIJw8MzK7/0pNVwf
# iThV9zeKiwmhywvpMRr/LhlcOXHhvpynCgbWJme3kuZOX956rEnPLqR0kq3bPKSc
# hh/jwVYbKyP/j7XqiHtwa+aguv06P0WmxOgWkVKLQcBIhEuWTatEQOON8BUozu3x
# GFYHKi8QxAwIZDwzj64ojDzLj4gLDb879M4ee47vtevLt/B3E+bnKD+sEq6lLyJs
# QfmCXBVmzGwOysWGw/YmMwwHS6DTBwJqakAwSEs0qFEgu60bhQjiWQ1tygVQK+pK
# HJ6l/aCnHwZ05/LWUpD9r4VIIflXO7ScA+2GRfS0YW6/aOImYIbqyK+p/pQd52Mb
# OoZWeE4wggdeMIIFRqADAgECAhAFulYuS3p29y1ilWIrK5dmMA0GCSqGSIb3DQEB
# CwUAMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8G
# A1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcgUlNBNDA5NiBT
# SEEzODQgMjAyMSBDQTEwHhcNMjExMjAxMDAwMDAwWhcNMjMxMjA3MjM1OTU5WjBj
# MQswCQYDVQQGEwJVUzESMBAGA1UECBMJVGVubmVzc2VlMRIwEAYDVQQHEwlUdWxs
# YWhvbWExFTATBgNVBAoTDENhcmwgV2Vic3RlcjEVMBMGA1UEAxMMQ2FybCBXZWJz
# dGVyMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA98Xfb+rSvcKK6oXU
# 0jjumwlQCG2EltgTWqBp3yIWVJvPgbbryZB0JNT3vWbZUOnqZxENFG/YxDdR88By
# ukOAeveRE1oeYNva7kbEpQ7vH9sTNiVFsglOQRtSyBch3353BZ51gIESO1sxW9dw
# 41rMdUw6AhxoMxwhX0RTV25mUVAadNzDEuZzTP3zXpWuoAeYpppe8yptyw8OR79A
# d83ttDPLr6o/SwXYH2EeaQu195FFq7Fn6Yp/kLYAgOrpJFJpRxd+b2kWxnOaF5RI
# /EcbLH+/20xTDOho3V7VGWTiRs18QNLb1u14wiBTUnHvLsLBT1g5fli4RhL7rknp
# 8DHksuISIIQVMWVfgFmgCsV9of4ymf4EmyzIJexXcdFHDw2x/bWFqXti/TPV8wYK
# lEaLa2MrSMH1Jrnqt/vcP/DP2IUJa4FayoY2l8wvGOLNjYvfQ6c6RThd1ju7d62r
# 9EJI8aPXPvcrlyZ3y6UH9tiuuPzsyNVnXKyDphJm5I57tLsN8LSBNVo+I227VZfX
# q3MUuhz0oyErzFeKnLsPB1afLLfBzCSeYWOMjWpLo+PufKgh0X8OCRSfq6Iigpj9
# q5KzjQ29L9BVnOJuWt49fwWFfmBOrcaR9QaN4gAHSY9+K7Tj3kUo0AHl66QaGWet
# R7XYTel+ydst/fzYBq6SafVOt1kCAwEAAaOCAgYwggICMB8GA1UdIwQYMBaAFGg3
# 4Ou2O/hfEYb7/mF7CIhl9E5CMB0GA1UdDgQWBBQ5WnsIlilu682kqvRMmUxb5DHu
# gTAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwgbUGA1UdHwSB
# rTCBqjBToFGgT4ZNaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hBMzg0MjAyMUNBMS5jcmwwU6BRoE+G
# TWh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNENvZGVT
# aWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEuY3JsMD4GA1UdIAQ3MDUwMwYGZ4EM
# AQQBMCkwJwYIKwYBBQUHAgEWG2h0dHA6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzCB
# lAYIKwYBBQUHAQEEgYcwgYQwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2lj
# ZXJ0LmNvbTBcBggrBgEFBQcwAoZQaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0VHJ1c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hBMzg0MjAyMUNB
# MS5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAGcm1xuESCj6Y
# VIf55C/gtmnsRJWtf7zEyqUtXhYU+PMciHnjnUbOmuF1+jKTA6j9FN0Ktv33fVxt
# WQ+ZisNssZbfwaUd3goBQatFF2TmUc1KVsRUj/VU+uVPcL++tzaYkDydowhiP+9D
# IEOXOYxunjlwFppOGrk3edKRj8p7puv9sZZTdPiUHmJ1GvideoXTAJ1Db6Jmn6ee
# tnl4m6zx9CCDJF9z8KexKS1bSpJBbdKz71H1PlgI7Tu4ntLyyaRVOpan8XYWmu9k
# 35TOfHHl8Cvbg6itg0fIJgvqnLJ4Huc+y6o/zrvj6HrFSOK6XowdQLQshrMZ2ceT
# u8gVkZsKZtu0JeMpkbVKmKi/7RXIZdh9bn0NhzslioXEX+s70d60kntMsBAQX0Ar
# OpKmrqZZJuxNMGAIXpEwSTeyqu0ujZI9eE1AU7EcZsYkZawdyLmilZdw1qwEQlAv
# EqyjbjY81qtpkORAeJSpnPelUlyyQelJPLWFR0syKsUyROqg5OFXINxkHaJcuWLW
# RPFJOEooSWPEid4rHMftaG2gOPg35o7yPzzHd8Y9pCX2v55NYjLrjUkz9JCjQ/g0
# LiOo3a+yvot+7izsaJEs8SAdhG7RZ/fdsyv+SyyoEzsd1iO/mZ2DQ0rKaU/fiCXJ
# pvrNmEwg+pbeIOCOgS0x5pQ0dyMlBZoxggUaMIIFFgIBATB9MGkxCzAJBgNVBAYT
# AlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQg
# VHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcgUlNBNDA5NiBTSEEzODQgMjAyMSBDQTEC
# EAW6Vi5Lenb3LWKVYisrl2YwCQYFKw4DAhoFAKBAMBkGCSqGSIb3DQEJAzEMBgor
# BgEEAYI3AgEEMCMGCSqGSIb3DQEJBDEWBBSvO9GlS4j48RbU8AW+8QO2Nfb5JDAN
# BgkqhkiG9w0BAQEFAASCAgCu8OwIsZVomiWxuAIlAyWZfZmGHKJh+/8rnzNpEbwu
# GZTwkLVoNSlijylNFdcA1Dx1wGcHM3AAFgiqiwhjuoa9Z+3pwfCw+y8KHdvvoBSv
# qxjrb7fHa3qGS80s8R8kF2iQ8tlxo9Uw0CMr+qcAUoijc6nE4AQ3BAkMZvw8tPXf
# d3mknAnERPO7ueojSA6zGW85wNIpwogpZXaBwlvKvjq9w3KnsIMU+VqwyIODtYWS
# 5Uzhnl0geAL0l6QQDfLj52VH+BpspsXRDUDb3VOqINDCnWFQn+mTMuXJ1h4Cb8bD
# UUDBYzgAaV2h7pliWLUovsEcAeNcf6ms3QtCJsuQ24svMocYYVzGOdcytTc+R6Ij
# 3+ANY0N2JN0PrjyWpAFmazX5Z4+L0BHbH2aHqt7DeAsLDFUlDadpfGmFqmF0sXid
# nWPORk+u7iH2Zhc06SkJ+/pRyeRhd1mpB8FgO0xAL8Ff2r1siRhEKnBJYj4LlkoI
# 2kOgqJ4JVG0/Susq0JI++H4WUXsbQItI5qDheKUn/KGol9UdVlnYGKU2Zb32AhXV
# pQqZuSW0zI4+T1JAkTUjKmgJZcKSHzdgbR9+9t6KofYnBbOQSSdniD2NrFFNn/r1
# nvZUN9PlgUpMcj65pxBIWQdZDlebVKZvlBWnaLwVIKYJgbTSer5iCFa81n4dLItQ
# 16GCAjAwggIsBgkqhkiG9w0BCQYxggIdMIICGQIBATCBhjByMQswCQYDVQQGEwJV
# UzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQu
# Y29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgVGltZXN0YW1w
# aW5nIENBAhANQkrgvjqI/2BAIc4UAPDdMA0GCWCGSAFlAwQCAQUAoGkwGAYJKoZI
# hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjIwMjA3MjAxNTE3
# WjAvBgkqhkiG9w0BCQQxIgQgKca8mmCk/wcENJHKuETayyL3jzLqshlbuJekRBsw
# lSwwDQYJKoZIhvcNAQEBBQAEggEABDFDl4RzBq1qlhs7wydB2jxeEj0S3ML1kbbf
# TJS4Rw+v6goDeCOQoHP4HlA9yNc31kEZgs4T+h3bBktRSmD/6Ibn6tnmyhyTBl61
# 1v3CuqmUoJOsUD1MXJt9ACEi3opWTl5gHqBWIzJefsUitnyzH91OsJkrpG51VbQK
# eThoisyXJxaS4RY+cZkR3tyIXwNcekozYsz48h3qCSI6IYsXz8S1Ju+fQsgC5qkp
# BsuOWbXAXWkomQQySlcNrde6vF+9Zs5jep43qqYJ21qAKbFa9P/QiFnGBPreroWw
# x4pvSiqDJ56Hcy0uLZFoK0zT9Ir5csLUzPns6AeHJcz1CB+flw==
# SIG # End signature block