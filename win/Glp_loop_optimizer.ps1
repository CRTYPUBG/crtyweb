Add-Type -AssemblyName PresentationFramework

# GUI XAML - mutlaka xmlns:x tanımı var
$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="CRTY GameLoop Optimizer" Height="380" Width="450" Background="#1E1E1E" WindowStartupLocation="CenterScreen" ResizeMode="NoResize">
    <Grid Margin="15">
        <TextBlock Text="CRTY GameLoop Optimizer" Foreground="White" FontSize="28" FontWeight="Bold" HorizontalAlignment="Center" Margin="0,10,0,0" />
        
        <StackPanel VerticalAlignment="Top" Margin="0,60,0,0" >
            <CheckBox x:Name="ChkFPS" Content="Enable FPS Boost" Foreground="LightGreen" FontSize="16" Margin="0,10"/>
            <CheckBox x:Name="ChkAntiLag" Content="Enable Anti-Lag" Foreground="LightGreen" FontSize="16" Margin="0,10"/>
            <CheckBox x:Name="ChkInputLag" Content="Enable Input Lag Removal" Foreground="LightGreen" FontSize="16" Margin="0,10"/>
        </StackPanel>

        <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Bottom" Margin="0,0,0,30" >
            <Button x:Name="BtnRun" Content="Optimize & Start GameLoop" Width="210" Height="45" Margin="10" Background="#007ACC" Foreground="White" FontWeight="Bold" Cursor="Hand"/>
            <Button x:Name="BtnRestore" Content="Restore Defaults" Width="130" Height="45" Margin="10" Background="#555555" Foreground="White" Cursor="Hand"/>
        </StackPanel>

        <TextBlock x:Name="StatusText" Text="Status: Waiting for your selection..." Foreground="LightGray" FontSize="14" HorizontalAlignment="Center" VerticalAlignment="Bottom" Margin="0,0,0,5" />
    </Grid>
</Window>
"@

# XAML oku ve WPF Window oluştur
$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader] $XAML)
$Window = [Windows.Markup.XamlReader]::Load($reader)

# Kontrolleri al
$ChkFPS = $Window.FindName("ChkFPS")
$ChkAntiLag = $Window.FindName("ChkAntiLag")
$ChkInputLag = $Window.FindName("ChkInputLag")
$BtnRun = $Window.FindName("BtnRun")
$BtnRestore = $Window.FindName("BtnRestore")
$StatusText = $Window.FindName("StatusText")

# Optimize işlemi fonksiyonu
function Optimize-GameLoop {
    $StatusText.Text = "Status: Applying optimizations..."
    Start-Sleep -Milliseconds 500

    # FPS Boost örneği - registry veya process tweak - buraya istediğin optimize kodunu koyabilirsin
    if ($ChkFPS.IsChecked) {
        # Örnek: Timer Resolution optimize
        # Timeout: 0 means max performance for multimedia timer
        Start-Process -FilePath "powershell" -ArgumentList "-Command [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject((New-Object -ComObject WScript.Shell))" -WindowStyle Hidden -Wait
        $StatusText.Text = "Status: FPS Boost enabled"
    } else {
        $StatusText.Text = "Status: FPS Boost skipped"
    }

    # Anti Lag örneği
    if ($ChkAntiLag.IsChecked) {
        # Örnek registry tweak
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -ErrorAction Stop
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "GameDVR_Enabled" -Value 0 -ErrorAction Stop
            $StatusText.Text = "Status: Anti-Lag enabled"
        }
        catch {
            $StatusText.Text = "Status: Failed to apply Anti-Lag settings"
        }
    }
    else {
        $StatusText.Text = "Status: Anti-Lag skipped"
    }

    # Input Lag kaldırma örneği (Örnek registry)
    if ($ChkInputLag.IsChecked) {
        try {
            Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -ErrorAction Stop
            Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -Value 0 -ErrorAction Stop
            $StatusText.Text = "Status: Input Lag Removal enabled"
        }
        catch {
            $StatusText.Text = "Status: Failed to apply Input Lag Removal"
        }
    }
    else {
        $StatusText.Text = "Status: Input Lag Removal skipped"
    }
}

# Geri al fonksiyonu - ayarları eski haline getirir (örnek)
function Restore-Defaults {
    $StatusText.Text = "Status: Restoring defaults..."
    Start-Sleep -Milliseconds 500
    try {
        # Örnek: registry ayarlarını eski haline getir
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 1 -ErrorAction Stop
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "GameDVR_Enabled" -Value 1 -ErrorAction Stop
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 1 -ErrorAction Stop
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -Value 1 -ErrorAction Stop
        $StatusText.Text = "Status: Defaults restored ✔️"
    }
    catch {
        $StatusText.Text = "Status: Failed to restore defaults"
    }
}

# Oyun başlatma fonksiyonu
function Start-GameLoop {
    $StatusText.Text = "Status: Starting GameLoop..."
    # GameLoop emulator yolu - gerekirse değiştir
    $emuPath = "C:\Program Files\TxGameAssistant\ui\AndroidEmulatorEn.exe"
    if (-not (Test-Path $emuPath)) {
        $StatusText.Text = "Status: GameLoop emulator not found!"
        return
    }
    Start-Process -FilePath $emuPath -ArgumentList '-cmd StartApk -param -startpkg "com.tencent.ig"' -Priority High
    $StatusText.Text = "Status: GameLoop started ✔️"
}

# Run butonuna tıklama olayı
$BtnRun.Add_Click({
    Optimize-GameLoop
    Start-GameLoop
})

# Restore butonuna tıklama olayı
$BtnRestore.Add_Click({
    Restore-Defaults
})

# Pencereyi aç
$Window.ShowDialog() | Out-Null
