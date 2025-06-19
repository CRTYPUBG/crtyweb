Add-Type -AssemblyName PresentationFramework

$XAML = @"
<Window xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
        xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'
        Title='CRTY GameLoop Optimizer v2' Height='520' Width='700' Background='#1E1E1E' WindowStartupLocation='CenterScreen' ResizeMode='NoResize' FontFamily='Segoe UI'>
    <Grid Margin='20'>
        <Grid.RowDefinitions>
            <RowDefinition Height='Auto'/>
            <RowDefinition Height='*'/>
            <RowDefinition Height='Auto'/>
        </Grid.RowDefinitions>

        <TextBlock x:Name='TitleText' Text='CRTY TOOL v2' FontSize='44' FontWeight='Bold' 
                   HorizontalAlignment='Center' VerticalAlignment='Top' Foreground='White' Margin='0,0,0,10'/>

        <StackPanel Grid.Row='1' Margin='0,10,0,0' VerticalAlignment='Top'>

            <StackPanel Orientation='Horizontal' Margin='0,0,0,15' VerticalAlignment='Center'>
                <TextBlock Text='FPS Setting:' Foreground='White' FontSize='16' Width='110' VerticalAlignment='Center'/>
                <ComboBox x:Name='FpsComboBox' Width='160' FontSize='16' SelectedIndex='1'>
                    <ComboBoxItem Content='30' />
                    <ComboBoxItem Content='60' />
                    <ComboBoxItem Content='90' />
                    <ComboBoxItem Content='120' />
                </ComboBox>
            </StackPanel>

            <TextBlock Text='Anti-Lag & FPS Boost Options:' Foreground='White' FontSize='16' Margin='0,0,0,5' />
            <StackPanel Margin='20,0,0,25'>
                <CheckBox x:Name='ChkDisableGameDVR' Content='Disable Game DVR' Foreground='White' FontSize='14' Margin='0,6'/>
                <CheckBox x:Name='ChkDisableGameBar' Content='Disable Game Bar' Foreground='White' FontSize='14' Margin='0,6'/>
                <CheckBox x:Name='ChkOptimizeTimer' Content='Optimize Timer Resolution (useplatformtick)' Foreground='White' FontSize='14' Margin='0,6'/>
                <CheckBox x:Name='ChkDisableDynamicTick' Content='Disable Dynamic Tick' Foreground='White' FontSize='14' Margin='0,6'/>
                <CheckBox x:Name='ChkHighPriority' Content='Run Emulator with High Priority' Foreground='White' FontSize='14' Margin='0,6'/>
            </StackPanel>

            <StackPanel Orientation='Horizontal' Margin='0,0,0,20' VerticalAlignment='Center'>
                <TextBlock Text='License Key:' Foreground='White' FontSize='16' Width='120' VerticalAlignment='Center'/>
                <TextBox x:Name='KeyBox' Width='280' FontSize='16' />
                <Button x:Name='BtnCheckKey' Content='Validate' Width='100' Margin='15,0,0,0' FontSize='16' Cursor='Hand' />
            </StackPanel>

            <TextBlock x:Name='KeyStatusText' Text='Please validate your license key.' Foreground='Orange' FontSize='14' Margin='0,0,0,20' TextAlignment='Center'/>

            <Button x:Name='StartButton' Content='START GAME 🚀' Width='260' Height='70' 
                HorizontalAlignment='Center' Background='#007ACC' Foreground='White' FontSize='22' Cursor='Hand' IsEnabled='False' />
        </StackPanel>

        <TextBlock x:Name='StatusText' Grid.Row='2' Text='Waiting...' Foreground='LightGreen' FontSize='14' HorizontalAlignment='Center' Margin='0,20,0,0'/>
    </Grid>
</Window>
"@

$xmlReader = [System.Xml.XmlReader]::Create([System.IO.StringReader]$XAML)
$Window = [Windows.Markup.XamlReader]::Load($xmlReader)

