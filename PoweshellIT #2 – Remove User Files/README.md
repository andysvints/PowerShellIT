# PoweshellIT #2 – Remove User Files
## Use Case
Delete all common file types(documents, media and pictures – basically user file), except for protected folders in the C:\windows directory. The intent is to prevent users from saving and retaining files from the web on a publicly accessible computer.
## Infrastructure overview 
![infra](https://www.andysvints.com/wp-content/uploads/2020/03/pwsh2-1142x706.png)

## Proposed solution
Json Config file with data types for ease of adding/removing them.
Simple PowerShell module with couple of functions referring config file.
### Pseudo code
```
Get config file with Personal File Types
Get All of Filesystem drives
foreach drive get all files with PersonalFileTypes extension
filter out excluded files & folders
remove not filtered files
```
[More Information](https://www.andysvints.com/poweshellit-2-remove-user-files/)
