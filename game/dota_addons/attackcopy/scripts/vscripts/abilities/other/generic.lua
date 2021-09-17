require("lib/timers")
require("lib/my")
require("lib/ai")
require("lib/warning")
LinkLuaModifier("modifier_generic_stunned_lua", "modifiers/modifier_generic_stunned_lua.lua", LUA_MODIFIER_MOTION_NONE)

local spells_aoe = {[0] = "custom_crystal_nova", 
"boss_enigma_black_hole", 
"custom_torrent",
"boss_storm_spirit_lightning_bolt",
"custom_maledict",
"custom_ice_path", -- index 5
"custom_desolation",
"custom_banish",
"boss_elder_titan_shifting_quake",
"custom_spectral_dagger",
"custom_fissure", -- index 10
"boss_death_prophet_carrion_swarm",
"custom_nyx_impale",
"boss_spirit_breaker_inner_fire",
"custom_deafening_blast",
"custom_mystic_flare", -- index 15
"custom_shockwave",
"boss_spiritbear_inner_fire",
"boss_lone_druid_split_earth",
"boss_invoker_arcane_whirl",
"boss_undying_tombstone", -- index 20
"boss_legion_commander_overwhelming_odds",
"boss_legion_commander_gods_rebuke",
"boss_abyssal_underlord_shockwave",
"boss_beastmaster_wild_axes",
"boss_void_spirit_resonant_pulse", -- index 25
"boss_enigma_midnight_pulse",
"boss_juggernaut_instant_strike",
"boss_juggernaut_blade_fury",
"boss_invoker_trance",
"boss_phantom_lancer_spiritlance", -- index 30
"boss_phantom_lancer_doppelganger",

}
local spells_target = {[0] = "boss_wisp_friendly_electric_vortex", -- DEPRECATED
"custom_frostbite", 
"boss_enigma_malefice",
"boss_juggernaut_omni_slash", 
"custom_doom", 
"custom_lightning_bolt", -- index 5 -- DEPRECATED
"custom_chaos_bolt", 
"boss_beastmaster_hawk",
"custom_reality_rift",
"custom_primal_roar",
"custom_paralyzing_cask", -- index 10
"boss_spirit_breaker_nether_strike",
"custom_purifying_flames",
"custom_life_drain",
"custom_sunder",
"boss_lone_druid_maul", -- index 15
"boss_invoker_telekinesis",
"boss_kobold_command",
"boss_undying_soul_rip",
"boss_abyssal_underlord_firestorm",
"boss_storm_spirit_electric_vortex", -- index 20 -- DEPRECATED
"boss_storm_spirit_sigil",
"boss_beastmaster_primal_roar",
"boss_death_prophet_spirit_siphon",
}

