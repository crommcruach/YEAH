function Invoke-ValidateClient
{
    <#
    .DESCRIPTION
        This function provides several way to validate or authenticate a client. A client
        could be a user or a computer.
    .PARAMETER VerificationType
        A VerificationType is optional - Accepted values are:
            -"VerifyRootCA": Verifies the Root CA of the Server and Client Cert Match.
            -"VerifySubject": Verifies the Root CA, and the Client is on a User provide ACL.
            -"VerifyUserAuth": Provides an option for Advanced Authentication, plus the RootCA,Subject Checks.
    .EXAMPLE
        Invoke-ValidateClient -VerificationType VerifyRootCA -RestPSLocalRoot c:\RestPS
    .NOTES
        This will return a boolean.
    #>
    [CmdletBinding()]
    [OutputType([boolean])]
    param(
        [ValidateSet("VerifyRootCA", "VerifySubject", "VerifyUserAuth", "VerifyBasicAuth", "VerifyYeahAuth")]
        [Parameter()][String]$VerificationType
    )
    switch ($VerificationType)
    {
        "VerifyRootCA"
        {
            # Source the File
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-ValidateClient: Gathering Client Cert Info"
            Get-ClientCertInfo
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-ValidateClient: Validating Client CN: $script:SubjectName"
            $script:VerifyStatus = Invoke-VerifyRootCA
        }

        "VerifySubject"
        {
            # Source the File
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-ValidateClient: Gathering Client Cert Info"
            Get-ClientCertInfo
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-ValidateClient: Validating Client CN: $script:SubjectName"

            $script:VerifyStatus = Invoke-VerifySubject
        }

        "VerifyUserAuth"
        {
            # Source the File
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-ValidateClient: Gathering Client Cert Info"
            Get-ClientCertInfo
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-ValidateClient: Validating Client CN: $script:SubjectName"

            $script:VerifyStatus = Invoke-VerifyUserAuth
        }

        "VerifyBasicAuth"
        {
            # Source the File
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-ValidateClient: Validating Basic Auth"

            $script:VerifyStatus = Invoke-VerifyBasicAuth
        }
        "VerifyYeahAuth"
        {
            # Source the File
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-ValidateClient: Validating Yeah Auth"

            $script:VerifyStatus = Invoke-VerifyYeahAuth
        }
        default
        {
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-ValidateClient: No Client Validation Selected."
            $script:VerifyStatus = $true
        }
    }
    $script:VerifyStatus
}
