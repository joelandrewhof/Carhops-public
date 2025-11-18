package game.ui;

import game.components.SkateMovement;
import flixel.group.FlxSpriteGroup;
import flixel.ui.FlxBar;
import game.states.PlayState;

class StaminaBar extends FlxSpriteGroup
{
    public var bar:FlxBar;

    private var refSkate:SkateMovement;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        bar = new FlxBar(0, 0, LEFT_TO_RIGHT, 150, 30);
        this.add(bar);

        fetchSkateComponent();

    }

    public function fetchSkateComponent()
    {
        if(PlayState.current.playerController != null)
        {
            refSkate = PlayState.current.playerController.getComponentByName("SkateMovement");
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(refSkate != null)
        {
            bar.percent = refSkate.kickStamina;
        }
    }
}