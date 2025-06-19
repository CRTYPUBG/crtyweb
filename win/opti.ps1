Add-Type -AssemblyName PresentationFramework

# Pencere oluştur
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="CRTY GameLoop FPS Optimizer" Height="300" Width="400" WindowStartupLocation="CenterScreen" ResizeMode="NoResize" Background="#222222" >
    <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <TextBlock Grid.Row="0" Text="CRTY GameLoop FPS Optimize Aracı" FontSize="18" FontWeight="Bold" Foreground="White" HorizontalAlignment="Center" Margin="0,0,0,10"/>

        <StackPanel Grid.Row="1" VerticalAlignment="Center" HorizontalAlignment="Center" Width="300" Spacing="10">
            <Button Name="btnOptimize" Content="⚡ Optimize Et (FPS Artır & Anti-Lag)" Height="40" FontSize="14" Background="#007ACC" Foreground="White" />
            <Button Name="btnUndo" Content="↩ Ayarları Geri Al" Height="40" FontSize="14" Background="#555555" Foreground="White" />
        </StackPanel>

        <TextBlock Name="statusText" Grid.Row="2" Text="Durum: Hazır." FontSize="14" Foreground="LightGreen" HorizontalAlignment="Center" Margin="0,15,0,0"/>
    </Grid>
</Window>
"@

# XAML'ı yükle
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Kontrolleri yakala
$btnOptimize = $window.FindName("btnOptimize")
$btnUndo = $window.FindName("btnUndo")
$statusText = $window.FindName("statusText")

# Optimize Et butonu tıklama olayı
$btnOptimize.Add_Click({
    try {
        $statusText.Text = "Durum: Gelişmiş optimizasyon başlıyor..."

        # Game DVR kapat
        reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f | Out-Null
        reg add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehavior /t REG_DWORD /d 0 /f | Out-Null

        # Xbox Game Bar kapat
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f | Out-Null
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AudioCaptureEnabled /t REG_DWORD /d 0 /f | Out-Null

        # Xbox ve Gaming Görevlerini Kapat (Schedule Task)
        Get-ScheduledTask | Where-Object { $_.TaskName -like "*Xbox*" -or $_.TaskName -like "*Gaming*" } | ForEach-Object { Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath }

        # Güç planını Yüksek Performansa al
        powercfg /setactive SCHEME_MIN

        # CPU throttle ayarları (maksimum performans)
        powercfg /setacvalueindex SCHEME_MIN SUB_PROCESSOR PROCTHROTTLEMIN 100
        powercfg /setacvalueindex SCHEME_MIN SUB_PROCESSOR PROCTHROTTLEMAX 100
        powercfg /setactive SCHEME_MIN

        # Superfetch (SysMain) servisini kapat
        Stop-Service SysMain -ErrorAction SilentlyContinue
        Set-Service SysMain -StartupType Disabled

        # TCP autotuning kapat (lag azaltmak için)
        netsh interface tcp set global autotuninglevel=disabled | Out-Null

        # GameLoop önceliğini yüksek yap (varsa)
        $gameLoop = Get-Process -Name "GameLoop" -ErrorAction SilentlyContinue
        if ($gameLoop) {
            $gameLoop | ForEach-Object { $_.PriorityClass = "High" }
        }

        # Sanal bellek elle ayarla (16GB RAM için örnek)
        $minPageFile = 16384
        $maxPageFile = 32768
        $computer = Get-WmiObject -Class Win32_ComputerSystem
        $computer.AutomaticManagedPagefile = $false
        $pagefile = Get-WmiObject -Query "SELECT * FROM Win32_PageFileSetting WHERE Name LIKE 'C:\\pagefile.sys'"
        if ($pagefile) {
            $pagefile.InitialSize = $minPageFile
            $pagefile.MaximumSize = $maxPageFile
            $pagefile.Put() | Out-Null
        }

        Start-Sleep -Seconds 3
        $statusText.Text = "Durum: Optimizasyon tamamlandı! 🎮🚀"
    }
    catch {
        $statusText.Text = "Hata: $_"
    }
})

# Geri Al butonu tıklama olayı
$btnUndo.Add_Click({
    try {
        $statusText.Text = "Durum: Ayarlar geri alınıyor..."

        # Game DVR aç
        reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 1 /f | Out-Null
        reg add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehavior /t REG_DWORD /d 1 /f | Out-Null

        # Xbox Game Bar aç
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 1 /f | Out-Null
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AudioCaptureEnabled /t REG_DWORD /d 1 /f | Out-Null

        # Schedule Task yeniden aç
        Get-ScheduledTask | Where-Object { $_.TaskName -like "*Xbox*" -or $_.TaskName -like "*Gaming*" } | ForEach-Object { Enable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath }

        # Güç planını Dengeye al
        powercfg /setactive SCHEME_BALANCED

        # SysMain servisini aç
        Set-Service SysMain -StartupType Automatic
        Start-Service SysMain

        # TCP autotuning aç
        netsh interface tcp set global autotuninglevel=normal | Out-Null

        # Sanal bellek otomatik yönetim
        $computer = Get-WmiObject -Class Win32_ComputerSystem
        $computer.AutomaticManagedPagefile = $true

        Start-Sleep -Seconds 3
        $statusText.Text = "Durum: Ayarlar geri alındı."
    }
    catch {
        $statusText.Text = "Hata: $_"
    }
})

# Pencereyi aç
$window.ShowDialog() | Out-Null
