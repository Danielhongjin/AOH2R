require("lib/my")



function copy_level(target, illusion)
    local level = target:GetLevel()
    for i = 1, level - 1 do
        illusion:HeroLevelUp(false)
    end
end


function copy_skill_level(target, illusion, copy_ultimate)
    illusion:SetAbilityPoints(0)
    for slot = 0, 15 do
        local ability = target:GetAbilityByIndex(slot)
        if ability ~= nil and ability:GetCastPoint() ~= 1337 then
            if ability:GetAbilityType() ~= 1 or copy_ultimate then  -- Not ultimate.
                local abilityLevel = ability:GetLevel()
                local abilityName = ability:GetAbilityName()
                local illusionAbility = illusion:FindAbilityByName(abilityName)
                illusionAbility:SetLevel(abilityLevel)
            end
        end
    end
end


function copy_items(target, illusion)
    for itemSlot = 0, 5 do
        local item = target:GetItemInSlot(itemSlot)
        if item ~= nil and item:GetName() ~= "item_pharaoh_crown" and item:GetCastPoint() ~= 1337 then
            local itemName = item:GetName()
            local newItem = CreateItem(itemName, illusion, illusion)
            illusion:AddItem(newItem)
        end
    end
end


function disable_inventory(illusion)
    illusion:SetHasInventory(false)
	illusion:SetCanSellItems(false)
end


function set_vision(illusion)
    illusion:SetDayTimeVisionRange(0)
    illusion:SetNightTimeVisionRange(0)
end


function kill_illusion(illusion)
    if not illusion:IsIllusion() then
        illusion:MakeIllusion()
    end
    illusion:ForceKill(false)
end
