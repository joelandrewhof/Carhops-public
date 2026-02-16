package game.ui;

import game.components.SkateMovement;
import crowbar.display.CrowbarSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
import crowbar.display.CrowbarText;
import flixel.util.FlxTimer;
import game.states.PlayState;

class TutorialHUD extends FlxSpriteGroup
{

    public var sprintPopup:TutorialPopup;
    public var flags:Array<String>;

    private var skate:SkateMovement;


    public function new()
    {
        super();

        sprintTipCreate();

        skate = PlayState.current.playerController.getComponentByName("SkateMovement");

    }

    override function update(elapsed:Float)
    {
        if(Controls.RUN && skate.xMomentum + skate.yMomentum >= 5.0)
        {
            sprintTipCallback();
        }

        sprintPopup.update(elapsed);
    }

    public function sprintTipCreate()
    {
        sprintPopup = new TutorialPopup(400, 620);
        sprintPopup.setText(0, 0, 0, "Hold K to skate forward!", 28);
        sprintPopup.setSprite();
        sprintPopup.flashIntensity = 0.5;
        add(sprintPopup);
    }

    public function sprintTipCallback()
    {
        sprintPopup.setText(0, 0, 0, "This consumes stamina; make use of your momentum!", 28);
        sprintPopup.flashIntensity = 0.0;
        new FlxTimer().start(5.0, function(tmr:FlxTimer) {
            FlxTween.tween(sprintPopup, {alpha:0.0}, 1.0);
        });
    }


}

class TutorialPopup extends FlxSpriteGroup
{
    public var text:CrowbarText;
    public var sprite:CrowbarSprite;

    //maybe replace this with global time later
    private var time:Float = 0.0;
    public var flashIntensity:Float = 0.0;
    public var flashSpeed:Float = 6.0;

    public function new(x:Float, y:Float)
    {
        super(x, y);
    }

    public function setText(?x:Float = 0, ?y:Float = 0, ?width:Float = 0, ?string:String, ?size:Int)
    {
        if(text == null)
        {
            text = new CrowbarText(x, y, width, string, size);
            text.updateHitbox();
            add(text);
        }
        else
        {
            text.x = this.x + x;
            text.y = this.y + y;
            text.width = width;
            text.text = string;
            text.updateHitbox();
        }
        
    }

    public function setSprite(?x:Float = 0, ?y:Float = 0, ?graphic:String)
    {
        if(graphic != null) {
            sprite = new CrowbarSprite(x, y, graphic);
            add(sprite);
        }
        else 
            sprite = new CrowbarSprite(x, y);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        time += elapsed;
        if(flashIntensity > 0) {
            text.alpha = (1.0 - flashIntensity) + (Math.sin(time * flashSpeed) * 0.5) + 0.5;
        }
    }
}