--[[Author: Nightborn
	Date: August 27, 2016
]]

LinkLuaModifier("modifier_spectre_custom_dispersion", "abilities/heroes/spectre_custom_dispersion.lua", LUA_MODIFIER_MOTION_NONE )

spectre_custom_dispersion = class({})


function spectre_custom_dispersion:GetIntrinsicModifierName()
    return "modifier_spectre_custom_dispersion"
end
function spectre_custom_dispersion:OnUpgrade()
	local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_spectre_custom_dispersion")
	caster:AddNewModifier(caster, self, "modifier_spectre_custom_dispersion" , {})
end
--[[Author: Nightborn
	Date: August 27, 2016
]]

modifier_spectre_custom_dispersion = class({})

function modifier_spectre_custom_dispersion:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end
function modifier_spectre_custom_dispersion:OnCreated()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.damage_reflect_pct = self.ability:GetSpecialValueFor("damage_reflection_pct") * 0.01
	self.min_radius = self.ability:GetSpecialValueFor("min_radius")
	local think_interval = 3
	self:StartIntervalThink(think_interval)
end
if IsServer() then
function modifier_spectre_custom_dispersion:OnTakeDamage (event)
	
	if event.unit == self.parent then
		if event.damage_flags ~= 16 then
			local post_damage = event.damage
			local original_damage = event.original_damage
			
			local unit = event.attacker
			if unit:GetTeam() ~= self.parent:GetTeam() then
				local vparent = self.parent:GetAbsOrigin()
				local vUnit = unit:GetAbsOrigin()

				local reflect_damage = 0.0
				local particle_name = ""

				local distance = (vUnit - vparent):Length2D()
				
				--Within 300 radius		
				if distance <= self.min_radius then
					reflect_damage = original_damage * self.damage_reflect_pct
					particle_name = "particles/units/heroes/hero_spectre/spectre_dispersion.vpcf"
					if self.parent:IsAlive() then
						self.parent:SetHealth(self.parent:GetHealth() + (post_damage * self.damage_reflect_pct) )
					end
				--Between 301 and 475 radius
				else
					local ratio = self.damage_reflect_pct * (1 - (distance - self.min_radius) * 0.142857 * 0.01)
					reflect_damage = original_damage * ratio
					particle_name = "particles/units/heroes/hero_spectre/spectre_dispersion_b_fallback_mid.vpcf"
					if self.parent:IsAlive() then
						self.parent:SetHealth(self.parent:GetHealth() + (post_damage * ratio) )
					end
				end
				
				--Create particle
				local particle = ParticleManager:CreateParticle( particle_name, PATTACH_POINT_FOLLOW, self.parent )
				ParticleManager:SetParticleControl(particle, 0, vparent)
				ParticleManager:SetParticleControl(particle, 1, vUnit)
				ParticleManager:SetParticleControl(particle, 2, vparent)	
				ApplyDamage({
					ability = self.ability,
					attacker = self.parent,
					damage = reflect_damage,
					damage_type = DAMAGE_TYPE_MAGICAL,
					damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
					victim = unit,
				})

			end
		end
	end

end

function modifier_spectre_custom_dispersion:OnIntervalThink()
	local talent = self.parent:FindAbilityByName("special_bonus_unique_spectre_5")
	if talent and talent:GetLevel() > 0 then
		self.damage_reflect_pct = self.damage_reflect_pct + talent:GetSpecialValueFor("value") * 0.01
		self:StartIntervalThink(-1)
	end
end
end
function modifier_spectre_custom_dispersion:IsHidden()
	return true
end

function modifier_spectre_custom_dispersion:RemoveOnDeath()
	return false
end

function modifier_spectre_custom_dispersion:IsPurgable()
	return false
end