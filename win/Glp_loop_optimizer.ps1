Add-Type -AssemblyName PresentationFramework,PresentationCore,System.Xaml,System.Windows.Forms

$XAML = @"
<Window xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
        Title='CRTY GameLoop Optimizer' Height='550' Width='680' Background='#1E1E1E' WindowStartupLocation='CenterScreen' ResizeMode='NoResize'>
    <Grid Margin='15'>
        <TextBlock Text='CRTY GameLoop Optimizer' FontSize='30' FontWeight='Bold' Foreground='Lime' HorizontalAlignment='Center' Margin='0,0,0,20'/>
        <StackPanel Orientation='Vertical' Margin='0,50,0,90'>

            <TextBlock Text='Select tweaks to apply:' Foreground='White' FontSize='16' Margin='0,0,0,15'/>
            
            <CheckBox x:Name='chkFPS' Content='Maximum FPS (120fps)' Foreground='White' FontSize='15' IsChecked='True' Margin='0,5'/>
            <CheckBox x:Name='chkAntiLag' Content='Anti-Lag Optimizations' Foreground='White' FontSize='15' IsChecked='True' Margin='0,5'/>
            <CheckBox x:Name='chkInputLag' Content='Input Lag Reduction' Foreground='White' FontSize='15' IsChecked='True' Margin='0,5'/>
            <CheckBox x:Name='chkGameBar' Content='Disable Game Bar & DVR' Foreground='White' FontSize='15' IsChecked='True' Margin='0,5'/>
            <CheckBox x:Name='chkPowerPlan' Content='Set High Performance Power Plan' Foreground='White' FontSize='15' IsChecked='True' Margin='0,5'/>
            <CheckBox x:Name='chkOther' Content='Additional System Tweaks' Foreground='White' FontSize='15' IsChecked='True' Margin='0,5'/>

        </StackPanel>

        <StackPanel Orientation='Horizontal' HorizontalAlignment='Center' VerticalAlignment='Bottom' Margin='0,0,0,45' Spacing='15'>
            <Button x:Name='btnStart' Content='Apply Tweaks & Start Game 🚀' Width='260' Height='55' Background='#007ACC' Foreground='White' FontSize='17' Cursor='Hand' />
            <Button x:Name='btnRestore' Content='Restore Defaults 🔄' Width='160' Height='55' Background='#444' Foreground='White' FontSize='17' Cursor='Hand' />
        </StackPanel>

        <TextBlock x:Name='txtStatus' Text='Ready' Foreground='Lime' FontSize='14' HorizontalAlignment='Center' VerticalAlignment='Bottom' Margin='0,0,0,15'/>
        <TextBlock Text='License Key: Crty-key-1246523564 (auto verified)' Foreground='Gray' FontSize='11' HorizontalAlignment='Center' VerticalAlignment='Bottom' Margin='0,0,0,0' />
    </Grid>
</Window>
"@

# Load XAML
$xmlReader = [System.Xml.XmlReader]::Create([System.IO.StringReader]$XAML)
$Window = [Windows.Markup.XamlReader]::Load($xmlReader)

# Controls
$btnStart = $Window.FindName('btnStart')
$btnRestore = $Window.FindName('btnRestore')
$txtStatus = $Window.FindName('txtStatus')
$chkFPS = $Window.FindName('chkFPS')
$chkAntiLag = $Window.FindName('chkAntiLag')
$chkInputLag = $Window.FindName('chkInputLag')
$chkGameBar = $Window.FindName('chkGameBar')
$chkPowerPlan = $Window.FindName('chkPowerPlan')
$chkOther = $Window.FindName('chkOther')

function Find-GameLoop {
    $possiblePaths = @(
        "C:\Program Files\TxGameAssistant\ui\AndroidEmulatorEn.exe",
        "C:\Program Files (x86)\TxGameAssistant\ui\AndroidEmulatorEn.exe"
    )
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) { return $path }
    }
    return $null
}

function Ask-GameLoopPath {
    Add-Type -AssemblyName System.Windows.Forms
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Filter = "GameLoop Executable|AndroidEmulatorEn.exe"
    $ofd.Title = "Select GameLoop Emulator Executable (AndroidEmulatorEn.exe)"
    if ($ofd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $ofd.FileName
    }
    return $null
}

function Apply-FPSTweaks {
    # FPS max 120 for GameLoop launch param
    return '-fps "120"'
}

