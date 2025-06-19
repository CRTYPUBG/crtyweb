Add-Type -AssemblyName PresentationFramework

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="GameLoop Optimizer" Height="180" Width="320"
        WindowStartupLocation="CenterScreen"
        ResizeMode="NoResize">
    <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="50"/>
            <RowDefinition Height="*"/>
        </Grid.RowDefinitions>
        <TextBlock x:Name="TitleText" Text="GameLoop Optimizer" FontSize="18" FontWeight="Bold" HorizontalAlignment="Center" Margin="0,0,0,10"/>
        <Button x:Name="StartButton" Grid.Row="1" Content="Optimize Başlat" Width="150" Height="35" HorizontalAlignment="Center" />
        <TextBlock x:Name="StatusText" Grid.Row="2" Text="Durum: Bekleniyor..." FontSize="14" HorizontalAlignment="Center" VerticalAlignment="Center" TextWrapping="Wrap" />
    </Grid>
</Window>
"@

# Load XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$Window = [Windows.Markup.XamlReader]::Load($reader)

# Find named elements
$StartButton = $Window.FindName('StartButton')
$StatusText = $Window.FindName('StatusText')

# Optimize fonksiyon (örnek)
function Optimize-GameLoop {
    $StatusText.Text = "Optimizasyon başladı..."
    Start-Sleep -Seconds 1

    # Buraya gerçek optimizasyon komutlarını ekle
    # Örneğin;
    # Set-ProcessPriority, registry ayarları, gamebar kapatma vb.

    $StatusText.Text = "Optimizasyon tamamlandı! FPS artışı deneyin."
}

# Buton click eventi
$StartButton.Add_Click({
    Optimize-GameLoop
})

# Show Window
$Window.ShowDialog() | Out-Null
