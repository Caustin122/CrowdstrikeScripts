$LogFile = "Crowdstrike_scripts.log"

if (!(Test-Path $LogFile)) 	#check for log file and create it if it doesnt already exist
{
	New-Item -Path Crowdstrike_scripts.log -ItemType File 
}

function Log #Function to log script events to $LogFile
{
    Param($Message)
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $Line = "$Stamp $Message"
    Add-Content $LogFile -Value $Line
}

$WinDefendStatus = (get-Service windefend).status
Log ("Windows Defender Status:" + $WinDefendStatus)
if($WinDefendStatus = "Stopped")
{
    start-service windefend
}

$DefenderConfig = Get-MpComputerStatus
if ($DefenderConfig.AntivirusSignatureLastUpdated) 
{
    Log ("HISTORY: Last definition update -" + $DefenderConfig.AntivirusSignatureLastUpdated)
}
if ($DefenderConfig.FullScanEndTime) 
{
    Log ("HISTORY: Last full scan - " + $DefenderConfig.FullScanEndTime)
}
if ($DefenderConfig.QuickScanEndTime) 
{
    Log ("HISTORY: Last quick scan - " + $DefenderConfig.QuickScanEndTime)
}

Log ("Starting Full Scan")
$proc = Start-MpScan –ScanType FullScan  
$proc.WaitForExit()
Log ("Threats Detected: " + $Get.MpThreatDetection)
Log ("HISTORY: Last full scan - " + $DefenderConfig.FullScanEndTime)
if (!(Test-Path Installed_applications.log)) 	#check for log file and create it if it doesnt already exist
{
	New-Item -Path Installed_applications.log -ItemType File 
}

Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSize > Installed_applications.log
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSize >> Installed_applications.log
