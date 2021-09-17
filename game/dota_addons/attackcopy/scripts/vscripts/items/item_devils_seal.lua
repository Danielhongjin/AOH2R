require("lib/timers")
LinkLuaModifier("modifier_devils_seal", "items/item_devils_seal.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_devils_seal_str", "items/item_devils_seal.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_devils_seal_buff", "items/item_devils_seal.lua", LUA_MODIFIER_MOTION_NONE)


item_devils_seal = class({})


function item_devils_seal:OnSpellStart()
	local caster = self:GetCaster()
	if caster:IsHero() then
		if caster:GetMaxHealth() > 665 then
			caster:AddNewModifier(caster, self, "modifier_devils_seal", {})
		end
	end
end
function item_devils_seal:GetIntrinsicModifierName()
    return "modifier_devils_seal_str"
end




modifier_devils_seal_str = class({})


function modifier_devils_seal_str:IsHidden()
    return true
end

function modifier_devils_seal_str:IsPurgable()
	return false
end

function modifier_devils_seal_str:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_devils_seal_str:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }
end


function modifier_devils_seal_str:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("bonus_strength")
end


modifier_devils_seal = class({})


function modifier_devils_seal:GetTexture()
    return "doom_bringer_doom"
end

function modifier_devils_seal:AllowIllusionDuplicate()
    return true
end


if IsServer() then
    function modifier_devils_seal:OnCreated()
		self.ability = self:GetAbility()
        self.parent = self:GetParent()
		self.radius = self.ability:GetSpecialValueFor("radius")
		self.safety = self.ability:GetSpecialValueFor("safety_margin")
		self.delay = self.ability:GetSpecialValueFor("delay")
		self.counter = 0
		if self.parent:GetHealth() > 666 then
			self.parent:SetHealth(666)
		end
		local fx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_infernal_blade_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
		ParticleManager:SetParticleControlEnt(fx2, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
		self:StartIntervalThink(0.25)
		Timers:CreateTimer(
			self.delay, 
			function()
				ParticleManager:DestroyParticle(fx2, false)
				local units = FindUnitsInRadius(self.parent:GetTeam(), 
					self.parent:GetAbsOrigin(), 
					nil, 
					self.radius,
					DOTA_UNIT_TARGET_TEAM_ENEMY, 
					DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 
					DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, 
					0, 
					false)
				if #units > 0 then
					self.parent:AddNewModifier(self.parent, self.ability, "modifier_devils_seal_buff", {})
				else
					self:Destroy()
				end
					
			end
		)
    end
	
	function modifier_devils_seal:OnDestroy()
		self.parent:RemoveModifierByName("modifier_devils_seal_buff")
    end

	
    function modifier_devils_seal:OnIntervalThink()
		if self.parent:GetHealth() > 666 then
			self.parent:SetHealth(666)
		end
		if not self.parent:IsIllusion() then
			local units = FindUnitsInRadius(self.parent:GetTeam(), 
				self.parent:GetAbsOrigin(), 
				nil, 
				self.radius,
				DOTA_UNIT_TARGET_TEAM_ENEMY, 
				DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 
				DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, 
				0, 
				false)
			if #units == 0 or self.parent:IsOutOfGame() then
				self.counter = self.counter + 0.25
				if self.counter >= self.safety then
					self:Destroy()
				end
			else
				self.counter = self.counter - 0.25
				if self.counter < 0 then
					self.counter = 0
				end
			end
		end
    end

end


modifier_devils_seal_buff = class({})

function modifier_devils_seal_buff:IsHidden()
    return true
end

function modifier_devils_seal_buff:IsPurgable()
    return false
end

function modifier_devils_seal_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}
	return funcs
end


function modifier_devils_seal_buff:GetEffectName()
	return "particles/units/heroes/hero_doom_bringer/doom_bringer_doom.vpcf"
end
function modifier_devils_seal_buff:GetModifierTotalDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor("outgoing_damage")
end