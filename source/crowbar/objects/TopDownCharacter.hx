package crowbar.objects;

import haxe.atomic.AtomicBool;
import crowbar.states.game.TopDownState;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup;
import crowbar.display.CrowbarSprite;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import crowbar.components.Collision;
import crowbar.components.Directional;
import flixel.math.FlxAngle;
import crowbar.components.MoveComponent;


//some basic actions
enum abstract ActionType(String) to String{
    var IDLE = "idle";
    var WALK = "walk";
    var RUN = "run";
    var TALK = "talk";
}

typedef Action = 
{
    name:String,
    priority:Int
}

/*
    a generic dynamic class for overworld characters.
    players and NPCs both extend this class for its movement, collision, and sprite/animation functionalities.
*/

//create defined animation phrases later

class TopDownCharacter extends TopDownSprite
{
    //VARS
    public var characterName:String = "dummy";
    public var direction:Directional;
    public var playingSpecialAnim:Bool = false;
    //OBJECTS
    public var specialAnimTimer:FlxTimer;
    public var collision:Collision;
    //FINALS
    private final _subDir = "characters/";


    public function new(charName:String = "dummy", x:Float, y:Float, facing:String = "s")
    {
        super(x, y);
        characterName = charName;
        name = charName;
        direction = new Directional(); //set later

        //sprite stuff
        loadCharacterSprite(charName);
        direction.updateDiv(autoDirectionCheck());
        direction.updateDirFromString(facing);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        //bottom-centers the box. offset values can adjust this if the sprite size is a bit weird.
        collision.x = sprite.x + (sprite.width / 2) - (collision.width / 2) + collision.hbOffset.x;
        collision.y = sprite.y + (sprite.height - collision.height) + collision.hbOffset.y;
    }

    //some of this is copied code from the parent class, but im not changing it right now, dont want to break it.
    public function loadCharacterSprite(char:String):TopDownCharacter
    {
        this.characterName = char;

        var data = AssetHelper.parseAsset(_defaultDataDirectory + _subDir + characterName, YAML);
        if (data == null) {
            trace('OW Character ${characterName} could not be parsed due to a inexistent file, Please provide a file called "${characterName}.yaml" in the "data/characters directory.');
            return this;
        }

        loadSprite(_defaultSpriteDirectory + _subDir + data.spritesheet, true);
        //add animations
        var animations:Array<Dynamic> = data.animations ?? [];
        if (animations.length > 0) {
            for (i in animations) 
            {
                sprite.addAtlasAnim(i.name, i.prefix, i.fps ?? 12, i.loop ?? false, cast(i.indices ?? []));
            }
        }
        else
            sprite.addAtlasAnim("idle_s", "default_walk_s", 0, false, [0]);

        var hitbox:Dynamic = data.hitbox ?? {x: 0, y: 0, width: 0, height: 0};
        collision = new Collision(0, 0, hitbox.width, hitbox.height, hitbox.offsetX, hitbox.offsetY);
        collision.enableCollide = false;
        //bottom-centers the collision box
        collision.x = (this.width / 2) - (collision.width / 2);
        collision.y = (this.height - collision.height);

        return this;
    }

    //very non-dynamic but for characters specifically it will work fine
    private function autoDirectionCheck():Int
    {
        var list = sprite.animation.getNameList();
        return list.filter(list -> list.contains('idle_')).length;
    }

    public function playBasicAnimation(action:String = "idle", ?direction:String = "s", ?modifier:String = "")
    {
        //do not override a special animation
        if(playingSpecialAnim) 
            return;
        if(modifier != "") 
            modifier += "_";
        updateAnim(modifier + action + "_" + direction);
    }

    public function playSpecialAnimation(anim:String, ?cancelTime:Float = 0.0, ?cancelOnEnd:Bool = false)
    {
        if(updateAnim(anim))
        {
            playingSpecialAnim = true;
            if(cancelTime > 0.0)
            {
                specialAnimTimer = new FlxTimer().start(cancelTime, function(tmr:FlxTimer){ cancelSpecialAnimation(); });
            }
            else if(cancelOnEnd)
            {
                animation.finishCallback = function(name:String) {
                    if(name == anim) cancelSpecialAnimation();
                }
            }
        }
    }

    public function cancelSpecialAnimation()
    {
        playingSpecialAnim = false;
    }

    public function updateAnim(anim:String):Bool
    {
        //takes care of attempting to play a playing animation issue.
        //returns true if the animation was successfully changed.
        if(sprite.animation.exists(anim))
        {
            if(sprite.animation.name != anim)
            {
                sprite.animation.play(anim);
                return true;
                //trace('playing animation ${anim} on character ${characterName}');
            }
            else
            {
                //trace('note: animation ${anim} on character ${characterName} is already being played.');
                return false;
            }
        }
        else
        {
            //trace('ERROR: animation does not exist.');
            return false;
        }
    }

