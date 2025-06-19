
Add-Type -AssemblyName PresentationFramework

$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="CRTY GameLoop Optimizer" Height="420" Width="620" Background="#1e1e1e" WindowStartupLocation="CenterScreen">
    <Grid Margin="20">
        <StackPanel HorizontalAlignment="Center" VerticalAlignment="Top">
            <TextBlock Text="CRTY GameLoop Optimizer" FontSize="26" FontWeight="Bold" Foreground="White" Margin="0,10,0,20" TextAlignment="Center"/>
            <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,0,0,20">
                <TextBox x:Name="KeyInput" Width="300" Height="28" Margin="0,0,10,0" PlaceholderText="Enter License Key"/>
                <Button x:Name="CheckKeyBtn" Content="Verify Key" Width="100" Height="28" Background="#0078D7" Foreground="White"/>
            </StackPanel>
            <TextBlock x:Name="StatusText" Text="" Foreground="Lime" FontSize="14" TextAlignment="Center" Margin="0,0,0,20"/>
            <CheckBox x:Name="FpsBoost" Content="Enable FPS Boost" Foreground="White" Margin="0,5"/>
            <CheckBox x:Name="AntiLag" Content="Enable Anti-Lag" Foreground="White" Margin="0,5"/>
            <CheckBox x:Name="InputLag" Content="Enable Input Lag Fix" Foreground="White" Margin="0,5"/>
            <CheckBox x:Name="Restore" Content="Restore Previous Settings" Foreground="White" Margin="0,5"/>
            <Button x:Name="ApplyBtn" Content="Apply Settings & Launch GameLoop" Width="240" Height="38" Margin="0,20,0,0" Background="#0078D7" Foreground="White"/>
        </StackPanel>
    </Grid>
</Window>
"@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]$XAML)
$Window = [Windows.Markup.XamlReader]::Load($reader)

$KeyInput = $Window.FindName("KeyInput")
$CheckKeyBtn = $Window.FindName("CheckKeyBtn")
$StatusText = $Window.FindName("StatusText")
$FpsBoost = $Window.FindName("FpsBoost")
$AntiLag = $Window.FindName("AntiLag")
$InputLag = $Window.FindName("InputLag")
$Restore = $Window.FindName("Restore")
$ApplyBtn = $Window.FindName("ApplyBtn")

$ApplyBtn.IsEnabled = $false

$CheckKeyBtn.Add_Click({
    if ($KeyInput.Text -eq "Crty-key-1246523564") {
        $StatusText.Text = "✅ License verified."
        $ApplyBtn.IsEnabled = $true
    } else {
        $StatusText.Text = "❌ Invalid license key."
        $ApplyBtn.IsEnabled = $false
    }
})

$ApplyBtn.Add_Click({
    $StatusText.Text = "Applying settings..."

    if ($FpsBoost.IsChecked) {
        Start-Process powershell -WindowStyle Hidden -ArgumentList "-Command `"
            powercfg /setactive SCHEME_MIN;
            reg add HKCU\Software\Microsoft\GameBar /v AllowAutoGameMode /t REG_DWORD /d 0 /f;
            reg add HKCU\System\GameConfigStore /v GameDVR_Enabled /t REG_DWORD /d 0 /f;
        `""
    }

    if ($AntiLag.IsChecked) {
        Start-Process powershell -WindowStyle Hidden -ArgumentList "-Command `"
            bcdedit /set useplatformtick yes;
            bcdedit /set disabledynamictick yes;
        `""
    }

    if ($InputLag.IsChecked) {
        Start-Process powershell -WindowStyle Hidden -ArgumentList "-Command `"
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 26 /f;
        `""
    }

    if ($Restore.IsChecked) {
        Start-Process powershell -WindowStyle Hidden -ArgumentList "-Command `"
            bcdedit /deletevalue useplatformtick;
            bcdedit /deletevalue disabledynamictick;
            powercfg /setactive SCHEME_BALANCED;
        `""
    }

    Start-Sleep -Seconds 2
    $StatusText.Text = "Launching GameLoop..."

    $paths = @(
        "C:\Program Files\TxGameAssistant\ui\AndroidEmulatorEn.exe",
        "C:\Program Files (x86)\TxGameAssistant\ui\AndroidEmulatorEn.exe"
    )
    $emuPath = $paths | Where-Object { Test-Path $_ } | Select-Object -First 1

    if ($emuPath) {
        Start-Process -FilePath $emuPath -ArgumentList '-cmd StartApk -param -startpkg "com.tencent.ig" -engine "aow" -vm "100" -fps "120" -resolution "1280x960" -from "Custom"' -Priority High
        $StatusText.Text = "✅ GameLoop started."
    } else {
        $StatusText.Text = "❌ GameLoop not found."
    }
})

$Window.ShowDialog() | Out-Null
