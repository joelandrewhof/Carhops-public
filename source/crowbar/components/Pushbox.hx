package crowbar.components;

import flixel.math.FlxPoint;

class Pushbox extends Collision
{
    public var pushForce:Float = 30.0;

    public function new(x:Float, y:Float, width:Float, height:Float, ?offsetX:Int = 0, ?offsetY:Int = 0)
    {
        super(x, y, width, height, offsetX, offsetY);
    }

    public function push(sprite:FlxSprite)
    {
        if(checkOverlap(sprite))
        {
            var pointA:FlxPoint = new FlxPoint(x + (width * 0.5), y + (height * 0.5));
            var pointB:FlxPoint = new FlxPoint(sprite.x + (sprite.width * 0.5), sprite.y + (sprite.height * 0.5));

            var xDif = pointB.x - pointA.x;
            var yDif = pointB.y - pointA.y;
            var angle = FlxAngle.angleFromOrigin(xDif, yDif, false);

            sprite.x += Math.cos(angle) * pushForce;
            sprite.y += Math.sin(angle) * pushForce;
        }
    }
}