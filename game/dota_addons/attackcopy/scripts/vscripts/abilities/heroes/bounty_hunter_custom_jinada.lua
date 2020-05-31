require("lib/my")
require("lib/popup")

bounty_hunter_custom_jinada = class({})


function bounty_hunter_custom_jinada:GetIntrinsicModifierName()
    return "modifier_bounty_hunter_custom_jinada"
end




LinkLuaModifier("modifier_bounty_hunter_custom_jinada", "abilities/heroes/bounty_hunter_custom_jinada.lua", LUA_MODIFIER_MOTION_NONE)

modifier_bounty_hunter_custom_jinada = class({})


function modifier_bounty_hunter_custom_jinada:IsHidden()
    return true
end


if IsServer() then
    function modifier_bounty_hunter_custom_jinada:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK,
        }
    end
    function modifier_bounty_hunter_custom_jinada:OnCreated()
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
		self.gold_ratio = self.ability:GetSpecialValueFor("gold_damage_pct") * 0.01
		if self.parent:IsIllusion() then
			self.gold_amount = self.ability:GetSpecialValueFor("gold_bonus") / 2
			self.gold_ratio = self.gold_ratio / 2
		else
			self.gold_amount = self.ability:GetSpecialValueFor("gold_bonus")
		end
		
		self.damage_type = self.ability:GetAbilityDamageType()

    end
    
    function modifier_bounty_hunter_custom_jinada:OnAttack(keys)
        local attacker = keys.attacker
        if attacker ~= self.parent then 
            return 
        end
		if self.ability:GetCooldownTimeRemaining() > 0 then
			return
		end
        local target = keys.target
		local damage = self.gold_ratio * self.parent:GetGold()
		
		PlayerResource:ModifyGold(self.parent:GetPlayerID(), self.gold_amount, false, DOTA_ModifyGold_Unspecified)
		local finaldamage = ApplyDamage({
			ability = self.ability,
			attacker = self.parent,
			damage = damage,
			damage_type = self.damage_type,
			victim = target
		})
		self.ability:UseResources(false, false, true)
		self.parent:EmitSoundParams("Hero_BountyHunter.Jinada", 0, 0.65, 0)
		local fx = ParticleManager:CreateParticle("particles/custom/jinada.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControlEnt(fx, 0, target, PATTACH_ABSORIGIN, "attach_origin", target:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(fx)
		create_popup({
			target = target,
			value = damage,
			color = Vector(255, 219, 77),
			type = "spell",
			pos = 6
		})
    end
end