function set-session($sessionid)
{
    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message "CookieID: $sessionid"
    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message  "setting session cookie"   
    $cookie = New-Object System.Net.Cookie 
    $cookie.Name = "PSHSESSIONID"
    $cookie.Value = $sessionid
    $cookie.Domain = "localhost"
    $cookie.path = "/"
    $cookie.Secure = $true
    $cookie.Expires = (get-date).AddMinutes(60)
    $cookie.HttpOnly = $true
    $script:context.Response.AppendCookie($cookie)
}