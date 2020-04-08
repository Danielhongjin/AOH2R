

life_stealer_custom_deny = class({})


function life_stealer_custom_deny:GetIntrinsicModifierName()
    return "modifier_life_stealer_custom_deny"
end



LinkLuaModifier("modifier_life_stealer_custom_deny", "abilities/heroes/life_stealer_custom_deny.lua", LUA_MODIFIER_MOTION_NONE)

modifier_life_stealer_custom_deny = class({})


function modifier_life_stealer_custom_deny:IsHidden()
    return true
end



if IsServer() then
    function modifier_life_stealer_custom_deny:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED
        }
    end


    function modifier_life_stealer_custom_deny:OnAttackLanded(keys)
        local ability = self:GetAbility()
        local attacker = keys.attacker
        local target = keys.target
    
        if attacker == self:GetParent() and attacker:IsOpposingTeam(target:GetTeam()) then
            local modifier_name = "modifier_life_stealer_custom_deny_debuff"

            if not target:HasModifier(modifier_name) and not self:GetParent():IsIllusion() then
                target:AddNewModifier(attacker, ability, modifier_name, {})
            end

            target:FindModifierByName(modifier_name):IncrementStackCount()
        end
    end
end



LinkLuaModifier("modifier_life_stealer_custom_deny_debuff", "abilities/heroes/life_stealer_custom_deny.lua", LUA_MODIFIER_MOTION_NONE)

modifier_life_stealer_custom_deny_debuff = class({})

function modifier_life_stealer_custom_deny_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}
end
function modifier_life_stealer_custom_deny_debuff:IsPurgable()
	return false
end
function modifier_life_stealer_custom_deny_debuff:OnCreated(keys)
	self.regen_decrease = self:GetAbility():GetSpecialValueFor("regen_decrease")
end

function modifier_life_stealer_custom_deny_debuff:GetModifierConstantHealthRegen()
	return self.regen_decrease * self:GetStackCount()
end