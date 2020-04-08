require("lib/my")
require("lib/illusion")


LinkLuaModifier("modifier_meepo_custom_divided_we_stand", "abilities/heroes/meepo_custom_divided_we_stand.lua", LUA_MODIFIER_MOTION_NONE)


local divided_we_stand_modifier = "modifier_meepo_custom_divided_we_stand"


function meepo_copy_items(target, illusion)
    for itemSlot = 0, 5 do
        local item = target:GetItemInSlot(itemSlot)
        if item ~= nil and item:IsPassive() and item:GetName() ~= "item_pharaoh_crown" and item:GetCastPoint() ~= 1337 then
            local itemName = item:GetName()
            local newItem = CreateItem(itemName, illusion, illusion)
            illusion:AddItem(newItem)
        end
    end
end


function create_clone(caster, ability)
    local spawnPos = caster:GetAbsOrigin() + RandomVector(100)

    local illusion = CreateUnitByName(caster:GetUnitName(), spawnPos, true, caster, caster:GetOwner(), caster:GetTeamNumber())
    --illusion:SetPlayerID(caster:GetPlayerID())
    illusion:SetControllableByPlayer(caster:GetPlayerID(), true)

    copy_level(caster, illusion)
    copy_skill_level(caster, illusion, false)
    meepo_copy_items(caster, illusion)
    disable_inventory(illusion)

    illusion:AddNewModifier(illusion, ability, "modifier_meepo_custom_divided_we_stand", {})
    illusion:AddNewModifier(illusion, ability, "modifier_arc_warden_tempest_double", {})
	
    caster:EmitSound("Hero_Meepo.Poof.End00")
end


function kill_alive_clones(caster)
    local ownedUnits = Entities:FindAllByName(caster:GetName())

    for i, unit in ipairs(ownedUnits) do
        if unit:IsAlive() and unit:HasModifier("modifier_meepo_custom_divided_we_stand") then
            kill_illusion(unit)
        end
    end
end


function cast_divided_we_stand(keys)
	local ability = keys.ability
    local caster = keys.caster
    local target = keys.target

    kill_alive_clones(caster)

    local n_clones = ability:GetSpecialValueFor(value_if_scepter(caster, "n_clones_scepter", "n_clones"))

    local n = 0

    -- spawn 1 clone every second.
    Timers(
        function()
            create_clone(caster, target, ability)
            n = n + 1

            if n_clones > n then
                return 0.5
            end
        end
    )
end



modifier_meepo_custom_divided_we_stand = class({})


function modifier_meepo_custom_divided_we_stand:GetTexture()
    return "meepo_divided_we_stand"
end


function modifier_meepo_custom_divided_we_stand:IsPurgable()
    return false
end


function modifier_meepo_custom_divided_we_stand:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_MIN_HEALTH,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
    return funcs
end


function modifier_meepo_custom_divided_we_stand:OnTakeDamage(keys)
    local unit = keys.unit

    if unit == self:GetParent() and unit:GetHealth() <= 1 then
        kill_illusion(unit)
    end
end


function modifier_meepo_custom_divided_we_stand:GetMinHealth()
    return 1
end


function modifier_meepo_custom_divided_we_stand:GetModifierDamageOutgoing_Percentage()
    return -50
end

function modifier_meepo_custom_divided_we_stand:GetModifierIncomingDamage_Percentage()
    return 25
end
