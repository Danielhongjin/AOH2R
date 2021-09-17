LinkLuaModifier("modifier_nyx_assassin_custom_vendetta_invis", "abilities/heroes/nyx_assassin_custom_vendetta.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nyx_assassin_custom_vendetta_crit", "abilities/heroes/nyx_assassin_custom_vendetta.lua", LUA_MODIFIER_MOTION_NONE)


nyx_assassin_custom_vendetta = class({})

function nyx_assassin_custom_vendetta:GetIntrinsicModifierName()
    return "modifier_nyx_assassin_custom_vendetta_crit"
end
function nyx_assassin_custom_vendetta:GetAbilityDamageType()
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
		return DAMAGE_TYPE_PURE
	else
		return DAMAGE_TYPE_MAGICAL
	end
end

function nyx_assassin_custom_vendetta:OnInventoryContentsChanged()
    if self.cooldown then
		if self.cooldown ~= self:GetCaster():GetCooldownReduction() then
			self:GetCaster():FindModifierByName("modifier_nyx_assassin_custom_vendetta_crit"):ForceRefresh()
			self.cooldown = self:GetCaster():GetCooldownReduction()
		end
	 elseif self:GetLevel() > 0 then
		self.cooldown = self:GetCaster():GetCooldownReduction()
		self:GetCaster():FindModifierByName("modifier_nyx_assassin_custom_vendetta_crit"):ForceRefresh()
	end
end

function nyx_assassin_custom_vendetta:OnUpgrade()
	self:GetCaster():FindModifierByName("modifier_nyx_assassin_custom_vendetta_crit"):ForceRefresh()
end


function nyx_assassin_custom_vendetta:OnSpellStart()
   local caster = self:GetCaster()
   local duration = self:GetSpecialValueFor("duration")

   local modifier = caster:AddNewModifier(caster, self, "modifier_nyx_assassin_custom_vendetta_invis", {duration = duration})
	if caster:HasModifier("modifier_item_aghanims_shard") then
		modifier:SetStackCount(1)
	else
		modifier:SetStackCount(0)
	end
	EmitSoundOn("Hero_NyxAssassin.Vendetta", caster)
end



modifier_nyx_assassin_custom_vendetta_crit = class({})


function modifier_nyx_assassin_custom_vendetta_crit:GetTexture()
    return "nyx_assassin_vendetta"
end

function modifier_nyx_assassin_custom_vendetta_crit:RemoveOnDeath()
	return false
end

function modifier_nyx_assassin_custom_vendetta_crit:IsPurgable()
	return false
end

function modifier_nyx_assassin_custom_vendetta_crit:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end


function modifier_nyx_assassin_custom_vendetta_crit:OnAttackLanded(keys)
    local attacker = keys.attacker
    if attacker == self:GetParent() then
        self:SetStackCount(0)
    end
end


function modifier_nyx_assassin_custom_vendetta_crit:OnCreated()
	local ability = self:GetAbility()
	self.max_crit_stack = ability:GetSpecialValueFor("max_crit_stacks")
	self.crit_increase = ability:GetSpecialValueFor("crit_increase")
	self.interval = ability:GetSpecialValueFor("interval") * self:GetParent():GetCooldownReduction()
	self:StartIntervalThink(self.interval)
end

function modifier_nyx_assassin_custom_vendetta_crit:OnRefresh()
	local ability = self:GetAbility()
	self.max_crit_stack = ability:GetSpecialValueFor("max_crit_stacks")
	self.crit_increase = ability:GetSpecialValueFor("crit_increase")
	self.interval = ability:GetSpecialValueFor("interval") * self:GetParent():GetCooldownReduction()
	self:StartIntervalThink(self.interval)
 end

function modifier_nyx_assassin_custom_vendetta_crit:OnIntervalThink()
    if self:GetStackCount() < self.max_crit_stack then
        self:IncrementStackCount()
    end
end


function modifier_nyx_assassin_custom_vendetta_crit:GetModifierPreAttack_CriticalStrike()
    return self.crit_increase * self:GetStackCount()
end


modifier_nyx_assassin_custom_vendetta_invis = class({})


function modifier_nyx_assassin_custom_vendetta_invis:GetTexture()
    return "nyx_assassin_vendetta"
end


function modifier_nyx_assassin_custom_vendetta_invis:CheckState()
    return {
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_CANNOT_MISS] = true,
    }
end


function modifier_nyx_assassin_custom_vendetta_invis:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
	}
end


function modifier_nyx_assassin_custom_vendetta_invis:GetModifierInvisibilityLevel()
    return 1
end

function modifier_nyx_assassin_custom_vendetta_invis:GetModifierIgnoreMovespeedLimit()
    return self:GetStackCount()
end

function modifier_nyx_assassin_custom_vendetta_invis:OnAttackLanded(keys)
    local attacker = keys.attacker
    if attacker == self:GetParent() then
		local target = keys.target
		local damage_type = self:GetAbility():GetAbilityDamageType()
		local finaldamage = ApplyDamage({
				ability = ability,
				attacker = attacker,
				damage = keys.damage * (self:GetAbility():GetSpecialValueFor("damage_pct") * 0.01),
				damage_type = damage_type,
				victim = target,
			})
		local fx = ParticleManager:CreateParticle("particles/custom/glare_edge.vpcf", PATTACH_POINT_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(
			fx,
			0,
			target,
			PATTACH_POINT,
			"attach_hitloc",
			target:GetAbsOrigin(), -- unknown
			true -- unknown, true
		)
		local color = Vector(100, 95, 237)
		if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
			color = Vector(200, 195, 47)
		end
		create_popup({
			target = target,
			value = finaldamage,
			color = color,
			type = "spell",
			pos = 6
		})
		EmitSoundOn("Hero_NyxAssassin.Vendetta.Crit", target)
        self:Destroy()
    end
end


function modifier_nyx_assassin_custom_vendetta_invis:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movement_speed") + (self:GetStackCount() * 40)
end


function modifier_nyx_assassin_custom_vendetta_invis:GetModifierSpellAmplify_Percentage()
    return self:GetAbility():GetSpecialValueFor("spell_amp")
end



		