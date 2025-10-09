package crowbar.objects;

import crowbar.states.game.TopDownState;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup;
import crowbar.display.CrowbarSprite;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

enum abstract DrawLayer(Int) to Int{
    var FOREGROUND = 1;
    var DEFAULT = 0;
    var BACKGROUND = -1;
}

/**
 * A Crowbar sprite that contains more draw order information, allowing for perspective depth.
 */

class TopDownSprite extends FlxSpriteGroup
{
    public var name:String = "NewSprite"; //for identification
    public var sprite:CrowbarSprite;

    public var worldHeight:Float; //determines draw order. do not change this.
    public var elevation:Float; //affects the height. a higher elevation means the sprite will draw later relative to others at the same y pos.
    public var drawHeight:Int; //a value assigned in Ogmo that determines draw order independent of height. prioritize over worldHeight.
    public var layer:Int; //if FOREGROUND: always draw on top. if BACKGROUND: always draw before everything else.

    public var bottomCenter:FlxPoint; //this is the object/character's "feet": used for pathfinding and other stuff.

    public function new(x:Float, y:Float, ?elevation:Float = 0.0, ?layer:Int = DEFAULT, ?drawHeight:Int = 0, ?name:String = "NewSprite")
    {
        super(x, y);
        sprite = new CrowbarSprite(0, 0);

        worldHeight = this.y; //temporary
        this.name = name;
        this.elevation = elevation;
        this.layer = layer;
        this.drawHeight = drawHeight;
        bottomCenter = new FlxPoint();
    }

    public function loadSprite(spr:String, ?animated:Bool = false):TopDownSprite
    {
        sprite.loadGraphic(AssetHelper.getAsset(spr, IMAGE));
        if(animated)
            sprite.frames = AssetHelper.getAsset(spr, ATLAS);

        sprite.antialiasing = false;
        sprite.updateHitbox();
        this.add(sprite);

        return this;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        bottomCenter.x = this.x + (sprite.width / 2);
        bottomCenter.y = this.y + sprite.height;

        worldHeight = bottomCenter.y + elevation;
    }
}