Add-Type -AssemblyName PresentationFramework

$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="CRTY GameLoop Optimizer" Height="360" Width="480" Background="#1e1e1e" WindowStartupLocation="CenterScreen">
  <Grid Margin="20">
    <StackPanel>
      <TextBlock Text="CRTY TOOL v1.0" Foreground="White" FontSize="28" HorizontalAlignment="Center" Margin="0,0,0,10"/>
      <TextBox x:Name="KeyBox" Height="30" Text="Enter license key..." Foreground="Gray"/>
      <Button x:Name="CheckKeyBtn" Content="Validate Key" Height="35" Background="#333" Foreground="White" Margin="0,10,0,10"/>
      <StackPanel x:Name="MainPanel" Visibility="Collapsed">
        <CheckBox x:Name="FpsBoost" Content="FPS Boost" Foreground="White"/>
        <CheckBox x:Name="AntiLag" Content="Anti‑Lag Fix" Foreground="White"/>
        <CheckBox x:Name="InputLag" Content="Input‑Lag Removal" Foreground="White"/>
        <CheckBox x:Name="Restore" Content="Restore Settings" Foreground="White"/>
        <Button x:Name="RunBtn" Content="Apply Tweaks" Height="40" Background="Green" Foreground="White" Margin="0,10,0,0"/>
        <TextBlock x:Name="DurumText" Text="Ready" Foreground="Lime" HorizontalAlignment="Center" Margin="0,10,0,0"/>
      </StackPanel>
    </StackPanel>
  </Grid>
</Window>
"@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]$XAML)
$Window = [Windows.Markup.XamlReader]::Load($reader)

$KeyBox     = $Window.FindName("KeyBox")
$CheckKeyBtn= $Window.FindName("CheckKeyBtn")
$MainPanel  = $Window.FindName("MainPanel")
$FpsBoost   = $Window.FindName("FpsBoost")
$AntiLag    = $Window.FindName("AntiLag")
$InputLag   = $Window.FindName("InputLag")
$Restore    = $Window.FindName("Restore")
$RunBtn     = $Window.FindName("RunBtn")
$DurumText  = $Window.FindName("DurumText")

$KeyBox.Add_GotFocus({
  if ($KeyBox.Text -eq "Enter license key...") {
    $KeyBox.Text = ""
    $KeyBox.Foreground = "White"
  }
})
$KeyBox.Add_LostFocus({
  if ([string]::IsNullOrWhiteSpace($KeyBox.Text)) {
    $KeyBox.Text = "Enter license key..."
    $KeyBox.Foreground = "Gray"
  }
})

$CheckKeyBtn.Add_Click({
  if ($KeyBox.Text -eq "Crty-key-1246523564") {
    $KeyBox.Visibility = "Collapsed"
    $CheckKeyBtn.Visibility = "Collapsed"
    $MainPanel.Visibility = "Visible"
  } else {
    [System.Windows.MessageBox]::Show("Invalid key!", "Error", "OK", "Error")
  }
})

$RunBtn.Add_Click({
  $DurumText.Text = "Applying tweaks..."
  Start-Sleep -Milliseconds 300

  if ($FpsBoost.IsChecked) {
    powercfg /setactive SCHEME_MIN
    bcdedit /set useplatformtick yes
    bcdedit /set disabledynamictick yes
    bcdedit /set tscsyncpolicy Enhanced
  }

  if ($AntiLag.IsChecked) {
    reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
    reg add "HKCU\Software\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 0 /f
  }

  if ($InputLag.IsChecked) {
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f
  }

  if ($Restore.IsChecked) {
    bcdedit /deletevalue useplatformtick
    bcdedit /deletevalue disabledynamictick
    bcdedit /deletevalue tscsyncpolicy
    reg delete "HKCU\System\GameConfigStore" /v GameDVR_Enabled /f
    reg delete "HKCU\Software\Microsoft\GameBar" /v AllowAutoGameMode /f
  }

  Start-Sleep -Milliseconds 300
  $DurumText.Text = "Tweaks applied ✔️"
})

$Window.ShowDialog() | Out-Null
