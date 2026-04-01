-- Safer Spaces (Buff)

local buff = Buff.new("saferSpaces")


-- ===== Assets =====

local sprite_ring = Sprite.new("buff/saferSpacesRing", "~/assets/sprites/effects/saferSpacesRing.png", 1, 128, 128)
local sound       =  Sound.new("buff/saferSpaces", "~/assets/sounds/buffs/saferSpaces.ogg")


-- ===== Properties =====

buff.show_icon = false
buff.is_timed  = false
buff.is_debuff = false

-- ===== Network ===== --

local packetSaferTakeDamage = Packet.new("packetSaferTakeDamage")

local function remove_buff(actor)
    actor:buff_remove(buff)
    sound:play_synced(actor.x, actor.y, 0.85)

    local actor_data = Instance.get_data(actor, "saferSpaces")
    actor_data.state = 2

    local item = Item.find("saferSpaces")
    local cd = 15 * (0.9 ^ (actor:item_count(item) - 1)) * 60
    print(cd)
    Alarm.add(cd, function()
        if not Instance.exists(actor) then return end
        actor:buff_apply(buff, 1)
    end)

    if Net.online and Net.host then
		packetSaferTakeDamage:send_to_all(actor)
	end
end

local SaferTakeDamage_serializer = function(buffer, actor)
	buffer:write_instance(actor)
end
local SaferTakeDamage_deserializer = function(buffer)
	local actor = buffer:read_instance()
	if not Instance.exists(actor) then return end
	remove_buff(actor)
end

packetSaferTakeDamage:set_serializers(SaferTakeDamage_serializer, SaferTakeDamage_deserializer)


-- ===== Callbacks =====

Callback.add(buff.on_apply, function(actor)
    local actor_data = Instance.get_data(actor, "saferSpaces")

    actor_data.state    = 1
    actor_data.diameter = 0
    actor_data.alpha    = 0

    local sprite_idle = actor.sprite_idle
    actor_data.height = (sprite_idle >= 0 and GM.sprite_get_height(sprite_idle)) or 0
end)


DamageDodge.add(function(api, current_dodge)
    if current_dodge ~= DamageDodge.NONE then return end

    local actor = Instance.wrap(api.hit)
    local stack = actor:buff_count(buff)
    if stack <= 0 then return end

    remove_buff(actor)

    return DamageDodge.BLOCKED
end)


Callback.add(Callback.ON_DRAW, function()
    local item = Item.find("saferSpaces")
    local actors = item:get_holding_actors()

    for _, actor in ipairs(actors) do
        if Util.bool(actor.dead) then goto continue end

        local actor_data = Instance.get_data(actor, "saferSpaces")
        local stack = actor:buff_count(buff)

        local diameter_to, alpha_to, alpha_incr = 0, 0, 0

        if stack > 0 then actor_data.state = 1 end

        -- Idle
        if actor_data.state == 0 then
            actor_data.diameter = 0

        -- Ready
        elseif actor_data.state == 1 then
            diameter_to = actor_data.height
            alpha_to    = 1
            alpha_incr  = 2 /60

        -- Break
        elseif actor_data.state == 2 then
            diameter_to = actor_data.height + 48
            alpha_incr  = 4 /60

            if actor_data.alpha <= 0 then actor_data.state = 0 end
        end

        -- Lerp
        actor_data.diameter = math.lerp(actor_data.diameter, diameter_to, 0.1)
        
        local diff = alpha_to - actor_data.alpha
        if math.abs(diff) <= alpha_incr then actor_data.alpha = alpha_to
        else actor_data.alpha = actor_data.alpha + alpha_incr * math.sign(diff)
        end

        -- Draw
        local height = actor_data.height
        local y      = (height > 0 and actor.bbox_bottom - height/2) or actor.y
        local scale  = (actor_data.diameter + 32) / 256
        GM.draw_sprite_ext(sprite_ring, 0, actor.x, y, scale, scale, 0, Color.WHITE, actor_data.alpha * 0.65)

        ::continue::
    end
end)