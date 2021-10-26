<#
.SYNOPSIS

.DESCRIPTION

.NOTES

.LINK
	
#>
function Resolve-ConfigPaths()
{
    $script:config.psobject.Properties | ForEach-Object { 
        if ($_.name -match "folder")
        {
            if (($_.value -match "^."))
            {
                $script:config.$($_.name) = (resolve-path "${Psscriptroot}\$($script:config.$($_.name))").Path 
            }
        } 
    }
}