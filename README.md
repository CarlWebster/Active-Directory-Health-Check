# ADHealthCheck
Active Directory Health Check
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
