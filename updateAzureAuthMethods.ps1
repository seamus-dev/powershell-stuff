#this is a simple script for importing a list of users and adding phone and email as authentication methods if they are blank
#got some of the device / auth conversion info from https://thesysadminchannel.com/get-mfa-methods-using-msgraph-api-and-powershell-sdk/ -- thanks Paul!

#write logs to file, remove / update this and either change WriteLog to Write-Host or remove entirely if you don't wanna log things
$Logfile = "C:\PS\Logs\azure_auth_methods_script.log"
function WriteLog
{
Param ([string]$LogString)
$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
$LogMessage = "$Stamp $LogString"
Add-content $LogFile -value $LogMessage
}

WriteLog "Starting Script"
#import from csv -- could also grab this from ad or wherever if you wanted
#headers are assumed to be user | phone | email
#example                test@school.edu,+1 2345678901,test@gmail.com
$UserList = Import-Csv "C:\Users\username\Downloads\auth_methods_test.csv"
WriteLog "Importing user list"

#connect to graph, need permissions to read and update authentication methods
#note, you need to grant permissions for this in azure graph enterprise app
Connect-MgGraph -scopes 'UserAuthenticationMethod.ReadWrite.All'

#for each user, get phone and email, if either is blank, set them
#log the change to log file
$UserList | ForEach-Object {
    try {
        #get emailAuth, this will return blank if it isn't set
        $userEmailAuth = Get-MgUserAuthenticationEmailMethod -UserId $($_.user)

        if ($null -eq $userEmailAuth) {
            #add email auth because it's blank
            WriteLog "email is null, setting $($_.user)'s email to $($_.email)"
            New-MgUserAuthenticationEmailMethod -UserId $($_.user) -emailAddress $($_.email)

        }else {
            WriteLog "$($_.user)'s email exists and is: $($userEmailAuth.emailAddress)"
        }

        #get phoneAuth, this will return blank if it isn't set
        $userPhoneAuth = Get-MgUserAuthenticationPhoneMethod -UserId $($_.user)

        if ($null -eq $userPhoneAuth) {
            #add phone auth because it's blank
            WriteLog "phone is null, setting $($_.user)'s phone to $($_.phone)"
            
            $params = @{
                phoneNumber = "$($_.phone)"
                phoneType = "mobile"
            }
            
            New-MgUserAuthenticationPhoneMethod -UserId $($_.user) -BodyParameter $params

        }else {
            WriteLog "$($_.user)'s phone exists and is: $($userPhoneAuth.phoneNumber)"
        }
    } catch {
        Write-Error $_.Exception.Message
        WriteLog $_.Exception.Message
    }
}

WriteLog "Completed List"
Disconnect-MgGraph
Exit 0
