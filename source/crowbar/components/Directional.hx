package crowbar.components;

//a directional component to give to certain types of objects if they have rotation

enum abstract DirectionString(String) to String{
    var NONE = "none";
    var NORTH = "n";
    var SOUTH = "s";
    var WEST = "w";
    var EAST = "e";
    var NORTHEAST = "ne";
    var SOUTHEAST = "se";
    var SOUTHWEST = "sw";
    var NORTHWEST = "nw";
}

enum abstract Orientation(Int) to Int{
    var FRONT = 0;
    var EQUAL = 0;
    var DIAGONAL_RIGHT = 1;
    var PERPENDICULAR_RIGHT = 2;
    var DIAGONAL_RIGHT_REAR = 3;
    var REAR = 4;
    var BEHIND = 4;
    var OPPOSITE = 4;
    var DIAGONAL_LEFT_REAR = 5;
    var PERPENDICULAR_LEFT = 6;
    var DIAGONAL_LEFT = 7;
}

class Directional
{
    public var degrees:Float = 0;
    public var div:Int = 8;
    private var slice:Float = 0;
    public var index:Int = 0;

    public static var cardinalMap:Map<String, Int> = [
        NORTH => 0, 
        NORTHEAST => 1, 
        EAST => 2, 
        SOUTHEAST => 3, 
        SOUTH => 4, 
        SOUTHWEST => 5, 
        WEST => 6, 
        NORTHWEST => 7];

    public static var cardinalArray:Array<String> = [
        NORTH, 
        NORTHEAST, 
        EAST, 
        SOUTHEAST, 
        SOUTH, 
        SOUTHWEST, 
        WEST,
        NORTHWEST];

    public function new(?div:Int = 8, ?degrees = 0)
    {
        this.degrees = degrees;
        updateDiv(div);
    }

    public function updateDir(dir:Int = 0)
    {
        index = dir;
    }

    public function updateDiv(div:Int = 8)
    {
        this.div = div;
        slice = 360 / div;
    }

    //NOTE: this function only works with div of 4 or 8
    public function updateDirFromString(?dir:String = NONE)
    {
        if(dir == "" || dir == NONE)
            return;
        var num:Int = cardinalMap.get(dir) ?? 0;
        num = Std.int(num * (div / 8));
        updateDir(num);
    }

    public function updateDirFromInput(ver:Int, hor:Int)
    {
        var str:String = "";

        if(ver == -1) str += "n";
        else if(ver == 1) str += "s";
        if(hor == -1) str += "w";
        else if(hor == 1) str += "e";
        
        updateDirFromString(str);
    }

    public function updateDirFromDegrees(degrees:Float)
    {
        degrees -= (slice * 0.5);
        degrees = degrees % 360;
        return Math.round(degrees / slice);
    }

    public inline function getDirString()
    {
        return cardinalArray[Std.int(index)];
    }


    //warning: don't use this one for an update function, go off of local values
    public static function _degreesToIndex(degrees:Float, ?div:Int = 8):Int
    {
        if(div <= 0) div = 1;
        var slice = 360 / div;
        degrees -= (slice * 0.5);
        degrees = degrees % 360;
        return Math.round(degrees / slice);
    }
}