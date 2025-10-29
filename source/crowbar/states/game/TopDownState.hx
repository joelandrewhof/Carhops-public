package crowbar.states.game;

import haxe.ds.StringMap;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.FlxCamera;
import flixel.math.FlxRect;
import flixel.FlxObject;
import flixel.util.typeLimit.OneOfTwo;
import flixel.tile.FlxTilemap;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.util.FlxSort;
import flixel.system.ui.FlxSoundTray;
import flixel.tweens.FlxTween;
import flixel.FlxState;
import crowbar.display.CrowbarSprite;
import crowbar.components.parsers.RoomParser;
import crowbar.objects.*;
import crowbar.objects.TopDownCharacter;
import crowbar.objects.Player;
import crowbar.components.*;

import flixel.addons.display.FlxPieDial;

//parse the json from the ogmo export using AssetHelper.parseAsset ?

class TopDownState extends FlxState
{
    public static var current:TopDownState;

    public var curRoomName:String = "default_level";
    var spawnX:Int;
    var spawnY:Int;
    public var room:TiledRoom;
    public var player:Player;
    public var playerController:PlayerController;
    public var playerHitbox:PlayerHitbox;

    public var camGame:FlxCamera;
    public var camHUD:FlxCamera; //for dialogue, menus, transition screens, etc.
    public var camPoint:FlxObject;
    public var camBounds:FlxRect;
    public var camPlayerLock:Bool = true;
    public var camOffset:FlxPoint;
    public var cameraScale:Float = 1.0;

    //mainly for NPC parsing, i don't want NPCs in the room object but it makes sense to store them in the room file.
    public var roomParser:RoomParser;
    public var foregroundDecals:Array<FlxSprite>;
    public var foregroundTiles:FlxTilemap;

    //helpers
    public var visMngr:TopDownVisualManager;
    //outsources some of the complex object interaction bullshit like collision to a helper class
    public var actMngr:TopDownInteractionManager;
    public var soundMngr:SoundManager;

    //just to save some constants to reduce the math in update()
    var centerWidth = FlxG.width / 2;
    var centerHeight = FlxG.height / 2;

    var loadCallback:Void->Void;

    //such as not triggering a loading zone when spawning within one, and only triggering the transition once

    public function new(?room:String, ?x:Int, ?y:Int, ?callback:Void->Void)
    {
        super();
        curRoomName = room ?? "default_level";
        spawnX = x ?? 0;
        spawnY = y ?? 0;
        setLoadCallback(callback);

        persistentUpdate = true; //this should allow dialogue and stuff to NOT pause the game
    }

    override function create()
    {
        super.create();

        setupCameras();

        soundMngr = new SoundManager();

        current = this;

        load(curRoomName);
    }

    public function setupCameras()
    {
        //game camera
        camGame = new FlxCamera();
        camGame.zoom = cameraScale;
        camGame.followLerp = 0.2;

        camPoint = new FlxObject(0, 0);
        camOffset = new FlxPoint(0, 0);
        FlxG.cameras.reset(camGame);
        FlxG.cameras.setDefaultDrawTarget(camGame, true);
        camGame.follow(camPoint);

        //UI camera
        camHUD = new FlxCamera();
        camHUD.bgColor.alphaFloat = 0.0; //so we're not looking at a black screen
        FlxG.cameras.add(camHUD, false); //UI elements will need to be manually assigned to this camera with { object.cameras = [camHUD] }
    }

    public function updateCameras()
    {
        //update camera
        if(camPlayerLock)
            camPoint.setPosition(player.bottomCenter.x + camOffset.x, player.bottomCenter.y + camOffset.y);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        controlInputCall(elapsed); //checks for inputs
        debugInputCall();
        debugCall();

        playerHitbox.updatePosition();

        updateCameras();

        //managers
        visMngr.sortSprites();
        actMngr.update(elapsed);
    }

    function load(roomName:String, ?playerX:Float, ?playerY:Float = 0)
    {
        curRoomName = roomName;
        initiateManagers();
        roomParser = new RoomParser(curRoomName);

        loadSound(roomParser.getRoomValues().music, roomParser.getRoomValues().ambience);
        loadRoom(curRoomName);

        //if there's no spawn point override, load from the map default
        if(playerX == null) {
            var spawn = roomParser.getDefaultSpawn();
            if(spawn == null || spawn.length != 2) {
                trace("Warning: failed to retrieve default spawn location, defaulting to 0");
                spawn = [0, 0];
            }
            playerX = spawn[0];
            playerY = spawn[1];
        }

        loadPlayer(playerX, playerY);
        
        loadRoomVisuals();

        //add newly loaded objects to the managers for them to track
        actMngr.setupInteractables();

        setCameraBounds(0, 0); //honestly probably wont need bounds for my purposes, just ignoring for now.
        camGame.follow(camPoint);
        camPoint.setPosition(player.x + camOffset.x, player.y + camOffset.y);

        loadCallback();
        setLoadCallback(null); //makes this callback happen only once.
    }

