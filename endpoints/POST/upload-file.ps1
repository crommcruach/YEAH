<#
    .DESCRIPTION
        This script will return the specified data to the Client.
    .EXAMPLE
        Invoke-GetProcess.ps1 -RequestArgs $RequestArgs -Body $Body
    .NOTES
        This will return data
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", '')]
param(
    $RequestArgs,
    $Body
)
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
    $Property, $Value = $RequestArgs.split("=")
}
#$Body | out-file "c:\testbody.txt"

$content = $body | ConvertFrom-Json
$content.uploadFolder
0..$content.idx | ForEach-Object { 
    $header = @{} 
    $header, $basecode = ($content."files[$_]").Split(",")
    $header = ($header -replace ("base64", ""))
    $Dictionary = @{}
    # Split input string into pairs
    $header.Split(';') | ForEach-Object {
        # Split each pair into key and value
        $key, $value = $_.Split(':')
        # Populate $Dictionary
        $Dictionary[$key] = $value
    }
    $Dictionary.filename
    $file = [Convert]::FromBase64String($basecode)
    [System.IO.File]::WriteAllBytes("c:\temp\$($Dictionary.filename)", $file)

}
return "ok"
