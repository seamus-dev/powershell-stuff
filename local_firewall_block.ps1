#this is just a simple script to block ports in the local firewall config
#there is definitely a better way to do this?
# author: seamus enright
#just runs like scipt.ps1 $DisplayName $Direction $LocalPort $Protocol $Action
#to do New-NetFirewallRule -DisplayName "$DisplayName" -Direction $Direction -LocalPort $LocalPort -Protocol $Protocol -Action $Action -FWProfile $FWProfile -Description $Description
#for FWProfile, it can be  The acceptable values for this parameter are: Any, Domain, Private, Public, or NotApplicable. The default value is Any. Separate multiple entries with a comma and do not include any spaces.

param (
    [Parameter(Mandatory=$true)]    
    [string]$DisplayName,
    [Parameter(Mandatory=$true)]
    [string]$Direction,
    [Parameter(Mandatory=$true)]
    [string]$LocalPort,
    [Parameter(Mandatory=$true)]
    [string]$Protocol,
    [Parameter(Mandatory=$true)]
    [string]$Action,
    [string]$FWProfile,
    [string]$Description
 )

#create the rule
New-NetFirewallRule -DisplayName "$DisplayName" -Direction $Direction -LocalPort $LocalPort -Protocol $Protocol -Action $Action -Description "$Description"
