

custom_attribute_focus = class({})


if IsServer() then
    function custom_attribute_focus:OnUpgrade()
        if not self.has_setup then
            local caster = self:GetCaster()

            caster:AddNewModifier(caster, self, "modifier_custom_attribute_focus_red", {
                duration = self:GetSpecialValueFor("rotation_time")
            })

            self.has_setup = true
        end
    end
end



LinkLuaModifier("modifier_custom_attribute_focus_base", "abilities/bosses/custom_attribute_focus.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_attribute_focus_base = class({})


function modifier_custom_attribute_focus_base:GetTexture()
    return self.texture
end


function modifier_custom_attribute_focus_base:GetStatusEffectName()
    return self.status_effect
end


function modifier_custom_attribute_focus_base:StatusEffectPriority()
    return 20
end


if IsServer() then
    function modifier_custom_attribute_focus_base:OnDestroy()
        local parent = self:GetParent()
        local ability = self:GetAbility()

        parent:AddNewModifier(parent, ability, self.next_modifier, {
            duration = ability:GetSpecialValueFor("rotation_time")
        })
    end


    function modifier_custom_attribute_focus_base:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_TAKEDAMAGE,
            MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        }
    end

    
    function modifier_custom_attribute_focus_base:GetModifierIncomingDamage_Percentage()
        return self:GetAbility():GetSpecialValueFor("damage_reduction")
    end

    
    function modifier_custom_attribute_focus_base:OnTakeDamage(keys)
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local attacker = keys.attacker

        if keys.unit == parent
            and keys.inflictor ~= ability  -- so it does not create a recursion loop and crash.
            and attacker
            and attacker.GetPrimaryAttribute
            and attacker:GetPrimaryAttribute() == self.attribute 
			and keys.damage_flags ~= 16
			then

            ApplyDamage({
                ability = self:GetAbility(),
                attacker = attacker,
                damage = keys.damage,
                damage_type = DAMAGE_TYPE_PURE,
				damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
                victim = parent
            })
        end
    end
end



LinkLuaModifier("modifier_custom_attribute_focus_red", "abilities/bosses/custom_attribute_focus.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_attribute_focus_red = class(modifier_custom_attribute_focus_base)
modifier_custom_attribute_focus_red.attribute = 0
modifier_custom_attribute_focus_red.next_modifier = "modifier_custom_attribute_focus_green"
modifier_custom_attribute_focus_red.texture = "attribute_focus_red"
modifier_custom_attribute_focus_red.status_effect = "particles/custom/status_effect_hellbear_red.vpcf"



LinkLuaModifier("modifier_custom_attribute_focus_green", "abilities/bosses/custom_attribute_focus.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_attribute_focus_green = class(modifier_custom_attribute_focus_base)
modifier_custom_attribute_focus_green.attribute = 1
modifier_custom_attribute_focus_green.next_modifier = "modifier_custom_attribute_focus_blue"
modifier_custom_attribute_focus_green.texture = "attribute_focus_green"
modifier_custom_attribute_focus_green.status_effect = "particles/custom/status_effect_hellbear_green.vpcf"



LinkLuaModifier("modifier_custom_attribute_focus_blue", "abilities/bosses/custom_attribute_focus.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_attribute_focus_blue = class(modifier_custom_attribute_focus_base)
modifier_custom_attribute_focus_blue.attribute = 2
modifier_custom_attribute_focus_blue.next_modifier = "modifier_custom_attribute_focus_red"
modifier_custom_attribute_focus_blue.texture = "attribute_focus_blue"
modifier_custom_attribute_focus_blue.status_effect = "particles/custom/status_effect_hellbear_blue.vpcf"



function get_attribute_focus(unit)
    if unit:HasModifier("modifier_custom_attribute_focus_red") then
        return 0
    end

    if unit:HasModifier("modifier_custom_attribute_focus_green") then
        return 1
    end

    if unit:HasModifier("modifier_custom_attribute_focus_blue") then
        return 2
    end

    return -1
end
