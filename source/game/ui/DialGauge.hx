package game.ui;

import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup;
import crowbar.display.CrowbarSprite;

class DialGauge extends FlxSpriteGroup
{
    public var needle:CrowbarSprite;
    public var gauge:CrowbarSprite;

    public var centerOffsetX:Float = 0;
    public var centerOffsetY:Float = 0;
    public var minDegrees:Float = 180; //The degrees position of "zero"
    public var maxDegrees:Float = 0; //The degrees position of a full gauge - by default it'll be opposite the minDegrees
    public var percent:Float = 0.0;

    public function new(x:Float, y:Float, gaugeSprite:String, needleSprite:String)
    {
        super(x, y);

        this.gauge = new CrowbarSprite(0, 0, gaugeSprite);
        this.needle = new CrowbarSprite(0, 0, needleSprite);
        add(gauge);
        add(needle);

        updateNeedlePosition();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        updateMeterDisplay();
    }

    public function updateNeedlePosition()
    {
        needle.x = gauge.x + (gauge.width * 0.5) - (needle.width * 0.5) + centerOffsetX;
        needle.y = gauge.y + gauge.height - (needle.height * 0.5) + centerOffsetY;
    }

    public function updateMeterDisplay()
    {
        var targetAngle = FlxMath.lerp(minDegrees, maxDegrees, percent);
        needle.angle = FlxMath.lerp(needle.angle, targetAngle, 0.30); //easing
    }
}