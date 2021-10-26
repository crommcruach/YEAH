function get-requestArgs($RequestArgs)
{
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
        return $RequestObj
    }
    else
    {
        #we have only one argument
        if ($RequestArgs)
        {
            $Property, $Value = $RequestArgs.split("=")
            return $Property, $Value
        }
    }
}