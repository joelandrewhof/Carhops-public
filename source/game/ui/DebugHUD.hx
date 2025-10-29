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
        + "\nSTAMINA: " + Std.int(skate.kickStamina)
        + "\nMOMENTUM: x " + Std.int(skate.xMomentum * 100) * 0.01 + " y" + Std.int(skate.yMomentum * 100) * 0.01);
    }

    public function addElements()
    {
        text = new CrowbarText(20, 600);
        text.setFont("vcr", 32);
        text.setBorder(3);
        add(text);
    }
}