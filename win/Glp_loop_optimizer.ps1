Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# Yönetici kontrolü
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    [System.Windows.MessageBox]::Show("Lütfen PowerShell'i Yönetici olarak çalıştırınız!", "Yetki Hatası", 'OK', 'Error') | Out-Null
    exit
}

# Window oluştur
$window = New-Object System.Windows.Window
$window.Title = "CRTY GameLoop Optimizer"
$window.Width = 450
$window.Height = 320
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
$titleText.FontSize = 24
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
$statusText.Margin = [System.Windows.Thickness]::new(0,0,0,15)
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
$btnOptimize.Height = 45
$btnOptimize.Margin = [System.Windows.Thickness]::new(0,0,0,15)
$btnOptimize.Background = [System.Windows.Media.Brushes]::DarkGreen
$btnOptimize.Foreground = [System.Windows.Media.Brushes]::White
$btnOptimize.FontWeight = 'SemiBold'
$stackPanel.Children.Add($btnOptimize) | Out-Null

# Geri al butonu
$btnUndo = New-Object System.Windows.Controls.Button
$btnUndo.Content = "Ayarları Geri Al"
$btnUndo.Width = 300
$btnUndo.Height = 45
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
$copyrightText.Margin = [System.Windows.Thickness]::new(0,20,0,0)
[System.Windows.Controls.Grid]::SetRow($copyrightText,3)
$grid.Children.Add($copyrightText) | Out-Null

# Optimize fonksiyonu
function Set-RegistryValueSafe {
    param(
        [string]$Path,
        [string]$Name,
        [int]$Value
    )
    try {
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type DWord -ErrorAction Stop
        return $true
    }
    catch {
        Write-Host "Registry ayarı yapılamadı: $Path $Name"
        return $false
    }
}

function Optimize-GameLoop {
    $statusText.Text = "Durum: Optimizasyon başladı..."

    # Game DVR kapatma
    Set-RegistryValueSafe -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0
    Set-RegistryValueSafe -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -Value 0

    # Policies altında GameDVR ayarları
    Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0
    Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowBroadcastRecording" -Value 0

    # Diğer optimizasyonlar...

    $statusText.Text = "Durum: Optimizasyon tamamlandı! 🎮"
}

function Undo-Optimization {
    $statusText.Text = "Durum: Ayarlar geri alınıyor..."

    Set-RegistryValueSafe -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 1
    Set-RegistryValueSafe -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -Value 1

    Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 1
    Set-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowBroadcastRecording" -Value 1

    # Diğer geri alma işlemleri...

    $statusText.Text = "Durum: Ayarlar geri alındı."
}


# Geri alma fonksiyonu
function Undo-Optimization {
    try {
        $statusText.Text = "Durum: Ayarlar geri alınıyor..."

        # Windows Game Bar & DVR aç
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 1 -Type DWord -ErrorAction Stop
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -Value 1 -Type DWord -ErrorAction Stop

        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 1 -Type DWord -ErrorAction Stop
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowBroadcastRecording" -Value 1 -Type DWord -ErrorAction Stop

        # CPU güç modunu varsayılan yap (Dengeli)
        powercfg /setactive SCHEME_BALANCED

        # Superfetch / SysMain servisini başlat ve otomatik yap
        Set-Service -Name "SysMain" -StartupType Automatic
        Start-Service -Name "SysMain" -ErrorAction SilentlyContinue

        # TCP autotuning tekrar etkinleştir
        netsh int tcp set global autotuninglevel=normal | Out-Null

        $statusText.Text = "Durum: Ayarlar geri alındı."
    }
    catch {
        $statusText.Text = "Hata: $($_.Exception.Message)"
    }
}

# Buton eventleri
$btnOptimize.Add_Click({ Optimize-GameLoop })
$btnUndo.Add_Click({ Undo-Optimization })

# Window'a grid ekle ve göster
$window.Content = $grid
$window.ShowDialog() | Out-Null
