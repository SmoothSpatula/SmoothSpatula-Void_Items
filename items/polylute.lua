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
object:set_depth(10)

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

function generate_curve_points(radius, curvature, steps)
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
        points[#points + 1] = {x = lx, y = ly}
    end

    return points
end

Callback.add(Callback.ON_HIT_PROC, function(attacker, target, hit_info)
    local count = attacker:item_count(item)
    if count <= 0 then return end --comment for testing or math.random(0, 99) > 25 then return end

    local actual_nb = math.min(count*3, 30) -- cap it or it lags quite a bit and looks worse
    for i=1, actual_nb do
        local inst = Instance.create(target.x, target.y, object)
        local inst_data = Instance.get_data(inst)
        inst_data.surface = -1
        inst_data.duration = 10

        local pts = generate_curve_points(
            15,
            3,   -- curvature
            12     -- number of segments
        )
        inst_data.pts = pts
        inst_data.target = target

    end

    -- play animation and sound wooo
end)

Callback.add(object.on_step, function(inst)
    local inst_data = Instance.get_data(inst)

    inst_data.duration = inst_data.duration - 1
    if inst_data.duration < 0 then
        inst:destroy()
    end

end)

-- duration is 15 frames
-- 1-2 first circle appears black with border
-- 2-8 the line travels 
-- 9 second circle appears, first circle is pink
-- 12 line is disapearing, second circle is pink
-- 15 end


Callback.add(object.ON_DRAW, function(inst)
    local inst_data = Instance.get_data(inst)
    
    if not Util.bool(gm.surface_exists(inst_data.surface)) then
        inst_data.surface = gm.surface_create(100, 100)
        gm.surface_set_target(inst_data.surface)
        gm.draw_set_color(Color.WHITE)
        local pts = inst_data.pts
        for i = 1, #pts - 1 do
            gm.draw_line(pts[i].x + 50, pts[i].y+50, pts[i + 1].x+50, pts[i + 1].y+50)
        end

        gm.draw_circle(pts[1].x + 50, pts[1].y + 50, 4, false)
        gm.draw_circle(pts[#pts].x + 50, pts[#pts].y + 50, 4, false)
        gm.draw_set_color(Color.PURPLE)
        gm.draw_circle(pts[1].x + 50, pts[1].y + 50, 3, false)
        gm.draw_circle(pts[#pts].x + 50, pts[#pts].y + 50, 3, false)
        gm.surface_reset_target()
    end
    gm.draw_set_alpha(1)
    -- change the x and y scale depending on the sprite size of the target
    local xscale = gm.sprite_get_width(inst_data.target.sprite_index) / 50
    local yscale = gm.sprite_get_height(inst_data.target.sprite_index) / 50

    gm.draw_surface_ext(inst_data.surface, 
        inst_data.target.x - 50*xscale, 
        inst_data.target.y -50*yscale, 
        xscale, yscale, 
        0, Color.WHITE, 1)
end)

