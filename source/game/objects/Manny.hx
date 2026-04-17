package game.objects;

import game.components.MannyHeadMovement;
import game.components.MannyStateManager;
import crowbar.objects.TopDownCharacter;
import flixel.FlxBasic;

class Manny extends FlxBasic
{
    //this class contains the different game objects and information pertaining to manny

    public var stateManager:MannyStateManager;
    public var head:MannyHead;
    public var headController:CharacterController;

    public function new()
    {
        super();
        stateManager = new MannyStateManager(this);

        head = new MannyHead(500, 500);
        PlayState.current.add(head);

        headController = new CharacterController(head);
        headController.addMoveComponent(new MannyHeadMovement(headController, this));
        headController.paused = true; //pause by default
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        stateManager.update(elapsed);
        headController.update(elapsed);
    }
}