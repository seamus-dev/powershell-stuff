#this is to add new people to three specific roles, can add or modify as needed
#specifically set as eligable in PIM

#import users
#### select csv from file explorer ####
    #load windows forms & create the filebrowser object
    Add-Type -AssemblyName System.Windows.Forms
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') }
    #showing dialog box
    $null = $FileBrowser.ShowDialog()
    $filepath = $FileBrowser.FileName
    #declare array & import list into it
    $userList = Import-Csv -Header 'username' -Path "$filepath" 

#if you don't have the module, need to install that, add that here in the future


#connect to azure
Connect-AzureAD

#get tenant info
$aadTenant = Get-AzureADMSPrivilegedResource -ProviderId aadRoles

#get role info, I might be able to bypass with with just the role ID -- I don't know if that's constant between tenants or what though, and this is easy enough
$roleReportsReader = Get-AzureADMSRoleDefinition -Filter "displayName eq 'Reports Reader'"
$roleAuthenticationAdministrator = Get-AzureADMSRoleDefinition -Filter "displayName eq 'Authentication Administrator'"
$roleHelpdeskAdministrator = Get-AzureADMSRoleDefinition -Filter "displayName eq 'Helpdesk Administrator'"

#set the assignment schedule, default to 1 year
$schedule = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedSchedule
$schedule.Type = "Once"
$schedule.StartDateTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
#if you wanted this to be shorter or longer, just change AddYears to like AddMonths(10) or AddDays(90) or whatever, I'm not in charge, I'm just the script
$schedule.EndDateTime = (Get-date).ToUniversalTime().AddYears(1).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")

#assign the roles to each user
$userList | ForEach-Object {
    #get the user
    $user = Get-AzureADUser -Filter "userPrincipalName eq '$($_.username)'"

    #assign the roles
    $roleAssignmentActiveReportsReader = Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId 'aadRoles' -ResourceId $aadTenant.Id -RoleDefinitionId $roleReportsReader.Id -SubjectId $user.objectId -Type 'AdminAdd' -AssignmentState 'Active' -schedule $schedule -reason "Service Desk to view authentication history and other info"
    $roleAssignmentEligibleAuthenticationAdministrator = Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId 'aadRoles' -ResourceId $aadTenant.Id -RoleDefinitionId $roleAuthenticationAdministrator.Id -SubjectId $user.objectId -Type 'AdminAdd' -AssignmentState 'Eligible' -schedule $schedule -reason "Service Desk, to manage MFA options for SSPR"
    $roleAssignmentEligibleHelpdeskAdministrator = Open-AzureADMSPrivilegedRoleAssignmentRequest -ProviderId 'aadRoles' -ResourceId $aadTenant.Id -RoleDefinitionId $roleHelpdeskAdministrator.Id -SubjectId $user.objectId -Type 'AdminAdd' -AssignmentState 'Eligible' -schedule $schedule -reason "Service Desk to be able to reset passwords"

    Write-Host "assignment for $($_.username) complete"
    #later: output what roles earch user now has -- need to use graph powershell module to do this
}
