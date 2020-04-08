item_unstoppable = class({})


function item_unstoppable:GetIntrinsicModifierName()
    return "modifier_item_unstoppable"
end

item_boss_unstoppable = class(item_unstoppable)
item_player_unstoppable = class(item_unstoppable)
LinkLuaModifier("modifier_item_unstoppable", "items/item_unstoppable.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_unstoppable = class({})


function modifier_item_unstoppable:IsHidden()
    return true
end
function modifier_item_unstoppable:IsPurgable()
	return false
end
function modifier_item_unstoppable:RemoveOnDeath()
	return false
end
if IsServer() then
    function modifier_item_unstoppable:OnCreated()
        local ability = self:GetAbility()
        self.radius = ability:GetSpecialValueFor("radius")
		self.tick_interval = ability:GetSpecialValueFor("interval")
		self.parent = self:GetParent()
		if ability:GetAbilityName() == "item_player_unstoppable" then
			self.parent:AddNewModifier(self.parent, ability, "modifier_item_player_unstoppable", {})
		end
		if not self.parent:IsIllusion() then
			self:StartIntervalThink(self.tick_interval)
		end
	end

	function modifier_item_unstoppable:OnIntervalThink()
		if not self.parent:IsStunned() then
			GridNav:DestroyTreesAroundPoint(self.parent:GetAbsOrigin(), self.radius, false)
		end
    end
	function modifier_item_unstoppable:OnDestroy()
		if self.parent then
			self.parent:RemoveModifierByName("modifier_item_player_unstoppable")
		end
	end


end

LinkLuaModifier("modifier_item_player_unstoppable", "items/item_unstoppable.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_player_unstoppable = class({})


function modifier_item_player_unstoppable:IsHidden()
    return true
end

function modifier_item_player_unstoppable:IsPurgable()
	return false
end

function modifier_item_player_unstoppable:RemoveOnDeath()
	return false
end

function modifier_item_player_unstoppable:DeclareFunctions()
    return {
       MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
       MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	   MODIFIER_PROPERTY_MODEL_SCALE,
	   MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end

function modifier_item_player_unstoppable:GetModifierExtraHealthPercentage()
    return self:GetAbility():GetSpecialValueFor("bonus_health_pct")
end

function modifier_item_player_unstoppable:GetModifierModelScale()
    return 15
end

function modifier_item_player_unstoppable:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_item_player_unstoppable:GetModifierSpellAmplify_Percentage()
    return self:GetStackCount()
end
function modifier_item_player_unstoppable:OnCreated()
	self.spell_amp_pct = self:GetAbility():GetSpecialValueFor("spell_amp_pct") * 0.01
	self.parent = self:GetParent()
	if not self.parent:IsIllusion() then
		self:StartIntervalThink(0.5)
	end
end

if IsServer() then
	function modifier_item_player_unstoppable:OnIntervalThink()
		self:SetStackCount(self.parent:GetMaxHealth() * self.spell_amp_pct)
	end
end