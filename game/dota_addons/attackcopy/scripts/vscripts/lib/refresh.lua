require("lib/my")


-- Can also be used for items.
function end_ability_cooldown(ability, exclude_table)
    if ability then
        if not exclude_table[ability:GetAbilityName()] then
            if ability:GetCooldownTimeRemaining() > 0 then
                ability:EndCooldown()
            end
        end
    end
end


function refresh_abilities(caster, exclude_abilities)
    for i = 0, caster:GetAbilityCount() do
        local ability = caster:GetAbilityByIndex(i)
        end_ability_cooldown(ability, exclude_abilities)
    end
end



function refresh_items(caster, exclude_items)
    for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
        local item = caster:GetItemInSlot(i)
        end_ability_cooldown(item, exclude_items)
    end
end
function end_ability_cooldown_mult(ability, exclude_table, mult)
    if ability then

    end
end
function refresh_abilities_mult(caster, exclude_table, mult)
    for i = 0, caster:GetAbilityCount() do
        local ability = caster:GetAbilityByIndex(i)
		if ability then
			local cooldown = ability:GetCooldownTimeRemaining()
			if not exclude_table[ability:GetAbilityName()] then
				if cooldown > 0 then
					ability:EndCooldown()
				end
			else 
				if cooldown > 0 then
					ability:EndCooldown()
					ability:StartCooldown(cooldown * (mult))
				end
			end
		end
    end
end

function get_all_cooldowns(caster)
    local cooldowns = {}

    for i = 0, caster:GetAbilityCount() do
        local ability = caster:GetAbilityByIndex(i)
        if ability then
            table.insert(cooldowns, ability:GetCooldown(ability:GetLevel() - 1))
        end
    end

    return cooldowns
end

