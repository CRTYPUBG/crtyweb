Add-Type -AssemblyName PresentationFramework

$XAML = @"
<Window xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
        Title='GameLoop Optimizer' Height='250' Width='350' WindowStartupLocation='CenterScreen' Background='White'>
    <Grid Margin='10'>
        <StackPanel VerticalAlignment='Center' HorizontalAlignment='Center'>
            <TextBlock Text='GameLoop Optimizer' FontSize='16' FontWeight='Bold' Margin='0,0,0,15' HorizontalAlignment='Center'/>
            
            <CheckBox Name='ChkFpsBoost' Content='FPS Boost' Margin='0,0,0,10'/>
            <CheckBox Name='ChkAntiLag' Content='Anti-Lag' Margin='0,0,0,10'/>
            <CheckBox Name='ChkInputLag' Content='Input Lag Removal' Margin='0,0,0,20'/>

            <StackPanel Orientation='Horizontal' HorizontalAlignment='Center'>
                <Button Name='BtnApply' Content='Apply' Width='100' Margin='5'/>
                <Button Name='BtnRestore' Content='Restore Defaults' Width='120' Margin='5'/>
            </StackPanel>

            <TextBlock Name='TxtStatus' Text='Status: Ready' Margin='10' TextAlignment='Center'/>
        </StackPanel>
    </Grid>
</Window>
"@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]$XAML)
$Window = [Windows.Markup.XamlReader]::Load($reader)

$ChkFpsBoost = $Window.FindName('ChkFpsBoost')
$ChkAntiLag = $Window.FindName('ChkAntiLag')
$ChkInputLag = $Window.FindName('ChkInputLag')
$BtnApply = $Window.FindName('BtnApply')
$BtnRestore = $Window.FindName('BtnRestore')
$TxtStatus = $Window.FindName('TxtStatus')

function Run-AsAdmin([scriptblock]$ScriptBlock) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "powershell.exe"
    $psi.Arguments = "-NoProfile -WindowStyle Hidden -Command & { $($ScriptBlock.ToString()) }"
    $psi.Verb = "runas"
    [System.Diagnostics.Process]::Start($psi) | Out-Null
}

function Apply-Optimizations {
    $TxtStatus.Text = "Applying optimizations..."
    if ($ChkFpsBoost.IsChecked) {
        Run-AsAdmin { powercfg /setactive SCHEME_MIN }
    }
    if ($ChkAntiLag.IsChecked) {
        Run-AsAdmin {
            reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
        }
    }
    if ($ChkInputLag.IsChecked) {
        Run-AsAdmin {
            reg add "HKCU\Control Panel\Mouse" /v MouseSensitivity /t REG_SZ /d 10 /f
            reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 1 /f
            reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f
            reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f
        }
    }
    Start-Sleep -Seconds 2
    $TxtStatus.Text = "Optimization complete!"
}

function Restore-Defaults {
    $TxtStatus.Text = "Restoring defaults..."
    Run-AsAdmin {
        powercfg /setactive SCHEME_BALANCED
        reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 1 /f
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 1 /f
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v GameDVR_Enabled /t REG_DWORD /d 1 /f
        reg add "HKCU\Control Panel\Mouse" /v MouseSensitivity /t REG_SZ /d 6 /f
        reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f
        reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 6 /f
        reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 10 /f
    }
    Start-Sleep -Seconds 2
    $TxtStatus.Text = "Defaults restored."
}

$BtnApply.Add_Click({ Apply-Optimizations })
$BtnRestore.Add_Click({ Restore-Defaults })

$Window.ShowDialog() | Out-Null
