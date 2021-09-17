

terrorblade_custom_dark_realm = class({})
if IsServer() then
	function terrorblade_custom_dark_realm:GetCooldown(iLevel)
		local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_terrorblade")
		if talent and talent:GetLevel() > 0 then
			return self.BaseClass.GetCooldown(self, iLevel) - talent:GetSpecialValueFor("value")
			
		end
		return self.BaseClass.GetCooldown(self, iLevel)
	end
end
function terrorblade_custom_dark_realm:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_dark_realm_invincibility", {duration = self:GetChannelTime()})
	self.duration_extend = self:GetSpecialValueFor("duration_extend")
	self.outgoing_damage = self:GetSpecialValueFor("outgoing_damage")
	self.incoming_damage = self:GetSpecialValueFor("incoming_damage")
	self.duration_percent = self:GetSpecialValueFor("duration_percent")
end
function terrorblade_custom_dark_realm:OnChannelFinish()
	local caster = self:GetCaster()
	local illusions = FindUnitsInRadius(
        caster:GetTeam(), 
        caster:GetAbsOrigin(), 
        nil, 
        99999, 
        DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
        DOTA_UNIT_TARGET_HERO, 
        0, 
        0, 
        false
    )
	ParticleManager:CreateParticle( "particles/econ/items/terrorblade/terrorblade_back_ti8/terrorblade_sunder_ti8.vpcf", PATTACH_ABSORIGIN, caster )
	
	local illusion_delay = 0
	local illusion_count = 0
	local maximum_illusions = self:GetSpecialValueFor("max_illusions")
	for _, illusion in ipairs(illusions) do
        if illusion:IsIllusion() then
			modifier = illusion:FindModifierByName("modifier_illusion")
			if modifier then
				local remaining_time = modifier:GetRemainingTime()
				modifier:SetDuration(remaining_time + self.duration_extend, true)
				illusion:AddNewModifier(caster, self, "modifier_dark_realm_delay", {
					duration = illusion_delay, durationafter = remaining_time * self.duration_percent + self.duration_extend
					, outgoing_damage = self.outgoing_damage, incoming_damage = self.incoming_damage, invulnerability_duration = self.duration_extend})
				illusion_delay = illusion_delay + 0.3
				illusion_count = illusion_count + 1
				if illusion_count > maximum_illusions then
					break
				end
			end
		end
    end
end

LinkLuaModifier("modifier_dark_realm_invincibility", "abilities/heroes/terrorblade_custom_dark_realm.lua", LUA_MODIFIER_MOTION_NONE)
modifier_dark_realm_invincibility = class({})

function modifier_dark_realm_invincibility:CheckState()
	local state = {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
	}

	return state
end

LinkLuaModifier("modifier_dark_realm_delay", "abilities/heroes/terrorblade_custom_dark_realm.lua", LUA_MODIFIER_MOTION_NONE)
modifier_dark_realm_delay = class({})
if IsServer() then
function modifier_dark_realm_delay:OnCreated(keys)
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.caster = self.ability:GetCaster()
	self.modifier = self.parent:FindModifierByName("modifier_illusion")
	self.playerID = self.caster:GetPlayerID()
	self.duration = keys.durationafter
	self.incoming_damage = keys.incoming_damage
	self.outgoing_damage = keys.outgoing_damage
	self.invulnerability_duration = keys.invulnerability_duration
end

	function modifier_dark_realm_delay:OnDestroy(keys)
		
		local illusions = CreateIllusions(self.caster, self.parent, {duration = self.duration, outgoing_damage = self.outgoing_damage, incoming_damage = self.incoming_damage}, 1, 50, true, true )
		for _,illusion in ipairs(illusions) do
			illusion:AddNewModifier(self.caster, self.ability, "modifier_terrorblade_conjureimage", nil)
			illusion:EmitSound("Hero_Terrorblade.Reflection")
			origin = self.parent:GetAbsOrigin() + RandomVector(100)
			FindClearSpaceForUnit( illusion, origin, true )
			illusion:AddNewModifier(self.caster, self.ability, "modifier_invulnerable", {duration = self.invulnerability_duration})
			illusion:AddNewModifier(self.caster, self.ability, "modifier_invulnerable", {duration = self.invulnerability_duration})
			illusion:Heal(99999, nil)
				
		end
		self.parent:AddNewModifier(self.caster, self.ability, "modifier_invulnerable", {duration = self.invulnerability_duration})
		self.parent:AddNewModifier(self.caster, self.ability, "modifier_invulnerable", {duration = self.invulnerability_duration})
		self.parent:Heal(99999, nil)
		ParticleManager:CreateParticle( "particles/econ/items/terrorblade/terrorblade_back_ti8/terrorblade_sunder_ti8.vpcf", PATTACH_ABSORIGIN, self.parent )
	end
end

