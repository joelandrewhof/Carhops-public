package crowbar.objects;

import flixel.FlxSprite;
import crowbar.components.Collision;
//import crowbar.scripts.UTScript;

/**
 * WARNING: THIS IS BEING TEMPORARILY NEUTERED
 */

class EventTrigger extends FlxSprite
{
    public var enabled:Bool = true;
    public var isButton:Bool = false; //if true, only activate on ACCEPT key press. if false, activate when colliding.
    public var disableAfterUses:Int = 1; //set to a negative number for infinite uses

    public var collision:Collision;

    public function new(x:Float, y:Float, width:Float, height:Float, script:String, ?isButton:Bool = false, ?uses:Int = 1)
    {
        super(x, y);
        makeGraphic(Std.int(width), Std.int(height), 0x4DFF7615);
        alpha = 0.0;
        collision = new Collision(x, y, width, height);

        this.isButton = isButton;
        disableAfterUses = uses;
    }

    public function callScript()
    {

    }

    public function checkOverlap(hitbox:FlxSprite):Bool
    {
        return collision.checkOverlap(hitbox);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        collision.x = this.x;
        collision.y = this.y;
    }
}