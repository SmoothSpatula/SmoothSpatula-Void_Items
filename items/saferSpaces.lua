-- Ration

local item = Item.new("saferSpaces")

local item_broken = Item.new("brokenSaferSpaces")


-- ===== Assets =====

local sprite = Sprite.new("item/saferSpaces", "~/assets/sprites/items/saferSpaces.png", 1, 16, 16)
local sound  =  Sound.new("item/ration", "~/assets/sounds/items/ration.ogg")

local sprite_broken = Sprite.new("item/rationUsed", "~/assets/sprites/items/rationUsed.png", 1, 16, 16)


-- ===== Properties =====

item_broken:set_sprite(sprite_broken)

item:set_sprite(sprite)
item:set_tier(ItemTier.COMMON)
item.loot_tags = Item.LootTag.CATEGORY_HEALING

local restore_safer_spaces = function (act)
    act:item_give(item)
    act:item_take(item_broken)
end
-- ===== Callbacks =====

-- Tougher Times -> Safer Spaces -> Blocks incoming damage once. Recharges after 15 seconds (-10% per stack)

DamageCalculate.add(function(api)
    if api.hit:item_count(item) <= 0 then return end
    api.damage = 0
    api.hit:item_take(item)
    api.hit:item_give(item_broken)
    print("test")
    Alarm.add(300, restore_safer_spaces, api.hit)
end)


-- ===== Additional =====

ItemLog.new_from_item(item)