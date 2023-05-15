#check for and remove calendar entry from list of users
# author: seamus enright
# author's note: I am not an expert
# example of a search query: Kind:meetings and from:malicious_sender@outlook.com
# example target mailbox ADMINACCOUNT@contoso.com (this will be where it goes to die)

#### select csv from file explorer ####
#load windows forms & create the filebrowser object
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') }
#showing dialog box
$null = $FileBrowser.ShowDialog()
$filepath = $FileBrowser.FileName
#declare array & import list into it
$userList = Import-Csv -Path "$filepath"

Connect-ExchangeOnline
#get the name of the calendar event
#possibly get the sender of the invite?

#this will force prompt for these, so we never go without the info we need
param (
    [Parameter(Mandatory=$true)]    
    [string]$SearchQuery,
    [Parameter(Mandatory=$true)]    
    [string]$TargetMailbox
)
$userList | Foreach-object {Search-Mailbox -identity $($_.users) -searchquery '$SearchQuery' -targetmailbox $TargetMailbox -TargetFolder "SearchData" -loglevel full -DeleteContent}