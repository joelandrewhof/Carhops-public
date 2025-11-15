package game.components;

import crowbar.components.MoveComponent;
import crowbar.objects.TopDownCharacter;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class CarMovement extends MoveComponent
{

    public var moveSpeed:Float = 0.0;
    public var acceleration:Float = 5.0;
    public final topSpeed:Float = 5.0;
    public var driving:Bool = false;
    public var friction:Float = 0.95;
    public var reversing:Bool = false;


    public function new(controller:CharacterController)
    {
        super(controller);
        name = "CarMovement";
        priority = 100;

    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(driving)
        {
            drive(elapsed, (reversing ? -1 : 1));
        }
        else {
            moveSpeed *= friction;
            if(moveSpeed <= 0.1)
                moveSpeed = 0;
        }
    }

    override function onCollide(?x:Bool, ?y:Bool)
    {
        super.onCollide(x, y);
    }

    override function addAction()
    {
        super.addAction();
    }

    public function startReverse()
    {
        driving = true;
        reversing = true;
    }

    public function drive(elapsed:Float, ?direction:Int = 1)
    {
        moveSpeed += acceleration * direction * elapsed;

        //note on diagonals the car is 30 degrees and moves twice more X than Y
        var ary = directionToMoveCalc();

        //converts to 30 degrees on the trig circle
        if(Math.abs(ary[0]) == 0.707)
            ary[0] = 0.886 * Math.round(ary[0]);
        if(Math.abs(ary[0]) == 0.707)
            ary[0] = 0.5 * Math.round(ary[0]);

        var dx = moveSpeed * ary[0];
        var dy = moveSpeed * ary[1];

        controller.requestMoveX += dx;
        controller.requestMoveY += dy;
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

}