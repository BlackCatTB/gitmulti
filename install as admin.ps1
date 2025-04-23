# Requires Admin privileges
function Ensure-Admin {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Warning "This script needs to run as Administrator. Relaunching..."
        Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
}

function Install-Mingw {
    $mingwUrl = "https://github.com/brechtsanders/winlibs_mingw/releases/download/14.2.0posix-19.1.7-12.0.0-msvcrt-r3/winlibs-x86_64-posix-seh-gcc-14.2.0-mingw-w64msvcrt-12.0.0-r3.zip" #idk how to get the latest
    $zipName = "mingw.zip"
    $mingwInstallDir = "C:\Program Files\mingw64"
    $mingwBin = "$mingwInstallDir\bin"

    if (Test-Path $mingwBin) {
        Write-Host "MinGW already installed at $mingwBin"
        return $mingwBin
    }

    $tempPath = "$env:TEMP\gitmulti-mingw"
    New-Item -ItemType Directory -Path $tempPath -Force | Out-Null
    $zipPath = "$tempPath\$zipName"

    Write-Host "`n[+] Downloading MinGW..."
    Invoke-WebRequest -Uri $mingwUrl -OutFile $zipPath

    Write-Host "[+] Extracting MinGW..."
    Expand-Archive -Path $zipPath -DestinationPath $tempPath -Force

    $extracted = Get-ChildItem $tempPath | Where-Object { $_.PSIsContainer -and $_.Name -like "winlibs-*" } | Select-Object -First 1
    if (-not $extracted) {
        Write-Error "Extraction failed. Could not find extracted MinGW folder."
        exit 1
    }

    Move-Item -Path $extracted.FullName -Destination $mingwInstallDir -Force

    # Add to system PATH
    $envPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if (-not ($envPath -split ";" | Where-Object { $_ -eq $mingwBin })) {
        Write-Host "[+] Adding MinGW to system PATH..."
        $newPath = "$envPath;$mingwBin"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
    }

    Write-Host "[✓] MinGW installed to $mingwInstallDir"
    return $mingwBin
}

function Add-ToSystemPath {
    param (
        [string]$newEntry
    )

    $envPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $pathEntries = $envPath -split ";" | ForEach-Object { $_.TrimEnd("\") }

    # Normalize path for comparison
    $normalizedNewEntry = $newEntry.TrimEnd("\")

    if (-not ($pathEntries -contains $normalizedNewEntry)) {
        Write-Host "[+] Adding '$normalizedNewEntry' to system PATH..."
        $updatedPath = "$envPath;$normalizedNewEntry"
        [Environment]::SetEnvironmentVariable("Path", $updatedPath, "Machine")

        # Trigger an environment refresh for running apps (optional)
        $signature = '[DllImport("user32.dll")] public static extern int SendMessageTimeout(int hWnd, int Msg, int wParam, string lParam, int fuFlags, int uTimeout, out int lpdwResult);'
        $type = Add-Type -MemberDefinition $signature -Name 'Win32SendMessageTimeout' -Namespace Win32Functions -PassThru
        $HWND_BROADCAST = 0xffff
        $WM_SETTINGCHANGE = 0x1A
        $SMTO_ABORTIFHUNG = 0x0002
        $result = 0
        $type::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, 0, "Environment", $SMTO_ABORTIFHUNG, 5000, [ref]$result) | Out-Null
    } else {
        Write-Host "[✓] '$normalizedNewEntry' already in system PATH."
    }
}


function Install-GitMulti {
    $programName = "gitmulti"
    $installPath = "C:\Program Files\$programName"
    $exePath = "$installPath\$programName.exe"
    $cppFile = "gitmulti.cpp"

    if (-not (Test-Path $cppFile)) {
        Write-Error "Missing $cppFile in current directory."
        exit 1
    }

    $gppPath = Get-Command g++ -ErrorAction SilentlyContinue
    if (-not $gppPath) {
        Write-Warning "g++ not found. Installing MinGW..."
        $mingwBin = Install-Mingw
        $env:Path += ";$mingwBin"
    }

    Write-Host "`n[+] Compiling $cppFile..."
    & g++ $cppFile -o "$programName.exe"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Compilation failed."
        exit 1
    }

    if (-not (Test-Path $installPath)) {
        New-Item -ItemType Directory -Path $installPath | Out-Null
    }

    Move-Item "$programName.exe" $exePath -Force

    Add-ToSystemPath -newEntry $installPath


    Write-Host "`n[✓] Installed $programName to $installPath"
    Write-Host "Restart your terminal or system to use 'gitmulti' globally."
}

# --- Start ---
Ensure-Admin
Install-GitMulti
