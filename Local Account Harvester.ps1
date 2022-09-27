Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

#Variables
$Output = "\\server\Users\username\Documents\CSV Dump\$env:COMPUTERNAME.csv"
$UserName = "username"
$Password = "password" 
$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $Password -ErrorAction SilentlyContinue

# Mount "X" Network Drive 
New-PSDrive -Name "X" -Persist -PSProvider "FileSystem" -Root "\\server\Users\username\Documents\CSV Dump" -Credential $Cred -ErrorAction SilentlyContinue

Get-WMIObject Win32_UserProfile |
Sort LastUseTime | 
Select LocalPath, @{LABEL="Last Used";EXPRESSION={$_.ConvertToDateTime($_.LastUseTime)}} | Export-csv $Output -NoTypeInformation

Get-PSDrive X | Remove-PSDrive -Force
