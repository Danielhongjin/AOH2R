require("lib/my")


boss_abyssal_underlord_firestorm = class({})


if IsServer() then
   
    function boss_abyssal_underlord_firestorm:OnSpellStart()	
		local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")
		local radius = self:GetSpecialValueFor("radius")
		local interval = self:GetSpecialValueFor("interval")
		local interval_reduction = self:GetSpecialValueFor("interval_reduction")
		local spread = self:GetSpecialValueFor("spread")
		local spread_reduction = self:GetSpecialValueFor("spread_reduction")
		local minimum_spread = self:GetSpecialValueFor("minimum_spread")
		local damageTable = {
		-- victim = target,
			attacker = caster,
			damage =  self:GetSpecialValueFor("damage"),
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self, --Optional.
		}
		local target = self:GetCursorTarget()
		local fx = ParticleManager:CreateParticle("particles/custom/bear_maul.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(fx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(fx, 2, Vector(duration, 1, 0))
		Timers:CreateTimer(
			0, 
			function()
				if self:IsChanneling() then
					target:EmitSoundParams("Hero_AbyssalUnderlord.Firestorm.Cast", 0, 0.4, 0)
					local pos = target:GetAbsOrigin() + Vector(RandomInt(-spread, spread), RandomInt(-spread, spread), 0)
					local fx = ParticleManager:CreateParticle("particles/custom/custom_firestorm_wave_chunks.vpcf", PATTACH_WORLDORIGIN, target)
					ParticleManager:SetParticleControl(fx, 0, pos)
					ParticleManager:SetParticleControl(fx, 4, Vector(10, 0, 0))
					ParticleManager:ReleaseParticleIndex(fx)

					local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, target)
					ParticleManager:SetParticleControl(fx, 0, pos)
					ParticleManager:SetParticleControl(fx, 1, Vector(radius, 1, 1))
					ParticleManager:SetParticleControl(fx, 2, Vector(0.4, 1, 1))
					ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
					ParticleManager:ReleaseParticleIndex(fx)
					Timers:CreateTimer(
						0.4,						
						function()
							target:EmitSoundParams("Hero_AbyssalUnderlord.Firestorm", 0, 0.8, 0)
							local enemies = FindUnitsInRadius(
								caster:GetTeamNumber(),	-- int, your team number
								pos,	-- point, center point
								nil,	-- handle, cacheUnit. (not known)
								radius,	-- float, 	radius. or use FIND_UNITS_EVERYWHERE
								DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
								DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
								0,	-- int, flag filter
								0,	-- int, order filter
								false	-- bool, can grow cache
							)
							for _,enemy in pairs(enemies) do
								damageTable.victim = enemy
								ApplyDamage(damageTable)
							end
						end
					)
					interval = interval - (interval_reduction * interval)
					spread = spread - (spread_reduction * interval)
					if spread < minimum_spread then
						spread = minimum_spread
					end
					return interval
				else
					ParticleManager:DestroyParticle(fx, true)
					ParticleManager:ReleaseParticleIndex(fx)
				end
			end
		)
		end

end
