package crowbar.components.parsers;

import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import funkin.components.parsers.*;
import flixel.tile.FlxTilemap;
import flixel.group.FlxGroup;
import flixel.util.FlxSort;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import crowbar.states.game.TopDownState;
import crowbar.objects.TopDownSprite;
import crowbar.objects.CrowbarTilemap;

class RoomParser extends FlxOgmo3Loader
{
    private final _defaultRoom:String = "default_level";

    // **FILEPATHS**
    public static final _defaultDecalDirectory:String = 'images/rooms/decals/';
    public static final _defaultTileDirectory:String = 'images/rooms/tile/';
    public static final _defaultRoomDirectory:String = "assets/data/rooms/";

    public function new(projectFile:String, roomFile:String)
    {
        super(_defaultRoomDirectory + projectFile, _defaultRoomDirectory + roomFile);
    }
    
    public function getRoomValues():Dynamic
    {
        return level.values;
    }

    public function getRoomValue(value:String):Dynamic
    {
        return getLevelValue(value);
    }

    public function loadAllTilemapLayers(?exclude:Array<String>):FlxTypedGroup<CrowbarTilemap>
    {
        //returns all tilemap layers from the json as tilemaps.
        //outside of creating them in the proper order, their distinctions are not really important because they're purely visual.
        //collision, entities, etc. are meant to be handled by grid layers and instance layers.
        //the exclude arg allows certain tilemap(s) to be excluded based on name; case insensitive. useful for layering.
        if(exclude == null) exclude = [];
        for(i in 0...exclude.length)
            exclude[i] = exclude[i].toLowerCase();

        var mapGroup:FlxTypedGroup<CrowbarTilemap> = new FlxTypedGroup<CrowbarTilemap>();
        //this reverse for-loop returns layers bottom to top, so the uppermost layers in the .json file are drawn on top.
        for(i in 0...level.layers.length)
        {
            var j = level.layers.length - 1 - i;
            if(Reflect.hasField(level.layers[j], "tileset") && !exclude.contains(level.layers[j].name.toLowerCase()))
            {

                mapGroup.add(initializeTilemap(cast level.layers[j]));
            }
        }
        return mapGroup;
    }

    //set includes to true in order to check if the layer includes the string rather than equals to it.
    public function getTileLayerByName(name:String = "", ?includes:Bool = false):TileLayer
    {
        var tl:TileLayer = null;
        for(i in 0...level.layers.length)
        {
            if(Reflect.hasField(level.layers[i], "tileset") && //if it's a tilemap
                Reflect.hasField(level.layers[i], "name")) //null safety for name field
            {
                if(level.layers[i].name.toLowerCase() == name.toLowerCase() || 
                    (includes && StringTools.contains(level.layers[i].name.toLowerCase(), name.toLowerCase())))
                {
                    tl = cast level.layers[i];
                    return tl;
                }
            }
        }
        return tl;
    }

    public function loadAllGridLayers():FlxTypedGroup<CrowbarTilemap>
    {
        var mapGroup:FlxTypedGroup<CrowbarTilemap> = new FlxTypedGroup<CrowbarTilemap>();
        for(i in 0...level.layers.length)
        {
            var j = level.layers.length - 1 - i;
            if(Reflect.hasField(level.layers[j], "grid"))
            {
                mapGroup.add(initializeTilemap(cast level.layers[j]));
            }
        }
        return mapGroup;
    }

    public function loadGridLayer(layerName:String):CrowbarTilemap
        {
            //loads a specific grid layer by name
            var map:CrowbarTilemap = new CrowbarTilemap();
            for(i in 0...level.layers.length)
            {
                var j = level.layers.length - 1 - i;
                if(Reflect.hasField(level.layers[j], "grid") && level.layers[j].name == layerName)
                {
                    map = initializeGridmap(cast level.layers[j]);
                }
            }
            return map;
        }

    //loading entities and retrieving entities are different
    public function loadAllEntities(callback:EntityData -> Void, ?layer:String = "entities")
    {
        for (entityLayer in getEntityLayers())
        {
            for (entity in entityLayer.entities)
                callback(entity);
        }
            
    }

    public function loadAllDecals(callback:DecalData -> Void, ?layer:String = "decals")
    {
        for (decalLayer in getDecalLayers())
        {
            for (decal in decalLayer.decals)
                callback(decal);
        }
            
    }

    //not sure if i really even need multiple entity layers... probably good to have this as a safecheck regardless.
    public function getEntityLayers():Array<EntityLayer>
    {
        //am i doing it right
        var entityLayers:Array<EntityLayer> = new Array<EntityLayer>();
        for(layer in level.layers)
        {
            if(Reflect.hasField(layer, "entities"))
            {
                entityLayers.push(cast layer);
            }
        }
        return entityLayers;
    }

