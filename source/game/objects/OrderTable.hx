package game.objects;

import crowbar.components.Collision;
import crowbar.objects.TopDownSprite;
import game.objects.Order;
import game.states.PlayState;
import flixel.tweens.FlxTween;
import flixel.math.FlxPoint;

//spawns orders. not directly but some global manager should do it.

class OrderTable extends TopDownSprite
{
    public var spawnX:Int = -20;
    public var spawnY:Int = -10;
    public final orderSpacing:Int = 83;
    //spawn trays as part of the table sprite group
    public var trays:Array<OrderTray>;
    public var hitbox:Collision;

    //add a hitbox that checks if the player is in its range.
    //if so, then hover over the closest order and allow the player to only pick that one up.

    public function new(x:Int, y:Int)
    {
        super(x,y);
        loadSprite("images/objects/carhop_table.png");

        trays = new Array<OrderTray>();
        hitbox = new Collision(x, y, this.width, this.height + 128);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(trays.length > 0)
        {
            if(hitbox.checkOverlap(PlayState.current.playerHitbox))
            {
                var i = getClosestTrayIndex();

                if(trays[i].interactable.interactionCheck())
                {
                    trays[i].onPickup();
                }
            }
        }
    }

    public function getClosestTrayIndex():Int
    {
        if(trays.length <= 0)
            return -1;

        var minDistance = 9999.0;
        var index = 0;
        var curDist = 0.0;
        for(i in 0...trays.length)
        {
            curDist = trays[i].bottomCenter.dist(PlayState.current.player.bottomCenter);
            if(curDist < minDistance)
            {
                minDistance = curDist;
                index = i;
            }
        }

        return index;
    }

    public function spawnOrderTray(order:Order)
    {
        var tray = new OrderTray(spawnX + (orderSpacing * trays.length), spawnY, order);
        trays.push(tray);
        this.add(tray);
        
    }

    public function removeOrderTray(ticket:Int)
    {
        for(t in trays) {
            if(t.refOrder.ticket == ticket)
                trays.remove(t);
        }

        pushTrays();
    }

    public function pushTrays()
    {
        for(i in 0...trays.length)
        {
            FlxTween.tween(trays[i], {x: this.x + spawnX + (orderSpacing * i)}, 0.3, {ease: FlxEase.cubeOut});
        }
    }
}