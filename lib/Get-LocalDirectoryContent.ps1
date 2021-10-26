function Get-LocalDirectoryContent()
{
    $Content = ""
    $localPath = ($script:Request.Url.LocalPath).replace("/files", "")
    $RequestedItem = Get-Item -LiteralPath "FileServe:\$localpath" -Force -ErrorAction Stop
    $FullPath = $RequestedItem.FullName
    if ($RequestedItem.Attributes -match "Directory")
    {
        #TODO: ?add filter for non browseable folders? Hidden folders from explorer will not shown as browseable only if u enter them directly
        $Content = Get-DirectoryContent -Path $FullPath -HeaderName $Script:config.FilesHeader
        $Encoding = [system.Text.Encoding]::UTF8
        $Content = $Encoding.GetBytes($Content)
        $ContentType = "text/html"
    }
    else
    {
        $Content = [System.IO.File]::ReadAllBytes($FullPath)
        $ContentType = [System.Web.MimeMapping]::GetMimeMapping($FullPath)
    }
    return $ContentType, $Content
}