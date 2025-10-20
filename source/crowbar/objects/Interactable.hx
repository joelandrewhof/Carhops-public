package crowbar.objects;

import flixel.FlxSprite;
import crowbar.components.Collision;
import crowbar.objects.Player;
import game.states.PlayState; //might not be wise to import fields in the game folder here, idk what else to do tho

/*
    an object with a hitbox and attached dialogue file.
    the overworld state checks if the player is standing in one when they press the ACCEPT key
    if so, a dialogue box is instantiated
    also allows for double-clicking. this feature is used on follower characters for convenience.
    can be spawned dynamically in Ogmo level files, but also are frequently attached to other game objects.
*/

class Interactable extends FlxSprite
{
    public var collision:Collision;
    public var checkCount:Int = 0; //how many times the interactable has been interacted with. used for progressing dialogue.
    public var overrideCheck:Bool = false; //set this to true if you're gonna use a parent class or state to check updates.

    //multiple click stuff for double-tapping
    public var clicks:Int = 0;
    public var clickRequirement:Int = 1;
    private var clickDecrementTime:Float = 0.4;
    private var clickCountdown:Float = 0.0;

    //

    public function new(x:Float, y:Float, width:Float, height:Float, ?dialogueName:String)
    {
        super(x, y);
        makeGraphic(Std.int(width), Std.int(height), 0x4D15C1FF);
        alpha = 0.0;
        collision = new Collision(x, y, width, height);
        clickCountdown = clickDecrementTime;
    }

    public function checkIncrement()
    {
        checkCount++;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        collision.x = this.x;
        collision.y = this.y;

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

        if(!overrideCheck) {
            interactionCheck();
        }

    }

    //check for interaction; putting controls first should limit how often collision is checked
    public function interactionCheck():Bool
    {
        if(Controls.ACCEPT && collision.checkOverlap(PlayState.current.player))
        {
            if(areClicksReached(1))
            {
                checkCallback();
                return true;
            }
        }
        return false;
    }

    //checks if enough clicks have been reached to allow
    public function areClicksReached(?addClicks:Int = 0):Bool
    {
        clicks += addClicks;
        return clicks >= clickRequirement;
    }

    public function resetClicks()
    {
        clicks = 0;
        clickCountdown = clickDecrementTime;
    }

    //set this callback in the object of this component
    public function checkCallback() {}
}