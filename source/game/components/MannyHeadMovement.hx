package game.components;

import crowbar.objects.TopDownCharacter.CharacterController;
import game.objects.Manny;
import crowbar.components.MoveComponent;
import flixel.FlxObject;
import flixel.math.FlxVelocity;
import flixel.math.FlxPoint;
import flixel.math.FlxAngle;

class MannyHeadMovement extends MoveComponent
{
    public var manny:Manny;
    public var chaseTarget:FlxObject;

    public var speed:Float;
    public var pursue:Bool = true;

    public final topSpeedGain:Float = 10.0;
    public final minSpeed:Float = 0.4;
    public final easeValue:Float = 0.8;

    public function new(controller:CharacterController, manny:Manny)
    {
        super(controller);
        this.manny = manny;
        chaseTarget = PlayState.current.playerHitbox;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        updateSpeed(manny.stateManager.rage);
        chase(chaseTarget);
    }

    public function updateSpeed(rage:Float)
    {
        speed = minSpeed + (Math.pow(rage, easeValue) * topSpeedGain);
    }

    public function chase(object:FlxObject) //make it an object in case manny chases other things (decoys)
    {
        var targetCoords:FlxPoint = new FlxPoint(object.x + (object.width * 0.5), object.y + (object.height * 0.5));
        manny.head.faceTowards(targetCoords.x, targetCoords.y);

        var xDif = targetCoords.x - (manny.head.x + (manny.head.width * 0.5));
        var yDif = targetCoords.y - (manny.head.y + (manny.head.height * 0.5));
        var angle = FlxAngle.angleFromOrigin(xDif, yDif, false);

        manny.head.x += Math.cos(angle) * speed;
        manny.head.y += Math.sin(angle) * speed;

        trace('ANGLE: ${angle}');
    }
}