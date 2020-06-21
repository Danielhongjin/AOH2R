require("lib/my")
function cast_ion_shell(keys)
	if not keys.target:HasModifier("modifier_ion_shell_custom") then
		keys.target:AddNewModifier(keys.caster, keys.ability, "modifier_ion_shell_custom", {duration = keys.duration})
	else 
		keys.target:RemoveModifierByName("modifier_ion_shell_custom")
		keys.target:AddNewModifier(keys.caster, keys.ability, "modifier_ion_shell_custom", {duration = keys.duration})
	end
end

LinkLuaModifier("modifier_ion_shell_custom", "abilities/heroes/dark_seer_custom_ion_shell.lua", LUA_MODIFIER_MOTION_NONE)
modifier_ion_shell_custom = class({})



if IsServer() then
    function modifier_ion_shell_custom:OnCreated()
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
		-- Setting attributes
		local ability_level = self.ability:GetLevel() - 1
		self.radius = self.ability:GetLevelSpecialValueFor("radius", ability_level) 
		self.interval = self.ability:GetLevelSpecialValueFor("think_interval", ability_level) 
		self.damage = self.ability:GetLevelSpecialValueFor("damage_per_second", ability_level) * self.interval
		local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_dark_seer")
		-- Talent modification
		if talent and talent:GetLevel() > 0 then
			self.damage = self.damage + talent:GetSpecialValueFor("value") * self.interval
		end
		local talent2 = self:GetCaster():FindAbilityByName("dark_seer_custom_bonus_unique_2")
		if talent2 and talent2:GetLevel() > 0 then
			self.interval = self.interval / talent2:GetSpecialValueFor("value")
		end
		self.caster = self.ability:GetCaster()
		-- Particle effects
		self.particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_ion_shell.vpcf", PATTACH_POINT, self.caster)
		ParticleManager:SetParticleControlEnt(self.particle2, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(self.particle2, 1, Vector(65,65,65))
		self.particle = "particles/units/heroes/hero_dark_seer/dark_seer_ion_shell_damage.vpcf"
		self.target_types = self.ability:GetAbilityTargetType() 
		self.parent:EmitSound("Hero_Dark_Seer.Ion_Shield_lp")
		-- damagetable init 
		self.damage_table = {}
		self.damage_table.attacker = self.caster
		self.damage_table.damage = self.damage
		self.damage_table.damage_type = self.ability:GetAbilityDamageType() 
		self.damage_table.ability = self.ability
		-- init
		self:StartIntervalThink(self.interval)
		
    end
	function modifier_ion_shell_custom:OnDestroy()
		ParticleManager:DestroyParticle(self.particle2,  true)
		self.parent:StopSound("Hero_Dark_Seer.Ion_Shield_lp")
		
	end

    function modifier_ion_shell_custom:OnIntervalThink()
		local parent_location = self.parent:GetAbsOrigin()
		
		local units = FindUnitsInRadius(self.caster:GetTeamNumber(), parent_location, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, self.target_types, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		for _,unit in ipairs(units) do
			-- Damage the unit as long as the found unit is not the holder of the modifier
			if unit ~= self.parent then
				-- Play the damage particle
				local particle = ParticleManager:CreateParticle(self.particle, PATTACH_POINT_FOLLOW, unit) 
				ParticleManager:SetParticleControlEnt(particle, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent_location, true) 
				ParticleManager:SetParticleControlEnt(particle, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(particle)

				self.damage_table.victim = unit
				ApplyDamage(self.damage_table)
			end
		end
    end
end