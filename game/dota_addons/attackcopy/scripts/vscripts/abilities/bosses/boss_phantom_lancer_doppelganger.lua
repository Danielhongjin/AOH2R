--[[Author: YOLOSPAGHETTI
	Date: February 16, 2016
	Draws all unit models, places them in random positions in the aoe, and creates the doppelganger illusions]]
function DoppelgangerEnd( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability	
	local radius = ability:GetSpecialValueFor( "target_radius")
	
	-- Draws the unit's model
	target:RemoveNoDraw()	
	-- Sets them in a random position in the target aoe
	target:SetAbsOrigin(target.doppleganger_position)
	FindClearSpaceForUnit(target, target.doppleganger_position, true)
	
	if target == caster then
		local player = caster:GetPlayerOwnerID()
		local duration = ability:GetSpecialValueFor( "illusion_duration")
		for j=0,1 do
			local outgoingDamage
			local incomingDamage

			-- Sets the outgoing and incoming damage values for the doppelgangers
			if j==0 then
				outgoingDamage = ability:GetSpecialValueFor( "first_illusion_outgoing_damage")
				incomingDamage = ability:GetSpecialValueFor( "first_illusion_incoming_damage")
			else
				outgoingDamage = ability:GetSpecialValueFor( "second_illusion_outgoing_damage")
				incomingDamage = ability:GetSpecialValueFor( "second_illusion_incoming_damage")
			end
			local rand_distance = math.random(0,radius)
			local origin = caster:GetAbsOrigin() + RandomVector(rand_distance)
			local illusion = CreateUnitByName("npc_boss_phantomlancer_illusion", origin, true, caster, nil, caster:GetTeamNumber())
			illusion:SetControllableByPlayer(player, true)
			
			illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	
			-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
		end
	end
end

--[[Author: YOLOSPAGHETTI
	Date: February 16, 2016
	Applies a basic dispel to the unit and removes the model]]
function DoppelgangerStart( keys )
	local target = keys.target

	-- Basic Dispel
	local RemovePositiveBuffs = false
	local RemoveDebuffs = true
	local BuffsCreatedThisFrameOnly = false
	local RemoveStuns = false
	local RemoveExceptions = false
	target:Purge(RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)
	
	-- Removes the unit's model
	
end

--[[Author: YOLOSPAGHETTI
	Date: February 16, 2016
	Applies the banish to the caster and all of his illusions in the area]]
function CheckUnits(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("delay")
	local radius = ability:GetSpecialValueFor("target_radius")
	
	-- Checks that the unit is either the caster or one of his illusions, and applies the banish
	if target:GetMainControllingPlayer() == caster:GetMainControllingPlayer() then
		-- Calculate the random positions for the illusions and caster
		local rand_distance = math.random(0,radius)	
		local rand_position = ability:GetCursorPosition() + RandomVector(rand_distance)
		target.doppleganger_position = rand_position
		target:AddNoDraw()
		-- Create the dopple disappear effect
		local dopple_particle = ParticleManager:CreateParticleForTeam("particles/custom/boss/boss_phantom_lancer_doppleganger_illlmove.vpcf",PATTACH_CUSTOMORIGIN, nil, 2)
		ParticleManager:SetParticleControl(dopple_particle,0,target:GetAbsOrigin())
		ParticleManager:SetParticleControl(dopple_particle,1,rand_position)
		ParticleManager:ReleaseParticleIndex(dopple_particle)

		ability:ApplyDataDrivenModifier(caster, target, "modifier_doppelganger_datadriven", {Duration = duration})
	end
end
