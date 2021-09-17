LinkLuaModifier("modifier_skeleton_king_hidden_skeleton", "abilities/heroes/skeleton_king_hidden_skeleton.lua", LUA_MODIFIER_MOTION_NONE)
skeleton_king_hidden_skeleton = class({})


function skeleton_king_hidden_skeleton:GetIntrinsicModifierName()
    return "modifier_skeleton_king_hidden_skeleton"
end

function skeleton_king_hidden_skeleton:OnHeroLevelUp()
    print("heyo")
end

modifier_skeleton_king_hidden_skeleton = class({})


function modifier_skeleton_king_hidden_skeleton:IsHidden()
    return true
end
function modifier_skeleton_king_hidden_skeleton:RemoveOnDeath()
    return false
end

function modifier_skeleton_king_hidden_skeleton:IsPurgable()
    return false
end

function modifier_skeleton_king_hidden_skeleton:GetTexture()
    return "atr_fix"
end

function modifier_skeleton_king_hidden_skeleton:DeclareFunctions()
    return {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
    }
end

if IsServer() then
	function modifier_skeleton_king_hidden_skeleton:OnCreated()
		self.parent = self:GetParent()
		local ability = self:GetAbility()
		self.skeleton = self.parent:FindAbilityByName("skeleton_king_vampiric_aura")
		self.minimum = ability:GetSpecialValueFor("minimum_stacks")
		Timers:CreateTimer(
			function()
				if not self.parent:HasModifier("modifier_skeleton_king_vampiric_aura") then
					return 0.25
				else 
					self.modifier = self.parent:FindModifierByName("modifier_skeleton_king_vampiric_aura")
					self.modifier:SetStackCount(self.minimum)
				end
			end
		)
	end
	function modifier_skeleton_king_hidden_skeleton:OnAbilityFullyCast(keys)
		local used_ability = keys.ability
		local unit = keys.unit
		if unit == self.parent and keys.ability:GetAbilityName() == "skeleton_king_vampiric_aura" then
			self.modifier:SetStackCount(self.minimum)
		end
	end
end