function Apply-AntiLagTweaks {
    # Disable Game DVR and Game Bar related services/settings
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -Command `"reg add HKCU\System\GameConfigStore /v GameDVR_Enabled /t REG_DWORD /d 0 /f; reg add HKCU\System\GameConfigStore /v GameDVR_FSEBehavior /t REG_DWORD /d 0 /f; reg add HKCU\Software\Microsoft\GameBar /v AllowAutoGameMode /t REG_DWORD /d 0 /f;`"" -WindowStyle Hidden -Wait
}

function Apply-InputLagTweaks {
    # System tweaks to reduce input lag and improve timer resolution
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -Command `"powercfg /setactive SCHEME_MIN; bcdedit /set useplatformtick yes; bcdedit /set disabledynamictick yes; bcdedit /set tscsyncpolicy Enhanced;`"" -WindowStyle Hidden -Wait
}

function Apply-DisableGameBar {
    # Further disable Game DVR & Game Bar components
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -Command `"reg add HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR /v AppCaptureEnabled /t REG_DWORD /d 0 /f; reg add HKCU\System\GameConfigStore /v GameDVR_Enabled /t REG_DWORD /d 0 /f;`"" -WindowStyle Hidden -Wait
}

function Apply-PowerPlanHighPerf {
    # Set High Performance power plan
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -Command `"powercfg /setactive SCHEME_MIN`"" -WindowStyle Hidden -Wait
}

function Apply-AdditionalTweaks {
    # Misc system tweaks - TCP optimizations etc
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -Command `"reg add HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters /v EnableTCPA /t REG_DWORD /d 0 /f;`"" -WindowStyle Hidden -Wait
}

function Restore-Defaults {
    # Restore default Windows settings for all applied tweaks

    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -Command `"
        reg add HKCU\System\GameConfigStore /v GameDVR_Enabled /t REG_DWORD /d 1 /f;
        reg add HKCU\System\GameConfigStore /v GameDVR_FSEBehavior /t REG_DWORD /d 1 /f;
        reg add HKCU\Software\Microsoft\GameBar /v AllowAutoGameMode /t REG_DWORD /d 1 /f;
        reg add HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR /v AppCaptureEnabled /t REG_DWORD /d 1 /f;
        powercfg /setactive SCHEME_BALANCED;
        bcdedit /deletevalue useplatformtick;
        bcdedit /deletevalue disabledynamictick;
        bcdedit /deletevalue tscsyncpolicy;
        reg add HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters /v EnableTCPA /t REG_DWORD /d 1 /f;
    `" -WindowStyle Hidden -Wait
}

# Button click event: Start & Apply Tweaks + Launch GameLoop
$btnStart.Add_Click({

    $txtStatus.Text = "Checking GameLoop path..."
    $emuPath = Find-GameLoop
    if (-not $emuPath) {
        $txtStatus.Text = "GameLoop not found, please select executable..."
        $emuPath = Ask-GameLoopPath
        if (-not $emuPath) {
            $txtStatus.Text = "Operation cancelled by user."
            return
        }
    }

    $txtStatus.Text = "Applying selected tweaks..."
    if ($chkAntiLag.IsChecked) { Apply-AntiLagTweaks }
    if ($chkInputLag.IsChecked) { Apply-InputLagTweaks }
    if ($chkGameBar.IsChecked) { Apply-DisableGameBar }
    if ($chkPowerPlan.IsChecked) { Apply-PowerPlanHighPerf }
    if ($chkOther.IsChecked) { Apply-AdditionalTweaks }

    # Build launch parameters string
    $args = '-cmd StartApk -param -startpkg "com.tencent.ig" -engine "aow" -vm "100"'
    if ($chkFPS.IsChecked) {
        $args += " " + (Apply-FPSTweaks)
    }
    $args += ' -resolution "1280x960" -from "Custom"'

    $txtStatus.Text = "Starting GameLoop with tweaks..."
    try {
        Start-Process -FilePath $emuPath -ArgumentList $args -Priority High
        $txtStatus.Text = "Game started successfully! 🚀"
    }
    catch {
        $txtStatus.Text = "Failed to start GameLoop!"
    }
})

# Button click event: Restore Defaults
$btnRestore.Add_Click({
    $txtStatus.Text = "Restoring default system settings..."
    Restore-Defaults
    $txtStatus.Text = "Defaults restored. Please reboot for full effect."
})

# Show GUI window
$Window.ShowDialog() | Out-Null
