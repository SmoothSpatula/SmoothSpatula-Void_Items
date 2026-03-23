-- Will-o'-the-Wisp -> Voidsent Flame -> Upon hitting an enemy at full health, spawn a lava pillar in a 12m (+2.4m per stack) radius for 260% (+156% per stack) base damage.
local item = Item.new("voidsentFlame")

-- ===== Assets =====

local sprite = Sprite.new("item/voidsentFlame", "~/assets/sprites/items/voidsentFlame.png", 1, 16, 16)
local sprite_effect = Sprite.new("effect/voidsentFlamesef", "~/assets/sprites/effects/voidFlamesEffect1.png", 9, 32, 32)


-- https://bdragon1727.itch.io

-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.find("voidUncommon"))

sprite_effect:set_speed(2)

-- ===== Callbacks =====

Callback.add(Callback.ON_HIT_PROC, function(attacker, target, hit_info)
    local count = attacker:item_count(item)
    if count <= 0 or target.hp < target.maxhp then return end
    local size = 96 + 12*(count-1)
    attacker:fire_explosion(target.x, target.y, attacker.damage * 1.04 + 1.56*count, size, size, sprite_effect, nil, false)

    -- play animation and sound wooo
end)

-- ===== Additional =====

ItemLog.new_from_item(item)