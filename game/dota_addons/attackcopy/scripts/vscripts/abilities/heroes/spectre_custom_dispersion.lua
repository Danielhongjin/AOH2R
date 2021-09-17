--[[Author: Nightborn
	Date: August 27, 2016
]]

LinkLuaModifier("modifier_spectre_custom_dispersion", "abilities/heroes/spectre_custom_dispersion.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_spectre_custom_dispersion_illusion", "abilities/heroes/spectre_custom_dispersion.lua", LUA_MODIFIER_MOTION_NONE )

spectre_custom_dispersion = class({})


function spectre_custom_dispersion:GetIntrinsicModifierName()
    return "modifier_spectre_custom_dispersion"
end

function spectre_custom_dispersion:OnUpgrade()
	if self:GetLevel() > 0 then
		self:GetCaster():FindModifierByName("modifier_spectre_custom_dispersion"):ForceRefresh()
	end
end

function spectre_custom_dispersion:OnInventoryContentsChanged()
	local caster = self:GetCaster()
	if not caster:IsIllusion() and self:GetLevel() > 0 then
		if self.shard then
			if self.shard ~= true and self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
				self.shard = true
				self:CreatePermanentIllusion()
			end
		else
			if not self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
				self.shard = false
			else
				self.shard = true
				self:CreatePermanentIllusion()
			end
		end
	end
end

function spectre_custom_dispersion:CreatePermanentIllusion()
	local caster = self:GetCaster()
	if not IsServer() then return end
	local illusions = CreateIllusions(caster, caster, {duration = -1, outgoing_damage = self:GetSpecialValueFor("damage_outgoing") - 100, incoming_damage = self:GetSpecialValueFor("damage_incoming") - 100}, 1, 50, true, true )
	for _,illusion in ipairs(illusions) do
		illusion:AddNewModifier(caster, self, "modifier_spectre_custom_dispersion_illusion", {})
	end
end

modifier_spectre_custom_dispersion_illusion = class({})

function modifier_spectre_custom_dispersion_illusion:IsHidden()
	return true
end

function modifier_spectre_custom_dispersion_illusion:RemoveOnDeath()
	return true
end

function modifier_spectre_custom_dispersion_illusion:IsPurgable()
	return false
end

function modifier_spectre_custom_dispersion_illusion:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
	}
end

function modifier_spectre_custom_dispersion_illusion:GetModifierMoveSpeedBonus_Percentage()
    return 25
end

function modifier_spectre_custom_dispersion_illusion:GetModifierIgnoreMovespeedLimit()
    return 1
end

function modifier_spectre_custom_dispersion_illusion:CheckState()
	local state = {
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}
	return state
end

if IsServer() then
	function modifier_spectre_custom_dispersion_illusion:OnCreated()
		self.ability = self:GetAbility()
		self.delay = self:GetAbility():GetSpecialValueFor("revive_delay")
	end

	function modifier_spectre_custom_dispersion_illusion:OnDestroy()
		Timers:CreateTimer(
			self.delay, 
			function()
				self.ability:CreatePermanentIllusion()
			end
		)
	end
end

function modifier_spectre_custom_dispersion_illusion:GetStatusEffectName()
	return "particles/status_fx/status_effect_phantom_lancer_illstrong.vpcf"
end

function modifier_spectre_custom_dispersion_illusion:StatusEffectPriority()
	return 100001
end

modifier_spectre_custom_dispersion = class({})

function modifier_spectre_custom_dispersion:IsHidden()
	return true
end

function modifier_spectre_custom_dispersion:RemoveOnDeath()
	return false
end

function modifier_spectre_custom_dispersion:IsPurgable()
	return false
end

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
	self:StartIntervalThink(3)
end

function modifier_spectre_custom_dispersion:OnRefresh()
	self.damage_reflect_pct = self.ability:GetSpecialValueFor("damage_reflection_pct") * 0.01
	self.min_radius = self.ability:GetSpecialValueFor("min_radius")
	local think_interval = 3
	self:StartIntervalThink(think_interval)
end

--[[Author: Nightborn
	Date: August 27, 2016
]]
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
					
					local particle = ParticleManager:CreateParticle( particle_name, PATTACH_POINT_FOLLOW, self.parent )
					ParticleManager:SetParticleControl(particle, 0, vparent)
					ParticleManager:SetParticleControl(particle, 1, vUnit)
					ParticleManager:SetParticleControl(particle, 2, vparent)	
					ApplyDamage({
						ability = self.ability,
						attacker = self.parent,
						damage = reflect_damage,
						damage_type = DAMAGE_TYPE_PURE,
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
