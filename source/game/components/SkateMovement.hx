package game.components;

import crowbar.components.MoveComponent;
import crowbar.objects.TopDownCharacter;

class SkateMovement extends MoveComponent
{
    public final baseFriction:Float = 0.960; //default when moving forward on normal terrain

    public final kickCooldownBase:Float = 2.0; //cooldown to fully recharge the kick without the added exponent
    public final kickCooldownExp:Float = 1.7; //these exponents make kicking work best when done rhythmically
    public final kickStaminaExp:Float = 1.4; 
    public final kickStaminaMax:Float = 100;
    public final kickStaminaDrain:Float = 1.2;
    
    public final maxMomentum:Float = 20.0;

    public var xMomentum:Float = 0.0;
    public var yMomentum:Float = 0.0;
    public var frameMomentum:Float = 0.0; //calculated per frame and distributed to actual momentum after
    public var kickPower:Float = 0.2;
    public var kickStamina:Float = 100;
    public var curFriction:Float;

    public var timeWithoutKick:Float = 0.0;

    public function new(controller:CharacterController)
    {
        super(controller);

        priority = 100;

        curFriction = baseFriction;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        //trace("NO KICK: " + Std.int(timeWithoutKick * 100) * 0.01 + " | STAMINA: " + Std.int(kickStamina));

        if(Controls.RUN)
        {
            if(kickStamina < 0 || kickStamina < 20 && timeWithoutKick != 0) //short cooldown for an exhaustive kick
                return;

            timeWithoutKick = 0.0;

            kickTick(elapsed);
        }
        else
        {
            timeWithoutKick += elapsed;
            recoverStaminaTick(elapsed);
        }

        //add momentum to movement no matter what
        controller.requestMoveX += xMomentum;
        controller.requestMoveY += yMomentum;

        roughFrictionTick();
    }

    public function kickTick(elapsed:Float)
    {
        //calculate the momentum this frame
        var fm = kickMathTick(elapsed);
        //distribute it
        distributeMomentum(fm, controller.character.direction.index, controller.character.direction.div);

        kickStamina -= kickStaminaDrain; //drains linear
    }

    public function kickMathTick(elapsed:Float):Float
    {
        var add = (Math.pow(kickStamina, kickStaminaExp) * 0.01) * kickPower;
        
        return add;
    }

    public function distributeMomentum(flatMomentum:Float, dir:Int, ?div:Int = 8)
    {
        dir *= Std.int(8 / div);
        var addX:Float = 0;
        var addY:Float = 0;
        if(dir % 2 == 1) //if dir is odd (diagonal)
        {
            flatMomentum *= 0.707;
            addX = flatMomentum;
            addY = flatMomentum;

            if(dir == 1 ||dir == 7) addY = -addY;
            if(dir == 5 ||dir == 7) addX = -addX;

        }
        else 
        {   //dont overthink it
            if (dir == 2) addX = flatMomentum;
            if (dir == 4) addY = flatMomentum;
            if (dir == 6) addX = -flatMomentum;
            if (dir == 0) addY = -flatMomentum;
        }

        xMomentum += addX;
        yMomentum += addY;
    }

    public function recoverStaminaTick(elapsed:Float)
    {
        if(kickStamina < 100) {
            kickStamina += (elapsed / kickCooldownBase) + (Math.pow(timeWithoutKick, kickCooldownExp)); //recharges exponentially
        }
    }

    //turn this into something that applies friction more heavily on the directions youre not facing?
    public function turn(dif:Int)
    {
        if(dif > 4) 
            dif -= (dif - 4);
        //use the difference of direction (in eighths)
        var p = [1.0, 0.97, 0.90, 0.75, 0.40];
        var f = p[dif];

        //make separate x and y momentum and convert them differently when turning
    }

    public function roughFrictionTick()
    {
        if(xMomentum < 0.2)
            xMomentum = 0;
        if(yMomentum < 0.2)
            yMomentum = 0;
        xMomentum *= baseFriction;
        yMomentum *= baseFriction;
    }

}