function Invoke-RequestRouter
{
    <#
    .DESCRIPTION
	This function will attempt to run a Client specified command defined in the Endpoint Routes.
    .PARAMETER RequestType
        A RequestType is required.
    .PARAMETER RequestURL
        A RequestURL is is required.
    .PARAMETER RequestArgs
        A RequestArgs is Optional.
    .PARAMETER RoutesFilePath
        A RoutesFilePath is Optional.
	.EXAMPLE
        Invoke-RequestRouter -RequestType GET -RequestURL /process
	.EXAMPLE
        Invoke-RequestRouter -RequestType GET -RequestURL /process -RoutesFilePath $env:systemdrive/RestPS/endpoints/routes.json
	.EXAMPLE
        Invoke-RequestRouter -RequestType GET -RequestURL /process -RoutesFilePath $env:systemdrive/RestPS/endpoints/routes.json -RequestArgs foo=Bar&cash=Money
	.NOTES
        This will return output from the Endpoint Command/script.
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", '')]
    [OutputType([boolean])]
    [OutputType([Hashtable])]
    param(
        [Parameter(Mandatory = $true)][String]$RequestType,
        [Parameter(Mandatory = $true)][String]$RequestURL,
        [Parameter(Mandatory = $false)][String]$RequestArgs,
        [Parameter()][String]$RoutesFilePath
    )
    # Import Routes each pass, to include new routes.
    #Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-RequestRouter: Importing RouteSet"
    Import-RouteSet -RoutesFilePath $RoutesFilePath
    $Route = ($Routes | Where-Object { $_.RequestType -eq $RequestType -and $_.RequestURL -eq $RequestURL })

    # Set the value of the $script:StatusDescription and $script:StatusCode to null from previous runs.
    $script:StatusDescription = $null
    $script:StatusCode = $null

    if ($null -ne $Route)
    {
        # Process Request
        $RequestCommand = $Route.RequestCommand

        # Grab non-default ResponseContentType for the route:
        $script:ResponseContentType = $Route.ResponseContentType

        set-location $PSScriptRoot
        if ($RequestCommand -like "*.ps1")
        {
            # Execute Endpoint Script
            #Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-RequestRouter: Executing Endpoint Script."
            #add fullendpoint path
            if (!($RequestCommand -match "^C:/"))
            {
                Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message "resolve route path"
                $RequestCommand = "$(Resolve-Path $script:config.EndpointFolder)$RequestType\$RequestCommand"
            }
            else
            {
                Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message "using original pathroute"
                
            }
            $CommandReturn = . $RequestCommand -RequestArgs $RequestArgs -Body $script:Body
        }
        else
        {
            # Execute Endpoint Command (No body allowed.)
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-RequestRouter: Executing Endpoint Command."
            $Command = $RequestCommand + " " + $RequestArgs
            $CommandReturn = Invoke-Expression -Command "$Command" -ErrorAction SilentlyContinue
        }

        if ($null -eq $CommandReturn)
        {
            # Not a valid response
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-RequestRouter: Bad Request (400)."
            if ($null -eq $script:StatusDescription)
            {
                $script:StatusDescription = "Bad Request"
            }
            if ($null -eq $script:StatusCode)
            {
                $script:StatusCode = 400
            }
        }
        else
        {
            # Valid response
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-RequestRouter: Valid Response (200)."
            $script:result = $CommandReturn
            if ($null -eq $script:StatusDescription)
            {
                $script:StatusDescription = "OK"
            }
            if ($null -eq $script:StatusCode)
            {
                $script:StatusCode = 200
            }
        }
    }
    else
    {
        # No matching Routes
        Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-RequestRouter: No Matching routes (404)."
        $script:StatusDescription = "Not Found"
        $script:StatusCode = 404
    }
    $script:result
}
