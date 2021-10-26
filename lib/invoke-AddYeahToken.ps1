function invoke-addYeahToken($ID, $user)
{
    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message  "add Session entry"
    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message  "User: " $user "ID:" $ID
    if (!($script:sessions))
    {
        [array]$script:sessions = @()
        
    }
    [array]$script:sessions += @{ID = $ID; user = $user; datetime = (get-date((get-date).AddMinutes($script:config.security.SessionLifetime)) -u %s) }
}