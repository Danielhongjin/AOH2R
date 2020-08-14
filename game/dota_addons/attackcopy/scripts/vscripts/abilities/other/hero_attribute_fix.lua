LinkLuaModifier("modifier_atr_fix", "abilities/other/hero_attribute_fix.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_builtin_blink", "abilities/other/hero_attribute_fix.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_builtin_blink_cooldown", "abilities/other/hero_attribute_fix.lua", LUA_MODIFIER_MOTION_NONE)
hero_attribute_fix = class({})


function hero_attribute_fix:GetIntrinsicModifierName()
    return "modifier_atr_fix"
end
if IsServer() then

	function hero_attribute_fix:OnHeroLevelUp()
		self:GetCaster():FindModifierByName("modifier_atr_fix"):ForceRefresh()
	end
end


modifier_atr_fix = class({})


function modifier_atr_fix:IsHidden()
    return true
end
function modifier_atr_fix:RemoveOnDeath()
    return false
end

function modifier_atr_fix:IsPurgable()
    return false
end

function modifier_atr_fix:GetTexture()
    return "atr_fix"
end


function modifier_atr_fix:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_BONUS,
	}
	return funcs
end


function modifier_atr_fix:GetModifierConstantHealthRegen()
	local parent_str = self.parent:GetStrength()
    local h_regen = parent_str * 0.2
    return h_regen
end

function modifier_atr_fix:OnCreated()
	self.parent = self:GetParent()
	self.level = self:GetParent()
	if self.parent:IsIllusion() then
		self.level = PlayerResource:GetSelectedHeroEntity(self.parent:GetPlayerOwnerID())
	else
		if IsServer() then
			self.parent:AddNewModifier(self.parent, nil, "modifier_builtin_blink", {duration = -1})
		end
	end

end
function modifier_atr_fix:OnRefresh()
	self:SetStackCount(self.level:GetLevel() * 25)
end


function modifier_atr_fix:GetModifierHealthBonus()
    return self:GetStackCount()
end

function modifier_atr_fix:GetModifierConstantManaRegen()
    local parent_int = self.parent:GetIntellect()
    local m_regen = parent_int * 0.05
    return m_regen
end

function modifier_atr_fix:GetModifierSpellAmplify_Percentage()
	local parent_int = self.parent:GetIntellect()
    local amp = parent_int * 0.12
    return amp
end

modifier_builtin_blink = class({})


function modifier_builtin_blink:IsPurgable()
	return false
end

function modifier_builtin_blink:IsHidden()
	return true
end

function modifier_builtin_blink:RemoveOnDeath()
	return false
end

function modifier_builtin_blink:OnCreated()
	self.parent = self:GetParent()
	self.blink_count = 0
	self.blink_active = true
	
end

function modifier_builtin_blink:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,
	}
	return funcs
end

function modifier_builtin_blink:OnOrder(keys)
	if self.parent == keys.unit then
		if keys.order_type == 1 and self.blink_active then
			self.blink_count = self.blink_count + 1
			Timers:CreateTimer(
				0.14,
				function()
					self.blink_count = self.blink_count - 1
				end
			)
			if self.blink_count > 1 then
				local duration = 4.5 * self.parent:GetCooldownReduction()
				local fx = ParticleManager:CreateParticle("particles/custom/custom_blink_cooldown.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
				ParticleManager:SetParticleControlEnt(
					fx,
					0,
					self.parent,
					PATTACH_ABSORIGIN_FOLLOW,
					"attach_origin",
					self.parent:GetAbsOrigin() + Vector(0, 0, 200), -- unknown
					true -- unknown, true
				)
				ParticleManager:SetParticleControl(fx, 3, Vector(duration, 0, 0))
				ParticleManager:ReleaseParticleIndex(fx)
				self.parent:AddNewModifier(self.parent, nil, "modifier_builtin_blink_cooldown", {duration = duration})
				self.blink_active = false
				Timers:CreateTimer(
					duration, 
					function()
						self.blink_active = true
					end
				)
				ProjectileManager:ProjectileDodge(self.parent)
				ParticleManager:CreateParticle("particles/econ/events/fall_major_2016/blink_dagger_start_fm06.vpcf", PATTACH_ABSORIGIN, self.parent)
				self.parent:EmitSound("DOTA_Item.BlinkDagger.Activate")
				local origin_point = self.parent:GetAbsOrigin()
				local difference_vector = keys.new_pos - origin_point
				if difference_vector:Length2D() > 325 then
					keys.new_pos = origin_point + (keys.new_pos - origin_point):Normalized() * 325
				end
				FindClearSpaceForUnit(self.parent, keys.new_pos, true)
				ParticleManager:CreateParticle("particles/econ/events/fall_major_2016/blink_dagger_end_fm06.vpcf", PATTACH_ABSORIGIN, self.parent)
			end
		end
	end
end

modifier_builtin_blink_cooldown = class({})

function modifier_builtin_blink_cooldown:GetTexture()
	return "blink"
end


function modifier_builtin_blink_cooldown:IsPurgable()
	return false
end

function modifier_builtin_blink_cooldown:IsHidden()
	return false
end

function modifier_builtin_blink_cooldown:RemoveOnDeath()
	return false
end