require("lib/my")

function add_perma(keys)
	if keys.caster:IsHero() then
		keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_item_plain_ring_perma", {duration = -1, invincibility_duration = keys.ability:GetSpecialValueFor("duration"), cooldown = keys.ability:GetSpecialValueFor("cooldown"), min_health = keys.ability:GetSpecialValueFor("min_health")})
		keys.caster:RemoveItem(find_item(keys.caster, "item_plain_perma"))
	end
end

LinkLuaModifier("modifier_item_plain_ring_perma", "items/item_plain_ring_perma.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_plain_ring_perma = class({})

function modifier_item_plain_ring_perma:GetTexture()
	return "plain_ring"
end

function modifier_item_plain_ring_perma:IsHidden()
	return false
end
function modifier_item_plain_ring_perma:IsPurgable()
	return false
end
function modifier_item_plain_ring_perma:RemoveOnDeath()
    return false
end
if IsServer() then

function modifier_item_plain_ring_perma:OnIntervalThink()
	if self.cooldownCounter > 0 then
		self.cooldownCounter = self.cooldownCounter -1
	else
		self:StartIntervalThink(-1)
	end
	self:SetStackCount(self.cooldownCounter)
end

function modifier_item_plain_ring_perma:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end


function modifier_item_plain_ring_perma:OnCreated(keys)
	self.parent = self:GetParent()
	self.invincibility_duration = keys.invincibility_duration
	self.cooldown = keys.cooldown
	self.cooldownCounter = 0
	self:SetStackCount(0)
	self.ability = self:GetAbility()
	self.min_health = keys.min_health
end


function modifier_item_plain_ring_perma:OnTakeDamage(keys)
	local attacker = keys.attacker
	local unit = keys.unit
	if self.parent == unit and self.cooldownCounter == 0 and self.parent:GetHealth() < 1  then
		self.parent:SetHealth(1)
		self.parent:AddNewModifier(self.parent, self.ability, "modifier_item_plain_ring_perma_invincibility", {duration = self.invincibility_duration, min_health = self.min_health})
		self.cooldownCounter = math.floor(self.cooldown * self.parent:GetCooldownReduction())
		self:StartIntervalThink(1)
	end
end

end

LinkLuaModifier("modifier_item_plain_ring_perma_invincibility", "items/item_plain_ring_perma.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_plain_ring_perma_invincibility = class({})
if IsServer() then
function modifier_item_plain_ring_perma_invincibility:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MIN_HEALTH,
	}
end

function modifier_item_plain_ring_perma_invincibility:IsPurgable()
	return false
end


function modifier_item_plain_ring_perma_invincibility:GetMinHealth()
	return 1
end
function modifier_item_plain_ring_perma_invincibility:OnCreated(keys)
local parent = self:GetParent()
	self.min_health = keys.min_health
end
function modifier_item_plain_ring_perma_invincibility:OnDestroy()
local parent = self:GetParent()
	ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
	parent:Heal((parent:GetMaxHealth() * self.min_health * 0.01), parent)
end
end
function modifier_item_plain_ring_perma_invincibility:GetTexture()
	return "plain_ring_invincibility"
end
function modifier_item_plain_ring_perma_invincibility:GetEffectName()
	return "particles/world_shrine/dire_shrine_regen.vpcf"
end

function modifier_item_plain_ring_perma_invincibility:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end