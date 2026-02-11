package game.ui;

import flixel.math.FlxPoint;
import flixel.addons.display.FlxPieDial;
import flixel.group.FlxSpriteGroup;
import haxe.ds.IntMap;

class DialClock extends FlxSpriteGroup
{
    public final _clockSpriteDir = "ui/clock_small";

    public var xOff:Int = -6;
    public var yOff:Int = 23;
    public var dialSize:Int = 16;
    public var dialAngle:Int = 330;

    //variables for shaking the clock when time runs out
    public var shakeFactor:Float = 2.0;
    public var shakeThreshold:Float = 0.25;
    //variables for timer fill color depending on amount
    public var colorThresholdMap:Map<Int, Float> = [
        0xFFFFFFFF => 1.0,
        0xFFFFFF55 => 0.5,
        0xFFFF2200 => 0.25
    ];

    private var empty:FlxPieDial;
    private var dial:FlxPieDial;
    public var outer:FlxSprite;
    public var anchor:FlxPoint;

    public var amount:Float = 1.0;

    public function new(x:Int = 0, y:Int = 0)
    {
        super();

        this.amount = 1.0;
        empty = new FlxPieDial(x + xOff, y + yOff, 16, FlxColor.BLACK, 128);
        empty.angle = dialAngle;
        this.add(empty);
        empty.amount = 1.0;
        dial = new FlxPieDial(x + xOff, y + yOff, 16, FlxColor.WHITE, 128, false);
        dial.angle = dialAngle;
        this.add(dial);
        dial.amount = amount;

        outer = new FlxSprite(x, y);
        outer.loadGraphic(Paths.image(_clockSpriteDir));
        outer.frames = AssetHelper.getAsset("images/" + _clockSpriteDir, ATLAS);
        outer.alpha = 0.5;
        this.add(outer);

        anchor = new FlxPoint(x, y);

    }

    public override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        dial.amount = amount;
        if(amount <= shakeThreshold && shakeFactor > 0) {
            shake();
        }
        else {
            this.x = anchor.x;
            this.y = anchor.y;
        }

        setColorFromThreshold();
    }

    public function setColorFromThreshold()
    {
        var lowest:Float = 1.0;
        var clr:FlxColor = 0xFFFFFFFF;
        for(key in colorThresholdMap.keys()) //this is probably a really retarded use of maps but haxe doesnt support float keys lol
        {
            if(amount <= colorThresholdMap.get(key)) //if we're below this threshold
            {
                if(lowest >= colorThresholdMap.get(key)) //if this is the new lowest threshold
                {
                    lowest = colorThresholdMap.get(key); //only updates if this is the lowest threshold we have reached
                    clr = key;
                }
            }
        }
        if(dial.color != clr)
            dial.color = clr;

    }

    public function shake()
    {
        this.x = anchor.x + (FlxG.random.float(-shakeFactor, shakeFactor)); 
        this.y = anchor.y + (FlxG.random.float(-shakeFactor, shakeFactor));
    }

    public function updateAnchor(x:Float, y:Float)
    {
        anchor.x = x;
        anchor.y = y;
        this.x = anchor.x;
        this.y = anchor.y;
    }
}