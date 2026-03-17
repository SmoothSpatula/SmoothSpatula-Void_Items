-- Will-o'-the-Wisp -> Voidsent Flame -> Upon hitting an enemy at full health, spawn a lava pillar in a 12m (+2.4m per stack) radius for 260% (+156% per stack) base damage.
local item = Item.new("voidsentFlames")
local object = Object.new("voidesentFlamesEf")

-- ===== Assets =====

local sprite = Sprite.new("item/ration", "~/assets/sprites/items/ration.png", 1, 16, 16)
local sprite_effect = Sprite.new("effect/voidsentFlamesef", "~/assets/sprites/effects/voidsentFlames.png", 13, 32, 32)

-- https://bdragon1727.itch.io

-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.COMMON)

object:set_sprite(sprite_effect)
object:set_depth(-1)

-- ===== Callbacks =====

Callback.add(Callback.ON_HIT_PROC, function(attacker, target, hit_info)
    local count = attacker:item_count(item)
    if count <= 0 or target.hp < target.maxhp then return end
    local height = 192 + 24 * (count-1)
    local flames = object:create(target.x, target.y - height/1.8 + 30)
    flames.image_yscale = 3 + count * 0.4
    flames.image_xscale = 3
    local inst_data = Instance.get_data(flames)
    inst_data.target = target
    attacker:fire_explosion(target.x, target.y, 64, height, 2.4 + 1.56 * (count-1), nil, nil, 0)

    -- play animation and sound wooo
end)

Callback.add(object.on_create, function(inst)
    inst.image_speed = 0.2
end)

Callback.add(object.on_step, function(inst)
    -- local inst_data = Instance.get_data(inst)
    
    if inst.image_index > 12 then inst:destroy() end
end)
