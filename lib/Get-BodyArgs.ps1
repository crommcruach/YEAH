<#
.SYNOPSIS
    Parses Body for Arguments and returns an obj or a single  Property and Value
.DESCRIPTION

.NOTES

.LINK
	
#>
function get-BodyArgs($body)
{
    $body = [System.Web.HttpUtility]::UrlDecode($body)
    if ($Body -like '*&*')
    {
        # Split the Argument Pairs by the '&' character
        $ArgumentPairs = $Body.split('&')
        $BodyObj = New-Object System.Object
        foreach ($ArgumentPair in $ArgumentPairs)
        {
            # Split the Pair data by the '=' character
            $Property, $Value = $ArgumentPair.split('=')
            $BodyObj | Add-Member -MemberType NoteProperty -Name $Property -value $Value
        }
        # Now we have an RequestObj
        return $BodyObj
    }
    else
    {
        #we have only one argument
        if ($body)
        {
            $Property, $Value = $body.split("=")
        }
        return $Property, $Value
    }
}