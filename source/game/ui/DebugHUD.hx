package game.ui;

import game.components.SkateMovement;
import flixel.group.FlxSpriteGroup;
import crowbar.display.CrowbarText;
import game.states.PlayState;

class DebugHUD extends FlxSpriteGroup
{
    public var text:CrowbarText;
    
    //utility variables
    public var skate:SkateMovement; 

    public function new()
    {
        super();
        addElements();
        //NULL CHECK THIS
        skate = PlayState.current.playerController.getComponentByName("SkateMovement");
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        text.text = ("NO KICK: " + Std.int(skate.timeWithoutKick * 100) * 0.01 
        + "\n | STAMINA: " + Std.int(skate.kickStamina)
        + "\n | MOMENTUM: x " + skate.xMomentum + " y" + skate.yMomentum);
    }

    public function addElements()
    {
        text = new CrowbarText(20, 680);
        text.setFont("terminus", 20);
        add(text);
    }
}