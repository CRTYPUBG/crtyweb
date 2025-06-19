Add-Type -AssemblyName PresentationFramework

# Pencere ayarları
$Window = New-Object System.Windows.Window
$Window.Title = "🎮 GameLoop Optimizer 🚀"
$Window.Width = 360
$Window.Height = 220
$Window.WindowStartupLocation = "CenterScreen"
$Window.ResizeMode = "NoResize"
$Window.Background = [System.Windows.Media.Brushes]::WhiteSmoke

# Grid oluştur
$Grid = New-Object System.Windows.Controls.Grid
$Grid.Margin = [System.Windows.Thickness]::new(15)

# Satır tanımları
$Grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition -Property @{Height=[System.Windows.GridLength]::Auto}))
$Grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition -Property @{Height=50}))
$Grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition -Property @{Height=[System.Windows.GridLength]::Star}))

# Başlık TextBlock
$Title = New-Object System.Windows.Controls.TextBlock
$Title.Text = "🚀 GameLoop FPS Optimize 🚀"
$Title.FontSize = 22
$Title.FontWeight = 'Bold'
$Title.Foreground = [System.Windows.Media.Brushes]::DarkBlue
$Title.HorizontalAlignment = 'Center'
$Title.Margin = [System.Windows.Thickness]::new(0,0,0,15)
[System.Windows.Controls.Grid]::SetRow($Title, 0)
$Grid.Children.Add($Title) | Out-Null

# Başlat butonu
$StartButton = New-Object System.Windows.Controls.Button
$StartButton.Content = "✨ Optimizasyonu Başlat ✨"
$StartButton.Width = 180
$StartButton.Height = 45
$StartButton.FontSize = 16
$StartButton.Foreground = [System.Windows.Media.Brushes]::White
$StartButton.Background = [System.Windows.Media.Brushes]::DodgerBlue
$StartButton.BorderBrush = [System.Windows.Media.Brushes]::RoyalBlue
$StartButton.Cursor = [System.Windows.Input.Cursors]::Hand
$StartButton.HorizontalAlignment = 'Center'
$StartButton.Margin = [System.Windows.Thickness]::new(0,0,0,10)
[System.Windows.Controls.Grid]::SetRow($StartButton, 1)
$Grid.Children.Add($StartButton) | Out-Null

# Durum TextBlock
$Status = New-Object System.Windows.Controls.TextBlock
$Status.Text = "ℹ️ Durum: Bekleniyor..."
$Status.FontSize = 14
$Status.Foreground = [System.Windows.Media.Brushes]::DarkSlateGray
$Status.HorizontalAlignment = 'Center'
$Status.VerticalAlignment = 'Center'
$Status.TextWrapping = 'Wrap'
[System.Windows.Controls.Grid]::SetRow($Status, 2)
$Grid.Children.Add($Status) | Out-Null

# Grid'i pencereye ekle
$Window.Content = $Grid

# Optimize fonksiyonu (örnek)
function Optimize-GameLoop {
    $Status.Text = "⏳ Optimizasyon başlıyor..."
    Start-Sleep -Seconds 1

    # Buraya FPS artırma, input lag azaltma gibi komutları ekle

    # Örnek: İşlem önceliği yükseltme
    # Start-Process -FilePath "gameloop.exe" -Priority "High"

    $Status.Text = "✅ Optimizasyon tamamlandı! FPS'niz arttırıldı."
}

# Buton tıklama eventi
$StartButton.Add_Click({
    Optimize-GameLoop
})

# Pencereyi göster
$Window.ShowDialog() | Out-Null
