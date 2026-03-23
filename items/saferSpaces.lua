-- Safer Spaces

local item = Item.new("saferSpaces")


-- ===== Assets =====

local sprite = Sprite.new("item/saferSpaces", "~/assets/sprites/items/saferSpaces.png", 1, 16, 16)


-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.find("voidUncommon"))


-- ===== Callbacks =====

Callback.add(item.on_acquired, function(actor, stack)
    actor:buff_apply(Buff.find("saferSpaces"), 1)
end)


-- ===== Additional =====

ItemLog.new_from_item(item)