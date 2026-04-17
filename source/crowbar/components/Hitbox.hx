package crowbar.components;

import flixel.math.FlxRect;
import flixel.math.FlxPoint;

class Hitbox extends FlxRect
{
    public var hbOffset:FlxPoint;

    public function new(x:Float, y:Float, width:Float, height:Float, ?offsetX:Int = 0, ?offsetY:Int = 0)
    {
        super(x, y, width, height);
        hbOffset = new FlxPoint(offsetX, offsetY);
    }

    public function checkOverlap(hitbox:FlxSprite):Bool
    {
        //generic in-bounds check. returns true if player is overlapping this area.
        if(hitbox.x + hitbox.width > this.left && hitbox.x < this.right) //horizontal check
        {
            if(hitbox.y + hitbox.height > this.top && hitbox.y < this.bottom) //vertical check
            {
                return true;
            }
            else
                return false;
        }
        else
            return false;
    }
}