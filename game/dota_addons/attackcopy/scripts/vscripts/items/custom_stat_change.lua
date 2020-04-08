item_custom_stat_change = class({})

function item_custom_stat_change:OnSpellStart()
    local caster = self:GetCaster()
	local temp = 0
	if caster:HasModifier("modifier_item_stat_change") then
		caster:RemoveModifierByName("modifier_item_stat_change")
	end
	if self:GetAbilityName() == "item_custom_stat_change_str" then
		local fx2 = ParticleManager:CreateParticle("particles/econ/events/ti6/hero_levelup_ti6_flash_hit_magic.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(fx2, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		temp = 0
	elseif self:GetAbilityName() == "item_custom_stat_change_agi" then
		local fx2 = ParticleManager:CreateParticle("particles/econ/events/ti8/hero_levelup_ti8_flash_hit_magic.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(fx2, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		temp = 1
	elseif self:GetAbilityName() == "item_custom_stat_change_int" then
		local fx2 = ParticleManager:CreateParticle("particles/econ/events/ti7/hero_levelup_ti7_flash_hit_magic.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(fx2, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		temp = 2
	end
	self.modifier = caster:AddNewModifier(caster, self, "modifier_item_stat_change", {
			attribute = temp})
	
end

item_custom_stat_change_str = class(item_custom_stat_change)
item_custom_stat_change_agi = class(item_custom_stat_change)
item_custom_stat_change_int = class(item_custom_stat_change)

LinkLuaModifier("modifier_item_stat_change", "items/custom_stat_change.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_stat_change = class({})

function modifier_item_stat_change:IsHidden()
    return true
end

function modifier_item_stat_change:IsPurgable()
	return false
end

function modifier_item_stat_change:RemoveOnDeath()
	return false
end

if IsServer() then
	function modifier_item_stat_change:OnCreated(keys)
		self.parent = self:GetParent()
		self.attribute = keys.attribute
		self.parent:SetPrimaryAttribute(self.attribute)
		self:StartIntervalThink(3)
	end
	function modifier_item_stat_change:OnIntervalThink()
		self.parent:SetPrimaryAttribute(self.attribute)
	end
end