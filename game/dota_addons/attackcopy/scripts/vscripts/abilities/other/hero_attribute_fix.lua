LinkLuaModifier("modifier_atr_fix", "abilities/other/hero_attribute_fix.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_builtin_blink", "abilities/other/hero_attribute_fix.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_builtin_blink_cooldown", "abilities/other/hero_attribute_fix.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_builtin_blink_movement", "abilities/other/hero_attribute_fix.lua",
    LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_builtin_blink_dashdamage", "abilities/other/hero_attribute_fix.lua",
    LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_builtin_blink_dashattack", "abilities/other/hero_attribute_fix.lua",
    LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_builtin_blink_immunity", "abilities/other/hero_attribute_fix.lua",
    LUA_MODIFIER_MOTION_HORIZONTAL)

hero_attribute_fix = class({})

function hero_attribute_fix:GetIntrinsicModifierName()
    return "modifier_atr_fix"
end
if IsServer() then
    function hero_attribute_fix:OnHeroLevelUp()
        local caster = self:GetCaster()
        if caster:HasModifier("modifier_atr_fix") then
            caster:FindModifierByName("modifier_atr_fix"):ForceRefresh()
        end
    end
end

modifier_atr_fix = class({})

function modifier_atr_fix:AllowIllusionDuplicate()
    return true
end

function modifier_atr_fix:IsHidden()
    return true
end
function modifier_atr_fix:RemoveOnDeath()
    return false
end

function modifier_atr_fix:IsPurgable()
    return false
end

function modifier_atr_fix:GetTexture()
    return "atr_fix"
end

function modifier_atr_fix:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
                   MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
                   MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
    return funcs
end

function modifier_atr_fix:GetModifierConstantHealthRegen()
    local parent_str = self.parent:GetStrength()
    local h_regen = parent_str * 0.15
    return h_regen
end

function modifier_atr_fix:OnCreated()
    self.parent = self:GetParent()
    self.level = self:GetParent()
    if IsServer() then
        self.parent:AddNewModifier(self.parent, self:GetAbility(), "modifier_builtin_blink", {
            duration = -1
        })
        if self.parent:IsIllusion() then
            self.level = PlayerResource:GetSelectedHeroEntity(self.parent:GetPlayerOwnerID())
        end
    end
    self:SetStackCount(self.level:GetLevel() * 25)
end

function modifier_atr_fix:OnRefresh()
    self:SetStackCount(self.level:GetLevel() * 25)
end

function modifier_atr_fix:GetModifierHealthBonus()
    return self:GetStackCount()
end

function modifier_atr_fix:GetModifierConstantManaRegen()
    local parent_int = self.parent:GetIntellect()
    local m_regen = parent_int * 0.05
    return m_regen
end

function modifier_atr_fix:GetModifierSpellAmplify_Percentage()
    local parent_int = self.parent:GetIntellect()
    local amp = parent_int * 0.21
    return amp
end

function modifier_atr_fix:GetModifierPercentageCooldown()
    local parent_agi = self.parent:GetAgility() - 15
    local amp = parent_agi * 0.075
    return math.min(amp, 70)
end

function modifier_atr_fix:GetModifierAttackRangeBonus()
    return 25
end

modifier_builtin_blink = class({})

function modifier_builtin_blink:IsPurgable()
    return false
end

function modifier_builtin_blink:IsHidden()
    return true
end

function modifier_builtin_blink:RemoveOnDeath()
    return false
end

function modifier_builtin_blink:OnCreated()
    self.parent = self:GetParent()
    self.playerID = 0
    if self.parent:IsHero() then
        self.playerID = self.parent:GetPlayerOwnerID()
    end
    self.skills = _G.AOHGameSkills.chosen_skills
    self.difficulty = _G.AOHGameMode._difficulty
    self.blink_count = 0
    self.blink_active = 0
end

