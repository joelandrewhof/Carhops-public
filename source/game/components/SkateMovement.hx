package game.components;

import crowbar.components.MoveComponent;
import crowbar.objects.TopDownCharacter;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class SkateMovement extends MoveComponent
{
    public final baseFriction:Float = 0.995; //default when moving forward on normal terrain

    public final kickCooldownBase:Float = 0.3; //cooldown to fully recharge the kick without the added exponent
    public final kickCooldownExp:Float = 2.0; //these exponents make kicking work best when done rhythmically
    public final kickStaminaExp:Float = 1.4; 
    public final kickStaminaMax:Float = 100;
    public final kickStaminaDrain:Float = 0;
    
    public final maxMomentum:Float = 20.0;

    public var xMomentum:Float = 0.0;
    public var yMomentum:Float = 0.0;
    public var frameMomentum:Float = 0.0; //calculated per frame and distributed to actual momentum after
    public var kickPower:Float = 0.07;
    public var kickStamina:Float = 100;
    public var curFriction:Float;
    //these variables subtract from the current friction value.
    var backwardsPenalty = 0.02;
    var diagonalPenalty = 0.03;
    var perpendicularPenalty = 0.30;
    var turnStrengthArray = [1.0, 0.99, 0.60, 0.75, 0.40];

    public var timeWithoutKick:Float = 0.0;
    public var skidTween:FlxTween;
    public var skidTime:Float = 0.5;
    public var skidFriction:Float = 0.83;

    //for turning
    public var curDir:Int;
    public var lastDir:Int;

    public function new(controller:CharacterController)
    {
        super(controller);
        name = "SkateMovement";
        priority = 100;

        curFriction = baseFriction;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        curDir = controller.character.direction.index;

        if(Controls.RUN)
        {
            if(kickStamina < 0 || kickStamina < 20 && timeWithoutKick != 0) //short cooldown for an exhaustive kick
            {}
            else
            {
                timeWithoutKick = 0.0;
                kickTick(elapsed);
            }
        }
        else
        {
            timeWithoutKick += elapsed;
            //recoverStaminaTick(elapsed);
        }

        //turning
        if(lastDir != curDir) {
            if(Math.abs(lastDir - curDir) % controller.character.direction.div == Std.int(controller.character.direction.div * 0.5)) {
                skid();
            }
            else 
                turn(lastDir - curDir);
        }

        //add momentum to movement no matter what
        controller.requestMoveX += xMomentum;
        controller.requestMoveY += yMomentum;

        directionalFrictionTick();

        lastDir = controller.character.direction.index;
    }

    override function onCollide(?x:Bool, ?y:Bool)
    {
        super.onCollide(x, y);

        if(x == null) return;
        else if(y == null) { //if only one parameter is given just use it for both
            y = x;
        }

        if(x) xMomentum = 0;
        if(y) yMomentum = 0;
    }

    public function kickTick(elapsed:Float)
    {
        //calculate the momentum this frame
        var fm = kickMathTick(elapsed);
        //distribute it
        distributeMomentum(fm, controller.character.direction.index, controller.character.direction.div);

        kickStamina -= kickStaminaDrain; //drains linear
        if(kickStamina < 0) kickStamina = 0;
    }

    public function kickMathTick(elapsed:Float):Float
    {
        var add = (Math.pow(kickStamina, kickStaminaExp) * 0.01) * kickPower;
        
        return add;
    }

    public function distributeMomentum(flatMomentum:Float, dir:Int, ?div:Int = 8)
    {
        var ary = directionToMoveCalc();
        xMomentum += flatMomentum * ary[0];
        yMomentum += flatMomentum * ary[1];
    }

    public function recoverStaminaTick(elapsed:Float)
    {
        if(kickStamina < 100) {
            kickStamina += (elapsed / kickCooldownBase) + (Math.pow(timeWithoutKick / kickCooldownBase, kickCooldownExp)); //recharges exponentially
        }

        if(kickStamina > 100) kickStamina = 100;
    }

    //turn this into something that applies friction more heavily on the directions youre not facing?
    public function turn(dif:Int)
    {
        if(dif == 0) return;

        dif = Std.int(Math.abs(dif));

        if(dif % 8 > 4) //5-8
        {
            dif -= ((dif % 4) * 2); //[5 - 2 = 3] [6 - 4 = 2] [7 - 6 = 1]
        }

        momentumTurnConvert(curDir, turnStrengthArray[dif]);
    }

    public function skid()
    {
        curFriction = skidFriction;
        skidTween = FlxTween.tween(this, {curFriction: baseFriction}, skidTime, {
            ease: FlxEase.sineIn
        });
    }

    public function directionToMoveCalc(?dir:Int):Array<Float>
    {
        if(dir == null)
            dir = controller.character.direction.index;
        //commenting out for performance, but this only works with 8dir characters like this
        //dir *= Std.int(8 / controller.character.direction.div);

        var addX:Float = 0;
        var addY:Float = 0;
        if(dir % 2 == 1) //if dir is odd (diagonal)
        {
            addX = 0.707;
            addY = 0.707;

            if(dir == 1 ||dir == 7) addY = -addY;
            if(dir == 5 ||dir == 7) addX = -addX;

        }
        else 
        {   //dont overthink it
            if (dir == 2) addX = 1;
            else if (dir == 4) addY = 1;
            else if (dir == 6) addX = -1;
            else if (dir == 0) addY = -1;
        }

        return [addX, addY];
    }

    /*
    *   A more in-depth friction system that applies more friction to the direction the player is adjacent to.
    */
    public function directionalFrictionTick()
    {
        var ary = directionToMoveCalc();

        for(z in ary) {
            z = Std.int(z);
        }

        var dx = xMomentum;
        var dy = yMomentum;

        var xPenal:Float = 0;
        var yPenal:Float = 0;

        var bx = compare(Math.abs(dx + ary[0]), dx);
        var by = compare(Math.abs(dy + ary[1]), dy);

        if(curDir == 2 || curDir == 6)
        {
            if(bx == -1) {
                xPenal += backwardsPenalty;
            }
            //all Y movement is perpendicular
            yPenal += perpendicularPenalty;
        }
        else if(curDir == 0 || curDir == 4)
        {
            if(by == -1) { //opposite signs
                yPenal += backwardsPenalty;
            }
            //all x movement is perpendicular
            xPenal += perpendicularPenalty;
        }
        else
        {
            var i = 0;
            //0 = backwards, 1 = perp, 2 = forwards
            if(bx == 1) i++;
            if(by == 1) i++;

            if(i == 1) {
                xPenal += perpendicularPenalty;
                yPenal += perpendicularPenalty;
            }
            else if(i == 0) {
                xPenal += backwardsPenalty;
                yPenal += backwardsPenalty;
            }
        }

        //prevent negative friction
        dx *= Math.max(curFriction - xPenal, 0);
        dy *= Math.max(curFriction - yPenal, 0);
        xMomentum = dx;
        yMomentum = dy;
    }

    public function roughFrictionTick()
    {
        //cause the player to fully stop if NOT inputting move
        //might want to expand on controlls affecting momentum later
        if(!Controls.RUN)
        {
            if(Math.abs(xMomentum) < 0.2)
            {
                xMomentum = 0;
            }
            if(Math.abs(yMomentum) < 0.2)
            {
                yMomentum = 0;
            }
                
        }
        xMomentum *= curFriction;
        yMomentum *= curFriction;
    }

    private function compare(a:Float, b:Float):Int
    {
        if(a>b) return 1;
        else if(a<b) return -1;
        else return 0;
    }

    //Merges xMomentum and yMomentum and returns a flattened value.
    private inline function flattenMomentum():Float
    {
        return Math.sqrt(Math.abs(xMomentum * xMomentum) + Math.abs(yMomentum * yMomentum));
    }


    private function momentumTurnConvert(newDir:Int, ?strength:Float = 1.0)
    {
        var n = flattenMomentum() * strength;
        xMomentum *= (1 - strength);
        yMomentum *= (1 - strength);
        var ary = directionToMoveCalc(newDir);

        xMomentum += (n * ary[0]);
        yMomentum += (n * ary[1]);
    }

}