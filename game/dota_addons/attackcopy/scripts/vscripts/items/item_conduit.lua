

item_conduit = class({})


function item_conduit:OnSpellStart()
    local target = self:GetCursorTarget()
	local origin = target:GetAbsOrigin() + RandomVector(100)
	local conduit = CreateUnitByName("npc_conduit", origin, true, target, nil, target:GetTeamNumber())
	conduit:SetOwner(target)
	local newhealth = math.floor(target:GetHealth() / (100 / self:GetSpecialValueFor("shared_life")))
	
    conduit:AddNewModifier(target, self, "modifier_item_conduit", {
        duration = self:GetSpecialValueFor("duration")
	
    })
	local particle = ParticleManager:CreateParticle("particles/econ/items/sven/sven_warcry_ti5/sven_warcry_cast_arc_lightning.vpcf", PATTACH_ABSORIGIN_FOLLOW, conduit) 
	EmitSoundOn("Hero_Zuus.GodsWrath.Target", conduit)
	conduit:SetBaseMaxHealth(newhealth)
	conduit:SetMaxHealth(newhealth)
	conduit:SetHealth(newhealth)
	conduit:SetPhysicalArmorBaseValue(target:GetPhysicalArmorBaseValue())
	conduit:SetBaseMagicalResistanceValue(target:GetBaseMagicalResistanceValue())
end
function item_conduit:GetIntrinsicModifierName()
    return "modifier_item_conduit_buff"
end

LinkLuaModifier("modifier_item_conduit_buff", "items/item_conduit.lua", LUA_MODIFIER_MOTION_NONE)


modifier_item_conduit_buff = class({})


function modifier_item_conduit_buff:IsHidden()
    return true
end


function modifier_item_conduit_buff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_conduit_buff:IsPurgable()
	return false
end
function modifier_item_conduit_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end


function modifier_item_conduit_buff:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end


function modifier_item_conduit_buff:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end


function modifier_item_conduit_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end


function modifier_item_conduit_buff:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_conduit_buff:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end


LinkLuaModifier("modifier_item_conduit", "items/item_conduit.lua", LUA_MODIFIER_MOTION_NONE)


modifier_item_conduit = class({})


if IsServer() then
    function modifier_item_conduit:OnDestroy()
		local parent = self:GetParent()
        if parent:IsAlive() then
			parent:ForceKill(false)
			parent:RemoveSelf()
			print("heyo conduit")
		end
    end
	
	function modifier_item_conduit:OnCreated()
		self.ability = self:GetAbility()

    end

    function modifier_item_conduit:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_TAKEDAMAGE,
        }
    end
	function modifier_item_conduit:GetUnitLifetimeFraction( params )
		return ( ( self:GetDieTime() - GameRules:GetGameTime() ) / self:GetDuration() )
	end
    
    function modifier_item_conduit:OnTakeDamage(keys)
        local caster = self:GetCaster()
        local parent = self:GetParent()
		local unit = keys.unit
		if unit == parent then
			local particle = ParticleManager:CreateParticle("particles/neutral_fx/harpy_chain_lightning.vpcf", PATTACH_POINT_FOLLOW, unit) 
			ParticleManager:SetParticleControlEnt(particle, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true) 
			ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(particle)

			ApplyDamage({
			ability = self.ability,
			attacker = keys.attacker,
			damage = keys.original_damage,
			damage_type = self.ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
			victim = caster
		
			})
			if not parent:IsAlive() or not caster:IsAlive() then
				parent:ForceKill(false)
				parent:RemoveSelf()
				self:Destroy()
			end
		end
    end

end
	function modifier_item_conduit:GetEffectName()
		return "particles/econ/events/ti7/mjollnir_shield_ti7.vpcf"
	end

	function modifier_item_conduit:GetEffectAttachType()
		return PATTACH_ABSORIGIN_FOLLOW
	end
