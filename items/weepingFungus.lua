-- Ration

local item = Item.new("weepingFungus")


-- ===== Assets =====

local sprite = Sprite.new("item/weepingFungus", "~/assets/sprites/items/weepingFungus.png", 1, 16, 16)
local sound  =  Sound.new("item/ration", "~/assets/sounds/items/ration.ogg")


-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.find("Void"))


-- ===== Callbacks =====

Callback.add(Callback.ON_SECOND, function()
    local actors = item:get_holding_actors()
    for _, actor in ipairs(actors) do
        if (math.abs(actor.pHspeed) > 0.0 and not (actor.value.x_skill or actor.value.v_skill or actor.value.z_skill or actor.value.c_skill)) 
        or math.abs(actor.pHspeed) >= actor.pHmax - 0.2 then
            actor:heal(actor.maxhp * 0.02 * actor:item_count(item))
        end
    end
    
end)

-- ===== Additional =====

ItemLog.new_from_item(item)