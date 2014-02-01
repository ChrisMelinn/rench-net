function Get-Tool {
	param
	(
		# GitHub username is mandatory in order to download and/or list available "tools"
		[Parameter(Position=0,Mandatory=$true)]
		[string]$gitHubUserName, 
		
		# not mandatory as will prompt user with list of files from the specified $gitHubUserName's GitHub Account's toolbox    
		[Parameter(Position=1,Mandatory=$false)]
		[string]$fileToDownload 
	)

	# if the user has not already specified the filename/tool to download
	if(!$fileToDownload)
	{
		# Query the specified GitHub user's account for the "toolbox/tools" 
		# folder and  list the available tools/files to download	
		
		$fileToDownload = Prompt-User-To-Select-From-Available-Tools($gitHubUserName)
	}
	
	if($fileToDownload)
	{	
		# Returns a reference to the DTE (Development Tools Environment) for the specified project. 
		# If none is specified, returns the default project selected in the Package Manager Console.
		# Reference:  http://docs.nuget.org/docs/reference/package-manager-console-powershell-reference#Get-Project	
		
		$project = Get-Project
		
		# download the specified file to the root of the project
		$toLocation = Get-Location-At-Root-Of-Project $project $fileToDownload

		Download-From-GitHub-Toolbox $gitHubUserName $fileToDownload $toLocation
		
		Add-File-To-Project $project $toLocation
		
		# open the file in Visual Studio
        # (need to wrap the command in double-quotes for when the toLocation contains spaces)
		$DTE.ExecuteCommand("File.OpenFile", """" + $toLocation + """")
	}
}

function Prompt-User-To-Select-From-Available-Tools($githubUserName) {

	$webResponse = Get-List-Of-GitHub-Tools($githubUserName)
	
	# the GitHub API will returns JSON as a string
	
	$jsonResponse = ToJsonObject($webResponse)
	
	$fileToDownload = Prompt-User-To-Choose-From-Toolbox($jsonResponse)
	
	return $fileToDownload
}

function Prompt-User-To-Choose-From-Toolbox($jsonResponse) {

	if(!$jsonResponse -or !($jsonResponse.Length -gt 0))
    {
        Write-Host `n`t"No tools found in toolbox"`n	
        return $null
    }

	Write-Host `n"Choose a tool:"`n

	$tools = @{}

    # when only 1 object in the response, the json serializer
    # doesn't create the array, just the object
    if($jsonResponse.Length -eq 1)
    {
        $tools[0] = $jsonResponse.name
    }

    if($jsonResponse.Length -gt 1)
	{		
		# Create list of available tools
		for ($i=0; $i -lt $jsonResponse.Length; $i++) 
		{
			# key = toolNumber, value = toolName
			$tools[$i] = $jsonResponse[$i].name
		}
	} 	

	# Display list of tools for selection
	for ($i=0; $i -lt $tools.Count; $i++) 
	{		
		Write-Host `t [$i] $tools[$i]
	}
		
	$strToolNumber = Read-Host `n'Enter Tool # to download'
		
	$toolNumber = $strToolNumber -as [int]
		
	if(!$tools.ContainsKey($toolNumber))
	{		
		Write-Host `n`t"Tool number [$strToolNumber] is not valid"`n
        return $null
	} 

    $fileToDownload = $tools[$toolNumber]
	return $fileToDownload
}

function Get-List-Of-GitHub-Tools($githubUserName) {

	$webClient = Get-WebClient		
	
	try	
	{
		# Note:
		#    PowerShell 3.0 has better APIs (e.g ConvertFrom-Json)
		#    However, at the moment, Package Manager Console uses PowerShell 2.0
		#    Later, if upgrading to 3.0, see https://gist.github.com/altrive/6400978 for good example of usage & API & error handling	
	
		# From: http://developer.github.com/v3/repos/contents/
		# This method returns the contents of a file or directory in a repository.
		# GET /repos/:owner/:repo/contents/:path	
	
		$webResponse = $webClient.DownloadString("https://api.github.com/repos/$githubUserName/toolbox/contents/tools")	
		
		return $webResponse
	} 
	catch [System.Net.WebException] 
	{		
		if ( # check for 404, which, for this call, usually means the GitHub "toolbox/tools" repo+folder could not be found
			($_.Exception.Status -eq [System.Net.WebExceptionStatus]::ProtocolError) -and 
			($_.Exception.Response) -and 
			($_.Exception.Response.StatusCode -eq [System.Net.HttpStatusCode]::NotFound))
		{		
			Write-Host `n"Toolbox not found for GitHub user '$githubUserName'.  Please verify a 'tools' folder exists at https://github.com/$githubUserName/toolbox" `n
			return $null
		} else {
			# rethrow the exception, as other exceptions are not "expected"
			throw
		}
	}	
}

function ToJsonObject($jsonAsString) {

	if(!$jsonAsString)
	{
		return $null
	}

	Add-Type -Assembly System.Web.Extensions # for JavaScriptSerializer
	$javaScriptSerializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
	$jsonObject = $javaScriptSerializer.DeserializeObject($jsonAsString)
	
	return $jsonObject
}
         
function Download-From-GitHub-Toolbox($githubUserName, $fileToDownload, $toLocation) {
	
	Write-Host `n"Downloading:"`n
	Write-Host `t"Tool:" $fileToDownload `n
	Write-Host `t"To Location:" $toLocation `n
		
	# download file from public git repo 

	$uri = New-Object System.Uri "https://raw.github.com/$githubUserName/toolbox/master/tools/$fileToDownload"
	$webClient = Get-WebClient
	
	# if user types invalid	$fileToDownload here, this could get 404
	# could add similar error handling to check for 404, but expect user
	# will generally enter a tool # which "guarantees" a valid file/tool name
	$webClient.DownloadFile($uri, $toLocation)	
}

function Get-WebClient {

	$webClient = New-Object System.Net.WebClient
	
	$webClient.Headers.Add("user-agent", "PowerShell Scripts")  # "user-agent" is required for GitHub API

	$webClient.UseDefaultCredentials = $true ## Proxy credentials only
	$webClient.Proxy.Credentials = $webClient.Credentials
	
	return $webClient
}

function Get-Location-At-Root-Of-Project($project, $fileLocation) {
	$path = [System.IO.Path]
	$projectRoot = $path::GetDirectoryName($project.FileName)
	return $path::Combine($projectRoot, $fileToDownload)
}

function Add-File-To-Project($project, $fileLocation) {
	
	Write-Host `t"Adding to default project:" $project.ProjectName `n
	
	# add the file to the project and save the project
	$projectItems = $project.ProjectItems
	$projectItem = $projectItems.AddFromFile($fileLocation)
	$project.Save($project.FullName)	
}

Register-TabExpansion 'Get-Tool' @{
    'githubUserName' = { 
        "someGithubUserName",
        "chrismelinn",
		"mrmicahcooper"
    }
}

Export-ModuleMember Get-Tool