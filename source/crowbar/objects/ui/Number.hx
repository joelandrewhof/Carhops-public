package crowbar.objects.ui;

import crowbar.display.CrowbarSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxSort;

class NumberGroup extends FlxTypedSpriteGroup<Number>
{
    private var spritePath:String;
    private var sLength:Int = 0;
    public var number:Int;
    public var minimumLength:Int = 1; //useful for decimals. should always be at least 1.

    public var numberSpacing:Float = 0.0;
    public var numberSkew:Float = 0.0;

    public function new(x:Int, y:Int, file:String, ?number:Int = 0)
    {
        super(x, y);
        spritePath = file;
        this.number = number;
        updateNumbers();
    }

    public function updateNumbers()
    {
        sortNumbersOrder();

        while(numToString().length > members.length) //if we lack enough digit sprites, make more
        {
            appendNumber(numToString().charAt(members.length));
        }

        while(numToString().length < members.length)
        {
            destroyLast();
        }

        for(i in 0...members.length)
        {
            var oneFactor:Float = (members[i].animation.name == '1' ? 0.7 : 1.0);
            members[i].updateDigit(numToString().charAt(i));
            members[i].setOrigin((i > 0 ? members[i-1].originX + (members[i-1].width * oneFactor) : this.x) + numberSpacing,
                this.y + (numberSkew * i * oneFactor));
            members[i].updatePosition();
        }

    }

    public function sortNumbersOrder()
    {
        this.members.sort((a:Number, b:Number) -> 
        FlxSort.byValues(FlxSort.ASCENDING, (a.index), (b.index)));
    }

    public function appendNumber(num:String)
    {
        var n = new Number(0, 0, spritePath, '${num}', length);
        this.add(n);
        sLength++;
    }

    public function setNumbers(num:Int):Bool
    {
        if(num != number) //skip the update if the number is the same
        {
            this.number = num;
            updateNumbers();
            return true;
        }
        return false;
    }

    public function destroyLast()
    {
        var n:Number = getLast();
        this.remove(n, true);
        n.destroy(); //maybe get some recycling shit figured out later
        sLength--;
    }

    public function getLast():Number
    {
        return members[members.length - 1];
    }

    //please use this function instead of converting number directly, this accounts for minimum digit counts.
    public function numToString():String
    {
        var s:String = '$number';
        while(s.length < minimumLength) {
            s = "0" + s;
        }
        trace(s);
        return s;
    }
}

class Number extends CrowbarSprite
{
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
		'9' => 'nine'
	];

    public final _defaultPath:String = "images/ui/";

	public var missEffectTween:FlxTween;

	public var originX:Float = 0;
	public var originY:Float = 0;
	public var moveX:Float = 0;
	public var moveY:Float = 0;
    public var index:Int;

    public var autoUpdatePos:Bool = false;


	public function new(x:Float, y:Float, file:String, ?digit:String = '0', ?index:Int = 0)
	{
		//0, 0 instead of x, y because it's responding to the group's location upon construction.
		super(0, 0);
        loadSprite(_defaultPath + file, true);
		//x and y are instead used to store where the number should be updated to every frame
		originX = x;
		originY = y;

		var digit = charToWordMap[digit];
        for(c in charToWordMap.keys())
        {
            animation.addByPrefix(c, charToWordMap[c]);
        }
        animation.play(digit);

		updateHitbox();

        this.index = index;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
        if(autoUpdatePos) {
            updatePosition();
        }
	}

    public function updateDigit(digit:String)
    {
        animation.play('${digit}');
        updateHitbox();
        updatePosition();
    }

    public function updatePosition()
    {
        this.x = originX;
        this.y = originY;
    }

    public function setOrigin(x:Float, y:Float) {
        originX = x;
        originY = y;
    }

    //unused damage effect
	public function damageEffect(?duration:Float = 0.3, ?intensity:Float = 8)
	{
		var missColor:FlxColor = 0x9F0B21;

		//the reason we simply set values and not the position of the numbers themselves in this tween is because we need to CONSTANTLY check
		//even outside of the tween
		missEffectTween = FlxTween.num(intensity, 0, duration, {
			type: ONESHOT,
			ease: FlxEase.sineIn,
			onComplete: function(twn:FlxTween)
			{
				moveX = 0;
				moveY = 0;
				this.color = FlxColor.WHITE;
			}
		}, function(v)
			{
				var balls = FlxG.random.float(v);
				moveX = (FlxG.random.bool() ? balls : -balls);
				moveY = (FlxG.random.bool() ? (v - balls) : -(v - balls));
				
				this.color = FlxColor.interpolate(FlxColor.WHITE, missColor, (v / intensity));
			});
	}
}