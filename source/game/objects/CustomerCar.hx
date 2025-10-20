package game.objects;

import crowbar.objects.TopDownCharacter;

class CustomerCar extends TopDownCharacter
{
    public var stallID:String; //the stall the car spawned at. for orders to reference.

    public var ordered:Bool = false; //if the customer is vacant for an order or not
    public var basePatience:Float; //how long it takes for the customer to get pissed off
    public var curPatience:Float;
    public var variant:String;
    public var impatient:Bool = false;

    public var patienceDrainFactor:Float = 1.0;
    public var patienceDrainEnabled:Bool = false;

    /*
    *   CONSTANTS
    */
    public final spritePath = "images/characters/";
    public static var patienceRange = [30.0, 45.0];

    public static var carVariants:Array<String> = [
        "test_car"
    ];

    public function new(x:Int, y:Int, stall:String, ?variant:String = "test_car")
    {
        super(x, y);
        stallID = stall;
        setCar(variant);
        startPatience();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(patienceDrainEnabled) {
            curPatience -= elapsed * patienceDrainFactor;
        }

        if(!impatient) {
            impatient = true;
            expirePatienceCall();
        }

    }

    //might want to manage this through the director class for rare car spawns
    private function setCar(variant:String)
    {
        this.variant = variant;
        loadSprite(spritePath+variant, true);
    }

    private function startPatience()
    {
        if(!ordered) return;
        basePatience = FlxG.random.float(patienceRange[0], patienceRange[1]);
        curPatience = basePatience;
        patienceDrainEnabled = true;
    }

    public function expirePatienceCall()
    {
        
    }
}