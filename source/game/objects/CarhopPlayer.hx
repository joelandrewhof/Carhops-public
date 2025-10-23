package game.objects;

import crowbar.objects.Player;
import game.components.SkateMovement;

class CarhopPlayer extends Player
{
    public var skate:SkateMovement;

    public function new(characterName:String = "dummy", x:Float, y:Float, facing:String = "s")
    {
        super(characterName, x, y, facing);
        
        skate = new SkateMovement(this);
    }
}