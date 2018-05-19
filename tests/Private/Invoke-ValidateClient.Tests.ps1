$script:ModuleName = 'RestPS'
Describe "Invoke-ValidateClient function for $moduleName" {
    function Write-Output {}
    function Invoke-VerifyRootCA {}
    function Invoke-VerifySubject {}
    function Invoke-VerifyUserAuth {}
    It "Should return True if the Client is Validated." {
        Mock -CommandName 'Write-Output' -MockWith {}
        Mock -CommandName 'Invoke-VerifyRootCA' -MockWith {
            $true
        }
        Invoke-ValidateClient -VerificationType VerifyRootCA -RestPSLocalRoot "c:\RestPS" | Should be $true
        Assert-MockCalled -CommandName 'Write-Output' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Invoke-VerifyRootCA' -Times 1 -Exactly
    }
    It "Should return True if the Client is Validated and verified." {
        Mock -CommandName 'Write-Output' -MockWith {}
        Mock -CommandName 'Invoke-VerifySubject' -MockWith {
            $true
        }
        Invoke-ValidateClient -VerificationType VerifySubject -RestPSLocalRoot "c:\RestPS" | Should be $true
        Assert-MockCalled -CommandName 'Write-Output' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Invoke-VerifySubject' -Times 1 -Exactly
    }
    It "Should return True if the Client is Validated, Verified and Authorized." {
        Mock -CommandName 'Write-Output' -MockWith {}
        Mock -CommandName 'Invoke-VerifyUserAuth' -MockWith {
            $true
        }
        Invoke-ValidateClient -VerificationType VerifyUserAuth -RestPSLocalRoot "c:\RestPS" | Should be $true
        Assert-MockCalled -CommandName 'Write-Output' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Invoke-VerifyUserAuth' -Times 1 -Exactly
    }
    It "Should return false if the Client is Validated." {
        Mock -CommandName 'Write-Output' -MockWith {}
        Mock -CommandName 'Invoke-VerifyRootCA' -MockWith {
            $false
        }
        Invoke-ValidateClient -VerificationType VerifyRootCA -RestPSLocalRoot "c:\RestPS" | Should be $false
        Assert-MockCalled -CommandName 'Write-Output' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Invoke-VerifyRootCA' -Times 2 -Exactly
    }
    It "Should return false if the Client is Validated and verified." {
        Mock -CommandName 'Write-Output' -MockWith {}
        Mock -CommandName 'Invoke-VerifySubject' -MockWith {
            $false
        }
        Invoke-ValidateClient -VerificationType VerifySubject -RestPSLocalRoot "c:\RestPS" | Should be $false
        Assert-MockCalled -CommandName 'Write-Output' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Invoke-VerifySubject' -Times 2 -Exactly
    }
    It "Should return false if the Client is Validated, Verified and Authorized." {
        Mock -CommandName 'Write-Output' -MockWith {}
        Mock -CommandName 'Invoke-VerifyUserAuth' -MockWith {
            $false
        }
        Invoke-ValidateClient -VerificationType VerifyUserAuth -RestPSLocalRoot "c:\RestPS" | Should be $false
        Assert-MockCalled -CommandName 'Write-Output' -Times 0 -Exactly
        Assert-MockCalled -CommandName 'Invoke-VerifyUserAuth' -Times 2 -Exactly
    }
    It "Should return True, if no Verification Type is specified." {
        Mock -CommandName 'Write-Output' -MockWith {}
        Invoke-ValidateClient | Should be $true
        Assert-MockCalled -CommandName 'Write-Output' -Times 1 -Exactly
    }
}