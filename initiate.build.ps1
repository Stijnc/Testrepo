<#  Should be a way to add this directly to the psake script
    and overwrite the default properties?
    Build_artifacts environment variable is missing from BuildHelpers (needs to be added)
    
#>
Write-Output "Initiating build environment"
if(!(Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction Ignore))
{
    Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
}

if (!(Get-PSRepository -Name PSGallery -ErrorAction Ignore))
{
    Register-PSRepository -Name PSGallery -SourceLocation https://www.powershellgallery.com/api/v2/ -InstallationPolicy Trusted -PackageManagementProvider NuGet
}

Write-Output "Installing required resources"
$requiredModules = @(@{Name='Pester';Version='3.4.3'}, @{Name='BuildHelpers';Version='0.0.26'},@{Name='PSake';Version='4.6.0'})

foreach ($Resource in $RequiredModules)
    {
        Install-Module -Name $Resource.Name -RequiredVersion $Resource.Version -Repository 'PSGallery' -Force -Scope CurrentUser
    }

Write-Output "Invoking Psake build script"
Invoke-psake $PSScriptRoot\build.ps1

exit( [int]( -not $psake.build_success))
