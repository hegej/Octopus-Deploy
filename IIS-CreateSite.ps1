<#
.SYNOPSIS
Creates an IIS website for AKVAconnect on Windows 10 IoT Enterprise 2019 using AppCmd.exe.

.DESCRIPTION
This script automates the creation and management of an IIS website on systems where the WebAdministration module is not supported. It uses AppCmd.exe to create a website, set properties, and manage its state. The script checks for an existing site, removes it if necessary, and creates a new site with specified bindings and physical path.

.PARAMETER siteName
The name of the website to be created.

.PARAMETER port
The port number on which the website will be hosted.

.PARAMETER physicalPath
The physical path of the website's root directory.

.EXAMPLE
.\CreateIISWebsite.ps1

Creates the AKVAconnect website on port 80 with its files located at C:\inetpub\wwwroot\AKVAconnect.
#>


$siteName = "AKVAconnect"
$port = 80
$physicalPath = "C:\inetpub\wwwroot\AKVAconnect"
$appCmd = "$env:windir\system32\inetsrv\appcmd.exe"

Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Creating IIS site for frontend"

try 
{
    $siteExists = & $appCmd list site "$siteName"
    if ($siteExists) {
        & $appCmd delete site "$siteName"
        Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Removed existing AKVAconnect site"
    }

    & $appCmd add site /name:"$siteName" /bindings:"http/*:$($port):" /physicalPath:"$physicalPath"
    Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Created new AKVAconnect site"

    & $appCmd set site /site.name:"$siteName" /[path='/'].applicationDefaults.preloadEnabled:true

    & $appCmd stop site "$siteName"
    & $appCmd start site "$siteName"
    Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Restarted AKVAconnect site"

    Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - IIS site creation completed successfully"
}
catch 
{
    Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Error: $_"
    throw $_
}