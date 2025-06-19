Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# Window oluştur
$window = New-Object System.Windows.Window
$window.Title = "CRTY GameLoop Optimizer"
$window.Width = 450
$window.Height = 350
$window.WindowStartupLocation = 'CenterScreen'
$window.Background = [System.Windows.Media.Brushes]::WhiteSmoke

# Grid oluştur
$grid = New-Object System.Windows.Controls.Grid
$grid.Margin = [System.Windows.Thickness]::new(10)

# Grid row tanımları
$row1 = New-Object System.Windows.Controls.RowDefinition
$row1.Height = [System.Windows.GridLength]::Auto
$row2 = New-Object System.Windows.Controls.RowDefinition
$row2.Height = [System.Windows.GridLength]::Auto
$row3 = New-Object System.Windows.Controls.RowDefinition
$row3.Height = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
$row4 = New-Object System.Windows.Controls.RowDefinition
$row4.Height = [System.Windows.GridLength]::Auto

$grid.RowDefinitions.Add($row1)
$grid.RowDefinitions.Add($row2)
$grid.RowDefinitions.Add($row3)
$grid.RowDefinitions.Add($row4)

# Başlık TextBlock
$titleText = New-Object System.Windows.Controls.TextBlock
$titleText.Text = "CRTY GameLoop Optimizer"
$titleText.FontSize = 22
$titleText.FontWeight = 'Bold'
$titleText.Foreground = [System.Windows.Media.Brushes]::Black
$titleText.HorizontalAlignment = 'Center'
$titleText.Margin = [System.Windows.Thickness]::new(0,0,0,15)
[System.Windows.Controls.Grid]::SetRow($titleText,0)
$grid.Children.Add($titleText) | Out-Null

# Durum TextBlock
$statusText = New-Object System.Windows.Controls.TextBlock
$statusText.Text = "Durum: Bekleniyor..."
$statusText.FontSize = 14
$statusText.Foreground = [System.Windows.Media.Brushes]::Black
$statusText.HorizontalAlignment = 'Center'
$statusText.Margin = [System.Windows.Thickness]::new(0,0,0,10)
[System.Windows.Controls.Grid]::SetRow($statusText,1)
$grid.Children.Add($statusText) | Out-Null

# Butonlar için StackPanel
$stackPanel = New-Object System.Windows.Controls.StackPanel
$stackPanel.Orientation = 'Vertical'
$stackPanel.HorizontalAlignment = 'Center'
$stackPanel.VerticalAlignment = 'Top'
[System.Windows.Controls.Grid]::SetRow($stackPanel,2)
$grid.Children.Add($stackPanel) | Out-Null

# Optimize butonu
$btnOptimize = New-Object System.Windows.Controls.Button
$btnOptimize.Content = "Optimize Et (FPS & Anti-Lag)"
$btnOptimize.Width = 300
$btnOptimize.Height = 40
$btnOptimize.Margin = [System.Windows.Thickness]::new(0,0,0,10)
$btnOptimize.Background = [System.Windows.Media.Brushes]::DarkGreen
$btnOptimize.Foreground = [System.Windows.Media.Brushes]::White
$btnOptimize.FontWeight = 'SemiBold'
$stackPanel.Children.Add($btnOptimize) | Out-Null

# Geri al butonu
$btnUndo = New-Object System.Windows.Controls.Button
$btnUndo.Content = "Ayarları Geri Al"
$btnUndo.Width = 300
$btnUndo.Height = 40
$btnUndo.Background = [System.Windows.Media.Brushes]::DarkRed
$btnUndo.Foreground = [System.Windows.Media.Brushes]::White
$btnUndo.FontWeight = 'SemiBold'
$stackPanel.Children.Add($btnUndo) | Out-Null

# Alt copyright yazısı
$copyrightText = New-Object System.Windows.Controls.TextBlock
$copyrightText.Text = "© 2025 CRTY Tool"
$copyrightText.FontSize = 12
$copyrightText.Foreground = [System.Windows.Media.Brushes]::Gray
$copyrightText.HorizontalAlignment = 'Center'
$copyrightText.Margin = [System.Windows.Thickness]::new(0,15,0,0)
[System.Windows.Controls.Grid]::SetRow($copyrightText,3)
$grid.Children.Add($copyrightText) | Out-Null

