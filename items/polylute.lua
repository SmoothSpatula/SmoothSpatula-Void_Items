-- 2) Ukulele -> polylute -> 25% chance to fire lightning for 60% TOTAL damage up to 3 (+3 per stack) times. Corrupts all Ukuleles. Single target on the 

local item = Item.new("polylute")
local object = Object.new("polyluteLightningEf")

-- ===== Assets =====

local sprite = Sprite.new("item/polylute", "~/assets/sprites/items/polylute.png", 1, 16, 16)
local sprite_effect = Sprite.new("effect/polyluteLightning", "~/assets/sprites/effects/tempEffect2.png",15, 32, 32)
local sprite_effect = Sprite.new("effect/polyluteOrb", "~/assets/sprites/effects/PolyluteOrb.png",1, 8, 8)

-- https://bdragon1727.itch.io

-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.find("Void"))

object:set_sprite(-1)
object:set_depth(-1)

local particlePolylute = Particle.new("Polylute")
particlePolylute:set_shape(7)
particlePolylute:set_life(300, 300)
particlePolylute:set_speed(0, 0, 0, 0)
particlePolylute:set_size(0.1, 0.1, 0, 0.01)
particlePolylute:set_scale(3, 0.5)
particlePolylute:set_color2(Color.from_rgb(255, 255, 255), Color.from_rgb(87, 36, 94))
particlePolylute:set_alpha3(1, 1, 0)
particlePolylute:set_blend(0)

local max_turn_radius = 2
local max_turn_radius_low = 1.1
local max_turn_radius_add = 0.5
local distance_from_target = 20

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

    local actual_nb = math.min(count*3, 30) -- cap it or it lags quite a bit and looks worse
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
    inst_data.count = count
    inst_data.all_pts = all_pts
    inst_data.target = target
    inst_data.parent = attacker
    
    -- play animation and sound wooo
end)

Callback.add(object.on_step, function(inst)
    local inst_data = Instance.get_data(inst)

    inst_data.duration = inst_data.duration - 1

    if inst_data.duration < 0 then
        if Util.bool(gm.surface_exists(inst_data.surface)) then
            gm.surface_free(inst_data.surface)
        end
        -- do the damage at the end location of the arcs
        for i=0, inst_data.count-1 do
            local pts = inst_data.all_pts[(i%(#inst_data.all_pts))+1]
            local attack = inst_data.parent:fire_direct(inst_data.target, 0.6, 0, 
                pts[#pts].x + inst_data.target.x, pts[#pts].y + inst_data.target.y, 
                gm.constants.sSparks1, false)

            --print(attack.attack_info)
        end

        inst:destroy()
    end

end)

-- duration is 15 frames
-- 1-2 first circle appears black with border
-- 2-8 the line travels 
-- 9 second circle appears, first circle is pink
-- 12 line is disapearing, second circle is pink
-- 15 end

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
                gm.draw_set_color(Color.PURPLE)
                gm.draw_line(pts[i-1].x + size_x, pts[i-1].y + size_y, pts[i].x+ size_x, pts[i].y + size_y)
            end
                gm.draw_set_color(Color.WHITE)
                gm.draw_line(pts[i].x + size_x, pts[i].y + size_y, pts[i + 1].x+ size_x, pts[i + 1].y + size_y)
            if i < 12 then
                gm.draw_set_color(Color.WHITE)
                gm.draw_line(pts[i+1].x + size_x, pts[i+1].y + size_y, pts[i + 2].x+ size_x, pts[i + 2].y + size_y)
            end

            if i < 4 then
                gm.draw_set_color(Color.WHITE)
                gm.draw_circle(pts[1].x + size_x, pts[1].y + size_y, 4, false)
                gm.draw_set_color(Color.BLACK)
                gm.draw_circle(pts[1].x + size_x, pts[1].y + size_y, 3, false)
            elseif i < 7 then 
                gm.draw_set_color(Color.FUCHSIA)
                gm.draw_circle(pts[1].x + size_x, pts[1].y + size_y, 4, false)
                gm.draw_set_color(Color.WHITE)
                gm.draw_circle(pts[#pts].x + size_x, pts[#pts].y + size_y, 4, false)
                gm.draw_set_color(Color.BLACK)
                gm.draw_circle(pts[#pts].x + size_x, pts[#pts].y + size_y, 3, false)
            elseif i < 13 then
                gm.draw_set_color(Color.FUCHSIA)
                gm.draw_circle(pts[#pts].x + size_x, pts[#pts].y + size_y, 4, false)
                
            end
        end
    
        gm.surface_reset_target()
    end
    gm.draw_set_alpha(1)
    -- change the x and y scale depending on the sprite size of the target

    gm.draw_surface_ext(inst_data.surface, 
        inst_data.target.x - size_x, 
        inst_data.target.y - size_y, 
        1, 1, 
        0, Color.WHITE, 1)
end)

