
item_tome_selling = class({})


function item_tome_selling:OnSpellStart()
local caster = self:GetCaster()
	if caster:IsRealHero() then
		for itemSlot = 0, 8 do
        local item = caster:GetItemInSlot(itemSlot)
		if item then
			if item:IsSellable() then
				caster:ModifyGold(item:GetCost(), true, 6)
				item:Destroy()
			end
		end
    end
	end
	self:SpendCharge()
end

