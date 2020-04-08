require("lib/my")

custom_refund = class({})

function custom_refund:GetIntrinsicModifierName()
    return "modifier_custom_refund"
end
tower_custom_refund = class(custom_refund)
rax_custom_refund = class(custom_refund)
LinkLuaModifier("modifier_custom_refund", "abilities/other/custom_refund.lua", LUA_MODIFIER_MOTION_NONE)
modifier_custom_refund = class({})

function modifier_custom_refund:IsHidden()
    return true
end
function modifier_custom_refund:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
    }
end
if IsServer() then
	function modifier_custom_refund:OnCreated(keys)
		self.parent = self:GetParent()
		self.location = self:GetParent():GetAbsOrigin()
		self.ability = self:GetAbility()
		self.team = self.parent:GetTeam()
		self.tick_interval = self.ability:GetSpecialValueFor("interval")
		self.damage_taken_pct = self.ability:GetSpecialValueFor("damage_taken_pct") * 0.01
		self.radius = self.ability:GetSpecialValueFor("radius")
		self:StartIntervalThink(self.tick_interval)
	end
	
	function modifier_custom_refund:OnIntervalThink()
		local units = FindUnitsInRadius(self.team,
			self.parent:GetAbsOrigin(),
			nil,
			self.radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false)
		if #units > 0 then
			ApplyDamage({victim = self.parent,
				attacker = self.parent,
				damage = self.parent:GetMaxHealth() * self.damage_taken_pct,
				damage_type = DAMAGE_TYPE_PURE,
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
				nil,
			})
		end
    end
	
	function modifier_custom_refund:OnDeath(keys)
		if self.parent == keys.unit then
			self.parent:GetOwner():ModifyGold(self:GetAbility():GetSpecialValueFor("refund"), true, 0)
		end
	end

end
