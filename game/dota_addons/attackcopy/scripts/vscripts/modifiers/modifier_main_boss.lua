LinkLuaModifier("modifier_revenge", "modifiers/modifier_main_boss.lua", LUA_MODIFIER_MOTION_NONE)
modifier_main_boss = class({})

function modifier_main_boss:IsBuff()
    return false
end

function modifier_main_boss:GetTexture()
    return "main_boss"
end

function modifier_main_boss:IsHidden()
    return false
end

function modifier_main_boss:IsPurgable()
    return false
end

if IsServer() then
    function modifier_main_boss:OnCreated(keys)
        self.parent = self:GetParent()
        self.interval = 0.1
        self.base_revenge = 8.08 - (keys.round * 0.08)
        self.current_revenge = self.base_revenge
        self:SetStackCount(100)
        self.revenge = self.base_revenge
        self:StartIntervalThink(self.interval)
        if _G.AOHGameMode._nRoundNumber ~= 35 then
            self.index = tonumber(self.parent:GetEntityIndex())
            self.states = {
                [0] = 100,
                100,
                100,
                100,
                100,
                100,
                100
            }
            self.state = 0
            Timers:CreateTimer(function()
                if self.parent:IsAlive() then
                    self.states[self.state] = self.parent:GetHealth() / self.parent:GetMaxHealth() * 100
                    self.state = self.state + 1
                    if self.state > 6 then
                        self.state = 0
                    end
                    return 0.2
                end
            end)
            Timers:CreateTimer(2, function()
                if self.parent:IsAlive() then
                    local value
                    if self.state ~= 0 then
                        value = self.states[self.state] - self.states[self.state - 1]
                    else
                        value = self.states[self.state] - self.states[6]
                    end
                    if value < 0.35 then
                        CustomGameEventManager:Send_ServerToAllClients("statebar_update", {
                            index = self.index
                        })
                        return 2
                    end

                    return 0.2
                end
            end)
            CustomGameEventManager:Send_ServerToAllClients("healthbar_init", {
                name = self.parent:GetUnitName(),
                index = self.index
            })
        end
    end

    function modifier_main_boss:OnIntervalThink()
        if _G.AOHGameMode._nRoundNumber ~= 35 then
            CustomGameEventManager:Send_ServerToAllClients("healthbar_update", {
                health = self.parent:GetHealth() / self.parent:GetMaxHealth() * 100,
                mana = self.parent:GetMana() / self.parent:GetMaxMana() * 100,
                index = self.index
            })
        end

        if self.parent:IsStunned() then
            self.revenge = self.revenge - self.interval
            if self.revenge < 0 and not self.parent:HasModifier("modifier_anim") then
                self.parent:Purge(false, false, false, true, false)
                self.parent:AddNewModifier(self.parent, nil, "modifier_revenge", {
                    duration = 4.0
                })
                local percent = self.parent:GetHealthPercent() * 0.01
                if percent < 0.50 then
                    percent = 0.5
                end

                self.current_revenge = self.base_revenge * percent
                self.revenge = self.current_revenge
            end
        else
            if self.revenge < self.current_revenge then
                self.revenge = self.revenge + 0.01
            end
        end
        self:SetStackCount((self.revenge / self.current_revenge) * 100)
    end
    function modifier_main_boss:OnDestroy()
        if self.state then
            CustomGameEventManager:Send_ServerToAllClients("healthbar_delete", {
                index = self.index
            })
        end
    end

end
function modifier_main_boss:GetModifierStatusResistance()
    return self:GetStackCount()
end

modifier_revenge = class({})

function modifier_revenge:IsPurgable()
    return false
end

function modifier_revenge:IsHidden()
    return true
end
function modifier_revenge:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
                   MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_STATUS_RESISTANCE,
                   MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_MODEL_SCALE}
    return funcs
end

function modifier_revenge:GetModifierAttackSpeedBonus_Constant()
    return 80
end

function modifier_revenge:GetModifierMoveSpeedBonus_Constant()
    return 80
end

function modifier_revenge:GetModifierIncomingDamage_Percentage()
    return -80
end

function modifier_revenge:GetModifierStatusResistance()
    return 80
end

function modifier_revenge:GetModifierModelScale()
    return 15
end

function modifier_revenge:GetStatusEffectName()
    return "particles/custom/revenge_colorwarp.vpcf"
end

if IsServer() then
    function modifier_revenge:OnTakeDamage(keys)
        local attacker = keys.attacker
        local unit = keys.unit
        if self.parent == unit then
            local signifier = ParticleManager:CreateParticle("particles/custom/boss_block.vpcf",
                PATTACH_ABSORIGIN_FOLLOW, self.parent)
            ParticleManager:ReleaseParticleIndex(signifier)
            EmitSoundOn("Hero_Mars.Shield.Block", self.parent)
        end
    end

    function modifier_revenge:OnCreated()
        self.parent = self:GetParent()
        EmitSoundOn("Hero_Zuus.GodsWrath.PreCast.Arcana", self.parent)
        for slot = 0, 16 do
            local ability = self.parent:GetAbilityByIndex(slot)
            if ability ~= nil then
                local cooldown = ability:GetCooldownTimeRemaining() - 2
                ability:EndCooldown()
                ability:StartCooldown(cooldown)
            end
        end
    end
end
function modifier_revenge:StatusEffectPriority()
    return 100
end
