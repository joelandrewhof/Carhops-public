package game.states;

import game.ui.TutorialHUD;
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
import game.components.CarhopsEntityParser;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import game.components.MannyStateManager;
import game.objects.Manny;
import game.components.LevelTime;

class PlayState extends TopDownState
{
	public static var current:PlayState;

	public var conductor:PlayConductor;

	public var levelTime:LevelTime;
	public var elapsedTime:Float = 0.0;

	//object lists
	public var manny:Manny;
	public var customers:FlxTypedGroup<CustomerCar>;
	public var orderTable:OrderTable;

	//gameplay mechanics
	public var inventory:Inventory;

	//hud
	public var hud:CarhopHUD;
	//separating tutorial hud as it's a more temporary thing with timed functions
	public var tutorialHUD:TutorialHUD;

	public var debugHUD:DebugHUD;

	public function new(?room:String, ?x:Int, ?y:Int, ?callback:Void->Void)
    {
        super("level_1");
		current = this;

		conductor = new PlayConductor();
		inventory = new Inventory();
		levelTime = new LevelTime();
		add(levelTime);
    }

	override public function create()
	{
		super.create();

		Score.reset();
		levelTime.reset();
		conductor.reset();

		manny = new Manny();
		add(manny);

		hud = new CarhopHUD();
		hud.camera = camHUD;
		add(hud);

		tutorialHUD = new TutorialHUD();
		tutorialHUD.camera = camHUD;
		add(tutorialHUD);

		customers = new FlxTypedGroup<CustomerCar>();

		//createLevel1Objects();
		createLevel1Debug();

		SoundManager.current.setMusicVolume(0.40);

	}

	override function loadPlayer(x:Float, y:Float)
    {
        player = new Player("player_logan", x, y);

        playerController = new PlayerController(player);
        //add movement components
        playerController.addMoveComponent(new SkateMovement(playerController));

        playerHitbox = new PlayerHitbox(player);
        add(playerHitbox);
    }

	public function createLevel1Debug()
	{
		
		debugHUD = new DebugHUD();
		debugHUD.camera = this.camHUD;
		add(debugHUD);
		
		

		var s = ["A1", "A2", "A3", "A4"];
		for(i in 0...4)
		{
			conductor.createOrderEntire(s[i]);
		}

		playerHitbox.alpha = 0.0;

	}

	public function debugInput(elapsed:Float)
	{
		if(FlxG.keys.pressed.CONTROL)
		{
			manny.stateManager.decreaseRage(0.2 * elapsed);
		}

		if(FlxG.keys.justPressed.SPACE)
		{
			manny.stateManager.addAnger();
		}

		levelTime.minsPerSecond = (FlxG.keys.pressed.SHIFT ? 30.0 : 1.0);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		elapsedTime += elapsed;

		//update objects
		conductor.update(elapsed);
		manny.update(elapsed);

		comboTick(elapsed);

		if(Math.floor(elapsedTime + elapsed) > Math.floor(elapsedTime)) //call every ~1 second
		{
			//insert code here
		}

		debugInput(elapsed);
	}

	override public function openPauseMenu()
    {
        final pause:CarhopPauseMenu = new CarhopPauseMenu();
		pause.camera = camAlt;
        setLockAllInput(true);
        playerController.paused = true;
		openSubState(pause);
    }

	override public function loadEntity(entity:EntityData)
	{
		CarhopsEntityParser.loadEntity(entity);
	}

	public function deliverOrder(car:CustomerCar)
	{
		var thisOrder = PlayState.current.inventory.getOrderFromStall(car.stallID);
		if(thisOrder != null && thisOrder.destination == car.stallID) //if the order is in the inventory and it matches this car
		{
			Score.addCombo();
			Score.addStreak();
			conductor.deliveryRageReduction(Score.doScoreCalculation(thisOrder));
			

			inventory.removeOrder(thisOrder.ticket);
			thisOrder.satisfied = true;

			SoundManager.playSound("order_success", 0.4);

			car.ignitionSound();
			car.controller.getComponentByName("CarMovement").startReverse();
		}
		
	}

	public function failOrder(order:Order)
	{
		var car = PlayState.current.conductor.getCustomerAtStall(order.destination);
		trace('FAILING ${car.stallID} ${order.destination}');
		if(car != null && order.destination == car.stallID)
		{
			Score.breakCombo();
			Score.breakStreak();
			//hud.scoreHUD.updateScoreDisplay();
			inventory.removeOrder(order.ticket);
			order.satisfied = true; //satisfied may be a bad word for this, change maybe

			//SoundManager.playSound("order_failure", 0.4);

			car.ignitionSound();
			car.controller.getComponentByName("CarMovement").startReverse();

			conductor.addMannyAnger();
		}
	}

	private function comboTick(elapsed:Float, ?modifier:Float = 1.0)
	{
		if(Score.combo > 0)
		{
			Score.comboTime -= elapsed * modifier;
			if(Score.comboTime <= 0.0)
			{
				Score.breakCombo();
			}
		}
	}

}
