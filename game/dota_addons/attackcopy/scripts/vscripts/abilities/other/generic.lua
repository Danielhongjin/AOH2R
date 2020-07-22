require("lib/timers")
require("lib/my")
require("lib/ai")

local spells_aoe = {[0] = "custom_crystal_nova", 
"custom_black_hole", 
"custom_torrent",
"custom_torrent_tide",
"custom_maledict",
"custom_ice_path", -- index 5
"custom_desolation",
"custom_banish",
"custom_dark_artistry",
"custom_spectral_dagger",
"custom_fissure", -- index 10
"custom_carrion_swarm",
"custom_nyx_impale",
"custom_spiritbreaker_inner_fire",
"custom_deafening_blast",
"custom_mystic_flare", -- index 15
"custom_shockwave",
"boss_spiritbear_inner_fire",
"boss_lone_druid_split_earth",
"boss_invoker_arcane_whirl",
"boss_undying_tombstone", -- index 20
"boss_legion_commander_overwhelming_odds",
"boss_legion_commander_gods_rebuke",
}
local spells_target = {[0] = "custom_static_link", 
"custom_frostbite", 
"custom_mana_void", 
"custom_omni_slash_jugg", 
"custom_doom", 
"custom_lightning_bolt", -- index 5
"custom_chaos_bolt", 
"custom_sunray", 
"custom_reality_rift",
"custom_primal_roar",
"custom_paralyzing_cask", -- index 10
"custom_nether_strike",
"custom_purifying_flames",
"custom_life_drain",
"custom_sunder",
"boss_lone_druid_maul", -- index 15
"boss_invoker_telekinesis",
"boss_kobold_command",
"boss_undying_soul_rip",
}
--Fires a warning aoe to a point and casts the spell immediately
function generate_warning_aoe(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local delay = keys.delay
	local spell = caster:FindAbilityByName(spells_aoe[keys.ability_index])
	if keys.is_line and keys.is_line == 1 then
		local norm = (point - caster:GetAbsOrigin()):Normalized()
		point = caster:GetAbsOrigin() + norm * keys.line_length
		local fx = ParticleManager:CreateParticle("particles/custom/line_aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(fx, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(fx, 1, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(fx, 2, point)
		ParticleManager:SetParticleControl(fx, 3, Vector(keys.radius, keys.radius, 1))
		ParticleManager:SetParticleControl(fx, 4, Vector(keys.delay, 1, 1))
		ParticleManager:ReleaseParticleIndex(fx)
	else 
		local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(fx, 0, point)
		ParticleManager:SetParticleControl(fx, 1, Vector(keys.radius, 1, 1))
		ParticleManager:SetParticleControl(fx, 2, Vector(keys.delay, 1, 1))
		ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
		ParticleManager:ReleaseParticleIndex(fx)
		local fx2 = ParticleManager:CreateParticle("particles/custom/link_warning.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(fx2, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(fx2, 1, point)
		ParticleManager:SetParticleControl(fx2, 2, Vector(keys.delay, 1, 1))
		ParticleManager:ReleaseParticleIndex(fx2)
	end
	EmitSoundOn("Hero_Mars.Spear.Cast", caster)
	caster:CastAbilityOnPosition(point, spell, -1)
end

function generic_aoe_noanim(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local delay = keys.delay
	local spell = caster:FindAbilityByName(spells_aoe[keys.ability_index])
	if keys.is_line and keys.is_line == 1 then
		local norm = (point - caster:GetAbsOrigin()):Normalized()
		norm = caster:GetAbsOrigin() + norm * keys.line_length
		local fx = ParticleManager:CreateParticle("particles/custom/line_aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(fx, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(fx, 1, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(fx, 2, norm)
		ParticleManager:SetParticleControl(fx, 3, Vector(keys.radius, keys.radius, 1))
		ParticleManager:SetParticleControl(fx, 4, Vector(keys.delay, 1, 1))
		ParticleManager:ReleaseParticleIndex(fx)
	else 
		local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(fx, 0, point)
		ParticleManager:SetParticleControl(fx, 1, Vector(keys.radius, 1, 1))
		ParticleManager:SetParticleControl(fx, 2, Vector(keys.delay, 1, 1))
		ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
		ParticleManager:ReleaseParticleIndex(fx)
		local fx2 = ParticleManager:CreateParticle("particles/custom/link_warning.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(fx2, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(fx2, 1, point)
		ParticleManager:SetParticleControl(fx2, 2, Vector(keys.delay, 1, 1))
		ParticleManager:ReleaseParticleIndex(fx2)
	end
	EmitSoundOn("Hero_Mars.Spear.Cast", caster)
	Timers:CreateTimer(
		delay - spell:GetCastPoint(), 
		function()
			if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil then
				return 0.5
			end
			spell:EndCooldown()
			caster:CastAbilityOnPosition(point, spell, -1)
		end
	)
end

function generic_aoe(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local delay = keys.delay
	local spell = caster:FindAbilityByName(spells_aoe[keys.ability_index])
	Timers:CreateTimer(
		0, 
		function()
			if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil or caster:IsCommandRestricted() then
				return 0.5
			end
			if keys.is_line and keys.is_line == 1 then
				local norm = (point - caster:GetAbsOrigin()):Normalized()
				norm = caster:GetAbsOrigin() + norm * keys.line_length
				local fx = ParticleManager:CreateParticle("particles/custom/line_aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(fx, 0, caster:GetAbsOrigin())
				ParticleManager:SetParticleControl(fx, 1, caster:GetAbsOrigin())
				ParticleManager:SetParticleControl(fx, 2, norm)
				ParticleManager:SetParticleControl(fx, 3, Vector(keys.radius, keys.radius, 1))
				ParticleManager:SetParticleControl(fx, 4, Vector(keys.delay, 1, 1))
				ParticleManager:ReleaseParticleIndex(fx)
			else 
				local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(fx, 0, point)
				ParticleManager:SetParticleControl(fx, 1, Vector(keys.radius, 1, 1))
				ParticleManager:SetParticleControl(fx, 2, Vector(keys.delay, 1, 1))
				ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
				ParticleManager:ReleaseParticleIndex(fx)
				local fx2 = ParticleManager:CreateParticle("particles/custom/link_warning.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
				ParticleManager:SetParticleControlEnt(fx2, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(fx2, 1, point)
				ParticleManager:SetParticleControl(fx2, 2, Vector(keys.delay, 1, 1))
				ParticleManager:ReleaseParticleIndex(fx2)
			end
			if caster:IsMoving() then
				caster:Stop()
				caster:FaceTowards(point)
			end
			EmitSoundOn("Hero_Mars.Spear.Cast", caster)
			StartAnimation(caster, {duration = keys.anim_duration, activity = ACT_DOTA_CAST_ABILITY_1, rate = 1 / keys.anim_duration})
			caster:AddNewModifier(caster, ability, "modifier_anim", {duration = keys.anim_duration})
			Timers:CreateTimer(
				delay - spell:GetCastPoint(), 
				function()
					if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil then
						return 0.5
					end
					spell:EndCooldown()
					caster:CastAbilityOnPosition(point, spell, -1)
				end
			)
		end
	)
end

function generic_aoe_notarget(keys)
	local caster = keys.caster
	local ability = keys.ability
	local delay = keys.delay
	local spell = caster:FindAbilityByName(spells_aoe[keys.ability_index])
	Timers:CreateTimer(
		0, 
		function()
			if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil or caster:IsCommandRestricted() then
				return 0.5
			end
			local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(fx, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(fx, 1, Vector(keys.radius, 1, 1))
			ParticleManager:SetParticleControl(fx, 2, Vector(keys.delay, 1, 1))
			ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
			ParticleManager:ReleaseParticleIndex(fx)
			if caster:IsMoving() then
				caster:Stop()
			end
			EmitSoundOn("Hero_Mars.Spear.Cast", caster)
			StartAnimation(caster, {duration = keys.anim_duration, activity = ACT_DOTA_CAST_ABILITY_1, rate = 1 / keys.anim_duration})
			caster:AddNewModifier(caster, ability, "modifier_anim", {duration = keys.anim_duration})
			Timers:CreateTimer(
				delay - spell:GetCastPoint(), 
				function()
					if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil then
						return 0.5
					end
					print("yes")
					spell:EndCooldown()
					caster:CastAbilityNoTarget(spell, -1)
				end
			)
		end
	)
end

function generic_aoe_farpoint(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local delay = keys.delay
	local spell = caster:FindAbilityByName(spells_aoe[keys.ability_index])
	Timers:CreateTimer(
		0, 
		function()
			if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil or caster:IsCommandRestricted() then
				return 0.5
			end
			if keys.is_line and keys.is_line == 1 then
				local start_radius = keys.initial_radius or keys.radius
				local norm = (point - caster:GetAbsOrigin()):Normalized()
				point = caster:GetAbsOrigin() + norm * keys.line_length
				local fx = ParticleManager:CreateParticle("particles/custom/line_aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(fx, 0, caster:GetAbsOrigin())
				ParticleManager:SetParticleControl(fx, 1, caster:GetAbsOrigin())
				ParticleManager:SetParticleControl(fx, 2, point)
				ParticleManager:SetParticleControl(fx, 3, Vector(keys.radius, start_radius, 1))
				ParticleManager:SetParticleControl(fx, 4, Vector(keys.delay, 1, 1))
				ParticleManager:ReleaseParticleIndex(fx)
			else 
				local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(fx, 0, point)
				ParticleManager:SetParticleControl(fx, 1, Vector(keys.radius, 1, 1))
				ParticleManager:SetParticleControl(fx, 2, Vector(keys.delay, 1, 1))
				ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
				ParticleManager:ReleaseParticleIndex(fx)
				local fx2 = ParticleManager:CreateParticle("particles/custom/link_warning.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
				ParticleManager:SetParticleControlEnt(fx2, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(fx2, 1, point)
				ParticleManager:SetParticleControl(fx2, 2, Vector(keys.delay, 1, 1))
				ParticleManager:ReleaseParticleIndex(fx2)
			end
			
			if caster:IsMoving() then
				caster:Stop()
				caster:FaceTowards(point)
			end
			EmitSoundOn("Hero_Mars.Spear.Cast", caster)
			StartAnimation(caster, {duration = keys.anim_duration, activity = ACT_DOTA_CAST_ABILITY_1, rate = 1 / keys.anim_duration})
			caster:AddNewModifier(caster, ability, "modifier_anim", {duration = keys.anim_duration})
			Timers:CreateTimer(
				delay - spell:GetCastPoint(), 
				function()
					if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil then
						return 0.5
					end
					spell:EndCooldown()
					caster:CastAbilityOnPosition(point, spell, -1)
				end
			)
		end
	)
end

function generic_target(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local delay = keys.delay
	local spell = caster:FindAbilityByName(spells_target[keys.ability_index])
	Timers:CreateTimer(
		0, 
		function()
			if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil or caster:IsCommandRestricted() then
				return 0.5
			end
		if caster:IsMoving() then
			caster:Stop()
			caster:FaceTowards(keys.target:GetAbsOrigin())
		end
		EmitSoundOn("Hero_Mars.Spear.Cast", caster)
		target:AddNewModifier(caster, ability, "modifier_target_delay", {duration = delay})
		StartAnimation(caster, {duration = delay, activity = ACT_DOTA_CAST_ABILITY_1, rate = 1 / delay})
		caster:AddNewModifier(caster, ability, "modifier_anim", {duration = delay})
		Timers:CreateTimer(
			delay - spell:GetCastPoint(), 
			function()
				if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil then
					return 0.5
				end
				spell:EndCooldown()
				caster:CastAbilityOnTarget(target, spell, -1)
			end
		)
		end
	)
end

function generic_target_aoe(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target:GetAbsOrigin()
	local delay = keys.delay
	local spell = caster:FindAbilityByName(spells_aoe[keys.ability_index])
	Timers:CreateTimer(
		0, 
		function()
			if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil or caster:IsCommandRestricted() then
				return 0.5
			end
			
			if keys.is_line and keys.is_line == 1 then
				local start_radius = keys.initial_radius or keys.radius
				local norm = (point - caster:GetAbsOrigin()):Normalized()
				norm = caster:GetAbsOrigin() + norm * keys.line_length
				local fx = ParticleManager:CreateParticle("particles/custom/line_aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(fx, 0, caster:GetAbsOrigin())
				ParticleManager:SetParticleControl(fx, 1, caster:GetAbsOrigin())
				ParticleManager:SetParticleControl(fx, 2, norm)
				ParticleManager:SetParticleControl(fx, 3, Vector(keys.radius, start_radius, 1))
				ParticleManager:SetParticleControl(fx, 4, Vector(keys.delay, 1, 1))
				ParticleManager:ReleaseParticleIndex(fx)
			else 
				local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(fx, 0, point)
				ParticleManager:SetParticleControl(fx, 1, Vector(keys.radius, 1, 1))
				ParticleManager:SetParticleControl(fx, 2, Vector(keys.delay, 1, 1))
				ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
				ParticleManager:ReleaseParticleIndex(fx)
				local fx2 = ParticleManager:CreateParticle("particles/custom/link_warning.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
				ParticleManager:SetParticleControlEnt(fx2, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(fx2, 1, point)
				ParticleManager:SetParticleControl(fx2, 2, Vector(keys.delay, 1, 1))
				ParticleManager:ReleaseParticleIndex(fx2)
			end
			if caster:IsMoving() then
				caster:Stop()
				caster:FaceTowards(point)
			end
			caster:EmitSound("Hero_Mars.Spear.Cast")
			StartAnimation(caster, {duration = keys.anim_duration, activity = ACT_DOTA_CAST_ABILITY_1, rate = 1 / keys.anim_duration})
			Timers:CreateTimer(
				delay - spell:GetCastPoint(), 
				function()
					if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil then
						return 0.5
					end
					caster:SetForwardVector((point - caster:GetAbsOrigin()):Normalized())
					caster:SetCursorPosition(point)
					spell:OnSpellStart()
					caster:SetForwardVector((point - caster:GetAbsOrigin()):Normalized())
				end
			)
		end
	)
end

function generic_target_random(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = ai_random_alive_hero()
	local delay = keys.delay
	local spell = caster:FindAbilityByName(spells_target[keys.ability_index])
	Timers:CreateTimer(
		0, 
		function()
			if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil or caster:IsCommandRestricted() then
				return 0.5
			end
			target:AddNewModifier(caster, ability, "modifier_target_delay", {duration = delay})
			if caster:IsMoving() then
				caster:Stop()
				caster:FaceTowards(point)
			end
			StartAnimation(caster, {duration = keys.anim_duration, activity = ACT_DOTA_CAST_ABILITY_1, rate = 1 / keys.anim_duration})
			caster:AddNewModifier(caster, ability, "modifier_anim", {duration = keys.anim_duration})
			Timers:CreateTimer(
				delay - spell:GetCastPoint(), 
				function()
					if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil then
						return 0.5
					end
					spell:EndCooldown()
					caster:CastAbilityOnTarget(target, spell, -1)
				end
			)
		end
	)
end

function generic_target_random_noanim(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = ai_random_alive_hero()
	local delay = keys.delay
	local spell = caster:FindAbilityByName(spells_target[keys.ability_index])
	target:AddNewModifier(caster, ability, "modifier_target_delay", {duration = delay})
	Timers:CreateTimer(
		delay - spell:GetCastPoint(), 
		function()
			if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil then
				return 0.5
			end
			spell:EndCooldown()
			caster:CastAbilityOnTarget(target, spell, -1)
		end
	)
end

LinkLuaModifier("modifier_target_delay", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
modifier_target_delay = class({})

function modifier_target_delay:IsPurgable()
	return false
end

function modifier_target_delay:RemoveOnDeath()
	return false
end

function modifier_target_delay:IsHidden()
	return false
end

function modifier_target_delay:GetTexture()
	return "grimstroke_spirit_walk"
end

function modifier_target_delay:IsDebuff()
	return true
end

function modifier_target_delay:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_target_delay:OnCreated(keys)
	self.parent = self:GetParent()
	local caster = self:GetCaster()
	self.fx = ParticleManager:CreateParticle("particles/custom/target_warning.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.fx, 0, self.parent, PATTACH_OVERHEAD_FOLLOW, "follow_overhead", self.parent:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(self.fx, 1, Vector(keys.duration, 1, 0))
	self.fx2 = ParticleManager:CreateParticle("particles/custom/link_warning.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.fx2, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.fx2, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(self.fx2, 2, Vector(keys.duration, 1, 0))

end

function modifier_target_delay:OnDestroy()
	self.parent = self:GetParent()
	ParticleManager:DestroyParticle(self.fx, false)
	ParticleManager:DestroyParticle(self.fx2, false)
	ParticleManager:ReleaseParticleIndex(self.fx)
	ParticleManager:ReleaseParticleIndex(self.fx2)
end

LinkLuaModifier("modifier_anim", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
modifier_anim = class({})

function modifier_anim:IsPurgable()
	return false
end

function modifier_anim:IsHidden()
	return true
end

function modifier_anim:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}
	return state
end

