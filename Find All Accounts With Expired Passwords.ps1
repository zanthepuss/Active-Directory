Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} -Properties DisplayName, msDS-UserPasswordExpiryTimeComputed | `

Select-Object -Property Displayname,@{Name="Expiration Date";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}} | `

Sort-Object "Expiration Date" | Export-Csv -Path "Export Path" -NoTypeInformation

