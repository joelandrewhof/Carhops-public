package game.objects;

import flixel.FlxObject;
import game.objects.CustomerCar;
//a location that associates with orders and cars

class Stall extends FlxObject
{
    public var id:String; //ID will be a letter and number; just making a string cuz it's mainly for differentiation.
    public var occupied:Bool = false; //if a car is currently here
    public var currentCar:CustomerCar;
    public var orientation:Int; //range from 0-7, cardinal directions clockwise. depends which way the spawned car faces.

    public var spawnX:Int;
    public var spawnY:Int;

    public function new(x:Int, y:Int)
    {
        super(x, y);

        spawnX = x + 20;
        spawnY = y + 20;
    }

    public function setOccupied(bool:Bool = false) {
        occupied = bool;
    }
}