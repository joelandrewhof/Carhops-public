package game.components;

import game.objects.Order;

class Score
{
    public static var score:Int = 0;
    public static var combo:Int = 0;
    public static var streak:Int = 0;
    public static var comboTime:Float = 0.0;

    public static final maxComboTime:Float = 1.0;
    public static final baseTipAmount:Float = 0.20;
    public static final comboExponent:Float = 1.2;
    public static final streakMultiplier:Float = 4;
    public static final streakFalloff:Int = 50;

    public static function addScore(base:Int)
    {
        score += base;
    }

    public static function clearActive()
    {
        score = 0;
    }

    //calculates a score to add from the base cost.
    public static function doScoreCalculation(order:Order):Int
    {
        var tipPercent:Float = baseTipAmount; //later, might want to add different base amounts depending on different types of customers
        tipPercent *= (Math.pow(comboExponent, combo)); //combo bonus
        //each second over a quarter provides a small bonus; each second over half provides a greater bonus
        var timeBonus:Float = Math.max(0, (order.patience - (order.basePatience * 0.25)) * 5);
        if(order.patience > order.basePatience * 0.5)
            timeBonus += ((order.patience - (order.basePatience * 0.5) + 10) * 10);

        var streakBonus:Int = Math.floor((streak * streakMultiplier) + (Math.max(streak, streakFalloff) * streakMultiplier) * 0.5);

        var tip:Int = Math.ceil(((order.cost + timeBonus) * tipPercent) + streakBonus);
        addScore(tip);
        return tip;
    }

    public static function addCombo()
    {
        combo++;
        fillComboTime();
    }

    public static function breakCombo()
    {
        combo = 0;
    }

    public static function fillComboTime()
    {
        comboTime = maxComboTime;
    }

}