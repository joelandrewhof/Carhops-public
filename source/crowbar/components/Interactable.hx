package crowbar.components;

import flixel.FlxSprite;
import crowbar.components.Collision;
import crowbar.states.game.TopDownState;

class Interactable extends FlxSprite
{
    public var collision:Collision;
    public var checkCount:Int = 0; //how many times the interactable has been interacted with. used for progressing dialogue.
    public var overrideCheck:Bool = false;

    //multiple click stuff for follower class
    public var clicks:Int = 0;
    public var clickRequirement:Int = 1;
    private var clickDecrementTime:Float = 0.4;
    private var clickCountdown:Float = 0.0;

    public function new(x:Float, y:Float, width:Float, height:Float)
    {
        super(x, y);
        makeGraphic(Std.int(width), Std.int(height), 0x4D15C1FF);
        alpha = 0.0;
        collision = new Collision(x, y, width, height);
        clickCountdown = clickDecrementTime;
    }

    public var checkCallback:() -> Void;

    public function checkIncrement()
    {
        checkCount++;
    }

    //check for interaction; putting controls first should limit how often collision is checked
    public function interactionCheck():Bool
    {
        if(Controls.ACCEPT && collision.checkOverlap(TopDownState.current.player))
        {
            return addClick();
        }
        return false;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        collision.x = this.x;
        collision.y = this.y;

        if(!overrideCheck) {
            interactionCheck();
        }

        //remove clicks for every [clickDecrementTime] seconds elapsed, until at 0
        if(clicks > 0)
        {
            clickCountdown -= elapsed;
            if(clickCountdown <= 0.0)
            {
                clicks -= 1;
                clickCountdown = clickDecrementTime;
            }
        }
    }

    //checks if enough clicks have been reached to allow
    public function addClick(?autoCallback:Bool):Bool
    {
        clicks++;
        if (clicks >= clickRequirement) {
            if(autoCallback ?? overrideCheck) {
                if(checkCallback != null) checkCallback();
                resetClicks();
            }
            return true;
        }
        return false;
    }

    public function resetClicks()
    {
        clicks = 0;
        clickCountdown = clickDecrementTime;
    }
}