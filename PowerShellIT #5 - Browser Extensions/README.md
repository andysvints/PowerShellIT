# PowershellIT #5 – Check Browser Extensions

## Use Case

Identify installed browser extension for a user. Cover popular browsers: FireFox, Chrome and Edge.
It should accept username as input and have parameters to get extensions for all browsers or specified ones. Also it should provide analysis on installed extensions like is it suspicious/malicious etc.

## Infrastructure Overview

![infra](https://www.andysvints.com/wp-content/uploads/2021/11/PowerShellIT5-Infra-1024x459.png)

## Proposed solution

Simple and elegant PowerShell function which will accept collection of usernames (or '*' for all) and browser type to get installed extensions from.

### Pseudo code

```cli
Check if user exist
foreach user & browser specified
 Get Installed Browser Extension
foreach identified extension
 Get Extension Risk Rating
```

[More Information](https://www.andysvints.com/powershell-5---browser-extensions)

 *Icons made by [Freepik](https://www.freepik.com) & [Pixel perfect](https://www.flaticon.com/authors/pixel-perfect) from [www.flaticon.com](https://www.flaticon.com/)*
