package crowbar.ui;

import crowbar.display.CrowbarSprite;

class DigitSprite extends CrowbarSprite
{
    //for animations
	public var charToWordMap:Map<String, String> = [
		'0' => 'zero',
		'1' => 'one',
		'2' => 'two',
		'3' => 'three',
		'4' => 'four',
		'5' => 'five',
		'6' => 'six',
		'7' => 'seven',
		'8' => 'eight',
		'9' => 'nine',
		'%' => 'percent',
		'.' => 'decimal'
	];

	public var originX:Float = 0;
	public var originY:Float = 0;
	public var moveX:Float = 0;
	public var moveY:Float = 0;


	public function new(graphic:String, x:Float, y:Float)
	{
		super(x, y, graphic);
        this.frames = AssetHelper.getAsset(graphic, ATLAS); //you should have an atlas here, obviously
		//for tween effects
		originX = x;
		originY = y;


		var digit = charToWordMap[type];
		animation.addByPrefix(digit, digit, 0);
		animation.play(digit);
		setGraphicSize(Std.int(this.width * 3));
		if(digit == 'decimal')
			setGraphicSize(18);
		updateHitbox();
	}

    public function setDigit(d:Int)
    {
        
    }

    public function setDigitString(s:String)
    {

    }

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		//originally the position updating happened here but it needs to occur in the accuracyHUD class to use the position of the other sprites
	}

}
