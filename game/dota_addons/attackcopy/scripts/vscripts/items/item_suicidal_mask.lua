item_suicidal_mask = class({})

function item_suicidal_mask:GetIntrinsicModifierName()
    return "modifier_item_suicidal_mask"
end

function item_suicidal_mask:OnSpellStart()
    local caster = self:GetCaster()
	if not caster:HasModifier("modifier_item_suicidal_mask_debuff") or not caster:HasModifier("modifier_item_suicidal_mask_buff") then
		caster:AddNewModifier(caster, self, "modifier_item_suicidal_mask_debuff", {duration = 9999})
		caster:AddNewModifier(caster, self, "modifier_item_suicidal_mask_buff", {duration = 9999})
	else
		caster:RemoveModifierByName("modifier_item_suicidal_mask_debuff")
		caster:RemoveModifierByName("modifier_item_suicidal_mask_buff")
	end
end

LinkLuaModifier("modifier_item_suicidal_mask", "items/item_suicidal_mask.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_suicidal_mask = class({})

function modifier_item_suicidal_mask:IsHidden()
    return true
end
function modifier_item_suicidal_mask:IsPurgable()
	return false
end

function modifier_item_suicidal_mask:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_suicidal_mask:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

	function modifier_item_suicidal_mask:GetModifierAttackSpeedBonus_Constant()
		return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	end


	function modifier_item_suicidal_mask:GetModifierPhysicalArmorBonus()
		return self:GetAbility():GetSpecialValueFor("bonus_armor")
	end

	function modifier_item_suicidal_mask:GetModifierBonusStats_Strength()
		return self:GetAbility():GetSpecialValueFor("bonus_strength")
	end

		function modifier_item_suicidal_mask:GetModifierPreAttack_BonusDamage()
			return self:GetAbility():GetSpecialValueFor("bonus_damage")
		end
if IsServer() then



		function modifier_item_suicidal_mask:OnAttackLanded(keys)
			local attacker = keys.attacker
			local target = keys.target

			if attacker == self:GetParent() and attacker ~= target then
				local heal = keys.damage * self:GetAbility():GetSpecialValueFor("lifesteal") / 100
				attacker:Heal(heal, self:GetAbility())
				ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
		end
	end
end

LinkLuaModifier("modifier_item_suicidal_mask_debuff", "items/item_suicidal_mask.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_suicidal_mask_debuff = class({})

function modifier_item_suicidal_mask_debuff:IsDebuff()
    return false
end

function modifier_item_suicidal_mask_debuff:RemoveOnDeath()
    return true
end
function modifier_item_suicidal_mask_debuff:IsHidden()
    return true
end

if IsServer() then

    function modifier_item_suicidal_mask_debuff:OnCreated(keys)
        self.ability = self:GetAbility()
		self.parent = self:GetParent()
		self.base_damage = self.ability:GetSpecialValueFor("base_damage")
		self.pct_damage = self.ability:GetSpecialValueFor("pct_damage") * 0.01
        self.radius = self.ability:GetSpecialValueFor("radius")
        self.target_type = self.ability:GetAbilityTargetType()
        self.target_team = self.ability:GetAbilityTargetTeam()
        self.target_flags = self.ability:GetAbilityTargetFlags()
        self.tick_interval = 1 / self.ability:GetSpecialValueFor("ticks_per_sec")
		self.damage_type = self:GetAbility():GetAbilityDamageType()	
		self.duration = self.ability:GetSpecialValueFor("duration")
		EmitSoundOn("Hero_Silencer.Curse", self.parent)
		self:OnIntervalThink()
        self:StartIntervalThink(self.tick_interval)
    end

	function modifier_item_suicidal_mask_debuff:OnDestroy(keys)
        ParticleManager:DestroyParticle(self.particle, true)
    end

    function modifier_item_suicidal_mask_debuff:OnIntervalThink()
		if not self.parent:IsOutOfGame() and not self.parent:HasModifier("modifier_dazzle_shallow_grave") then
			if not self.parent:IsAlive()then
				self:Destroy()
			end
			count_modifier = self.parent:FindModifierByName("modifier_item_suicidal_mask_count")
			if count_modifier then
				count_modifier:IncrementStackCount()
				count_modifier:SetDuration(self.duration, true)
			else
				count_modifier = self.parent:AddNewModifier(self.parent, self, "modifier_item_suicidal_mask_count", {duration = self.duration})
				count_modifier:SetStackCount(0)
			end
			local stack_count = count_modifier:GetStackCount()
			local damage = stack_count * self.base_damage + (stack_count * self.pct_damage * self.parent:GetMaxHealth())
			local units = FindUnitsInRadius(self.parent:GetTeam(), self.parent:GetOrigin(), nil, self.radius, self.target_team, self.target_type, 0, 0, false)
			self.particle = ParticleManager:CreateParticle("particles/bloodbath_ribbon_bigger.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
			ParticleManager:SetParticleControlEnt(self.particle, 1, self.parent, PATTACH_POINT_FOLLOW, "follow_hitloc", self.parent:GetAbsOrigin(), true)
			EmitSoundOn("Hero_Silencer.Curse", self.parent)
			for _, unit in ipairs(units) do
				ApplyDamage({
					ability = self.ability,
					attacker = self.parent,
					damage = damage,
					damage_type = self.damage_type,
					victim = unit
				})
			end
			self.parent:ModifyHealth(self.parent:GetHealth() - damage, self, true, 0 )
		end
	end
end

LinkLuaModifier("modifier_item_suicidal_mask_count", "items/item_suicidal_mask.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_suicidal_mask_count = class({})

function modifier_item_suicidal_mask_count:GetTexture()
	return "suicidal_mask_debuff"
end

LinkLuaModifier("modifier_item_suicidal_mask_buff", "items/item_suicidal_mask.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_suicidal_mask_buff = class({})

function modifier_item_suicidal_mask_buff:IsHidden()
    return true
end
function modifier_item_suicidal_mask_buff:RemoveOnDeath()
    return true
end

function modifier_item_suicidal_mask_buff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_suicidal_mask_buff:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,

    }
end

function modifier_item_suicidal_mask_buff:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("active_bonus_attack_speed")
end

function modifier_item_suicidal_mask_buff:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("active_damage_resistance")
end

function modifier_item_suicidal_mask_buff:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("active_bonus_movespeed")
end
