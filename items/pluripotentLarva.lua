-- Ration (Used)

local item = Item.new("pluripotentLarva")


-- ===== Assets =====

local sprite = Sprite.new("item/pluripotentLarva", "~/assets/sprites/items/pluripotentLarva.png", 1, 16, 16)

-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.find("Void"))

-- ===== Callbacks =====


Hook.add_pre(gm.constants.actor_death, function(self, other, result, args)
    
    if self:item_count(item) <= 0 then return end
    if self.hp <= 0 then 
        self:heal(self.maxhp) 
        self.invincible = 180 
        self:item_take(item)
        --self:item_give(used_item)
        gm.__rpc_item_proc_dios_friend_implementation__(self.value)
        -- add new animation

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
                
        return false
    end
end)

-- ===== Additional =====

ItemLog.new_from_item(item)