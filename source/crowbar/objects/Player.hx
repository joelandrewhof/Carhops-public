package crowbar.objects;

import crowbar.components.PlayerDirMovement;
import crowbar.objects.TopDownCharacter.CharacterController;
import crowbar.states.game.TopDownState;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup;
import crowbar.display.CrowbarSprite;
import flixel.math.FlxMath;
import crowbar.components.TopDownUtil;

//private var controls(get, never):Controls;
//private function get_controls() return Controls.instance;
//UI controls should be the same as overworld controls

//thank you poopshitters

/*
    the player class. extends the overworldcharacter class.
    will probably contain more independent functionality later
    but its main distinction right now is the playerhitbox and having its controller hooked up to user input.
*/

class Player extends TopDownCharacter
{
    public var lockMoveInput:Bool = false;
    public var lockActionInput:Bool = false;

    public function new(characterName:String = "clover", x:Float, y:Float, facing:String = "down")
    {
        super(characterName, x, y, facing);
    }
}

class PlayerHitbox extends FlxSprite
{
    var player:Player;
    var playerOffset:Array<Float> = [0, 0];
    public var prevPosition:FlxPoint;

    public function new(player:Player)
    {
        super();
        alpha = 0.0;
        this.player = player;
        var halfHeight = Std.int(player.height / 2);
        makeGraphic(Std.int(player.width), halfHeight, 0x3800FF00);
        playerOffset = [0, halfHeight];

        prevPosition = new FlxPoint(x, y);
    }

    override function update(elapsed:Float)
    {
        //this is already run in the overworld update()
        //updatePosition();
    }

    public function updatePosition()
    {
        prevPosition.set(x, y);

        x = player.x + playerOffset[0];
        y = player.y + playerOffset[1];
    }


}

class PlayerController extends CharacterController
{
    public var playerMove:PlayerDirMovement; //for other classes to access

    public function new(player:Player)
    {
        super(player);

        playerMove = new PlayerDirMovement(this);
        autoUpdateMove = false;

        addMoveComponent(playerMove);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        //ROOM COLLISION MAP
        var dirCol = TopDownUtil.isPlayerTilemapCollideAfterMove(requestMoveX, requestMoveY);

        //if we can at least move in a direction
        if(!dirCol[0] || !dirCol[1])
        {
            move(dirCol[0], dirCol[1]);
        }

        requestMoveX = 0;
        requestMoveY = 0;
    }

}