-- Will-o'-the-Wisp -> Voidsent Flame -> Upon hitting an enemy at full health, spawn a lava pillar in a 12m (+2.4m per stack) radius for 260% (+156% per stack) base damage.
local item = Item.new("voidsentFlame")

-- ===== Assets =====

local sprite = Sprite.new("item/voidsentFlame", "~/assets/sprites/items/voidsentFlame.png", 1, 16, 16)
local sprite_effect = Sprite.new("effect/voidsentFlamesef", "~/assets/sprites/effects/voidFlamesEffect1.png", 9, 32, 32)
-- sprite effect used made by https://bdragon1727.itch.io

local sound = Sound.new("item/voidsentFlame", "~/assets/sounds/items/voidsentFlame.ogg")

-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.find("voidUncommon"))

sprite_effect:set_speed(1)

-- ===== Callbacks =====

Callback.add(Callback.ON_HIT_PROC, function(attacker, target, hit_info)
    local count = attacker:item_count(item)
    if count <= 0 or target.hp < target.maxhp then return end
    local size = 96 + 16*(count-1)
    local tx, ty = target.x, target.y
    attacker:fire_explosion(tx, ty, size, size, 1.04 + 1.56*count, sprite_effect, nil, false)

    -- Sfx
    sound:play_synced(tx, ty, 0.5)
end)

-- ===== Additional =====

ItemLog.new_from_item(item)