--Fires a warning aoe to a point and casts the spell immediately
function generate_warning_aoe_noanim(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local delay = keys.delay
	local spell = caster:FindAbilityByName(spells_aoe[keys.ability_index])
	caster:SetCursorPosition(point)
	spell:OnSpellStart()
	local signifier = ParticlzeManager:CreateParticle("particles/custom/boss_block.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(signifier)
	if keys.is_line and keys.is_line == 1 then
		local start_radius = keys.initial_radius or keys.radius
		local norm = (point - caster:GetAbsOrigin()):Normalized()
		point = caster:GetAbsOrigin() + norm * keys.line_length
		local fx = aoe_line_particle(caster, keys.delay, caster:GetAbsOrigin(), norm, start_radius, keys.radius, 2)	
	else 
		local fx = aoe_particle(caster, keys.delay, point, keys.radius, 2)	
		local fx2 = line_to_point(caster, keys.delay, caster:GetAbsOrigin(), point, 2)
	end
	
end

function generic_aoe_noanim(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local delay = keys.delay
	local spell = caster:FindAbilityByName(spells_aoe[keys.ability_index])
	local signifier = ParticleManager:CreateParticle("particles/custom/boss_block.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(signifier)
	if keys.is_line and keys.is_line == 1 then
		local start_radius = keys.initial_radius or keys.radius
		local norm = (point - caster:GetAbsOrigin()):Normalized()
		norm = caster:GetAbsOrigin() + norm * keys.line_length
		local fx = aoe_line_particle(caster, keys.delay, caster:GetAbsOrigin(), norm, start_radius, keys.radius, 2)	
	else 
		local fx = aoe_particle(caster, keys.delay, point, keys.radius, 2)	
		local fx2 = line_to_point(caster, keys.delay, caster:GetAbsOrigin(), point, 2)
	end
	EmitSoundOn("Hero_Mars.Spear.Cast", caster)
	Timers:CreateTimer(
		delay - spell:GetCastPoint(), 
		function()
				
			spell:EndCooldown()
			caster:CastAbilityOnPosition(point, spell, -1)
		end
	)
end

function generic_aoe_noincrement(keys)
	local caster = keys.caster
	local ability = keys.ability
	local origin_point = keys.target_points[1]
	local delay = keys.delay
	local spell = caster:FindAbilityByName(spells_aoe[keys.ability_index])
	local range = spell:GetCastRange(origin_point, caster)
	if range == 0 then
		range = 1000
	end
	local signifier = ParticleManager:CreateParticle("particles/custom/boss_block.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	local total = 1
	local count = 0
	local point = origin_point
	local ticket_concession = caster:FindModifierByName("modifier_boss")
	local ticket = ticket_concession:RequestTicket()
	if keys.iterations then
		total = keys.iterations
	end
	local difficulty = _G.AOHGameMode._difficulty
	if difficulty == 2 then
		delay = delay * 0.8
	end
	local heroes = nil
	ParticleManager:ReleaseParticleIndex(signifier)
	Timers:CreateTimer(
		function()
			if caster:IsChanneling() or caster:IsCommandRestricted() or caster:HasModifier("modifier_casting_locked") or caster:GetCurrentActiveAbility() ~= nil or not ticket_concession:QueryTicket(ticket) then
				return 0.08
			end
			local point = nil
			if count > 0 then
				heroes = FindUnitsInRadius(caster:GetTeamNumber(),
					caster:GetAbsOrigin(),
					nil,
					range,
					DOTA_UNIT_TARGET_TEAM_ENEMY,
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					DOTA_UNIT_TARGET_FLAG_NONE,
					FIND_FARTHEST,
					false
				)
				if #heroes > 0 then
					point = random_from_table(heroes):GetAbsOrigin()
				else
					point = origin_point
				end
			else
				point = origin_point
			end
			local count_temp = count
			if keys.is_line and keys.is_line == 1 then
				local start_radius = keys.initial_radius or keys.radius
				local norm = 0
				if keys.line_length then
					norm = (point - caster:GetAbsOrigin()):Normalized()
					norm = caster:GetAbsOrigin() + norm * keys.line_length
				else
					norm = point
				end
				local fx = aoe_line_particle(caster, keys.delay, caster:GetAbsOrigin(), norm, start_radius, keys.radius, 2)	
			else 
				local fx = aoe_particle(caster, keys.delay, point, keys.radius, 2)	
				local fx2 = line_to_point(caster, keys.delay, caster:GetAbsOrigin(), point, 2)
			end
			caster:Stop()
			caster:FaceTowards(point)
			EmitSoundOn("Hero_Mars.Spear.Cast", caster)
			caster:AddNewModifier(caster, ability, "modifier_anim", {duration = keys.delay - spell:GetCastPoint()})
			StartAnimation(caster, {duration = keys.delay - spell:GetCastPoint(), activity = ACT_DOTA_CAST_ABILITY_1, rate = 1 / keys.delay - spell:GetCastPoint()})
			Timers:CreateTimer(
				delay - spell:GetCastPoint(), 
				function()
					if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil or caster:HasModifier("modifier_anim") then
						return 0.05
					end
					caster:SetForwardVector((point - caster:GetAbsOrigin()):Normalized())
					local lock = caster:AddNewModifier(caster, ability, "modifier_casting_locked", {duration = -1})
					spell:EndCooldown()
					caster:CastAbilityOnPosition(point, spell, caster:GetPlayerOwnerID())
					Timers:CreateTimer(
					spell:GetCastPoint() + 0.1,
						function()
							if not spell:IsCooldownReady() then
								lock:Destroy()
							elseif caster:GetCurrentActiveAbility() == nil then
								caster:CastAbilityOnPosition(point, spell, caster:GetPlayerOwnerID())
								return spell:GetCastPoint() + 0.1
							else
								return spell:GetCastPoint() + 0.1
							end
						end
					)
					if count_temp == total - 1 then
						ticket_concession:ReleaseTicket()
					end
				end
			)
			count = count + 1
			if count < total then
				return delay
			end
		end
	)
end
-- Holy fuck what even is this? I come back to this shit for the first time in 3 months and now I see this bullshit what the fuck
-- Why isn't this a modifier?
function generic_aoe(keys)
	local caster = keys.caster
	local ability = keys.ability
	local origin_point = keys.target_points[1]
	local delay = keys.delay
	local spell = caster:FindAbilityByName(spells_aoe[keys.ability_index])
	local range = spell:GetCastRange(origin_point, caster)
	if range == 0 then
		range = 1000
	end
	local signifier = ParticleManager:CreateParticle("particles/custom/boss_block.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	local total = 1
	local count = 0
	local point = origin_point
	local ticket_concession = caster:FindModifierByName("modifier_boss")
	local ticket = ticket_concession:RequestTicket()
	if keys.iterations then
		total = keys.iterations
	end
	local difficulty = _G.AOHGameMode._difficulty
	if difficulty == 2 then
		total = total + 1
		delay = delay * 0.8
	end
	local heroes = nil
	ParticleManager:ReleaseParticleIndex(signifier)
	Timers:CreateTimer(
		function()
			if caster:IsChanneling() or caster:IsCommandRestricted() or caster:HasModifier("modifier_casting_locked") or caster:GetCurrentActiveAbility() ~= nil or not ticket_concession:QueryTicket(ticket) then
				return 0.08
			end
			local point = nil
			if count > 0 then
				heroes = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_FARTHEST, false)
				if #heroes > 0 then
					point = random_from_table(heroes):GetAbsOrigin()
				else
					point = origin_point
				end
			else
				point = origin_point
			end
			local count_temp = count
			if keys.is_line and keys.is_line == 1 then
				local start_radius = keys.initial_radius or keys.radius
				local norm = 0
				if keys.line_length then
					norm = (point - caster:GetAbsOrigin()):Normalized()
					norm = caster:GetAbsOrigin() + norm * keys.line_length
				else
					norm = point
				end
				local fx = aoe_line_particle(caster, keys.delay, caster:GetAbsOrigin(), norm, start_radius, keys.radius, 2)	
			else 
				local fx = aoe_particle(caster, keys.delay, point, keys.radius, 2)	
				local fx2 = line_to_point(caster, keys.delay, caster:GetAbsOrigin(), point, 2)
			end
			caster:Stop()
			caster:FaceTowards(point)
			EmitSoundOn("Hero_Mars.Spear.Cast", caster)
			caster:AddNewModifier(caster, ability, "modifier_anim", {duration = keys.delay - spell:GetCastPoint()})
			StartAnimation(caster, {duration = keys.delay - spell:GetCastPoint(), activity = ACT_DOTA_CAST_ABILITY_1, rate = 1 / keys.delay - spell:GetCastPoint()})
			Timers:CreateTimer(
				delay - spell:GetCastPoint(), 
				function()
					if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil or caster:HasModifier("modifier_anim") then
						return 0.05
					end
					caster:SetForwardVector((point - caster:GetAbsOrigin()):Normalized())
					local lock = caster:AddNewModifier(caster, ability, "modifier_casting_locked", {duration = -1})
					spell:EndCooldown()
					caster:CastAbilityOnPosition(point, spell, caster:GetPlayerOwnerID())
					Timers:CreateTimer(
						spell:GetCastPoint() + 0.1,
						function()
							if spell and not spell:IsCooldownReady() then
								lock:Destroy()
								if count_temp == total - 1 then
									caster:AddNewModifier(caster, ability, "modifier_weak", {duration = 0.5})
								end
							elseif caster:GetCurrentActiveAbility() == nil and not caster:IsSilenced() then
								caster:FaceTowards(point)
								caster:Stop()
								caster:CastAbilityOnPosition(point, spell, caster:GetPlayerOwnerID())
								return spell:GetCastPoint() + 0.12
							else
								return spell:GetCastPoint() + 0.1
							end
						end
					)
					if count_temp == total - 1 then
						ticket_concession:ReleaseTicket()
					end
				end
			)
			count = count + 1
			if count < total then
				return delay + spell:GetCastPoint() + 0.1
			end
		end
	)
end


function generic_aoe_notarget(keys)
	local caster = keys.caster
	local ability = keys.ability
	local delay = keys.delay
	local spell = caster:FindAbilityByName(spells_aoe[keys.ability_index])
	local signifier = ParticleManager:CreateParticle("particles/custom/boss_block.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	local ticket_concession = caster:FindModifierByName("modifier_boss")
	local ticket = ticket_concession:RequestTicket()
	ParticleManager:ReleaseParticleIndex(signifier)
	Timers:CreateTimer(
		function()
			if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil or caster:IsCommandRestricted() or not ticket_concession:QueryTicket(ticket) then
				return 0.05
			end
			local fx = aoe_particle(caster, keys.delay, caster:GetAbsOrigin(), keys.radius, 2)	
			caster:Stop()
			EmitSoundOn("Hero_Mars.Spear.Cast", caster)
			StartAnimation(caster, {duration = keys.delay - spell:GetCastPoint(), activity = ACT_DOTA_CAST_ABILITY_1, rate = 1 / keys.delay - spell:GetCastPoint()})
			caster:AddNewModifier(caster, ability, "modifier_anim", {duration = keys.delay - spell:GetCastPoint()})
			Timers:CreateTimer(
				delay - spell:GetCastPoint(), 
				function()
					if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil or caster:HasModifier("modifier_anim") then
						return 0.01
					end
					caster:AddNewModifier(caster, ability, "modifier_casting_locked", {duration = 0.5})
					spell:EndCooldown()
					local lock = caster:AddNewModifier(caster, ability, "modifier_casting_locked", {duration = -1})
					caster:CastAbilityNoTarget(spell, -1)
					Timers:CreateTimer(
						spell:GetCastPoint() + 0.1,
						function()
							if spell and not spell:IsCooldownReady() then
								lock:Destroy()
							elseif caster:GetCurrentActiveAbility() == nil then
								caster:CastAbilityNoTarget(spell, -1)
								return spell:GetCastPoint() + 0.1
							else
								return spell:GetCastPoint() + 0.1
							end
						end
					)
					
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
	local signifier = ParticleManager:CreateParticle("particles/custom/boss_block.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	local ticket_concession = caster:FindModifierByName("modifier_boss")
	local ticket = ticket_concession:RequestTicket()
	local total = 1
	local count = 0
		if keys.iterations then
		total = keys.iterations
	end
	ParticleManager:ReleaseParticleIndex(signifier)
	local difficulty = _G.AOHGameMode._difficulty
	if difficulty == 2 then
		delay = delay * 0.8
	end
	Timers:CreateTimer(
		function()
			if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil or caster:IsCommandRestricted() or caster:HasModifier("modifier_casting_locked") or not ticket_concession:QueryTicket(ticket) then
				return 0.1
			end
			local count_temp = count
			local maximum_distance = keys.maximum_distance or 475
			local point = target:GetAbsOrigin()
			local distance_fx = ParticleManager:CreateParticle("particles/custom/aoe_warning_target.vpcf", PATTACH_WORLDORIGIN, target)
			ParticleManager:SetParticleControl(distance_fx, 0, point)
			ParticleManager:SetParticleControl(distance_fx, 1, Vector(maximum_distance, delay, 1))
			ParticleManager:ReleaseParticleIndex(distance_fx)
			if keys.is_line and keys.is_line == 1 then
				local start_radius = keys.initial_radius or keys.radius
				local fx = ParticleManager:CreateParticle("particles/custom/line_aoe_warning.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
				ParticleManager:SetParticleControl(fx, 0, caster:GetAbsOrigin())
				ParticleManager:SetParticleControl(fx, 1, caster:GetAbsOrigin())
				ParticleManager:SetParticleControlEnt(fx, 2, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(fx, 3, Vector(keys.radius, start_radius, 1))
				ParticleManager:SetParticleControl(fx, 4, Vector(keys.delay * 1.05, 1, 1))
				ParticleManager:ReleaseParticleIndex(fx)
			end
			caster:Stop()
			caster:FaceTowards(keys.target:GetAbsOrigin())
			EmitSoundOn("Hero_Mars.Spear.Cast", caster)
			target:AddNewModifier(caster, ability, "modifier_target_delay", {duration = delay})
			StartAnimation(caster, {duration = delay, activity = ACT_DOTA_CAST_ABILITY_1, rate = 1 / delay})
			caster:AddNewModifier(caster, ability, "modifier_anim", {duration = delay})
			Timers:CreateTimer(
				delay - spell:GetCastPoint(), 
				function()
					if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil or caster:HasModifier("modifier_anim") then
						return 0.01
					end
					if not target then 
						ticket_concession:ReleaseTicket()
						return nil 
					end
					local temp_target = target
					local lock = caster:AddNewModifier(caster, ability, "modifier_casting_locked", {duration = -1})
					local distance = (point - target:GetAbsOrigin()):Length2D()
					local modifier
					if distance > maximum_distance then
						local norm = (point - temp_target:GetAbsOrigin()):Normalized()
						temp_target = CreateUnitByName("npc_target", target:GetAbsOrigin() + norm * maximum_distance, false, target, target, target:GetTeamNumber())
						AddFOWViewer(caster:GetTeamNumber(), target:GetAbsOrigin() + norm * maximum_distance, 100, 2, false)
						modifier = temp_target:AddNewModifier(caster, keys.ability, "modifier_dummy", {duration = -1})
					end
					caster:CastAbilityOnTarget(temp_target, spell, -1)
					Timers:CreateTimer(
						function()
							if spell and not spell:IsCooldownReady() then
								lock:Destroy()
								if modifier then
									modifier:SetDuration(1, true)
								end
								if count_temp == total - 1 then
									caster:AddNewModifier(caster, ability, "modifier_weak", {duration = 0.5})
								end
							elseif caster:GetCurrentActiveAbility() == nil and not caster:IsSilenced() then
								caster:FaceTowards(point)
								caster:Stop()
								caster:CastAbilityOnTarget(temp_target, spell, -1)
								return spell:GetCastPoint() + 0.12
							else
								return spell:GetCastPoint() + 0.1
							end
						end
					)
					if count_temp == total - 1 then
						ticket_concession:ReleaseTicket()
					end
				end
			)
			count = count + 1
			if count < total then
				return delay + spell:GetCastPoint() + 0.1 
			end
		end
	)
end

function generic_target_aoe(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target:GetAbsOrigin()
	local delay = keys.delay
	local spell = caster:FindAbilityByName(spells_aoe[keys.ability_index])
	local signifier = ParticleManager:CreateParticle("particles/custom/boss_block.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	local ticket_concession = caster:FindModifierByName("modifier_boss")
	local ticket = ticket_concession:RequestTicket()
	ParticleManager:ReleaseParticleIndex(signifier)
	Timers:CreateTimer(
		function()
			if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil or caster:IsCommandRestricted() or not ticket_concession:QueryTicket(ticket) then
				return 0.1
			end
			
			if keys.is_line and keys.is_line == 1 then
				local start_radius = keys.initial_radius or keys.radius
				local norm = 0
				if keys.line_length then
					norm = (point - caster:GetAbsOrigin()):Normalized()
					norm = caster:GetAbsOrigin() + norm * keys.line_length
				else
					norm = point
				end
				local fx = aoe_line_particle(caster, keys.delay, caster:GetAbsOrigin(), norm, start_radius, keys.radius, 2)
			else 
				local fx = aoe_particle(caster, keys.delay, point, keys.radius, 2)	
				local fx2 = line_to_point(caster, keys.delay, caster:GetAbsOrigin(), point, 2)
			end
			local forward_vector = (point - caster:GetAbsOrigin()):Normalized()
			caster:Stop()
			caster:SetForwardVector(forward_vector)
			caster:EmitSound("Hero_Mars.Spear.Cast")
			caster:AddNewModifier(caster, ability, "modifier_anim", {duration = delay - spell:GetCastPoint() - 0.04})
			StartAnimation(caster, {duration = keys.delay - spell:GetCastPoint(), activity = ACT_DOTA_CAST_ABILITY_1, rate = 1 / keys.delay - spell:GetCastPoint()})
			Timers:CreateTimer(
				delay - spell:GetCastPoint(), 
				function()
					if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil or caster:HasModifier("modifier_anim") then
						return 0.05
					end
					caster:SetForwardVector(forward_vector)
					caster:SetCursorPosition(point)
					spell:OnSpellStart()
					caster:SetForwardVector(forward_vector)
					ticket_concession:ReleaseTicket()
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
	local signifier = ParticleManager:CreateParticle("particles/custom/boss_block.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(signifier)
	Timers:CreateTimer(
		function()
			if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil or caster:IsCommandRestricted() then
				return 0.5
			end
			target:AddNewModifier(caster, ability, "modifier_target_delay", {duration = delay})
			if caster:IsMoving() then
				caster:Stop()
				caster:FaceTowards(point)
			end
			StartAnimation(caster, {duration = keys.delay - spell:GetCastPoint(), activity = ACT_DOTA_CAST_ABILITY_1, rate = 1 / keys.delay - spell:GetCastPoint()})
			caster:AddNewModifier(caster, ability, "modifier_anim", {duration = keys.delay - spell:GetCastPoint()})
			caster:EmitSoundParams("Hero_VoidSpirit.Pulse.Cast", 0, 0.5, 0)
			Timers:CreateTimer(
				delay - spell:GetCastPoint(), 
				function()
					if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil or caster:HasModifier("modifier_anim") then
						return 0.05
					end
					spell:EndCooldown()
					caster:CastAbilityOnTarget(target, spell, -1)
				end
			)
		end
	)
end

LinkLuaModifier("modifier_dummy", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
modifier_dummy = class({})

function modifier_dummy:IsPurgable()
	return false
end

function modifier_dummy:RemoveOnDeath()
	return false
end

function modifier_dummy:IsHidden()
	return true
end

function modifier_dummy:CheckState()
	local state = {
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
	}
	return state
end
if IsServer() then
	function modifier_dummy:OnDestroy()
		print("why aren't you dead")
		self:GetParent():ForceKill(false)
	end
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
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_SILENCED] = true,
	}
	return state
end
function modifier_anim:GetStatusEffectName()
    return "particles/custom/warning_colorwarp.vpcf"
end

function modifier_anim:DeclareFunctions() 
  local funcs = {
    
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
  }
  return funcs
end
function modifier_anim:StatusEffectPriority()
    return 90
end
function modifier_anim:GetModifierStatusResistanceStacking()
	return 100
end


LinkLuaModifier("modifier_cooldown_lock", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
modifier_cooldown_lock = class({})

function modifier_cooldown_lock:IsPurgable()
	return false
end

function modifier_cooldown_lock:IsHidden()
	return true
end
if IsServer() then
	function modifier_cooldown_lock:OnCreated(keys)
		self.cooldowns = {[0] = 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
		for slot = 0, 16 do
			local ability = self.parent:GetAbilityByIndex(slot)
			if ability ~= nil then
				self.cooldowns[slot] = ability:GetCooldownTimeRemaining()
				ability:EndCooldown()
				ability:StartCooldown(9999)
			end
		end
	end
	function modifier_cooldown_lock:OnDestroy()
		for slot = 0, 16 do
			local ability = self.parent:GetAbilityByIndex(slot)
			if ability ~= nil and self.cooldowns[slot] < 500 then
				ability:EndCooldown()
				ability:StartCooldown(self.cooldowns[slot])
			end
		end
	end
end

LinkLuaModifier("modifier_vulnerable", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
modifier_vulnerable = class({})

function modifier_vulnerable:IsPurgable()
	return false
end

function modifier_vulnerable:IsHidden()
	return true
end
function modifier_vulnerable:DeclareFunctions() 
  local funcs = {
    MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
  }
  return funcs
end

function modifier_vulnerable:GetActivityTranslationModifiers()
  return "injured"
end

function modifier_vulnerable:GetStatusEffectName()
    return "particles/custom/vulnerable_colorwarp.vpcf"
end


function modifier_vulnerable:StatusEffectPriority()
    return 100
end


LinkLuaModifier("modifier_weak", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
modifier_weak = class({})

function modifier_weak:IsPurgable()
	return false
end

function modifier_weak:IsHidden()
	return true
end

function modifier_weak:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		
	}
	return state
end


function modifier_weak:DeclareFunctions() 
  local funcs = {
    MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,

		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,	
  }
  return funcs
end
function modifier_weak:GetModifierStatusResistanceStacking()
	return -25
end

function modifier_weak:GetActivityTranslationModifiers()
  return "injured"
end


function modifier_weak:GetStatusEffectName()
    return "particles/custom/vulnerable_colorwarp.vpcf"
end

function modifier_weak:StatusEffectPriority()
    return 100
end


LinkLuaModifier("modifier_casting_locked", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
modifier_casting_locked = class({})

function modifier_casting_locked:IsPurgable()
	return false
end

function modifier_casting_locked:IsHidden()
	return true
end

function modifier_casting_locked:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = false,
	}
	return state
end

function modifier_casting_locked:DeclareFunctions() 
  local funcs = {
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
  }
  return funcs
end

function modifier_casting_locked:GetModifierStatusResistanceStacking()
	return 100
end

LinkLuaModifier("modifier_hidden", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
modifier_hidden = class({})

function modifier_hidden:IsPurgable()
	return false
end

function modifier_hidden:IsHidden()
	return true
end

function modifier_hidden:CheckState()
	local state = {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}
	return state
end

function modifier_hidden:OnDestroy()
	self:GetParent():ForceKill(false)
end