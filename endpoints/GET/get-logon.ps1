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
[string]$content = $null
###return argument object or single key value pair ###
$args = get-requestArgs($RequestArgs)

### import header ###
$content += get-header

### import ur content ###
$url = [System.Web.HttpUtility]::UrlDecode($script:Request.RawUrl)
# example json object for templating
$jsonObject = @"
{
    url: '$url'
}
"@
#run template engine
$content += ConvertTo-PoshstacheTemplate -InputFile "$(resolve-path $script:config.HtmlFolder)\forms\logon.html" -ParametersObject $jsonObject

### import footer ###
$content += get-footer

##### return body #####
if ($content)
{
    $rbody = $content
}
else
{
    $rbody = "empty content"
}
return $rbody
