

centaur_custom_return = class({})


function centaur_custom_return:GetIntrinsicModifierName()
    return "modifier_centaur_custom_return"
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
		self.cooldown = self.ability:GetSpecialValueFor("cooldown")
	end

    function modifier_centaur_custom_return:OnTakeDamage(keys)
        local unit = keys.unit
        local attacker = keys.attacker

        if unit == self.parent and unit ~= attacker and not unit:HasModifier("modifier_centaur_custom_return_cooldown") and keys.damage_flags ~= 16 then

            
			self.ability:StartCooldown(self.cooldown)
            local damage = self.base_damage + (unit:GetStrength() * self.str_bonus * 0.01)

			ApplyDamage({
				ability = self.ability,
				attacker = unit,
				damage = damage,
				damage_type = self.ability:GetAbilityDamageType(),
				victim = attacker
            })
            

            local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_return.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
            ParticleManager:SetParticleControlEnt(particle, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(particle, 1, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(particle)

            unit:AddNewModifier(caster, self.ability, "modifier_centaur_custom_return_cooldown", {
                duration = self.cooldown
            })
        end
    end
end



LinkLuaModifier("modifier_centaur_custom_return_cooldown", "abilities/heroes/centaur_custom_return.lua", LUA_MODIFIER_MOTION_NONE)

modifier_centaur_custom_return_cooldown = class({})


function modifier_centaur_custom_return_cooldown:IsHidden()
    return true
end
