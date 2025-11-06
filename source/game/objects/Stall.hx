package game.objects;

import flixel.FlxObject;
import flixel.FlxSprite;
import game.objects.CustomerCar;
//a location that associates with orders and cars

class Stall extends FlxSprite
{
    public var id:String; //ID will be a letter and number; just making a string cuz it's mainly for differentiation.
    public var occupied:Bool = false; //if a car is currently here
    public var currentCar:CustomerCar;
    public var orientation:Int; //range from 0-7, cardinal directions clockwise. depends which way the spawned car faces.

    public var spawnX:Int;
    public var spawnY:Int;

    public var showDebug:Bool = false;

    public function new(x:Int, y:Int, id:String, ?orientation:Int = 5)
    {
        super(x, y);

        this.id = id;
        this.orientation = orientation;

        spawnX = x;
        spawnY = y;

        makeGraphic(20, 20, FlxColor.YELLOW);
        alpha = (showDebug ? 1.0 : 0.0);
    }

    public function setOccupied(bool:Bool = false) {
        occupied = bool;
    }
}