Add-Type -AssemblyName PresentationFramework

$XAML = @"
<Window xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'
        xmlns:x='http://schemas.microsoft.com/winfx/2006/xaml'
        Title='CRTY GameLoop Optimizer' Height='400' Width='600' Background='#111'>
    <Grid>
        <TextBlock x:Name='TitleText' Text='CRTY TOOL' FontSize='36' FontWeight='Bold' 
                   HorizontalAlignment='Center' VerticalAlignment='Top' Margin='0,30,0,0' Foreground='White' />
        <Button x:Name='StartButton' Content='OYUNU BAŞLAT 🚀' Width='220' Height='60' 
                HorizontalAlignment='Center' VerticalAlignment='Center' Background='#222' 
                Foreground='White' FontSize='20' Cursor='Hand' />
        <TextBlock x:Name='StatusText' Text='Hazır...' HorizontalAlignment='Center' 
                   VerticalAlignment='Bottom' Margin='0,0,0,20' Foreground='Lime' FontSize='14'/>
    </Grid>
</Window>
"@

$xmlReader = [System.Xml.XmlReader]::Create([System.IO.StringReader]$XAML)
$Window = [Windows.Markup.XamlReader]::Load($xmlReader)

$StartButton = $Window.FindName('StartButton')
$StatusText = $Window.FindName('StatusText')
$TitleText = $Window.FindName('TitleText')

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
    $StatusText.Text = "Sistem optimize ediliyor..."
    try {
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -Command `"powercfg /setactive SCHEME_MIN; bcdedit /set useplatformtick yes; bcdedit /set disabledynamictick yes; bcdedit /set tscsyncpolicy Enhanced; reg add HKCU\System\GameConfigStore /v GameDVR_Enabled /t REG_DWORD /d 0 /f; reg add HKCU\System\GameConfigStore /v GameDVR_FSEBehavior /t REG_DWORD /d 0 /f; reg add HKCU\Software\Microsoft\GameBar /v AllowAutoGameMode /t REG_DWORD /d 0 /f;`""
    } catch {
        $StatusText.Text = "Optimize sırasında hata oluştu: $_"
        $StartButton.IsEnabled = $true
        return
    }

    Start-Sleep -Seconds 1

    $StatusText.Text = "GameLoop başlatılıyor..."
    try {
        Start-Process -FilePath $emuPath -ArgumentList '-cmd StartApk -param -startpkg "com.tencent.ig" -engine "aow" -vm "100" -fps "120" -resolution "1280x960" -from "Custom"' -Priority High
        $StatusText.Text = "Oyun başlatıldı ✔️"
    } catch {
        $StatusText.Text = "Oyun başlatılamadı: $_"
    }
    $StartButton.IsEnabled = $true
})

$Window.ShowDialog() | Out-Null
