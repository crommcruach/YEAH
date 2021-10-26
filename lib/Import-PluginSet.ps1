function import-pluginset()
{  
    import-pluginconfig
    $pluginfolder = $Script:config.PluginFolder
    $plugins = Get-ChildItem $pluginfolder
    $pluginlist = @()
    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message "Listing Plugins:"
    foreach ( $plugin in $plugins)
    {
        $pluginlist += $plugin.name
        #import modules
        Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message  "$($plugin.FullName)\modules"
        $modules = Get-ChildItem "$($plugin.FullName)\modules"
        foreach ($module in $modules)
        {
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message  "Import Module: " $module.FullName
            try
            {
                import-module $module.FullName -Verbose   
            }
            catch
            {
                Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType ERROR -Message  "could not load module"
            }
        } 
        
        #create symlinks
        #lib
        Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message  "$($plugin.FullName)\lib"
        $linkpath = "$($plugin.FullName)\lib"
        $dstfolder = resolve-path -path "${PSScriptRoot}\..\lib\plugins\"
       
        $linkdest = "$dstfolder$($plugin.Name)"
        if (!(test-path $linkdest))
        {
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message "adding lib to $linkdest"
            New-Item -ItemType SymbolicLink -Path $linkdest -Value $linkpath
        }
        
        #html
        Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message "$($plugin.FullName)\html"
        $linkpath = "$($plugin.FullName)\html"
        $dstfolder = "$($script:config.htmlfolder)\plugins\"
        $linkdest = "$dstfolder$($plugin.Name)"
        if (!(test-path $linkdest))
        {
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message "adding html to $linkdest"
            New-Item -ItemType SymbolicLink -Path $linkdest -Value $linkpath
        }   
        
        #files
        Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message "$($plugin.FullName)\files"
        $linkpath = "$($plugin.FullName)\files"
        $dstfolder = "$($script:config.filesfolder)\plugins\"
        $linkdest = "$dstfolder$($plugin.Name)"
        if (!(test-path $linkdest))
        {
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message "adding files to $linkdest"
            New-Item -ItemType SymbolicLink -Path $linkdest -Value $linkpath
        } 
        ######
        Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message "import plugin routes"
        [string]$pluginfile = (get-content "$($Script:config.PluginFolder)$($plugin.Name)\config\routes.json")
        
        $pluginfile = $pluginfile.Replace("./", "$($Script:config.PluginFolder)$($plugin.Name)\")
        $pluginfile = $pluginfile -replace ("\\", "/")
        Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message $pluginfile
        $pluginroute = $pluginfile | convertfrom-json
        Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message $pluginroute.RequestCommand
        $pluginroutes += $pluginroute
    }
    #merge routes
    merge-routes -pluginroutes $pluginroutes
    #remove unused plugins
    remove-plugins -pluginlist $pluginlist
    import-pluginlibs
}

function remove-plugins($pluginlist)
{
    $activeplugins = $pluginlist
    #remove symlinks in files
    $foundplugins = (Get-ChildItem "$($script:config.filesfolder)\plugins").name
    $removeablePlugins = Compare-Object -ReferenceObject $activeplugins -DifferenceObject $foundplugins -PassThru
    echo "remove files plugins"
    foreach ($folder in $removeablePlugins)
    {
        echo $folder
        #TODO Workarround for ondriveFolder first move then delete :(
        Move-Item "$($script:config.filesfolder)\plugins\$folder" "$($env:TEMP)\$folder"
        Remove-Item "$($env:TEMP)\$folder" -force
    }
    #remove symlinks in lib
    $libfolder = resolve-path -path "${PSScriptRoot}\..\lib\plugins\"
    $foundplugins = (Get-ChildItem $libfolder).name
    $removeablePlugins = Compare-Object -ReferenceObject $activeplugins -DifferenceObject $foundplugins -PassThru
    echo "remove files plugins"
    foreach ($folder in $removeablePlugins)
    {
        echo $folder
        #TODO Workarround for ondriveFolder first move then delete :(
        Move-Item "$libfolder$folder" "$($env:TEMP)\$folder"
        Remove-Item "$($env:TEMP)\$folder" -force
    }
    #remove symlinks in html
    $foundplugins = (Get-ChildItem "$($script:config.htmlfolder)\plugins\").name
    $removeablePlugins = Compare-Object -ReferenceObject $activeplugins -DifferenceObject $foundplugins -PassThru
    echo "remove files plugins"
    foreach ($folder in $removeablePlugins)
    {
        echo $folder
        #TODO Workarround for ondriveFolder first move then delete :(
        Move-Item "$($script:config.htmlfolder)\plugins\$folder" "$($env:TEMP)\$folder"
        Remove-Item "$($env:TEMP)\$folder" -force
    }
   
}

function merge-routes($pluginroutes)
{
    $routes = get-content "${Psscriptroot}\..\config\routes.json" | ConvertFrom-Json

    $routes += $pluginroutes
    #TODO: is this a fancy way for unescaping ?
    $routes = $routes | ConvertTo-Json | ForEach-Object { [Regex]::Replace($_, "\\u(?<Value>[a-zA-Z0-9]{4})", { param($m) ([char]([int]::Parse($m.Groups['Value'].Value, [System.Globalization.NumberStyles]::HexNumber))).ToString() } ) }
    #
    $routes | Out-File "$($script:config.RoutesFolder)$($script:config.RoutesMergedFile)"
}

function import-pluginconfig()
{
    #what todo with config?

}

function import-pluginlibs()
{
    $libfolder = "${PSScriptRoot}\..\lib\plugins"
    Get-ChildItem ($libfolder) -recurse | Where-Object { $_.name -like "*.ps1" } | ForEach-Object { 
        try
        {
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message "importing Plugin lib: $($_.name)"
            . $($_.FullName)
            
        }
        catch
        {
            throw "could not import file: $($_.name)"
        }
    } | Out-Null
}