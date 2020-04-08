require("lib/my")


custom_nyx_behavior = class({})


function custom_nyx_behavior:GetIntrinsicModifierName()
	if not self:GetCaster():IsIllusion() then
		return "modifier_custom_nyx_behavior"
	end
end




LinkLuaModifier("modifier_custom_nyx_behavior", "bosses/custom_nyx_behavior.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_nyx_behavior = class({})


function modifier_custom_nyx_behavior:IsHidden()
    return true
end
function modifier_custom_nyx_behavior:IsPurgable()
	return false
end

if IsServer() then


function modifier_custom_nyx_behavior:OnCreated()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.nyxAbility = self.parent:GetAbilityByIndex(2)
	self.interval = self.ability:GetSpecialValueFor("interval")
	self.health_threshold = self.ability:GetSpecialValueFor("health_threshold")
	self.flippedIntermediate = true
	self.notFlipped = true
	self.ancient = Entities:FindByName(nil, "dota_goodguys_fort")
	self:StartIntervalThink(self.interval)
end
function modifier_custom_nyx_behavior:OnIntervalThink()
	if self.flippedIntermediate then
		if self.notFlipped then
			if self.parent:GetHealthPercent() < self.health_threshold then
				self.notFlipped = false
				
			end
		else	
			self.parent:Purge(false, true, false, true, false)
			find_item(self.parent, "item_black_king_bar_boss"):CastAbility()
			self.parent:CastAbilityNoTarget(self.nyxAbility, -1)
			ExecuteOrderFromTable({
				UnitIndex = self.parent:entindex(), 
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = self.ancient:entindex()
			})
			self.flippedIntermediate = false
		end
	else 
		ExecuteOrderFromTable({
            UnitIndex = self.parent:entindex(), 
            OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
            TargetIndex = self.ancient:entindex()
        })
	end
end


end


