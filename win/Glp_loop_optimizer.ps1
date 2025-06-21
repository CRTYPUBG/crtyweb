Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# Window oluştur
$window = New-Object System.Windows.Window
$window.Title = "CRTY GameLoop Optimizer"
$window.Width = 450
$window.Height = 300
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
$btnOptimize.Width = 250
$btnOptimize.Height = 40
$btnOptimize.Margin = [System.Windows.Thickness]::new(0,0,0,10)
$btnOptimize.Background = [System.Windows.Media.Brushes]::DarkGreen
$btnOptimize.Foreground = [System.Windows.Media.Brushes]::White
$btnOptimize.FontWeight = 'SemiBold'
$stackPanel.Children.Add($btnOptimize) | Out-Null

# Geri al butonu
$btnUndo = New-Object System.Windows.Controls.Button
$btnUndo.Content = "Ayarları Geri Al"
$btnUndo.Width = 250
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

# Event: Optimize butonu tıklanınca
$btnOptimize.Add_Click({
    try {
        $statusText.Text = "Durum: Optimize ediliyor..."

        # Game DVR kapat
        reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f | Out-Null
        reg add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehavior /t REG_DWORD /d 0 /f | Out-Null

        # CPU Power Plan to High Performance
        reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v CsEnabled /t REG_DWORD /d 0 /f | Out-Null
        reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes" /v ActivePowerScheme /t REG_SZ /d 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c /f | Out-Null

        # Disable SysMain (Superfetch)
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\SysMain" /v Start /t REG_DWORD /d 4 /f | Out-Null
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\SysMain" /v Start /t REG_DWORD /d 4 /f | Out-Null

        # Disable Windows Update
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\wuauserv" /v Start /t REG_DWORD /d 4 /f | Out-Null
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\wuauserv" /v Start /t REG_DWORD /d 4 /f | Out-Null

        # Disable BITS
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\BITS" /v Start /t REG_DWORD /d 4 /f | Out-Null
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\BITS" /v Start /t REG_DWORD /d 4 /f | Out-Null

        # Disable TCP autotuning
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v Tcp1323Opts /t REG_DWORD /d 1 /f | Out-Null
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v Tcp1323Opts /t REG_DWORD /d 1 /f | Out-Null

        Start-Sleep -Seconds 2

        $statusText.Text = "Durum: Optimizasyon tamamlandı! 🎮"
    }
    catch {
        $statusText.Text = "Hata: $_"
    }
})

# Event: Geri al butonu tıklanınca
$btnUndo.Add_Click({
    try {
        $statusText.Text = "Durum: Ayarlar geri alınıyor..."

        # Game DVR aç
        reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 1 /f | Out-Null
        reg add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehavior /t REG_DWORD /d 1 /f | Out-Null
        # Rollback CPU Power Plan to Balanced
        reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v CsEnabled /t REG_DWORD /d 1 /f  | Out-Null
        reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes" /v ActivePowerScheme /t REG_SZ /d 381b4222-f694-41f0-9685-ff5bb260df2e /f | Out-Null

        # Rollback SysMain (Superfetch) to Automatic
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\SysMain" /v Start /t REG_DWORD /d 2 /f | Out-Null
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\SysMain" /v Start /t REG_DWORD /d 2 /f | Out-Null

        # Rollback Windows Update to Manual
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\wuauserv" /v Start /t REG_DWORD /d 3 /f | Out-Null
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\wuauserv" /v Start /t REG_DWORD /d 3 /f | Out-Null

        # Rollback BITS to Manual
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\BITS" /v Start /t REG_DWORD /d 3 /f | Out-Null
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\BITS" /v Start /t REG_DWORD /d 3 /f | Out-Null

        # Rollback TCP Autotuning to Normal
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v Tcp1323Opts /t REG_DWORD /d 3 /f | Out-Null
        reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v Tcp1323Opts /t REG_DWORD /d 3 /f | Out-Null

        Start-Sleep -Seconds 2

        $statusText.Text = "Durum: Ayarlar geri alındı."
    }
    catch {
        $statusText.Text = "Hata: $_"
    }
})

# Window'a grid ekle ve göster
$window.Content = $grid
$window.ShowDialog() | Out-Null
