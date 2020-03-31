# PoweshellIT #3 – User Profile Migration
## Use Case
Perform a backup/migration of files from any laptop to a network drive. copy all files/folders of the user to their new computer. It needs to be able to migrate over  printers, stored WiFi connections and browser passwords and settings. 

## Infrastructure Overview
![infra](https://www.andysvints.com/wp-content/uploads/2020/03/pwshit3-Infa-1.png)

## Proposed solution
Simple and elegant PowerShell function which will accept username Destination where to copy user’s data.

### Pseudo code
```
Get Username and Data to Copy and Destination Path
if DataToCopy contains "Files"
    Get user profile files
    Copy to Destination Path

if DataToCopy contains "Printers"
    Get list of printers
    Export to Destination Path

if DataToCopy contains "WiFiNetworks"
    Get list of save WiFi networks and passwords
    Export to Destination Path

if DataToCopy contains "BrowserProfiles"
    Get Firefox profile files
    Copy to Destination Path
    Get Chrome profile files
    Copy to Destination Path

End.
```
[More Information](https://www.andysvints.com/powershellit-3-user-profile-migration/)

