item_diff_doom = class({})
LinkLuaModifier( "modifier_diff_doom_thinker", "items/diff_doom.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_diff_doom_marker", "items/diff_doom.lua", LUA_MODIFIER_MOTION_NONE )

function item_diff_doom:GetAOERadius()
	return self:GetSpecialValueFor( "area_of_effect" )
end

function item_diff_doom:GetIntrinsicModifierName()
    return "modifier_diff_doom"
end


function item_diff_doom:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local aoe = self:GetSpecialValueFor("area_of_effect")
	local delay = self:GetSpecialValueFor("delay")
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		point,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		aoe,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self, "modifier_diff_doom_marker", {duration = delay + 0.5})
	end
	-- create modifier thinker
	CreateModifierThinker(
		caster,
		self,
		"modifier_diff_doom_thinker",
		{ duration = delay },
		point,
		caster:GetTeamNumber(),
		false
	)

end



LinkLuaModifier("modifier_diff_doom", "items/diff_doom.lua", LUA_MODIFIER_MOTION_NONE)

modifier_diff_doom = class({})

function modifier_diff_doom:IsHidden()
    return true
end
function modifier_diff_doom:IsPurgable()
	return false
end

function modifier_diff_doom:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_diff_doom:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
end


function modifier_diff_doom:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_diff_doom:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("bonus_strength")
end

function modifier_diff_doom:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_diff_doom:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

modifier_diff_doom_marker = class({})

function modifier_diff_doom_marker:GetTexture()
	return "ether_hammer_marked"
end

function modifier_diff_doom_marker:IsHidden()
	return false
end

function modifier_diff_doom_marker:IsPurgable()
	return true
end

function modifier_diff_doom_marker:OnCreated()
	local parent = self:GetParent()
	self.fx = ParticleManager:CreateParticle("particles/econ/items/silencer/silencer_ti6/silencer_last_word_status_ti6_ring_edge.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
	ParticleManager:SetParticleControlEnt(self.fx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", parent:GetAbsOrigin(), true)
end

function modifier_diff_doom_marker:OnDestroy()
	ParticleManager:DestroyParticle(self.fx, true)
	ParticleManager:ReleaseParticleIndex(self.fx)
end

modifier_diff_doom_thinker = class({})


function modifier_diff_doom_thinker:IsHidden()
	return true
end

function modifier_diff_doom_thinker:IsPurgable()
	return false
end

function modifier_diff_doom_thinker:OnCreated(kv)
	self.caster = self:GetCaster()
	if IsServer() then
		-- references
		self.damage = self:GetAbility():GetSpecialValueFor("damage")
		self.damage_int = self:GetAbility():GetSpecialValueFor("damage_int") * 0.01
		self.damage_marker = self:GetAbility():GetSpecialValueFor("damage_marker") * 0.01
		self.radius = self:GetAbility():GetSpecialValueFor("area_of_effect")

		-- Play effects
		self:PlayEffects1()
	end
end

function modifier_diff_doom_thinker:OnDestroy( kv )
	if IsServer() then
		local int = self.caster:GetIntellect()
		self.damage = self.damage + self.damage_int * int
		-- Damage enemies
		local damageTable = {
			attacker = self:GetCaster(),
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility(), --Optional.
		}

		local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),	-- int, your team number
			self:GetParent():GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		for _,enemy in pairs(enemies) do
			if not enemy:HasModifier("modifier_diff_doom_marker") then
				damageTable.victim = enemy
				damageTable.damage = self.damage
				ApplyDamage(damageTable)
			else 
				damageTable.victim = enemy
				damageTable.damage = self.damage * self.damage_marker
				ApplyDamage(damageTable)
			end
		end
		self:PlayEffects2()
		UTIL_Remove(self:GetParent())
	end
end

function modifier_diff_doom_thinker:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/custom/diff_doom_team.vpcf"
	local sound_cast = "Hero_Invoker.SunStrike.Charge"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticleForTeam( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster(), self:GetCaster():GetTeamNumber() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOnLocationForAllies( self:GetParent():GetOrigin(), sound_cast, self:GetCaster() )
end

function modifier_diff_doom_thinker:PlayEffects2()
	-- Get Resources
	local particle_cast = "particles/custom/diff_doom.vpcf"
	local sound_cast = "Hero_Invoker.SunStrike.Ignite"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), sound_cast, self:GetCaster() )
end