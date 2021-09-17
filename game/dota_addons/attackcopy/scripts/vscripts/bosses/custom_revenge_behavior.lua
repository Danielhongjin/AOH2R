require("lib/my")


custom_revenge_behavior = class({})


function custom_revenge_behavior:GetIntrinsicModifierName()
	if not self:GetCaster():IsIllusion() then
		return "modifier_custom_revenge_behavior"
	end
end




LinkLuaModifier("modifier_custom_revenge_behavior", "bosses/custom_revenge_behavior.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_revenge_behavior = class({})


function modifier_custom_revenge_behavior:IsHidden()
    return true
end
function modifier_custom_revenge_behavior:IsPurgable()
	return false
end

if IsServer() then
	function modifier_custom_revenge_behavior:DeclareFunctions()
		return {
			MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
		}
	end
	function modifier_custom_revenge_behavior:OnCreated()
		self.parent = self:GetParent()
		self.parent:SetMana(0)
		self.ability = self:GetAbility()
		self.revengeAbility = self.parent:GetAbilityByIndex(16)
		self.revengeAbility:StartCooldown(3600)
		self.interval = self.ability:GetSpecialValueFor("interval")
		self.health_threshold = self.ability:GetSpecialValueFor("health_threshold")
		self.mana_regen_mult = self.ability:GetSpecialValueFor("mana_mult")
		self.parent_max_health = self.parent:GetMaxHealth()
		self.parent_previous_health = self.parent:GetHealth()
		self.disable_regen = self.ability:GetSpecialValueFor("disable_regen")
		self.mana_regen_percent = 0
		self.isDisabled = false
		
		self:StartIntervalThink(self.interval)
	end
	function modifier_custom_revenge_behavior:OnIntervalThink()
		local health_lost = ((self.parent_previous_health - self.parent:GetHealth()) / self.parent_max_health) * 100
		if self.health_threshold < health_lost then
			self.mana_regen_percent = (health_lost - self.health_threshold) * self.mana_regen_mult
		else
			self.mana_regen_percent = 0
		end
		if self.parent:IsStunned() or self.parent:IsSilenced() or self.parent:IsDisarmed() then
			self.mana_regen_percent = self.mana_regen_percent + self.disable_regen
		end 	
		if self.parent:GetManaPercent() > 98 then
			self.parent:Purge(false, true, false, true, false)
			self:getPissed()
			self.parent:SetMana(0)
		end
		self.parent_previous_health = self.parent:GetHealth()
		self.isDisabled = true
	end

	function modifier_custom_revenge_behavior:GetModifierTotalPercentageManaRegen()
		return self.mana_regen_percent
	end

	function modifier_custom_revenge_behavior:getPissed()
			self.revengeAbility:EndCooldown()
			self.parent:Heal(self.parent:GetMaxHealth() * 0.03, nil)
	end
end


