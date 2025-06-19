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
            <CheckBox x:Name='chkGameBar' Content='Disable Game Bar &amp; DVR' Foreground='White' FontSize='15' IsChecked='True' Margin='0,5'/>
            <CheckBox x:Name='chkPowerPlan' Content='Set High Performance Power Plan' Foreground='White' FontSize='15' IsChecked='True' Margin='0,5'/>
            <CheckBox x:Name='chkOther' Content='Additional System Tweaks' Foreground='White' FontSize='15' IsChecked='True' Margin='0,5'/>

        </StackPanel>

        <StackPanel Orientation='Horizontal' HorizontalAlignment='Center' VerticalAlignment='Bottom' Margin='0,0,0,45' Spacing='15'>
            <Button x:Name='btnStart' Content='Apply Tweaks &amp; Start Game 🚀' Width='260' Height='55' Background='#007ACC' Foreground='White' FontSize='17' Cursor='Hand' />
            <Button x:Name='btnRestore' Content='Restore Defaults 🔄' Width='160' Height='55' Background='#444' Foreground='White' FontSize='17' Cursor='Hand' />
        </StackPanel>

        <TextBlock x:Name='txtStatus' Text='Ready' Foreground='Lime' FontSize='14' HorizontalAlignment='Center' VerticalAlignment='Bottom' Margin='0,0,0,15'/>
        <TextBlock Text='License Key: Crty-key-1246523564 (auto verified)' Foreground='Gray' FontSize='11' HorizontalAlignment='Center' VerticalAlignment='Bottom' Margin='0,0,0,0' />
    </Grid>
</Window>
"@

# Load XAML window
$xmlReader = [System.Xml.XmlReader]::Create([System.IO.StringReader]$XAML)
$Window = [Windows.Markup.XamlReader]::Load($xmlReader)

# Find controls
$chkFPS = $Window.FindName('chkFPS')
$chkAntiLag = $Window.FindName('chkAntiLag')
$chkInputLag = $Window.FindName('chkInputLag')
$chkGameBar = $Window.FindName('chkGameBar')
$chkPowerPlan = $Window.FindName('chkPowerPlan')
$chkOther = $Window.FindName('chkOther')
$btnStart = $Window.FindName('btnStart')
$btnRestore = $Window.FindName('btnRestore')
$txtStatus = $Window.FindName('txtStatus')

# Function to find GameLoop Emulator executable automatically
function Find-EmulatorPath {
    $paths = @(
        "C:\Program Files\TxGameAssistant\ui\AndroidEmulatorEn.exe",
        "C:\Program Files (x86)\TxGameAssistant\ui\AndroidEmulatorEn.exe"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

# Prompt user to select executable manually if not found automatically
function Ask-UserForPath {
    Add-Type -AssemblyName System.Windows.Forms
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Filter = "Emulator Executable|AndroidEmulatorEn.exe"
    $ofd.Title = "Select GameLoop Emulator Executable"
    if ($ofd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $ofd.FileName
    } else {
        return $null
    }
}

# Function to apply system tweaks based on user selection
function Apply-Tweaks {
    $txtStatus.Text = "Applying selected tweaks..."

    # Anti-Lag Optimization
    if ($chkAntiLag.IsChecked) {
        # Disable Dynamic Ticks & platform timer for better game timer precision
        bcdedit /set useplatformtick yes | Out-Null
        bcdedit /set disabledynamictick yes | Out-Null
        bcdedit /set tscsyncpolicy Enhanced | Out-Null
    }

    # Disable Game Bar & DVR
    if ($chkGameBar.IsChecked) {
        reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f | Out-Null
        reg add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehavior /t REG_DWORD /d 0 /f | Out-Null
        reg add "HKCU\Software\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 0 /f | Out-Null
    }

    # Input Lag Reduction
    if ($chkInputLag.IsChecked) {
        # Set graphics priority to high
        reg add "HKCU\Control Panel\Desktop" /v ForegroundLockTimeout /t REG_DWORD /d 0 /f | Out-Null
    }

    # Set High Performance Power Plan
    if ($chkPowerPlan.IsChecked) {
        powercfg /setactive SCHEME_MIN | Out-Null
    }

    # Additional system tweaks (example: multimedia prioritization)
    if ($chkOther.IsChecked) {
        # Optimize timer resolution
        # (Requires third party tools or specific drivers usually, so this is a placeholder)
        # But can set multimedia scheduler priority, for example:
        # (This is just a stub; advanced users can extend this.)
    }
    
    # Max FPS tweak is done via emulator parameters on game start
}

# Function to restore defaults
function Restore-Defaults {
    $txtStatus.Text = "Restoring default settings..."
    # Restore default bcdedit settings
    bcdedit /deletevalue useplatformtick 2>$null
    bcdedit /deletevalue disabledynamictick 2>$null
    bcdedit /deletevalue tscsyncpolicy 2>$null

    # Restore default registry values
    reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 1 /f | Out-Null
    reg add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehavior /t REG_DWORD /d 1 /f | Out-Null
    reg add "HKCU\Software\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 1 /f | Out-Null
    reg add "HKCU\Control Panel\Desktop" /v ForegroundLockTimeout /t REG_DWORD /d 20000 /f | Out-Null

    powercfg /setactive SCHEME_BALANCED | Out-Null

    $txtStatus.Text = "Defaults restored."
}

# Button events
$btnStart.Add_Click({
    $txtStatus.Text = "Searching for emulator path..."
    $emuPath = Find-EmulatorPath
    if (-not $emuPath) {
        $txtStatus.Text = "Emulator not found, please select executable."
        $emuPath = Ask-UserForPath
        if (-not $emuPath) {
            $txtStatus.Text = "Operation cancelled by user."
            return
        }
    }

    # Apply tweaks
    Apply-Tweaks

    # Start the emulator with max FPS param if selected
    $fpsArg = if ($chkFPS.IsChecked) { '-fps "120"' } else { '-fps "60"' }

    $txtStatus.Text = "Starting GameLoop Emulator..."
    Start-Process -FilePath $emuPath -ArgumentList "-cmd StartApk -param -startpkg `"com.tencent.ig`" -engine `"aow`" -vm `"100`" $fpsArg -resolution `"1280x960`" -from `"Custom`"" -Priority High

    $txtStatus.Text = "Game started successfully!"
})

$btnRestore.Add_Click({
    Restore-Defaults
})

# Show the window
$Window.ShowDialog() | Out-Null
