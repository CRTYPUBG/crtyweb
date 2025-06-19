Add-Type -AssemblyName PresentationFramework

$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="CRTY GameLoop Optimize Aracı" Height="420" Width="640" Background="#1e1e1e" WindowStartupLocation="CenterScreen">
  <Grid Margin="10">
    <TextBlock Text="🟢 CTTY TOOL" FontSize="32" FontWeight="Bold" Foreground="Lime" HorizontalAlignment="Center" Margin="0,10,0,0"/>
    
    <CheckBox x:Name="FpsBoost" Content="FPS Artır (DirectX + OpenGL için)" Foreground="White" Margin="20,80,0,0" VerticalAlignment="Top"/>
    <CheckBox x:Name="AntiLag" Content="Anti Lag Uygula" Foreground="White" Margin="20,110,0,0" VerticalAlignment="Top"/>
    <CheckBox x:Name="InputLag" Content="Input Lag Kaldır" Foreground="White" Margin="20,140,0,0" VerticalAlignment="Top"/>
    <CheckBox x:Name="GeriAl" Content="🔁 Önceki Ayarlara Geri Dön" Foreground="Orange" Margin="20,170,0,0" VerticalAlignment="Top"/>
    
    <Button x:Name="RunBtn" Content="🛠️ Optimize Et ve Başlat" Width="240" Height="50" HorizontalAlignment="Center" VerticalAlignment="Bottom" Margin="0,0,0,60" Background="#333" Foreground="White" FontSize="16"/>
    <TextBlock x:Name="DurumText" Text="Hazır..." Foreground="LightGreen" FontSize="14" HorizontalAlignment="Center" VerticalAlignment="Bottom" Margin="0,0,0,20"/>
  </Grid>
</Window>
"@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]$XAML)
$Window = [Windows.Markup.XamlReader]::Load($reader)

$FpsBoost = $Window.FindName("FpsBoost")
$AntiLag = $Window.FindName("AntiLag")
$InputLag = $Window.FindName("InputLag")
$GeriAl = $Window.FindName("GeriAl")
$RunBtn = $Window.FindName("RunBtn")
$DurumText = $Window.FindName("DurumText")

function GameLoopBul {
  $yollar = @(
    "C:\Program Files\TxGameAssistant\ui\AndroidEmulatorEn.exe",
    "C:\Program Files (x86)\TxGameAssistant\ui\AndroidEmulatorEn.exe"
  )
  foreach ($y in $yollar) {
    if (Test-Path $y) { return $y }
  }
  Add-Type -AssemblyName System.Windows.Forms
  $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
  $fileDialog.Filter = "AndroidEmulatorEn.exe|AndroidEmulatorEn.exe"
  $fileDialog.Title = "GameLoop EXE Yolunu Seç"
  if ($fileDialog.ShowDialog() -eq "OK") {
    return $fileDialog.FileName
  }
  return $null
}

$RunBtn.Add_Click({
  $DurumText.Text = "İşleniyor..."
  $exe = GameLoopBul
  if (-not $exe) {
    $DurumText.Text = "GameLoop yolu bulunamadı!"
    return
  }

  if ($GeriAl.IsChecked) {
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -Command `"bcdedit /deletevalue useplatformtick; bcdedit /deletevalue disabledynamictick; bcdedit /deletevalue tscsyncpolicy; powercfg /setactive SCHEME_BALANCED`""
    $DurumText.Text = "Ayarlar sıfırlandı!"
    return
  }

  if ($FpsBoost.IsChecked) {
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -Command `"bcdedit /set useplatformtick yes; bcdedit /set disabledynamictick yes; bcdedit /set tscsyncpolicy Enhanced; powercfg /setactive SCHEME_MIN`""
  }

  if ($AntiLag.IsChecked) {
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -Command `"reg add HKCU\Software\Microsoft\GameBar /v AllowAutoGameMode /t REG_DWORD /d 0 /f; reg add HKCU\System\GameConfigStore /v GameDVR_Enabled /t REG_DWORD /d 0 /f; reg add HKCU\System\GameConfigStore /v GameDVR_FSEBehavior /t REG_DWORD /d 0 /f`""
  }

  if ($InputLag.IsChecked) {
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -Command `"reg add HKCU\Control Panel\Mouse /v MouseSensitivity /t REG_SZ /d 10 /f`""
  }

  Start-Sleep -Seconds 1
  Start-Process -FilePath $exe -ArgumentList '-cmd StartApk -param -startpkg "com.tencent.ig" -engine "aow" -vm "100" -fps "120" -resolution "1280x960" -from "Custom"' -Priority High
  $DurumText.Text = "GameLoop başlatıldı ✅"
})

$Window.ShowDialog() | Out-Null
