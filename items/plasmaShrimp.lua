-- 6) AtG Missile Launcher -> Plasma Shrimp -> Gain a shield equal to 10% of your maximum health. While you have a shield, hitting an enemy fires a missile that deals 40% (+40% per stack) TOTAL damage

local item = Item.new("plasmaShrimp")

local object = Object.new("shrimpMissileObject")

local particleShrimp = Particle.new("Shrimp")

-- ===== Assets =====

local sprite = Sprite.new("item/plasmaShrimp", "~/assets/sprites/items/plasmaShrimp.png", 1, 16, 16)
local sprite_effect = Sprite.new("effect/shrimpEf", "~/assets/sprites/effects/shrimpEffect.png", 1, 4, 4)
local sprite_explosion_effect = Sprite.new("effect/shrimpExplosionEf", "~/assets/sprites/effects/Symmetrical_impact_003.png", 7, 48, 48)

-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.COMMON)

object:set_sprite(sprite_effect)
object:set_depth(-10)

particleShrimp:set_shape(7)
particleShrimp:set_life(10, 10)
particleShrimp:set_speed(0, 0, 0, 0)
particleShrimp:set_size(0.1, 0.1, 0, 0.01)
particleShrimp:set_scale(6, 0.5)
particleShrimp:set_color2(Color.from_rgb(227, 111, 200), Color.from_rgb(87, 36, 94))
particleShrimp:set_alpha3(1, 1, 0)
particleShrimp:set_blend(1)

local max_turn_radius = 2.5

-- ===== Callbacks =====

local function set_missile_on_target(missile, target, speed) 
        local dx = target.x - missile.x
        local dy = target.y - missile.y
        local angle = math.deg(math.atan(dy, dx))
        angle = angle + (math.random(0,1)*2-1) * math.random(60, 90)

        if angle < 0 then
            angle = angle + 360
        elseif angle >= 360 then
            angle = angle - 360
        end
        missile.direction = angle

        local start_distance = 20 -- change this to whatever distance you want
        local rad = math.rad(angle)
        missile.x = missile.x + math.cos(rad) * start_distance
        missile.y = missile.y - math.sin(rad) * start_distance

        local distance = math.sqrt(dx*dx + dy*dy)
        local log_factor = 2
        missile.speed = 5 + (math.log(distance + 1))^1.1 * log_factor
    end

Callback.add(Callback.ON_HIT_PROC, function(attacker, target, hit_info)
    local stack = attacker:item_count(item)
    if stack <= 0 or attacker.shield <= 0 then return end
    
    missile_inst = Instance.create(attacker.x, attacker.y, object)
    local inst_data = Instance.get_data(missile_inst)
    missile_inst.direction = 180
    inst_data.target = target
    inst_data.duration = 600
    inst_data.parent = attacker
    inst_data.damage = stack * 0.4
    inst_data.last_x = attacker.x
    inst_data.last_y = attacker.y
    set_missile_on_target(missile_inst, target) 
    -- play animation and sound wooo
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

    if not Instance.exists(inst_data.target) then 
        inst:destroy()
    end

    particleShrimp:set_orientation(inst.direction, inst.direction, 0, 0, 0);
    particleShrimp:set_scale(inst.speed/3, 0.7)
    particleShrimp:create((inst.x + inst_data.last_x) / 2, (inst.y + inst_data.last_y) / 2, 1)

    local dx = inst_data.target.x - inst.x
    local dy = inst_data.target.y - inst.y

    local dist = math.sqrt(dx*dx + dy*dy)
    local desired = (360 - math.deg(math.atan(dy, dx))) % 360
    local diff = (desired - inst.direction + 180) % 360 - 180

    local turnBoost = 1 + (400 / math.max(dist,1)) -- +400 for more agressive finish
    local maxTurn = max_turn_radius * turnBoost

    if diff > maxTurn then diff = maxTurn end
    if diff < -maxTurn then diff = -maxTurn end
    inst.direction = (inst.direction + diff) % 360

    inst_data.last_x = inst.x
    inst_data.last_y = inst.y

    if dist < 10 then
        inst_data.parent:fire_direct(inst_data.target, inst_data.damage, 0, inst_data.target.x, inst_data.target.y, sprite_explosion_effect, false)
        inst:destroy()
        return
    end

    inst_data.duration = inst_data.duration - 1
    if inst_data.duration < 0 then
        inst:destroy()
    end

end)