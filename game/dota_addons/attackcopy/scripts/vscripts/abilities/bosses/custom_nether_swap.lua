require("lib/ai")
require("lib/timers")
require("lib/my")


local function swap_effect(hero1, hero2)
	local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero1)
	ParticleManager:SetParticleControlEnt(fx, 1, hero2, PATTACH_ABSORIGIN_FOLLOW, nil, hero2:GetOrigin(), false)
    ParticleManager:ReleaseParticleIndex(fx)
    EmitSoundOn("Hero_VengefulSpirit.NetherSwap", hero1)
end


local function swap_heroes(hero1, hero2)
	local vPos1 = hero1:GetOrigin() + RandomVector(100)
	local vPos2 = hero2:GetOrigin() + RandomVector(100)

	GridNav:DestroyTreesAroundPoint(vPos1, 300, false)
	GridNav:DestroyTreesAroundPoint(vPos2, 300, false)

	hero1:SetOrigin(vPos2)
	hero2:SetOrigin(vPos1)

	FindClearSpaceForUnit(hero1, vPos2, true)
	FindClearSpaceForUnit(hero2, vPos1, true)
	
	hero2:Interrupt()

    swap_effect(hero1, hero2)
    swap_effect(hero2, hero1)
end


function cast_nether_swap(keys)
    local caster = keys.caster

    local to_swap = ai_alive_heroes()

    if #to_swap > 0 then
        table.insert(to_swap, caster)   -- The boss will also swap.

        local number_switch = (#to_swap * 2) - 1   -- The number should be odd.

        local i = 1

        Timers:CreateTimer(
            function()
                if i <= number_switch then
                    i = i + 1

                    local random1 = RandomInt(1, #to_swap)
                    local random2 = RandomInt(1, #to_swap)
                    
                    while random2 == random1 do     -- assert random1 and random2 are different.
                        random2 = RandomInt(1, #to_swap)
                    end
        
                    swap_heroes(to_swap[random1], to_swap[random2])

                    return 0.15
                end
                return nil
            end
        )
    end
end

