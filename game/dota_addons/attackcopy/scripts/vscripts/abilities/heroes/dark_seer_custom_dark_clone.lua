require("lib/my")
require("lib/illusion")


LinkLuaModifier("modifier_dark_seer_custom_dark_clone", "abilities/heroes/dark_seer_custom_dark_clone.lua", LUA_MODIFIER_MOTION_NONE)



function create_clone(caster, target, ability)
    local spawnPos = target:GetAbsOrigin() + RandomVector(100)

    local illusion = CreateUnitByName(target:GetUnitName(), spawnPos, true, caster, caster:GetOwner(), caster:GetTeamNumber())
    --illusion:SetPlayerID(caster:GetPlayerID())
    illusion:SetControllableByPlayer(caster:GetPlayerID(), true)

    copy_level(target, illusion)
    copy_skill_level(target, illusion, false)
    copy_items(target, illusion)
    disable_inventory(illusion)
    set_vision(illusion)

    ability:ApplyDataDrivenModifier(illusion, illusion, "modifier_dark_clone_damage", {})
    illusion:AddNewModifier(illusion, ability, "modifier_dark_seer_custom_dark_clone", {})
    illusion:AddNewModifier(illusion, ability, "modifier_arc_warden_tempest_double", {})

    caster:EmitSound("Hero_Dark_Seer.Wall_of_Replica_Start")
end


function cast_dark_clone(keys)
	local ability = keys.ability
    local caster = keys.caster
    local target = keys.target

    local n_clones = ability:GetSpecialValueFor("n_clones")

    local talent = caster:FindAbilityByName("dark_seer_custom_bonus_unique_1")

    if talent and talent:GetLevel() > 0 then
        n_clones = n_clones + 1
    end

    for i = 1, n_clones do
        create_clone(caster, target, ability)
    end
end


function on_dark_clone_expire(keys)
    local caster = keys.caster
    kill_illusion(caster)
end



modifier_dark_seer_custom_dark_clone = class({})


function modifier_dark_seer_custom_dark_clone:GetTexture()
    return "dark_seer_wall_of_replica"
end


function modifier_dark_seer_custom_dark_clone:IsHidden()
    return true
end


function modifier_dark_seer_custom_dark_clone:IsPurgable()
    return false
end


function modifier_dark_seer_custom_dark_clone:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_MIN_HEALTH,
    }
    return funcs
end


function modifier_dark_seer_custom_dark_clone:OnTakeDamage(keys)
    local unit = keys.unit

    if unit == self:GetParent() and unit:GetHealth() <= 1 then
        kill_illusion(unit)
    end
end


function modifier_dark_seer_custom_dark_clone:GetMinHealth(keys)
    return 1
end

