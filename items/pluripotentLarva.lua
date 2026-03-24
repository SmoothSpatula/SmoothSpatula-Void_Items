-- Ration (Used)

local item = Item.new("pluripotentLarva")
local item_used = Item.new("pluripotentLarvaUsed")

-- ===== Assets =====

local sprite = Sprite.new("item/pluripotentLarva", "~/assets/sprites/items/pluripotentLarva.png", 1, 16, 16)
local sprite_used = Sprite.new("item/pluripotentLarva", "~/assets/sprites/items/pluripotentLarva.png", 1, 16, 16)

-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.find("voidRare"))
item_used:set_sprite(sprite_used)

local reviving_count = 0
local revivingUVs = {}
--revivingUVs[1] = {500, 500, 1000, 0}

-- ===== Callbacks =====


Hook.add_pre(gm.constants.actor_death, function(self, other, result, args)
    
    if self:item_count(item) <= 0 then return end

    if self.hp <= 0 then 
        self:heal(self.maxhp) 
        self.invincible = 180 
        self:item_take(item)
        --self:item_give(used_item)
        
        local cam = Global.view_camera
        local camX, camY = gm.camera_get_view_x(cam), gm.camera_get_view_y(cam)
        local camWidth, camHeight = gm.camera_get_view_width(cam), gm.camera_get_view_height(cam)

        -- Screen resolution
        local screenWidth, screenHeight = gm.display_get_width(), gm.display_get_height()

        -- World → screen (top-left = 0,0)
        local screenX = (self.x - camX) --/ camWidth * screenWidth
        local screenY = (self.y - camY) --/ camHeight * screenHeight

        print(screenX, screenY)

        --print(screenX, screenY)
        revivingUVs[self.id] = {screenX, screenY, 60, 1} -- time and scale
        reviving_count = reviving_count + 1

        -- add new animation

        for og, crpt in pairs(corruptions) do
            local original = Item.find(og)
            local count = self:item_count(original)
            if count>=1 then
                corrupted = Item.find(crpt)
                self:item_take(original, count)
                self:item_give(corrupted, count)

                local oHUD = gm.instance_find(gm.constants.oHUD, 0)
                oHUD:add_item_pickup_display_for_player(oHUD, 
                self.value,
                gm.translate(corrupted.token_name),
                gm.translate(corrupted.token_text),
                corrupted.sprite_id,
                1,
                corrupted.tier,
                false,
                false)
            end
        end
                
        return false
    end
end)


-- ===== Shaders =====

local shd_void_explosion = gm.find_shader_by_name("shd_void_explosion")
if shd_void_explosion > -1 then
    --gm.shader_replace(path.combine(_ENV["!plugins_mod_folder_path"], "shaders", "void_explosion"), "shd_void_explosion", shd_void_explosion)
else
    shd_void_explosion = gm.shader_add(path.combine(_ENV["!plugins_mod_folder_path"], "shaders", "void_explosion"), "shd_void_explosion")
end

local _uni_uvs = gm.shader_get_uniform(shd_void_explosion, "UVS")
local _uni_nb = gm.shader_get_uniform(shd_void_explosion, "NUM_UVS")

local my_surface = gm.surface_create(1920, 1080)
gm.post_code_execute("gml_Object_oInit_Draw_73", function()
    if reviving_count < 1 then return end
    local application_surface = gm.variable_global_get("application_surface")
    if gm.surface_exists(application_surface) then
        local app_surf_w = gm.surface_get_width(application_surface)
        local app_surf_h = gm.surface_get_height(application_surface)
        if not gm.surface_exists(my_surface) then
            my_surface = gm.surface_create(app_surf_w, app_surf_h)
        elseif app_surf_w ~= gm.surface_get_width(my_surface) or app_surf_h ~= gm.surface_get_height(my_surface) then
            gm.surface_free(my_surface)
            my_surface = gm.surface_create(app_surf_w, app_surf_h)
        end

        -- max number of UVs
        local MAX_UVS = 10
        local flat = gm.array_create(MAX_UVS * 4, 0)

        local count = 0
        for id, b in pairs(revivingUVs) do
            if count >= MAX_UVS then break end
            gm.array_set(flat, count*4 + 0, b[1] or 0) -- x
            gm.array_set(flat, count*4 + 1, b[2] or 0) -- y
            gm.array_set(flat, count*4 + 2, b[3] or 0) -- time
            gm.array_set(flat, count*4 + 3, b[4] or 0) -- size or padding
            count = count + 1

            revivingUVs[id][3] = b[3] - 1
            if b[3] < 0 then
                revivingUVs[id] = nil
            end
        end

        gm.surface_set_target(my_surface)
        gm.shader_set(shd_void_explosion)
        gm.shader_set_uniform_f_array(_uni_uvs, flat)
        gm.shader_set_uniform_i(_uni_nb, count)
        gm.draw_surface(application_surface, 0, 0)
        gm.shader_reset()
        gm.surface_reset_target()
        gm.surface_copy(application_surface, 0, 0, my_surface)
    end
end)


-- ===== Additional =====

ItemLog.new_from_item(item)