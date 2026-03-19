-- 2) Ukulele -> polylute -> 25% chance to fire lightning for 60% TOTAL damage up to 3 (+3 per stack) times. Corrupts all Ukuleles. Single target on the 

local item = Item.new("polylute")
--local object = Object.new("polyluteLightningEf")

-- ===== Assets =====

local sprite = Sprite.new("item/polylute", "~/assets/sprites/items/polylute.png", 1, 16, 16)
local sprite_effect = Sprite.new("effect/polyluteLightning", "~/assets/sprites/effects/tempEffect2.png",15, 32, 32)

-- https://bdragon1727.itch.io

-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.find("Void"))

-- object:set_sprite(sprite_effect)
-- object:set_depth(10)

local object = Object.find("shrimpMissileObject")
local particleShrimp = Particle.find("Shrimp")

local max_turn_radius = 1.2
local max_turn_radius_low = 1.1
local max_turn_radius_add = 0.5
local distance_from_target = 20

-- ===== Callbacks =====

Callback.add(Callback.ON_HIT_PROC, function(attacker, target, hit_info)
    local count = attacker:item_count(item)
    if count <= 0 or math.random(0, 99) > 25 then return end

    local actual_nb = math.min(count*3, 30) -- cap it or it lags quite a bit and looks worse

    for i=1, actual_nb do
        --positioning 
        local first_angle = math.random(0, 359)
        local rad = math.rad(first_angle)
        local missile_x = target.x + math.cos(rad) * distance_from_target
        local missile_y = target.y - math.sin(rad) * distance_from_target
        missile_inst = Instance.create(missile_x, missile_y, object)

        local second_angle = first_angle + (math.random(0,1)*2-1) * math.random(15, 90)
        missile_inst.direction = second_angle%360
        missile_inst.speed = math.random(3, 7)

        -- data
        local inst_data = Instance.get_data(missile_inst)
        inst_data.target = target
        inst_data.duration = 120
        inst_data.parent = attacker
        inst_data.damage = 0.6 *(count*3/actual_nb)
        inst_data.last_x = attacker.x
        inst_data.last_y = attacker.y
        --inst_data.max_turn_radius = max_turn_radius_low + math.random()*max_turn_radius_add
        inst_data.max_turn_radius = max_turn_radius
    end

    -- play animation and sound wooo
end)