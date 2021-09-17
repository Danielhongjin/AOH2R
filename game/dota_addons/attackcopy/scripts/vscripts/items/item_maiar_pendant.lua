require("lib/my")
item_maiar_pendant = class({})


function item_maiar_pendant:GetIntrinsicModifierName()
    return "modifier_item_maiar_pendant"
end
function item_maiar_pendant:OnSpellStart()
        local caster = self:GetCaster()
		caster:SetMana(caster:GetMaxMana())
		caster:SetHealth(13)
        caster:EmitSound("DOTA_Item.Bloodstone.Cast")

        local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControl(effect, 0, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(effect, 1, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(effect, 2, caster:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(effect)
    end


LinkLuaModifier("modifier_item_maiar_pendant", "items/item_maiar_pendant.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_maiar_pendant = class({})

function modifier_item_maiar_pendant:IsHidden()
    return true
end

function modifier_item_maiar_pendant:IsPurgable()
	return false
end

function modifier_item_maiar_pendant:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_maiar_pendant:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    }
end


function modifier_item_maiar_pendant:GetModifierPercentageManacost()
    return self:GetAbility():GetSpecialValueFor("manacost_reduction")
end

function modifier_item_maiar_pendant:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_maiar_pendant:GetModifierSpellAmplify_Percentage()
    return self:GetAbility():GetSpecialValueFor("spell_amp")
end


if IsServer() then

function modifier_item_maiar_pendant:OnCreated()
	local ability = self:GetAbility()
	self.parent = self:GetParent()
	self.interval = ability:GetSpecialValueFor("interval")
	self.proc_mana = ability:GetSpecialValueFor("proc_mana")
	self:StartIntervalThink(self.interval)
end
function modifier_item_maiar_pendant:OnIntervalThink()
	if self.parent:GetManaPercent() < self.proc_mana then
		self.parent:AddNewModifier(self.parent, self:GetAbility(), "modifier_item_maiar_pendant_thinker", {})
	end
end

end
LinkLuaModifier("modifier_item_maiar_pendant_thinker", "items/item_maiar_pendant.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_maiar_pendant_thinker = class({})

function modifier_item_maiar_pendant_thinker:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }
end

function modifier_item_maiar_pendant_thinker:GetModifierTotalPercentageManaRegen()
    return self:GetAbility():GetSpecialValueFor("proc_mana_regen")
end


function modifier_item_maiar_pendant_thinker:GetTexture()
	return "maiar_pendant_thinker"
end
function modifier_item_maiar_pendant_thinker:GetEffectName()
	return "particles/world_shrine/radiant_shrine_regen.vpcf"
end

function modifier_item_maiar_pendant_thinker:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

if IsServer() then
	function modifier_item_maiar_pendant_thinker:OnCreated()
		local ability = self:GetAbility()
		self.min_mana = ability:GetSpecialValueFor("min_mana")
		self.regen_reduction = ability:GetSpecialValueFor("hp_regen_reduction") * 0.01
		self.parent = self:GetParent()
		self.modifier = self.parent:AddNewModifier(self.parent, ability, "modifier_item_maiar_pendant_regen", {})
		self.modifier:SetStackCount((self.parent:GetHealthRegen() + self.modifier:GetStackCount()) * self.regen_reduction)
		self.interval = ability:GetSpecialValueFor("interval")
		self:StartIntervalThink(self.interval)
	end
	
	function modifier_item_maiar_pendant_thinker:OnIntervalThink()
		self.modifier:SetStackCount((self.parent:GetHealthRegen() + self.modifier:GetStackCount()) * self.regen_reduction)
		if self.parent:GetManaPercent() > self.min_mana or not self.parent:HasItemInInventory("item_maiar_pendant") then
			self:Destroy()
		end
	end
	
	function modifier_item_maiar_pendant_thinker:OnDestroy()
		self.modifier:Destroy()
	end
end

LinkLuaModifier("modifier_item_maiar_pendant_regen", "items/item_maiar_pendant.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_maiar_pendant_regen = class({})

function modifier_item_maiar_pendant_regen:IsHidden()
    return true
end

function modifier_item_maiar_pendant_regen:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }
end

function modifier_item_maiar_pendant_regen:GetModifierConstantHealthRegen()
    return -self:GetStackCount()
end