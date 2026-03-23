-- Ration

local item = Item.new("weepingFungus")
local particleFungus_center = Particle.new("weepingFungusParticleCenter")
local particleFungus_out = Particle.new("weepingFungusParticleMid")

-- ===== Assets =====

local sprite = Sprite.new("item/weepingFungus", "~/assets/sprites/items/weepingFungus.png", 1, 16, 16)


-- ===== Properties =====

local particle_fungus_dist = 6
local particle_life = 50

item:set_sprite(sprite)
item:set_tier(ItemTier.find("Void"))

particleFungus_center:set_shape(1)
particleFungus_center:set_life(particle_life, particle_life)
particleFungus_center:set_speed(0, 0, 0, 0)
particleFungus_center:set_color3(Color.from_rgb(192, 184, 250), Color.from_rgb(192, 184, 250), Color.FUCHSIA)
particleFungus_center:set_alpha3(1, 1, 0)
particleFungus_center:set_blend(0)
particleFungus_center:set_scale(0.07, 0.07)
particleFungus_center:set_speed(0.1, 0.1, 0, 0)

--
particleFungus_out:set_shape(1)
particleFungus_out:set_life(particle_life, particle_life)
particleFungus_out:set_speed(0, 0, 0, 0)
particleFungus_out:set_color3(Color.from_rgb(192, 184, 250), Color.from_rgb(192, 184, 250), Color.FUCHSIA)
particleFungus_out:set_alpha3(1, 1, 0)
particleFungus_out:set_blend(0)
particleFungus_out:set_scale(0.03, 0.03)
particleFungus_out:set_size(1, 1, -0.01, 0)
particleFungus_out:set_speed(0.1, 0.1, 0, 0)

-- ===== Callbacks =====

local function spawn_fungus_particle(actor)
    if (math.abs(actor.pHspeed) > 0.0 and not (actor.value.x_skill or actor.value.v_skill or actor.value.z_skill or actor.value.c_skill)) 
        or math.abs(actor.pHspeed) >= actor.pHmax - 0.2 then
        local x = actor.x
        local y = actor.y + math.random() * 15
        local dir = 270 - actor.image_xscale * 60
        particleFungus_center:set_direction(dir, dir, 0, 0)
        particleFungus_center:create(x, y, 1)
        for i=1, 8 do
            particleFungus_out:set_direction(dir, dir, 0, 0)
            particleFungus_out:create(x + math.cos(0.78539*i) * particle_fungus_dist, 
                                    y - math.sin(0.78539*i) * particle_fungus_dist, 1)
        end
    end
end


Callback.add(Callback.ON_SECOND, function()
    local actors = item:get_holding_actors()
    for _, actor in ipairs(actors) do
        if (math.abs(actor.pHspeed) > 0.0 and not (actor.value.x_skill or actor.value.v_skill or actor.value.z_skill or actor.value.c_skill)) 
        or math.abs(actor.pHspeed) >= actor.pHmax - 0.2 then
            actor:heal(actor.maxhp * 0.02 * actor:item_count(item))

            -- effect 1
            spawn_fungus_particle(actor)
            Alarm.add(20, spawn_fungus_particle, actor)
            Alarm.add(40, spawn_fungus_particle, actor)
        end
    end
end)

-- ===== Additional =====

ItemLog.new_from_item(item)