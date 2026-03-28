package game.ui;

import flixel.math.FlxRect;
import crowbar.display.CrowbarSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;

enum abstract OdometerDirection(Int) to Int{
    var VERTICAL = 0;
    var HORIZONTAL = 1;
}

class Odometer extends CrowbarSprite
{
    public var direction:OdometerDirection = VERTICAL;
    public var indexLength:Int; //the length of each option in pixels, width or height
    public var indices:Int;
    public var index:Int = 0;
    //add a loop variable at some point (when reaching bottom warp to top & vice versa)
    public var ease:Float = 20;

    public var cliptangle:FlxRect;
    public var clipTween:FlxTween;

    public function new(x:Float, y:Float, graphic:String, length:Int, ?direction:OdometerDirection = VERTICAL)
    {
        super(x, y, graphic);
        indices = length;
        this.direction = direction;

        indexLength = Math.ceil((direction == VERTICAL ? this.height : this.width) / indices);

        switch direction
        {
            case VERTICAL:
                cliptangle = new FlxRect(0, 0, this.width, indexLength);
            case HORIZONTAL:
                cliptangle = new FlxRect(0, 0, indexLength, this.height);
        }
        this.clipRect = cliptangle;

    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        clipFunc(elapsed);
    }

    public function clipTweenFunc()
    {

    }

    public function clipFunc(elapsed:Float)
    {
        switch direction
        {
            case VERTICAL: {
                var prev = cliptangle.y;
                if(Math.abs(cliptangle.y - (index * indexLength)) > 1) {
                    cliptangle.y = FlxMath.lerp(cliptangle.y, index * indexLength, ease * elapsed); 
                }
                else {
                    cliptangle.y = index * indexLength;
                }
                this.y += prev - cliptangle.y;
            }
            case HORIZONTAL: {
                var prev = cliptangle.x;
                if(Math.abs(cliptangle.x - (index * indexLength)) > 1) {
                    cliptangle.x = FlxMath.lerp(cliptangle.x, index * indexLength, ease * elapsed); 
                }
                else {
                    cliptangle.x = index * indexLength;
                }
                this.x += prev - cliptangle.x;
            }
        }
    }

    public function updateIndex(i:Int)
    {
        index = i % indices;
    }
}