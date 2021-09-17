require("lib/popup")

LinkLuaModifier("modifier_global_damage_effects", "abilities/other/global_damage_effects.lua", LUA_MODIFIER_MOTION_NONE)
global_damage_effects = class({})

function global_damage_effects:GetIntrinsicModifierName()
    return "modifier_global_damage_effects"
end


modifier_global_damage_effects = class({})

function modifier_global_damage_effects:IsHidden()
    return true
end

function modifier_global_damage_effects:IsPurgable()
	return false
end

function modifier_global_damage_effects:RemoveOnDeath()
	return false
end

function modifier_global_damage_effects:DeclareFunctions()
    return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end



if IsServer() then

	function modifier_global_damage_effects:OnCreated()
		self.is_talon = _G.AOHGameMode.talonCount
		self.is_arcane = _G.AOHGameMode.isArcane
		self.talon_count = _G.AOHGameMode.talonCount
		self.arcane_count = _G.AOHGameMode.arcaneCount
	end
	
	function modifier_global_damage_effects:OnTakeDamage(keys)
		if keys.damage_flags ~= 16 then
			local attacker = keys.attacker
			local id = attacker:GetPlayerOwnerID()
			local victim = keys.unit
			
			if id >= 0 and victim:GetTeamNumber() ~= attacker:GetTeamNumber() then
				if self.is_talon[id] then
					local phys = self.talon_count[id][0]
					local mag = self.talon_count[id][1]
					if not attacker:IsRealHero() then
						phys = phys / 2
						mag = mag / 2
					end
					if phys > 0 then
						ApplyDamage({
							ability = keys.inflictor,
							attacker = attacker,
							damage = phys,
							damage_type = DAMAGE_TYPE_PHYSICAL,
							damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
							victim = victim
						})
						local particle = ParticleManager:CreateParticle("particles/custom/demon_talon_custom.vpcf", PATTACH_ABSORIGIN_FOLLOW, victim)
						ParticleManager:ReleaseParticleIndex(particle)
					end
					if mag > 0 then
						ApplyDamage({
							ability = keys.inflictor,
							attacker = attacker,
							damage = mag,
							damage_type = DAMAGE_TYPE_MAGICAL,
							damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
							victim = victim
						})
						local particle = ParticleManager:CreateParticle("particles/custom/magi_demon_talon_custom.vpcf",PATTACH_ABSORIGIN_FOLLOW, victim)
						ParticleManager:ReleaseParticleIndex(particle)
					end
				end
				if keys.damage_type ~= 1 and attacker:IsRealHero() and self.is_arcane[id] then
					local time_diff = GameRules:GetGameTime() - self.arcane_count[id][2]
					if time_diff > 0.15 then
						time_diff = time_diff + 0.15
						if time_diff > 1 then
							time_diff = 1
						end
						local mana = attacker:GetMana()
						local int = attacker:GetIntellect()
						
						local final_damage = self.arcane_count[id][0] + (keys.original_damage * self.arcane_count[id][1] * 0.01) * time_diff
						local mana_cost = final_damage * 0.4 * (110 / (110 + int))	
						if mana < mana_cost then
							final_damage = mana / (0.4 * (110 / (110 + int)))
							mana_cost = mana
						end
						self.arcane_count[id][2] = GameRules:GetGameTime()
						attacker:ReduceMana(mana_cost)
						Timers:CreateTimer(
							0.4,
							function()
								local particle = ParticleManager:CreateParticle("particles/custom/arcane_staff.vpcf", PATTACH_POINT, attacker)
								ParticleManager:SetParticleControlEnt(particle, 1, victim, PATTACH_POINT, "attach_hitloc", victim:GetAbsOrigin(), true)
								ParticleManager:SetParticleControl(particle, 2, Vector(time_diff * 120, 0, 0))
								ParticleManager:ReleaseParticleIndex(particle)
								ApplyDamage({
									attacker = attacker,
									victim = victim,
									ability = keys.inflictor,
									damage_type = DAMAGE_TYPE_MAGICAL,
									damage = final_damage,
									damage_flags = DOTA_DAMAGE_FLAG_REFLECTION
								})
								create_popup({
									target = victim,
									value = final_damage,
									color = Vector(100, 149, 237),
									type = "crit",
									pos = 4
								})
							end
						)
						
					end
				end
			end
		end
	end
end

