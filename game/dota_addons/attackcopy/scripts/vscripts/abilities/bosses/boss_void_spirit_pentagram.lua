require("lib/timers")
LinkLuaModifier("modifier_anim", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)

boss_void_spirit_pentagram = class({})

function boss_void_spirit_pentagram:OnSpellStart()
	local caster = self:GetCaster()
	local counter = caster:FindAbilityByName("boss_void_spirit_astral_step")
	local points = self:GetSpecialValueFor("points")
	local total = self:GetSpecialValueFor("total")
	local rings = self:GetSpecialValueFor("rings")
	local delay_per_ring = self:GetSpecialValueFor("delay_per_ring")
	local radius_per_ring = self:GetSpecialValueFor("radius_per_ring")
	local radius = self:GetSpecialValueFor("radius")
	local interval = self:GetSpecialValueFor("interval")
	local origin = caster:GetAbsOrigin()
	local angle = 0
	local i = 0
	local count = 0
	local ring_count = 1
	local anim_duration = (interval * total) * (rings + 1) + interval + (delay_per_ring * rings)
	local delay = self:GetSpecialValueFor("delay")
	caster:AddNewModifier(caster, ability, "modifier_anim", {duration = anim_duration})
	if caster:IsMoving() then
		caster:Stop()
	end
	find_item(caster, "item_black_king_bar_boss"):CastAbility()
	local particle = ParticleManager:CreateParticle("particles/econ/items/lich/frozen_chains_ti6/lich_frozenchains_frostnova_g2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) 
	EmitSoundOn("Hero_Antimage.ManaVoidCast", caster)
	local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(fx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(fx, 1, Vector(radius, 1, 1))
	ParticleManager:SetParticleControl(fx, 2, Vector(delay, 1, 1))
	ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
	ParticleManager:ReleaseParticleIndex(fx)
	StartAnimation(caster, {duration = delay, activity = ACT_DOTA_CAST_ABILITY_1, rate = 1 / delay})
	caster:AddNewModifier(caster, ability, "modifier_anim", {duration = delay})
	Timers:CreateTimer(
		delay,
		function()
			b = i / points
			angle = 360 * b * math.floor(points / 2 + 1)
			x = radius * math.sin(math.rad(angle)) + origin.x
			y = radius * math.cos(math.rad(angle)) + origin.y
			point = Vector(x, y, 0)
			caster:SetCursorPosition(point)
			counter:OnSpellStart()
			i = i + 1
			count = count + 1
			if count < total then
				return interval
			elseif ring_count < rings then
				ring_count = ring_count + 1
				count = 0
				radius = radius - radius_per_ring
				return delay_per_ring
			else
				Timers:CreateTimer(
					interval,
					function()
						caster:SetCursorPosition(origin + Vector(0, 1000, 0))
						counter:OnSpellStart()
						Timers:CreateTimer(
							interval,
							function()
								caster:SetCursorPosition(origin)
								counter:OnSpellStart()
							end
						)
					end
				)
			end
		end
	)
end

