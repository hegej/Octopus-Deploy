<#
.SYNOPSIS
Creates an IIS website for AKVAconnect using AppCmd.exe. Setup to manage potential port conflicts.

.DESCRIPTION
verifies the existence of the 'AKVAconnect' site in IIS. If the site does not exist, it creates a new site with specific settings and configurations. If the site already exists, the script checks for and resolves any port conflicts by adjusting bindings of other sites that might interfere, ensuring the AKVAconnect site can operate on the designated port without issues.

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
$newPort = 8080  # New port
$physicalPath = "C:\inetpub\wwwroot\AKVAconnect"
$timeStamp = Get-Date -Format 'dd-MM-yyyy HH:mm:ss'

$websites = Get-Website

foreach ($site in $websites) 
{
    if ($site.Name -ne $siteName) 
    {
        foreach ($binding in $site.Bindings.Collection) 
        {
            if ($binding.bindingInformation -like "*:$($port):*") 
            {
                $newBindingInfo = $binding.bindingInformation -replace ":$($port):", ":$($newPort):"
                Set-WebBinding -Name $site.Name -BindingInformation $binding.bindingInformation -PropertyName "bindingInformation" -Value $newBindingInfo
                Write-Output "$($timeStamp) - Changed binding of site $($site.Name) from port $($port) to $newPort"
            }
        }
    }
}

$existingSite = Get-Website | Where-Object { $_.Name -eq $siteName }

if ($existingSite) 
{
    Write-Output "$($timeStamp) - Site '$siteName' already exists."
    Stop-Website -Name $siteName
    Start-Sleep -Seconds 2
} 
else 
{
    New-Website -Name $siteName -Port $port -PhysicalPath $physicalPath -Force
    Write-Output "$($timeStamp) - Created new site: $siteName at $physicalPath on port $($port)"
}

Start-Website -Name $siteName
Write-Output "$($timeStamp) - Site '$siteName' started successfully."
Write-Output "$($timeStamp) - IIS site setup completed successfully."
