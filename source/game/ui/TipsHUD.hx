package game.ui;

import flixel.math.FlxPoint;
import crowbar.display.CrowbarSprite;
import flixel.group.FlxSpriteGroup;
import crowbar.objects.ui.Number;
import game.components.Score;

class TipsHUD extends FlxSpriteGroup
{
    public var numWhole:NumberGroup;
    public var numDec:NumberGroup;

    public var tipText:CrowbarSprite;
    public var base:CrowbarSprite;
    public var dollar:CrowbarSprite;
    public var decimalPoint:CrowbarSprite;

    public var numTotal:NumberDecimalGroup;

    public var addBase:CrowbarSprite;
    public var addTotal:NumberDecimalGroup;

    public var recentPoints:Int;
    public var addDisplayTimer:Float = -10.0;
    private final addDisplayMaxTime:Float = 1.8;


    public function new(x:Int, y:Int)
    {
        super(x, y);

        base = new CrowbarSprite(0, 0, "images/ui/tips_base");
        add(base);

        dollar = new CrowbarSprite(90, 15, "images/ui/tips_dollar");
        add(dollar);

        tipText = new CrowbarSprite(-10, 70, "images/ui/tips_text");
        add(tipText);

        numTotal = new NumberDecimalGroup(150, 0, "tips_num", 0);
        numTotal.whole.numberSkew = 10;
        numTotal.whole.numberSpacing = 0.9;
        numTotal.decimal.minimumLength = 2;
        numTotal.decimal.numberSkew = 4;
        numTotal.decimal.numberSpacing = 0.9;
        numTotal.pointOffset = new FlxPoint(0, -40);
        numTotal.decimalOffset = new FlxPoint(-12, 5);
        add(numTotal);

        addBase = new CrowbarSprite(30, -60, "images/ui/tips_add_base");
        add(addBase);

        addTotal = new NumberDecimalGroup(90, -50, "tips_add", 0);
        addTotal.decimal.minimumLength = 2;
        add(addTotal);

        addBase.alpha = 0.0;
        addTotal.alpha = 0.0;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        addDisplayTimer -= elapsed;
        updateNumbers();

        if(addDisplayTimer <= 0) {
            recentPoints = 0;
            addTotal.alpha = (addDisplayTimer * 2) + 1;
            addBase.alpha = (addDisplayTimer * 2) + 1;
        }

        trace(addTotal.alpha);
    }

    public function addPoints(points:Int)
    {
        addDisplayTimer = addDisplayMaxTime;
        recentPoints += points;
        addTotal.alpha = 1.0;
        addBase.alpha = 1.0;
    }

    public function updateNumbers()
    {
        var f:Int = Std.int(numTotal.number * 100);
        if(numTotal.setNumbers(Score.score * 0.01)) {
            updatePositions();
            addPoints(Score.score - f);
        }
        if(recentPoints > 0 && addTotal.setNumbers(recentPoints * 0.01)) {
            addTotal.updatePositions();
        }
    }

    public function updatePositions()
    {
        base.x = this.x;
        base.y = this.y;

        dollar.x = this.x + 90;
        dollar.y = this.y + 15;

        tipText.x = this.x - 10;
        tipText.y = this.y + 70;

        numTotal.updatePositions();
        numTotal.updateNumbers();

        addTotal.updatePositions();
        addTotal.updateNumbers();
    }
}