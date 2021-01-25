# PShot
PowerShell Module for taking a Screenshot
https://www.osdeploy.com/modules/pshot

Here's a quick example:

PShot -Verbose
VERBOSE: Loading module from path 'D:\GitHub\Modules\PShot\PShot.psm1'.
VERBOSE: ======================================================================================================
VERBOSE: PShot 21.1.25.1
VERBOSE: Take Screenshots in Windows and WinPE with Get-PShot
VERBOSE: ======================================================================================================
VERBOSE:
VERBOSE: -Path       Directory where the screenshots will be saved
VERBOSE:             Default = $Env:TEMP\PShots
VERBOSE:             Value = C:\Users\SEGURA~1\AppData\Local\Temp\PShot
VERBOSE:
VERBOSE: -Prefix     Pattern in the file name PShot_20210125_020525.png
VERBOSE:             Default = PShot
VERBOSE:             Value = PShot
VERBOSE:
VERBOSE: -Count      Total number of screenshots to capture
VERBOSE:             Default = 1
VERBOSE:             Value = 1
VERBOSE:
VERBOSE: -Delay      Delay before capturing the screenshots in seconds
VERBOSE:             Default = 0 (Count = 1) | Default = 1 (Count > 1)
VERBOSE:             Value = 0
VERBOSE:
VERBOSE: -Clipboard  Additionally copies the screenshot to the Clipboard
VERBOSE:             Value = False
VERBOSE: ======================================================================================================
VERBOSE: Screen DPI Scaling is 200 Percent
VERBOSE: Screen resolution is 1920 x 1080
VERBOSE: Physical Screen resolution is 3840 x 2160
VERBOSE: Delay 0 Seconds
VERBOSE: Saving PShot 1 of 1 to to C:\Users\SEGURA~1\AppData\Local\Temp\PShot\PShot_20210125_020525.png