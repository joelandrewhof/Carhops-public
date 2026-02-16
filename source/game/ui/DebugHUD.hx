package game.ui;

import game.components.SkateMovement;
import flixel.group.FlxSpriteGroup;
import crowbar.display.CrowbarText;
import game.states.PlayState;
import crowbar.objects.ui.Number;

class DebugHUD extends FlxSpriteGroup
{
    public var text:CrowbarText;
    
    //utility variables
    public var skate:SkateMovement; 

    public var numGrp:NumberGroup;

    public function new()
    {
        super();
        addElements();
        //NULL CHECK THIS
        skate = PlayState.current.playerController.getComponentByName("SkateMovement");

        add(new DialClock(50, 50));

        numGrp = new NumberGroup(0, 0, "tips_num_big", 123);
        add(numGrp);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        text.text = ("NO KICK: " + Std.int(skate.timeWithoutKick * 100) * 0.01 
        + "\nSTAMINA: " + Std.int(skate.kickStamina)
        + "\nMOMENTUM: x " + Std.int(skate.xMomentum * 100) * 0.01 + " y" + Std.int(skate.yMomentum * 100) * 0.01);
        //numGrp.updateNumbers();
    }

    public function addElements()
    {
        text = new CrowbarText(20, 600);
        text.setFont("vcr", 32);
        text.setBorder(3);
        //add(text);
    }
}