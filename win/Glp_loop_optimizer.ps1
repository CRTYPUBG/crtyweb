Add-Type -AssemblyName PresentationFramework

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

            <TextBlock Text='Anti Lag &amp; FPS Artırma Ayarları:' Foreground='White' FontSize='16' Margin='0,0,0,5' />
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

$StartButton = $Window.FindName('StartButton')
$StatusText = $Window.FindName('StatusText')
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

# Renkli başlık efekti
$colors = @("Red","Orange","Yellow","Green","Cyan","Blue","Purple")
$i = 0
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromMilliseconds(150)
$timer.Add_Tick({
    $TitleText.Foreground = [System.Windows.Media.Brushes]::$( $colors[$i] )
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

$global:validKey = $false
$expectedKey = "Crty-key-1246523564"

$BtnCheckKey.Add_Click({
    if ($KeyBox.Text.Trim() -eq $expectedKey) {
        $KeyStatusText.Text = "Lisans doğrulandı! 🎉"
        $KeyStatusText.Foreground = [System.Windows.Media.Brushes]::Lime
        $StartButton.IsEnabled = $true
        $global:validKey = $true
    } else {
        $KeyStatusText.Text = "Geçersiz lisans anahtarı!"
        $KeyStatusText.Foreground = [System.Windows.Media.Brushes]::Red
        $StartButton.IsEnabled = $false
        $global:validKey = $false
    }
})

$StartButton.Add_Click({
    if (-not $global:validKey) {
        $StatusText.Text = "Lütfen önce lisans anahtarını doğrulayın!"
        return
    }
    $StatusText.Text = "GameLoop yolu aranıyor..."
    $emuPath = Find-EmulatorPath
    if (-not $emuPath) {
        $StatusText.Text = "Yol bulunamadı, lütfen dosya seçin."
        $emuPath = Ask-UserForPath
        if (-not $emuPath) {
            $StatusText.Text = "İşlem iptal edildi."
            return
        }
    }

    $StatusText.Text = "Sistem optimize ediliyor..."

    # Ayarları uygula
    if ($ChkDisableGameDVR.IsChecked) {
        reg add HKCU\System\GameConfigStore /v GameDVR_Enabled /t REG_DWORD /d 0 /f | Out-Null
        reg add HKCU\System\GameConfigStore /v GameDVR_FSEBehavior /t REG_DWORD /d 0 /f | Out-Null
    }
    if ($ChkDisableGameBar.IsChecked) {
        reg add HKCU\Software\Microsoft\GameBar /v AllowAutoGameMode /t REG_DWORD /d 0 /f | Out-Null
    }
    if ($ChkOptimizeTimer.IsChecked) {
        bcdedit /set useplatformtick yes | Out-Null
        bcdedit /set disabledynamictick yes | Out-Null
        bcdedit /set tscsyncpolicy Enhanced | Out-Null
    }
    if ($ChkDisableDynamicTick.IsChecked) {
        bcdedit /set disabledynamictick yes | Out-Null
    }

    $fps = ($FpsComboBox.SelectedItem).Content
    $StatusText.Text = "GameLoop başlatılıyor... FPS: $fps"

    $arguments = "-cmd StartApk -param -startpkg `"com.tencent.ig`" -engine `"aow`" -vm `"100`" -fps `"$fps`" -resolution `"1280x960`" -from `"Custom`""

    $priority = if ($ChkHighPriority.IsChecked) { "High" } else { "Normal" }

    Start-Process -FilePath $emuPath -ArgumentList $arguments -Priority $priority

    $StatusText.Text = "Oyun başlatıldı ✔️"
})

$Window.ShowDialog() | Out-Null
