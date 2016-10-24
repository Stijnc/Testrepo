
function Add-GithubRelease {
    # Parameter help description
    [Parameter(mandatory=$true)]
    [ValidateScript({Test-Path -Path $_})]
    [String]   
    $artifact
}




# The version number for this release
$versionNumber = $Env:APPVEYOR_BUILD_VERSION
# The Commit SHA for corresponding to this release
$commitId = $Env:APPVEYOR_REPO_COMMIT
# The notes to accompany this release, uses the commit message in this case
$releaseNotes = $Env:APPVEYOR_REPO_COMMIT_MESSAGE
# The folder artifacts are built to
$artifactOutputDirectory = $Env:APPVEYOR_BUILD_FOLDER
# The name of the file to attach to this release
$artifact = 'xunit-build-runner.zip'
# The github username
$gitHubUsername = 'rhysgodfrey'
# The github repository name
$gitHubRepository = 'team-city-xunit-meta-runner'
# The github API key (https://github.com/blog/1509-personal-api-tokens)
$gitHubApiKey = $Env:GitHubKey
# Set to true to mark this as a draft release (not visible to users)
$draft = $FALSE
# Set to true to mark this as a pre-release version
$preRelease = $TRUE


$releaseData = @{
   tag_name = [string]::Format("v{0}", $versionNumber);
   target_commitish = $commitId;
   name = [string]::Format("v{0}", $versionNumber);
   body = $releaseNotes;
   draft = $draft;
   prerelease = $preRelease;
 }

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

 $result = Invoke-RestMethod @releaseParams 
 $uploadUri = $result | Select -ExpandProperty upload_url
 $uploadUri = $uploadUri -replace '\{\?name\}', "?name=$artifact"
 $uploadFile = Join-Path -path $artifactOutputDirectory -childpath $artifact

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