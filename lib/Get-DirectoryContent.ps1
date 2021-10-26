<#
.SYNOPSIS
    Generates local Directory HTML Content
.DESCRIPTION
    Returns HTML Content 
.NOTES

.LINK
	
#>
function Get-DirectoryContent
{ 
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'Directory Path')]
        [string]$Path,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Header Name')]
        [string]$HeaderName
    )
    @"
    <html>
    <head>
    <title>$($HeaderName)</title>
    </head>
    <body>
    <h1>$($HeaderName) - $($script:Request.Url.LocalPath)</h1>
    <hr>
"@
    if (!($($script:Request.Url.LocalPath -eq "/files")))
    {
        $parenturl = $($script:Request.Url.LocalPath) -replace ('\/[^\/]*$', '')
    }
    else
    {
        $parenturl = "#"
    }
    @"
    <a href="$parenturl">[To Parent Directory]</a><br><br>
    <table cellpadding="5">
"@
    $Files = (Get-ChildItem "$Path")
    foreach ($File in $Files)
    {
        $FileURL = ($File.FullName -replace [regex]::Escape($($script:Rootfolder)), "" ) -replace "\\", "/"
        $fileURL = "/files/$fileURL"
        if ($file.PSIsContainer) { $FileLength = "[dir]" } else { $FileLength = $File.Length }
        @"
    <tr>
    <td align="right">$($File.LastWriteTime)</td>
    <td align="right">$($FileLength)</td>
    <td align="left"><a href="$($FileURL)">$($File.Name)</a></td>
    </tr>
"@
    }
    @"
    </table>
    <hr>
    </body>
    </html>
"@
}
