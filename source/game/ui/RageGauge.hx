package game.ui;

class RageGauge extends DialGauge
{
    public function new(x:Float, y:Float)
    {
        super(x, y, "images/ui/anger_meter.png", "images/ui/anger_needle.png");
        centerOffsetX = 0;
        centerOffsetY = -80;
        minDegrees = 155;
        maxDegrees = 385;
    }
}