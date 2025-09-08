package;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;

class PlayState extends FlxState
{
	override public function create()
	{
		super.create();

		var hello:FlxText = new FlxText(0, 0, "Hello World", 48);
		hello.screenCenter();
		add(hello);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
