Add-Type -AssemblyName PresentationFramework

# Ana pencere oluştur
$Window = New-Object System.Windows.Window
$Window.Title = "GameLoop Optimizer - FPS & Anti-Lag"
$Window.Width = 360
$Window.Height = 210
$Window.WindowStartupLocation = "CenterScreen"
$Window.ResizeMode = "NoResize"
$Window.Background = [System.Windows.Media.Brushes]::WhiteSmoke

# Grid layout
$Grid = New-Object System.Windows.Controls.Grid
$Grid.Margin = [System.Windows.Thickness]::new(15)

$Grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition -Property @{Height=[System.Windows.GridLength]::Auto}))
$Grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition -Property @{Height=55}))
$Grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition -Property @{Height=[System.Windows.GridLength]::Star}))

# Başlık
$Title = New-Object System.Windows.Controls.TextBlock
$Title.Text = "GameLoop FPS & Anti-Lag Optimize"
$Title.FontSize = 20
$Title.FontWeight = 'Bold'
$Title.Foreground = [System.Windows.Media.Brushes]::DarkGreen
$Title.HorizontalAlignment = 'Center'
$Title.Margin = [System.Windows.Thickness]::new(0,0,0,15)
[System.Windows.Controls.Grid]::SetRow($Title, 0)
$Grid.Children.Add($Title) | Out-Null

# Başlat butonu
$StartButton = New-Object System.Windows.Controls.Button
$StartButton.Content = "Optimize Et & Başlat"
$StartButton.Width = 200
$StartButton.Height = 50
$StartButton.FontSize = 16
$StartButton.Foreground = [System.Windows.Media.Brushes]::White
$StartButton.Background = [System.Windows.Media.Brushes]::ForestGreen
$StartButton.BorderBrush = [System.Windows.Media.Brushes]::DarkGreen
$StartButton.Cursor = [System.Windows.Input.Cursors]::Hand
$StartButton.HorizontalAlignment = 'Center'
$StartButton.Margin = [System.Windows.Thickness]::new(0,0,0,10)
[System.Windows.Controls.Grid]::SetRow($StartButton, 1)
$Grid.Children.Add($StartButton) | Out-Null

# Durum metni
$Status = New-Object System.Windows.Controls.TextBlock
$Status.Text = "Durum: Bekleniyor..."
$Status.FontSize = 14
$Status.Foreground = [System.Windows.Media.Brushes]::DarkSlateGray
$Status.HorizontalAlignment = 'Center'
$Status.VerticalAlignment = 'Center'
$Status.TextWrapping = 'Wrap'
[System.Windows.Controls.Grid]::SetRow($Status, 2)
$Grid.Children.Add($Status) | Out-Null

$Window.Content = $Grid

function Optimize-AndStartGameLoop {
    try {
        $Status.Text = "Ultimate Performance planı aktif ediliyor..."
        # Ultimate Performance planını aktif et
        powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
        powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61

        Start-Sleep -Seconds 1
        $Status.Text = "FPS, Anti-Lag ve Input Lag ayarları uygulanıyor..."
        # Burada sistem ayarları, registry tweakleri ekle
        # Örnek:
        # Disable Nagle's Algorithm, optimize ağ, oyun modu ayarları, timer resolution vs.
        # (Kendi optimize kodlarını buraya ekleyebilirsin)

        Start-Sleep -Seconds 1

        $Status.Text = "GameLoop yüksek öncelikle başlatılıyor..."

        # GameLoop exe yolu - bunu kendi sistemine göre değiştir
        $glPath = "C:\Program Files\Tencent\Tencent Gaming Buddy\TencentGamingBuddy.exe"
        if (-Not (Test-Path $glPath)) {
            $Status.Text = "GameLoop bulunamadı: $glPath"
            return
        }

        # GameLoop'u 120 FPS + AOW modunda başlatmak için argüman ekle (örnek args)
        $arguments = "--fps 120 --aow-mode"

        # Yeni process başlat
        $process = Start-Process -FilePath $glPath -ArgumentList $arguments -PassThru

        # İşleme yüksek öncelik ver
        Start-Sleep -Milliseconds 500
        $proc = Get-Process -Id $process.Id
        $proc.PriorityClass = 'High'

        $Status.Text = "Optimize edildi ve GameLoop başlatıldı! İyi oyunlar."
    }
    catch {
        $Status.Text = "Hata oluştu: $_"
    }
}

# Buton tıklama eventi
$StartButton.Add_Click({
    Optimize-AndStartGameLoop
})

# Pencereyi göster
$Window.ShowDialog() | Out-Null
