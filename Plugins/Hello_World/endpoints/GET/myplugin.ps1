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

#simple template test
$templatetest = "This is my Templatetesttext"
$jsonObject = @"
{
    TemplateTest: "$templatetest"
}
"@
echo "$($script:config.PluginFolder)\Hello_World\html\hello_world.html"
echo "<img src=""/files/plugins/Hello_World/helloworld.jpg"">"
#run template engine
$content = ConvertTo-PoshstacheTemplate -InputFile "C:\Users\cromm\OneDrive\YEAH\Plugins\Hello_World\html\hello_world.html" -ParametersObject $jsonObject

#output content
if ($content)
{
    $rbody = $rbody + $content
}
return $rbody
