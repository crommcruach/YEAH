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
    #we have only one argument
    if ($RequestArgs)
    {
        $Property, $Value = $RequestArgs.split("=")
    }
}


$rbody = "<p>forms:</p><br>"
#main execution

#import header
$header = "<p>Header<p><br>"
$rbody = $header
#import main
if ($Property -eq "name" -and $value -ne "")
{
    $Content = get-content "$(resolve-path $script:config.HtmlFolder)\forms\$value.html"
    if ($content)
    {
        $rbody = $rbody + $content
    }
}
else
{
    $forms = Get-ChildItem "$(resolve-path $script:config.HtmlFolder)\forms" -Filter *.html
    foreach ($form in $forms)
    {
        $str = `
            @"
<a href="/forms?name=$($form.basename)">$($form.basename) $value $property</a></td>
"@   
        $rbody = $rbody + $str
    }
}
#import footer
$footer = "<p>Footer<p>"
$rbody = $rbody + $footer
#return body
return $rbody