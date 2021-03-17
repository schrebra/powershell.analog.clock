
Set-StrictMode -Version latest

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

$DegreesToRadians = [Math]::PI/180
$PSicon = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command -Name powershell).Path)

#################################
function Initialize-Clock()
{
# create the form to display the clock
$script:form = New-Object  -TypeName Windows.Forms.Form
$script:form.Icon = $PSicon
$script:form.Text = 'Analogue Clock'
$script:form.Height = 700
$script:form.Width = $form.Height
$script:form.BackColor=[Drawing.Color]::black
$script:form.Location.X = 1000
$script:form.TransparencyKey = [Drawing.Color]::Brown

$script:clockRadius = $form.Height / 2
$script:CentreRadius = $form.Height / 45

$script:lenHrHand = ($form.Height/3/1.75)
$script:lenMinHand = ($form.Height/3/1.1)
$script:lenSecHand = ($form.Height/3/1.1)

#$script:SecondsPen = New-Object  -TypeName Drawing.Pen -ArgumentList ([Drawing.Color]::Red)
$script:MinutesPen = New-Object  -TypeName Drawing.Pen -ArgumentList ([Drawing.Color]::White)
$script:HoursPen =   New-Object  -TypeName Drawing.Pen -ArgumentList ([Drawing.Color]::White)
$script:TicksPen =   New-Object  -TypeName Drawing.Pen -ArgumentList ([Drawing.Color]::White)
$script:FifthPen =   New-Object  -TypeName Drawing.Pen -ArgumentList ([Drawing.Color]::White)

$script:CircleBrush = New-Object  -TypeName Drawing.SolidBrush -ArgumentList ([Drawing.Color]::White)

$script:CentrePoint = New-Object  -TypeName Drawing.PointF
$script:HourPoint =   New-Object  -TypeName Drawing.PointF
$script:MinPoint =    New-Object  -TypeName Drawing.PointF
$script:SecPoint =    New-Object  -TypeName Drawing.PointF

$script:InnerPoint = New-Object  -TypeName Drawing.PointF
$script:OuterPoint = New-Object  -TypeName Drawing.PointF
$script:SpotPoint =  New-Object  -TypeName Drawing.PointF

$script:CentrePoint.X = $form.ClientSize.Width  / 2
$script:CentrePoint.Y = $form.ClientSize.Height / 2

$script:formTimer = New-Object  -TypeName Windows.Forms.Timer
$formTimer.Interval = 1000    # 1 second
}

#################################
$load_AnalogueClock = {
$resize_AnalogueClock
}

#################################
$redraw_AnalogueClock = {
$form.Invalidate()
}

#################################
$resize_AnalogueClock = {
$form.Width = $form.Height
$CentrePoint.X = $form.ClientSize.Width  / 2
$CentrePoint.Y = $form.ClientSize.Height / 2

$clockRadius = $form.Height / 2
$CentreRadius = $form.Height / 45

$lenHrHand = ($form.Height/3/1.75)
$lenMinHand = ($form.Height/3/1.1)
$lenSecHand = ($form.Height/3/1.1)

#$secondsPenWidth = $form.Height/600
$minutesPenWidth = $form.Height/200
$hoursPenWidth = $form.Height/150

#$SecondsPen.Width = $secondsPenWidth
$MinutesPen.Width = $minutesPenWidth
$HoursPen.Width = $hoursPenWidth
#$TicksPen.Width = $secondsPenWidth
#$FifthPen.Width = $secondsPenWidth * 3

$form.refresh()
}

#################################
$paint_AnalogueClock = {
$graphicsObj = $form.createGraphics()
$currentHour   = (Get-Date).Hour % 12
$currentMinute = (Get-Date).Minute
$currentSecond = (Get-Date).Second

# degrees around the circle
$hourDegrees = 30 * ($currentHour+($currentMinute/60))
$minuteDegrees = $currentMinute * 6
$secondDegrees = $currentSecond * 6

# Sin and Cos functions require angles in radians
$hourRadian   = $hourDegrees   * $DegreesToRadians
$minuteRadian = $minuteDegrees * $DegreesToRadians
$secondRadian = $secondDegrees * $DegreesToRadians

# calc the endpoint of each hand
$HourPoint.X = $CentrePoint.X + ($lenHrHand  * [Math]::Sin($hourRadian))
$HourPoint.Y = $CentrePoint.Y - ($lenHrHand  * [Math]::Cos($hourRadian))
$MinPoint.X = $CentrePoint.X + ($lenMinHand * [Math]::Sin($minuteRadian))
$MinPoint.Y = $CentrePoint.Y - ($lenMinHand * [Math]::Cos($minuteRadian))
$SecPoint.X = $CentrePoint.X + ($lenSecHand * [Math]::Sin($secondRadian))
$SecPoint.Y = $CentrePoint.Y - ($lenSecHand * [Math]::Cos($secondRadian))

# now draw the clock hands
# should use FillPolygon for hour and minutes hands?
$graphicsObj.DrawLine($HoursPen,   $CentrePoint, $HourPoint)
$graphicsObj.DrawLine($MinutesPen, $CentrePoint, $MinPoint)
#$graphicsObj.DrawLine($SecondsPen, $CentrePoint, $SecPoint)

# draw the ticks around the outside clock face
for ($ticks = 1; $ticks -lt 61; $ticks++)
{
$tickRadian = ($ticks * 6) * $DegreesToRadians
$innerpoint.X = $CentrePoint.X + ($clockRadius / 1.50 * [Math]::Sin($tickRadian))
$innerpoint.Y = $CentrePoint.Y - ($clockRadius / 1.50 * [Math]::Cos($tickRadian))
if (($ticks % 5) -eq 0)
{
$outerpoint.X = $CentrePoint.X + ($clockRadius / 1.60 * [Math]::Sin($tickRadian))
$outerpoint.Y = $CentrePoint.Y - ($clockRadius / 1.60 * [Math]::Cos($tickRadian))
$graphicsObj.DrawLine($FifthPen, $innerpoint, $outerpoint)
}
else
{
$outerpoint.X = $CentrePoint.X + ($clockRadius / 1.55 * [Math]::Sin($tickRadian))
$outerpoint.Y = $CentrePoint.Y - ($clockRadius / 1.55 * [Math]::Cos($tickRadian))
$graphicsObj.DrawLine($TicksPen, $innerpoint, $outerpoint)
}
}

# and draw the circle at Centre
$SpotPoint.X = $CentrePoint.X - $CentreRadius/2
$SpotPoint.Y = $CentrePoint.Y - $CentreRadius/2
$graphicsObj.FillEllipse($CircleBrush, $SpotPoint.X, $SpotPoint.Y, $CentreRadius, $CentreRadius)

$graphicsObj.Dispose()
}

#################################
$dispose_AnalogueClock = {
#$SecondsPen.Dispose()
$MinutesPen.Dispose()
$HoursPen.Dispose()
$TicksPen.Dispose()
$CircleBrush.Dispose()
$formTimer.Dispose()
$form.Dispose()
}

#################################
function Start-Clock
{
Initialize-Clock
$formTimer.add_tick($resize_AnalogueClock)
$form.add_load($load_AnalogueClock)
$form.add_resize($resize_AnalogueClock)
$form.add_paint($paint_AnalogueClock)
$form.add_formclosed($dispose_AnalogueClock)
$formTimer.Start()
[void]$form.ShowDialog()
}

start-clock
