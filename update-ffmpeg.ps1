$sourceUrl = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z"
$sourceTempfile = $env:TEMP + "\tempffmpeg.exe"
$targetFolder="C:\Program Files (x86)\DVBViewer"


function Test-IsElevated {
    if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        return $true
    } else {
        return $false
    }
}


Function Test-IsFileLocked {
    [cmdletbinding()]
    Param (
        [parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [Alias('FullName','PSPath')]
        [string[]]$Path
    )
    Process {
        ForEach ($Item in $Path) {
            #Verify that this is a file and not a directory
            If ([System.IO.File]::Exists($Item)) {
                Try {
                    $FileStream = [System.IO.File]::Open($Item,'Open','Write')
                    $FileStream.Close()
                    $FileStream.Dispose()
                    $IsLocked = $False
                } Catch [System.UnauthorizedAccessException] {
                    $IsLocked = 'AccessDenied'
                } Catch {
                    $IsLocked = $True
                }
                [pscustomobject]@{
                    File = $Item
                    IsLocked = $IsLocked
                }
            } else {
                [pscustomobject]@{
                    File = $Item
                    IsLocked = 'FileDoesNotExistOrNoFullFilePath'
                }
            }
        }
    }
}

clear-host
write-host "Updating DVBViewer FFmpeg to the most recent version"
write-host "------------------------------------------------------------"
write-host

write-host "Checking for elevated permissions"
if (Test-IsElevated) {
    write-host "  Script running elevated."
} else {
    write-host "  Script not running elevated, exiting."
    Start-Sleep -s 10
    exit 1
}
write-host

write-host "Downloading file"
(New-Object System.Net.WebClient).DownloadFile($sourceUrl, $sourceTempfile)

if (!(test-path $sourceTempfile)) {
    write-host "  Problem downloading file, exiting."
    Start-Sleep -s 10
    exit 1
}

write-host "Extracting and updating"
if (((Get-ChildItem ($targetFolder + "\ffmpeg.exe") -Recurse -Force | where-object {$_.PSIsContainer -ne $true} | Test-IsFileLocked | where {$_.IsLocked -ne $false}).count) -ne 0) {
    write-host ("  File ffmpeg.exe in or below """ + $targetFolder + """ is locked, exiting.")
    Start-Sleep -s 10
    exit 1
} else {
    & "$PSScriptRoot\7za.exe" e "$sourceTempfile" -o"$targetFolder" ffmpeg.exe -r -y | Out-Null
}


if ((test-path $sourceTempfile)) {
    remove-item $sourceTempfile -force
}

Start-Sleep -s 10