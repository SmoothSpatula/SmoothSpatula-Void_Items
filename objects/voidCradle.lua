-- Void Cradle

local spr_cradle = Sprite.new("voidCradle", "~/assets/sprites/objects/voidCradle.png", 10, 16, 36)

local spawn_cost    = 65
local spawn_weight  = 3
local spawn_rarity  = 1

-- Create loot pools
local loot_pools = {}
for i, identifier in ipairs{
    "voidCommon",
    "voidUncommon",
    "voidRare",
} do
    local tier = ItemTier.find(identifier)
    loot_pools[i] = LootPool.new_from_tier(tier)
end

-- The game has a TreasureWeights struct
-- but honestly it's not needed
local treasure_weights = {
    60, -- Common    60 %
    30, -- Uncommon  30 %
        -- Rare      10 %
}


-- ========== Objects ==========

local obj = Object.new("voidCradle", Object.Parent.INTERACTABLE)
obj:set_sprite(spr_cradle)
obj:set_depth(1)

local card = InteractableCard.new("voidCradle")
card.object_id                      = obj
card.required_tile_space            = 0
card.spawn_with_sacrifice           = true
card.spawn_cost                     = spawn_cost
card.spawn_weight                   = spawn_weight
card.default_spawn_rarity_override  = spawn_rarity
card.decrease_weight_on_spawn       = true


-- ========== Particles ==========

local spr_fire = Sprite.new("voidCradleFire", "~/assets/sprites/effects/sEfFireyVoid.png", 7, 4, 10)

local part_fire = Particle.new("voidCradleFire")
part_fire:set_sprite(spr_fire, true, true, false)
part_fire:set_size(0.6, 1, 0, 0)
part_fire:set_scale(2, 1)
part_fire:set_life(25, 30)
part_fire:set_speed(0.5, 1, -0.03, 0)
part_fire:set_direction(-180, 180, 0, 1)
part_fire:set_orientation(0, 0, 0, 0, 1)


-- ========== Callbacks ==========

Callback.add(obj.on_create, function(inst)
    inst:interactable_init()
    inst:interactable_init_name()

    inst.cost = 0.5
    inst.cost_type = 2  -- hp

    -- Set prompt text
    -- inst.translation_key = "interactable.voidCradle"
    -- inst.text = gm.translate(inst.translation_key..".text")
end)

Hook.add_post(gm.constants.interactable_pay_cost, function(self, other, result, args)
    if self:get_object_index() ~= obj.value then return end
    self.image_speed = 0.25
end)

Callback.add(obj.on_step, function(inst)
    if inst.active == 2 and inst.image_index >= 9 then
        local rng = math.random(1, 100)
        local index = 0
        local sum = 0
        for i, weight in ipairs(treasure_weights) do
            sum = sum + weight
            if rng <= sum then
                index = i
                break
            end
        end
        
        local pool = loot_pools[index]
        local item, pickup = pool:roll()

        local pos = Vector(inst.x, inst.y - 16)
        pickup:create(pos.x, pos.y)
        part_fire:create(pos.x, pos.y, 6)

        inst:destroy()
    end
end)

Hook.add_pre(gm.constants.run_create, function(self, other, result, args)
    local stages = Stage.find_all()
    for _, stage in ipairs(stages) do
        stage:add_interactable(card)
    end
end)


-- ========== Command ==========

Console.new{
    "spawn_cradle [count]",
    {
        "Spawns a void cradle(s) at the current mouse position.",
        {"[count]", "number", "The number of cradles to spawn. <y>1</c> by default."},
    },
    function(args)
        if Net.client then
            Console.print("Must be lobby host.")
            return
        end

        local count = 1
        if type(args[1]) == "number" then
            count = args[1]
        end

        local x, y = Global.mouse_x, Global.mouse_y
        for i = 1, count do
            Instance.create(x, y, obj)
        end
    end
}