package crowbar.core;

import flixel.FlxBasic;

class Clock extends FlxBasic
{
    public static var current:Clock;

    public var runtime:Float = 0;
    public var tick:Int = 0;
    public static final tps:Int = 10;
    public var isTickFrame:Bool = false;

    private var subTick:Float = 0.0;
    private var t:Float = 0;
    private var _tickRate:Float;

    public function new() 
    {
        super();
        
        _tickRate = 1 / tps;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        runtime += elapsed;
        subTick += elapsed;

        if(subTick > _tickRate) {
            t = subTick / _tickRate;
            tick += Math.floor(t);
            subTick = t % Math.floor(t);
            isTickFrame = true;
        }
        else {
            isTickFrame = false;
        }

        trace(runtime);
    }


}