#region Main
function main()
{
    #self elevate session if not started as admin
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
        exit;
    }
    #import modules
    import-module -name Poshstache
   
    #import JSON config file
    $script:config = get-content("${Psscriptroot}\..\config\config.json") | convertfrom-json

    # Load default Script Libraries
    $libfolder = "${PSScriptRoot}\..\lib"
    Get-ChildItem ($libfolder) | Where-Object { $_.name -like "*.ps1" } | ForEach-Object { 
        try
        {
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message "importing: $($_.name)"
            . $($_.FullName)
        }
        catch
        {
            throw "could not import file: $($_.name)"
        }
    } | Out-Null

    #catch config relative path in folders
    resolve-configpaths

    #load Plugins
    import-pluginset

    #start listener
    Start-YeahListener `
        -Port $script:config.Port `
        -RoutesFilePath "$($script:config.RoutesFolder)$($script:config.RoutesMergedFile)"`
        -YeahLocalRoot $script:config.YeahLocalRoot`
        -SSLThumbprint $script:config.Security.SSLThumbprint`
        -AppGuid $script:config.Security.AppGuid`
        -VerificationType $script:config.Security.VerificationType`
        -VerifyClientIP $script:config.Security.VerifyClientIP`
        -Logfile "$($script:config.LogFolder)$($script:config.LogFile)"`
        -LogLevel $script:config.LogLevel
    #pause
    pause 
}

#region Footer
if ($MyInvocation.InvocationName -ne '.')
{
    main
}
#endregion