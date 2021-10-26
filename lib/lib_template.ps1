<#
.SYNOPSIS

.DESCRIPTION

.NOTES

.LINK
	
#>

#region functions
function example()
{
    <#
    .SYNOPSIS
        This function does some fancy stuff.

    .DESCRIPTION

    .PARAMETER test

    .PARAMETER test2

    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", '')]
    param(
        $test,
        $test2
    )
    #exmaple function start

    #exmaple function end
}
#endregion

#region Main
function main()
{
    #if needed self elevate session if not started as admin
    #if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    #{
    #    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
    #    exit;
    #}
    
    #begin benchmark
    #$startms = (get-date).Millisecond
    #Main executions start

    #main executions end
    #benchmark end
    #$endms = (get-date).Millisecond
    #"Runtime: $($endms - $startms ) ms"
    #pause if needed
    #pause 
}
#endregion
#region Footer
if ($MyInvocation.InvocationName -ne '.')
{
    main
}
#endregion