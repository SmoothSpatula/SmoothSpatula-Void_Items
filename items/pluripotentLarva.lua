-- Ration (Used)

local item = Item.new("pluripotentLarva")
local item_used = Item.new("pluripotentLarvaUsed")

-- ===== Assets =====

local sprite = Sprite.new("item/pluripotentLarva", "~/assets/sprites/items/pluripotentLarva.png", 1, 16, 16)
local sprite_used = Sprite.new("item/pluripotentLarvaUsed", "~/assets/sprites/items/pluripotentLarvaUsed.png", 1, 16, 16)

local sound = Sound.new("item/pluripotentLarva", "~/assets/sounds/items/pluripotentLarva.ogg")

-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.find("voidRare"))
item_used:set_sprite(sprite_used)

local reviving_count = 0
local revivingUVs = {}

-- ===== Network ===== --

local packetPluriDeath = Packet.new("packetPluriDeath")

local function add_to_uvs(actor)
    revivingUVs[actor.id] = {actor, 60, 1} -- time and scale
    reviving_count = reviving_count + 1
    if Net.online and Net.host then
		packetPluriDeath:send_to_all(actor)
	end
end

local pluriDeath_serializer = function(buffer, actor)
	buffer:write_instance(actor)
end
local pluriDeath_deserializer = function(buffer)
	local actor = buffer:read_instance()
	if not Instance.exists(actor) then return end
	add_to_uvs(actor)
end

packetPluriDeath:set_serializers(pluriDeath_serializer, pluriDeath_deserializer)

-- ===== Callbacks =====

function get_pixel_position(inst)
    local cam = Global.view_camera
    local camX, camY = gm.camera_get_view_x(cam), gm.camera_get_view_y(cam)
    local camWidth, camHeight = gm.camera_get_view_width(cam), gm.camera_get_view_height(cam)

    local screenWidth, screenHeight = gm.display_get_width(), gm.display_get_height()
    return (inst.x - camX), (inst.y - camY) -- camHeight * screenHeight
end

Hook.add_pre(gm.constants.actor_death, function(self, other, result, args)
    
    if self:item_count(item) <= 0 then return end

    if ((self.hp <= 0 and Net.host and self.actor_state_current_id ~= 1) 
        or Util.bool(args[1].value)) and not self.dead then
        self:heal(self.maxhp) 
        self.invincible = 180 
        self:item_take(item)
        self:item_give(item_used)
        
        add_to_uvs(self) -- networked

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

        -- Sfx
        sound:play_synced(self.x, self.y, 0.9)
                
        return false
    end
end)


-- ===== Shaders =====

local shd_void_explosion = gm.shader_add(path.combine(_ENV["!plugins_mod_folder_path"], "shaders", "void_explosion"), "shd_void_explosion")

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
            screenX, screenY = get_pixel_position(b[1])
            gm.array_set(flat, count*4 + 0, screenX or 0) -- x
            gm.array_set(flat, count*4 + 1, screenY or 0) -- y
            gm.array_set(flat, count*4 + 2, b[2] or 0) -- time
            gm.array_set(flat, count*4 + 3, b[3] or 0) -- size or padding
            count = count + 1

            revivingUVs[id][2] = b[2] - 1
            if b[2] < 0 then
                revivingUVs[id] = nil
            end
        end

        gm.surface_set_target(my_surface)
        gm.gpu_set_blendenable(false)
        gm.shader_set(shd_void_explosion)
        gm.shader_set_uniform_f_array(_uni_uvs, flat)
        gm.shader_set_uniform_i(_uni_nb, count)
        gm.draw_surface(application_surface, 0, 0)
        gm.shader_reset()
        gm.surface_reset_target()
        gm.surface_copy(application_surface, 0, 0, my_surface)
        gm.gpu_set_blendenable(true)
    end
end)


-- ===== Additional =====

ItemLog.new_from_item(item)