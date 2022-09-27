import-module ActiveDirectory

$90Days = (get-date).adddays(-90)

Get-ADUser -properties * -filter {(lastlogondate -notlike "*" -OR lastlogondate -le $90days) -AND (passwordlastset -le $90days) -AND (enabled -eq $True) -and (PasswordNeverExpires -eq $false) -and (whencreated -le $90days)} | 

select-object name, SAMaccountname, passwordExpired, PasswordNeverExpires, logoncount, whenCreated, lastlogondate, PasswordLastSet, lastlogontimestamp | 

export-csv c:\users\lmacinnis\Desktop\90days.csv 
