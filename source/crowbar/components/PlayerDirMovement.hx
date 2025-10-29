package crowbar.components;

import crowbar.components.MoveComponent;
import crowbar.objects.TopDownCharacter;
import crowbar.components.Directional;

class PlayerDirMovement extends MoveComponent
{

    public function new(controller:CharacterController)
    {
        super(controller);
        name = "PlayerDirMovement";
        priority = 1000;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        updateMovingInput();
    }

    public function updateMovingInput()
    {
        var hor:String = DirectionString.NONE;
        var ver:String = DirectionString.NONE;

        if(enabled)
        {
            if (Controls.UP && !Controls.DOWN) //up
                ver = DirectionString.NORTH;
            if (Controls.DOWN && !Controls.UP) //down
                ver = DirectionString.SOUTH;
            if (Controls.LEFT && !Controls.RIGHT) //left
                hor = DirectionString.WEST;
            if (Controls.RIGHT && !Controls.LEFT) //right
                hor = DirectionString.EAST;
        }
        controller.setMoving(hor, ver);
    }
}