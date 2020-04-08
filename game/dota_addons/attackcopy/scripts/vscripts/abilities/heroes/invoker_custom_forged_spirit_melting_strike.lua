
invoker_custom_forged_spirit_melting_strike = class({})




function invoker_custom_forged_spirit_melting_strike:GetIntrinsicModifierName()
    return "modifier_forge_spirit_custom_armorbreak"
end



LinkLuaModifier("modifier_forge_spirit_custom_armorbreak", "abilities/heroes/invoker_custom_forged_spirit_melting_strike.lua", LUA_MODIFIER_MOTION_NONE)

modifier_forge_spirit_custom_armorbreak = class({})


function modifier_forge_spirit_custom_armorbreak:IsHidden()
	return true
end

if IsServer() then

    function modifier_forge_spirit_custom_armorbreak:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED
        }
    end
	function modifier_forge_spirit_custom_armorbreak:OnCreated()
        self.ability = self:GetAbility()
		self.duration = self.ability:GetSpecialValueFor("duration")
		self.parent = self:GetParent()
		self.debuff_name = "modifier_forge_spirit_custom_armorbreak_debuff"
		self.max_count = self.ability:GetSpecialValueFor("max_stacks")
		local talent = self:GetParent():GetOwner():FindAbilityByName("special_bonus_unique_invoker_11")
		if talent and talent:GetLevel() > 0 then
			self.max_count = self.max_count + talent:GetSpecialValueFor("value")
		end
    end

    function modifier_forge_spirit_custom_armorbreak:OnAttackLanded(keys)
        local attacker = keys.attacker
        local target = keys.target
        if attacker == self.parent and not target:IsNull() then
            if not target:HasModifier(self.debuff_name) then
                target:AddNewModifier(attacker, self.ability, self.debuff_name, {duration = self.duration})
            end
			local modifier = target:FindModifierByName(self.debuff_name)
			if modifier:GetStackCount() < self.max_count then
				modifier:IncrementStackCount()
			end 	
			modifier:SetDuration(self.duration, true)
        end
    end
end



LinkLuaModifier("modifier_forge_spirit_custom_armorbreak_debuff", "abilities/heroes/invoker_custom_forged_spirit_melting_strike.lua", LUA_MODIFIER_MOTION_NONE)

modifier_forge_spirit_custom_armorbreak_debuff = class({})

function modifier_forge_spirit_custom_armorbreak_debuff:GetTexture()
    return "forged_spirit_melting_strike"
end
function modifier_forge_spirit_custom_armorbreak_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end
function modifier_forge_spirit_custom_armorbreak_debuff:OnCreated(keys)
	self.armor_decrease = self:GetAbility():GetSpecialValueFor("armor_decrease")
	
end

function modifier_forge_spirit_custom_armorbreak_debuff:GetModifierPhysicalArmorBonus()
    return self.armor_decrease * self:GetStackCount()
end

