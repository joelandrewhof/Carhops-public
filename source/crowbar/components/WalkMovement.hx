package crowbar.components;

import crowbar.components.MoveComponent;
import crowbar.objects.TopDownCharacter;

class WalkMovement extends MoveComponent
{
    public var isRunning:Bool = false;
    public var walkSpeed:Float = 4.5;
    public var runSpeed:Float = 7.5;

    public final baseWalkSpeed:Float = 4.5;
    public final baseRunSpeed:Float = 7.5;
    private final _diagonal = 0.707; //diagonal movement speed for characters: [(sqrt 2) / 2]

    public function new(controller:CharacterController)
    {
        super(controller);
        name = "WalkMovement";
        priority = 500;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        setRunning(Controls.RUN);

        var req = calculateMove();
        controller.requestMoveX += req[0];
        controller.requestMoveY += req[1];
    }

    override function addAction()
    {
        super.addAction();

        var action:Action = {name: "idle", priority: 0};
        if(controller.isMoving)
            action = (isRunning ? 
                {name: "run", priority: 20,} : 
                {name: "walk", priority: 10});

        controller.addAction(action);
    }



    public function calculateMove():Array<Float>
    {
        var moveAmount = (isRunning ? runSpeed : walkSpeed); //move by the run speed if we're running
        if(controller.movingX != 0 && controller.movingY != 0) //if moving diagonally
            moveAmount *= _diagonal;
        //move sprite according to move direction
        //maybe it's inefficient to do all this multiplication shit each frame, but whatever. i want smooth movement
        var moveX = moveAmount * controller.movingX;
        var moveY = moveAmount * controller.movingY;
        //slope
        moveY -= (moveX * controller.slope);

        return [moveX, moveY];
    }

    public function setRunning(running:Bool)
    {
        isRunning = running;
    }

    public inline function setWalkSpeed(spd:Float) {
        walkSpeed = spd;
    }

    public inline function setRunSpeed(spd:Float) {
        runSpeed = spd;
    }

}