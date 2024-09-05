<#
.SYNOPSIS
Limits the number of processors that Windows will use at boot.

.DESCRIPTION
This script uses the BCDEdit command to set the 'numproc' option, which limits the number of logical processors the operating system will use. This can be useful for system performance experiments or specific application requirements.

.PARAMETER NumberOfProcessors
The number of processors that the operating system is allowed to use.

.EXAMPLE
.\CoreIsolationSetup.ps1 -NumberOfProcessors 3

Limits the system to use only three processors.
#>

param (
    [Parameter(Mandatory = $true)]
    [int]$NumberOfProcessors = 3
)

function Set-NumberOfProcessors
{
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        Write-Error "You must run PowerShell as Administrator to modify BCDEdit settings."
        return
    }
    
    try
    {
        $output = bcdedit /set numproc $NumberOfProcessors
        if ($output -like "*The operation completed successfully.*")
        {
            Write-Host "Successfully set the number of processors to $NumberOfProcessors."
        }
        else
        {
            Write-Error "Failed to set the number of processors. Error: $output"
        }
    }
    catch
    {
        Write-Error "An error occurred: $_"
    }
}

Set-NumberOfProcessors