$StartButton = $Window.FindName('StartButton')
$StatusText = $Window.FindName('StatusText')
$TitleText = $Window.FindName('TitleText')
$FpsComboBox = $Window.FindName('FpsComboBox')
$ChkDisableGameDVR = $Window.FindName('ChkDisableGameDVR')
$ChkDisableGameBar = $Window.FindName('ChkDisableGameBar')
$ChkOptimizeTimer = $Window.FindName('ChkOptimizeTimer')
$ChkDisableDynamicTick = $Window.FindName('ChkDisableDynamicTick')
$ChkHighPriority = $Window.FindName('ChkHighPriority')
$KeyBox = $Window.FindName('KeyBox')
$BtnCheckKey = $Window.FindName('BtnCheckKey')
$KeyStatusText = $Window.FindName('KeyStatusText')

# Rainbow cycling title effect
$colors = @("Red","Orange","Yellow","Green","Cyan","Blue","Purple")
$i = 0
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromMilliseconds(150)
$timer.Add_Tick({
    $TitleText.Foreground = [System.Windows.Media.Brushes]::$( $colors[$i] )
    $i = ($i + 1) % $colors.Length
})
$timer.Start()

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

$global:validKey = $false
$expectedKey = "Crty-key-1246523564"

$BtnCheckKey.Add_Click({
    if ($KeyBox.Text.Trim() -eq $expectedKey) {
        $KeyStatusText.Text = "License validated successfully! 🎉"
        $KeyStatusText.Foreground = [System.Windows.Media.Brushes]::Lime
        $StartButton.IsEnabled = $true
        $global:validKey = $true
    } else {
        $KeyStatusText.Text = "Invalid license key!"
        $KeyStatusText.Foreground = [System.Windows.Media.Brushes]::Red
        $StartButton.IsEnabled = $false
        $global:validKey = $false
    }
})

$StartButton.Add_Click({
    if (-not $global:validKey) {
        $StatusText.Text = "Please validate your license key first!"
        return
    }

    $StatusText.Text = "Searching for GameLoop path..."
    $emuPath = Find-EmulatorPath
    if (-not $emuPath) {
        $StatusText.Text = "Path not found, please select the emulator executable."
        $emuPath = Ask-UserForPath
        if (-not $emuPath) {
            $StatusText.Text = "Operation cancelled."
            return
        }
    }

    $StatusText.Text = "Applying system optimizations..."

    if ($ChkDisableGameDVR.IsChecked) {
        reg add HKCU\System\GameConfigStore /v GameDVR_Enabled /t REG_DWORD /d 0 /f | Out-Null
        reg add HKCU\System\GameConfigStore /v GameDVR_FSEBehavior /t REG_DWORD /d 0 /f | Out-Null
    }
    if ($ChkDisableGameBar.IsChecked) {
        reg add HKCU\Software\Microsoft\GameBar /v AllowAutoGameMode /t REG_DWORD /d 0 /f | Out-Null
    }
    if ($ChkOptimizeTimer.IsChecked) {
        bcdedit /set useplatformtick yes | Out-Null
        bcdedit /set disabledynamictick yes | Out-Null
        bcdedit /set tscsyncpolicy Enhanced | Out-Null
    }
    if ($ChkDisableDynamicTick.IsChecked) {
        bcdedit /set disabledynamictick yes | Out-Null
    }

    $fps = ($FpsComboBox.SelectedItem).Content
    $StatusText.Text = "Starting GameLoop with FPS: $fps"

    $arguments = "-cmd StartApk -param -startpkg `"com.tencent.ig`" -engine `"aow`" -vm `"100`" -fps `"$fps`" -resolution `"1280x960`" -from `"Custom`""

    $priority = if ($ChkHighPriority.IsChecked) { "High" } else { "Normal" }

    Start-Process -FilePath $emuPath -ArgumentList $arguments -Priority $priority

    $StatusText.Text = "Game started successfully ✔️"
})

$Window.ShowDialog() | Out-Null
