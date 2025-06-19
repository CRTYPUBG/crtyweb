Add-Type -AssemblyName PresentationFramework

$Window = New-Object System.Windows.Window
$Window.Title = "CRTY TOOL"
$Window.Width = 400
$Window.Height = 250
$Window.WindowStartupLocation = "CenterScreen"
$Window.ResizeMode = "NoResize"
$Window.Background = [System.Windows.Media.Brushes]::WhiteSmoke

$Grid = New-Object System.Windows.Controls.Grid
$Grid.Margin = [System.Windows.Thickness]::new(15)

# RowDefinitions oluştururken Height'i ayrı ayarlıyoruz
$row1 = New-Object System.Windows.Controls.RowDefinition
$row1.Height = [System.Windows.GridLength]::Auto
$Grid.RowDefinitions.Add($row1)

$row2 = New-Object System.Windows.Controls.RowDefinition
$row2.Height = New-Object System.Windows.GridLength(55)
$Grid.RowDefinitions.Add($row2)

$row3 = New-Object System.Windows.Controls.RowDefinition
$row3.Height = [System.Windows.GridLength]::Star
$Grid.RowDefinitions.Add($row3)

# Başlık TextBlock
$Title = New-Object System.Windows.Controls.TextBlock
$Title.Text = @"
 _______  _______ _________         
(  ____ \(  ____ )\__   __/|\     /|
| (    \/| (    )|   ) (   ( \   / )
| |      | (____)|   | |    \ (_) / 
| |      |     __)   | |     \   /  
| |      | (\ (      | |      ) (   
| (____/\| ) \ \__   | |      | |   
(_______/|/   \__/   )_(      \_/  

CRTY TOOL
"@  # Çok satırlı string

$Title.FontSize = 14
$Title.FontFamily = 'Consolas' # Monospace font
$Title.Foreground = [System.Windows.Media.Brushes]::DarkSlateGray
$Title.TextAlignment = 'Center'
$Title.HorizontalAlignment = 'Center'
$Title.VerticalAlignment = 'Center'
[System.Windows.Controls.Grid]::SetRow($Title, 0)
$Grid.Children.Add($Title) | Out-Null

# Başlat Butonu
$StartButton = New-Object System.Windows.Controls.Button
$StartButton.Content = "Başlat"
$StartButton.Width = 200
$StartButton.Height = 50
$StartButton.FontSize = 16
$StartButton.Foreground = [System.Windows.Media.Brushes]::White
$StartButton.Background = [System.Windows.Media.Brushes]::DarkGreen
$StartButton.BorderBrush = [System.Windows.Media.Brushes]::ForestGreen
$StartButton.Cursor = [System.Windows.Input.Cursors]::Hand
$StartButton.HorizontalAlignment = 'Center'
$StartButton.Margin = [System.Windows.Thickness]::new(0,10,0,10)
[System.Windows.Controls.Grid]::SetRow($StartButton, 1)
$Grid.Children.Add($StartButton) | Out-Null

# Durum TextBlock
$Status = New-Object System.Windows.Controls.TextBlock
$Status.Text = "Durum: Bekleniyor..."
$Status.FontSize = 14
$Status.Foreground = [System.Windows.Media.Brushes]::Black
$Status.TextAlignment = 'Center'
$Status.HorizontalAlignment = 'Center'
$Status.VerticalAlignment = 'Center'
$Status.TextWrapping = 'Wrap'
[System.Windows.Controls.Grid]::SetRow($Status, 2)
$Grid.Children.Add($Status) | Out-Null

$Window.Content = $Grid

# Butona tıklanınca çalışacak fonksiyon
$StartButton.Add_Click({
    $Status.Text = "Çalışıyor... Lütfen bekleyin."
    Start-Sleep -Seconds 1
    $Status.Text = "Optimize Edildi! İyi oyunlar :)"
})

$Window.ShowDialog() | Out-Null
