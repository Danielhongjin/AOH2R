LinkLuaModifier("modifier_skill_trident", "modifiers/modifier_tier_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skill_transfusion", "modifiers/modifier_tier_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skill_dashdamage", "modifiers/modifier_tier_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skill_flames", "modifiers/modifier_tier_3.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skill_flames_counter", "modifiers/modifier_tier_3.lua", LUA_MODIFIER_MOTION_NONE)
modifier_skill_trident = class({})

function modifier_skill_trident:IsPurgable()
    return false
end

function modifier_skill_trident:IsHidden()
    return true
end

function modifier_skill_trident:IsDebuff()
    return false
end

function modifier_skill_trident:RemoveOnDeath()
    return false
end

function modifier_skill_trident:AllowIllusionDuplicate()
    return false
end

function modifier_skill_trident:GetTexture()
    return "modifier_skill_trident"
end
if IsServer() then
	function modifier_skill_trident:OnCreated()
		local parent = self:GetParent()
		for slot = 0, 15 do
			local ability = parent:GetAbilityByIndex(slot)
			if ability and ability:GetName() == "generic_hidden" then
				parent:RemoveAbilityByHandle(ability)
				break
			end
		end
		local skill = parent:AddAbility("skill_trident")
		skill:SetLevel(1)
	end
	function modifier_skill_trident:OnDestroy()
		local parent = self:GetParent()
		parent:RemoveAbility("skill_trident")
	end
end

modifier_skill_transfusion = class({})

function modifier_skill_transfusion:IsPurgable()
    return false
end

function modifier_skill_transfusion:IsHidden()
    return true
end

function modifier_skill_transfusion:IsDebuff()
    return false
end

function modifier_skill_transfusion:RemoveOnDeath()
    return false
end

function modifier_skill_transfusion:AllowIllusionDuplicate()
    return true
end

function modifier_skill_transfusion:GetTexture()
    return "modifier_skill_transfusion"
end


if IsServer() then
	function modifier_skill_transfusion:OnCreated()
		local parent = self:GetParent()
		for slot = 0, 15 do
			local ability = parent:GetAbilityByIndex(slot)
			if ability and ability:GetName() == "generic_hidden" then
				parent:RemoveAbilityByHandle(ability)
				break
			end
		end
		local skill = parent:AddAbility("skill_transfusion")
		skill:SetLevel(1)
	end
	function modifier_skill_transfusion:OnDestroy()
		local parent = self:GetParent()
		parent:RemoveAbility("skill_transfusion")
	end
end

modifier_skill_dashdamage = class({})

function modifier_skill_dashdamage:IsPurgable()
    return false
end

function modifier_skill_dashdamage:IsHidden()
    return true
end

function modifier_skill_dashdamage:IsDebuff()
    return false
end

function modifier_skill_dashdamage:RemoveOnDeath()
    return false
end

function modifier_skill_dashdamage:AllowIllusionDuplicate()
    return true
end

function modifier_skill_dashdamage:GetTexture()
    return "modifier_skill_dashdamage"
end


function modifier_skill_dashdamage:GetTexture()
    return "modifier_skill_dashdamage"
end

modifier_skill_flames = class({})

function modifier_skill_flames:IsPurgable()
    return false
end

function modifier_skill_trident:IsHidden()
    return true
end

function modifier_skill_flames:RemoveOnDeath()
    return false
end

function modifier_skill_flames:AllowIllusionDuplicate()
    return true
end

function modifier_skill_flames:GetTexture()
    return "modifier_skill_flames"
end

function modifier_skill_flames:DeclareFunctions()
    return {
		MODIFIER_EVENT_ON_ATTACKED,
    }
end

if IsServer() then
	function modifier_skill_flames:OnCreated()
		self.parent = self:GetParent()
		self.ability = self.parent:FindAbilityByName("hero_attribute_fix")
	end
	function modifier_skill_flames:OnDestroy()
		self.counter:Destroy()
	end
end
function modifier_skill_flames:OnAttacked(keys)
	local attacker = keys.attacker
	local victim = keys.target
	if attacker == self.parent or self.parent == victim then
		self:IncrementStackCount()
		local damage_victim = victim
		if self.parent == victim then
			damage_victim = attacker
			self.parent:AddNewModifier(self.parent, nil, "modifier_skill_flames_counter", {duration = 12})
		else
			self.parent:AddNewModifier(self.parent, nil, "modifier_skill_flames_counter", {duration = 8})
		end
		local fx = ParticleManager:CreateParticle("particles/custom/skill_flames.vpcf", PATTACH_POINT_FOLLOW, self.parent)
		ParticleManager:SetParticleControlEnt(
			fx,
			3,
			damage_victim,
			PATTACH_POINT,
			"attach_hitloc",
			damage_victim:GetAbsOrigin(), -- unknown
			true -- unknown, true
		)
		create_popup({
			target = damage_victim,
			value = self:GetStackCount() * 3,
			color = Vector(100, 95, 237),
			type = "spell",
			pos = 6
		})
		ApplyDamage({
			attacker = self.parent,
			victim = damage_victim,
			ability = self.ability,
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage = self:GetStackCount() * 3,
			damage_flags = DOTA_DAMAGE_FLAG_REFLECTION
		})
	end
end

function modifier_skill_flames:OnDestroy()
end


modifier_skill_flames_counter = class({})

function modifier_skill_flames_counter:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_skill_flames_counter:IsPurgable()
    return false
end

function modifier_skill_flames_counter:IsDebuff()
    return false
end

function modifier_skill_flames_counter:IsHidden()
    return true
end

function modifier_skill_flames_counter:RemoveOnDeath()
    return false
end
if IsServer() then
	function modifier_skill_flames_counter:OnDestroy()
		self:GetParent():FindModifierByName("modifier_skill_flames"):DecrementStackCount()
	end
end