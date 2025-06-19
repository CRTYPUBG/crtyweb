Add-Type -AssemblyName PresentationFramework

# Basit arayüz fonksiyonu
function Show-UI {
    $Window = New-Object System.Windows.Window
    $Window.Title = "CRTY FPS OPTIMIZER"
    $Window.Width = 600
    $Window.Height = 350
    $Window.WindowStartupLocation = "CenterScreen"
    $Window.ResizeMode = "NoResize"
    $Window.Background = [System.Windows.Media.Brushes]::WhiteSmoke

    $Grid = New-Object System.Windows.Controls.Grid
    $Grid.Margin = [System.Windows.Thickness]::new(20)

    # Satırlar
    $row1 = New-Object System.Windows.Controls.RowDefinition
    $row1.Height = [System.Windows.GridLength]::Auto
    $Grid.RowDefinitions.Add($row1)
    $row2 = New-Object System.Windows.Controls.RowDefinition
    $row2.Height = New-Object System.Windows.GridLength(80)
    $Grid.RowDefinitions.Add($row2)
    $row3 = New-Object System.Windows.Controls.RowDefinition
    $row3.Height = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star)
    $Grid.RowDefinitions.Add($row3)

    # Başlık
    $Title = New-Object System.Windows.Controls.TextBlock
    $Title.Text = "CRTY FPS OPTIMIZER"
    $Title.FontSize = 24
    $Title.FontWeight = 'Bold'
    $Title.Foreground = [System.Windows.Media.Brushes]::DarkBlue
    $Title.HorizontalAlignment = 'Center'
    $Title.VerticalAlignment = 'Center'
    [System.Windows.Controls.Grid]::SetRow($Title, 0)
    $Grid.Children.Add($Title) | Out-Null

    # Başlat Butonu
    $StartButton = New-Object System.Windows.Controls.Button
    $StartButton.Content = "Optimize Et"
    $StartButton.Width = 200
    $StartButton.Height = 60
    $StartButton.FontSize = 18
    $StartButton.Foreground = [System.Windows.Media.Brushes]::White
    $StartButton.Background = [System.Windows.Media.Brushes]::Green
    $StartButton.HorizontalAlignment = 'Center'
    [System.Windows.Controls.Grid]::SetRow($StartButton, 1)
    $Grid.Children.Add($StartButton) | Out-Null

    # Durum metni
    $Status = New-Object System.Windows.Controls.TextBlock
    $Status.Text = "Durum: Bekleniyor..."
    $Status.FontSize = 16
    $Status.Foreground = [System.Windows.Media.Brushes]::Black
    $Status.TextAlignment = 'Center'
    $Status.HorizontalAlignment = 'Center'
    $Status.VerticalAlignment = 'Top'
    $Status.TextWrapping = 'Wrap'
    [System.Windows.Controls.Grid]::SetRow($Status, 2)
    $Grid.Children.Add($Status) | Out-Null

    $Window.Content = $Grid

    # Optimize fonksiyonu
    function Optimize-System {
        try {
            $Status.Text = "Optimize ediliyor... Lütfen bekleyin."

            # 1. Güç Planını Yüksek Performansa Çevir
            powercfg /setactive SCHEME_MIN

            # 2. Windows Oyun Modunu Aktif Et
            reg add "HKCU\Software\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 1 /f | Out-Null

            # 3. Oyun DVR ve Game Bar kapat (bazı sistemlerde lag yapabilir)
            reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f | Out-Null
            reg add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehavior /t REG_DWORD /d 0 /f | Out-Null
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f | Out-Null
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v GameDVR_Enabled /t REG_DWORD /d 0 /f | Out-Null

            # 4. Arka Plan Uygulamalarını Kapat (gerekirse)
            Get-Process | Where-Object { $_.MainWindowTitle -eq '' -and $_.Responding } | Stop-Process -ErrorAction SilentlyContinue

            # 5. Zamanlayıcı ve önbellek optimizasyonları (DPC latency, timer resolution)
            # Burada sadece örnek, gelişmiş araç önerilir

            # 6. Sanal Belleği Otomatik Ayarla
            $sysPageFile = Get-WmiObject Win32_PageFileSetting
            if ($sysPageFile) {
                $sysPageFile.InitialSize = 0
                $sysPageFile.MaximumSize = 0
                $sysPageFile.Put() | Out-Null
            }

            # 7. Önemsiz görsel efektleri kapat (Performans Modu)
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f | Out-Null

            # 8. Ağ için TCP optimizasyonu (basit)
            netsh int tcp set global autotuninglevel=normal | Out-Null
            netsh int tcp set global chimney=enabled | Out-Null
            netsh int tcp set global rss=enabled | Out-Null

            Start-Sleep -Seconds 2
            $Status.Text = "Optimizasyon tamamlandı! FPS artışı ve düşük lag bekleniyor."
        } catch {
            $Status.Text = "Bir hata oluştu: $_"
        }
    }

    # Geri alma fonksiyonu (eklemek istersen buraya)
    function Undo-Optimize {
        try {
            $Status.Text = "Geri alınıyor... Lütfen bekleyin."

            # Güç Planını varsayılan yap (dengeli)
            powercfg /setactive SCHEME_BALANCED

            # Oyun modunu kapat
            reg add "HKCU\Software\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 0 /f | Out-Null

            # Oyun DVR ve Game Bar aç
            reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 1 /f | Out-Null
            reg add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehavior /t REG_DWORD /d 1 /f | Out-Null
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 1 /f | Out-Null
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v GameDVR_Enabled /t REG_DWORD /d 1 /f | Out-Null

            # Görsel efektleri eski haline getir
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 1 /f | Out-Null

            # TCP ayarlarını varsayılan yap
            netsh int tcp set global autotuninglevel=normal | Out-Null
            netsh int tcp set global chimney=default | Out-Null
            netsh int tcp set global rss=enabled | Out-Null

            $Status.Text = "Ayarlar geri alındı."
        } catch {
            $Status.Text = "Geri alma sırasında hata: $_"
        }
    }

    # Optimize ve Undo için butonlar
    $UndoButton = New-Object System.Windows.Controls.Button
    $UndoButton.Content = "Geri Al"
    $UndoButton.Width = 200
    $UndoButton.Height = 60
    $UndoButton.FontSize = 18
    $UndoButton.Foreground = [System.Windows.Media.Brushes]::White
    $UndoButton.Background = [System.Windows.Media.Brushes]::DarkRed
    $UndoButton.HorizontalAlignment = 'Center'
    $UndoButton.Margin = [System.Windows.Thickness]::new(0,10,0,0)
    [System.Windows.Controls.Grid]::SetRow($UndoButton, 2)
    $Grid.Children.Add($UndoButton) | Out-Null

    # Buton eventleri
    $StartButton.Add_Click({ Optimize-System })
    $UndoButton.Add_Click({ Undo-Optimize })

    $Window.Content = $Grid
    $Window.ShowDialog() | Out-Null
}

# Script çalıştırma
Show-UI
