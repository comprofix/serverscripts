#Map Network Drive
New-PSDrive -Persist -Name "Z" -PSProvider "FileSystem" -Root "\\NAS\backup" -Confirm:$false

# set variables 
$date = get-Date -UFormat "%d-%m-%Y"
$SourceFolder = "D:\"
$DestinationFolder = "Z:\DATA"
$Logfile = "backup-$date.log"
$EmailParams = @{
    From       = "support@comprofix.com"
    To         = "support@comprofix.com"
    Subject    = "Backup Log $date"
    SMTPServer = "mail.comprofix.local"
    Port   = "25"
}


# copy
ROBOCOPY.EXE $SourceFolder $DestinationFolder /E /J /PURGE /MIR /X /FP /NS /NDL /ETA /TEE /np /LOG:$LogFile /XD "$RECYCLE.BIN" "System Volume Information" ".session"


# build email body
$EmailBody = (Get-Content $Logfile | % { "$_<br/>" -replace "`t","&#09;" -replace " ","&nbsp;" })

#send email
Send-MailMessage @EmailParams -Bodyashtml "<div style='Font-Family:Lucida Console,Courier New,Monospace'>$EmailBody</div>"

#Disconnect Network Drive
Get-PSDrive Z | Remove-PSDrive -Confirm:$false