    public function getEntityLayerByName(name:String):EntityLayer
    {
        for(layer in level.layers)
        {
            if(Reflect.hasField(layer, "entities") && layer.name == name)
            {
                return cast layer;
            }
        }
        return {
            name: "",
            _eid: "",
            offsetX: 0,
            offsetY: 0,
            gridCellWidth: 64,
            gridCellHeight: 64,
            gridCellsX: 1,
            gridCellsY: 1,
            entities: []
        };
    }

    public function getAllEntities(?ignoreTags:Bool = false):Array<EntityData>
    {
        //flattens all entity layers into one array of entitydatas and returns it
        var entityList:Array<EntityData> = new Array<EntityData>();
        var layers:Array<EntityLayer> = getEntityLayers();
        for(layer in layers)
        {
            for(entity in layer.entities)
            {
                if(ignoreTags) //only add if flags are met or we're just ignoring them
                entityList.push(cast entity);
            }
        }
        return entityList;
    }

    public function getEntitiesByLayerName(name:String):Array<EntityData>
    {
        var entityList:Array<EntityData> = new Array<EntityData>();
        var layer:EntityLayer = getEntityLayerByName(name);
        for(entity in layer.entities) {
            entityList.push(cast entity);
        }
        return entityList;
    }

    public function getEntitiesByName(name:String, ?additionalValueField:String):Array<EntityData>
    {
        // will return an array of all entities with the provided name, and with a certain value field if provided
        // good for parsing types of entities into arrays and spawning them (like all the loading zones in a room)
        var typedEntities:Array<EntityData> = new Array<EntityData>();
        var entities:Array<EntityData> = getAllEntities(); //retrieve the entities
        for(entity in entities)
        {
            if(Reflect.hasField(entity, "name") && entity.name == name)
            {
                //if no special value is specified, just push the entity.
                //if a special value IS specified, check if it's there and only push the entity if it is.
                if(additionalValueField != null)
                {
                    if(Reflect.hasField(entity.values, additionalValueField))
                    {
                        typedEntities.push(entity);
                    }
                }
                else
                {
                    typedEntities.push(entity);
                }
                
            }
        }
        return typedEntities;
    }

    //from what I understand, decals are just sections of a map that are untiled and use png assets
    //e.g. the first room in undertale
    public function getDecalLayers():Array<DecalLayer>
    {
        var decalLayers:Array<DecalLayer> = new Array<DecalLayer>();
        for(layer in level.layers)
        {
            if(Reflect.hasField(layer, "decals"))
            {
                decalLayers.push(cast layer);
            }
        }
        return decalLayers;
    }

    public function getAllDecals():Array<DecalData>
    {
        //flattens all decal layers into one array of decaldatas and returns it
        var decalList:Array<DecalData> = new Array<DecalData>();
        var layers:Array<DecalLayer> = getDecalLayers();
        for(layer in layers)
        {
            for(decal in layer.decals)
            {
                decalList.push(cast decal);
            }
        }
        return decalList;
    }

    public function getDecalLayerByName(name:String):DecalLayer
    {
        var decalLayer:DecalLayer = null;
        for(layer in level.layers)
        {
            if(Reflect.hasField(layer, "decals")) //if it's a decal layer
            {
                if(Reflect.hasField(layer, "name") && layer.name.toLowerCase() == name.toLowerCase()) //if its name is correct
                {
                    decalLayer = cast layer;
                }
            }
        }
        if(decalLayer == null) trace ("RoomParser 207: decalLayer is null");
        return decalLayer;
    }

    public function initializeTilemap(layer:TileLayer):CrowbarTilemap
    {
        if(!Reflect.hasField(layer, "tileset"))
        {
            trace("ERROR: layer is not a tilemap");
            return new CrowbarTilemap();
        }
        

        //NOTE: THE NAME OF THE TILESET IN OGMO HAS TO BE EXACTLY THE SAME AS THE TILESHEET FILE.
        var graphic = null;
        graphic = AssetHelper.getAsset(_defaultTileDirectory + layer.tileset, IMAGE);
        if(graphic == null) //backup
        {
            trace('WARNING: could not find tile graphic at ${_defaultTileDirectory + layer.tileset}');
            graphic = AssetHelper.getAsset('${_defaultTileDirectory}tile_default', IMAGE);
        }
            

        var tilemap:CrowbarTilemap = new CrowbarTilemap();

        tilemap.loadMapFromArray(
            layer.data,
            layer.gridCellsX,
            layer.gridCellsY,
            graphic,
            layer.gridCellWidth,
            layer.gridCellHeight
        );
        
        tilemap.antialiasing = false;

        return tilemap;
    }

