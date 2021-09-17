LinkLuaModifier( "modifier_kobold_command", "abilities/bosses/boss_kobold_command.lua", LUA_MODIFIER_MOTION_NONE )
boss_kobold_command = class({})


function boss_kobold_command:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local radius = self:GetSpecialValueFor("radius")
	EmitSoundOn("Hero_LegionCommander.PressTheAttack", caster)
	local allies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		caster:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,
		0,
		false
	)
	for _,ally in pairs(allies) do
		if not ally:HasModifier("modifier_kobold_command") then
			ally:AddNewModifier(target, self, "modifier_kobold_command", {duration = self:GetSpecialValueFor("duration")})
		end
	end
end

modifier_kobold_command = class({})

function modifier_kobold_command:IsPurgable()
	return true
end

function modifier_kobold_command:IsHidden()
	return false
end


function modifier_kobold_command:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_kobold_command:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MODEL_SCALE,
    }
end

function modifier_kobold_command:GetEffectName()
	return "particles/units/heroes/hero_life_stealer/life_stealer_open_wounds.vpcf"
end

function modifier_kobold_command:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_kobold_command:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_movespeed")
end

function modifier_kobold_command:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attackspeed")
end

function modifier_kobold_command:GetModifierModelScale()
    return 15
end

function modifier_kobold_command:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
	return state
end

if IsServer() then
	function modifier_kobold_command:OnCreated(keys)
		self.target = self:GetCaster()
		self.parent = self:GetParent()
		self.fx = ParticleManager:CreateParticle("particles/custom/bear_maul.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
		ParticleManager:SetParticleControlEnt(self.fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.fx, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(self.fx, 2, Vector(self:GetAbility():GetSpecialValueFor("duration"), 1, 0))
		self.parent:SetForceAttackTarget(self.target)
		self:StartIntervalThink(0.25)
	end
	
	
	function modifier_kobold_command:OnIntervalThink()
		if self.target:IsMagicImmune() then
			self:Destroy()
		end
	end	
	
	function modifier_kobold_command:OnDestroy()
		self.parent:SetForceAttackTarget(nil)
		ParticleManager:DestroyParticle(self.fx, true)
		ParticleManager:ReleaseParticleIndex(self.fx)
	end
end