    public function faceTowards(x:Float, y:Float)
    {
        var xDif = x - this.bottomCenter.x;
        var yDif = y - this.bottomCenter.y;
        var slope = yDif / xDif;
        var angle = Math.atan(slope) * FlxAngle.TO_DEG;

        direction.updateDirFromDegrees(angle);
    }

    public function faceTowardsSpr(obj:TopDownSprite)
    {
        faceTowards(obj.bottomCenter.x, obj.bottomCenter.y);
    }
}

/*
    a controller that's similarly dynamic and multipurpose.
    used to move overworldcharacters (and children) and manipulate their animations.
    examples: player input to control Player.hx, followers constantly tracking the player, NPCs controlled during a cutscene
    you get the idea
*/

enum ScriptInput {
    ScriptInput(direction:String, running:Bool, time:Float);
}

class CharacterController
{
    public var character:TopDownCharacter; //the character to be controlled

    public var requestMoveX:Float = 0;
    public var requestMoveY:Float = 0;
    
    public var moveComponents:Array<MoveComponent>;
    public var actions:Array<Action>;

    public var paused:Bool = false;

    public var isMoving:Bool = false;
    public var movingX:Int = 0; //1: right, -1: left
    public var movingY:Int = 0; //1: down, -1: up
    public var slope:Float = 0; //will augment Y movement when moving X

    public var prevPosition:FlxPoint; 

    public var autoUpdateMove:Bool = true;
    
    private final _diagonal = 0.707; //diagonal movement speed for characters: [(sqrt 2) / 2]

    public function new(char:TopDownCharacter)
    {
        character = char;
        prevPosition = new FlxPoint(character.x, character.y);
        
        actions = new Array<Action>();
        moveComponents = new Array<MoveComponent>();
    }

    public function update(elapsed:Float)
    {
        if(!paused)
        {
            //clear previous actions
            actions = new Array<Action>();

            //sort priority
            moveComponents.sort(function(a, b) {
                if(a.priority > b.priority) return -1;
                else if(a.priority < b.priority) return 1;
                else return 0;
            });

            //Performs all movement actions from components
            for(comp in moveComponents)
            {
                comp.update(elapsed);
                comp.addAction();
            }

            if(autoUpdateMove)
            {
                move();
            }

            updateAnimation();
        }
    }

    public function addMoveComponent(comp:MoveComponent)
    {
        moveComponents.push(comp);
    }

    public function move(?noX:Bool = false, ?noY:Bool = false)
    {
        //move character based on moving vars
        prevPosition.set(character.x, character.y);

        character.x += noX ? 0 : requestMoveX;
        character.y += noY ? 0 : requestMoveY;

        requestMoveX = 0;
        requestMoveY = 0;
    }

    public function setMoving(horizontal:String = DirectionString.NONE, vertical:String = DirectionString.NONE)
    {
        switch (horizontal)
        {
            case DirectionString.WEST:
                movingX = -1;
            case DirectionString.EAST:
                movingX = 1;
            default:
                movingX = 0;
        }

        switch (vertical)
        {
            case DirectionString.NORTH:
                movingY = -1;
            case DirectionString.SOUTH:
                movingY = 1;
            default:
                movingY = 0;
        }

        //checks if we're currently moving based on these inputs
        isMoving = !(movingX == 0 && movingY == 0); 

        character.direction.updateDirFromInput(movingY, movingX);
    }

    public function setMovingFromInt(horizontal:Int = 0, vertical:Int = 0)
    {
        movingX = horizontal == 0 ? horizontal : FlxMath.signOf(horizontal);
        movingY = vertical == 0 ? vertical : FlxMath.signOf(vertical);

        //checks if we're currently moving based on these inputs
        isMoving = !(movingX == 0 && movingY == 0); 
    }

    public function setMovingFromPoint(point:FlxPoint)
    {
        setMovingFromInt(Std.int(point.x), Std.int(point.y));
    }

    public function previousPosition(?x:Bool = true, ?y:Bool = true)
    {
        if(x)
            character.x = prevPosition.x;
        if(y)
            character.y = prevPosition.y;
    }

    public function updateAnimation()
    {
        //add idle as an action
        addAction({name: IDLE, priority: 0});

        //highest priority (9999) first
        actions.sort(function(a, b) {
            if(a.priority > b.priority) return -1;
            else if(a.priority < b.priority) return 1;
            else return 0;
        });

        var priorityAction = actions[0].name;

        character.playBasicAnimation(priorityAction, character.direction.getDirString());
    }

    public function getCharacterName():String {
        return character.characterName;
    }

    public function addAction(action:Action)
    {
        actions.push(action);
    }

    public function getComponentByName(name:String):Dynamic
    {
        for(c in moveComponents)
        {
            trace(c.name);
            if(name == c.name)
            {
                return c;
            }
        }
        trace('ERROR: No component of this name found, returning null (component length: ${moveComponents.length})');
        return null;
    }
}