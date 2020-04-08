require("lib/my")
require("lib/timers")



local SOUL_STACK_MODIFIER = "modifier_nevermore_custom_necromastery"


nevermore_custom_requiem = class({})


if IsServer() then
	function nevermore_custom_requiem:RequiemLineEffect(position, velocity, duration)
		local caster = self:GetCaster()
		local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_line.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(effect, 0, position)
		ParticleManager:SetParticleControl(effect, 1, velocity)
		ParticleManager:SetParticleControl(effect, 2, Vector(0, duration, 0))
		ParticleManager:ReleaseParticleIndex(effect)
	end


	function nevermore_custom_requiem:LaunchRequiemLine(start_pos, travel_distance, start_radius, end_radius, velocity, travel_time, isScepter)
		ProjectileManager:CreateLinearProjectile({
			Ability = self,
			EffectName = nil,
			vSpawnOrigin = start_pos,
			fDistance = travel_distance,
			fStartRadius = start_radius,
			fEndRadius = end_radius,
			Source = self:GetCaster(),
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			bDeleteOnHit = false,
			vVelocity = velocity,
			bProvidesVision = false,
			ExtraData = {is_scepter = isScepter}
		})
	
		self:RequiemLineEffect(start_pos, velocity, travel_time)
	end


	function nevermore_custom_requiem:CreateRequiemLine(caster_pos, end_pos)
		local caster = self:GetCaster()
		local velocity = (end_pos - caster_pos):Normalized() * self.lines_travel_speed
		self:LaunchRequiemLine(caster_pos, self.travel_distance, self.lines_starting_width, self.lines_end_width, velocity, self.travel_time, false)
		if caster:IsAlive() and caster:HasScepter() then
			Timers:CreateTimer(
				self.travel_time,
				function()
					local back_velocity = (caster_pos - end_pos):Normalized() * self.lines_travel_speed
					self:LaunchRequiemLine(end_pos, self.travel_distance, self.lines_end_width, self.lines_starting_width, back_velocity, self.travel_time, true)
				end
			)
		end
	end


	function nevermore_custom_requiem:OnSpellStart()
		local souls_per_line = self:GetSpecialValueFor("requiem_soul_conversion")
		local caster = self:GetCaster()
		self.damage = self:GetSpecialValueFor("damage")
		self.scepter = self.damage * self:GetSpecialValueFor("damage_pct_scepter") * 0.01
		caster:EmitSound("Hero_Nevermore.RequiemOfSouls")
		self.lines_end_width = self:GetSpecialValueFor("lines_end_width")
		self.lines_starting_width = self:GetSpecialValueFor("lines_starting_width")
		self.lines_travel_speed = self:GetSpecialValueFor("lines_travel_speed")
		self.travel_distance = self:GetSpecialValueFor("travel_distance")
		self.travel_time = self.travel_distance / self.lines_travel_speed
		
		local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_requiemofsouls.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:ReleaseParticleIndex(effect)
		
		if caster:HasModifier(SOUL_STACK_MODIFIER) then
			local stacks = caster:GetModifierStackCount(SOUL_STACK_MODIFIER, caster)
			local line_count = math.floor(stacks / souls_per_line)
			local caster_pos = caster:GetAbsOrigin()
			local line_pos = caster_pos + caster:GetForwardVector() * self.travel_distance
			local rotation_rate = 360 / line_count  -- spaced around all circle.
			
			self:CreateRequiemLine(caster_pos, line_pos)
			for i = 1, line_count - 1 do
				line_pos = RotatePosition(caster_pos, QAngle(0, rotation_rate, 0), line_pos)
	
				self:CreateRequiemLine(caster_pos, line_pos)
			end
		end
	end


	function nevermore_custom_requiem:OnProjectileHit_ExtraData(target, location, extra)
		if target then
			local caster = self:GetCaster()
			local damage = 0
			if extra.is_scepter ~= 1 then
				damage = self.damage
			else
				damage = self.scepter
			end
			ApplyDamage({
				ability = self,
				attacker = caster,
				damage = damage,
				damage_type = self:GetAbilityDamageType(),
				victim = target
			})
		end
	end
end
