
LinkLuaModifier("modifier_anim", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)

boss_storm_spirit_teleport = class({})

function boss_storm_spirit_teleport:OnSpellStart()	
	local caster = self:GetCaster()
	local delay = self:GetSpecialValueFor("delay")
	local radius = self:GetSpecialValueFor("radius")
	local path_radius = self:GetSpecialValueFor("path_radius")
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_FARTHEST,
		false
	)
	if #enemies > 0 then
		local target = nil
		for _, enemy in ipairs(enemies) do
			target = enemy:GetAbsOrigin()
			break
		end
		caster:AddNewModifier(caster, self, "modifier_anim", {duration = delay})
		local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(fx, 0, target)
		ParticleManager:SetParticleControl(fx, 1, Vector(radius, 1, 1))
		ParticleManager:SetParticleControl(fx, 2, Vector(delay, 1, 1))
		ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
		ParticleManager:ReleaseParticleIndex(fx)
		local fx = ParticleManager:CreateParticle("particles/custom/line_aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(fx, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(fx, 1, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(fx, 2, target)
		ParticleManager:SetParticleControl(fx, 3, Vector(path_radius, path_radius, 1))
		ParticleManager:SetParticleControl(fx, 4, Vector(delay, 1, 1))
		ParticleManager:ReleaseParticleIndex(fx)
		local fx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_ball_lightning.vpcf", PATTACH_POINT, caster)
		ParticleManager:SetParticleControlEnt(fx2, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(fx2, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)

		
		StartAnimation(caster, {duration = delay, activity = ACT_DOTA_CAST_ABILITY_4, rate = 0.5 / delay})
		local damageTable = {
		-- victim = target,
			attacker = caster,
			damage =  self:GetSpecialValueFor("damage"),
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self, --Optional.
		}
		caster:EmitSound("Hero_StormSpirit.BallLightning.Loop")
		Timers:CreateTimer(
			delay, 
			function()
				StartAnimation(caster, {duration = delay, activity = ACT_DOTA_CAST_ABILITY_4, rate = 0.5})
				local fx = ParticleManager:CreateParticle("particles/econ/items/storm_spirit/strom_spirit_ti8/storm_spirit_ti8_overload_active_e.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(fx, 0, target)
				ParticleManager:ReleaseParticleIndex(fx)
				caster:StopSound("Hero_StormSpirit.BallLightning.Loop")
				caster:EmitSoundParams("Hero_StormSpirit.BallLightning", 0, 1.2, 0)
				caster:EmitSoundParams("Hero_StormSpirit.Overload", 0, 1.2, 0)
				FindClearSpaceForUnit(caster, target, false)
				local enemies = FindUnitsInRadius(
					caster:GetTeamNumber(),	-- int, your team number
					target,	-- point, center point
					nil,	-- handle, cacheUnit. (not known)
					radius,	-- float, 	radius. or use FIND_UNITS_EVERYWHERE
					DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
					0,	-- int, flag filter
					0,	-- int, order filter
					false	-- bool, can grow cache
				)
				local enemies_line = FindUnitsInLine(
					caster:GetTeamNumber(),	-- int, your team number
					caster:GetAbsOrigin(),
					target,
					nil,	-- handle, cacheUnit. (not known)
					path_radius,	-- float, 	radius. or use FIND_UNITS_EVERYWHERE
					DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
					0	-- int, flag filter
				)
				for _,enemy in pairs(enemies) do
					damageTable.victim = enemy
					ApplyDamage(damageTable)
				end
				for _,enemy in pairs(enemies_line) do
					damageTable.victim = enemy
					ApplyDamage(damageTable)
				end
				
				Timers:CreateTimer(
					0.25, 
					function()
						ParticleManager:DestroyParticle(fx2, false)
						ParticleManager:ReleaseParticleIndex(fx2)
					end
				)
			end
		)
	end
end