    public function initializeGridmap(layer:GridLayer):CrowbarTilemap
    {
        if(!Reflect.hasField(layer, "grid"))
            {
                trace("ERROR: layer is not a gridmap");
                return new CrowbarTilemap();
            }
            
            var gridmap:CrowbarTilemap = new CrowbarTilemap();

            //kind of annoying that ogmo saves this as strings but whatever
            var csv:Array<Int> = new Array<Int>();
            for(i in layer.grid)
            {
                csv.push(Std.parseInt(i));
            }
            //and i guess you need a graphic too
            var graphic = AssetHelper.getAsset('${_defaultTileDirectory}empty_grid', IMAGE);
            //the loadMapFromCSV doesn't work but this one does... just don't question it
            //trace("CSV " + csv);
            //trace("LAYER " + layer);
            gridmap.loadMapFromArray(
                csv,
                layer.gridCellsX,
                layer.gridCellsY,
                graphic,
                layer.gridCellWidth
            );
            
            gridmap.antialiasing = false;
    
            return gridmap;
    }

    public function loadDecalLayerAdvanced(layer:DecalLayer):FlxTypedGroup<TopDownSprite>
    {
        var decalGrp:FlxTypedGroup<TopDownSprite> = new FlxTypedGroup<TopDownSprite>();

        for(i in 0...layer.decals.length)
            decalGrp.add(loadDecalAdvanced(layer.decals[i]));

        decalGrp.members.sort((a:TopDownSprite, b:TopDownSprite) -> 
        FlxSort.byValues(FlxSort.ASCENDING, (a.drawHeight), (b.drawHeight)));

        return decalGrp;
    }

    public function loadDecalAdvanced(decal:DecalData):TopDownSprite
    {
        //directory removal from ogmo formatting.
        var tex:String = decal.texture;
        if(tex.lastIndexOf("/") > -1)
            tex = tex.substr(tex.lastIndexOf("/") + 1);

        var dh:Int = 0; 
        if(Reflect.hasField(decal, "values") && Reflect.hasField(decal.values, "drawHeight"))
            dh = decal.values.drawHeight;
        var elv:Int = 0; 
        if(Reflect.hasField(decal, "values") && Reflect.hasField(decal.values, "elevation"))
            elv = decal.values.elevation;

        var sprite:TopDownSprite = new TopDownSprite(decal.x, decal.y, elv, DrawLayer.DEFAULT, dh);
        sprite.loadSprite(_defaultDecalDirectory + tex);


        //set anything relevant in the values field
        if(Reflect.hasField(decal, "values"))
        {
            //scrollFactor
            if((Reflect.hasField(decal.values, "scrollFactorX") && decal.values.scrollFactorX != null) &&
                (Reflect.hasField(decal.values, "scrollFactorY") && decal.values.scrollFactorY != null))
            {
                sprite.scrollFactor.set(decal.values.scrollFactorX, decal.values.scrollFactorY);
            }
            //animated. only do this stuff if the variable exists and is true.
            if(Reflect.hasField(decal.values, "animated") && decal.values.animated)
            {
                sprite.frames = AssetHelper.getAsset(_defaultDecalDirectory + tex, ATLAS);
                //not gonna make a very modular animation system for decals right now
                //if they have an animation, it plays on loop. that's it.
                sprite.animation.addByPrefix("anim", "anim", 
                    (Reflect.hasField(decal.values, "frameRate") && decal.values.frameRate != null) ?
                        decal.values.frameRate : 12, true);
            }
            //flipping
            if(Reflect.hasField(decal.values, "flipX"))
                sprite.flipX = decal.values.flipX; 
            if(Reflect.hasField(decal.values, "flipY"))
                sprite.flipY = decal.values.flipY; 
        }

        return sprite;
    }

    public function getDefaultSpawn():Array<Int>
    {
        return [level.values.defaultSpawnX ?? 0, level.values.defaultSpawnY ?? 0];
    }

    function _flagStringToArray(str:String):Array<String>
    {
        var arr:Array<String> = new Array<String>();
        var substr:String = "";
        while(str.length > 0)
        {
            if(StringTools.isSpace(str, 0))
            {
                if(substr.length > 0)
                {
                    arr.push(substr);
                    substr = "";
                }
            }
            else
            {
                substr += str.charAt(0);
            }
            str = str.substr(1);
            //check if the string is done for the last push
            if(str.length == 0)
                arr.push(substr);
        }
        return arr;
    }
}

/**
 * Decal subset of LayerData
 */
typedef DecalLayer =
{
	name:String,
	_eid:String,
	offsetX:Int,
	offsetY:Int,
	gridCellWidth:Int,
	gridCellHeight:Int,
	gridCellsX:Int,
	gridCellsY:Int,
	decals:Array<RoomParser.DecalData>,
}

/**
 * Individual Decal data
 */
typedef DecalData =
{
	x:Int,
	y:Int,
	texture:String,
	?scaleX:Float,
	?scaleY:Float,
	?rotation:Float,
    ?values:DecalValues
}

//a typedef for storing additional values assigned to the decal in Ogmo.
//typically for use in converting the decal to an FlxSprite (for instance, scroll factors for background decals)
typedef DecalValues = 
{
    drawHeight:Int,
    elevation:Int,
    flipX:Bool,
    flipY:Bool,
    ?scrollFactorX:Float,
    ?scrollFactorY:Float,
    ?animated:Bool,
    ?frameRate:Int
}