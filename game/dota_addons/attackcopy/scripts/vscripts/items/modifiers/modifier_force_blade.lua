--[[Author: Nightborn
	Date: August 27, 2016
]]

modifier_force_blade = class({})

function modifier_force_blade:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_force_blade:OnAttackLanded (keys)

	if keys.unit == self:GetParent() then

	local caster = self:GetParent()
	local target = keys.target
	local damage = keys.damage * 50
	local ability = self:GetAbility()

	if target:IsAlive() then
		target:SetHealth(target:GetHealth() + keys.damage)
	end
	local dealt_damage = ApplyDamage({
		ability = ability,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		victim = target
	})


	end



end

function modifier_force_blade:IsHidden()
	return false
end

function modifier_force_blade:RemoveOnDeath()
	return false
end

function modifier_force_blade:IsPurgable()
	return false
end