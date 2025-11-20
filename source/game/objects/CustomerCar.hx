package game.objects;

import game.components.CarMovement;
import crowbar.objects.TopDownCharacter;
import crowbar.components.Collision;
import crowbar.components.Interactable;
import game.components.Score;
import game.states.PlayState;

class CustomerCar extends TopDownCharacter
{
    public var tick:Float;

    public var stallID:String; //the stall the car spawned at. for orders to reference.

    public var ordered:Bool = false; //if the customer is vacant for an order or not
    public var basePatience:Float; //how long it takes for the customer to get pissed off
    public var curPatience:Float;
    public var variant:String;
    public var impatient:Bool = false;

    public var patienceDrainFactor:Float = 1.0;
    public var patienceDrainEnabled:Bool = false;

    public var interactable:Interactable;

    public var controller:CharacterController;

    /*
    *   CONSTANTS
    */
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

        //collision has already been set, reset it to cover a more reasonable area
        collision = new Collision(0, 30, sprite.width, sprite.height - 60);
        interactable = new Interactable(-50, -100, sprite.width + 200, sprite.height + 100);
        interactable.alpha = 0.0;
        this.add(interactable);

        controller = new CharacterController(this);
        controller.addMoveComponent(new CarMovement(controller));

        this.setPosition(x, y);
        sprite.setPosition(x, y);

        sprite.updateHitbox();
        updateHitbox();

        interactable.checkCallback = function() {
            var thisOrder = PlayState.current.inventory.getOrderFromStall(stallID);
            if(thisOrder != null && thisOrder.destination == stallID)
            {
                Score.addScore(100);
                PlayState.current.hud.scoreHUD.updateScoreDisplay();
                PlayState.current.inventory.removeOrder(thisOrder.ticket);
                SoundManager.playSound("order_success", 0.4);

                ignitionSound();
                
                controller.getComponentByName("CarMovement").startReverse();
            }
        }

    }

    public function ignitionSound()
    {
        SoundManager.playSound('car_ignition${FlxG.random.int(1, 2)}');
        SoundManager.playSound('car_start_short${FlxG.random.int(1, 2)}', 1.0, 0.4);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        controller.update(elapsed);

        tick += elapsed;
        if(tick > 0.2)
        {
            if(checkOffscreen()) 
            {
                cleanup();
                kill();
            }
            tick = 0;
        }

        if(patienceDrainEnabled) {
            curPatience -= elapsed * patienceDrainFactor;
        }

        if(!impatient) {
            impatient = true;
            expirePatienceCall();
        }

        sprite.setPosition(x, y);
        interactable.setPosition(x - 100, y - 50);
        collision.setPosition(x, y + 30);

        sprite.updateHitbox();
        interactable.updateHitbox();

    }

    public function checkOffscreen():Bool
    {
        var margin = 400;
        if(x < 0 - margin || y < 0 - margin || 
            x > PlayState.current.room.roomBounds.width + margin || y > PlayState.current.room.roomBounds.height + margin)
        {
            return true;
        }
        else return false;
    }

    //might want to manage this through the director class for rare car spawns
    private function setCar(variant:String)
    {
        this.variant = variant;
        loadCharacterSprite(variant);
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

    public function cleanup()
    {
        PlayState.current.conductor.setVacantStall(stallID, true);
        PlayState.current.conductor.customers.remove(this);
    }

    override function kill()
    {        
        super.kill();
    }
}