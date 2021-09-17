LinkLuaModifier("modifier_boss_abyssal_underlord_cleave", "abilities/bosses/boss_abyssal_underlord_cleave", LUA_MODIFIER_MOTION_NONE)
boss_abyssal_underlord_cleave = class({})

function boss_abyssal_underlord_cleave:GetIntrinsicModifierName()
	return "modifier_boss_abyssal_underlord_cleave"
end

modifier_boss_abyssal_underlord_cleave = class({})

function modifier_boss_abyssal_underlord_cleave:IsHidden()
	return true
end

function modifier_boss_abyssal_underlord_cleave:OnCreated()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.radius = self.ability:GetSpecialValueFor("cleave_radius")
	self.arc_radius = self.ability:GetSpecialValueFor("arc_radius")
	self.angle = self.ability:GetSpecialValueFor("angle")
	self.damageTable = {
		-- victim = target,
		attacker = self.parent,
		damage =  self.ability:GetSpecialValueFor("damage"),
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability, --Optional.
	}
end


function modifier_boss_abyssal_underlord_cleave:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end
if IsServer() then
	function modifier_boss_abyssal_underlord_cleave:OnAttackLanded(params)
		if params.attacker == self:GetParent() then
			if self:GetParent():PassivesDisabled() then
				return 0
			end
			
			local target = params.target
			DoCleaveAttack( self.parent, target, self:GetAbility(), 0, 0, 0, 0, "particles/custom/abyssal_underlord_cleave.vpcf")
			if target ~= nil  then
				local origin = self.parent:GetAbsOrigin()
				local point = target:GetAbsOrigin()
				local enemies = FindUnitsInRadius(
					self.parent:GetTeamNumber(),	-- int, your team number
					origin,	-- point, center point
					nil,	-- handle, cacheUnit. (not known)
					self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
					DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
					DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
					0,	-- int, order filter
					false	-- bool, can grow cache
				)
				local cast_direction = (point-origin):Normalized()
				local cast_angle = VectorToAngles(cast_direction).y
				for _,enemy in pairs(enemies) do
					if enemy ~= target then
						local enemy_direction = (enemy:GetAbsOrigin() - origin):Normalized()
						local enemy_angle = VectorToAngles(enemy_direction).y
						local angle_diff = math.abs(AngleDiff(cast_angle, enemy_angle))
						if angle_diff <= self.angle then
							local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_rubick/rubick_fade_bolt.vpcf", PATTACH_POINT, target)
							ParticleManager:SetParticleControlEnt(fx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
							ParticleManager:SetParticleControlEnt(fx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
							Timers:CreateTimer(
								0.4, 
								function()
									self.damageTable.victim = enemy
									ApplyDamage(self.damageTable)
									local next_enemies = FindUnitsInRadius(
										self.parent:GetTeamNumber(),	-- int, your team number
										enemy:GetAbsOrigin(),	-- point, center point
										nil,	-- handle, cacheUnit. (not known)
										self.arc_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
										DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
										DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
										DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
										0,	-- int, order filter
										false	-- bool, can grow cache
									)
									if #next_enemies == 1 then
										self.parent:EmitSoundParams("Hero_Zuus.ArcLightning.Cast", 0, 0.25, 0)
										local pos = enemy:GetAbsOrigin() + Vector(RandomInt(-200, 200), RandomInt(-200, 200), 0)
										local fx = ParticleManager:CreateParticle("particles/custom/underlord_arc_lightning_.vpcf", PATTACH_POINT, enemy)
										ParticleManager:SetParticleControlEnt(fx, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
										ParticleManager:SetParticleControl(fx, 1, pos)
									else
										for _,next_enemy in pairs(next_enemies) do
											if next_enemy ~= target then
												local fx = ParticleManager:CreateParticle("particles/custom/underlord_arc_lightning_.vpcf", PATTACH_POINT, enemy)
												ParticleManager:SetParticleControlEnt(fx, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
												ParticleManager:SetParticleControlEnt(fx, 1, next_enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", next_enemy:GetAbsOrigin(), true)
												self.damageTable.victim = next_enemy
												ApplyDamage(self.damageTable)
												break
											end
										end
									end
								end
							)
							
						
						end
					end
				end
			end
		end
	end
end
