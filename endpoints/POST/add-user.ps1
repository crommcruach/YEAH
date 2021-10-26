function add-user($email, $username, $password, $Firstname, $Lastname, $roles)
{
  $newobj = @"
  [
    {
      "email": "blah@localhost.lan",
      "username": "admin",
      "password": "03AC674216F3E15C761EE1A5E255F067953623C8B388B4459E13F978D7C846F4",
      "Firstname": "Anton",
      "Lastname": "Test",
      "roles": [
        "user"
      ]
    }
  ]
"@
  $newobj = $newobj | ConvertFrom-Json
  #$accounts = get-content $path$($Script:config.AccountsFile) | ConvertFrom-Json
  $accounts = get-content "C:\Users\cromm\OneDrive\YEAH\config\yeahUserAuth.json" | ConvertFrom-Json
  if (($accounts.email) -match $newobj.email)
  {
    echo "user already exist"
  }
  else
  {
    echo "adding new user"
    $accounts += $newobj
    echo $accounts
    echo  "backup current file"
    Copy-Item "C:\Users\cromm\OneDrive\YEAH\config\yeahUserAuth.json" "C:\Users\cromm\OneDrive\YEAH\config\yeahUserAuth_bak.json"
    $accounts | ConvertTo-Json | Out-File "C:\temp\testaccounts.json" 
  }
  

  #$accounts
}
add-user