

centaur_custom_return = class({})


function centaur_custom_return:GetIntrinsicModifierName()
    return "modifier_centaur_custom_return"
end

function centaur_custom_return:OnUpgrade()
	local caster = self:GetCaster()
	caster:FindModifierByName("modifier_centaur_custom_return"):ForceRefresh()
end

LinkLuaModifier("modifier_centaur_custom_return", "abilities/heroes/centaur_custom_return.lua", LUA_MODIFIER_MOTION_NONE)
modifier_centaur_custom_return = class({})


function modifier_centaur_custom_return:IsHidden()
    return true
end


if IsServer() then
    function modifier_centaur_custom_return:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_TAKEDAMAGE
        }
    end
	function modifier_centaur_custom_return:OnCreated()
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
		self.base_damage = self.ability:GetSpecialValueFor("base_damage")
		self.str_bonus = self.ability:GetSpecialValueFor("str_bonus")
		self.time = 0
		self:StartIntervalThink(0)
	end
	function modifier_centaur_custom_return:OnRefresh()
		self.base_damage = self.ability:GetSpecialValueFor("base_damage")
		self.str_bonus = self.ability:GetSpecialValueFor("str_bonus")
		local talent = self.parent:FindAbilityByName("special_bonus_unique_centaur_3")
		if talent and talent:GetLevel() > 0 then
			self.base_damage = self.base_damage + talent:GetSpecialValueFor("value")
		else
			self:StartIntervalThink(5)
		end
	end
	
	function modifier_centaur_custom_return:OnIntervalThink()
		local talent = self.parent:FindAbilityByName("special_bonus_unique_centaur_3")
		if talent and talent:GetLevel() > 0 then
			self.base_damage = self.base_damage + talent:GetSpecialValueFor("value")
			self:StartIntervalThink(-1)
		end
	end


    function modifier_centaur_custom_return:OnTakeDamage(keys)
        local unit = keys.unit
        local attacker = keys.attacker
			
        if unit == self.parent and unit ~= attacker and keys.damage_flags ~= 16 then
			local current_time = GameRules:GetGameTime()
			local time_diff = current_time - self.time
			if time_diff > 0.15 then
				self.time = current_time
				local damage = self.base_damage + (unit:GetStrength() * self.str_bonus * 0.01)

				ApplyDamage({
					ability = self.ability,
					attacker = unit,
					damage = damage,
					damage_type = self.ability:GetAbilityDamageType(),
					damage_flags = 16,
					victim = attacker
				})

				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_return.vpcf", PATTACH_POINT, unit)
				ParticleManager:SetParticleControlEnt(particle, 1, attacker, PATTACH_POINT, "attach_hitloc", attacker:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(particle)

			end
        end
    end
end
