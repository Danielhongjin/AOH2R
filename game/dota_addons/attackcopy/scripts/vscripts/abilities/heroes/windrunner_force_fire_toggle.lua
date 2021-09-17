


windrunner_force_fire_toggle = class({})


if IsServer() then
    function windrunner_force_fire_toggle:OnToggle()
        local caster = self:GetCaster()

        if self:GetToggleState() then
            caster:AddNewModifier(caster, self, "modifier_windrunner_focus_fire_toggle_interim", {})
        else
            caster:RemoveModifierByName("modifier_windrunner_focus_fire_toggle_interim")
        end
    end
end
LinkLuaModifier("modifier_windrunner_focus_fire_toggle_interim", "abilities/heroes/windrunner_force_fire_toggle.lua", LUA_MODIFIER_MOTION_NONE)

modifier_windrunner_focus_fire_toggle_interim = class({})


function modifier_windrunner_focus_fire_toggle_interim:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START,
	}
end

function modifier_windrunner_focus_fire_toggle_interim:IsPurgable()
	return false
end

function modifier_windrunner_focus_fire_toggle_interim:IsHidden()
	return true
end

function modifier_windrunner_focus_fire_toggle_interim:AllowIllusionDuplicate()
	return true
end

if IsServer() then
	function modifier_windrunner_focus_fire_toggle_interim:OnCreated()
		local parent = self:GetParent()
		Timers:CreateTimer(
			0.07, 
			function()
				parent:AddNewModifier(parent, self:GetAbility(), "modifier_windrunner_focus_fire_toggle", {})
			end
		)
		
	end
	function modifier_windrunner_focus_fire_toggle_interim:OnDestroy()
		local parent = self:GetParent()
		parent:RemoveModifierByName("modifier_windrunner_focus_fire_toggle")
	end
end

LinkLuaModifier("modifier_windrunner_focus_fire_toggle", "abilities/heroes/windrunner_force_fire_toggle.lua", LUA_MODIFIER_MOTION_NONE)

modifier_windrunner_focus_fire_toggle = class({})


function modifier_windrunner_focus_fire_toggle:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START,
	}
end

function modifier_windrunner_focus_fire_toggle:IsPurgable()
	return false
end

function modifier_windrunner_focus_fire_toggle:IsHidden()
	return true
end

if IsServer() then
	function modifier_windrunner_focus_fire_toggle:OnCreated()
		self.parent = self:GetParent()
		self.focus_fire = self.parent:FindAbilityByName("windrunner_focusfire")
		if self.focus_fire:GetLevel() < 1 then
			self:GetAbility():ToggleAbility()
		end
	end

	function modifier_windrunner_focus_fire_toggle:OnAttackStart(keys)
		local attacker = keys.attacker
		local target = keys.target
		if attacker == self.parent and not target:GetTeam() ~= self.parent:GetTeam() and self.focus_fire:IsCooldownReady() then 
			if not self.parent:HasModifier("modifier_windrunner_focusfire") then
				self.parent:SetCursorCastTarget(target)
				self.focus_fire:OnSpellStart()
				self.focus_fire:UseResources(true, false, true)
			else
				self.parent:FindModifierByName("modifier_windrunner_focusfire"):SetDuration(self.focus_fire:GetDuration(), true)
				self.focus_fire:UseResources(true, false, true)
			end
		end
	end
end
