

grimstroke_custom_phantoms_embrace = class({})


function grimstroke_custom_phantoms_embrace:OnSpellStart()
    local target = self:GetCursorTarget()
	local origin = self:GetCaster():GetAbsOrigin() + RandomVector(100)
	local phantom = CreateUnitByName("npc_grimstroke_custom_phantom", origin, true, target, nil, target:GetTeamNumber())
	phantom:SetOwner(target)
	local newhealth = math.floor(target:GetHealth() / (100 / self:GetSpecialValueFor("shared_life")))
	phantom:AddNewModifier(target, self, "modifier_grimstroke_custom_phantom", {
		duration = self:GetSpecialValueFor("duration")
	})
	EmitSoundOn("Hero_Grimstroke.InkCreature.Cast", self:GetCaster())
	effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_grimstroke/grimstroke_cast_phantom.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:ReleaseParticleIndex(effect_cast)
	phantom:SetBaseMaxHealth(newhealth)
	phantom:SetMaxHealth(newhealth)
	phantom:SetHealth(newhealth)
	phantom:SetPhysicalArmorBaseValue(target:GetPhysicalArmorBaseValue())
	phantom:SetBaseMagicalResistanceValue(target:GetBaseMagicalResistanceValue())
end

LinkLuaModifier("modifier_grimstroke_custom_phantom", "abilities/heroes/grimstroke_custom_phantoms_embrace.lua", LUA_MODIFIER_MOTION_NONE)
modifier_grimstroke_custom_phantom = class({})

modifier_grimstroke_custom_phantom = class({})
function modifier_grimstroke_custom_phantom:IsPurgable()
	return false
end

function modifier_grimstroke_custom_phantom:GetOverrideAnimation()
	return ACT_DOTA_CAPTURE
end

function modifier_grimstroke_custom_phantom:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end

if IsServer() then
    function modifier_grimstroke_custom_phantom:OnDestroy()
		local parent = self:GetParent()
		ParticleManager:DestroyParticle(self.fx, true)
		ParticleManager:ReleaseParticleIndex(self.fx)
        if parent:IsAlive() then
			parent:ForceKill(false)
			parent:RemoveSelf()
		end
    end
	
	function modifier_grimstroke_custom_phantom:OnCreated()
		self.ability = self:GetAbility()
		self.damage_type = self.ability:GetAbilityDamageType()
		self.damage_ratio = self:GetAbility():GetSpecialValueFor("damage_ratio") * 0.01
        self.caster = self:GetCaster()
        self.parent = self:GetParent()
		self.has_reached = false
		self.fx = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_phantom_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
		ParticleManager:SetParticleControlEnt(
			self.fx,
			0,
			self.parent,
			PATTACH_POINT_FOLLOW,
			"attach_hitloc",
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
		local destination = self.caster:GetAbsOrigin()
		Timers:CreateTimer(
			0.1, 
			function()
				self.parent:MoveToPosition(destination)
			end
		)
    end
	
	
	function modifier_grimstroke_custom_phantom:GetUnitLifetimeFraction( params )
		return (( self:GetDieTime() - GameRules:GetGameTime() ) / self:GetDuration())
	end
    
    function modifier_grimstroke_custom_phantom:OnTakeDamage(keys)
		local unit = keys.unit
		if unit == self.parent then
			local particle = ParticleManager:CreateParticle("particles/custom/grimstroke_custom_phantom.vpcf", PATTACH_POINT_FOLLOW, self.caster) 
			ParticleManager:SetParticleControlEnt(particle, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true) 
			ParticleManager:SetParticleControlEnt(particle, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(particle)

			ApplyDamage({
				ability = self.ability,
				attacker = keys.attacker,
				damage = keys.damage * self.damage_ratio,
				damage_type = self.damage_type,
				damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
				victim = self.caster,
			})
		end
    end

end