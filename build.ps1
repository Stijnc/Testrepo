import-module -Name psake

FormatTaskName "--------------- {0} ---------------"

Properties {
    $sourcePath = $Env:BUILD_SOURCESDIRECTORY
    $solutionPath = "$Env:BUILD_SOURCESDIRECTORY\Test"
    $artifactPath = $Env:BUILD_ARTIFACTSTAGINGDIRECTORY
    if(-not $artifactPath){
        $artifactPath = $PSScriptRoot
    }
    $siteArtifactPath = "$artifactPath\Site"
}


Task Default -depends Clean, Build

Task Changelog -depends Clean {
    <#  bump up the changelog file based on commit message
        supposed to be run locally - not on build server (as data will not persist)
        --> could write back to git repo if build conditions in VSTS are reality!?
    #>
    $Content = Get-Content "$ProjectRoot\CHANGELOG.md" | Select-Object -Skip 2
        $CommitMessage = git log --format=%B -n 2
        $NewContent = @('# SBS Blueprint Documentation Release History','',"## $($Version)", "### $(Get-Date -Format MM/dd/yyy)", @($CommitMessage),'','',@($Content))
        $NewContent | Out-File -FilePath "$ProjectRoot\CHANGELOG.md" -Force -Encoding ascii
}

Task Build -depends Changelog {
    #build the Site
    Push-Location
    cd $solutionPath
    $mkdocsCmd = 'C:\Program Files (x86)\Python35-32\Scripts\mkdocs.exe'
    $mkdocsArgs = @('build', '--clean', "--site-dir $siteArtifactPath", "--config-file $sourcePath\mkdocs.yml")
    & $cmd $mkdocsArgs
    Pop-Location
}

Task Clean {
    "Start cleaning environment"
    #remove any leftovers - VSTS cleans it automatically
    
    New-Item -Name $siteArtifactPath -ItemType Directory -Force
    Remove-item "$siteArtifactPath\*" -Force -Verbose

    $Error.Clear()
}