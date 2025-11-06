package crowbar.objects;

import flixel.tile.FlxTilemap;
import flixel.math.FlxRect;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import crowbar.components.parsers.RoomParser;
import crowbar.objects.LoadingZone;
import crowbar.components.Interactable;
import crowbar.objects.EventTrigger;
import crowbar.components.Collision;

/*
    stores tilemap info from room files.
    try to limit this to just the grid stuff. i.e. the tilemaps, collision grid, and maybe other game objects like interactables on signs.
    probably best for some stuff like backgrounds, NPCs, etc. to go in the overworld state, somewhere organized
*/
class TiledRoom extends FlxTypedGroup<FlxObject>
{
    var parser:RoomParser;

    //all map visuals
    public var black:FlxSprite;
    public var background:FlxTypedGroup<TopDownSprite>; //drawn the lowest, fractional scroll factor
    public var tilemaps:FlxTypedGroup<CrowbarTilemap>;
    public var decals:FlxTypedGroup<TopDownSprite>; //regular decals with the same scroll factor as the tilemap
    public var foregroundTilemap:CrowbarTilemap;
    public var foregroundDecals:FlxTypedGroup<TopDownSprite>;

    //collision
    public var collisionGrid:CrowbarTilemap;

    //entities
    //NOTE: Loading zones and interactables were removed for the engine
    public var objects:FlxTypedGroup<TopDownSprite>;
    public var triggers:FlxTypedGroup<EventTrigger>;

    //the boundaries of the room
    public var roomBounds:FlxRect;

    public function new(roomName:String)
    {
        super();
        load(roomName);
    }

    public function load(roomName:String)
    {
        parser = new RoomParser(roomName);

        //add the collision grid before the sprites, i think black needs it to prevent null exception
        collisionGrid = parser.loadGridLayer("collision");
        add(collisionGrid);
        roomBounds = collisionGrid.getBounds();

        //sprite/tilemap setup
        black = new FlxSprite().makeGraphic(Std.int(roomBounds.width), Std.int(roomBounds.height), 0xFF000000);
        tilemaps = parser.loadAllTilemapLayers(["foreground"]);
        background = parser.loadDecalLayer(parser.getDecalLayerByName("Background"));
        decals = parser.loadDecalLayer(parser.getDecalLayerByName("Decals"));
            
        foregroundTilemap = parser.initializeTilemap(parser.getTileLayerByName("foreground"));
        foregroundDecals = parser.loadDecalLayer(parser.getDecalLayerByName("Foreground"));

        //add the black backdrop
        //add(black);

        objects = new FlxTypedGroup<TopDownSprite>();
        var objData:Array<EntityData> = parser.getEntitiesByLayerName("objects");
        for(t in objData)
        {
            var newObj:TopDownSprite = new TopDownSprite(
                t.x,
                t.y
            );
            objects.add(newObj);
            add(newObj);
        }

        //loads all event triggers
        triggers = new FlxTypedGroup<EventTrigger>();
        var triggerData:Array<EntityData> = parser.getEntitiesByName("EventTrigger");
        for(t in triggerData)
        {
            var newTrig:EventTrigger = new EventTrigger(
                t.x,
                t.y,
                t.width,
                t.height,
                t.values.script,
                t.values.isButton,
                t.values.useCount
            );
            triggers.add(newTrig);
            add(newTrig);
        }
    }

    override public function destroy()
    {
        super.destroy();
    }
}