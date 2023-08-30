function Confirm-Action {
    param (
        [string]$Message
    )

    $choice = $null
    while ($choice -ne 'y' -and $choice -ne 'n') {
        $choice = Read-Host "$Message (y/n)"
    }
    
    return $choice -eq 'y'
}

function Uninstall-AATPSensor {
    if (Confirm-Action "Do you want to run the uninstaller for Azure ATP Sensor?") {
        $packageCachePath = "C:\ProgramData\Package Cache"
        Get-ChildItem -Path $packageCachePath -Recurse -Include "Azure ATP Sensor Setup.exe" | ForEach-Object {
            & $_.FullName /uninstall
        }
        Write-Output "Uninstall process completed."
    }
}

function Remove-AATPServices {
    if (Confirm-Action "Do you want to remove Azure ATP services?") {
        $services = @('aatpsensor', 'aatpsensorupdater')

        foreach ($service in $services) {
            if (Get-Service $service -ErrorAction SilentlyContinue) {
                Stop-Service $service
                sc.exe delete $service
                Write-Output "Service $service removed successfully."
            }
        }
    }
}

function Verify-Removal {
    if (Confirm-Action "Do you want to verify if Azure ATP services and folders have been removed?") {
        $serviceNames = @("aatpsensor", "aatpsensorupdater")
        $programFolderPath = "C:\Program Files\Azure Advanced Threat Protection Sensor"
    
        foreach ($service in $serviceNames) {
            if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
                Write-Output "$service still exists."
            } else {
                Write-Output "$service has been removed successfully."
            }
        }
    
        if (Test-Path $programFolderPath) {
            Write-Output "Program Folder still exists: $programFolderPath"
        } else {
            Write-Output "Program Folder has been removed successfully."
        }
    }
}

function Rename-PackageCache {
    if (Confirm-Action "Do you want to rename the Azure ATP Sensor cache?") {
        $packageCachePath = "C:\ProgramData\Package Cache"
    
        Get-ChildItem -Path $packageCachePath -Directory | Where-Object { $_.Name -match "^\{[a-fA-F0-9]{8}(-[a-fA-F0-9]{4}){3}-[a-fA-F0-9]{12}\}$" } | ForEach-Object {
            try {
                Rename-Item -Path $_.FullName -NewName ($_.Name + "_backup") -ErrorAction Stop
                Write-Output "Successfully renamed $_.FullName."
            } catch {
                Write-Warning "Failed to rename $_.FullName."
                if (Confirm-Action "Do you want to modify permissions and retry renaming?") {
                    $acl = Get-Acl $_.FullName
                    $acl.SetAccessRuleProtection($false, $false)
                    Set-Acl -Path $_.FullName -AclObject $acl
                    Rename-Item -Path $_.FullName -NewName ($_.Name + "_backup")
                    Write-Output "Successfully renamed $_.FullName after adjusting permissions."
                }
            }
        }
    }
}

function Confirm-Action {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    return ($true -eq (Read-Host "$Message (y/n)" -Confirm))
}

function Uninstall-AATPSensor {
    if (Confirm-Action "Do you want to run the uninstall command for Azure ATP Sensor?") {
        $guidPath = Get-ChildItem "C:\ProgramData\Package Cache\" -Recurse | Where-Object { $_.Name -match "Azure ATP Sensor Setup.exe" } | Select-Object -ExpandProperty DirectoryName
        if ($guidPath) {
            try {
                & "$guidPath\Azure ATP Sensor Setup.exe" /uninstall
                Write-Output "Azure ATP Sensor uninstalled successfully."
            } catch {
                Write-Output "Error during uninstallation: $_.Exception.Message"
            }
        } else {
            Write-Output "Azure ATP Sensor Setup.exe not found."
        }
    }
}

# ... [Other functions with added try-catch blocks as demonstrated above]

# Call the functions
Uninstall-AATPSensor
Remove-AATPServices
Rename-PackageCache
Remove-RegistryKeys

# Completion message
Write-Output "Sensor cleanup is done!"
Read-Host "Press Enter to close the window..."