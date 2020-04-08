


item_warriors_seal = class({})

function item_warriors_seal:GetIntrinsicModifierName()
    return "modifier_item_warriors_seal_buff"
end

LinkLuaModifier("modifier_item_warriors_seal_buff", "items/item_warriors_seal.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_warriors_seal_buff = class({})


if IsServer() then
    function modifier_item_warriors_seal_buff:OnCreated(keys)
        local parent = self:GetParent()

        if parent then
			if not parent:IsIllusion() then
				parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_warriors_seal", {})
				EmitSoundOn("Hero_Antimage.Counterspell.Absorb", parent)
			end
        end
    end
end


function modifier_item_warriors_seal_buff:IsHidden()
    return true
end
function modifier_item_warriors_seal_buff:IsPurgable()
	return false
end

function modifier_item_warriors_seal_buff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_warriors_seal_buff:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    }
end

function modifier_item_warriors_seal_buff:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_item_warriors_seal_buff:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_warriors_seal_buff:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("magic_resist")
end

function modifier_item_warriors_seal_buff:GetModifierDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage_pct")
end

LinkLuaModifier("modifier_item_warriors_seal", "items/item_warriors_seal.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_warriors_seal = class({})


function modifier_item_warriors_seal:GetTexture()
	return "warriors_seal"
end

function modifier_item_warriors_seal:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACKED,
	}
end
function modifier_item_warriors_seal:IsPurgable()
	return false
end

function modifier_item_warriors_seal:RemoveOnDeath()
    return false
end

if IsServer() then
function modifier_item_warriors_seal:OnAttacked(keys)
	local attacker = keys.attacker
	local victim = keys.target
	if attacker ~= self.parent and self.parent == victim then
		local damageTaken = keys.damage
		local new_hp = self.parent:GetHealth() + (damageTaken * self.damage_reduction * self:GetStackCount() * 0.01) 
		if not self.parent:HasModifier("modifier_item_warriors_seal_buff") then
			self:Destroy()
			return nil
		end
		if self:GetStackCount() > 0 then
			ParticleManager:CreateParticle("particles/econ/items/medusa/medusa_daughters/medusa_daughters_mana_shield_shell_impact_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
			if new_hp < 1 then
				self.parent:ForceKill(false)
			else
				self.parent:SetHealth(new_hp)
			end
			self:DecrementStackCount()
		end
	end
end

function modifier_item_warriors_seal:OnCreated()
	local ability = self:GetAbility()
	self.parent = self:GetParent()
	self.damage_reduction = ability:GetSpecialValueFor("damage_reduction")
	self.interval = ability:GetSpecialValueFor("interval")
	self.max_stacks = ability:GetSpecialValueFor("max_stacks")
	ParticleManager:CreateParticle("particles/econ/items/medusa/medusa_daughters/medusa_daughters_mana_shield_end_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	self:SetStackCount(1)
	self:StartIntervalThink(self.interval)
end

function modifier_item_warriors_seal:OnIntervalThink()
	local parent = self:GetParent()
	if not parent:HasModifier("modifier_item_warriors_seal_buff") then
		self:Destroy()
		return nil
	end
	if self:GetStackCount() < self.max_stacks then
		self:IncrementStackCount()
	end
end

end

