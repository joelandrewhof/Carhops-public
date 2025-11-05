package crowbar.ui;

import crowbar.display.CrowbarText;
import crowbar.display.CrowbarSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;

class ScrollSelectionList extends FlxSpriteGroup
{
    public var selection:Int = 0;
    public var screenScroll:Int = 0;
    public var amountOnScreen:Int = 5;
    public var optionList:Array<ListOption>;

    public var optionSpacing:Int = 56;
    public var taper:Int = 0; //how gradually options fade transparent outside the target zone
    public var allowScroll:Bool = true;

    public final tweenTime:Float = 0.25;

    public function new(x:Float, y:Float)
    {
        super(x, y);
        optionList = new Array<ListOption>();
    }

    public function addOption(text:String, ?spr:String)
    {
        var l:Int = optionList.length;
        var opt:ListOption = new ListOption(x, y + Std.int(optionList.length * optionSpacing), text, spr);
        optionList.push(opt);

        this.add(optionList[l]);
        addToSelection(0);
    }

    public function addToSelection(add:Int):Int
    {
        return changeSelection(selection + add);
    }

    //maybe try to avoid using this a ton, like not as a constant update thing
    public function changeSelection(sel:Int):Int
    {
        if(sel < 0)
            sel = optionList.length - 1;
        if(sel > optionList.length - 1)
            sel = 0;

        selection = sel;
        hoverCheck();
        return selection;
    }

    /*
    *   Sets the hover and dehover values and duration on all options to the provided values.
    *   Use very sparingly, like only on loads, because this makes heavy use of Reflect functions.
    */
    public function setAllHoverFields(fields:Dynamic, ?duration:Float = 0.0)
    {
        for (o in optionList) {
            o.setHoverFields(fields);
            o.tweenDur = duration;
        }
    }

    public function hoverCheck()
    {
        if(!allowScroll)
            return;

        //update which one is highlighted
        for(i in 0...optionList.length)
        {
            optionList[i].onDehover();
        }
        optionList[selection].onHover();

        scroll();
    }

    public function getSel():ListOption
    {
        return optionList[selection];
    }

    public function scroll()
    {
        if(!allowScroll)
            return;

        var oldOOB = optionDistOOB(selection);

        //covering for the wrap-arounds: scroll should always immediately be set to the ends
        if(selection == 0)
        {
            screenScroll = 0;
        }
        else if(selection == optionList.length - 1)
        {
            screenScroll = optionList.length - amountOnScreen;
        }

        //otherwise, only move if shit gets out of range.
        screenScroll += optionDistOOB(selection);

        for(i in 0...optionList.length)
        {
            var alpha = 1.0 - (FlxMath.absInt(optionDistOOB(i)) / (FlxMath.absInt(taper) + 1)); //alpha determined by taper value and distance oob
            var dY = -oldOOB * optionSpacing; //move down or up by the spacing value
            optionList[i].startTween(dY, alpha, tweenTime);
        }
    }

    //will return negative if it's above screen, positive if it's below screen, and 0 if it's in bounds.
    private inline function optionDistOOB(option:Int):Int
    {
        var dif:Int;
        dif = option - screenScroll;
        if(dif < 0)
            return dif;
        if(dif > (amountOnScreen - 1))
            return dif - (amountOnScreen - 1);
        else return 0;
    }
}

//generic option from the list. perhaps can be childed for different types of options, for settings?
//like settings bools/enums with callbacks?
class ListOption extends FlxSpriteGroup
{
    public var text:CrowbarText;
    public var sprite:CrowbarSprite;
    public var tween:FlxTween;

    public var defaultSpritePath:String = "images/engine/menu_cursor.png";

    public var hoverTween:FlxTween;
    public var tweenHoverFields = {};
    public var tweenDehoverFields = {};
    public var tweenDur:Float = 0.0;

    private var targetPos:FlxPoint; //for tween cancelling
    private var targetAlpha:Float = 1.0;
    
    //for letting this object know when to update itself
    public var hovering:Bool = false;
    public var selected:Bool = false;
    private final textSpriteSpacing:Int = 70;

    //for updating
    public var hoverFields:Dynamic;
    public var defaultFields:Dynamic;

    public function new(x:Float = 0, y:Float = 0, ?txt:String = "", ?spr:String)
    {
        super();
        setSprite(spr);
        setText(txt);
        add(sprite);
        add(text);

        targetPos = new FlxPoint(x, y);
    }

    public function setText(?txt:String, ?font:String = "vcr", ?size:Int = 38)
    {
        text = new CrowbarText(Std.int(this.x), Std.int(this.y), 0, txt ?? this.text.text ?? "");
        text.setFont(font, size);
        text.updateHitbox();

        var hasSprite:Bool = !(sprite == null || sprite.width <= 0);
        text.x = (hasSprite ? sprite.x + textSpriteSpacing : 0);
        text.y = (hasSprite ? sprite.y + (sprite.height * 0.5) : 0) - (text.height * 0.5);
    }

    public function setSprite(graphic:String, ?resize:Float = 1.0)
    {
        sprite = new CrowbarSprite(this.x, this.y);
        if(graphic == null || graphic == "")
        {
            sprite.addGraphic(defaultSpritePath);
            sprite.antialiasing = false;
            sprite.scale.set(2.0, 2.0);
        }
        else
        {
            sprite.addGraphic(graphic);
            sprite.antialiasing = false;
            sprite.scale.set(resize, resize);
        }
        sprite.updateHitbox();

        sprite.x = this.x;
        sprite.y = this.y - (sprite.height * 0.5);
    }

    public function updatePosition()
    {
        //try just moving the entire group for now
    }

    public function onHover()    
    {
        hovering = true;
        if(hoverTween != null) {
            trace(tweenHoverFields);
            hoverTween = FlxTween.tween(this, tweenHoverFields, tweenDur);
            hoverTween.start();
        }
        sprite.visible = true;
    }

    public function onDehover()
    {
        hovering = false;
        if(hoverTween != null) {
            hoverTween = FlxTween.tween(this, tweenDehoverFields, tweenDur);
            hoverTween.start();
        }
        sprite.visible = false;
    }

    public function onSelect()
    {

    }

    //use this function sparingly, as it uses lots of Reflects
    public function setHoverFields(fields:Dynamic)
    {
        for(f in Reflect.fields(fields)) {
            if(Type.getInstanceFields(ListOption).contains(f)) {
                var oldF = Reflect.field(this, f);
                var newF = Reflect.field(fields, f);
                Reflect.setField(tweenDehoverFields, f, oldF); //sets the tweenDehover field based on the current value
                Reflect.setField(tweenHoverFields, f, newF); //sets the tweenHover field based on the parameter value
            }
        }
    }

    public function startTween(dY:Int = 0, ?alpha:Float = 1.0, ?time:Float = 0.25)
    {
        if(tween != null)
        {
            if(dY == 0 && alpha == targetAlpha) //optimization + stops tweens being awkwardly interrupted by scrolling too fast.
                return;
            else
                tween.cancel();
        }

        this.y = targetPos.y;
        this.alpha = targetAlpha;
        
        targetPos.y += dY;
        targetAlpha = alpha;
        
        tween = FlxTween.tween(this, {x: targetPos.x, y: targetPos.y, alpha: targetAlpha}, time, {ease: FlxEase.circOut});
    }
}