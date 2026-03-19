-- Ration (Used)

local item = Item.new("benthicBloom")


-- ===== Assets =====

local sprite = Sprite.new("item/benthicBloom", "~/assets/sprites/items/benthicBloom.png", 1, 16, 16)

-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.find("Void"))


-- ===== Callbacks =====

Callback.add(Callback.ON_STAGE_START, function()
    local actors = item:get_holding_actors()

    for _, actor in ipairs(actors) do
        local item_ready = Item.find("benthic")
        local stack_size = actor:item_count(item, Item.StackKind.NORMAL)
        
        local common_list = LootPool.find("common").available_drop_pool
        local uncommon_list = LootPool.find("uncommon").available_drop_pool
        local full_list = gm.ds_list_create()
        gm.ds_list_copy(full_list, common_list)

        for i=0, gm.ds_list_size(uncommon_list)-1 do 
            gm.ds_list_add(full_list, gm.ds_list_find_value(uncommon_list, i))
        end
        local pool_list = List.wrap(full_list)
        pool_list:delete_value(item.object_id)
        local common_nb = 0
        local uncommon_nb = 0

        --change 3 to 3x stack size
        while common_nb+uncommon_nb < 3* stack_size and pool_list:size() > 0 do
            --random item id from pool
            local obj_id = pool_list:get(math.random(pool_list:size())-1)
            local item_del = Item.wrap(gm.object_to_item(obj_id))
            --check if actor has item
            local item_count = actor:item_count(item_del)
            if item_count > 0 then 
                actor:item_take(item_del)
                if item_del.tier > 0 then
                    uncommon_nb = uncommon_nb + 1
                    local given_item, _ = LootPool.find("rare"):roll()
                    actor:item_give(given_item, 1, Item.StackKind.NORMAL)
                    
                else 
                    common_nb = common_nb + 1
                    local given_item, _ = LootPool.find("uncommon"):roll()
                    actor:item_give(given_item, 1, Item.StackKind.NORMAL)
                    if not pool_list:contains(given_item.object_id) then
                        pool_list:add(given_item.object_id)
                    end
                end
                if item_count == 1 then
                    pool_list:delete_value(obj_id)
                end
            else
                pool_list:delete_value(obj_id)
            end
        end
        pool_list:destroy()
    end
end)