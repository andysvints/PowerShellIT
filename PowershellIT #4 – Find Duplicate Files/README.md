# PowershellIT #4 – Find Duplicate Files 
## Use Case
Identify identical files(twins) in the folder. Not just with same metadata (file name, author, file size, timestamps) but truly identical files which have the same content.

## Infrastructure Overview
![infra](https://www.andysvints.com/wp-content/uploads/2020/04/pwshit4-Infa.png)

## Proposed solution
Simple and elegant PowerShell function which will accept path to folder where duplicates(twins) should be found. Also a additional(optional) parameter a path to file which should be considered as baseline and identify any of duplicates of it.

### Pseudo code
```

#Find Duplicates within folder
Get List of files in the Directory
Generate hash values for each file
Compare hashes and identify any duplicates

#Find Duplicate of a file within folder
Generate hash value for a BaseFile
Get List of file in the Directory
Generate hash values for each file
Compare baseline hash to Directory files hash values and identify duplicates

```
[More Information](https://www.andysvints.com/powershellit-4-find-duplicate-files/)

 *Icons made by [Good Ware ](https://www.flaticon.com/authors/good-ware) & [Nhor Phai](https://www.flaticon.com/authors/nhor-phai) & [Payungkead](https://www.flaticon.com/authors/payungkead) & [Smashicons](https://www.flaticon.com/authors/smashicons) from  [www.flaticon.com](www.flaticon.com)*
