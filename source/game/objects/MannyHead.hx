package game.objects;

import crowbar.components.Hitbox;
import crowbar.objects.TopDownCharacter;
import flixel.math.FlxVelocity;

class MannyHead extends TopDownCharacter
{   
    public var hitbox:Hitbox;

    public var canKill:Bool = true;

    public final spritePath:String = "manny_head";

    public function new(x:Float, y:Float)
    {
        super(spritePath, x, y, "s");
        sprite.scale.set(0.5, 0.5);
        hitbox = new Hitbox(x, y, Std.int(sprite.width * 0.70), Std.int(sprite.height * 0.70));

        visible = false;
        canKill = false;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        hitbox.x = (sprite.width * 0.5) - (hitbox.width * 0.5);
        hitbox.y = (sprite.height * 0.5) - (hitbox.height * 0.5);

        if(hitbox.checkOverlap(PlayState.current.playerHitbox))
        {
            if(canKill)
                killPlayer();
        }
    }

    public function killPlayer()
    {
        trace("KILL");
    }

    public function activate()
    {
        visible = true;
        canKill = true;
    }

    public function deactivate()
    {
        visible = false;
        canKill = false;
    }

}