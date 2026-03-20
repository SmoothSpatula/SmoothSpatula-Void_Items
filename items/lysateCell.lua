-- 3) Energy cell -> Lysate Cell -> Add +1 (+1 per stack) charge of your Special skill. Reduces Special skill cooldown by 33%. 

local item = Item.new("lysateCell")

-- ===== Assets =====

local sprite = Sprite.new("item/lysateCell", "~/assets/sprites/items/lysateCell.png", 1, 16, 16)

-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.find("Void"))

-- ===== Callbacks =====

RecalculateStats.add(function(actor, api)
    -- Check buff count
    local stack = actor:item_count(item)
    if stack <= 0 then return end

    -- Add stats
    api.skill_special.cooldown_mult(0.67)
    api.skill_special.max_stock_add(stack)
end)

-- ===== Additional =====

ItemLog.new_from_item(item)