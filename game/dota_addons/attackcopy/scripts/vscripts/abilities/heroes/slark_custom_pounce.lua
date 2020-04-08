require("lib/my")


LinkLuaModifier("modifier_slark_custom_pounce", "abilities/heroes/slark_custom_pounce.lua", LUA_MODIFIER_MOTION_HORIZONTAL)


local foward_modifier = "modifier_slark_custom_pounce"


function cast_slark_pounce(keys)
	local ability = keys.ability
    local caster = keys.caster

    local speed = ability:GetSpecialValueFor("dash_speed")
    local attack_count = ability:GetSpecialValueFor("attack_count")

    local talent = caster:FindAbilityByName("slark_custom_bonus_unique_1")

    if talent and talent:GetLevel() > 0 then
        attack_count = attack_count + talent:GetSpecialValueFor("value")
    end

    local distance = ability:GetCastRange()

    caster:RemoveModifierByName(foward_modifier)
    caster:StartGesture(ACT_DOTA_RUN)

    local kv = {
        duration = distance / speed,
        distance = distance,
        attack_count = attack_count,
        speed = speed
    }

    caster:AddNewModifier(nil, nil, foward_modifier, kv)
end



modifier_slark_custom_pounce = class({})


function modifier_slark_custom_pounce:IsHidden()
	return true
end


function modifier_slark_custom_pounce:IsPurgable()
	return false
end


function modifier_slark_custom_pounce:GetPriority()
	return DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST
end


function modifier_slark_custom_pounce:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	return state
end



function modifier_slark_custom_pounce:OnCreated(keys)
    local parent = self:GetParent()

    parent:EmitSound("Hero_Slark.Pounce.Cast")

    self.direction = parent:GetForwardVector()
    self.distance_left = keys.distance
    self.speed = keys.speed
    self.attack_count = keys.attack_count

    if self:ApplyHorizontalMotionController() == false then
        self:Destroy()
        return
    end
end


function modifier_slark_custom_pounce:OnDestroy()
    local parent = self:GetParent()

    parent:FadeGesture(ACT_DOTA_RUN)
    parent:RemoveHorizontalMotionController(self)
    ResolveNPCPositions(parent:GetAbsOrigin(), 128)
end


function modifier_slark_custom_pounce:UpdateHorizontalMotion(parent, deltaTime)
    local parentPos = parent:GetAbsOrigin()

    local distance = math.min(self.speed * deltaTime, self.distance_left)
    local newPos = parentPos + (distance * self.direction)

    parent:SetAbsOrigin(newPos)

    self.distance_left = self.distance_left - distance

    local units = FindUnitsInRadius(parent:GetTeam(), newPos, nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
    for _, unit in ipairs(units) do
        if unit then
            parent:EmitSound("Hero_Slark.Pounce.Impact")
            for i = 1, self.attack_count do
                parent:PerformAttack(unit, true, true, true, true, true, false, false)
            end
            self:Destroy()
        end
	end
end


function modifier_slark_custom_pounce:OnHorizontalMotionInterrupted()
    self:Destroy()
end

