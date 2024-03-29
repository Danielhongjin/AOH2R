require("lib/my")
LinkLuaModifier("modifier_undying_custom_decay_hud", "abilities/heroes/undying_custom_decay.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_undying_custom_decay_buff", "abilities/heroes/undying_custom_decay.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_summon_timer", "lib/modifiers/modifier_generic_summon_timer.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_summonbuff", "modifiers/modifier_summonbuff.lua", LUA_MODIFIER_MOTION_NONE)

local hud_modifier = "modifier_undying_custom_decay_hud"

undying_custom_decay = class({})

function undying_custom_decay:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    local damage = self:GetSpecialValueFor("damage")

    ApplyDamage({
		ability = self,
		attacker = caster,
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		victim = target
    })

    local duration = self:GetSpecialValueFor("duration")

    caster:AddNewModifier(caster, self, "modifier_undying_custom_decay_buff", {
        duration = duration
    })
    
    caster:EmitSound("Hero_Undying.Decay.Cast")
    if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
        local rand = math.random()
        local unit_name = nil
        if rand == 1 then
            unit_name = "npc_dota_unit_undying_zombie_torso"
        else
            unit_name = "npc_dota_unit_undying_zombie"
        end
        CreateUnitByNameAsync(
            unit_name,
            target:GetAbsOrigin(),
            true,
            caster,
            nil,
            caster:GetTeamNumber(),
            function(zombie)
				zombie:SetOwner(caster)
                local talent = caster:FindAbilityByName("special_bonus_unique_undying")
                if talent and talent:GetLevel() > 0 then
                    local bonus = talent:GetSpecialValueFor("value")
                    zombie:SetBaseDamageMin(zombie:GetBaseDamageMin() + bonus)
                    zombie:SetBaseDamageMax(zombie:GetBaseDamageMax() + bonus)
                end
                zombie:AddNewModifier(caster, self, "modifier_generic_summon_timer", {duration = self:GetSpecialValueFor("shard_duration")})
                zombie:AddNewModifier(caster, nil, "modifier_summonbuff", {id = caster:GetPlayerID()})
                zombie:SetForceAttackTarget(target)
            end
        )
    end
    ParticleManager:CreateParticle("particles/econ/items/undying/undying_manyone/undying_pale_tombstone.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
end


function undying_custom_decay:GetCooldown(iLevel)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("cooldown_scepter")
    end
    return self.BaseClass.GetCooldown(self, iLevel)
end



modifier_undying_custom_decay_hud = class({})


function modifier_undying_custom_decay_hud:IsBuff()
    return true
end


function modifier_undying_custom_decay_hud:GetTexture()
    return "undying_decay"
end


function modifier_undying_custom_decay_hud:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MODEL_SCALE,
    }
end


function modifier_undying_custom_decay_hud:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("str_bonus") * self:GetStackCount()
end

function modifier_undying_custom_decay_hud:GetModifierModelScale()
    return 2 * self:GetStackCount()
end

modifier_undying_custom_decay_buff = class({})


function modifier_undying_custom_decay_buff:IsHidden()
    return true
end


function modifier_undying_custom_decay_buff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


if IsServer() then
    function modifier_undying_custom_decay_buff:OnCreated()
        local caster = self:GetCaster()
        if not caster:HasModifier(hud_modifier) then
            caster:AddNewModifier(caster, self:GetAbility(), hud_modifier, {})
        end
		local modifier = caster:FindModifierByName(hud_modifier)
		modifier:SetDuration(self:GetAbility():GetSpecialValueFor("duration"), true)
        modifier:IncrementStackCount()
    end


    function modifier_undying_custom_decay_buff:OnDestroy()
        local caster = self:GetCaster()
        if caster:HasModifier(hud_modifier) then
            local modifier = caster:FindModifierByName(hud_modifier)

            if modifier:GetStackCount() > 1 then
                modifier:DecrementStackCount()
            else 
                modifier:Destroy()
            end
        end
    end
end
