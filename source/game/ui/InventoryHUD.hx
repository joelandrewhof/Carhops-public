package game.ui;

import game.objects.Order;
import crowbar.display.CrowbarText;
import crowbar.display.CrowbarSprite;
import flixel.group.FlxSpriteGroup;
import game.states.PlayState;
import game.ui.PatienceClock;

class InventoryHUD extends FlxSpriteGroup
{
    public var receipts:Array<HUDReceipt>;

    var receiptSpacing:Int = 20;
    var spaced:Bool = false;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        receipts = new Array<HUDReceipt>();
        for(i in 0...4) {
            var r = new HUDReceipt(0, 0);
            add(r);
            receipts.push(r);
        }

        updateFromInventory();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(!spaced)
        {
            for(i in 0...receipts.length) {
                receipts[i].updatePosition(FlxG.width - receipts[i].receipt.width - 30, 
                    20 + (receiptSpacing * i) + (receipts[i].receipt.height * i));
            }
            spaced = true;
        }

        var orders = PlayState.current.inventory.orders;
        for(i in 0...receipts.length)
        {
            if(receipts[i].occupied && orders.length > i)
                receipts[i].patienceClock.amount = (orders[i].patience / orders[i].basePatience);
        }
    }

    public function updateFromInventory()
    {
        var list = PlayState.current.inventory.orders;

        for(i in 0...receipts.length)
        {
            if(list.length <= i) {
                receipts[i].setEmpty();
            }
            else {
                receipts[i].updateInfo(list[i]);
                receipts[i].setActive();
            }
        }
    }
}

class HUDReceipt extends FlxSpriteGroup
{
    public var receipt:CrowbarSprite;
    public var ticket:CrowbarText;
    public var stall:CrowbarText;
    public var patienceClock:PatienceClock;
    public var occupied:Bool;

    public function new(x:Float, y:Float)
    {
        super(x, y);
        receipt = new CrowbarSprite(x, y);
        receipt.loadSprite("images/ui/hud_receipt", true);
        receipt.addAtlasAnim('active', 'active', 6, true);
        receipt.addAtlasAnim('empty', 'empty', 0, false);
        receipt.playAnim('active');
        receipt.updateHitbox();
        add(receipt);

        ticket = new CrowbarText(x + 10, y + 10);
        ticket.setFormat("vcr", 54, FlxColor.BLACK, CENTER);
        ticket.setFont("vcr", 54);
        ticket.setColor(FlxColor.BLACK);
        ticket.antialiasing = false;
        ticket.updateHitbox();
        ticket.x = Std.int((receipt.width * 0.5) - (ticket.width * 0.5));
        add(ticket);

        stall = new CrowbarText(x + 10, y + 75);
        stall.setFont("vcr", 24);
        stall.setColor(0xFF991010);
        stall.antialiasing = false;
        add(stall);

        patienceClock = new PatienceClock(Std.int(x), Std.int(y));
        patienceClock.updateHitbox();
        add(patienceClock);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    public function setEmpty()
    {
        receipt.playAnim('empty');
        occupied = false;
        ticket.alpha = 0.0;
        stall.alpha = 0.0;
        patienceClock.alpha = 0.0;
    }

    public function setActive()
    {
        receipt.playAnim('active');
        occupied = true;
        ticket.alpha = 1.0;
        stall.alpha = 1.0;
        patienceClock.alpha = 1.0;
    }

    public function updateInfo(order:Order)
    {
        ticket.text = Std.string(order.ticket);
        stall.text = order.destination;
    }

    public function updatePosition(?x:Float = 0, ?y:Float = 0)
    {
        receipt.setPosition(x, y);
        ticket.setPosition(x + Std.int((receipt.width * 0.5) - (ticket.width * 0.5)), y + 10);
        stall.setPosition(x + 10, y + 75);
        patienceClock.updateAnchor(x - 50, y - 50);
    }
}