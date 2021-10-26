<#
    .DESCRIPTION
        This script will return the specified data to the Client.
    .EXAMPLE
        set-logon.ps1 -RequestArgs $RequestArgs -Body $Body
    .NOTES
        This will return data
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", '')]
param(
    $RequestArgs,
    $Body
)
#decode Body
$body = [System.Web.HttpUtility]::UrlDecode($body)

if ($Body -like '*&*')
{
    # Split the Argument Pairs by the '&' character
    $ArgumentPairs = $Body.split('&')
    $BodyObj = New-Object System.Object
    foreach ($ArgumentPair in $ArgumentPairs)
    {
        # Split the Pair data by the '=' character
        $Property, $Value = $ArgumentPair.split('=')
        $BodyObj | Add-Member -MemberType NoteProperty -Name $Property -value $Value
    }
    # Now we have an RequestObj
}
else
{
    $Property, $Value = $Body.split("=")
}
if ($RequestArgs -like '*&*')
{
    # Split the Argument Pairs by the '&' character
    $ArgumentPairs = $RequestArgs.split('&')
    $RequestObj = New-Object System.Object
    foreach ($ArgumentPair in $ArgumentPairs)
    {
        # Split the Pair data by the '=' character
        $Property, $Value = $ArgumentPair.split('=')
        $RequestObj | Add-Member -MemberType NoteProperty -Name $Property -value $Value
    }
    # Now we have an RequestObj
}
else
{
    #we have only one argument
    if ($RequestArgs)
    {
        $Property, $Value = $RequestArgs.split("=")
    }
}
#execution
$path = resolve-path -path "$($Script:config.AccountsFolder)"
$accounts = get-content $path$($Script:config.AccountsFile) | ConvertFrom-Json

Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message "bodyobj" $BodyObj.email
$account = $accounts | where email -eq $BodyObj.email
if ($account)
{
    $pwhash = get-hashstring($BodyObj.password)
    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message "Request: --$pwhash--"
    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message  "account File: --$($account.password)--"
    #Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message  "compare" (compare-hash $pwhash $account.password) 
    if (compare-hash $pwhash $account.password)
    {
        # add cookie and ID entry
        $script:YeahAuth = $true
        Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message "account.email: $($account.email)"
        $script:sessionId = $(Get-RandomAlphanumericString)   
        invoke-addYeahToken $script:sessionId $account.email
        
        $script:setSession = $true  
        $script:StatusCode = 200
        $script:StatusDescription = "OK"
        return @{Status = "OK" }
    }
    else
    {
        $script:StatusDescription = "Unauthorized"
        $script:StatusCode = 401
        return @{Status = "wrong password" } 
    }
}
else
{
    $script:StatusDescription = "Unauthorized"
    $script:StatusCode = 401
    return @{Status = "user unknown"; User = $BodyObj.email } 
}