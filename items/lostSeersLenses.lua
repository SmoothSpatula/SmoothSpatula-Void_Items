-- Len's Maker's Glasses -> Lost Seer's Lenses -> Your attacks have a 0.5% (+0.5% per stack) chance to instantly kill a non-Boss enemy. 

local item = Item.new("lostSeersLenses")
local object = Object.new("lensesVoidEf")
local particleSeer = Particle.new("lostSeersLensesParticle")

-- ===== Assets =====

-- when shaders get fixed this will work
-- print(path.combine(_ENV["!plugins_mod_folder_path"], "shaders", "void_explosion"))
-- local shd_void_explosion = gm.shader_add(path.combine(_ENV["!plugins_mod_folder_path"], "shaders", "void_explosion"), "shd_void_explosion")

-- local _uni_time  = gm.shader_get_uniform(shd_void_explosion, "u_time")
-- local _uni_scale = gm.shader_get_uniform(shd_void_explosion, "u_scale")
-- local _uni_seed  = gm.shader_get_uniform(shd_void_explosion, "u_seed")

local sprite = Sprite.new("item/lostSeersLenses", "~/assets/sprites/items/lostSeersLenses.png", 1, 16, 16)

local effect_sprite = Sprite.new("item/seerEffect", "~/assets/sprites/effects/100x108frames30.png", 30, 50, 54)


-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.find("Void"))

object:set_sprite(effect_sprite)
effect_sprite:set_speed(1)
object:set_depth(-11)


particleSeer:set_shape(0)
particleSeer:set_life(60, 80)
particleSeer:set_speed(2, 2, -0.05, 0.05)
--particleSeer:set_size(0.2, 0.2, -0.005, 0.005)
particleSeer:set_scale(30, 30)
particleSeer:set_color2(Color.from_rgb(219, 100, 205), Color.from_rgb(255, 255, 255))
particleSeer:set_alpha3(1, 1, 1)
particleSeer:set_blend(0)


-- ===== Callbacks =====

Callback.add(Callback.ON_HIT_PROC, function(attacker, target, hit_info)
    if attacker:item_count(item) <= 0 or gm.object_get_parent(target.object_index) == gm.constants.pBoss then return end
    
    if math.random(0, 200) < attacker:item_count(item) then
        local inst = Instance.create(target.x, target.y, object)
        local inst_data = Instance.get_data(inst)
        inst_data.surface = -1
        inst_data.duration = 40
        inst_data.size_x = gm.sprite_get_width(target.sprite_index)
        inst_data.size_y = gm.sprite_get_height(target.sprite_index)


        Alarm.add(1, function(target) target:kill() end, target) 
    end
    -- play animation and sound wooo
end)


Callback.add(object.on_step, function(inst)
    inst.image_alpha = 0.8
    local inst_data = Instance.get_data(inst)

    inst_data.duration = inst_data.duration - 1

    if inst_data.duration == 15 then
        
        for i=1, 20 do
            --print()
            particleSeer:set_speed(1, 3, 0, 0)
            particleSeer:set_direction(0, 360, 0, 5)
            particleSeer:create(inst.x, inst.y, 1)
        end
    end
    if inst_data.duration < 10 then
        inst.image_alpha = 0
    end
    if inst_data.duration < 0 then
        inst:destroy()
    end
    

end)

-- ===== Additional =====

ItemLog.new_from_item(item)

-- Callback.add(object.ON_DRAW, function(inst)
--     local inst_data = Instance.get_data(inst)
--     local size_x = inst_data.size_x
--     local size_y = inst_data.size_y

--     if not Util.bool(gm.surface_exists(inst_data.surface)) then
--         inst_data.surface = gm.surface_create(size_x*4, size_y*4)
--     else
--         gm.surface_set_target(inst_data.surface)
--         gm.draw_clear_alpha(Color.BLACK,0)

        
        
--         -- local i = 20 - inst_data.duration
--         -- gm.draw_set_color(Color.FUCHSIA)
--         -- for j = 1, 4 do
--         --     gm.draw_circle(size_x*2, size_y*2, i*6+j, true)
--         -- end
--         -- gm.draw_circle(size_x*2, size_y*2, )


--         --         gm.draw_line(pts[i-1].x + size_x, pts[i-1].y + size_y, pts[i].x+ size_x, pts[i].y + size_y)
--         --         gm.draw_circle(pts[1].x + size_x, pts[1].y + size_y, 4, false)
--         --         gm.draw_ellipse(x1, y1, x2, y2, outline)
--         gm.surface_reset_target()
--     end
--     gm.draw_set_alpha(1)
--     -- change the x and y scale depending on the sprite size of the target

--     gm.draw_surface_ext(inst_data.surface, 
--         inst.x - size_x*2, 
--         inst.y - size_y*2, 
--         1, 1, 
--         0, Color.WHITE, 1)
-- end)