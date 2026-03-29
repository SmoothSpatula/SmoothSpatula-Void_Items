-- 6) AtG Missile Launcher -> Plasma Shrimp -> Gain a shield equal to 10% of your maximum health. While you have a shield, hitting an enemy fires a missile that deals 40% (+40% per stack) TOTAL damage

local item = Item.new("plasmaShrimp")

local object = Object.new("shrimpMissileObject")

local particleShrimp = Particle.new("Shrimp")
local particleCircle = Particle.new("ShrimpCircle")
local particleCircle2 = Particle.new("ShrimpCircle2")
local particleLine = Particle.new("ShrimpLines")

-- ===== Assets =====

local sprite = Sprite.new("item/plasmaShrimp", "~/assets/sprites/items/plasmaShrimp.png", 1, 16, 16)
local sprite_effect = Sprite.new("effect/shrimpEf", "~/assets/sprites/effects/shrimpEffect.png", 1, 4, 4)
local sprite_explosion_effect = Sprite.new("effect/shrimpExplosionEf", "~/assets/sprites/effects/Symmetrical_impact_003.png", 7, 48, 48)

local sound = Sound.new("item/plasmaShrimp", "~/assets/sounds/items/plasmaShrimp.ogg")

-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.find("voidUncommon"))

object:set_sprite(sprite_effect)
object:set_depth(-10)

local CO_PURPLE = Color.from_rgb(87, 36, 94)
local CO_PINK = Color.from_rgb(233, 40, 72)
local CO_OFFWHITE = Color.from_rgb(225, 214, 242)

particleShrimp:set_shape(7)
particleShrimp:set_life(10, 10)
particleShrimp:set_speed(0, 0, 0, 0)
particleShrimp:set_size(0.1, 0.1, 0, 0)
particleShrimp:set_color3(CO_PINK, CO_PURPLE, CO_PURPLE)
particleShrimp:set_alpha3(1, 1, 0)
particleShrimp:set_blend(0)

particleCircle:set_shape(5) -- circle
particleCircle:set_life(15, 20)
particleCircle:set_speed(0, 0, 0, 0)
particleCircle:set_scale(2,2)
particleCircle:set_size(0.05, 0.05, 0.03, 0)
particleCircle:set_color3(CO_PINK, CO_OFFWHITE, CO_PURPLE)
particleCircle:set_alpha3(1, 1, 1)
particleCircle:set_blend(0)

particleCircle2:set_shape(1) -- disk
particleCircle2:set_life(10, 10)
particleCircle2:set_speed(0, 0, 0, 0)
particleCircle2:set_scale(0.5, 0.5)
particleCircle2:set_size(0.5, 0.5, 0, 0)
particleCircle2:set_color1(CO_OFFWHITE)
particleCircle2:set_alpha3(1, 1, 0)
particleCircle2:set_blend(0)

particleLine:set_shape(1) -- line
particleLine:set_life(10, 10)
particleLine:set_speed(0, 0, 0, 0)
particleLine:set_scale(0.8, 0.08)
particleLine:set_size(0, 0, 0.15, 0)
particleLine:set_color2(CO_PINK, Color.from_rgb(54, 28, 92) )
particleLine:set_alpha3(1, 1, 1)
particleLine:set_blend(0)

local max_turn_radius = 2.5
local start_distance = 40 -- change this to whatever distance you want
local base_speed = 5

-- ===== Callbacks =====

local function shrimp_pos_angle_speed(attacker, target) 
    local dx = target.x - attacker.x
    local dy = target.y - attacker.y
    angle = (math.deg(math.atan(dy, dx)) + (math.random(0,1)*2-1) * math.random(60, 90)) % 360
    
    local rad = math.rad(angle)
    local x = attacker.x + math.cos(rad) * start_distance
    local y = attacker.y - math.sin(rad) * start_distance

    speed = base_speed + (math.log(math.sqrt(dx*dx + dy*dy) + 1))^1.1 * 2 -- logfactor calculation

    return x, y, angle, speed
end

Callback.add(Callback.ON_HIT_PROC, function(attacker, target, hit_info)
    local stack = attacker:item_count(item)
    if stack <= 0 or attacker.shield <= 0 then return end
    
    local shrimp_x, shrimp_y, shrimp_angle, shrimp_speed = shrimp_pos_angle_speed(attacker, target)

    shrimp_inst = Instance.create(shrimp_x, shrimp_y, object)
    local inst_data = Instance.get_data(shrimp_inst)
    shrimp_inst.direction = shrimp_angle
    shrimp_inst.speed = shrimp_speed
    inst_data.target = target
    inst_data.duration = 480
    inst_data.parent = attacker
    inst_data.damage = stack * 0.4
    inst_data.last_x = shrimp_x - math.cos(math.rad(shrimp_angle)) * 20 
    inst_data.last_y = shrimp_y + math.sin(math.rad(shrimp_angle)) * 20 
    inst_data.max_turn_radius = max_turn_radius

    -- play animation and sound wooo
    sound:play_synced(shrimp_x, shrimp_y, 0.6)
end)

RecalculateStats.add(function(actor, api)
    -- Check buff count
    local stack = actor:item_count(item)
    if stack <= 0 then return end

    -- Add stats
    api.maxshield_add_from_maxhp(0.1)
end)


Callback.add(object.on_step, function(inst)
    local inst_data = Instance.get_data(inst)
    
    if Instance.exists(inst_data.target) then
        inst_data.tx = inst_data.target.x
        inst_data.ty = inst_data.target.y
    end

    particleShrimp:set_orientation(inst.direction, inst.direction, 0, 0, 0);
    particleShrimp:set_scale(inst.speed/2.9, 0.7)
    particleShrimp:create((inst.x + inst_data.last_x) / 2, (inst.y + inst_data.last_y) / 2, 1)

    local dx = inst_data.tx - inst.x
    local dy = inst_data.ty - inst.y

    local dist = math.sqrt(dx*dx + dy*dy)
    local desired = (360 - math.deg(math.atan(dy, dx))) % 360
    local diff = (desired - inst.direction + 180) % 360 - 180

    local maxTurn = inst_data.max_turn_radius * (1 + (350 / math.max(dist,1))) -- 400 for more agressive finish

    if diff > maxTurn then diff = maxTurn end
    if diff < -maxTurn then diff = -maxTurn end
    inst.direction = (inst.direction + diff) % 360

    inst_data.last_x = inst.x
    inst_data.last_y = inst.y

    if dist < 10 then
        if Instance.exists(inst_data.target) then
            inst_data.parent:fire_direct(inst_data.target, inst_data.damage, 0, inst_data.target.x, inst_data.target.y, nil, false)
            
            local orientation = math.random() * 360
            particleLine:set_orientation(orientation, orientation, 0, 0, 0)
            particleLine:create(inst.x, inst.y, 1)
            particleLine:set_orientation(orientation+ 90, orientation+90, 0, 0, 0)
            particleLine:create(inst.x, inst.y, 1)
            
            particleCircle2:create(inst.x, inst.y, 1)
            particleCircle:create(inst.x, inst.y, 1)
            
        end
        inst:destroy()
        return
    end

    inst_data.duration = inst_data.duration - 1
    if inst_data.duration < 0 then
        inst:destroy()
    end
end)

-- ===== Additional =====

ItemLog.new_from_item(item)