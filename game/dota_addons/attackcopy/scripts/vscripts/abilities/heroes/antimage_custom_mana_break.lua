

antimage_custom_mana_break = class({})


function antimage_custom_mana_break:GetIntrinsicModifierName()
    return "modifier_antimage_custom_mana_break"
end



LinkLuaModifier("modifier_antimage_custom_mana_break", "abilities/heroes/antimage_custom_mana_break.lua", LUA_MODIFIER_MOTION_NONE)

modifier_antimage_custom_mana_break = class({})


function modifier_antimage_custom_mana_break:IsHidden()
    return true
end


if IsServer() then
    function modifier_antimage_custom_mana_break:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
    end
	function modifier_antimage_custom_mana_break:OnCreated() 
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
		self.mana_per_hit = self.ability:GetSpecialValueFor("mana_per_hit")
		self.damage = self.ability:GetSpecialValueFor("mana_burn_as_damage") * 0.01
		if self.parent:IsIllusion() then
			self.mana_per_hit = self.mana_per_hit / 2
		end
	end

    function modifier_antimage_custom_mana_break:OnAttackLanded(keys)
        local attacker = keys.attacker
        if attacker == self.parent then
            local target = keys.target
            if attacker:PassivesDisabled() or target:GetMaxMana() == 0 then
                return nil
            end

            target:EmitSound("Hero_Antimage.ManaBreak")

            local particle = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
            ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle)

            target:ReduceMana(self.mana_per_hit)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, target, self.mana_per_hit, nil)

			ApplyDamage({
				ability = self.ability,
				attacker = attacker,
				damage = self.mana_per_hit * self.damage,
				damage_type = self.ability:GetAbilityDamageType(),
				victim = target
			})
        end
    end
end
