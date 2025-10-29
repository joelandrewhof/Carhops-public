package game.states;

import game.ui.DebugHUD;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import crowbar.states.game.TopDownState;
import flixel.math.FlxPoint;
import game.objects.*;
import game.components.*;
import crowbar.objects.Player;

class PlayState extends TopDownState
{
	public static var current:PlayState;

	public var conductor:PlayConductor;

	public var elapsedTime:Float = 0.0;

	//object lists
	public var customers:FlxTypedGroup<CustomerCar>;
	public var orderTable:OrderTable;

	//gameplay mechanics
	public var inventory:Inventory;

	public var debugHUD:DebugHUD;

	public function new(?room:String, ?x:Int, ?y:Int, ?callback:Void->Void)
    {
        super("level_1");
		current = this;

		conductor = new PlayConductor();
		inventory = new Inventory();
    }

	override public function create()
	{
		super.create();

		createLevel1Objects();
		createLevel1Debug();

	}

	override function loadPlayer(x:Float, y:Float)
    {
        player = new Player("dummy", x, y);

        playerController = new PlayerController(player);
        //add movement components
        playerController.addMoveComponent(new SkateMovement(playerController));

        playerHitbox = new PlayerHitbox(player);
        add(playerHitbox);
    }

	public function createLevel1Objects()
	{
		customers = new FlxTypedGroup<CustomerCar>();
		orderTable = new OrderTable(1000, 1000);

		add(customers);
		add(orderTable);

		//create the stalls
		var stallin:FlxPoint = new FlxPoint(128, 256);
		if(conductor.stalls != null)
		{
			for(i in 0...2)
			{
				for(j in 0...7)
				{
					var id:String = (i == 0 ? "A" : "B");
					var s = new Stall(Std.int(stallin.x), Std.int(stallin.y) + (352 * j), id + (j + 1));
					conductor.stalls.push(s);
					this.add(s); //we can do this for now, but best to add them from the array later
				}
				stallin.x += 2368;
			}
		}
	}

	public function createLevel1Debug()
	{
		debugHUD = new DebugHUD();
		debugHUD.camera = this.camHUD;
		add(debugHUD);

		for(i in 0...4)
		{
			conductor.createOrderEntire();
		}

	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		elapsedTime += elapsed;

		if(Math.floor(elapsedTime + elapsed) > Math.floor(elapsedTime)) //call every ~1 second
		{
			//trace("active orders: " + conductor.orders);
			//trace("active cars: " + conductor.customers);
		}
	}

}
