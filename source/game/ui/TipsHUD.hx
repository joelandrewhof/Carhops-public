package game.ui;

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

    public function new(x:Int, y:Int)
    {
        super(x, y);

        base = new CrowbarSprite(0, 0, "images/ui/tips_base");
        add(base);

        dollar = new CrowbarSprite(90, 15, "images/ui/tips_dollar");
        add(dollar);

        tipText = new CrowbarSprite(-10, 70, "images/ui/tips_text");
        add(tipText);

        decimalPoint = new CrowbarSprite(240, 35, "images/ui/tips_num_decimal");
        add(decimalPoint);

        numWhole = new NumberGroup(150, 0, "tips_num_big", 0);
        numWhole.numberSkew = 10;
        numWhole.numberSpacing = -5;
        add(numWhole);

        numDec = new NumberGroup(Std.int(decimalPoint.x) - 30, 5, "tips_num_small", 0);
        numDec.minimumLength = 2;
        numDec.numberSkew = 4;
        numDec.numberSpacing = -3;
        add(numDec);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        updateNumbers();
    }

    public function updateNumbers()
    {
        if(numWhole.setNumbers(Math.floor(Score.score / 100)) || 
            numDec.setNumbers(Score.score % 100)) {
                updatePositions();
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

        numWhole.x = this.x + 150;
        numWhole.y = this.y + 0;
        numWhole.updateNumbers();

        decimalPoint.x = numWhole.getLast().x + 85;
        decimalPoint.y = numWhole.getLast().y + 35;

        numDec.x = decimalPoint.x + 10;
        numDec.y = decimalPoint.y - 30;


    }
}