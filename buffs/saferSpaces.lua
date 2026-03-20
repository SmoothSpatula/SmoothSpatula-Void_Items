-- Safer Spaces (Buff)

local buff = Buff.new("saferSpaces")


-- ===== Assets =====

local sprite_ring = Sprite.new("buff/saferSpacesRing", "~/assets/sprites/effects/saferSpacesRing.png", 1, 128, 128)


-- ===== Properties =====

buff.show_icon = false
buff.is_timed  = false
buff.is_debuff = false

local diameter = 80 / 256


-- ===== Callbacks =====

DamageDodge.add(function(api, current_dodge)
    if current_dodge ~= DamageDodge.NONE then return end

    local actor = api.hit
    local stack = actor:buff_count(buff)
    if stack <= 0 then return end

    actor:buff_remove(buff)
    Alarm.add(300, function()
        if not Instance.exists(actor) then return end
        actor:buff_apply(buff, 1)
    end)

    return DamageDodge.BLOCKED
end)


Callback.add(Callback.ON_DRAW, function()
    -- TODO improve vfx

    local actors = buff:get_holding_actors()

    for _, actor in ipairs(actors) do
        local diameter = (actor.bbox_bottom - actor.bbox_top + 32) / 256
        GM.draw_sprite_ext(sprite_ring, 0, actor.x, actor.y, diameter, diameter, 0, Color.WHITE, 0.6)
    end
end)