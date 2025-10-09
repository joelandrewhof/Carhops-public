package crowbar.objects;

import crowbar.states.game.TopDownState;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup;
import crowbar.display.CrowbarSprite;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

//an overworld object that acts as an incline, adjusting the player's Y with X movement.
class Stairs extends TopDownSprite
{
    public var parallelogram:Parallelogram;

    public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0, slope:Float = 0)
    {
        super(x, y);
        parallelogram = new Parallelogram(x, y, width, height, slope);
    }
}