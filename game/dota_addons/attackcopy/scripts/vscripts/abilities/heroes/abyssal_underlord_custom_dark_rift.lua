 require("lib/timers")

LinkLuaModifier("modifier_bonus_primary_controller", "modifiers/modifier_bonus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonus_primary_token", "modifiers/modifier_bonus.lua", LUA_MODIFIER_MOTION_NONE)


abyssal_underlord_custom_dark_rift = class({})

function abyssal_underlord_custom_dark_rift:OnUpgrade()
	if self.modifier == nil then
	local caster = self:GetCaster()
		caster:AddNewModifier(caster, self, "modifier_bonus_primary_controller", {})
		self.modifier = caster:AddNewModifier(caster, self, "modifier_bonus_primary_token", {
			bonus = self:GetSpecialValueFor("primary_stat_percent_passive")
		})
	end
end
function abyssal_underlord_custom_dark_rift:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local stat_ratio = self:GetSpecialValueFor("stat_damage_pct") * 0.01
	local stats = 0
	local duration = self:GetSpecialValueFor("duration")
	local heroes = FindUnitsInRadius(
        caster:GetTeam(), 
        caster:GetAbsOrigin(), 
        nil, 
        self:GetSpecialValueFor("radius"), 
        DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
        DOTA_UNIT_TARGET_HERO, 
        DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, 
        0, 
        false
    )
	for _, hero in ipairs(heroes) do
		if hero:IsRealHero() then
			stats = stats + hero:GetStrength()
			stats = stats + hero:GetIntellect()
			stats = stats + hero:GetAgility()
		end
	end
    local modifier = target:AddNewModifier(caster, self, "modifier_abyssal_underlord_custom_dark_rift", {
        duration = self:GetSpecialValueFor("duration")
	})
	modifier:SetStackCount(stats * stat_ratio)
	if target ~= caster then
		self:EndCooldown()
		self:StartCooldown((self:GetCooldown(self:GetLevel() - 1) - self:GetSpecialValueFor("cooldown_reduce")) * caster:GetCooldownReduction())
	end
	target:AddNewModifier(caster, self, "modifier_bonus_primary_controller", {})
	target:AddNewModifier(caster, self, "modifier_bonus_primary_token", {
        duration = self:GetSpecialValueFor("duration"), bonus = self:GetSpecialValueFor("primary_stat_percent_active")
	})
end


LinkLuaModifier("modifier_abyssal_underlord_custom_dark_rift", "abilities/heroes/abyssal_underlord_custom_dark_rift.lua", LUA_MODIFIER_MOTION_NONE)
modifier_abyssal_underlord_custom_dark_rift = class({})



function modifier_abyssal_underlord_custom_dark_rift:IsPurgable()
	return false
end

function modifier_abyssal_underlord_custom_dark_rift:RemoveOnDeath()
	return false
end

if IsServer() then
    function modifier_abyssal_underlord_custom_dark_rift:OnCreated(keys)
		self.ability = self:GetAbility()
        self.parent = self:GetParent()
		self.caster = self.ability:GetCaster()
		self.radius = self.ability:GetSpecialValueFor("damage_radius")
		self.fx = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/abyssal_underlord_darkrift_target.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
		ParticleManager:SetParticleControlEnt(self.fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.fx, 6, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
		self.parent:EmitSound("Hero_AbyssalUnderlord.DarkRift.Target")
    end

	function modifier_abyssal_underlord_custom_dark_rift:OnDestroy()		
		self.parent:EmitSound("Hero_AbyssalUnderlord.DarkRift.Complete")
		ParticleManager:DestroyParticle(self.fx, false)
		ParticleManager:ReleaseParticleIndex(self.fx)
		self.fx2 = ParticleManager:CreateParticle("particles/custom/abbysal_underlord_custom_darkrift_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
		ParticleManager:SetParticleControlEnt(self.fx2, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.fx2, 5, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(self.fx2)
		local effect_cast2 = ParticleManager:CreateParticle( "particles/custom/custom_bomb_distort.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt(effect_cast2, 0, self.parent, PATTACH_ABSORIGIN, "attach_absorigin", self.parent:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex( effect_cast2 )
		local units = FindUnitsInRadius(self.parent:GetTeam(), 
			self.parent:GetAbsOrigin(), 
			nil, 
			self.radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 
			DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, 
			0, 
			false
		)
	
		for _, unit in ipairs(units) do
			if unit then
				ApplyDamage({
				attacker = self.parent,
				victim = unit,
				ability = self.ability,
				damage_type = self.ability:GetAbilityDamageType(),
				damage = self:GetStackCount() / #units
			})
			end
		end
		if self.caster:HasScepter()then
			ability1 = self.caster:FindAbilityByName("abyssal_underlord_firestorm")
			ability2 = self.caster:FindAbilityByName("abyssal_underlord_pit_of_malice")
			self.caster:SetCursorPosition(self.parent:GetAbsOrigin())
			ability1:OnSpellStart()
			ability2:OnSpellStart()
		end
	end

end
