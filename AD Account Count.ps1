# AD Reporting tool 

Import-Module ActiveDirectory

Clear-Host
$allDisabldAccounts = (Search-ADAccount -AccountDisabled).count
Write-Output "Disabled accounts:`t`t $allDisabldAccounts"
$all = (get-aduser -Filter *).count
$allactive = $all - $allDisabldAccounts
Start-Sleep -Seconds 1 
Write-Output "Active Accounts:`t`t $allactive"
Write-Output "All Accounts:`t`t`t $all"