if IsServer() then
    function modifier_builtin_blink:Dash(keys)
        if self.blink_active < GameRules:GetGameTime() and
            (self.parent:GetAggroTarget() == nil or self.parent:HasModifier("modifier_windrunner_focusfire")) then
            local cooldown = 3.5 * self.parent:GetCooldownReduction()
            if self.difficulty == 2 then
                cooldown = cooldown * 0.85
            end
            if self.skills[self.playerID][0][0] == 1 then
                cooldown = cooldown * 0.75
            end
            if self.skills[self.playerID][4][3] == 1 then
                cooldown = cooldown * 0.8
            end
            self.parent:AddNewModifier(self.parent, nil, "modifier_builtin_blink_cooldown", {
                duration = cooldown
            })
            Timers:CreateTimer(cooldown, function()
                self.blink_count = self.blink_count - 1
            end)

            self.blink_active = GameRules:GetGameTime() + 0.66

            local origin_point = self.parent:GetAbsOrigin()
            local difference_vector = (keys.pos - origin_point):Normalized()

            local duration = 0.2 / (1 + (self.blink_count * 0.6))

            local immunity = 0.4
            local ratio = 4.0
            local distance = (Vector(keys.pos.x, keys.pos.y, 0) - Vector(origin_point.x, origin_point.y, 0)):Length2D()
            local speed = self.parent:GetMoveSpeedModifier(self.parent:GetBaseMoveSpeed(), true) * (ratio / 33)
            if self.skills[self.playerID][3][2] == 1 and self.parent:IsRealHero() and distance > 400 then
                duration = -1
            else
                if (speed * (duration / 0.03)) > distance then
                    duration = duration * (distance / (speed * (duration / 0.03)))
                end
            end

            self.parent:SetForwardVector(Vector(difference_vector.x, difference_vector.y, 0))

            local is_dash_attack = false

            local fx = ParticleManager:CreateParticleForPlayer("particles/custom/blink_cooldown_screen.vpcf",
                PATTACH_RENDERORIGIN_FOLLOW, self.parent, self.parent:GetPlayerOwner())
            ParticleManager:SetParticleControl(fx, 6, Vector(cooldown, 0, 0))
            if self.blink_count == 0 then
                ProjectileManager:ProjectileDodge(self.parent)
                self.parent:EmitSound("DOTA_Item.BlinkDagger.Activate")
                if self.skills[self.playerID][2][2] == 1 then
                    is_dash_attack = true
                end
                if self.skills[self.playerID][0][2] == 1 then
                    immunity = immunity * 3
                    self.parent:Purge(false, true, false, true, true)
                end
                if self.skills[self.playerID][4][3] == 1 then
                    self.parent:AddNewModifier(self.parent, nil, "modifier_builtin_blink_dashattack", {})
                end

            else
                self.parent:EmitSoundParams("DOTA_Item.BlinkDagger.Activate", 0, 0.9 / (1 + (self.blink_count * 0.6)), 0)
            end
            local modifier = self.parent:AddNewModifier(self.parent, nil, "modifier_builtin_blink_movement", {
                duration = duration,
                speed = speed,
                is_dash_attack = is_dash_attack
            })
            self.parent:AddNewModifier(self.parent, nil, "modifier_builtin_blink_immunity", {
                duration = immunity
            })
            self.blink_count = self.blink_count + 1
        end
    end
end
modifier_builtin_blink_movement = class({})

function modifier_builtin_blink_movement:IsHidden()
    return true
end

function modifier_builtin_blink_movement:IsDebuff()
    return false
end

function modifier_builtin_blink_movement:IsStunDebuff()
    return true
end

function modifier_builtin_blink_movement:IsPurgable()
    return true
end

function modifier_builtin_blink_movement:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE, MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
                   MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE, MODIFIER_PROPERTY_OVERRIDE_ANIMATION_WEIGHT,
                   MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS, MODIFIER_EVENT_ON_ORDER,
                   MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
    return funcs
end

function modifier_builtin_blink_movement:CheckState()
    local state = {
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
    }
    return state
end

function modifier_builtin_blink_movement:GetOverrideAnimation()
    return ACT_DOTA_RUN
end

function modifier_builtin_blink_movement:GetOverrideAnimationRate()
    return 1
end

function modifier_builtin_blink_movement:GetOverrideAnimationWeight()
    return 1
end

function modifier_builtin_blink_movement:GetActivityTranslationModifiers()
    return "haste"
end

function modifier_builtin_blink_movement:GetModifierTurnRate_Percentage()
    return -95
end

function modifier_builtin_blink_movement:GetModifierIncomingDamage_Percentage()
    return -self:GetStackCount()
end

