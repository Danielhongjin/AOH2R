require("lib/my")



function item_consumable_used(keys)
    EmitSoundOn("Item.MoonShard.Consume", keys.caster)
    increase_modifier(keys.caster, keys.caster, keys.ability, keys.modifier)
    keys.ability:SpendCharge()
end
