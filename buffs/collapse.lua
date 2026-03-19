-- Collapse (Debuff) detonates after a few seconds for a large amount of damage per stack of Collapse.

local buff = Buff.new("collapseDebuff")


-- ===== Assets =====

local sprite = Sprite.new("buff/collapse", "~/assets/sprites/items/benthicBloom.png", 1, 8, 8)

-- ===== Properties =====

buff.icon_sprite = sprite
buff.max_stack = 999
buff.is_debuff = true
buff.is_timed = true


-- ===== Callbacks =====

Callback.add(buff.on_remove, function(actor)
    local inst_data = Instance.get_data(actor)
    local damage = inst_data.collapse_count * inst_data.attacker.damage * 4
    inst_data.attacker:fire_direct(actor, damage, 0, actor.x, actor.y, gm.constants.sSparks1, false)
end)