function modifier_builtin_blink_movement:OnOrder(keys)
    if self.parent == keys.unit and self.skills[self.playerID][3][2] == 1 and self.ready then
        if keys.order_type == 1 then
            local range = Vector(keys.new_pos.x, keys.new_pos.y, 0) -
                              Vector(self.parent:GetAbsOrigin().x, self.parent:GetAbsOrigin().y, 0)
            local distance = math.sqrt(math.pow(range.x, 2) + math.pow(range.y, 2))
            if distance > 400 then
                local attackOrder = {
                    UnitIndex = self.parent:entindex(),
                    OrderType = DOTA_UNIT_ORDER_STOP
                }
                ExecuteOrderFromTable(attackOrder)
                Timers:CreateTimer(0.03, function()
                    self.parent:FaceTowards(keys.new_pos)
                end)
            else
                self:Destroy()
            end
        elseif keys.order_type == 10 then
            self:Destroy()
        end
    end
end
function modifier_builtin_blink_movement:OnRemoved()
    if not IsServer() then
        return
    end
    self:GetParent():InterruptMotionControllers(false)
end
if IsServer() then
    function modifier_builtin_blink_movement:OnCreated(keys)
        self.ability = self:GetAbility()
        self.parent = self:GetParent()
        self.skills = _G.AOHGameSkills.chosen_skills
        local original_speed = keys.speed
        local speed_ratio = 1
        self.speed = keys.speed
        self.ready = false
        Timers:CreateTimer(0.2, function()
            self.ready = true
        end)
        Timers:CreateTimer(0.5, function()
            if speed_ratio > 0.5 then
                speed_ratio = speed_ratio - 0.02
                self.speed = original_speed * speed_ratio
                return 0.2
            end
        end)
        local sound_level = self.parent:EmitSound("AOH.DashLoop")
        self.isHero = false
        self.playerID = self.parent:GetPlayerOwnerID()
        if self:GetRemainingTime() == -1 and self.parent:IsRealHero() then
            self.isHero = true
            PlayerResource:SetCameraTarget(self.playerID, self.parent)
        end

        if keys.is_dash_attack == 1 then
            self.fx = ParticleManager:CreateParticle("particles/custom/dash_damage.vpcf", PATTACH_ABSORIGIN_FOLLOW,
                self.parent)
            ParticleManager:SetParticleControlEnt(self.fx, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, "follow_origin",
                self.parent:GetAbsOrigin(), true)
            self:StartIntervalThink(0.1)
            local enemies = FindUnitsInRadius(self.parent:GetTeamNumber(), -- int, your team number
            self.parent:GetAbsOrigin(), -- point, center point
            nil, -- handle, cacheUnit. (not known)
            150, -- float, radius. or use FIND_UNITS_EVERYWHERE
            DOTA_UNIT_TARGET_TEAM_ENEMY, -- int, team filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, -- int, type filter
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, -- int, flag filter
            0, -- int, order filter
            false -- bool, can grow cache
            )
            for _, enemy in pairs(enemies) do
                enemy:AddNewModifier(self.parent, self:GetAbility(), "modifier_builtin_blink_dashdamage", {
                    duration = 2,
                    speed = self.speed
                })
            end
            self:SetStackCount(0)
        else
            self:SetStackCount(40)
            self.fx =
                ParticleManager:CreateParticle("particles/custom/dash.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
            ParticleManager:SetParticleControlEnt(self.fx, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, "follow_origin",
                self.parent:GetAbsOrigin(), true)
        end
        if self:ApplyHorizontalMotionController() == false then
            self:Destroy()
        end
    end
    function modifier_builtin_blink_movement:OnDestroy()
        FindClearSpaceForUnit(self.parent, self.parent:GetAbsOrigin(), false)
        if self.isHero == true then
            PlayerResource:SetCameraTarget(self.parent:GetPlayerOwnerID(), nil)
        end
        ParticleManager:DestroyParticle(self.fx, false)
        Timers:CreateTimer(0.05, function()
            self.parent:StopSound("AOH.DashLoop")
        end)
    end
    function modifier_builtin_blink_movement:OnIntervalThink()
        local enemies = FindUnitsInRadius(self.parent:GetTeamNumber(), -- int, your team number
        self.parent:GetAbsOrigin(), -- point, center point
        nil, -- handle, cacheUnit. (not known)
        150, -- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY, -- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, -- int, type filter
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, -- int, flag filter
        0, -- int, order filter
        false -- bool, can grow cache
        )
        for _, enemy in pairs(enemies) do
            enemy:AddNewModifier(self.parent, self:GetAbility(), "modifier_builtin_blink_dashdamage", {
                duration = 2,
                speed = self.speed
            })
        end
    end
    -- Status Effects

    function modifier_builtin_blink_movement:UpdateHorizontalMotion()
        local origin = self.parent:GetAbsOrigin()
        if -4000 > origin.x or origin.x > 5000 or math.abs(origin.y) > 5000 then
            self:Destroy()
        end
        self.parent:SetAbsOrigin(origin + self.parent:GetForwardVector() * self.speed)

    end
end

function modifier_builtin_blink_movement:OnHorizontalMotionInterrupted()
    if IsServer() then
        self:Destroy()
    end
end

modifier_builtin_blink_dashdamage = class({})

function modifier_builtin_blink_dashdamage:IsPurgable()
    return false
end

function modifier_builtin_blink_dashdamage:IsHidden()
    return false
end

function modifier_builtin_blink_dashdamage:RemoveOnDeath()
    return false
end

function modifier_builtin_blink_dashdamage:GetEffectName()
    return "particles/econ/items/wraith_king/wraith_king_ti6_bracer/wraith_king_ti6_hellfireblast_debuff.vpcf"
end

function modifier_builtin_blink_dashdamage:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_builtin_blink_dashdamage:GetTexture()
    return "modifier_skill_dashdamage"
end

if IsServer() then
    function modifier_builtin_blink_dashdamage:OnCreated(keys)
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.ability = self:GetAbility()
        self.speed = keys.speed * 33
        self:StartIntervalThink(0.2)
    end
    function modifier_builtin_blink_dashdamage:OnDestroy()
    end
    function modifier_builtin_blink_dashdamage:OnIntervalThink()
        ApplyDamage({
            victim = self.parent,
            attacker = self.caster,
            damage = self.speed * 0.15,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self.ability
        })
    end
end

modifier_builtin_blink_dashattack = class({})

function modifier_builtin_blink_dashattack:IsPurgable()
    return false
end

function modifier_builtin_blink_dashattack:IsHidden()
    return false
end

function modifier_builtin_blink_dashattack:RemoveOnDeath()
    return false
end

function modifier_builtin_blink_dashattack:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_builtin_blink_dashattack:GetTexture()
    return "modifier_skill_wavedash"
end

function modifier_builtin_blink_dashattack:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED}
    return funcs
