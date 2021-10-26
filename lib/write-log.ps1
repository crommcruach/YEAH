Write-Verbose 'Importing from [C:\projects\powerlumber\PowerLumber\private]'
# .\PowerLumber\private\Compare-Weekday.ps1
function Compare-Weekday
{
    <#
	.DESCRIPTION
		Determine if the day of the week has changed since the last check.
    .PARAMETER Weekday
        A valid Day of the week is required.
	.EXAMPLE
        Compare-Weekday -Weekday Tuesday
	.NOTES
        It will return boolean
    #>
    [CmdletBinding()]
    [OutputType([boolean])]
    param(
        $Weekday = $null
    )
    if ($null -eq $Weekday)
    {
        # No day was passed in (This is acceptable.)
        Return $false
    }
    else
    {
        $CurrentDay = (Get-Date).DayOfWeek
        if ($CurrentDay -eq $Weekday)
        {
            # The days match.
            $true
        }
        else
        {
            # The days do not match.
            $false
        }
    }
}
# .\PowerLumber\private\Get-Timestamp.ps1
#=============================================================================================
# ____                        _                    _
#|  _ \ _____      _____ _ __| |   _   _ _ __ ___ | |__   ___ _ __
#| |_) / _ \ \ /\ / / _ \ '__| |  | | | | '_ ` _ \| '_ \ / _ \ '__|
#|  __/ (_) \ V  V /  __/ |  | |__| |_| | | | | | | |_) |  __/ |
#|_|   \___/ \_/\_/ \___|_|  |_____\__,_|_| |_| |_|_.__/ \___|_|
#=============================================================================================
function Get-Timestamp
{
    <#
	.SYNOPSIS
		Function to create timestamp.
	.DESCRIPTION
		Returns the current timestamp.
	.EXAMPLE
		$datenow = Get-Timestamp
	.NOTES
		No Additional information about the function or script.
	#>
    try
    {
        return $(get-date).ToString("yyyy-MM-dd HH:mm:ss")
    }
    Catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Throw "Get-Timestamp: $ErrorMessage $FailedItem"
    }
}
#=============================================================================================
#  ___                 _                _         _                        _   _
# |_ _|_ ____   _____ | | _____        / \  _   _| |_ ___  _ __ ___   __ _| |_(_) ___  _ __
#  | || '_ \ \ / / _ \| |/ / _ \_____ / _ \| | | | __/ _ \| '_ ` _ \ / _` | __| |/ _ \| '_ \
#  | || | | \ V / (_) |   <  __/_____/ ___ \ |_| | || (_) | | | | | | (_| | |_| | (_) | | | |
# |___|_| |_|\_/ \___/|_|\_\___|    /_/   \_\__,_|\__\___/|_| |_| |_|\__,_|\__|_|\___/|_| |_|
#=============================================================================================
# .\PowerLumber\private\Write-Message.ps1
#=============================================================================================
# ____                        _                    _
#|  _ \ _____      _____ _ __| |   _   _ _ __ ___ | |__   ___ _ __
#| |_) / _ \ \ /\ / / _ \ '__| |  | | | | '_ ` _ \| '_ \ / _ \ '__|
#|  __/ (_) \ V  V /  __/ |  | |__| |_| | | | | | | |_) |  __/ |
#|_|   \___/ \_/\_/ \___|_|  |_____\__,_|_| |_| |_|_.__/ \___|_|
#=============================================================================================
function Write-Message
{
    <#
	.SYNOPSIS
		Function to write log files, option to print to console.
	.DESCRIPTION
		Writes messages to log file and optional console.
	.PARAMETER Message
		Please Specify a message.
	.PARAMETER Logfile
		Please Specify a valid logfile.
	.PARAMETER OutputStyle
		Please specify an output OutputStyle.
	.EXAMPLE
		Write-Message -Message "I love lamp" -Logfile "C:\temp\mylog.log" -OutputStyle noConsole
	.EXAMPLE
		Write-Message -Message "I love lamp" -Logfile "C:\temp\mylog.log" -OutputStyle both
	.EXAMPLE
		Write-Message -Message "I love lamp" -Logfile "C:\temp\mylog.log" -OutputStyle consoleOnly
	.EXAMPLE
		Write-Message -Message "I love lamp" -Logfile "C:\temp\mylog.log"
	.EXAMPLE
		Write-Message -Message "I love lamp" -OutputStyle ConsoleOnly
	.NOTES
		No Additional information about the function or script.
	#>
    [CmdletBinding(DefaultParameterSetName = 'LogFileFalse')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'LogFileTrue')]
        [Parameter(Mandatory = $true, ParameterSetName = 'LogFileFalse')]
        [string]$Message,
        [Parameter(Mandatory = $true, ParameterSetName = 'LogFileTrue')]
        [string]$Logfile,
        [Parameter(Mandatory = $false, ParameterSetName = 'LogFileTrue')]
        [Parameter(Mandatory = $true, ParameterSetName = 'LogFileFalse')]
        [validateset('ConsoleOnly', 'Both', 'noConsole', 'None', IgnoreCase = $true)]
        [string]$OutputStyle
    )
    try
    {
        $dateNow = Get-Timestamp
        switch ($OutputStyle)
        {
            ConsoleOnly
            {
                Write-Output ""
                Write-Output "$dateNow $Message"
            }
            None
            {
                # Do Nothing
            }
            Both
            {
                Write-Output ""
                Write-Output "$dateNow $Message"
                if (!(Test-Path $logfile -ErrorAction SilentlyContinue))
                {
                    Write-Warning "Logfile does not exist."
                    New-Log -Logfile $Logfile
                }
                Write-Output "$dateNow $Message" | Out-File $Logfile -append -encoding ASCII
            }
            noConsole
            {
                if (!(Test-Path $logfile -ErrorAction SilentlyContinue))
                {
                    Write-Warning "Logfile does not exist."
                    New-Log -Logfile $Logfile
                }
                Write-Output "$dateNow $Message" | Out-File $Logfile -append -encoding ASCII
            }
            default
            {
                Write-Output ""
                Write-Output "$dateNow $Message"
                if (!(Test-Path $logfile -ErrorAction SilentlyContinue))
                {
                    Write-Warning "Logfile does not exist."
                    New-Log -Logfile $Logfile
                }
                Write-Output "$dateNow $Message" | Out-File $Logfile -append -encoding ASCII
            }
        }
    }
    Catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Throw "Write-Message: $ErrorMessage $FailedItem"
    }
}
#=============================================================================================
#  ___                 _                _         _                        _   _
# |_ _|_ ____   _____ | | _____        / \  _   _| |_ ___  _ __ ___   __ _| |_(_) ___  _ __
#  | || '_ \ \ / / _ \| |/ / _ \_____ / _ \| | | | __/ _ \| '_ ` _ \ / _` | __| |/ _ \| '_ \
#  | || | | \ V / (_) |   <  __/_____/ ___ \ |_| | || (_) | | | | | | (_| | |_| | (_) | | | |
# |___|_| |_|\_/ \___/|_|\_\___|    /_/   \_\__,_|\__\___/|_| |_| |_|\__,_|\__|_|\___/|_| |_|
#=============================================================================================
Write-Verbose 'Importing from [C:\projects\powerlumber\PowerLumber\public]'
# .\PowerLumber\public\Clear-LogDirectory.ps1
#=============================================================================================
# ____                        _                    _
#|  _ \ _____      _____ _ __| |   _   _ _ __ ___ | |__   ___ _ __
#| |_) / _ \ \ /\ / / _ \ '__| |  | | | | '_ ` _ \| '_ \ / _ \ '__|
#|  __/ (_) \ V  V /  __/ |  | |__| |_| | | | | | | |_) |  __/ |
#|_|   \___/ \_/\_/ \___|_|  |_____\__,_|_| |_| |_|_.__/ \___|_|
#=============================================================================================
function Clear-LogDirectory
{
    <#
	.SYNOPSIS
		Clears logs in a directory older than the specified number of days.
	.DESCRIPTION
		Clears logs in a directory older than the specified number of days.
	.PARAMETER Path
		Please Specify a valid path.
	.PARAMETER Daysback
		Please Specify a number of daysback.
	.EXAMPLE
		Clear-LogDirectory -Path "c:\temp" -DaysBack 3
	.NOTES
		No Additional information about the function or script.
	#>
    param(
        [cmdletbinding()]
        [Parameter(Mandatory = $true)]
        [ValidateScript( { Test-Path $_ })]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [int]$DaysBack
    )
    try
    {
        $DatetoDelete = (Get-Date).AddDays( - $Daysback)
        if (! (Get-ChildItem $Path))
        {
            Write-Message -Message "Path is not valid" -OutputStyle consoleOnly
        }
        else
        {
            Get-ChildItem $Path -Recurse  | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item -Recurse -Confirm:$false
            Write-Message -Message "Logs older than $DaysBack have been cleared!" -OutputStyle consoleOnly
        }
    }
    Catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Throw "Clear-LogDirectory: $ErrorMessage $FailedItem"
    }
}
#=============================================================================================
#  ___                 _                _         _                        _   _
# |_ _|_ ____   _____ | | _____        / \  _   _| |_ ___  _ __ ___   __ _| |_(_) ___  _ __
#  | || '_ \ \ / / _ \| |/ / _ \_____ / _ \| | | | __/ _ \| '_ ` _ \ / _` | __| |/ _ \| '_ \
#  | || | | \ V / (_) |   <  __/_____/ ___ \ |_| | || (_) | | | | | | (_| | |_| | (_) | | | |
# |___|_| |_|\_/ \___/|_|\_\___|    /_/   \_\__,_|\__\___/|_| |_| |_|\__,_|\__|_|\___/|_| |_|
#=============================================================================================
# .\PowerLumber\public\Invoke-RollLog.ps1
function Invoke-RollLog
{
    <#
	.DESCRIPTION
		This function will Roll the log file if it is a new week day.
    .PARAMETER LogFile
        A valid file path is required.
    .PARAMETER Weekday
        A valid Weekday in datetime format is required.
	.EXAMPLE
        Invoke-RollLogs -LogFile "c:\temp\test.log" -Weekday Tuesday
	.NOTES
        It's pretty simple.
    #>
    [CmdletBinding()]
    [OutputType([boolean])]
    param(
        [Parameter(Mandatory = $true)][string]$Logfile,
        [Parameter(Mandatory = $true)][string]$Weekday

    )
    try
    {
        if (!(Test-Path -Path $Logfile))
        {
            Write-Message -Message "#################### New Log created #####################" -Logfile $logfile -OutputStyle both
            Throw "LogFile path: $Logfile does not exist."
        }
        else
        {
            # Determine if its a new day
            if (Compare-Weekday -Weekday $Script:Weekday)
            {
                # The Day of the week has not changed.
                Return $true
            }
            else
            {
                # The day of the week has changed.
                $CurrentTime = Get-Date -Format MMddHHmm
                $OldLogName = "$currentTime.log"
                Rename-Item -Path $logfile -NewName $OldLogName -Force -Confirm:$false
                # Create a new log.
                Write-Message -Message "#################### New Log created #####################" -Logfile $logfile
            }
        }
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Throw "Invoke-RollLog: $ErrorMessage $FailedItem"
    }
}
# .\PowerLumber\public\New-Log.ps1
#=============================================================================================
# ____                        _                    _
#|  _ \ _____      _____ _ __| |   _   _ _ __ ___ | |__   ___ _ __
#| |_) / _ \ \ /\ / / _ \ '__| |  | | | | '_ ` _ \| '_ \ / _ \ '__|
#|  __/ (_) \ V  V /  __/ |  | |__| |_| | | | | | | |_) |  __/ |
#|_|   \___/ \_/\_/ \___|_|  |_____\__,_|_| |_| |_|_.__/ \___|_|
#=============================================================================================
function New-Log
{
    <#
	.SYNOPSIS
		Clears logs in a directory older than the specified number of days.
	.DESCRIPTION
		Clears logs in a directory older than the specified number of days.
	.PARAMETER Logfile
		Please Specify a valid path and file name.
	.EXAMPLE
		New-Log -Logfile c:\temp\new.log
	.NOTES
		No Additional information about the function or script.
	#>
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Logfile
    )
    try
    {
        if ( !(Split-Path -Path $Logfile -ErrorAction SilentlyContinue))
        {
            Write-Message -Message "Creating new Directory." -OutputStyle consoleOnly
            if ($PSCmdlet.ShouldProcess("Creating new Directory")) { New-Item (Split-Path -Path $Logfile) -ItemType Directory -Force }
        }
        Write-Message -Message "Creating new file." -OutputStyle consoleOnly
        if ($PSCmdlet.ShouldProcess("Creating new File")) { New-Item $logfile -type file -force -value "New file created." }
    }
    Catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Throw "New-Log: $ErrorMessage $FailedItem"
    }
}
#=============================================================================================
#  ___                 _                _         _                        _   _
# |_ _|_ ____   _____ | | _____        / \  _   _| |_ ___  _ __ ___   __ _| |_(_) ___  _ __
#  | || '_ \ \ / / _ \| |/ / _ \_____ / _ \| | | | __/ _ \| '_ ` _ \ / _` | __| |/ _ \| '_ \
#  | || | | \ V / (_) |   <  __/_____/ ___ \ |_| | || (_) | | | | | | (_| | |_| | (_) | | | |
# |___|_| |_|\_/ \___/|_|\_\___|    /_/   \_\__,_|\__\___/|_| |_| |_|\__,_|\__|_|\___/|_| |_|
#=============================================================================================
# .\PowerLumber\public\Write-Log.ps1
#=============================================================================================
# ____                        _                    _
#|  _ \ _____      _____ _ __| |   _   _ _ __ ___ | |__   ___ _ __
#| |_) / _ \ \ /\ / / _ \ '__| |  | | | | '_ ` _ \| '_ \ / _ \ '__|
#|  __/ (_) \ V  V /  __/ |  | |__| |_| | | | | | | |_) |  __/ |
#|_|   \___/ \_/\_/ \___|_|  |_____\__,_|_| |_| |_|_.__/ \___|_|
#=============================================================================================
function Write-Log
{
    <#
	.SYNOPSIS
		Function to write information to  log files, based on a set LogLevel.
	.DESCRIPTION
        Writes messages to log file based on a set LogLevel.
        -LogLevel is the System Wide setting.
        -MsgType is specific to a message.
	.PARAMETER Message
		Please Specify a message.
	.PARAMETER Logfile
		Please Specify a valid logfile.
	.PARAMETER LogLevel
		Please specify a Running Log Level.
	.PARAMETER MsgType
		Please specify a Message Log Level.
	.EXAMPLE
		Write-Log -Message "I love lamp" -Logfile "C:\temp\mylog.log" -LogLevel All -MsgType TRACE
	.EXAMPLE
		Write-Log -Message "I love lamp" -Logfile "C:\temp\mylog.log" -LogLevel TRACE -MsgType TRACE
	.EXAMPLE
		Write-Log -Message "I love lamp" -Logfile "C:\temp\mylog.log" -LogLevel DEBUG -MsgType DEBUG
	.EXAMPLE
		Write-Log -Message "I love lamp" -Logfile "C:\temp\mylog.log" -LogLevel INFO -MsgType INFO
	.EXAMPLE
		Write-Log -Message "I love lamp" -Logfile "C:\temp\mylog.log" -LogLevel WARN -MsgType WARN
	.EXAMPLE
		Write-Log -Message "I love lamp" -Logfile "C:\temp\mylog.log" -LogLevel ERROR -MsgType ERROR
	.EXAMPLE
		Write-Log -Message "I love lamp" -Logfile "C:\temp\mylog.log" -LogLevel FATAL -MsgType FATAL
	.EXAMPLE
		Write-Log -Message "I love lamp" -Logfile "C:\temp\mylog.log" -LogLevel CONSOLEONLY -MsgType CONSOLEONLY
	.EXAMPLE
		Write-Log -Message "I love lamp" -Logfile "C:\temp\mylog.log" -LogLevel OFF -MsgType OFF
	.NOTES
		No Additional information about the function or script.
	#>
    [CmdletBinding(DefaultParameterSetName = 'LogFileFalse')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'LogFileTrue')]
        [Parameter(Mandatory = $true, ParameterSetName = 'LogFileFalse')]
        [string]$Message,
        [Parameter(Mandatory = $true, ParameterSetName = 'LogFileTrue')]
        [string]$Logfile,
        [Parameter(Mandatory = $true, ParameterSetName = 'LogFileTrue')]
        [Parameter(Mandatory = $true, ParameterSetName = 'LogFileFalse')]
        [ValidateSet("ALL", "TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL", "CONSOLEONLY", "OFF")]
        [string]$LogLevel,
        [Parameter(Mandatory = $true, ParameterSetName = 'LogFileTrue')]
        [Parameter(Mandatory = $true, ParameterSetName = 'LogFileFalse')]
        [ValidateSet("TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL", "CONSOLEONLY")]
        [string]$MsgType
    )
    try
    {
        switch ($LogLevel)
        {
            ALL
            {
                $OutPutStyle = "Both"
            }
            TRACE
            {
                $OutPutStyle = "Both"
            }
            OFF
            {
                $OutPutStyle = "None"
            }
            CONSOLEONLY
            {
                $OutPutStyle = "ConsoleOnly"
            }
            default
            {
                if (($LogLevel -eq "DEBUG") -and ($MsgType -ne "TRACE") -and ($MsgType -ne "CONSOLEONLY"))
                {
                    $OutPutStyle = "Both"
                }
                elseif (($LogLevel -eq "INFO") -and ($MsgType -ne "TRACE") -and ($MsgType -ne "DEBUG") -and ($MsgType -ne "CONSOLEONLY"))
                {
                    $OutPutStyle = "Both"
                }
                elseif (($LogLevel -eq "WARN") -and ($MsgType -ne "TRACE") -and ($MsgType -ne "DEBUG") -and ($MsgType -ne "INFO") -and ($MsgType -ne "CONSOLEONLY"))
                {
                    $OutPutStyle = "Both"
                }
                elseif (($LogLevel -eq "ERROR") -and ($MsgType -ne "TRACE") -and ($MsgType -ne "DEBUG") -and ($MsgType -ne "INFO") -and ($MsgType -ne "WARN") -and ($MsgType -ne "CONSOLEONLY"))
                {
                    $OutPutStyle = "Both"
                }
                elseif (($LogLevel -eq "FATAL") -and ($MsgType -ne "TRACE") -and ($MsgType -ne "DEBUG") -and ($MsgType -ne "INFO") -and ($MsgType -ne "WARN") -and ($MsgType -ne "ERROR") -and ($MsgType -ne "CONSOLEONLY"))
                {
                    $OutPutStyle = "Both"
                }
                else
                {
                    $OutPutStyle = "ConsoleOnly"
                }
            }
        }
        $Message = $MsgType + ": " + $Message
        if (($Logfile -eq "") -or ($null -eq $logfile))
        {
            Write-Message -Message $Message -OutputStyle $OutPutStyle
        }
        else
        {
            Write-Message -Message $Message -Logfile $Logfile -OutputStyle $OutPutStyle
        }
    }
    Catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Throw "Write-Log: $ErrorMessage $FailedItem"
    }
}
#=============================================================================================
#  ___                 _                _         _                        _   _
# |_ _|_ ____   _____ | | _____        / \  _   _| |_ ___  _ __ ___   __ _| |_(_) ___  _ __
#  | || '_ \ \ / / _ \| |/ / _ \_____ / _ \| | | | __/ _ \| '_ ` _ \ / _` | __| |/ _ \| '_ \
#  | || | | \ V / (_) |   <  __/_____/ ___ \ |_| | || (_) | | | | | | (_| | |_| | (_) | | | |
# |___|_| |_|\_/ \___/|_|\_\___|    /_/   \_\__,_|\__\___/|_| |_| |_|\__,_|\__|_|\___/|_| |_|
#=============================================================================================
Write-Verbose 'Importing from [C:\projects\powerlumber\PowerLumber\classes]'

