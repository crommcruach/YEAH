function test-roles($role)
{
    if (!($role))
    {
        return $true
    }
    else
    {
        $user = $script:sessionData.user
        $path = resolve-path -path "$($Script:config.AccountsFolder)"
        $accounts = get-content $path$($Script:config.AccountsFile) | ConvertFrom-Json
        $account = $accounts | where email -eq $user
        $roles = $account.roles
        if ($role)
        {
            if ($roles.contains($role))
            {
                return $true
            }
            else
            {
                return $false
            }
        }
        else
        {
            return $false
        }
    }
}