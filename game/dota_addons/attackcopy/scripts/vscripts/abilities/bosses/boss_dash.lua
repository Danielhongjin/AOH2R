require("lib/timers")



boss_dash = class({})


function boss_dash:OnSpellStart()
    local caster = self:GetCaster()
    caster:AddNewModifier(caster, self, "modifier_boss_dash", {})
end



LinkLuaModifier("modifier_boss_dash", "abilities/bosses/boss_dash.lua", LUA_MODIFIER_MOTION_HORIZONTAL)


modifier_boss_dash = class({})


function modifier_boss_dash:IsHidden()
	return true
end


function modifier_boss_dash:IsPurgable()
	return false
end


if IsServer() then
    function modifier_boss_dash:GetPriority()
        return DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST
    end


    function modifier_boss_dash:CheckState()
        return {
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        }
    end


    function modifier_boss_dash:OnCreated(keys)
        local ability = self:GetAbility()

        self.distance_left = ability:GetSpecialValueFor("distance")
        self.speed = ability:GetSpecialValueFor("speed")
        self.direction = self:GetParent():GetForwardVector()

        if self:ApplyHorizontalMotionController() == false then
            self:Destroy()
            return
        end
    end


    function modifier_boss_dash:OnDestroy()
        local parent = self:GetParent()

        parent:FadeGesture(ACT_DOTA_RUN)
        parent:RemoveHorizontalMotionController(self)
        ResolveNPCPositions(parent:GetAbsOrigin(), 128)
    end


    function modifier_boss_dash:UpdateHorizontalMotion(parent, deltaTime)
        local parent_pos = parent:GetAbsOrigin()

        local distance = math.min(self.speed * deltaTime, self.distance_left)
        local new_pos = parent_pos + (distance * self.direction)

        parent:SetAbsOrigin(new_pos)

        self.distance_left = self.distance_left - distance

        if self.distance_left <= 0  then
            self:Destroy()
        end
    end


    function modifier_boss_dash:OnHorizontalMotionInterrupted()
        self:Destroy()
    end
end
