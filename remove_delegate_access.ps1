# this script requires a .csv file with a column of users under the header user Example:
# user
# 

#### select csv from file explorer ####
#load windows forms & create the filebrowser object
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') }
#showing dialog box
$null = $FileBrowser.ShowDialog()
$filepath = $FileBrowser.FileName
#declare array & import list into it
$userList = Import-Csv -Path "$filepath" 

#get account you are setting delegate access for
$delegateAccount = Read-Host "enter delegate account (example@contoso.com) "

#connect to o365, log to the temp directory
Connect-ExchangeOnline -EnableErrorReporting -LogDirectoryPath %TEMP% -LogLevel All

#take users and remove read and manage, as well as send as
$userList | ForEach-Object { 
    $user = $_.user 
    Write-Host "removing delegate permissions for: $user"
    Remove-MailboxPermission -Identity $delegateAccount -User $user -AccessRights FullAccess -InheritanceType All
    Remove-RecipientPermission -Identity $delegateAccount -AccessRights SendAs -Trustee $user -Confirm:$false
}

#write status of setting to keep a copy of messages in the delegates account's sent box
Get-Mailbox -Identity $delegateAccount | Select-Object Name,MessageCopyForSentAsEnabled,MessageCopyForSendOnBehalfEnabled | Format-Table -Auto

#list current delegates to be able to review access
Write-Host "current read and manage users"
Get-MailboxPermission -Identity $delegateAccount | Where-Object {$_.AccessRights -like 'Full*' -and $_.User -notlike "NAMPRD*" -and $_.User -notlike "NT AUTHORITY*" -and $_.User -notlike "S-1-5-21*"} | Format-Table -Auto User,Deny,IsInherited,AccessRights
Write-Host "current send as users"
Get-RecipientPermission -Identity $delegateAccount | Where-Object {$_.Trustee -notlike "NT AUTHORITY*" -and $_.Trustee -notlike "S-1-5-21*"} | Format-Table -Auto Trustee,AccessControlType,IsInherited,AccessRights

#close powershell window
Write-Host "Press Any Key To Exit"
$keyInput = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
(Get-Host).SetShouldExit(0)