function Log-Message 
{
    param([string]$message)
    Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $message"
}

function Create-WebConfig 
{
    param(
        [string]$path,
        [string]$content
    )
    try 
    {
        Set-Content -Path $path -Value $content -Encoding UTF8
        Log-Message "Created web.config at $path"
    }
    catch 
    {
        Log-Message "Error creating web.config at $path $_"
        throw $_
    }
}

$basePath = "C:\inetpub\wwwroot\AKVAconnect"

$rootWebConfig = @"
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <staticContent>
            <remove fileExtension=".db" />
            <remove fileExtension=".wasm" />
            <mimeMap fileExtension=".db" mimeType="application/octet-stream" />
            <mimeMap fileExtension=".wasm" mimeType="application/wasm" />
        </staticContent>
        <rewrite>
        <rules>
        <rule name="Vue Router History Mode" stopProcessing="true">
        <match url=".*" />
        <conditions logicalGrouping="MatchAll">
        <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
        <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
        <!-- Exclude files in the 'localization' folder with 'UserManual' in the name -->
        <add input="{REQUEST_URI}" pattern="/localization/.*UserManual.*" negate="true" />
        </conditions>
        <action type="Rewrite" url="/" />
        </rule>
        </rules>
        </rewrite>
    </system.webServer>
</configuration>
"@

$cacheDisableWebConfig = @"
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <staticContent>
            <clientCache cacheControlMode="DisableCache" />
        </staticContent>
    </system.webServer>
</configuration>
"@

Create-WebConfig -path "$basePath\web.config" -content $rootWebConfig
Create-WebConfig -path "$basePath\localization\web.config" -content $cacheDisableWebConfig
Create-WebConfig -path "$basePath\db\web.config" -content $cacheDisableWebConfig

Log-Message "Web.config files creation process completed"