

bloodseeker_custom_thirst = class({})

if IsServer() then
function bloodseeker_custom_thirst:GetIntrinsicModifierName()
	return "modifier_bloodseeker_custom_thirst_off"
end

function bloodseeker_custom_thirst:OnToggle()
    local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_bloodseeker_custom_thirst_off")
	caster:RemoveModifierByName("modifier_bloodseeker_custom_thirst")
    if self:GetToggleState() then
        caster:AddNewModifier(caster, self, "modifier_bloodseeker_custom_thirst", {})
	else 
		caster:AddNewModifier(caster, self, "modifier_bloodseeker_custom_thirst_off", {})
    end
end


function bloodseeker_custom_thirst:OnUpgrade()
	self:ToggleAbility()
	self:ToggleAbility()
end
end

LinkLuaModifier("modifier_bloodseeker_custom_thirst_off", "abilities/heroes/bloodseeker_custom_thirst.lua", LUA_MODIFIER_MOTION_NONE)
modifier_bloodseeker_custom_thirst_off = class({})

function modifier_bloodseeker_custom_thirst_off:IsHidden()
	return true
end

if IsServer() then
	function modifier_bloodseeker_custom_thirst_off:OnCreated()
		self.parent = self:GetParent()
		self.health_regen_percent = self:GetAbility():GetSpecialValueFor( "health_regen_percent" )
		self:SetStackCount(self.health_regen_percent * self.parent:GetAverageTrueAttackDamage(self.parent) / 100)
		self:StartIntervalThink(0.25)
	end
	function modifier_bloodseeker_custom_thirst_off:OnIntervalThink()
		self:SetStackCount(self.health_regen_percent * self.parent:GetAverageTrueAttackDamage(self.parent) / 100)
	end
end
function modifier_bloodseeker_custom_thirst_off:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_bloodseeker_custom_thirst_off:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }
end

function modifier_bloodseeker_custom_thirst_off:GetModifierConstantHealthRegen()
	return self:GetStackCount()
end
function modifier_bloodseeker_custom_thirst_off:GetEffectName()
	return "particles/econ/events/ti6/fountain_regen_ribbon.vpcf"
end
function modifier_bloodseeker_custom_thirst_off:GetEffectName()
	return "particles/econ/events/ti6/fountain_regen_ribbon.vpcf"
end

function modifier_bloodseeker_custom_thirst_off:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end



LinkLuaModifier("modifier_bloodseeker_custom_thirst", "abilities/heroes/bloodseeker_custom_thirst.lua", LUA_MODIFIER_MOTION_NONE)


modifier_bloodseeker_custom_thirst = class({})


function modifier_bloodseeker_custom_thirst:IsHidden()
	return true
end

function modifier_bloodseeker_custom_thirst:OnCreated()
	-- references
	self.health_regen_percent = self:GetAbility():GetSpecialValueFor( "health_regen_percent" )
end
function modifier_bloodseeker_custom_thirst:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
end

if IsServer() then
	function modifier_bloodseeker_custom_thirst:OnCreated()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		self.health_regen_percent = self.ability:GetSpecialValueFor( "health_regen_percent" )
		self.damage = self.ability:GetSpecialValueFor("proc_damage") * 0.01
		self:SetStackCount(self.health_regen_percent * self.parent:GetAverageTrueAttackDamage(self.parent) / 100)
		self:StartIntervalThink(0.25)
	end
	function modifier_bloodseeker_custom_thirst:OnIntervalThink()
		self:SetStackCount(self.health_regen_percent * self.parent:GetAverageTrueAttackDamage(self.parent) / 100)
	end
    function modifier_bloodseeker_custom_thirst:OnAttack(keys)
		local attacker = keys.attacker
		local target = keys.target
		if attacker == self.parent and not target:IsNull() then 
			local damage = ApplyDamage({
				ability = self.ability,
				attacker = self.parent,
				damage = self.parent:GetAverageTrueAttackDamage(self.parent) * self.damage,
				damage_type = DAMAGE_TYPE_PURE,
				victim = target
			})
			ParticleManager:CreateParticle("particles/econ/items/lifestealer/ls_ti9_immortal/ls_ti9_open_wounds_blood_soft.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)

			create_popup({
				target = target,
				value = damage,
				color = Vector(195, 0, 0),
				type = "spell",
				pos = 3
			})
		
	
		end
	end
end
function modifier_bloodseeker_custom_thirst:GetEffectName()
	return "particles/world_shrine/dire_shrine_regen.vpcf"
end

function modifier_bloodseeker_custom_thirst:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_bloodseeker_custom_thirst:GetModifierConstantHealthRegen()
	return -self:GetStackCount()
end
