-- Void Items

mods["LuaENVY-ENVY"].auto()
mods["ReturnsAPI-ReturnsAPI"].auto{
    namespace = "vi",
}

PATH = _ENV["!plugins_mod_folder_path"]

corruptions = {
    willOTheWisp = "voidsentFlame",
    ukulele = "polylute",
    toughTimes = "saferSpaces",
    atgMissileMk1 = "plasmaShrimp",
    diosFriend = "pluripotentLarva",
    bustlingFungus = "weepingFungus",
    energyCell = "lysateCell",
    rustyKnife = "needleTick",
    lensMakersGlasses = "lostSeersLenses"
}
corruptions["56LeafClover"] = "benthicBloom" --freaking lua man, malformed number near '56L'


Initialize.add_hotloadable(function()    
    -- Create item tiers
    for _, data in ipairs{
        {"voidCommon",   nil,                      nil},
        {"voidUncommon", Global.pItemTierUncommon, {{0, 11}, {120, 11}, {240, 11}}},
        {"voidRare",     Global.pItemTierRare,     {{0, 12}, {90, 12}, {180, 12}, {270, 12}}},
    } do
        local tier = ItemTier.new(data[1])
        tier.text_color          = "p"
        tier.pickup_color        = Color(0xd183d7)
        tier.pickup_color_bright = Color(0xd183d7)
        if data[2] then tier.pickup_particle_type = data[2] end
        if data[3] then tier:set_head_shape(data[3]) end
    end

    -- Require all files in content folders
    local folders = {
        "buffs",
        "items",
        "objects",
    }
    for _, folder in ipairs(folders) do
        local names = path.get_files(path.combine(PATH, folder))
        for _, name in ipairs(names) do require(name) end
    end

    -- Corruption logic
    Callback.add(Callback.ON_PICKUP_COLLECTED, function(pickup, actor)
        --Instance.wrap(pickup):print_variables()
        local item = Item.wrap(pickup.item_id)
        if item.namespace == "vi" then
            for i, v in pairs(corruptions) do
                if v == item.identifier then
                    local original_item = Item.find(i)
                    local count = actor:item_count(original_item)
                    actor:item_take(original_item, count)
                    actor:item_give(item, count)
                end
            end
            return
        end

        local corrupted = corruptions[item.identifier]
        if corrupted == nil then return end
        local corrupted_item = Item.find(corrupted)
        if actor:item_count(Item.find(corrupted)) >= 1 then
            pickup.item_id = gm.item_find(corrupted)
            pickup.text1 = Item.find(corrupted)
            pickup.text1_key = "item."..corrupted..".name"
            pickup.text2 = corrupted_item.token_text
            pickup.on_collect = corrupted_item.on_acquired
            pickup.show_pickup_display = true
        end
    end)
end)

-- this is just here to fix the display to show the corrupted item
Hook.add_pre(gm.constants['add_item_pickup_display_for_player@gml_Object_oHUD_Create_0'], function(self, other, result, args)
    if gm.typeof(args[2].value) == "number" then
        local item = Item.wrap(args[2].value)
        args[2].value = gm.translate(item.token_name)
        args[3].value = gm.translate(item.token_text)
        args[4].value = item.sprite_id
    end
end)