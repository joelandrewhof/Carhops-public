package game.states;

import crowbar.components.Directional;
import crowbar.objects.TopDownCharacter;
import game.ui.CarhopHUD;
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
import game.states.sub.CarhopPauseMenu;

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

	//hud
	public var hud:CarhopHUD;

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

		hud = new CarhopHUD();
		hud.camera = camHUD;
		add(hud);

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
		orderTable = new OrderTable(1280, 1600);

		visMngr.add(customers);
		visMngr.add(orderTable);

		//create the stalls
		var stallin:FlxPoint = new FlxPoint(128, 256);
		if(conductor.stalls != null)
		{
			for(i in 0...2)
			{
				for(j in 0...7)
				{
					var id:String = (i == 0 ? "A" : "B");
					var s = new Stall(Std.int(stallin.x), Std.int(stallin.y) + (352 * j), id + (6 - j + 1), 
						(id == "A" ? 3 : 7));
					conductor.stalls.push(s);
					visMngr.add(s); //we can do this for now, but best to add them from the array later
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

		var s = ["A1", "A4", "B1", "B7"];
		for(i in 0...4)
		{
			conductor.createOrderEntire(s[i]);
		}

		playerHitbox.alpha = 0.0;

	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		elapsedTime += elapsed;

		if(Math.floor(elapsedTime + elapsed) > Math.floor(elapsedTime)) //call every ~1 second
		{
			trace("active cars: " + conductor.customers.length + " x" + conductor.customers[0].x + " y" + conductor.customers[0].y);

		}
	}

	override public function openPauseMenu()
    {
        final pause:CarhopPauseMenu = new CarhopPauseMenu();
		pause.camera = camAlt;
        setLockAllInput(true);
        playerController.paused = true;
		openSubState(pause);
    }

}
