function Invoke-StartListener
{
    <#
	.DESCRIPTION
		This function will start a defined HTTP listener.
    .PARAMETER Port
        A Port is required.
    .PARAMETER SSLThumbprint
        An SSLThumbprint is optional.
    .PARAMETER AppGuid
        A AppGuid is Optional.
	.EXAMPLE
        Invoke-StartListener -Port 8080
	.EXAMPLE
        Invoke-StartListener -Port 8080 -SSLThumbPrint $SSLThumbPrint -AppGuid $AppGuid
	.NOTES
        This will return null.
    #>
    param(
        [Parameter(Mandatory = $true)][String]$Port,
        [Parameter()][String]$SSLThumbprint,
        [Parameter()][String]$AppGuid
    )
    if (!($SSLThumbprint -eq ""))
    {
        # Verify the Certificate with the Specified Thumbprint is available.
        $CertificateListCount = ((Get-ChildItem -Path Cert:\LocalMachine -Recurse | Where-Object { $_.Thumbprint -eq "$SSLThumbprint" }) | Measure-Object).Count
        if ($CertificateListCount -ne 0)
        {
            # SSL Thumbprint present, enabling SSL
            netsh http delete sslcert ipport=0.0.0.0:$Port
            netsh http add sslcert ipport=0.0.0.0:$Port certhash=$SSLThumbprint "appid={$AppGuid}"
            $Prefix = "https://"
        }
        else
        {
            Throw "Invoke-StartListener: Could not find Matching Certificate in CertStore: Cert:\LocalMachine"
        }
    }
    else
    {
        # No SSL Thumbprint present
        Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message "Invoke-StartListener: No SSL Thumbprint present"
        $Prefix = "http://"
    }
    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message "$port $prefix"
    try
    {
        $Script:URL = "$prefix$($script:config.servername):$port"
        $listener.Prefixes.Add("$Prefix+:$Port/")
        $listener.Start()
        $Host.UI.RawUI.WindowTitle = "Yeah - $Prefix - Port: $Port"
        Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-StartListener: Starting: $Prefix Listener on Port: $Port"
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Throw "Invoke-StartListener: $ErrorMessage $FailedItem"
    }
}