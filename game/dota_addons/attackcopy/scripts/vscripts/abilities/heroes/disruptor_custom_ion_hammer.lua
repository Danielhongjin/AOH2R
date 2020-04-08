 

disruptor_custom_ion_hammer = class({})




function disruptor_custom_ion_hammer:OnSpellStart()
    local caster = self:GetCaster()

    caster:AddNewModifier(caster, self, "modifier_disruptor_custom_ion_hammer", {
        duration = self:GetSpecialValueFor("duration")
	})
	caster:AddNewModifier(caster, self, "modifier_disruptor_custom_ion_hammer_buff", {
        duration = self:GetSpecialValueFor("duration")
    })
end


LinkLuaModifier("modifier_disruptor_custom_ion_hammer", "abilities/heroes/disruptor_custom_ion_hammer.lua", LUA_MODIFIER_MOTION_NONE)

modifier_disruptor_custom_ion_hammer = class({})


function modifier_disruptor_custom_ion_hammer:IsHidden()
	return true
end

if IsServer() then

    function modifier_disruptor_custom_ion_hammer:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED
        }
    end
	function modifier_disruptor_custom_ion_hammer:OnCreated()
        self.ability = self:GetAbility()
		self.duration = self.ability:GetSpecialValueFor("debuff_duration")
		self.parent = self:GetParent()
		self.damage = self.ability:GetSpecialValueFor("damage")
    end

    function modifier_disruptor_custom_ion_hammer:OnAttackLanded(keys)
        local attacker = keys.attacker
        local target = keys.target
		
    
        if attacker == self.parent and not target:IsNull() then
            local debuff_name = "modifier_disruptor_custom_ion_hammer_debuff"
			
            if not target:HasModifier(debuff_name) then
                target:AddNewModifier(attacker, self.ability, debuff_name, {duration = self.duration})
					
            end
			
            target:FindModifierByName(debuff_name):IncrementStackCount()
			target:FindModifierByName(debuff_name):SetDuration(self.duration, true)
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_silencer/silencer_global_silence.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_ABSORIGIN, "follow_overhead", target:GetAbsOrigin(), true)
			EmitSoundOn("Hero_Rattletrap.Rocket_Flare.Explode", target)
			ApplyDamage({
				ability = self.ability,
				attacker = self.parent,
				damage = self.damage,
				damage_type = self.ability:GetAbilityDamageType(),
				victim = target
			})
        end
    end
end

LinkLuaModifier("modifier_disruptor_custom_ion_hammer_buff", "abilities/heroes/disruptor_custom_ion_hammer.lua", LUA_MODIFIER_MOTION_NONE)

modifier_disruptor_custom_ion_hammer_buff = class({})


function modifier_disruptor_custom_ion_hammer_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_ATTACK_POINT_CONSTANT,
    }
end

function modifier_disruptor_custom_ion_hammer_buff:GetModifierProjectileSpeedBonus()
    return self:GetAbility():GetSpecialValueFor("projectile_speed_bonus")
end


function modifier_disruptor_custom_ion_hammer_buff:GetModifierBaseAttackTimeConstant()
    return self:GetAbility():GetSpecialValueFor("caster_slow")
end

function modifier_disruptor_custom_ion_hammer_buff:GetModifierModelScale()
	return self:GetAbility():GetSpecialValueFor("model_mult")
end	

function modifier_disruptor_custom_ion_hammer_buff:GetModifierAttackPointConstant()
	return 0.7
end


LinkLuaModifier("modifier_disruptor_custom_ion_hammer_debuff", "abilities/heroes/disruptor_custom_ion_hammer.lua", LUA_MODIFIER_MOTION_NONE)

modifier_disruptor_custom_ion_hammer_debuff = class({})


function modifier_disruptor_custom_ion_hammer_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
end
function modifier_disruptor_custom_ion_hammer_debuff:OnCreated(keys)
	self.armor_decrease = self:GetAbility():GetSpecialValueFor("armor_decrease")
	self.resist_decrease = self:GetAbility():GetSpecialValueFor("resistance_decrease") 
end

function modifier_disruptor_custom_ion_hammer_debuff:GetModifierPhysicalArmorBonus()
    return self.armor_decrease * self:GetStackCount()
end

function modifier_disruptor_custom_ion_hammer_debuff:GetModifierMagicalResistanceBonus()
    return self.resist_decrease * self:GetStackCount()
end