    //sets up some of the manager classes that outsource labor to other classes
    function initiateManagers()
    {
        visMngr = new TopDownVisualManager();
        actMngr = new TopDownInteractionManager();

        this.add(visMngr);
    }

    function loadRoomVisuals()
    {
        if(visMngr == null)
            visMngr = new TopDownVisualManager();
        visMngr.addBackgroundObjects(room.background.members);
        visMngr.addTilemaps(room.tilemaps.members);
        visMngr.addForegroundObjects(room.foregroundDecals.members);
        visMngr.addForegroundObject(room.foregroundTilemap);

        //for(i in room.decals)
            //this.add(i);
        trace(room.decals);

        visMngr.addSprite(player);

        visMngr.addSprites(room.decals.members);
        visMngr.addSprites(room.objects.members);
        //reminder: the problem is not here, check tiledroom

        //visMngr.sortSprites();
        add(visMngr);
        add(room);
        trace("VIS MNGR SPRITE LENGTH: " + visMngr.owSprites.members.length);
    }

    inline function loadRoom(roomName:String)
    {
        room = new TiledRoom(roomName);
    }

    function loadSound(music:String, ambience:String)
    {
        soundMngr.updateMusic(music ?? "none");
        soundMngr.updateAmbience(ambience ?? "none");
        soundMngr.setMusicVolume(1.0);
        soundMngr.setAmbienceVolume(1.0);
    }

    /*
    *   Function that sets up the player class, using the default engine Player object.
    *   If you extend the player object, this function should be easy to overwrite.
    */
    function loadPlayer(x:Float, y:Float)
    {
        player = new Player("dummy", x, y);

        playerController = new PlayerController(player);
        //add movement components
        playerController.addMoveComponent(new WalkMovement(playerController));

        playerHitbox = new PlayerHitbox(player);
        add(playerHitbox);
    }

    function loadNPCs(roomName:String)
    {

    }

    public function setLoadCallback(func:Void->Void)
    {
        if(func != null)
            loadCallback = func;
        else
            loadCallback = function() {};
    }

    function setCameraBounds(?expandX:Float = 0, ?expandY:Float = 0)
    {
        //sets the rectangle bounds at which the camera will stop following clover
        //making expand positive will allow the camera to extend out of the room's range
        //making expand negative will stop the camera before the end side of the room
        camBounds = new FlxRect(
            room.roomBounds.left - expandX,
            room.roomBounds.top - expandY,
            room.roomBounds.width + expandX,
            room.roomBounds.height + expandY);

        //center the camera in small rooms
        if(camBounds.width < FlxG.width)
        {
            camBounds.left = camBounds.left + (camBounds.width * 0.5);
            camBounds.width = FlxG.width * 0.5;
        }
        if(camBounds.height < FlxG.height)
        {
            camBounds.top = camBounds.top + (camBounds.height * 0.5);
            camBounds.height = FlxG.height * 0.5;
        }
        //trace("camera bounds are: " + camBounds.left + ", " + camBounds.top + " | " + camBounds.right + ", " + camBounds.bottom);

        camGame.setScrollBoundsRect(camBounds.left, camBounds.top, camBounds.width, camBounds.height);
    }

    function controlInputCall(elapsed:Float)
    {
        //an update() function. poopshitters checked for input in the player object in order to move it but I think i should do that here.
        //i think this is necessary to prevent janky collision, and is cleaner anyways.

        /* ----------------------------------------------------
        ---                    MOVEMENT                     ---
        -----------------------------------------------------*/

        playerController.update(elapsed);

        /* ----------------------------------------------------
        ---                   ACTION KEYS                   ---
        -----------------------------------------------------*/


        /* ----------------------------------------------------
        ---                      ESCAPE                     ---
        -----------------------------------------------------*/
    }
    
    private function debugInputCall()
    {
        

    }

    private function debugCall()
    {
        //trace("objects in room: " + room.objects.length);
        //trace(player.direction.getDirString());
    }

    public function triggersCheck()
    {
        room.triggers.forEach(function(t:EventTrigger)
        {
            if(t.enabled && t.checkOverlap(playerHitbox)) //if the trigger is active and you're inside of it
            {
                if(!t.isButton || Controls.ACCEPT) //if it's not a button, or if it is, you're pressing ACCEPT
                {
                    t.callScript();
                    return;
                }
                //otherwise, this is a button trigger, and you're not pressing ACCEPT
            }
        });
    }

    public function tweenCameraOffset(x:Int, y:Int, time:Float)
    {
        FlxTween.cancelTweensOf(camOffset);
        FlxTween.tween(camOffset, {x: x, y: y}, time);
    }

    public function npcControllerUpdate(elapsed:Float)
    {

    }

    public function nextRoomTransition(roomName:String, playerX:Float, playerY:Float)
    {
        var blackScreen:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        blackScreen.cameras = [camHUD];
        blackScreen.alpha = 0.0;
        add(blackScreen);

        FlxTween.tween(blackScreen, {alpha: 1.0}, 0.5 / 2, {
            onComplete: function(twn:FlxTween)
                {
                    roomCleanup();
                    load(roomName, playerX, playerY);
                    FlxTween.tween(blackScreen, {alpha: 0.0}, 0.5 / 2);
                }
        });
    }

