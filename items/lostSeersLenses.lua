-- Len's Maker's Glasses -> Lost Seer's Lenses -> Your attacks have a 0.5% (+0.5% per stack) chance to instantly kill a non-Boss enemy. 

local item = Item.new("lostSeersLenses")


-- ===== Assets =====

local sprite = Sprite.new("item/lostSeersLenses", "~/assets/sprites/items/lostSeersLenses.png", 1, 16, 16)

-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.find("Void"))

-- ===== Callbacks =====

Callback.add(Callback.ON_HIT_PROC, function(attacker, target, hit_info)
    if attacker:item_count(item) <= 0 then return end
    
    if math.random(0, 200) < attacker:item_count(item) then
        target.hp = -1
    end
    -- play animation and sound wooo
end)