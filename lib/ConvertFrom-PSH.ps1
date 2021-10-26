<#
.SYNOPSIS
    Powershell Preprocessor allows to execute Powershell Code in HTML File
.DESCRIPTION
    Just add your PSH Code into yout HTML File with following TAG: <?psh echo "Hello World" ?>
.NOTES
    Very rudimentary implementation but it works in most cases. 
.LINK
	https://github.com/crommcruach/YEAH
#>
function convertfrom-psh($string, $file)
{
    if ($file)
    {
        if (test-path $file)
        {
            $string = [System.IO.File]::ReadAllText($file)
        }
        else
        {
            $string = "File not found"
        }
    }
    $results = $string | select-string '<\?psh((.|\n)*?)\?>' -AllMatches  | ForEach-Object matches  | ForEach-Object Value
    $results | ForEach-Object {
        $in = $_
        $out = Invoke-expression ($_.replace("<?psh", "")).replace("?>", "").trim()
        $string = $string.replace($in, $out)   
    }  
    return $string
}
