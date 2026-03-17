-- 6) AtG Missile Launcher -> Plasma Shrimp -> Gain a shield equal to 10% of your maximum health. While you have a shield, hitting an enemy fires a missile that deals 40% (+40% per stack) TOTAL damage

local item = Item.new("plasmaShrimp")

-- ===== Assets =====

local sprite = Sprite.new("item/ration", "~/assets/sprites/items/ration.png", 1, 16, 16)

-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.COMMON)

-- ===== Callbacks =====

Callback.add(Callback.ON_HIT_PROC, function(attacker, target, hit_info)
    local stack = attacker:item_count(item)
    if stack <= 0 or attacker.shield <= 0 then return end
    
    missile = Instance.create(attacker.x, attacker.y, gm.constants.oEfMissile)
    missile.damage = attacker.damage * 0.4 * stack
    missile.image_xscale = 1.5 + 0.05 * stack
    missile.image_yscale = 1.5 + 0.05 * stack

    -- play animation and sound wooo
end)

RecalculateStats.add(function(actor, api)
    -- Check buff count
    local stack = actor:item_count(item)
    if stack <= 0 then return end

    -- Add stats
    api.maxshield_add_from_maxhp(0.1)
end)