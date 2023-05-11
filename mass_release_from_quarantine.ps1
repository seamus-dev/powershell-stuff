#this is just a simple script to import a csv and use it to release messages from o365 quarantine
#the csv should have a column named messageID with the internet message ID in it (or change stuff so that whatever you want to call that column works
#author: seamus enright

#### select csv from file explorer ####
#load windows forms & create the filebrowser object
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') }
#showing dialog box
$null = $FileBrowser.ShowDialog()
$filepath = $FileBrowser.FileName
#declare array & import list into it
$messageList = Import-Csv -Path "$filepath" 
####         end csv import       ####

#list each message that is being worked on, and then release for all users
$messageList | ForEach-Object {
    Write-Host "working on message: $($_.messageID)"
    Get-QuarantineMessage -MessageID "$($_.messageID)"| Release-QuarantineMessage -ReleaseToAll 
}
