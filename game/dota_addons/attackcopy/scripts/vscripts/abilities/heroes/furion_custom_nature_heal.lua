require("lib/my")
require("lib/timers")


furion_custom_nature_heal = class({})



if IsServer() then
    function furion_custom_nature_heal:CastFilterResultTarget(target)
        if self:GetCaster() == target then
            return UF_FAIL_CUSTOM
        end

        return UF_SUCCESS
    end


    function furion_custom_nature_heal:GetCustomCastErrorTarget(target)
        if self:GetCaster() == target then
            return "#dota_hud_error_cant_cast_on_self"
        end

        return ""
    end


    function furion_custom_nature_heal:OnSpellStart()
        self.target = self:GetCursorTarget()

        self.base_heal = self:GetSpecialValueFor("base_heal")
        self.health_transfer = self:GetSpecialValueFor("health_transfer") * 0.01
        self.base_mana = self:GetSpecialValueFor("base_mana")
        self.mana_transfer = self:GetSpecialValueFor("mana_transfer") * 0.01
        self.interval = self:GetSpecialValueFor("interval")

        self.ticks_per_second = 1 / self.interval
        self.tick_base_heal = self.base_heal / self.ticks_per_second
        self.tick_health_transfer = self.health_transfer / self.ticks_per_second
        self.tick_base_mana = self.base_mana / self.ticks_per_second
        self.tick_mana_transfer = self.mana_transfer / self.ticks_per_second

        self.accumulated_time = 0.0
        self:HealTarget()
    end


    function furion_custom_nature_heal:OnChannelThink(flInterval)
        self.accumulated_time = self.accumulated_time + flInterval 
        if self.accumulated_time >= self.interval then
            self.accumulated_time = self.accumulated_time - self.interval

            self:HealTarget()
        end
    end


    function furion_custom_nature_heal:HealTarget(direction)
        local caster = self:GetCaster()

        if not self.target:IsAlive() then
            caster:Interrupt()
            caster:InterruptChannel()
            return
        end

        ProjectileManager:CreateTrackingProjectile({
            Ability = self,
            Target = self.target,
            Source = caster,
            EffectName = "particles/units/heroes/hero_furion/furion_wrath_of_nature_trail.vpcf",
            iMoveSpeed = caster:GetRangeToUnit(self.target),
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
            bDodgeable = false,
            flExpireTime = GameRules:GetGameTime() + 3,
        })

        caster:FadeGesture(ACT_DOTA_CAST_ABILITY_4)
        caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)


        local health_loss = (caster:GetMaxHealth() * self.tick_health_transfer) + (caster:GetHealthRegen() / self.ticks_per_second)
        if caster:GetHealth() >= health_loss then
            caster:ModifyHealth(caster:GetHealth() - health_loss, self, false, 0)

            local heal = self.tick_base_heal + health_loss
            self.target:Heal(heal, caster)
        end


        local mana_loss = (caster:GetMaxMana() * self.tick_mana_transfer) + (caster:GetManaRegen() / self.ticks_per_second)
        if caster:GetMana() >= mana_loss then
            caster:SpendMana(mana_loss, self)

            local mana_gain = self.tick_base_mana + mana_loss
            self.target:GiveMana(mana_gain)
        end
    end
end
