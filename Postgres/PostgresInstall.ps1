<#
.SYNOPSIS
Installs and configures PostgreSQL on a Windows environment, sets up service, and configures access permissions.

.DESCRIPTION
This script downloads the PostgreSQL installer, installs PostgreSQL as a Windows service, and configures the initial settings. It specifies the service name, superuser account details, and data directory. Post-installation, it updates the `pg_hba.conf` file to manage access permissions and restarts the PostgreSQL service to apply changes.

.PARAMETER postgresVersion
The version number of PostgreSQL to install.

.PARAMETER installerUrl
The URL to download the PostgreSQL installer.

.PARAMETER installerPath
The path where the PostgreSQL installer will be saved.

.PARAMETER pgDataPath
The directory path where PostgreSQL data will be stored.

.PARAMETER pgHbaPath
The path to the PostgreSQL host-based authentication configuration file (`pg_hba.conf`).

.PARAMETER serviceName
The name of the Windows service for PostgreSQL.

.PARAMETER superUser
The username for the superuser account of PostgreSQL.

.PARAMETER superPassword
The password for the superuser account. Consider using a secure method to handle the password.

.EXAMPLE
.\InstallPostgreSQL.ps1

Executes the script to install PostgreSQL version 15, configure service and access permissions, tailored for an AkvaConnect environment.
#>

$postgresVersion = "15"  # Version of PostgreSQL to install, should this be a octopus variable?
$installerUrl = "https://get.enterprisedb.com/postgresql/postgresql-$postgresVersion.3-1-windows-x64.exe"
$installerPath = "$env:TEMP\postgresql_installer.exe"
$pgDataPath = "C:\Program Files\PostgreSQL\$postgresVersion\data"
$pgHbaPath = "$pgDataPath\pg_hba.conf"
$timeStamp = Get-Date -Format 'dd-MM-yyyy HH:mm:ss'

$serviceName = "AkvaConnectPostgreSQL"
$superUser = "akvaconnect"
$superPassword = "PASSWORD" # Ensure this is secure, should it be an Environment Variable or octopus tenant variable? 

Write-Output "$($timeStamp) - Downloading PostgreSQL installer"
Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

Write-Output "$($timeStamp) - Installing PostgreSQL"
$installArgs = @(
    "--mode", "unattended",
    "--unattendedmodeui", "minimal",
    "--enable-components", "server",
    "--disable-components", "stackbuilder",
    "--servicename", $serviceName,
    "--superaccount", $superUser,
    "--superpassword", $superPassword,
    "--datadir", $pgDataPath
)

try 
{
    $process = Start-Process -FilePath $installerPath -ArgumentList $installArgs -PassThru -Wait
    if ($process.ExitCode -ne 0) {
        throw "PostgreSQL installation failed with exit code: $($process.ExitCode)"
    }
    Write-Output "$($timeStamp) - PostgreSQL installed successfully"
}
catch 
{
    Write-Output "$($timeStamp) - Error installing PostgreSQL: $_"
    throw $_
}

Write-Output "$($timeStamp) - Configuring pg_hba.conf"
$pgHbaContent = @"
# TYPE  DATABASE        USER            ADDRESS                 METHOD
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
"@

try 
{
    Set-Content -Path $pgHbaPath -Value $pgHbaContent -Force
    Write-Output "$($timeStamp) - pg_hba.conf updated successfully"
}
catch 
{
    Write-Output "$($timeStamp)- Error updating pg_hba.conf: $_"
    throw $_
}

Write-Output "$($timeStamp) - Restarting PostgreSQL service"
try 
{
    Restart-Service -Name $serviceName -Force
    Write-Output "$($timeStamp) - PostgreSQL service restarted successfully"
}
catch 
{
    Write-Output "$($timeStamp) - Error restarting PostgreSQL service: $_"
    throw $_
}

Write-Output "$($timeStamp) - PostgreSQL installation and configuration completed"
