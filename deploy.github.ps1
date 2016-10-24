
Import-Module -Name psake

FormatTaskName "--------------- {0} ---------------"

Properties {
    $buildNumber = $Env:BUILD_BUILDNUMBER
    #$versionNumber = $Env:
    #$commitId = $Env:APPVEYOR_REPO_COMMIT
    #$releaseNotes = $Env:APPVEYOR_REPO_COMMIT_MESSAGE
    #$artifact = 'xunit-build-runner.zip'
    $PSScriptRoot = $Env:AGENT_RELEASEDIRECTORY
    $PSScriptRootParent = (Split-Path -Path $PSScriptRoot -Parent)
    $siteReleaseFolder= "siteGithub"
    $githubToken = $null
    $githubUser = $null
    $githubRepo = $null
    $gitHubApiKey = $null
    $githubUriWithAuth = "https://{1}:{0}@github.com/{1}/{2}" -f $githubToken, $githubUser, $githubRepo
    $githubCommitMessage = "VSTS build $Env:BUILD_BUILDNUMBER pushed"
    $draft = $false
    $preRelease = $true
}


Task Default -depends Clean, Deploy


Task Deploy -depends Clean {
    #deploy the artifact to Github
    Push-Location
    Set-Location -Path $PSScriptRootParent
    git clone $githubUriWithAuth -q
    cd relGithub
    git remote rm origin
    git remote add origin githubUriWithAuth
    Pop-Location
    Copy-Item -Path .\* -Destination ."$PSScriptRootParent\$siteAReleaseFolder\" -Exclude '.git' -Force
    cd "$PSScriptRootParent\$siteAReleaseFolder\"
    git add . -f
    git commit -m $githubCommitMessage -q
    git push -fq origin master
}
<#
Task Release -depends Clean, Deploy {
    #Construct release data
    $releaseData = @{
        tag_name = [string]::Format("v{0}", $versionNumber);
        target_commitish = $commitId;
        name = [string]::Format("v{0}", $versionNumber);
        body = $releaseNotes;
        draft = $draft;
        prerelease = $preRelease;
    }
    #release parameters
    $releaseParams = @{
        Uri = "https://api.github.com/repos/$gitHubUsername/$gitHubRepository/releases";
        Method = 'POST';
        Headers = @{
            Authorization = 'Basic ' + [Convert]::ToBase64String(
            [Text.Encoding]::ASCII.GetBytes($gitHubApiKey + ":x-oauth-basic"));
        }
        ContentType = 'application/json';
        Body = (ConvertTo-Json $releaseData -Compress)
    }
    #create release
    $result = Invoke-RestMethod @releaseParams 
    $uploadUri = $result | Select -ExpandProperty upload_url
    $uploadUri = $uploadUri -replace '\{\?name\}', "?name=$artifact"
    $uploadFile = Join-Path -path $artifactOutputDirectory -childpath $artifact

    #upload file
    $uploadParams = @{
        Uri = $uploadUri;
        Method = 'POST';
        Headers = @{
            Authorization = 'Basic ' + [Convert]::ToBase64String(
            [Text.Encoding]::ASCII.GetBytes($gitHubApiKey + ":x-oauth-basic"));
        }
        ContentType = 'application/zip';
        InFile = $uploadFile
    }
    $result = Invoke-RestMethod @uploadParams
}
#>
Task Clean {
    "Start cleaning environment"
    #remove any leftovers - VSTS cleans it automatically
    Remove-item -Path "$PSScriptRootParent\$siteAReleaseFolder\" -Recurse -Force -Verbose 

    $Error.Clear()
}