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
        hitbox = new Hitbox(x, y, Std.int(sprite.width * 0.30), Std.int(sprite.height * 0.30));

        visible = false;
        canKill = false;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        hitbox.x = sprite.x + (sprite.width * 0.5) - (hitbox.width * 0.5);
        hitbox.y = sprite.y + (sprite.height * 0.5) - (hitbox.height * 0.5);

        if(!PlayState.current.inGameOverScreen && hitbox.checkOverlapHitbox(PlayState.current.player.collision))
        {
            if(canKill)
                killPlayer();
        }
    }

    public function killPlayer()
    {
        trace("KILL");
        PlayState.current.openGameOverState();
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