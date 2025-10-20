package crowbar.ui;

import crowbar.display.CrowbarSprite;
import flixel.group.FlxSpriteGroup;

class Alphabet extends FlxSpriteGroup
{
	public var textSize:Float;

	public var paused:Bool = false;

	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;
	var lastWasSpace:Bool = false;

	var splitWords:Array<String> = [];

	public function new(x:Float, y:Float, text:String = "", ?textSize:Float = 1)
	{
		super(x, y);

		this.text = text;
	}

    public function createText(text:String)
    {
		
    }

    //recommended for text where the character limit remains the same, like timers
    public function updateText(text:String)
    {

    }

    function destroyText():Void
	{
		for (_sprite in _sprites.copy())
			_sprite.destroy();
		clear();
	}
	
}

class AlphaCharacter extends FlxSprite
{
	public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";

	public static var numbers:String = "1234567890";

	public static var symbols:String = "|~#$%()*+-:;<=>@[]^_.,'!?";

	public var row:Int = 0;

	private var textSize:Float = 1;

    private final framerate:Int = 12;

	public function new(x:Float, y:Float, ?textSize:Float = 1, ?graphic:String)
	{
		super(x, y);
		this.textSize = textSize;
		this.frames = AssetHelper.getAsset(graphic, ATLAS);

		antialiasing = true;
	}

    public function setCharacter(c:String)
    {
        if(alphabet.contains(c.toLowerCase()))
            createLetter(c);
        else if(numbers.contains(c))
            createNumber(c);
        else if(symbols.contains(c))
            createSymbol(c);
    }

	public function createBold(letter:String)
	{
		if (AlphaCharacter.alphabet.indexOf(letter.toLowerCase()) != -1)
		{
			// or just load regular text
			animation.addByPrefix(letter, letter.toUpperCase() + " bold", framerate);
			animation.play(letter);
			scale.set(textSize, textSize);
			updateHitbox();
		}
	}

	public function createLetter(letter:String):Void
	{
		var letterCase:String = "lowercase";
		if (letter.toLowerCase() != letter)
		{
			letterCase = 'capital';
		}

		animation.addByPrefix(letter, letter + " " + letterCase, framerate);
		animation.play(letter);
		scale.set(textSize, textSize);
		updateHitbox();

		FlxG.log.add('the row' + row);

		y = (110 - height);
		y += row * 50;
	}

	public function createNumber(letter:String):Void
	{
		animation.addByPrefix(letter, letter, 24);
		animation.play(letter);

		updateHitbox();
	}

	public function createSymbol(letter:String)
	{
		switch (letter)
		{
			case '.':
				animation.addByPrefix(letter, 'period', 24);
				animation.play(letter);
				setGraphicSize(8, 8);
				y += 48;
			case "'":
				animation.addByPrefix(letter, 'apostrophe', 24);
				animation.play(letter);
				setGraphicSize(10, 10);
				y += 20;
			case "?":
				animation.addByPrefix(letter, 'question', 24);
				animation.play(letter);
				setGraphicSize(20, 40);
				y += 16;
			case "!":
				animation.addByPrefix(letter, 'exclamation', 24);
				animation.play(letter);
				setGraphicSize(10, 40);
				y += 16;
			case ",":
				animation.addByPrefix(letter, 'comma', 24);
				animation.play(letter);
				setGraphicSize(10, 10);
				y += 48;
			default:
				animation.addByPrefix(letter, letter, 24);
				animation.play(letter);
		}

		updateHitbox();
	}
}