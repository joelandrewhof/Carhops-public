package game.components;

import flixel.FlxBasic;

class LevelTime extends FlxBasic
{
    //tracks the in-game time, shift duration, overtime, etc.

    public var trueElapsedMinutes:Float = 0.0; //tracks the actual elapsed time of this level
    public var elapsedMinutes:Float = 0.0; //tracks the effective in-game time
    public var minsPerSecond:Float = 1.0;

    //format time as a 24-h Ints like this.
    public var shiftStart:Int = 1200; 
    public var shiftEnd:Int = 2000;
    public var storeClose:Int = 2400;

    public var startBufferTime:Int = 400;
    public var shiftLength:Int;

    override public function new(?start:Int = 1200, ?end:Int = 2000)
    {
        super();

        shiftStart = start;
        shiftEnd = end;

        reset();

        shiftLength = Std.int(base10Convert(shiftEnd) - base10Convert(shiftStart));
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        trueElapsedMinutes += elapsed;
        elapsedMinutes += elapsed * minsPerSecond;
    }
    
    public function reset()
    {
        trueElapsedMinutes = 0.0;
        elapsedMinutes = 0.0 - startBufferTime;
    }

    public function base60Convert(seconds:Float):Float
    {
        if(seconds >= 0) {
            return ((Math.floor(seconds / 60) * 100) + (seconds % 60));
        }
        else {
            return ((Math.ceil(seconds / 60) * 100) + (seconds % 60)) - 40;
        }

    }

    //reverses the above function
    public function base10Convert(seconds:Float):Float
    {
        if(seconds >= 0) {
            return ((Math.floor(seconds / 100) * 60) + (seconds % 100));
        }
        else {
            return ((Math.ceil(seconds / 100) * 60) + (seconds % 100)) + 40;
        }
    }

    //basically just adds the elapsed time to the start time.
    public function getTimeFloat():Float
    {
        return shiftStart + base60Convert(elapsedMinutes);
    }

    public function getTimeString():String
    {
        var time:Int = Math.floor(getTimeFloat());
        var hours = Math.floor(time * 0.01);
        var mins = time - (hours * 100);
        var meridian = (hours < 12 ? "AM" : "PM");

        while(hours > 12)
            hours -= 12;
        if(hours == 0 || hours == 24)
            hours = 12;

        return '${hours}:${(mins < 10 ? "0" : "")}${mins} ${meridian}';
    }

    public function isItOvertime():Bool
    {
        return (shiftStart + base60Convert(elapsedMinutes) > shiftEnd);
    }
}