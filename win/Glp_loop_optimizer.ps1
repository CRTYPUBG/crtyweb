Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase,System.Net.Http

$XAML = @"
<Window xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
        xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'
        Title='CRTY GameLoop Optimizer v2' Height='480' Width='700' Background='#121212' WindowStartupLocation='CenterScreen'>
    <Grid Margin='20'>
        <Grid.RowDefinitions>
            <RowDefinition Height='Auto'/>
            <RowDefinition Height='*'/>
            <RowDefinition Height='Auto'/>
        </Grid.RowDefinitions>

        <TextBlock x:Name='TitleText' Text='CRTY TOOL v2' FontSize='40' FontWeight='Bold' 
                   HorizontalAlignment='Center' VerticalAlignment='Top' Foreground='White' />

        <StackPanel Grid.Row='1' Margin='0,30,0,0' VerticalAlignment='Top'>

            <StackPanel Orientation='Horizontal' Margin='0,0,0,10'>
                <TextBlock Text='FPS Ayarı:' Foreground='White' FontSize='16' Width='100' VerticalAlignment='Center'/>
                <ComboBox x:Name='FpsComboBox' Width='150' FontSize='16'>
                    <ComboBoxItem Content='30' />
                    <ComboBoxItem Content='60' IsSelected='True'/>
                    <ComboBoxItem Content='90' />
                    <ComboBoxItem Content='120' />
                </ComboBox>
            </StackPanel>

            <TextBlock Text='Anti Lag & FPS Artırma Ayarları:' Foreground='White' FontSize='16' Margin='0,0,0,5' />
            <StackPanel Margin='20,0,0,20'>
                <CheckBox x:Name='ChkDisableGameDVR' Content='Game DVR kapat' Foreground='White' FontSize='14' Margin='0,5'/>
                <CheckBox x:Name='ChkDisableGameBar' Content='Game Bar kapat' Foreground='White' FontSize='14' Margin='0,5'/>
                <CheckBox x:Name='ChkOptimizeTimer' Content='Zamanlayıcı optimizasyonu (useplatformtick vs)' Foreground='White' FontSize='14' Margin='0,5'/>
                <CheckBox x:Name='ChkHighPriority' Content='Emülatör işlemini yüksek öncelikle çalıştır' Foreground='White' FontSize='14' Margin='0,5'/>
                <CheckBox x:Name='ChkDisableDynamicTick' Content='Dynamic Tick devre dışı bırak' Foreground='White' FontSize='14' Margin='0,5'/>
            </StackPanel>

            <StackPanel Orientation='Horizontal' Margin='0,0,0,10' VerticalAlignment='Center'>
                <TextBlock Text='Lisans Anahtarı:' Foreground='White' FontSize='16' Width='120' VerticalAlignment='Center'/>
                <TextBox x:Name='KeyBox' Width='250' FontSize='16' />
                <Button x:Name='BtnCheckKey' Content='Doğrula' Width='100' Margin='10,0,0,0' FontSize='16' />
            </StackPanel>

            <TextBlock x:Name='KeyStatusText' Text='Lütfen lisans anahtarını doğrula.' Foreground='Orange' FontSize='14' Margin='0,0,0,20'/>

            <Button x:Name='StartButton' Content='OYUNU BAŞLAT 🚀' Width='240' Height='70' 
                HorizontalAlignment='Center' Background='#1E90FF' Foreground='White' FontSize='22' Cursor='Hand' IsEnabled='False'/>
        </StackPanel>

        <TextBlock x:Name='StatusText' Grid.Row='2' Text='Bekleniyor...' Foreground='Lime' FontSize='14' HorizontalAlignment='Center' Margin='0,20,0,0'/>

    </Grid>
</Window>
"@

$xmlReader = [System.Xml.XmlReader]::Create([System.IO.StringReader]$XAML)
$Window = [Windows.Markup.XamlReader]::Load($xmlReader)

$TitleText = $Window.FindName('TitleText')
$FpsComboBox = $Window.FindName('FpsComboBox')
$ChkDisableGameDVR = $Window.FindName('ChkDisableGameDVR')
$ChkDisableGameBar = $Window.FindName('ChkDisableGameBar')
$ChkOptimizeTimer = $Window.FindName('ChkOptimizeTimer')
$ChkHighPriority = $Window.FindName('ChkHighPriority')
$ChkDisableDynamicTick = $Window.FindName('ChkDisableDynamicTick')
$KeyBox = $Window.FindName('KeyBox')
$BtnCheckKey = $Window.FindName('BtnCheckKey')
$KeyStatusText = $Window.FindName('KeyStatusText')
$StartButton = $Window.FindName('StartButton')
$StatusText = $Window.FindName('StatusText')

