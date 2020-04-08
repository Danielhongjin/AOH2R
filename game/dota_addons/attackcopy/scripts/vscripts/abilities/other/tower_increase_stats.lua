require("lib/my")
require("AOHGameMode")


tower_increase_stats = class({})


function tower_increase_stats:GetIntrinsicModifierName()
    return "modifier_tower_increase_stats"
end



LinkLuaModifier("modifier_tower_increase_stats", "abilities/other/tower_increase_stats.lua", LUA_MODIFIER_MOTION_NONE)

modifier_tower_increase_stats = class({})


if IsServer() then
    function modifier_tower_increase_stats:OnCreated()
        self.parent = self:GetParent()
		local ability = self:GetAbility()
		self.health_base = ability:GetSpecialValueFor("health_base")
		self.health_per_round = ability:GetSpecialValueFor("health_per_round")
		self.armor_base = ability:GetSpecialValueFor("armor_base")
		self.armor_per_round = ability:GetSpecialValueFor("armor_per_round")
		self.damage_base = ability:GetSpecialValueFor("damage_base")
		self.damage_per_round = ability:GetSpecialValueFor("damage_per_round")
		self.round = 0
		self:StartIntervalThink(3)
    end
	function modifier_tower_increase_stats:OnIntervalThink()
		if self.parent and not self.parent:IsNull() and self.parent:IsAlive() then
			local round = GameRules.GLOBAL_roundNumber
			if round and round > self.round then
				
				-- Health
				local maxHealth = self.health_base + (self.health_per_round * round)
				local damage = self.damage_base + (self.damage_per_round * round)
				self.parent:SetMaxHealth(maxHealth)
				self.parent:SetBaseMaxHealth(maxHealth)
				self.parent:SetHealth(maxHealth)
				--
				self.parent:SetBaseDamageMin(damage)
				self.parent:SetBaseDamageMax(damage)


				-- Armor
				local armor = self.armor_base + (self.armor_per_round * round)
				self.parent:SetPhysicalArmorBaseValue(armor)
				--

				self.round = round
			end
		end
	end
	

end


function modifier_tower_increase_stats:IsHidden()
    return true
end
function modifier_tower_increase_stats:IsPurgable()
	return false
end

