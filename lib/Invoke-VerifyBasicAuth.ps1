function Invoke-VerifyBasicAuth
{
	# Basic Authentication
	$RestUserAuth = (Get-RestUserAuth).UserData

	if ($null -ne $RestUserAuth)
	{

		# Get the AuthString from Client Headers
		$ClientHeaders = $script:Request.Headers
		$script:Request | Out-File C:\request.txt
		$ClientHeadersAuth = $ClientHeaders.GetValues("Authorization")
		Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -DEBUG "Client Headers: $ClientHeaders"
		Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType TRACE -DEBUG "Client Headers Auth: $ClientHeadersAuth"
		$AuthType, $AuthString = $ClientHeadersAuth.split(" ")
		Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-VerifyBasicAuth: Auth type is: $AuthType, AuthString is: $AuthString"

		if ($null -ne $AuthString)
		{
			Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message $AuthString
			# Decode the Authorization header if base64
			try { $null = [Convert]::FromBase64String($AuthString); $isbase64 = $true } catch { $isbase64 = $false }
			if ($isbase64)
			{
				$DecodedAuthString = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($AuthString))
			}
			else
			{
				$DecodedAuthString = [Text.Encoding]::UTF8.GetString($AuthString)
			}
			Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType DEBUG -Message $DecodedAuthString
			# Split the decoded auth string, and compare to the $RestUserAuth array
			$RequestUserName, $RequestPass = $DecodedAuthString -split (":")
			$AllowedUser = $RestUserAuth | Where-Object { ($_.UserName -eq "$RequestUserName") -And ($_.SystemAuthString -eq "$RequestPass") }

			if (($AllowedUser | Measure-Object).Count -eq 1)
			{
				Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-VerifyBasicAuth: Client Authorization type: $AuthType is Verified."
				$script:VerifyStatus = $true
			}
			else
			{
				Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-VerifyBasicAuth: Client did not pass Authorization type: $AuthType."
				$script:VerifyStatus = $false
			}

		}
		else
		{
			Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-VerifyBasicAuth: No Authorization String found."
			$script:VerifyStatus = $false
		}
	}
	else
	{
		Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-VerifyBasicAuth: No Authorization data available."
		$script:VerifyStatus = $false
	}
	$script:VerifyStatus
}