# Optimize fonksiyonu
function Optimize-GameLoop {
    try {
        # Game DVR ve Xbox Game Bar kapat
        reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f | Out-Null
        reg add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehavior /t REG_DWORD /d 0 /f | Out-Null
        reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f | Out-Null
        reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowBroadcastRecording /t REG_DWORD /d 0 /f | Out-Null

        # Superfetch (SysMain) servisini durdur
        Stop-Service -Name "SysMain" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "SysMain" -StartupType Disabled

        # CPU güç planını Ultimate Performance (Nihai Performans) yap
        $ultimatePerfGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
        $existingPlans = powercfg /list
        if (-not ($existingPlans -match $ultimatePerfGuid)) {
            powercfg -duplicatescheme $ultimatePerfGuid | Out-Null
        }
        powercfg /setactive $ultimatePerfGuid

        # TCP autotuning kapat (lag azaltmak için)
        netsh interface tcp set global autotuning=disabled | Out-Null

        # Sanal bellek otomatik ayar yap (RAM*1.5)
        $totalRAM = (Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory
        $totalRAMMB = [math]::Round($totalRAM / 1MB)
        $initialSize = $totalRAMMB
        $maximumSize = [math]::Round($totalRAMMB * 1.5)
        $pageFile = "C:\pagefile.sys"

        wmic computersystem where name="%computername%" set AutomaticManagedPagefile=False | Out-Null
        wmic pagefileset where name="$pageFile" delete | Out-Null
        wmic pagefileset create name="$pageFile" | Out-Null
        wmic pagefileset where name="$pageFile" set InitialSize=$initialSize,MaximumSize=$maximumSize | Out-Null

        # GameLoop işlemini yüksek önceliğe al (örnek: dnplayer.exe)
        $gameloopProcess = Get-Process -Name "dnplayer" -ErrorAction SilentlyContinue
        if ($gameloopProcess) {
            $gameloopProcess | ForEach-Object {
                $_.PriorityClass = 'High'
            }
        }

        # Zamanlayıcı çözünürlüğünü 1ms yap (performans için)
        # (Yöntem biraz farklıdır, bunun için ekstra DLL import gerekebilir, burada örnek veriliyor)
        # Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "powershell -command ""[DllImport('winmm.dll')] public static extern uint timeBeginPeriod(uint uPeriod); timeBeginPeriod(1);""" -NoNewWindow -Wait

        # Görsel efektleri azalt (Windows görsel ayarları)
        $VisualFX = @(
            "UserPreferencesMask"
            "VisualFXSetting"
        )
        foreach ($name in $VisualFX) {
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\" -Name $name -Value 2 -ErrorAction SilentlyContinue
        }

        return "Optimizasyon tamamlandı! FPS artışı ve anti-lag etkin."
    }
    catch {
        return "Hata oluştu: $_"
    }
}

# Geri alma fonksiyonu
function Undo-Optimize {
    try {
        # Game DVR ve Xbox Game Bar aç
        reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 1 /f | Out-Null
        reg add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehavior /t REG_DWORD /d 1 /f | Out-Null
        reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /f | Out-Null
        reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowBroadcastRecording /f | Out-Null

        # Superfetch (SysMain) servisini başlat ve otomatik yap
        Set-Service -Name "SysMain" -StartupType Automatic
        Start-Service -Name "SysMain" -ErrorAction SilentlyContinue

        # CPU güç planını Balanced yap
        powercfg /setactive SCHEME_BALANCED

        # TCP autotuning aç
        netsh interface tcp set global autotuning=normal | Out-Null

        # Sanal bellek otomatik ayar yap
        wmic computersystem where name="%computername%" set AutomaticManagedPagefile=True | Out-Null

        return "Ayarlar geri alındı."
    }
    catch {
        return "Hata oluştu: $_"
    }
}

# Buton tıklama eventleri
$btnOptimize.Add_Click({
    $statusText.Text = "Durum: Optimize ediliyor..."
    $result = Optimize-GameLoop
    $statusText.Text = "Durum: $result"
})

$btnUndo.Add_Click({
    $statusText.Text = "Durum: Ayarlar geri alınıyor..."
    $result = Undo-Optimize
    $statusText.Text = "Durum: $result"
})

# Window'a grid ekle ve göster
$window.Content = $grid
$window.ShowDialog() | Out-Null
