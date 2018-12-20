#do something

if (!($env:test -eq $true)) {

    #Check for variables

    if ($null -eq $env:log_grabber_output_dir) {
        Write-Host "Output directory not specified, will output to local directory"
        Write-Host "This is not best practice"
        $log_grabber_output_dir = ".\"
    } else {
        $log_grabber_output_dir = $env:log_grabber_output_dir
    }

} else {
    #We're in testing mode
}

$date = Get-Date
$dir = -join($env:computername,'-', $date.Year, $date.Month, $date.Day, $date.Hour, $date.Minute, $date.Second)
$zipfile = -join($env:computername,'-', $date.Year, $date.Month, $date.Day, $date.Hour, $date.Minute, $date.Second, ".zip")

New-Item -ItemType Directory -Force -Path .\$dir

$drives = GET-WMIOBJECT -query "SELECT * from win32_logicaldisk where DriveType = '3'"
foreach ($drive in $drives) {
    $drive.DeviceID | Out-File -Append -FilePath .\$dir\ntfsinfo.txt
    fsutil fsinfo ntfsinfo $drive.DeviceID | Out-File -Append -FilePath .\$dir\ntfsinfo.txt
}

Copy-Item -Recurse $env:SystemRoot"\system32\config\systemprofile\AppData\Local\Datto\Datto Windows Agent\*" .\$dir

wevtutil epl System  C:\jmaddington\$dir\system.evtx

.\bin\7zip\7z.exe a  $log_grabber_output_dir\$zipfile -tzip  .\$dir\*