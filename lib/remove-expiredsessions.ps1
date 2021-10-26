function remove-ExpiredSessions()
{   
    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message $script:sessions.datetime "vs"  $(get-date -u %s)
    
    $oldlgt = $script:sessions.Length
    $script:sessions = $script:sessions | where datetime -gt $(get-date -u %s)
    $newlgt = $script:sessions.Length
    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message  "$($oldlgt-$newlgt) of $oldlgt entrys removed"
}