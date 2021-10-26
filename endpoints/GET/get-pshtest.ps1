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

### role needed for access
$role = "admin"
### return argument object or single key value pair ###
$args = get-requestArgs($RequestArgs)

if (test-roles $role)
{
    ### import header ###
    $content += get-header

    ### import ur content goes here: ###
    $content += convertfrom-psh -file "$(resolve-path $script:config.HtmlFolder)\testpsh.psh"

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
}
else
{
    $rbody = "no role access"
}
return $rbody