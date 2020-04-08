

local hud_modifier = "modifier_monkey_king_custom_jingu_mastery_hit"


monkey_king_custom_jingu_mastery = class({})


function monkey_king_custom_jingu_mastery:GetIntrinsicModifierName()
    return "modifier_monkey_king_custom_jingu_mastery_thinker"
end



LinkLuaModifier("modifier_monkey_king_custom_jingu_mastery_thinker", "abilities/heroes/monkey_king_custom_jingu_mastery.lua", LUA_MODIFIER_MOTION_NONE)

modifier_monkey_king_custom_jingu_mastery_thinker = class({})


function modifier_monkey_king_custom_jingu_mastery_thinker:IsHidden()
    return true
end


if IsServer() then
    function modifier_monkey_king_custom_jingu_mastery_thinker:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
    end


    function modifier_monkey_king_custom_jingu_mastery_thinker:OnAttackLanded(keys)
        local attacker = keys.attacker
        
        if attacker == self:GetParent() then
            local ability = self:GetAbility()

            if not attacker:HasModifier(hud_modifier) then
                attacker:AddNewModifier(attacker, ability, hud_modifier, {})
            end

            local modifier_handler = attacker:FindModifierByName(hud_modifier)
            modifier_handler:IncrementStackCount()

            if modifier_handler:GetStackCount() == ability:GetSpecialValueFor("attack_count") - 1 then
                attacker:AddNewModifier(attacker, ability, "modifier_monkey_king_custom_jingu_mastery_buff", {})
            end
			if modifier_handler:GetStackCount() == ability:GetSpecialValueFor("attack_count") then
                modifier_handler:Destroy()
				
			end
        end
    end
end



LinkLuaModifier("modifier_monkey_king_custom_jingu_mastery_hit", "abilities/heroes/monkey_king_custom_jingu_mastery.lua", LUA_MODIFIER_MOTION_NONE)

modifier_monkey_king_custom_jingu_mastery_hit = class({})


function modifier_monkey_king_custom_jingu_mastery_hit:IsBuff()
    return true
end


if IsServer() then
    function modifier_monkey_king_custom_jingu_mastery_hit:OnStackCountChanged(count)
        ParticleManager:SetParticleControl(self.effect, 1, Vector(1, count + 1, 1))
    end


    function modifier_monkey_king_custom_jingu_mastery_hit:OnCreated(keys)
        local parent = self:GetParent()
        self.effect = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, parent)
        ParticleManager:SetParticleControl(self.effect, 0, parent:GetAbsOrigin())
    end


    function modifier_monkey_king_custom_jingu_mastery_hit:OnDestroy()
        ParticleManager:DestroyParticle(self.effect, false)
        ParticleManager:ReleaseParticleIndex(self.effect)
    end
end



LinkLuaModifier("modifier_monkey_king_custom_jingu_mastery_buff", "abilities/heroes/monkey_king_custom_jingu_mastery.lua", LUA_MODIFIER_MOTION_NONE)

modifier_monkey_king_custom_jingu_mastery_buff = class({})





function modifier_monkey_king_custom_jingu_mastery_buff:IsBuff()
    return true
end


function modifier_monkey_king_custom_jingu_mastery_buff:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end


function modifier_monkey_king_custom_jingu_mastery_buff:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end


if IsServer() then
    function modifier_monkey_king_custom_jingu_mastery_buff:DisplayHitEffect(target)
        local heal_effect = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:ReleaseParticleIndex(heal_effect)
    end


    function modifier_monkey_king_custom_jingu_mastery_buff:OnAttackLanded(keys)
        if keys.attacker == self:GetParent() then
            local lifesteal = self:GetAbility():GetSpecialValueFor("lifesteal") * 0.01

            local parent = self:GetParent()
            parent:Heal(keys.damage * lifesteal, parent)
			local hit_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_quad_tap_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
			ParticleManager:SetParticleControl(hit_effect, 1, keys.target:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(hit_effect)
            self:DisplayHitEffect(keys.target)
            self:Destroy()  
        end
    end
end
