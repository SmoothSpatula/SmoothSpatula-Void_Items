-- Rusty Knife -> NeedleTick -> 10% (+10% per stack) chance to collapse an enemy for 400% base damage. 
-- Needletick allows you to apply a stack of Collapse to foes, which detonates after a few seconds for a large amount of damage per stack of Collapse.

local item = Item.new("needletick")

-- ===== Assets =====

local sprite = Sprite.new("item/needletick", "~/assets/sprites/items/needletick.png", 1, 16, 18)

-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.find("voidCommon"))

buff = Buff.find("collapseDebuff")
buff_time = 180

-- ===== Callbacks =====

Callback.add(Callback.ON_HIT_PROC, function(attacker, target, hit_info)
    local count = attacker:item_count(item)
    if count <= 0 then return end
    if math.random(1, 10) > count then return end
    
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
end)

-- ===== Additional =====

ItemLog.new_from_item(item)