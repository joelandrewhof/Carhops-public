package game.components;

import yaml.schema.SafeSchema;
import game.objects.Order;

class Score
{
    public static var score:Int = 0;
    public static var combo:Int = 0;
    public static var streak:Int = 0;
    public static var comboTime:Float = 0.0;

    public static var streakBreaks:Int = 0;

    public static var doubles:Int = 0;
    public static var triples:Int = 0;
    public static var homeruns:Int = 0;

    public static var lastTimeBonus:Int = 0;
    public static var lastStreakBonus:Int = 0;


    public static final maxComboTime:Float = 1.8;
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
        //* COMBO BONUS *//
        tipPercent *= (Math.pow(comboExponent, combo));

        //* TIME BONUS *//
        var timeBonus:Float = Math.max(0, (order.patience - (order.basePatience * 0.25)) * 5); //remaining time over 25% is slightly rewarded
        if(order.patience > order.basePatience * 0.5) //remaining time over 50% is significantly rewarded, plus 100 points bonus
            timeBonus += ((order.patience - (order.basePatience * 0.5) + 10) * 10); 
        lastTimeBonus = Math.ceil(timeBonus);
        timeBonus = lastTimeBonus;

        //* STREAK BONUS *//
        var streakBonus:Int = Math.floor((streak * streakMultiplier) + (Math.max(streak, streakFalloff) * streakMultiplier) * 0.5);
        if(streak < 10)
            streakBonus = 0;
        lastStreakBonus = streakBonus;

        var tip:Int = Math.ceil(((order.cost + timeBonus) * tipPercent) + streakBonus);
        addScore(tip);
        return tip;
    }

    public static inline function addCombo() {
        combo++;
        fillComboTime();
    }

    public static inline function breakCombo() {
        switch combo {
            case 2:
                doubles++;
            case 3:
                triples++;
        }
        if(combo >= 4)
            homeruns++;
        combo = 0;
    }
    public static inline function addStreak() {
        streak++;
    }

    public static inline function breakStreak() {
        streak = 0;
        streakBreaks++;
    }

    public static inline function fillComboTime() {
        comboTime = maxComboTime;
    }

}

typedef OrderScore = {
    order:Int,
    stall:String,
    patience:Float,

}