package crowbar.objects;

import flixel.tile.FlxTilemap;
import flixel.math.FlxRect;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import crowbar.components.parsers.RoomParser;
import crowbar.objects.LoadingZone;
import crowbar.objects.Interactable;
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
    public var loadingZones:FlxTypedGroup<LoadingZone>;
    public var interactables:FlxTypedGroup<Interactable>;
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
        
        //loads all loading zones/doorways
        loadingZones = new FlxTypedGroup<LoadingZone>();
        var loadZoneData:Array<EntityData> = parser.getEntitiesByName("LoadingZone");
        for (loadZone in loadZoneData)
        {
            var newZone:LoadingZone = new LoadingZone(
                loadZone.x, //this is for pixel scale shit
                loadZone.y,
                loadZone.width,
                loadZone.height,
                loadZone.values.toRoom,
                loadZone.values.toX,
                loadZone.values.toY
            );
            loadingZones.add(newZone);
            add(newZone);
        }
        //loads all interactables (stuff you can check)
        interactables = new FlxTypedGroup<Interactable>();
        var interactablesData:Array<EntityData> = parser.getEntitiesByName("Interactable");
        for(i in interactablesData)
        {
            var newInter:Interactable = new Interactable(
                i.x,
                i.y,
                i.width,
                i.height,
                i.values.dialogue
            );
            interactables.add(newInter);
            add(newInter);
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