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
}