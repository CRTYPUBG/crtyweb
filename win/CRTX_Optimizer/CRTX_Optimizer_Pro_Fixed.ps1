Add-Type -AssemblyName PresentationFramework
[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="CRTX FPS Optimizer" Height="400" Width="600"
        WindowStartupLocation="CenterScreen" Background="#1e1e1e">
    <Grid Margin="20">
        <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center" >
            <TextBlock Text="CRTX FPS Booster - GameLoop Pro" FontSize="22" Foreground="White" HorizontalAlignment="Center"/>
            <Button x:Name="OptimizeBtn" Content="FPS Boost Uygula" Width="200" Height="40" Margin="10" Background="#2ecc71" Foreground="White"/>
            <Button x:Name="RestoreBtn" Content="Ayarları Geri Al" Width="200" Height="40" Margin="10" Background="#e74c3c" Foreground="White"/>
            <TextBlock x:Name="StatusText" Text="" FontSize="14" Foreground="White" Margin="10" TextAlignment="Center"/>
        </StackPanel>
    </Grid>
</Window>
'@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

$OptimizeBtn = $window.FindName("OptimizeBtn")
$RestoreBtn = $window.FindName("RestoreBtn")
$StatusText = $window.FindName("StatusText")

$OptimizeBtn.Add_Click({
    $StatusText.Text = "FPS ayarları uygulanıyor..."

    # GameDVR kapatma
    reg add "HKEY_CURRENT_USER\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f | Out-Null
    reg add "HKEY_CURRENT_USER\System\GameConfigStore" /v GameDVR_FSEBehavior /t REG_DWORD /d 0 /f | Out-Null

    # Zamanlayıcı ve input lag için ayarlar
    bcdedit /set useplatformclock true | Out-Null
    bcdedit /set tscsyncpolicy Enhanced | Out-Null
    bcdedit /set disabledynamictick yes | Out-Null

    # Hyper-V ve benzeri sistemleri kapat (yeniden başlatma gerektirir)
    dism /Online /Disable-Feature:Microsoft-Hyper-V-All /NoRestart | Out-Null
    dism /Online /Disable-Feature:VirtualMachinePlatform /NoRestart | Out-Null
    dism /Online /Disable-Feature:Windows-Subsystem-Linux /NoRestart | Out-Null

    # AndroidEmulator.exe öncelik
    try {
        $proc = Get-Process -Name AndroidEmulator -ErrorAction Stop
        $proc.PriorityClass = 'High'
    } catch {}

    # Gereksiz servisleri durdur
    $services = "SysMain","WSearch","Fax","PrintSpooler","DiagTrack"
    foreach ($s in $services) {
        if (Get-Service $s -ErrorAction SilentlyContinue) {
            Stop-Service -Name $s -Force -ErrorAction SilentlyContinue
            Set-Service -Name $s -StartupType Disabled
        }
    }

    # Ağ optimizasyonu
    Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses ("8.8.8.8","8.8.4.4") -ErrorAction SilentlyContinue
    netsh interface tcp set global autotuninglevel=disabled | Out-Null

    # Temp temizliği
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue

    $StatusText.Text = "✅ FPS ayarları tamamlandı. Lütfen bilgisayarınızı yeniden başlatın."
})

$RestoreBtn.Add_Click({
    $StatusText.Text = "Ayarlar geri yükleniyor..."

    reg add "HKEY_CURRENT_USER\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 1 /f | Out-Null
    reg add "HKEY_CURRENT_USER\System\GameConfigStore" /v GameDVR_FSEBehavior /t REG_DWORD /d 1 /f | Out-Null

    bcdedit /deletevalue useplatformclock | Out-Null
    bcdedit /deletevalue tscsyncpolicy | Out-Null
    bcdedit /deletevalue disabledynamictick | Out-Null

    dism /Online /Enable-Feature:Microsoft-Hyper-V-All /NoRestart | Out-Null
    dism /Online /Enable-Feature:VirtualMachinePlatform /NoRestart | Out-Null
    dism /Online /Enable-Feature:Windows-Subsystem-Linux /NoRestart | Out-Null

    $services = "SysMain","WSearch","Fax","PrintSpooler","DiagTrack"
    foreach ($s in $services) {
        if (Get-Service $s -ErrorAction SilentlyContinue) {
            Set-Service -Name $s -StartupType Manual
            Start-Service -Name $s -ErrorAction SilentlyContinue
        }
    }

    $StatusText.Text = "♻️ Ayarlar geri yüklendi."
})

$window.ShowDialog() | Out-Null
