<#
.SYNOPSIS
Installs the IIS Rewrite module if it is not already installed, and checks the current version if it is installed.

.DESCRIPTION
This script checks for the installation of the IIS Rewrite module by querying the registry. If not installed, it proceeds to install the module using a provided MSI installer. It logs each step of the process with time-stamped outputs for tracking progress and troubleshooting.

.PARAMETER registryKeyPath
The registry path where the IIS Rewrite module's installation details are stored.

.PARAMETER installerPath
The file path to the MSI installer for the IIS Rewrite module.
#>

$registryKeyPath = "HKLM:\SOFTWARE\Microsoft\IIS Extensions\URL Rewrite"
$installerPath = ".\PATH\TO\rewrite_amd64_en-US.msi" # Update with correct path for installer file
$timeStamp = Get-Date -Format 'dd-MM-yyyy HH:mm:ss'

Write-Output "$($timeStamp) - Checking IIS Rewrite module installation"

try 
{
    if (Test-Path $registryKeyPath) {
        $version = (Get-ItemProperty -Path $registryKeyPath -Name "Version").Version
        Write-Output "$($timeStamp) - IIS Rewrite module is installed. Version: $version"
    }
    else {
        Write-Output "$($timeStamp) - IIS Rewrite module is not installed. Proceeding with installation."

        $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$installerPath`" /quiet /qn /norestart" -PassThru -Wait -NoNewWindow

        if ($process.ExitCode -eq 0) {
            Write-Output "$($timeStamp) - IIS Rewrite module installed successfully"
        }
        else {
            throw "Installation failed with exit code: $($process.ExitCode)"
        }
    }
}
catch 
{
    Write-Output "$($timeStamp) - Error: $_"
    throw $_
}
