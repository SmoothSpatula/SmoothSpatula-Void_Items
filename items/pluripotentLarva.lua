-- Ration (Used)

local item = Item.new("pluripotentLarva")


-- ===== Assets =====

local sprite = Sprite.new("item/rationUsed", "~/assets/sprites/items/rationUsed.png", 1, 16, 16)

-- ===== Properties =====

item:set_sprite(sprite)
item:set_tier(ItemTier.COMMON)


-- ===== Callbacks =====


Hook.add_pre(gm.constants.actor_death, function(self, other, result, args)
    
    if self:item_count(item) <= 0 then return end
    if self.hp <= 0 then 
        self:heal(self.maxhp) 
        self.invincible = 180 
        self:item_take(item)
        gm.__rpc_item_proc_dios_friend_implementation__(self.value)
        -- add new animation
        -- make other items corrupted, might wait for the full list
        return false
    end
end)

