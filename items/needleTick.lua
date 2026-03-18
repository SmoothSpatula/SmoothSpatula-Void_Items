-- Rusty Knife -> NeedleTick -> 10% (+10% per stack) chance to collapse an enemy for 400% base damage. 
-- Needletick allows you to apply a stack of Collapse to foes, which detonates after a few seconds for a large amount of damage per stack of Collapse.

local item = Item.new("needleTick")

-- ===== Assets =====

local sprite = Sprite.new("item/needleTick", "~/assets/sprites/items/needleTick.png", 1, 16, 16)
--local sprite_effect = Sprite.new("effect/polyluteLightning", "~/assets/sprites/effects/tempEffect2.png",15, 32, 32)

-- https://bdragon1727.itch.io

-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.COMMON)

buff = Buff.find("collapseDebuff")
buff_time = 180

-- object:set_sprite(sprite_effect)
-- object:set_depth(10)

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
    if count <= 0 then return end
    if math.random(0, 10) > count then return end
    
    if target:buff_count(buff) > 0 then 
        target:buff_apply(buff, gm.get_buff_time(target.value, buff.value), 1)
        local inst_data = Instance.get_data(target)
        inst_data.collapse_count = target:buff_count(buff)
    else
        target:buff_apply(buff, buff_time, 1)
        local inst_data = Instance.get_data(target)
        inst_data.collapse_count = 1
        inst_data.attacker = attacker
    end
    print(target:buff_count(buff))
    print(gm.get_buff_time(target.value, buff.value))

    -- play animation and sound wooo
end)