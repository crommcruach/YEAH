# Break from loop if GET request sent to /shutdown
Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message " Shutting down Yeah Endpoint"
$script:result = "Shutting down Yeah Endpoint."
$script:Status = $false
$script:StatusCode = 200
