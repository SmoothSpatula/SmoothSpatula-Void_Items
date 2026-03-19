local sCradle = Sprite.new("voidCradle", "~/assets/sprites/objects/voidCradle.png", 1, 10, 25)

local itemTier = ItemTier.find("Void")
local lootPool = LootPool.new_from_tier(itemTier) -- doesnt add the items

-- lootPool:add_item(Item.find("pluripotentLarva")) dont work

local lootList = List.wrap(lootPool.available_drop_pool)

for k, v in pairs(corruptions) do
    lootList:add(Item.find(v).object_id)
end

local spawn_cost            = 10
local spawn_weight          = 4
local spawn_rarity          = 1

-- ========== Objects ==========

local obj = Object.new("voidCradle", Object.Parent.INTERACTABLE)
obj:set_sprite(sCradle)
obj:set_depth(1)

local card = InteractableCard.new("scrapper")
card.object_id                      = obj
card.required_tile_space            = 0
card.spawn_with_sacrifice           = true
card.spawn_cost                     = spawn_cost
card.spawn_weight                   = spawn_weight
card.default_spawn_rarity_override  = spawn_rarity
card.decrease_weight_on_spawn       = true

-- Callbacks

Callback.add(obj.on_create, function(inst)
    --inst.is_scrapper = true     -- Flag for other crate-related mods
    inst.cost = 0.5
    inst.cost_type = 2.0

    -- Set prompt text
    inst.translation_key = "interactable.voidCradle"
    inst.text = gm.translate(inst.translation_key..".text")
end)

Hook.add_pre(gm.constants.interactable_check_cost, function(self, other, result, args)
    --print("test")
end)

Hook.add_post(gm.constants.interactable_pay_cost, function(self, other, result, args)
    if self:get_object_index() ~= obj.value then return end

    local inst_data = Instance.get_data(self)
    local actor = args[3].value

    print(lootPool:roll())
    local item, pickup = lootPool:roll() -- the pickup from this doesnt work?
    print(pickup.value)
    local pickup = Object.wrap(item.object_id)
    pickup:create(self.x, self.y)
    result.value = false
    self.active = 2.0

    -- change the sprite to get the opening animation before it destroys itself
    Alarm.add(10, function(self) self:destroy() end, self)
end)

Hook.add_pre(gm.constants.run_create, function(self, other, result, args)
    local stages =Stage.find_all()
    for id=0, #stages-1 do
        local stage = Stage.wrap(id)
        stage:add_interactable(card)
    end
end)

-- local oP = Instance.find(gm.constants.oP)

-- obj:create(oP.x, oP.y)