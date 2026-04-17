package crowbar.components;

import flixel.math.FlxRect;
import flixel.math.FlxPoint;

/*
    general collision component for NPCs and stuff
*/

class Collision extends Hitbox
{
    public var enableCollide:Bool = true; //if false, collision will be ignored
    public var isTrigger:Bool = false; //if true, the player can enter the object, but something happens when they do

    public function new(x:Float, y:Float, width:Float, height:Float, ?offsetX:Int = 0, ?offsetY:Int = 0)
    {
        super(x, y, width, height, offsetX, offsetY);
    }
}