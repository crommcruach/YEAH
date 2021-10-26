function start-yeahlistener
{
    <#
    .DESCRIPTION
        Start a HTTP listener on a specified port.
    .PARAMETER Port
        A Port can be specified, but is not required, Default is 8080.
    .PARAMETER SSLThumbprint
        A SSLThumbprint can be specified, but is not required.
    .PARAMETER YeahLocalRoot
        A YeahLocalRoot be specified, but is not required. Default is c:\Yeah
    .PARAMETER AppGuid
        A AppGuid can be specified, but is not required.
    .PARAMETER VerificationType
        A VerificationType is optional - Accepted values are:
           start-yeahlistener -"VerifyRootCA": Verifies the Root CA of the Server and Client Cert Match.
           start-yeahlistener -"VerifySubject": Verifies the Root CA, and the Client is on a User provide ACL.
           start-yeahlistener -"VerifyUserAuth": Provides an option for Advanced Authentication, plus the RootCA,Subject Checks.
           start-yeahlistener -"VerifyBasicAuth": Provides an option for Basic Authentication.
    .PARAMETER RoutesFilePath
        A Custom Routes file can be specified, but is not required, default is included in the module.
    .PARAMETER Logfile
        Full path to a logfile for Yeah messages to be written to.
    .PARAMETER LogLevel
        Level of verbosity of logging for the runtime environment. Default is 'INFO' See PowerLumber Module for details.
    .PARAMETER VerifyClientIP
        Validate client IP authorization. (Default=$false) to enable set $true
    .EXAMPLE
            .EXAMPLE
        start-yeahlistener -Port 8081
    .EXAMPLE
        start-yeahlistener -Port 8081 -Logfe YeahPYeahPSPSPS.log" -LogLevel TRACE
    .EXAMPLE
        start-yeahlistener -Port 8081 -Logfe YeahPYeahPSPSPS.log" -LogLevel INFO
    .EXAMPLE
        start-yeahlistener -Port 8081 -RoutesFilePath $env:SystDrYeahPSPSPS/temp/customRoutes.ps1
    .EXAMPLE
        start-yeahlistener -RoutesFilePath $env:SystDrYeahPSPSPS/customRoutes.ps1
    .EXAMPLE
        start-yeahlistener -RoutesFilePath $env:SystDrYeahPSPSPS/customRoutes.ps1 -VerificationType VerifyRootCA -SSLThumbprint $Thumb -AppGuid $Guid
    .NOTES
        No notes at this time.
    #>
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([boolean])]
    [OutputType([Hashtable])]
    [OutputType([String])]
    param(
        [Parameter()][String]$RoutesFilePath = "$env:SystemDrive/Yeah/endpoints/YeahRoutes.json",
        [Parameter()][String]$YeahLocalRoot = "$env:SystemDrive/Yeah",
        [Parameter()][String]$Port = 8080,
        [Parameter()][String]$SSLThumbprint,
        [Parameter()][String]$AppGuid = ((New-Guid).Guid),
        [ValidateSet("", "VerifyRootCA", "VerifySubject", "VerifyUserAuth", "VerifyBasicAuth", "VerifyYeahAuth")]
        [Parameter()][String]$VerificationType,
        [Parameter()][String]$Logfile = "$env:SystemDrive/Yeah/Yeah.log",
        [ValidateSet("ALL", "TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL", "CONSOLEONLY", "OFF")]
        [Parameter()][String]$LogLevel = "INFO",
        [Parameter()][String]$VerifyClientIP = "false"
    )
    # Set a few Flags
    $script:Status = $true
    $script:ValidateClient = $true
    #stores all valid sessions inkl data
    [array]$script:sessions = @()

    #map psdrive
    $script:rootfolder = Resolve-Path $script:config.FilesFolder
    New-PSDrive -Name FileServe -PSProvider FileSystem -Root $script:rootfolder
    if ($pscmdlet.ShouldProcess("Starting .Net.HttpListener."))
    {
        $script:listener = New-Object System.Net.HttpListener
        Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message " Calling Invoke-StartListener"
        Invoke-StartListener -Port $Port -SSLThumbPrint $SSLThumbprint -AppGuid $AppGuid
        Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message " Finished Calling Invoke-StartListener"
        # Run until you send a GET request to /shutdown
        Do
        {
            #check for expired ids and remove them from array
            remove-ExpiredSessions
            # Capture requests as they come in (not Asyncronous)
            # Routes can be configured to be Asyncronous in Nature.
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message " Captured incoming request"
            $script:Request = Invoke-GetContext
            $script:ProcessRequest = $true
            $script:result = $null
            $script:sessionId = $null
            $script:setSession = $false
            $script:sessionData = $null
            #todo: move up when implemented reload listner
            $script:exceptionList = get-content("$($script:config.UrlauthExceptionFolder)$($($script:config.URLExceptionAuthFile))") | ConvertFrom-Json

            # Perform Client Verification if SSLThumbprint is present and a Verification Method is specified.
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message " Determining VerificationType: '$VerificationType'"
            if ($VerificationType -ne "" -or $VerifyClientIP -eq $true)
            {
                # Validate client IP authorization.
                if ($VerifyClientIP -eq "$true")
                {
                    # Start validation of client IP's.
                    if ($VerificationType -eq "")
                    {
                        Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message " Executing Invoke-ValidateIP Validate IP only"
                        $script:ProcessRequest = (Invoke-ValidateIP -YeahLocalRoot $YeahLocalRoot -VerifyClientIP $VerifyClientIP)
                    }
                    # Validate client IP's and VerificationType.
                    else
                    {
                        Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message " Executing Invoke-ValidateIP Validate IP before Authentication"
                        $script:ProcessRequest = (Invoke-ValidateIP -YeahLocalRoot $YeahLocalRoot -VerifyClientIP $VerifyClientIP)
                        # Determine if client IP validation was successful then start validation of VerificationType.
                        if ($script:ProcessRequest -eq $true)
                        {
                            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message " Executing Invoke-ValidateIP Validate Authentication Type"
                            $script:ProcessRequest = (Invoke-ValidateClient -VerificationType $VerificationType -YeahLocalRoot $YeahLocalRoot)
                        }
                    }
                }
                else
                {
                    # Validate only verification type.
                    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message " Executing Invoke-ValidateClient"
                    $script:ProcessRequest = (Invoke-ValidateClient -VerificationType $VerificationType)
                }
            }
            else
            {
                Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message " NOT Executing Invoke-ValidateClient"
                $script:ProcessRequest = $true
            }
            $script:Request | out-file C:\request.txt
            
            # Request Handler Data
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message " Determining Method and URL"
            $RequestType = $script:Request.HttpMethod
            $RawRequestURL = [System.Web.HttpUtility]::UrlDecode($script:Request.RawUrl)
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message " New Request - Method: $RequestType URL: $RawRequestURL"
            
            # Specific args will need to be parsed in the Route commands/scripts
            $RequestURL, $RequestArgs = $RawRequestURL.split("?")

            # Determine if a Body was sent with the Client request
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message " Executing Invoke-GetBody"
            $script:Body = Invoke-GetBody

            #only process if logged in or user trys to logon
            if (($script:ProcessRequest -eq $true) -or ($RequestURL -match '^/api/auth/logon') -or ($RequestCookie -eq $true) -or (($script:exceptionList.url).contains($RequestURL)))
            {
                if (($script:exceptionList.url).contains($RequestURL))
                {
                    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message "URL: $RequestURL match exception List"
                }
                Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "accessing "
                Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message "Session Data" $script:sessionData.user


                if ($RequestURL -match '^/files')
                {   
                    #access to files
                    Set-Location FileServe:\
                    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message " Processing RequestType: $RequestType URL: $RequestURL Args: $RequestArgs"
                    $script:ResponseContentType, $script:result = Get-LocalDirectoryContent
                    Set-Location $script:config.LocalRoot
                    $script:StatusCode = 200
                } 

                else
                {
                    # Attempt to process the Request.
                    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message " Processing RequestType: $RequestType URL: $RequestURL Args: $RequestArgs"
                    $script:result = Invoke-RequestRouter -RequestType "$RequestType" -RequestURL "$RequestURL" -RoutesFilePath "$RoutesFilePath" -RequestArgs "$RequestArgs"
                    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message " Finished request. StatusCode: $script:StatusCode StatusDesc: $Script:StatusDescription"
                }
            }
            elseif ($VerificationType -eq "VerifyYeahAuth")
            {
                #give user a chance to verify first redirect him to logon page
                $RequestURL = "/auth/logon"
                $RequestType = "GET"
                $script:result = Invoke-RequestRouter -RequestType "$RequestType" -RequestURL "$RequestURL" -RoutesFilePath "$RoutesFilePath" -RequestArgs "$RequestArgs"
                $script:StatusCode = 200
            }
            else
            {
                Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message " Unauthorized (401) NOT Processing RequestType: $RequestType URL: $RequestURL Args: $RequestArgs"
                Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message $VerificationType
                $script:StatusDescription = "Unauthorized"
                $script:StatusCode = 401

            }
            # Stream the output back to requestor.
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message " Streaming response back to requestor."
            Invoke-StreamOutput
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message " Streaming response is complete."
        } while ($script:Status -eq $true)
        #Terminate the listener
        Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message " Stopping Listener."
        Invoke-StopListener -Port $Port
        Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message " Listener Stopped."
    }
    else
    {
        # -WhatIf was used.
        return $false
    }
    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message "Removing PS Drive"
    Remove-PSDrive -Name FileServe
}