    public function roomCleanup()
    {
        //destroys stuff and resets groups for the next room
        room.destroy();

        var i:Int = 0;
		while (i != visMngr.members.length) {
			visMngr.members[i].destroy();
			i++;
		}

        visMngr.clear();
        visMngr.destroy();
    }

    override function closeSubState():Void
    {
        //for allowing movement after dialogue boxes for now; may need to change
        if(player != null)
        {
            setLockAllInput(false);
        }
        super.closeSubState();
    }

    public function setLockAllInput(locked:Bool = true)
    {
        setLockMoveInput(locked);
        setLockActionInput(locked);
    }

    public function setLockMoveInput(locked:Bool = true)
    {
        player.lockMoveInput = locked;
    }

    public function setLockActionInput(locked:Bool = true)
    {
        player.lockActionInput = locked;
    }

    public function returnToMenu()
    {
        
    }

    public function warp(room:String, x:Int, y:Int)
    {
        roomCleanup();
        load(room, x, y);
        FlxG.sound.play(AssetHelper.getAsset('audio/sfx/engine/bip', SOUND));
    }
}

class TopDownVisualManager extends FlxTypedGroup<FlxBasic>
{
    //so this order: background tiles/decals, tiles (in layer order), sprites, foreground tiles/decals

    //only visible sprite objects should go here
    public var room:TiledRoom;
    public var owSprites:FlxTypedGroup<TopDownSprite>;
    public var owTilemaps:FlxTypedGroup<CrowbarTilemap>;
    //to prevent a ton of unnecessary array sorting each frame, probably best to separate into layers
    public var background:FlxTypedGroup<Dynamic>;
    public var foreground:FlxTypedGroup<Dynamic>;

    public function new()
    {
        super();
        owSprites = new FlxTypedGroup<TopDownSprite>();
        owTilemaps = new FlxTypedGroup<CrowbarTilemap>();
        background = new FlxTypedGroup<Dynamic>();
        foreground = new FlxTypedGroup<Dynamic>();
        //this is the layer order:
        this.add(background);
        this.add(owTilemaps);
        this.add(owSprites);
        this.add(foreground);
    }

    public function addSprite(sprite:TopDownSprite)
    {
        owSprites.add(sprite);
    }

    //NOTE: giving an Array<Parent> type an Array<Child> DOES NOT REGISTER the child class
    //don't use this except for locally and for actual non-child overworldsprites for now
    public function addSprites(sprites:Array<TopDownSprite>)
    {
        if(sprites == null) return;
        for(i in 0...sprites.length)
            addSprite(sprites[i]);
    }

    public function sortSprites():FlxTypedGroup<TopDownSprite>
    {
        owSprites.members.sort((a:TopDownSprite, b:TopDownSprite) -> 
            FlxSort.byValues(FlxSort.ASCENDING, (a.worldHeight), (b.worldHeight)));

        return owSprites;
    }

    public function addTilemap(tilemap:CrowbarTilemap)
    {
        owTilemaps.add(tilemap);
    }

    public function addTilemaps(tilemaps:Array<CrowbarTilemap>)
    {
        if(tilemaps == null) return;
        for(i in 0...tilemaps.length)
            addTilemap(tilemaps[i]);
    }

    //most likely an unnecessary function; just use what the parser gives
    public function sortTilemaps():FlxTypedGroup<CrowbarTilemap>
    {
        owTilemaps.members.sort((a:CrowbarTilemap, b:CrowbarTilemap) -> 
        FlxSort.byValues(FlxSort.ASCENDING, (a.drawHeight), (b.drawHeight)));

        return owTilemaps;
    }

    //NOTE: these functions use dynamic to get fields from both Tilemaps and Sprites
    //fix later, probably an unstable solution long-term

    public function addBackgroundObject(obj:Dynamic)
    {
        background.add(obj);
    }

    public function addBackgroundObjects(objs:Array<Dynamic>)
    {
        for(i in 0...objs.length)
            addBackgroundObject(objs[i]);
    }

    public function sortBackground():FlxTypedGroup<Dynamic>
    {
        background.members.sort((a:Dynamic, b:Dynamic) -> 
            FlxSort.byValues(FlxSort.ASCENDING, (a.drawHeight), (b.drawHeight)));

        return background;
    }

    public function addForegroundObject(obj:Dynamic)
    {
        foreground.add(obj);
    }

    public function addForegroundObjects(objs:Array<Dynamic>)
    {
        for(i in 0...objs.length)
            addForegroundObject(objs[i]);
    }

    public function sortForeground():FlxTypedGroup<Dynamic>
    {
        foreground.members.sort((a:Dynamic, b:Dynamic) -> 
            FlxSort.byValues(FlxSort.ASCENDING, (a.drawHeight), (b.drawHeight)));

        return foreground;
    }
}
