Add-Type -AssemblyName PresentationFramework

$XAML = @"
<Window xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation' 
        Title='GameLoop FPS Optimizer' Height='300' Width='350' WindowStartupLocation='CenterScreen' Background='White'>
    <Grid Margin='10'>
        <StackPanel VerticalAlignment='Center' HorizontalAlignment='Center' >
            <TextBlock Text='GameLoop FPS & Performance Optimizer' FontSize='16' FontWeight='Bold' Margin='0,0,0,15' HorizontalAlignment='Center'/>

            <CheckBox Name='ChkPowerPlan' Content='High Performance Power Plan' Margin='0,0,0,10'/>
            <CheckBox Name='ChkDisableGameDVR' Content='Disable Game DVR & Background Recording' Margin='0,0,0,10'/>
            <CheckBox Name='ChkNetworkPriority' Content='Set Network Priority for GameLoop' Margin='0,0,0,10'/>
            <CheckBox Name='ChkDisableVisualEffects' Content='Disable Visual Effects for Better Performance' Margin='0,0,0,10'/>
            <CheckBox Name='ChkInputLagFix' Content='Reduce Input Lag (Mouse Settings)' Margin='0,0,0,15'/>

            <StackPanel Orientation='Horizontal' HorizontalAlignment='Center'>
                <Button Name='BtnApply' Content='Apply Optimization' Width='140' Margin='5'/>
                <Button Name='BtnRestore' Content='Restore Defaults' Width='120' Margin='5'/>
            </StackPanel>

            <TextBlock Name='TxtStatus' Text='Status: Ready' Margin='15,10,15,0' TextAlignment='Center' Foreground='DarkGreen' FontWeight='SemiBold'/>
        </StackPanel>
    </Grid>
</Window>
"@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]$XAML)
$Window = [Windows.Markup.XamlReader]::Load($reader)

$ChkPowerPlan = $Window.FindName('ChkPowerPlan')
$ChkDisableGameDVR = $Window.FindName('ChkDisableGameDVR')
$ChkNetworkPriority = $Window.FindName('ChkNetworkPriority')
$ChkDisableVisualEffects = $Window.FindName('ChkDisableVisualEffects')
$ChkInputLagFix = $Window.FindName('ChkInputLagFix')

$BtnApply = $Window.FindName('BtnApply')
$BtnRestore = $Window.FindName('BtnRestore')
$TxtStatus = $Window.FindName('TxtStatus')

function Run-AdminScript([scriptblock]$ScriptBlock) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "powershell.exe"
    $psi.Arguments = "-NoProfile -WindowStyle Hidden -Command & { $($ScriptBlock.ToString()) }"
    $psi.Verb = "runas"
    $proc = [System.Diagnostics.Process]::Start($psi)
    $proc.WaitForExit()
}

function Apply-Optimizations {
    $TxtStatus.Text = "Applying optimizations..."
    try {
        if ($ChkPowerPlan.IsChecked) {
            Run-AdminScript { powercfg /setactive SCHEME_MIN }  # High Performance Plan
        }
        if ($ChkDisableGameDVR.IsChecked) {
            Run-AdminScript {
                reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
                reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f
                reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
            }
        }
        if ($ChkNetworkPriority.IsChecked) {
            Run-AdminScript {
                # Set Process Priority for GameLoop to High (Example)
                $processes = Get-Process | Where-Object { $_.ProcessName -like "*GameLoop*" }
                foreach ($proc in $processes) {
                    $proc.PriorityClass = 'High'
                }
            }
        }
        if ($ChkDisableVisualEffects.IsChecked) {
            Run-AdminScript {
                reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f
                reg add "HKCU\Control Panel\Desktop" /v UserPreferencesMask /t REG_BINARY /d 90120080 /f
            }
        }
        if ($ChkInputLagFix.IsChecked) {
            Run-AdminScript {
                reg add "HKCU\Control Panel\Mouse" /v MouseSensitivity /t REG_SZ /d 10 /f
                reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 1 /f
                reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f
                reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f
            }
        }
        $TxtStatus.Text = "Optimization applied successfully!"
    } catch {
        $TxtStatus.Text = "Error during optimization: $_"
    }
}

function Restore-Defaults {
    $TxtStatus.Text = "Restoring defaults..."
    try {
        Run-AdminScript {
            powercfg /setactive SCHEME_BALANCED
            reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 1 /f
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 1 /f
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v GameDVR_Enabled /t REG_DWORD /d 1 /f
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 1 /f
            reg add "HKCU\Control Panel\Desktop" /v UserPreferencesMask /t REG_BINARY /d 90130128 /f
            reg add "HKCU\Control Panel\Mouse" /v MouseSensitivity /t REG_SZ /d 6 /f
            reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f
            reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 6 /f
            reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 10 /f
        }
        $TxtStatus.Text = "Defaults restored successfully!"
    } catch {
        $TxtStatus.Text = "Error during restore: $_"
    }
}

$BtnApply.Add_Click({ Apply-Optimizations })
$BtnRestore.Add_Click({ Restore-Defaults })

$Window.ShowDialog() | Out-Null
