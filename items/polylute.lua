-- 2) Ukulele -> polylute -> 25% chance to fire lightning for 60% TOTAL damage up to 3 (+3 per stack) times. Corrupts all Ukuleles. Single target on the 

local item = Item.new("polylute")
local object = Object.new("polyluteLightningEf")

-- ===== Assets =====

local sprite = Sprite.new("item/polylute", "~/assets/sprites/items/polylute.png", 1, 16, 16)
local sprite_effect = Sprite.new("effect/polyluteLightning", "~/assets/sprites/effects/tempEffect2.png",15, 32, 32)

-- https://bdragon1727.itch.io

-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.COMMON)

object:set_sprite(sprite_effect)
object:set_depth(10)

-- ===== Callbacks =====

RecalculateStats.add(function(actor, api)
    -- Check buff count
    local stack = actor:item_count(item)
    if stack <= 0 then return end

    -- Add stats
    api.maxshield_add_from_maxhp(0.1)
end)

Callback.add(Callback.ON_HIT_PROC, function(attacker, target, hit_info)
    local count = attacker:item_count(item)
    if count <= 0 or attacker.shield <= 0 then return end

    local lightning = object:create(target.x, target.y)
    local inst_data = Instance.get_data(lightning)
    inst_data.target = target

    -- play animation and sound wooo
end)

Callback.add(object.on_create, function(inst)
    local inst_data = Instance.get_data(inst)
    inst.direction = math.random(0, 359)
    inst.image_speed = 0.2
        inst.image_xscale = gm.sprite_get_width(inst_data.target.sprite_index) * inst_data.target.image_xscale * 2
        inst.image_yscale = gm.sprite_get_height(inst_data.target.sprite_index) * inst_data.target.image_yscale * 2
end)

Callback.add(object.on_step, function(inst)
    local inst_data = Instance.get_data(inst)
    
    if inst.image_index > 13 or not Instance.exists(inst_data.target) then
        inst:destroy()
    else
        inst.x = inst_data.target.x
        inst.y = inst_data.target.y
    end
end)
