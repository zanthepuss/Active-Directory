Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force 

<# 
.NAME
    AD Account Tool
.SYNOPSIS
    Check User by SamAccountName . Can Unlock User and lock user. Reset Password, enable nad disable user
.DESCRIPTION
    Checks user by SamAccountName. Returns Name, Last LogonDate, LockedOut Status, LockedoutTime, and Enabled Status. Allows User to be unlocked and locked. Locking of user is by increasing badpasswordcount. User is able to reset password for account. Enabling and disabling of Users are allowed.
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$CheckLockTool                   = New-Object system.Windows.Forms.Form
$CheckLockTool.ClientSize        = New-Object System.Drawing.Point(550,160)
$CheckLockTool.text              = "Check Locked Accounts"
$CheckLockTool.TopMost           = $false

$CheckLocked                     = New-Object system.Windows.Forms.Button
$CheckLocked.text                = "Check Locked"
$CheckLocked.width               = 100
$CheckLocked.height              = 30
$CheckLocked.location            = New-Object System.Drawing.Point(200,39)
$CheckLocked.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',8)
$CheckLocked.ForeColor           = [System.Drawing.ColorTranslator]::FromHtml("#000000")
$CheckLocked.BackColor           = [System.Drawing.ColorTranslator]::FromHtml("#fabc47")

$User                            = New-Object system.Windows.Forms.TextBox
$User.multiline                  = $false
$User.width                      = 174
$User.height                     = 25
$User.location                   = New-Object System.Drawing.Point(14,46)
$User.Font                       = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Header                          = New-Object system.Windows.Forms.Label
$Header.text                     = "Enter User"
$Header.AutoSize                 = $true
$Header.width                    = 25
$Header.height                   = 10
$Header.location                 = New-Object System.Drawing.Point(12,26)
$Header.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$UnlockAccount                   = New-Object system.Windows.Forms.Button
$UnlockAccount.text              = "Unlock Account"
$UnlockAccount.width             = 100
$UnlockAccount.height            = 30
$UnlockAccount.location          = New-Object System.Drawing.Point(310,39)
$UnlockAccount.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',8)
$UnlockAccount.BackColor         = [System.Drawing.ColorTranslator]::FromHtml("#81b772")

$LockAccount                     = New-Object system.Windows.Forms.Button
$LockAccount.text                = "Lock Account"
$LockAccount.width               = 100
$LockAccount.height              = 30
$LockAccount.location            = New-Object System.Drawing.Point(420,39)
$LockAccount.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',8)
$LockAccount.BackColor           = [System.Drawing.ColorTranslator]::FromHtml("#e55d5d")

$Header2                         = New-Object system.Windows.Forms.Label
$Header2.text                    = "Set New Password"
$Header2.AutoSize                = $true
$Header2.width                   = 25
$Header2.height                  = 10
$Header2.location                = New-Object System.Drawing.Point(14,87)
$Header2.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Password                        = New-Object system.Windows.Forms.TextBox
$Password.multiline              = $false
$Password.width                  = 174
$Password.height                 = 20
$Password.location               = New-Object System.Drawing.Point(12,109)
$Password.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$SetPassword                     = New-Object system.Windows.Forms.Button
$SetPassword.text                = "Set Password"
$SetPassword.width               = 100
$SetPassword.height              = 30
$SetPassword.location            = New-Object System.Drawing.Point(200,100)
$SetPassword.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',8)

$DIsableAccount                  = New-Object system.Windows.Forms.Button
$DIsableAccount.text             = "Disable Account"
$DIsableAccount.width            = 100
$DIsableAccount.height           = 30
$DIsableAccount.location         = New-Object System.Drawing.Point(310,100)
$DIsableAccount.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',8)

$EnableAccount                   = New-Object system.Windows.Forms.Button
$EnableAccount.text              = "Enable Account"
$EnableAccount.width             = 100
$EnableAccount.height            = 30
$EnableAccount.location          = New-Object System.Drawing.Point(420,100)
$EnableAccount.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',8)

$CheckLockTool.controls.AddRange(@($CheckLocked,$User,$Header,$UnlockAccount,$LockAccount,$Header2,$Password,$SetPassword,$DIsableAccount,$EnableAccount))

$CheckLocked.Add_Click({ CheckLocked })
$UnlockAccount.Add_Click({ UnlockAccount })
$LockAccount.Add_Click({ LockAccount })
$SetPassword.Add_Click({ SetPassword })
$DIsableAccount.Add_Click({ DisableAccount })
$EnableAccount.Add_Click({ EnableAccount })

#region Logic 

#Write your logic code here
function SetPassword { 
    Set-ADAccountPassword -Identity $User.text -NewPassword (ConvertTo-SecureString -AsPlainText $Password.text -Force)
    [System.Windows.MessageBox]::Show('Password Changed')
}

function CheckLocked {

$Result = Get-ADUser -Identity $User.text -Properties Name, LastLogonDate, LockedOut, AccountLockOutTime, Enabled | select Name, LastLogonDate, LockedOut, AccountLockOutTime, Enabled 
$Result | Out-GridView -Title 'Locked Accounts'

    
}

function UnlockAccount { 
    Unlock-ADAccount -Identity $User.text
    
    $Result = Get-ADUser -Identity $User.text -Properties Name, LastLogonDate, LockedOut, AccountLockOutTime, Enabled | select Name, LastLogonDate, LockedOut, AccountLockOutTime, Enabled 
    $Result | Out-GridView -Title 'Unlocked Account'
}

function LockAccount { 
if ($LockoutBadCount = ((([xml](Get-GPOReport -Name "Default Domain Policy" -ReportType Xml)).GPO.Computer.ExtensionData.Extension.Account |
            Where-Object name -eq LockoutBadCount).SettingNumber)) {
 
    $Password = ConvertTo-SecureString 'NotMyPassword' -AsPlainText -Force
 
    Get-ADUser -Identity $User.text -Properties SamAccountName, UserPrincipalName, LockedOut |
        ForEach-Object {
 
            for ($i = 1; $i -le $LockoutBadCount; $i++) { 
 
                Invoke-Command -ComputerName dc01 {Get-Process
                } -Credential (New-Object System.Management.Automation.PSCredential ($($_.UserPrincipalName), $Password)) -ErrorAction SilentlyContinue            
 
            }
 
            $Result = Get-ADUser -Identity $User.text -Properties Name, LastLogonDate, LockedOut, AccountLockOutTime, Enabled | select Name, LastLogonDate, LockedOut, AccountLockOutTime, Enabled 
            $Result | Out-GridView -Title 'Unlocked Account'
        }
}
}

function EnableAccount {
    Enable-ADAccount -Identity $User.text
    $Result = Get-ADUser -Identity $User.text -Properties Name, LastLogonDate, LockedOut, AccountLockOutTime, Enabled | select Name, LastLogonDate, LockedOut, AccountLockOutTime, Enabled 
    $Result | Out-GridView -Title 'Enabled Account'
    }


function DisableAccount { 
    Disable-ADAccount -Identity $User.text
    $Result = Get-ADUser -Identity $User.text -Properties Name, LastLogonDate, LockedOut, AccountLockOutTime, Enabled | select Name, LastLogonDate, LockedOut, AccountLockOutTime, Enabled 
    $Result | Out-GridView -Title 'Disabled Account'
}

#Write-Output
#endregion

[void]$CheckLockTool.ShowDialog()
