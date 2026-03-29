-- 2) Ukulele -> polylute -> 25% chance to fire lightning for 60% TOTAL damage up to 3 (+3 per stack) times. Corrupts all Ukuleles. Single target on the 

local item = Item.new("polylute")
local object = Object.new("polyluteLightningEf")

-- ===== Assets =====

local sprite = Sprite.new("item/polylute", "~/assets/sprites/items/polylute.png", 1, 16, 16)
local sprite_effect = Sprite.new("effect/polyluteLightning", "~/assets/sprites/effects/tempEffect2.png",15, 32, 32)
local sprite_effect = Sprite.new("effect/polyluteOrb", "~/assets/sprites/effects/PolyluteOrb.png",1, 8, 8)

-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.find("voidUncommon"))

object:set_sprite(-1)
object:set_depth(-1)

local max_turn_radius = 2
local max_turn_radius_low = 1.1
local max_turn_radius_add = 0.5
local distance_from_target = 20

local damage_color = Color(0xd183d7)

-- ===== Callbacks =====

function generate_curve_points(radius, curvature, steps, size_x, size_y)
    local points = {}

    -- generate random start point on circle around origin
    local angle_start = math.random() * 2 * math.pi
    local sx = math.cos(angle_start) * radius
    local sy = math.sin(angle_start) * radius

    -- distance and angle for curve offset
    local angle = math.atan(sy, sx)
    local dist = math.sqrt(sx*sx + sy*sy)

    -- random 120° offset
    local offset = math.rad(math.random(120, 120))
    if math.random() < 0.5 then offset = -offset end
    local end_angle = angle + offset

    -- end point
    local ex = math.cos(end_angle) * dist
    local ey = math.sin(end_angle) * dist

    -- midpoint
    local mx = (sx + ex) * 0.5
    local my = (sy + ey) * 0.5

    -- perpendicular
    local px = -(ey - sy)
    local py = (ex - sx)
    local len = math.sqrt(px*px + py*py)
    px = px / len
    py = py / len

    -- force outward
    local dot = px * (-mx) + py * (-my)
    if dot > 0 then
        px = -px
        py = -py
    end

    -- control point
    local cx = mx + px * dist * curvature
    local cy = my + py * dist * curvature

    -- sample curve
    for i = 0, steps do
        local t = i / steps
        local u = 1 - t
        local lx = u*u*sx + 2*u*t*cx + t*t*ex
        local ly = u*u*sy + 2*u*t*cy + t*t*ey

        local scaled_x = math.floor(lx * size_x / 50)
        local scaled_y = math.floor(ly * size_y / 50)
        points[#points + 1] = {x = scaled_x, y = scaled_y}
    end

    return points
end

Callback.add(Callback.ON_HIT_PROC, function(attacker, target, hit_info)
    local count = attacker:item_count(item)
    if count <= 0 or math.random(1, 100) > 25 then return end

    local actual_nb = math.min(count*3, 15) -- cap it or it will get too busy imo
    local inst = Instance.create(target.x, target.y, object)
    local inst_data = Instance.get_data(inst)
    inst_data.surface = -1
    inst_data.duration = 25


    local size_x = gm.sprite_get_width(target.sprite_index)
    local size_y = gm.sprite_get_height(target.sprite_index)
    inst_data.size_x = size_x
    inst_data.size_y = size_y
    local all_pts = {}
    for i=1, actual_nb do
        all_pts[i] = generate_curve_points(15,2,12, size_x, size_y)
    end
    inst_data.damage = hit_info.attack_info.damage * 0.6 * count
    inst_data.all_pts = all_pts
    inst_data.target = target
    inst_data.parent = attacker
    inst_data.angle = {}
    for i = 0, 4 do
        inst_data.angle[i*2+1] = math.cos(math.random() * 6.242) * 4
        inst_data.angle[i*2+2] = math.sin(math.random() * 6.242) * 4
    end
    -- play animation and sound wooo
end)

Callback.add(object.on_step, function(inst)
    local inst_data = Instance.get_data(inst)
    inst_data.duration = inst_data.duration - 1
    if inst_data.duration < 0 then
        if Util.bool(gm.surface_exists(inst_data.surface)) then
            gm.surface_free(inst_data.surface)
        end

        -- do the damage at the end location of the arcs (actually it doesnt I can't do that here)
        for i = 1, 3 do
            local attack_info = inst_data.parent:fire_direct(inst_data.target, inst_data.damage, 0, 
                inst_data.target.x, inst_data.target.y, gm.constants.sSparks1, false).attack_info
            attack_info:use_raw_damage()
            if Util.bool(attack_info.critical) then attack_info:set_critical(false) end
            attack_info.climb = (i - 1) * 10
            attack_info.damage_color = damage_color
        end
        inst:destroy()
    end

end)

-- duration is 25/2 frames
-- 1-2 first circle appears black with border
-- 2-12 the line travels 
-- 4 second circle appears, first circle is pink
-- 7 line is disapearing, second circle is pink
-- 12 end

local COLOR_PINK = Color.from_rgb(188, 143, 143)

Callback.add(object.ON_DRAW, function(inst)
    local inst_data = Instance.get_data(inst)
    local size_x = inst_data.size_x
    local size_y = inst_data.size_y

    if not Util.bool(gm.surface_exists(inst_data.surface)) then
        inst_data.surface = gm.surface_create(size_x*2, size_y*2)
    else
        gm.surface_set_target(inst_data.surface)
        gm.draw_clear_alpha(Color.BLACK,0)
        gm.draw_set_color(Color.WHITE)
        
        local i = 12 -  math.floor(inst_data.duration/2)
        for j=1, #inst_data.all_pts do
            local pts = inst_data.all_pts[j]
            gm.draw_set_color(Color.WHITE)

            if i > 1 then 
                gm.draw_set_color(Color.WHITE)
                gm.draw_line(pts[i-1].x + size_x, pts[i-1].y + size_y, pts[i].x+ size_x, pts[i].y + size_y)
            end
            gm.draw_set_color(Color.WHITE)
            gm.draw_line(pts[i].x + size_x, pts[i].y + size_y, pts[i + 1].x+ size_x, pts[i + 1].y + size_y)
            if i < 12 then
                gm.draw_set_color(Color.PURPLE)
                gm.draw_line(pts[i+1].x + size_x, pts[i+1].y + size_y, pts[i + 2].x+ size_x, pts[i + 2].y + size_y)
            end

            if i < 4 then -- first circle
                gm.draw_set_color(Color.WHITE)
                gm.draw_circle(pts[1].x + size_x, pts[1].y + size_y, 4, false)
                gm.draw_set_color(Color.BLACK)
                gm.draw_circle(pts[1].x + size_x, pts[1].y + size_y, 3, false)
            elseif i < 7 then -- both circles
                gm.draw_set_color(Color.FUCHSIA)
                gm.draw_circle(pts[1].x + size_x, pts[1].y + size_y, 4, false)
                gm.draw_set_color(Color.WHITE)
                gm.draw_circle(pts[#pts].x + size_x, pts[#pts].y + size_y, 4, false)
                gm.draw_set_color(Color.BLACK)
                gm.draw_circle(pts[#pts].x + size_x, pts[#pts].y + size_y, 3, false)
            elseif i < 13 then -- second circle and explosion lines
                local angle = inst_data.angle
                gm.draw_set_color(Color.FUCHSIA)
                gm.draw_circle(pts[#pts].x + size_x, pts[#pts].y + size_y, 4, false) 

                gm.draw_set_color(Color.FUCHSIA)
                for k = 0, 4 do
                    gm.draw_line(pts[#pts].x + size_x, pts[#pts].y + size_y, 
                        pts[#pts].x + size_x + inst_data.angle[k*2+1] * (i-7),
                        pts[#pts].y + size_y + inst_data.angle[k*2+2] * (i-7))
                end
            end
        end
        gm.surface_reset_target()
    end
    gm.draw_set_alpha(1)
    gm.draw_surface_ext(inst_data.surface, 
        inst_data.target.x - size_x, 
        inst_data.target.y - size_y, 
        1, 1, 
        0, Color.WHITE, 1)
end)

-- ===== Additional =====

ItemLog.new_from_item(item)