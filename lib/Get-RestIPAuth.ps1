function Get-RestIPAuth
{
    if (($script:config.security.ipauthfolder -match "^.")) { $script:config.security.ipauthfolder = "${Psscriptroot}\$($script:config.security.ipauthfolder)" }

    $RestIPAuth = Get-Content("$($script:config.security.ipauthfolder)$($script:config.security.ipauthfile)")
    return $RestIPAuth
}
