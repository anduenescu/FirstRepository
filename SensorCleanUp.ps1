function Uninstall-AATPSensor {
    $packageCacheFolder = "C:\ProgramData\Package Cache"
    try {
        $setupFiles = Get-ChildItem -Path $packageCacheFolder -Recurse -File | Where-Object { $_.Name -match "Azure ATP Sensor Setup.exe" }
        
        if ($setupFiles.Count -eq 0) {
            Write-Host "Azure ATP Sensor Setup.exe not found." -ForegroundColor Red
            return
        }

        foreach ($setupFile in $setupFiles) {
            $confirmation = Read-Host "Found setup at $($setupFile.FullName). Do you want to run uninstall? (Y/N)"
            if ($confirmation -eq "Y") {
                Start-Process -Wait $setupFile.FullName -ArgumentList "/uninstall"
                Write-Host "Uninstallation command executed for $($setupFile.FullName)" -ForegroundColor Green
            }
        }
    } catch {
        Write-Host "Error during uninstallation: $_" -ForegroundColor Red
    }
}

function Remove-SensorFolder {
    $sensorFolderPath = "C:\Program Files\Azure Advanced Threat Protection Sensor"
    
    if (Test-Path $sensorFolderPath) {
        $confirmation = Read-Host "Found Sensor Folder at $sensorFolderPath. Do you want to delete it? (Y/N)"
        if ($confirmation -eq "Y") {
            try {
                Remove-Item -Path $sensorFolderPath -Recurse -Force
                Write-Host "Sensor folder deleted successfully." -ForegroundColor Green
            } catch {
                Write-Host "Failed to delete sensor folder. Error: $_" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "Sensor Folder not found." -ForegroundColor Yellow
    }
}

function Remove-AATPServices {
    $services = @("aatpsensor", "aatpsensorupdater")

    foreach ($service in $services) {
        $confirmation = Read-Host "Do you want to delete the service named '$service'? (Y/N)"
        if ($confirmation -eq "Y") {
            try {
                sc.exe delete $service
                Write-Host "Service '$service' deleted successfully." -ForegroundColor Green
            } catch {
                Write-Host "Failed to delete service: $service. Error: $_" -ForegroundColor Red
            }
        }
    }
}

function Rename-PackageCache {
    $packageCacheFolder = "C:\ProgramData\Package Cache"
    try {
        $GUIDFolders = Get-ChildItem -Path $packageCacheFolder -Directory | Where-Object { $_.Name -match '^{.*}$' }
        
        foreach ($folder in $GUIDFolders) {
            $confirmation = Read-Host "Found GUID folder: $($folder.Name). Do you want to rename it for backup? (Y/N)"
            if ($confirmation -eq "Y") {
                Rename-Item -Path $folder.FullName -NewName ($folder.Name + "_backup")
                Write-Host "Folder $($folder.Name) renamed successfully." -ForegroundColor Green
            }
        }
    } catch {
        Write-Host "Error during renaming PackageCache: $_" -ForegroundColor Red
        $permissionChange = Read-Host "Do you want to modify permissions and retry? (Y/N)"
        if ($permissionChange -eq "Y") {
            # Add necessary code or steps to modify folder permissions here
            Write-Host "Please modify permissions and retry."
        }
    }
}

function Remove-RegistryKeys {
    $registryPaths = @(
        "HKLM:\SOFTWARE\Classes\Installer\Products\",
        "HKLM:\SOFTWARE\Classes\Installer\Features\",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\",
        "HKLM:\SOFTWARE\Classes\Installer\Dependencies"
    )
    
    $keyFound = $false
    foreach ($path in $registryPaths) {
        try {
            $keys = Get-ChildItem -Path $path | Where-Object { (Get-ItemProperty -Path $_.PsPath).DisplayName -eq "Azure Advanced Threat Protection Sensor" }
            
            if ($keys.Count -gt 0) {
                $keyFound = $true
            }
            
            foreach ($key in $keys) {
                $confirmation = Read-Host "Found related registry key at $($key.PsPath). Do you want to delete it? (Y/N)"
                if ($confirmation -eq "Y") {
                    Remove-Item -Path $key.PsPath -Recurse
                    Write-Host "Registry key $($key.PsPath) removed successfully." -ForegroundColor Green
                }
            }
        } catch {
            Write-Host "Error during removing registry keys: $_" -ForegroundColor Red
        }
    }

    if (-not $keyFound) {
        Write-Host "No relevant registry keys found for removal." -ForegroundColor Yellow
    }
}

# Execute the functions
Uninstall-AATPSensor
Remove-SensorFolder
Remove-AATPServices
Rename-PackageCache
Remove-RegistryKeys
Write-Host "Sensor cleanup is done!" -ForegroundColor Yellow
Pause