end
function modifier_builtin_blink_dashattack:GetModifierDamageOutgoing_Percentage()
    return 300
end
if IsServer() then
    function modifier_builtin_blink_dashattack:OnAttackLanded(keys)
        local attacker = keys.attacker
        if attacker == self:GetParent() then
            local fx = ParticleManager:CreateParticle("particles/custom/wavedash_crit.vpcf", PATTACH_POINT_FOLLOW,
                keys.target)
            ParticleManager:SetParticleControlEnt(fx, 0, keys.target, PATTACH_POINT, "attach_hitloc",
                keys.target:GetAbsOrigin(), -- unknown
                true -- unknown, true
            )
            Timers:CreateTimer(0.1, function()
                self:Destroy()
            end)
        end
    end
end
modifier_builtin_blink_immunity = class({})

function modifier_builtin_blink_immunity:IsPurgable()
    return false
end

function modifier_builtin_blink_immunity:IsHidden()
    return false
end

function modifier_builtin_blink_immunity:RemoveOnDeath()
    return false
end

function modifier_builtin_blink_immunity:GetStatusEffectName()
    return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function modifier_builtin_blink_immunity:GetTexture()
    return "juggernaut_counter"
end

function modifier_builtin_blink_immunity:CheckState()
    local state = {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true
    }
    return state
end

modifier_builtin_blink_cooldown = class({})

function modifier_builtin_blink_cooldown:GetTexture()
    return "blink"
end

function modifier_builtin_blink_cooldown:IsPurgable()
    return false
end

function modifier_builtin_blink_cooldown:IsHidden()
    return false
end

function modifier_builtin_blink_cooldown:RemoveOnDeath()
    return false
end
