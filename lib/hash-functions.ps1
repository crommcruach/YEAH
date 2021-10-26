function get-hashfile($path, $algorithm)
{
    if ($algorithm)
    {
        $hash = $(get-filehash -path $path -algorithm $algorithm).hash
    }
    else
    {
        $hash = $(get-filehash -path $path).hash
    }   
    return $hash
}
function get-hashstring($string, $algorithm)
{
    $stringAsStream = [System.IO.MemoryStream]::new()
    $writer = [System.IO.StreamWriter]::new($stringAsStream)
    $writer.write("$string")
    $writer.Flush()
    $stringAsStream.Position = 0
    if ($algorithm)
    {
        $result = Get-FileHash -InputStream $stringAsStream -Algorithm $algorithm | Select-Object Hash 
    }
    else
    {
        $result = Get-FileHash -InputStream $stringAsStream | Select-Object Hash 
    }
    return $result.hash
}
function compare-hash($a, $b)
{
    If ($a -eq $b)
    {
        return $true
    }
    else
    {
        return $false
    }
}
function main()
{
    #self elevate session if not started as admin
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
        exit;
    }
    #begin benchmark
    $startms = (get-date).Millisecond
    #executions start
    #executions end
    #benchmark end
    $endms = (get-date).Millisecond
    "Runtime: $($endms - $startms ) ms"
    #pause
    pause
}
if ($MyInvocation.InvocationName -ne '.')
{
    main
}