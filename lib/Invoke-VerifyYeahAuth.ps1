function Invoke-VerifyYeahAuth
{
    #check if session cookie was send
    $cookies = $script:Request.cookies
    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message "check cookie"
    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message $script:sessions.GetType().BaseType.Name
    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message "cookies: $cookies"
    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message "IDs:" $script:sessions.id
    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message $script:sessions.GetType().BaseType.Name
    $AuthCookie = $cookies | where Name -eq "PSHSESSIONID"
    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message "AuthCookie: $($AuthCookie.value)"
    if ($AuthCookie.value)
    {
        if ($script:sessions)
        {
            if (( $script:sessions.id).contains($AuthCookie.value))
            {
                Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -Message "ID Matches $( $script:sessions.id) -match $($AuthCookie.value)"
                $script:sessionData = $script:sessions | where id -eq $AuthCookie.value
                $script:VerifyStatus = $true
            }
            else
            {
                Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType WARN -Message "ID not Match $( $script:sessions.id) -match $($AuthCookie.value)"
                $script:VerifyStatus = $false
            }
        }
        else
        {
            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType WARN -Message "Empty array"
            $script:VerifyStatus = $false
        }
    }
    else 
    {	
        Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType WARN -Message "No ID"
        $script:VerifyStatus = $false
    }
    $script:VerifyStatus
}
