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
	caster:AddNewModifier(caster, ability, "modifier_anim", {duration = anim_duration})
	Timers:CreateTimer(
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

