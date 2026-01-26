Add-Type -AssemblyName PresentationFramework
$w = New-Object Windows.Window
$w.WindowStyle = 'None'
$w.WindowState = 'Maximized'
$w.Topmost = $true
$w.Background = '#0078D7'

$t = New-Object Windows.Controls.TextBlock
$t.Foreground = 'White'
$t.FontSize = 28
$t.Margin = '60'
$t.TextWrapping = 'Wrap'
$t.Text = ":(`n`nYour PC ran into a problem and needs to restart.`nWe're just collecting some error info, and then we'll restart for you.`n`n0% complete`n`nStop code: CRITICAL_PROCESS_DIED"

$w.Content = $t
$w.ShowDialog()
