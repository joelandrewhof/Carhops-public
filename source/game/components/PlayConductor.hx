package game.components;

import game.objects.*;
import game.states.PlayState;
import crowbar.components.Directional;

//DO LATER AS PART OF GAMEPLAY
//keeps track of game elements and makes decisions

class PlayConductor
{
    public var orders:Array<Order>;
    public var stalls:Array<Stall>;
    public var customers:Array<CustomerCar>;
    public var nextOrder:Int = 1;

    public var timeSinceLastSpawn:Float = 0.0;

    public function new()
    {
        orders = new Array<Order>();
        stalls = new Array<Stall>();
        customers = new Array<CustomerCar>();
    }


    public function update(elapsed:Float)
    {
        timeSinceLastSpawn += elapsed;

        spawnOrderTimed();
        updateUnsatisfiedOrders(elapsed);
    }

    public function spawnOrderTimed()
    {
        if(customers.length >= 6)
            return;
        if(timeSinceLastSpawn > 2.0 + (2.0 * customers.length))
        {
            createOrderEntire();
            timeSinceLastSpawn = 0;
        }
    }

    public function getVacantStalls():Array<Stall>
    {
        var vacants:Array<Stall> = new Array<Stall>();
        for(s in stalls) {
            if(!s.occupied)
                vacants.push(s);
        }
        return vacants;
    }

    public function setVacantStall(id:String, vacant:Bool)
    {
        getStallFromID(id).occupied = !vacant;
        return;
    }

    public function removeCar(id:String)
    {
        
    }

    public function getStallFromID(id:String):Stall
    {
        for(s in stalls) {
            if(s.id == id) 
                return s;
        }
        return null;
    }

    public function isStallVacant(id:String):Bool
    {
        var s = getStallFromID(id);
        return (s != null && !s.occupied);
    }

    private function createCustomer(stall:Stall):CustomerCar
    {
        var car = new CustomerCar(0, 0, stall.id);
        car.setPosition(stall.x, stall.y);
        car.direction.updateDir(stall.orientation);
        car.playBasicAnimation("idle", car.direction.getDirString());
        PlayState.current.customers.add(car);
        PlayState.current.actMngr.collisionArray.push(car.collision);
        PlayState.current.actMngr.interactableArray.push(car.interactable);
        PlayState.current.visMngr.addSprite(car);
        this.customers.push(car);
        stall.setOccupied(true);
        return car;
    }

    private function createCustomerAtRandomStall():CustomerCar
    {
        var vacants = getVacantStalls();
        return createCustomer(vacants[FlxG.random.int(0, vacants.length - 1)]);
    }

    public function createOrderEntire(?id:String)
    {
        if(getVacantStalls().length <= 0)
        {
            trace("Notice: no vacant stalls left, cancelling order");
            return;
        }
        else
        {
            if(isStallVacant(id)) {
                spawnOrderTray(createOrderToCustomer(createCustomer(getStallFromID(id))));
            }
            else {
                spawnOrderTray(createOrderToCustomer(createCustomerAtRandomStall()));
            }
        }
    }

    public function createOrderToCustomer(customer:CustomerCar):Order
    {
        var order = new Order(nextOrder, customer.stallID);
        nextOrder++;
        orders.push(order);
        return order;
    }

    public function getVacantCustomer()
    {
        for(c in PlayState.current.customers)
        {
            if(!c.ordered)
                return c;
        }
        return null;
    }

    public function spawnOrderTray(order:Order)
    {
        PlayState.current.orderTable.spawnOrderTray(order);
    }

    public function updateUnsatisfiedOrders(elapsed:Float)
    {
        for(order in orders)
        {
            if(!order.satisfied) {
                order.drainPatience(elapsed);
            }
        }
    }
}