# PowerShellIT #1 - Distribution Groups Restrictions
## Use Case 
Business need to restrict people to send email to specific distribution lists. E.g. Board Members, All Employees etc

## Infrastructure overview 
![infra](https://www.andysvints.com/wp-content/uploads/2020/02/pwshit1-diagram.png)
## Proposed solution

Simple and elegant PowerShell function which will accept username and Distribution group name and will set both attributes to parent and nested groups.

### Pseudo code
```
Get user object and get distinguished name
Get distribution group object
Get all distribution group members
Set attributes for parent group
For each member
If member is group
Set attributes to group recursively 
```
