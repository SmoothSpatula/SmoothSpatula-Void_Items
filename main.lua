-- Void Items

mods["LuaENVY-ENVY"].auto()
mods["ReturnsAPI-ReturnsAPI"].auto{
    namespace = "vi",
    mp        = true
}

PATH = _ENV["!plugins_mod_folder_path"]


Initialize.add_hotloadable(function()    
    -- Require all files in content folders
    local folders = {
        "items",
        "buffs",
        "objects",
    }

    for _, folder in ipairs(folders) do
        local names = path.get_files(path.combine(PATH, folder))
        for _, name in ipairs(names) do require(name) end
    end

    local corruptions = {
        willOTheWisp = "voidsentFlames",
        ukulele = "polylute",
        tougherTimes = "saferSpaces",
        atgMissileMk1 = "plasmaShrimp"
       
    }


    -- corruption logic
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
gm.pre_script_hook(gm.constants['add_item_pickup_display_for_player@gml_Object_oHUD_Create_0'], function(self, other, result, args)
    if gm.typeof(args[2].value) == "number" then
        local item = Item.wrap(args[2].value)
        args[2].value = item.token_name
        args[4].value = item.sprite_id
    end
end)