# Renkli animasyon
$colors = @("Red","Orange","Yellow","Green","Cyan","Blue","Purple")
$i = 0
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromMilliseconds(150)
$timer.Add_Tick({
    $colorName = $colors[$i]
    $brush = [System.Windows.Media.Brushes]::$colorName
    $TitleText.Foreground = $brush
    $i = ($i + 1) % $colors.Length
})
$timer.Start()

function Find-EmulatorPath {
    $paths = @(
        "C:\Program Files\TxGameAssistant\ui\AndroidEmulatorEn.exe",
        "C:\Program Files (x86)\TxGameAssistant\ui\AndroidEmulatorEn.exe"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

function Ask-UserForPath {
    Add-Type -AssemblyName System.Windows.Forms
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Filter = "Emulator Executable|AndroidEmulatorEn.exe"
    $ofd.Title = "GameLoop Emulator Dosyasını Seçin"
    if ($ofd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $ofd.FileName
    } else {
        return $null
    }
}

function Validate-Key($key) {
    # Burada https://crtypubg.github.io/crtyweb/ sitesine request yapılabilir.
    # Şimdilik sabit key kontrolü:
    return $key -eq "Crty-key-1246523564"
}

# Lisans doğrulama butonu
$BtnCheckKey.Add_Click({
    $enteredKey = $KeyBox.Text.Trim()
    $KeyStatusText.Foreground = [System.Windows.Media.Brushes]::Orange
    $KeyStatusText.Text = "Doğrulanıyor..."
    Start-Sleep -Milliseconds 500

    if (Validate-Key $enteredKey) {
        $KeyStatusText.Foreground = [System.Windows.Media.Brushes]::LimeGreen
        $KeyStatusText.Text = "Lisans doğrulandı! Artık oyunu başlatabilirsiniz."
        $StartButton.IsEnabled = $true
    } else {
        $KeyStatusText.Foreground = [System.Windows.Media.Brushes]::Red
        $KeyStatusText.Text = "Lisans doğrulaması başarısız! Geçerli bir anahtar girin."
        $StartButton.IsEnabled = $false
    }
})

$StartButton.Add_Click({
    $StartButton.IsEnabled = $false
    $StatusText.Text = "GameLoop yolu aranıyor..."
    $emuPath = Find-EmulatorPath
    if (-not $emuPath) {
        $StatusText.Text = "Yol bulunamadı, lütfen dosya seçin."
        $emuPath = Ask-UserForPath
        if (-not $emuPath) {
            $StatusText.Text = "İşlem iptal edildi."
            $StartButton.IsEnabled = $true
            return
        }
    }

    $StatusText.Text = "Seçilen ayarlar uygulanıyor..."

    $fps = $FpsComboBox.SelectedItem.Content
    $argsList = @()
    if ($ChkDisableGameDVR.IsChecked) {
        $argsList += "reg add HKCU\System\GameConfigStore /v GameDVR_Enabled /t REG_DWORD /d 0 /f"
    }
    if ($ChkDisableGameBar.IsChecked) {
        $argsList += "reg add HKCU\Software\Microsoft\GameBar /v AllowAutoGameMode /t REG_DWORD /d 0 /f"
    }
    if ($ChkOptimizeTimer.IsChecked) {
        $argsList += "bcdedit /set useplatformtick yes"
        $argsList += "bcdedit /set disabledynamictick yes"
        $argsList += "bcdedit /set tscsyncpolicy Enhanced"
    }
    if ($ChkDisableDynamicTick.IsChecked) {
        $argsList += "bcdedit /set disabledynamictick yes"
    }

    $regCommands = $argsList -join "; "

    # Yönetici yetkisi ile optimize komutları çalıştırılıyor
    try {
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -Command `"$regCommands`""
    } catch {
        $StatusText.Text = "Optimize sırasında hata oluştu: $_"
        $StartButton.IsEnabled = $true
        return
    }

    Start-Sleep -Seconds 2

    $StatusText.Text = "GameLoop başlatılıyor..."

    $startArgs = "-cmd StartApk -param -startpkg `"com.tencent.ig`" -engine `"aow`" -vm `"100`" -fps `"$fps`" -resolution `"1280x960`" -from `"Custom`""

    try {
        if ($ChkHighPriority.IsChecked) {
            Start-Process -FilePath $emuPath -ArgumentList $startArgs -Priority High
        } else {
            Start-Process -FilePath $emuPath -ArgumentList $startArgs
        }
        $StatusText.Text = "Oyun başlatıldı ✔️"
    } catch {
        $StatusText.Text = "Oyun başlatılamadı: $_"
    }
    $StartButton.IsEnabled = $true
})

$Window.ShowDialog() | Out-Null
