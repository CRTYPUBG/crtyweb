Add-Type -AssemblyName PresentationFramework

# Pencere oluştur
$Window = New-Object System.Windows.Window
$Window.Title = "GameLoop Optimizer"
$Window.Width = 320
$Window.Height = 180
$Window.WindowStartupLocation = "CenterScreen"
$Window.ResizeMode = "NoResize"

# Grid oluştur
$Grid = New-Object System.Windows.Controls.Grid
$Grid.Margin = [System.Windows.Thickness]::new(10)

# Satır tanımları
$rowDef1 = New-Object System.Windows.Controls.RowDefinition
$rowDef1.Height = [System.Windows.GridLength]::new([System.Windows.GridUnitType]::Auto)
$rowDef2 = New-Object System.Windows.Controls.RowDefinition
$rowDef2.Height = [System.Windows.GridLength]::new(50)
$rowDef3 = New-Object System.Windows.Controls.RowDefinition
$rowDef3.Height = [System.Windows.GridLength]::new([System.Windows.GridUnitType]::Star)

$Grid.RowDefinitions.Add($rowDef1)
$Grid.RowDefinitions.Add($rowDef2)
$Grid.RowDefinitions.Add($rowDef3)

# Başlık TextBlock
$TitleText = New-Object System.Windows.Controls.TextBlock
$TitleText.Text = "GameLoop Optimizer"
$TitleText.FontSize = 18
$TitleText.FontWeight = 'Bold'
$TitleText.HorizontalAlignment = 'Center'
$TitleText.Margin = [System.Windows.Thickness]::new(0,0,0,10)
[System.Windows.Controls.Grid]::SetRow($TitleText, 0)
$Grid.Children.Add($TitleText) | Out-Null

# Başlat Butonu
$StartButton = New-Object System.Windows.Controls.Button
$StartButton.Content = "Optimize Başlat"
$StartButton.Width = 150
$StartButton.Height = 35
$StartButton.HorizontalAlignment = 'Center'
[System.Windows.Controls.Grid]::SetRow($StartButton, 1)
$Grid.Children.Add($StartButton) | Out-Null

# Durum TextBlock
$StatusText = New-Object System.Windows.Controls.TextBlock
$StatusText.Text = "Durum: Bekleniyor..."
$StatusText.FontSize = 14
$StatusText.HorizontalAlignment = 'Center'
$StatusText.VerticalAlignment = 'Center'
$StatusText.TextWrapping = 'Wrap'
[System.Windows.Controls.Grid]::SetRow($StatusText, 2)
$Grid.Children.Add($StatusText) | Out-Null

# Grid'i pencereye ekle
$Window.Content = $Grid

# Optimize fonksiyonu
function Optimize-GameLoop {
    $StatusText.Text = "Optimizasyon başladı..."
    Start-Sleep -Seconds 1

    # Buraya optimizasyon kodlarını ekle

    $StatusText.Text = "Optimizasyon tamamlandı! FPS artışı deneyin."
}

# Buton click eventi ekle
$StartButton.Add_Click({
    Optimize-GameLoop
})

# Pencereyi göster
$Window.ShowDialog() | Out-Null
