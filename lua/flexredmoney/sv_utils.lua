FRedMoney = FRedMoney or {}

local PLAYER = FindMetaTable("Player")

function PLAYER:AddRedMoney(amount)
    FRedMoney:DebugPrint("Adding " .. amount .. " to " .. self:Nick() .. "'s RedMoney")
    self:SetNWInt("RedMoney", self:GetNWInt("RedMoney") + amount)
end

function PLAYER:TakeRedMoney(amount)
    self:SetNWInt("RedMoney", self:GetNWInt("RedMoney") - amount)
end

function PLAYER:SetRedMoney(amount)
    self:SetNWInt("RedMoney", amount)
end

if FRedMoney.Config.OverwriteDarkRPFunction then
    function PLAYER:addMoney(amount)
        FRedMoney:DebugPrint("Added Red money to" .. self:Nick() .. " @ " .. amount .. "\n RedMoney - sv_utils.lua : 7")
        self:AddRedMoney(amount)
    end
end

function FRedMoney.PayoutPlayer(ply, amount)
    if not IsValid(ply) then return end
    if not amount then return end
    if not isnumber(amount) then return end
    if amount < 0 then return end

    amount = DarkRP.toInt(amount)
    if not amount then return false end
    local self = ply
    local total = self:getDarkRPVar("money") + amount
    total = hook.Call("playerWalletChanged", GAMEMODE, self, amount, self:getDarkRPVar("money")) or total

    self:setDarkRPVar("money", total)

    if self.DarkRPUnInitialized then return end
    DarkRP.storeMoney(self, total)
end

function FRedMoney:ChangeTax()
    assert( isnumber(FRedMoney.Config.RedMoneyRates["min"]) == true , "Well we fucked up FRedMoney.Config.RedMoneyRates.min is not a fucking number")
    assert( isnumber(FRedMoney.Config.RedMoneyRates["max"]) == true , "Well we fucked up FRedMoney.Config.RedMoneyRates.max is not a fucking number")
    for k, v in ipairs( ents.FindByClass( "flex_money_cleaner" ) ) do
        v:SetRate(math.floor(math.random(FRedMoney.Config.RedMoneyRates["min"], FRedMoney.Config.RedMoneyRates["max"])))
    end
end

timer.Create("FRedMoney.Config.RateRefreshTime" , FRedMoney.Config.RateRefreshTime or 30 , 0 , function()
	FRedMoney:ChangeTax()
end)

hook.Add( "PlayerDeath", "FRedMoney.PlayerDeath", function( victim, inflictor, attacker )
    local money = victim:GetRedMoney()
    victim:SetRedMoney(0)
    attacker:AddRedMoney(money)
end)