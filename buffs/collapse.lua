-- Collapse (Debuff) detonates after a few seconds for a large amount of damage per stack of Collapse.

local buff = Buff.new("collapseDebuff")
local particleSmall = Particle.new("CollapseSmall")
local particleBig = Particle.new("CollapseBig")

-- ===== Assets =====

local sprite = Sprite.new("buff/collapse", "~/assets/sprites/buffs/collapse.png", 1, 8, 8)
local sound  =  Sound.new("buff/collapse", "~/assets/sounds/buffs/collapse.ogg")

-- ===== Properties =====

buff.icon_sprite = sprite
buff.max_stack = 999
buff.is_debuff = true
buff.is_timed = true
buff.draw_stack_number = true

local COL_COLLAPSE_RED = Color.from_rgb(255, 73, 74)

particleSmall:set_shape(5) -- shape circle
particleSmall:set_life(25, 25)
particleSmall:set_speed(0, 0, 0, 0)
particleSmall:set_alpha3(1, 1, 0)
particleSmall:set_scale(1, 1)
particleSmall:set_blend(0)

particleBig:set_shape(5) -- shape circle
particleBig:set_life(25, 25)
particleBig:set_speed(0, 0, 0, 0)
particleBig:set_alpha3(1, 1, 0)
particleBig:set_scale(1, 1)
particleBig:set_blend(0)


-- ===== Callbacks =====

Callback.add(buff.on_remove, function(actor)
    local actor_x, actor_y = actor.x, actor.y

    local inst_data = Instance.get_data(actor)
    local damage = inst_data.collapse_count * 2.5

    if not inst_data.attacker then return end
    local result = inst_data.attacker:fire_direct(actor, damage, 0, actor_x, actor_y, gm.constants.sSparks1, false)
    if not result or not result.attack_info then 
        log.warning("Void_Items - Collapse : failed to retrieve data attack_info from fire_direct \n")
    return end
    result.attack_info.damage_color = COL_COLLAPSE_RED
    local size = math.sqrt(gm.sprite_get_width(actor.sprite_index) *  gm.sprite_get_height(actor.sprite_index)) / 500

    -- small circle
    particleSmall:set_color1(COL_COLLAPSE_RED)
    particleSmall:set_size(size - 0.05, size - 0.05, 0.12 *  size, 0)
    particleSmall:create(actor_x, actor_y, 1)
    particleSmall:set_size(size + 0.05, size + 0.05, 0.12 *  size, 0)
    particleSmall:create(actor_x, actor_y, 1)

    particleSmall:set_color1(Color.BLACK)
    particleSmall:set_size(size, size, 0.1 * size, 0)
    particleSmall:create(actor_x, actor_y, 1)

    -- big circle

    particleBig:set_color1(COL_COLLAPSE_RED)
    particleBig:set_size(size*2 - 0.05, size*2 - 0.05, 0.18 *  size, 0)
    particleBig:create(actor_x, actor_y, 1)
    particleBig:set_size(size*2 + 0.05, size*2 + 0.05, 0.18 *  size, 0)
    particleBig:create(actor_x, actor_y, 1)

    particleBig:set_color1(Color.BLACK)
    particleBig:set_size(size*2, size*2, 0.15 * size, 0)
    particleBig:create(actor_x, actor_y, 1)

    -- Sfx
    sound:play_synced(actor_x, actor_y, 1)
end)