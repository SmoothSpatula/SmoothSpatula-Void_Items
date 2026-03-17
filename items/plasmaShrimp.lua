-- 6) AtG Missile Launcher -> Plasma Shrimp -> Gain a shield equal to 10% of your maximum health. While you have a shield, hitting an enemy fires a missile that deals 40% (+40% per stack) TOTAL damage

local item = Item.new("plasmaShrimp")

-- ===== Assets =====

local sprite = Sprite.new("item/ration", "~/assets/sprites/items/ration.png", 1, 16, 16)

-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.COMMON)

-- ===== Callbacks =====

local function set_missile_on_target(missile, target) 
        local dx = target.x - missile.x
        local dy = target.y - missile.y
        local angle = math.deg(math.atan(dy, dx))
        angle = angle + 15

        if angle < 0 then
            angle = angle + 360
        elseif angle >= 360 then
            angle = angle - 360
        end
        missile.direction = angle
    end

Callback.add(Callback.ON_HIT_PROC, function(attacker, target, hit_info)
    local stack = attacker:item_count(item)
    if stack <= 0 or attacker.shield <= 0 then return end
    
    missile_inst = Instance.create(attacker.x, attacker.y, gm.constants.oEfMissile)
    missile_inst.speed = 5
    missile_inst.damage = attacker.damage * 0.4 * stack
    missile_inst.image_xscale = 1
    missile_inst.image_yscale = 1

    missile_inst:print_variables()

    --Util.table_print(missile_inst.value)

    --set_missile_on_target(missile_inst, target)

    -- Alarm.add(1, 
    -- end, missile_inst, target)


    -- play animation and sound wooo
end)

RecalculateStats.add(function(actor, api)
    -- Check buff count
    local stack = actor:item_count(item)
    if stack <= 0 then return end

    -- Add stats
    api.maxshield_add_from_maxhp(0.1)
end)