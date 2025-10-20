package game.states;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import crowbar.states.game.TopDownState;
import game.objects.*;
import game.components.*;

class PlayState extends TopDownState
{
	public static var current:PlayState;

	public var conductor:PlayConductor;

	//object lists
	public var customers:FlxTypedGroup<CustomerCar>;
	public var orderTable:OrderTable;

	public function new(?room:String, ?x:Int, ?y:Int, ?callback:Void->Void)
    {
        super("level_1");
		current = this;

		conductor = new PlayConductor();
    }

	override public function create()
	{
		super.create();

	}

	public function createLevel1Objects()
	{
		customers = new FlxTypedGroup<CustomerCar>();
		orderTable = new OrderTable(1000, 1000);

		add(customers);
		add(orderTable);
		for(i in 0...4)
		{
			conductor.createOrderEntire();
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

}
