package crowbar.components;

import flixel.FlxObject;
import crowbar.objects.TopDownCharacter;

//parent class; mainly specify the structure here
class MoveComponent
{
    public var parent:FlxObject;
    public var controller:CharacterController;

    public var priority:Int = 0; //determines when a move component will be called
    public var enabled:Bool = true; //disabling this cancels movement behavior

    public function new(controller:CharacterController)
    {
        this.controller = controller;
    }

    public function update(elapsed:Float)
    {

    }

    public function controlInput()
    {

    }

    /*
    Adds an action to the list in the character controller. the highest priority one is animated.
    */
    public function addAction()
    {

    }
}