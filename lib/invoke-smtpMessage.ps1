function invoke-smtpMessage($message, $subject, $recipient)
{
    
    if ($true)
    {
        $date = get-date -format "ddMMyyyyhhmmss"
        $message | Out-File "$env:TEMP\$recipient$subject$date.html"
        Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message "mock message generated in: $env:TEMP\$recipient$subject$date.html"
    } 
    else 
    {

    }
}
#invoke-smtpMessage "test" "testnachricht" "dennis.blum@test.de"