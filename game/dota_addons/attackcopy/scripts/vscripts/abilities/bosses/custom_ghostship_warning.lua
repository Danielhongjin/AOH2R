require("lib/my")

LinkLuaModifier( "modifier_dummy", "modifiers/modifier_dummy.lua", LUA_MODIFIER_MOTION_NONE )


custom_ghostship_warning = class({})

function custom_ghostship_warning:GetIntrinsicModifierName()
	return "modifier_custom_ghostship_warning"
end


LinkLuaModifier("modifier_custom_ghostship_warning", "abilities/bosses/custom_ghostship_warning.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_ghostship_warning = class({})

function modifier_custom_ghostship_warning:IsHidden()
    return true
end
if IsServer() then


    function modifier_custom_ghostship_warning:OnCreated()
        local ability = self:GetAbility()
		self.caster = self:GetCaster()
        self.radius = ability:GetSpecialValueFor("radius")
        self.interval = ability:GetSpecialValueFor("interval")
		self.base_interval = ability:GetSpecialValueFor("interval")
        self.ghostship = self:GetParent():FindAbilityByName("custom_ghostship_instant")
        self:StartIntervalThink(self.interval)
    end


    function modifier_custom_ghostship_warning:OnIntervalThink()
		local casterLocation = self.caster:GetAbsOrigin()
		self.interval = self.base_interval - ((100 - self.caster:GetHealthPercent()) / 10)
		
		local castDistance = RandomInt( 0, self.radius )
		local angle = RandomInt( 0, 90 )
		local dy = castDistance * math.sin( angle )
		local dx = castDistance * math.cos( angle )
		local attackPoint = Vector( 0, 0, 0 )
		local directionConstraint = RandomInt(0,3)
		if directionConstraint == 0 then			-- NW
			attackPoint = Vector( casterLocation.x - dx, casterLocation.y + dy, casterLocation.z )
		elseif directionConstraint == 1 then		-- NE
			attackPoint = Vector( casterLocation.x + dx, casterLocation.y + dy, casterLocation.z )
		elseif directionConstraint == 2 then		-- SE
			attackPoint = Vector( casterLocation.x + dx, casterLocation.y - dy, casterLocation.z )
		else										-- SW
			attackPoint = Vector( casterLocation.x - dx, casterLocation.y - dy, casterLocation.z )
		end
		self.caster:CastAbilityOnPosition(attackPoint, self.ghostship, -1)
		self:StartIntervalThink(self.interval)
		local dummy = CreateUnitByName("npc_dummy_unit", attackPoint, false, self.caster, self.caster, self.caster:GetTeamNumber())
		dummy:AddNewModifier(self.caster,self:GetAbility(), "modifier_dummy", {})
		local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, dummy)
		ParticleManager:SetParticleControl(fx, 0, dummy:GetAbsOrigin())
		ParticleManager:SetParticleControl(fx, 1, Vector(350, 1, 1))
		ParticleManager:SetParticleControl(fx, 2, Vector(4, 1, 1))
		ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
		

		local particleIndex1 = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_ghostship_marker.vpcf", PATTACH_ABSORIGIN_FOLLOW, dummy)
		dummy:ForceKill(false)
    end

end
