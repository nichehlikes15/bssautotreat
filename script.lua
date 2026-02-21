--Credit duysuts for orignal owner

-------------------------------------------------
-- MAIN CONFIG  (EDIT THESE)
-------------------------------------------------

local WEBHOOK = "https://discord.com/api/webhooks/123456789/qwe_rtyuiopasdfghjk_lzxcvbnm"
local PINGID = "1071772788504924180"
-- Only edit the below to true or false
local CLAIMFREETOKENS = true
local AUTO_HATCH_ENABLE = true
local AUTO_FEED_ENABLE = true
local AUTO_PRINTER_ENABLE = true
local AUTO_BUY_EGG_TICKET = true
local CHECK_QUEST = true
local AUTO_DELETE_ENABLE = false

-------------------------------------------------
-- PRECISE CONFIG  (DEFAULT IS ALREADY PERFECT)
-------------------------------------------------

local AUTO_FEED_BEE_LEVEL = 7
local AUTO_FEED_BEE_AMOUNT = 7
local AUTO_FEED_AUTO_BUY_TREAT = true
local AUTO_FEED_BEE_FOOD = {
    Treat = true,
    Blueberry = true,
    Strawberry = true,
    Pineapple = true,
    SunflowerSeed = true,
    Bitterberry = true,
    MoonCharm = true,
    GingerbreadBear = true,
    Neonberry = true,
}
local AUTO_HATCH_EGGS = {
    "Basic",
    "Silver",
    "Gold",
    "Diamond"
}
local AUTO_DELETE_KEEP_KEYWORDS = {
    "star",
    "cub",
    "sign"
}

local ALLOWED_PLACEID = 1537690962
if game.PlaceId ~= ALLOWED_PLACEID then
    warn("Wrong PlaceId, script stopped:", game.PlaceId)
    return
end

repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local Config = getgenv().Config or {}
local FeedConfig = Config["Auto Feed"] or {}

local ts = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Http = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")

local ClientStatCache = require(RS:WaitForChild("ClientStatCache"))
local Player = Players.LocalPlayer
local Events = RS:WaitForChild("Events")

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "By Nichehlikes15",
    Text = "Loading Star Sign Script",
    Duration = 5
})
print("Loading Script...")

getgenv().Config = getgenv().Config or {}
getgenv().Config["PingId"] = PINGID
getgenv().Config["LinkWebhook"] = WEBHOOK
getgenv().Config["Auto Feed"] = {Enable = AUTO_FEED_ENABLE,["Bee Level"] = AUTO_FEED_BEE_LEVEL,["Bee Amount"] = AUTO_FEED_BEE_AMOUNT,["Auto Buy Treat"] = AUTO_FEED_AUTO_BUY_TREAT,["Bee Food"] = AUTO_FEED_BEE_FOOD}
getgenv().Config["Auto Hatch"] = {Enable = AUTO_HATCH_ENABLE,["Egg Hatch"] = AUTO_HATCH_EGGS}
getgenv().Config["Auto Printer"] = {Enable = AUTO_PRINTER_ENABLE}
getgenv().Config["Auto Buy Egg Ticket"] = AUTO_BUY_EGG_TICKET
getgenv().Config["Check Quest"] = CHECK_QUEST
getgenv().Config["Auto Delete"] = {Enable = AUTO_DELETE_ENABLE,KeepKeywords = AUTO_DELETE_KEEP_KEYWORDS}

local function now()
    return tick()
end

local function safeRequest(url, payload)
    if not url or url == "" then return end
    pcall(function()
        request({
            Url = url,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = Http:JSONEncode(payload)
        })
    end)
end

local function makeEmbed(title, fields, color, embedExtra)
    local e = {
        title = title,
        color = color or 65280,
        fields = fields or {},
        --image = { url = IMAGE_URL },
        footer = { text = "made by Nichehlikes15" }
    }
    if type(embedExtra) == "table" then
        for k, v in pairs(embedExtra) do
            e[k] = v
        end
    end
    return e
end

local function sendWebhook(title, fields, color, embedExtra)
    local pingId = tostring((getgenv().Config or {})["PingId"] or "")
    local payload = {
        content = (pingId ~= "" and ("<@" .. pingId .. ">")) or nil,
        embeds = { makeEmbed(title, fields, color, embedExtra) }
    }

    safeRequest((getgenv().Config or {})["LinkWebhook"], payload)
end

task.spawn(function()
    local player = Players.LocalPlayer

    local fields = {
        { name = "Username", value = "`" .. player.Name .. "`" },
        { name = "User ID", value = "`" .. tostring(player.UserId) .. "`" },
        { name = "Account Age", value = "`" .. player.AccountAge .. " Days`" },
        { name = "Job ID", value = "`" .. tostring(game.JobId) .. "`" },
        { name = "In Group", value = "`" .. tostring(player:IsInGroup(3982592)) .. "`"},
        { name = "Sticker Printer Access", value = "`" .. (player:IsInGroup(3982592) and player.AccountAge >= 7 and "Yes" or "No") .. "`" }
    }

    local embedExtra = {
        description = "Below is the details of the account used.",
        title = "Sign Farm Script Startup",
        color = 65280,
        footer = {
            text = "Made By NichEhLikes15",
            icon_url = "https://cdn.nookazon.com/beeswarmsimulator/stickers/Aries_Star_Sign.png"
        },
        timestamp = DateTime.now():ToIsoDate(),
        thumbnail = { url = "https://cdn.nookazon.com/beeswarmsimulator/stickers/Aries_Star_Sign.png" }
    }

    sendWebhook(nil, fields, nil, embedExtra)
end)

local function deepFind(tbl, key, seen)
    if type(tbl) ~= "table" then return end
    seen = seen or {}
    if seen[tbl] then return end
    seen[tbl] = true
    for k, v in pairs(tbl) do
        if k == key then return v end
        if type(v) == "table" then
            local f = deepFind(v, key, seen)
            if f ~= nil then return f end
        end
    end
end

local ITEM_KEYS = {
    MoonCharm = "MoonCharm",
    Pineapple = "Pineapple",
    Strawberry = "Strawberry",
    Blueberry = "Blueberry",
    SunflowerSeed = "SunflowerSeed",
    Bitterberry = "Bitterberry",
    Neonberry = "Neonberry",
    GingerbreadBear = "GingerbreadBear",
    Treat = "Treat",
    Silver = "Silver",
    Ticket = "Ticket",
    Gold = "Gold",
    Diamond = "Diamond",
    ["Star Egg"] = "Star",
    Basic = "Basic",
    Royal = "RoyalJelly",
    Star = "StarJelly",
}

local BOND_ITEMS = {
    { Name = "Neonberry", Value = 500 },
    { Name = "MoonCharm", Value = 250 },
    { Name = "GingerbreadBear", Value = 250 },
    { Name = "Bitterberry", Value = 100 },
    { Name = "Pineapple", Value = 50 },
    { Name = "Strawberry", Value = 50 },
    { Name = "Blueberry", Value = 50 },
    { Name = "SunflowerSeed", Value = 50 },
    { Name = "Treat", Value = 10 }
}

local QUEST_ORDER = {
    "Treat Tutorial",
    "Bonding With Bees",
    "Search For A Sunflower Seed",
    "The Gist Of Jellies",
    "Search For Strawberries",
    "Binging On Blueberries",
    "Royal Jelly Jamboree",
    "Search For Sunflower Seeds",
    "Picking Out Pineapples",
    "Seven To Seven"
}

local QUEST_TREAT_REQ = {
    ["Treat Tutorial"] = 1,
    ["Bonding With Bees"] = 5,
    ["Search For A Sunflower Seed"] = 10,
    ["The Gist Of Jellies"] = 15,
    ["Search For Strawberries"] = 20,
    ["Binging On Blueberries"] = 30,
    ["Royal Jelly Jamboree"] = 50,
    ["Search For Sunflower Seeds"] = 100,
    ["Picking Out Pineapples"] = 250,
    ["Seven To Seven"] = 500
}

local QUEST_FRUIT_REQ = {
    ["Search For A Sunflower Seed"] = { SunflowerSeed = 1 },
    ["Search For Strawberries"] = { Strawberry = 5 },
    ["Binging On Blueberries"] = { Blueberry = 10 },
    ["Search For Sunflower Seeds"] = { SunflowerSeed = 25 },
    ["Picking Out Pineapples"] = { Pineapple = 25 },
    ["Seven To Seven"] = { Blueberry = 25, Strawberry = 25 }
}

local Cache = { data = nil, last = 0, ttl = 0.8 }
local function getCache()
    local t = now()
    if (t - Cache.last) > Cache.ttl or Cache.data == nil then
        local ok, res = pcall(function()
            return ClientStatCache:Get()
        end)
        if ok then
            Cache.data = res
            Cache.last = t
        end
    end
    return Cache.data
end

local function getInventory(cache)
    cache = cache or getCache()
    if not cache or not cache.Eggs then return {} end
    local inv = {}
    for name, key in pairs(ITEM_KEYS) do
        inv[name] = tonumber(cache.Eggs[key]) or 0
    end
    return inv
end
local function getCurrentQuestFromActive(cache)
    cache = cache or getCache()
    local active = cache and cache.Quests and cache.Quests.Active
    if type(active) ~= "table" then return nil end

    local activeSet = {}
    for _, v in pairs(active) do
        local n = v and v.Name
        if n then
            n = tostring(n)
            if QUEST_TREAT_REQ[n] ~= nil then
                activeSet[n] = true
            end
        end
    end

    for _, q in ipairs(QUEST_ORDER) do
        if activeSet[q] then
            return q
        end
    end
    return nil
end

local function getGlobalReserveFromCurrent(currentQuest)
    local treat = 0
    local fruits = {}
    local started = (currentQuest == nil)

    for _, q in ipairs(QUEST_ORDER) do
        if not started and q == currentQuest then
            started = true
        end
        if started then
            treat += (QUEST_TREAT_REQ[q] or 0)
            local f = QUEST_FRUIT_REQ[q]
            if f then
                for name, amt in pairs(f) do
                    fruits[name] = (fruits[name] or 0) + amt
                end
            end
        end
    end

    if currentQuest == nil then
        return treat, fruits
    end
    return treat, fruits
end
local function getBees(cache)
    cache = cache or getCache()
    local bees = {}
    if not cache or not cache.Honeycomb then return bees end

    for cx, col in pairs(cache.Honeycomb) do
        for cy, bee in pairs(col) do
            if bee and bee.Lvl then
                local x = tonumber(tostring(cx):match("%d+"))
                local y = tonumber(tostring(cy):match("%d+"))
                if x and y then
                    bees[#bees + 1] = { col = x, row = y, level = bee.Lvl }
                end
            end
        end
    end
    return bees
end

local function findEmptySlot()
    local hives = Workspace:WaitForChild("Honeycombs")
    for _, hive in ipairs(hives:GetChildren()) do
        local owner = hive:FindFirstChild("Owner")
        local isMine =
            (owner and owner:IsA("ObjectValue") and owner.Value == Player) or
            (owner and owner:IsA("StringValue") and owner.Value == Player.Name) or
            (owner and owner:IsA("IntValue") and owner.Value == Player.UserId)

        if isMine and hive:FindFirstChild("Cells") then
            local bestX, bestY
            for _, cell in ipairs(hive.Cells:GetChildren()) do
                local cellType = cell:FindFirstChild("CellType")
                local x = cell:FindFirstChild("CellX")
                local y = cell:FindFirstChild("CellY")
                local locked = cell:FindFirstChild("CellLocked")

                if cellType and x and y and locked and not locked.Value then
                    local empty = (cellType.Value == "" or tostring(cellType.Value):lower() == "empty")
                    if empty then
                        if not bestX
                            or (x.Value < bestX)
                            or (x.Value == bestX and y.Value < bestY) then
                            bestX, bestY = x.Value, y.Value
                        end
                    end
                end
            end
            if bestX then return bestX, bestY end
        end
    end
end

local function getBondLeft(col, row)
    local result
    pcall(function()
        result = Events.GetBondToLevel:InvokeServer(col, row)
    end)
    if type(result) == "number" then return result end
    if type(result) == "table" then
        for _, v in pairs(result) do
            if type(v) == "number" then return v end
        end
    end
end

local function buyTreatIfNeeded()
    local cfg = (getgenv().Config or {})["Auto Feed"]
    if not cfg or not cfg["Auto Buy Treat"] then return end
    local honey = Player.CoreStats.Honey.Value
    if honey < 10000000 then return end
    pcall(function()
        Events.ItemPackageEvent:InvokeServer("Purchase", {
            Type = "Treat",
            Amount = 1000,
            Category = "Eggs"
        })
    end)
end

local FEED_LOCKED = getgenv().FEED_LOCKED or {}
local FEED_LOCK_FINAL = getgenv().FEED_LOCK_FINAL or false
local FEED_DONE = getgenv().FEED_DONE or false

getgenv().FEED_LOCKED = FEED_LOCKED
getgenv().FEED_LOCK_FINAL = FEED_LOCK_FINAL
getgenv().FEED_DONE = FEED_DONE

local function autoFeed()
    local FeedConfig = (getgenv().Config or {})["Auto Feed"]
    if FEED_DONE or not FeedConfig["Enable"] then return end

    local cache = getCache()
    if not cache then return end

    local completed = deepFind(cache, "Completed") or {}
    local targetLevel = FeedConfig["Bee Level"] or 7
    local maxCount = FeedConfig["Bee Amount"] or 7

    local bees = getBees(cache)
    if #bees == 0 then return end

    local function beeKey(col, row)
        return tostring(col) .. ":" .. tostring(row)
    end

    local function lockedCount()
        local c = 0
        for _ in pairs(FEED_LOCKED) do c += 1 end
        return c
    end

    local live = {}
    for _, b in ipairs(bees) do
        live[beeKey(b.col, b.row)] = b
    end

    for k, lb in pairs(FEED_LOCKED) do
        local cur = live[k]
        if cur then
            lb.level = cur.level
        else
            if not FEED_LOCK_FINAL then
                FEED_LOCKED[k] = nil
            end
        end
    end

    if not FEED_LOCK_FINAL then
        if lockedCount() < maxCount then
            table.sort(bees, function(a, b) return a.level > b.level end)
            for _, b in ipairs(bees) do
                if lockedCount() >= maxCount then break end
                local k = beeKey(b.col, b.row)
                if not FEED_LOCKED[k] then
                    FEED_LOCKED[k] = { col = b.col, row = b.row, level = b.level }
                end
            end
            if lockedCount() >= maxCount then
                FEED_LOCK_FINAL = true
                getgenv().FEED_LOCK_FINAL = true
            end
        else
            FEED_LOCK_FINAL = true
            getgenv().FEED_LOCK_FINAL = true
        end
    end

    if lockedCount() >= maxCount then
        local reached = 0
        for _, b in pairs(FEED_LOCKED) do
            if b.level >= targetLevel then
                reached += 1
            end
        end

        if reached >= maxCount then
            FEED_DONE = true
            getgenv().FEED_DONE = true
            return
        end
    end

    local target, minLevel = nil, math.huge
    for _, b in pairs(FEED_LOCKED) do
        if b.level < targetLevel and b.level < minLevel then
            minLevel = b.level
            target = b
        end
    end
    if not target then return end

    local currentQuest = getCurrentQuestFromActive(cache)
    local isFinalQuest = (currentQuest == "Seven To Seven")
    local reserveTreat, reserveFruits = getGlobalReserveFromCurrent(currentQuest)

    local inventory = getInventory(cache)
    local bondLeft = getBondLeft(target.col, target.row)
    if not bondLeft or bondLeft <= 0 then return end

    local remaining = bondLeft
    local feedPlan = {}

    for _, item in ipairs(BOND_ITEMS) do
        if remaining <= 0 then break end
        if FeedConfig["Bee Food"] and FeedConfig["Bee Food"][item.Name] then
            local keep = 0
            if not isFinalQuest then
                if item.Name == "Treat" then keep = reserveTreat end
                if reserveFruits[item.Name] then keep = reserveFruits[item.Name] end
            end

            local have = (inventory[item.Name] or 0) - keep
            if have > 0 then
                local maxBond = have * item.Value
                local bondToUse = math.min(remaining, maxBond)
                local use = math.ceil(bondToUse / item.Value)

                if use > 0 then
                    feedPlan[#feedPlan + 1] = {
                        name = item.Name,
                        amount = use
                    }
                    remaining -= use * item.Value
                end
            end
        end
    end

    if remaining <= 0 and #feedPlan > 0 then
        for _, feed in ipairs(feedPlan) do
            buyTreatIfNeeded()
            Events.ConstructHiveCellFromEgg:InvokeServer(
                target.col,
                target.row,
                ITEM_KEYS[feed.name],
                feed.amount,
                false
            )
            task.wait(0.1)
        end
        return
    end

    if FeedConfig["Auto Buy Treat"] then
        local honey = Player.CoreStats.Honey.Value

        if isFinalQuest then
            local maxBuy = math.floor(honey / 10000)
            if maxBuy > 0 then
                Events.ItemPackageEvent:InvokeServer("Purchase", {
                    Type = "Treat",
                    Amount = maxBuy,
                    Category = "Eggs"
                })
                return
            end
        else
            local freeTreat = (inventory["Treat"] or 0) - reserveTreat
            local needTreat = math.max(0, math.ceil(remaining / 10) - freeTreat)
            local cost = needTreat * 10000

            if needTreat > 0 and honey >= cost then
                Events.ItemPackageEvent:InvokeServer("Purchase", {
                    Type = "Treat",
                    Amount = needTreat,
                    Category = "Eggs"
                })
                return
            end
        end
    end
end

local function rerollBasic(col, row)
    task.wait(0.4)

    local cache = getCache()
    if not cache or not cache.Honeycomb then return end

    local cell = cache.Honeycomb[col] and cache.Honeycomb[col][row]
    if not cell then return end

    local beeType = tostring(cell.BeeType or "")
    local gifted = cell.Gifted == true

    if beeType ~= "Basic" or gifted then
        return
    end

    local inv = getInventory(cache)

    if (inv["Star"] or 0) > 0 then
        Events.ConstructHiveCellFromEgg:InvokeServer(col,row,"Star",1,false)
        return
    end

    if (inv["Royal"] or 0) > 0 then
        Events.ConstructHiveCellFromEgg:InvokeServer(col,row,"Royal",1,false)
        return
    end
end

local function autoHatch()
    local cfg = (getgenv().Config or {})["Auto Hatch"]
    if not cfg or not cfg["Enable"] then return end

    local col, row = findEmptySlot()
    if not col then return end

    local cache = getCache()
    if not cache then return end
    local inv = getInventory(cache)

    for _, egg in ipairs(cfg["Egg Hatch"] or {}) do
        if (inv[egg] or 0) > 0 then
            pcall(function()
                Events.ConstructHiveCellFromEgg:InvokeServer(col, row, egg, 1, false)

                task.spawn(function()
                    rerollBasic(col, row)
                end)

                return
            end)
            return
        end
    end
end

local GROUP_ID = 3982592
local MIN_DAYS = 7
local PRINTER_CD = 0

local function autoPrinter()
    local cfg = (getgenv().Config or {})["Auto Printer"]
    if not cfg or not cfg["Enable"] then return end
    if now() - PRINTER_CD < 10 then return end
    if not Player or Player.AccountAge < MIN_DAYS then return end

    local cache = getCache()
    if not cache then return end
    local bees = getBees(cache)
    if #bees < 25 then return end

    local inGroup = false
    pcall(function()
        inGroup = Player:IsInGroup(GROUP_ID)
    end)
    if not inGroup then return end

    local inv = getInventory(cache)
    if (inv["Star Egg"] or 0) > 0 then
        PRINTER_CD = now()
        Events.StickerPrinterActivate:FireServer("Star Egg")

        local fields = {
            { name = "Username", value = "`" .. Player.Name .. "`" },
            { name = "User ID", value = "`" .. tostring(Player.UserId) .. "`" },
            { name = "Account Age", value = "`" .. Player.AccountAge .. " Days`"},
            { name = "Bee Count", value = tostring(#bees)},
            { name = "In Group", value = tostring(inGroup)},
            { name = "Sticker Printer Access", value = "`" .. (Player:IsInGroup(3982592) and Player.AccountAge >= 7 and "Yes" or "No") .. "`" }

        }
        local embedExtra = {
            description = "Below is the details of the account used.",
            title = "Star Egg Printer Roll",
            color = 16777215,
            footer = {
                text = "Made By NichEhLikes15",
                icon_url = "https://cdn.nookazon.com/beeswarmsimulator/stickers/Aries_Star_Sign.png"
            },
            timestamp = DateTime.now():ToIsoDate(),
            thumbnail = { url = "https://cdn.nookazon.com/beeswarmsimulator/stickers/Aries_Star_Sign.png" }
        }

        sendWebhook(nil, fields, nil, embedExtra)
    end
end

local QUEST_DONE = false
local function checkQuest()
    if QUEST_DONE or (getgenv().Config or {})["Check Quest"] == false then return end
    local cache = getCache()
    if not cache then return end
    local completed = deepFind(cache, "Completed")
    if not completed then return end

    for _, q in pairs(completed) do
        if tostring(q) == "Seven To Seven" then
            local fields = {
                { name = "Username", value = "`" .. Player.Name .. "`" },
                { name = "User ID", value = "`" .. tostring(Player.UserId) .. "`" },
                { name = "Account Age", value = "`" .. Player.AccountAge .. " Days`"},
                { name = "Bee Count", value = tostring(#getBees(cache))},
                { name = "In Group", value = (Player:IsInGroup(3982592) and "Yes" or "No")},
                { name = "Sticker Printer Access", value = "`" .. (Player:IsInGroup(3982592) and Player.AccountAge >= 7 and "Yes" or "No") .. "`" }

            }
            local embedExtra = {
                description = "Below is the details of the account used.",
                title = "Quest: Seven To Seven Completed",
                color = 16777215,
                footer = {
                    text = "Made By NichEhLikes15",
                    icon_url = "https://cdn.nookazon.com/beeswarmsimulator/stickers/Aries_Star_Sign.png"
                },
                timestamp = DateTime.now():ToIsoDate(),
                thumbnail = { url = "https://cdn.nookazon.com/beeswarmsimulator/stickers/Aries_Star_Sign.png" }
            }

            sendWebhook(nil, fields, nil, embedExtra)
            QUEST_DONE = true
            return
        end
    end
end

local function getStickerTypes()
    local folder = RS:FindFirstChild("Stickers", true)
    if not folder then return end
    local module = folder:FindFirstChild("StickerTypes")
    if not module then return end
    local ok, data = pcall(require, module)
    return ok and data or nil
end

local function buildIDMap(tbl, map, seen)
    map = map or {}
    seen = seen or {}
    if seen[tbl] then return map end
    seen[tbl] = true
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            if v.ID then
                map[tonumber(v.ID)] = tostring(k)
            end
            buildIDMap(v, map, seen)
        end
    end
    return map
end

local STICKER_TYPES = getStickerTypes()
local STICKER_ID_MAP = STICKER_TYPES and buildIDMap(STICKER_TYPES) or {}

local function getRemote(name)
    return RS:FindFirstChild(name, true)
end

local function getBook(cache)
    cache = cache or getCache()
    if not cache then return nil end
    return cache.Stickers and cache.Stickers.Book
end

local function getInbox(cache)
    cache = cache or getCache()
    if not cache then return nil end
    return cache.Stickers and cache.Stickers.Inbox
end

local LAST_EGG_BUY = 0
local function autoBuyEggTicket()
    local cfg = (getgenv().Config or {})["Auto Buy Egg Ticket"]
    if cfg == false then return end
    if now() - LAST_EGG_BUY < 10 then return end

    local cache = getCache()
    if not cache then return end
    local inv = getInventory(cache)
    local tickets = inv["Ticket"] or 0
    if tickets < 50 then return end

    LAST_EGG_BUY = now()
    pcall(function()
        Events.ItemPackageEvent:InvokeServer("Purchase", {
            Type = "Silver",
            Amount = 1,
            Category = "Eggs"
        })
    end)
end

local function shouldKeepSticker(name)
    local ad = (Config or {})["Auto Delete"]
    if not ad or not ad.Enable then
        return true
    end
    local keep = ad.KeepKeywords
    if type(keep) ~= "table" then
        return false
    end
    local lname = tostring(name):lower()
    for _, k in ipairs(keep) do
        if lname:find(tostring(k):lower(), 1, true) then
            return true
        end
    end
    return false
end

local function autoClaimStickers(limit)
    limit = limit or 20
    local cache = getCache()
    if not cache then return end

    local inbox = getInbox(cache)
    if type(inbox) ~= "table" or #inbox == 0 then return end

    local book = getBook(cache) or {}
    local used = {}
    for _, d in ipairs(book) do
        local s = d[4] or d.Slot
        if s then used[s] = true end
    end

    local function empty()
        local i = 1
        while used[i] do i += 1 end
        used[i] = true
        return i
    end

    local ev = getRemote("StickerClaimFromInbox")
    if not ev then return end

    local claimed = 0
    for i = #inbox, 1, -1 do
        local d = inbox[i]
        ev:FireServer({
            [1] = d[1],
            [2] = d[2],
            [3] = d[3],
            [4] = empty()
        }, false)
        claimed += 1
        if claimed >= limit then break end
    end
end

local function autoDeleteStickers(limit)
    limit = limit or 10
    local cache = getCache()
    if not cache then return end

    local book = getBook(cache)
    if type(book) ~= "table" or #book == 0 then return end

    local ev = getRemote("StickerDiscard")
    if not ev then return end

    local deleted = 0
    for _, d in ipairs(book) do
        local id = d.TypeID or d[3]
        local name = STICKER_ID_MAP[tonumber(id)] or ""

        if not shouldKeepSticker(name) then
            ev:FireServer({
                [1] = d[1],
                [2] = d[2],
                [3] = d[3],
                [4] = d[4]
            }, false)
            deleted += 1
            if deleted >= limit then break end
        end
    end
end

local STATE = {
    WROTE_STATUS = false,
    NO_STAR_TIMER = 0,
    LAST_SIGNS = {}
}

local function getAllStickersNew(cache)
    cache = cache or getCache()
    if not cache or not cache.Stickers then return {} end

    local result = {}

    local function readList(list)
        if type(list) ~= "table" then return end
        for _, data in ipairs(list) do
            local typeId = data.TypeID or data[3]
            if typeId then
                local name = STICKER_ID_MAP[tonumber(typeId)]
                if name then
                    result[name] = (result[name] or 0) + 1
                end
            end
        end
    end

    readList(cache.Stickers.Book)
    readList(cache.Stickers.Inbox)
    return result
end

local function checkStarSign()
    if STATE.WROTE_STATUS then return end

    local cache = getCache()
    if not cache then return end

    local stickers = getAllStickersNew(cache)

    for name, amount in pairs(stickers) do
        local lname = tostring(name):lower()
        local isSign = lname:match("star%s*sign")
        local isCub = lname:match("star%s*cub")

        if isSign or isCub then
            local key = isCub and "star_cub" or "star_sign"
            local last = STATE.LAST_SIGNS[key] or 0

            if amount > last then
                local label = isCub and "Star Cub" or "Star Sign"

                local fields = {
                    { name = "Username", value = "`" .. Player.Name .. "`" },
                    { name = "User ID", value = "`" .. tostring(Player.UserId) .. "`" },
                    { name = "Type", value = label, inline = false },
                    { name = "Sticker", value = name, inline = false },
                    { name = "Amount", value = tostring(amount), inline = false }
                }
                local embedExtra = {
                    description = "Below is the details of the account used.",
                    title = "Collected: " .. label,
                    color = 65280,
                    footer = {
                        text = "Made By NichEhLikes15",
                        icon_url = "https://cdn.nookazon.com/beeswarmsimulator/stickers/Aries_Star_Sign.png"
                    },
                    timestamp = DateTime.now():ToIsoDate(),
                    thumbnail = { url = "https://cdn.nookazon.com/beeswarmsimulator/stickers/Aries_Star_Sign.png" }
                }

                sendWebhook(nil, fields, nil, embedExtra)

                STATE.LAST_SIGNS[key] = amount
            end
        end
    end
end

local function claimFreeTokens()
    local rise_info = TweenInfo.new(1, Enum.EasingStyle.Linear)
    local move_info = TweenInfo.new(1, Enum.EasingStyle.Linear)
    local bob_info  = TweenInfo.new(0.2, Enum.EasingStyle.Linear)

    local targets = {
        CFrame.new(42, 149, -531),
        CFrame.new(-413.77, 17.17, 467.18),
        CFrame.new(83.94, 68.01, -142.12),
        CFrame.new(-435.52, 93.26, 48.78),
        CFrame.new(-480.57, 69.39, -0.42),
    }

    local index = 1
    local BOB_DURATION = 2

    while index <= #targets do
        local character = Player.Character or Player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        local humanoid = character:WaitForChild("Humanoid")

        local pos = hrp.Position
        local rise_target = CFrame.new(pos.X, 500, pos.Z)
        ts:Create(hrp, rise_info, { CFrame = rise_target }):Play()
        task.wait(1)

        ts:Create(hrp, move_info, { CFrame = targets[index] }):Play()
        task.wait(1)

        local start = os.clock()
        while os.clock() - start < BOB_DURATION do
            ts:Create(hrp, bob_info, { CFrame = hrp.CFrame * CFrame.new(0, 1, 0) }):Play()
            task.wait(0.2)
            ts:Create(hrp, bob_info, { CFrame = hrp.CFrame * CFrame.new(0, -1, 0) }):Play()
            task.wait(0.2)
        end

        index += 1
        if index <= #targets then
            humanoid.Health = 0
            Player.CharacterAdded:Wait()
        end
    end
end

if CLAIMFREETOKENS then claimFreeTokens() end

local function redeemCodes()
    task.spawn(function()

        local codes = {
            "38217","BeesBuzz123","BopMaster",
            "Connoisseur","Crawlers","Nectar",
            "Roof","Wax"
        }

        for _,code in ipairs(codes) do
            pcall(function()
                Events.PromoCodeEvent:FireServer(code)
            end)
            task.wait(1.2)
        end

        repeat task.wait(8)
        until #getBees() >= 15

        pcall(function()
            Events.PromoCodeEvent:FireServer("ClubBean")
        end)

    end)
end
redeemCodes()
local Scheduler = {}
Scheduler.__index = Scheduler

function Scheduler.new()
    return setmetatable({ tasks = {} }, Scheduler)
end

function Scheduler:add(name, interval, fn)
    self.tasks[name] = {
        interval = interval,
        fn = fn,
        last = 0
    }
end

function Scheduler:run()
    while task.wait(0.25) do
        local t = now()
        for _, taskDef in pairs(self.tasks) do
            if (t - taskDef.last) >= taskDef.interval then
                taskDef.last = t
                pcall(taskDef.fn)
            end
        end
    end
end

local sched = Scheduler.new()

sched:add("AutoBuyEggTicket", 5, autoBuyEggTicket)
sched:add("CheckStarSign", 5, checkStarSign)
sched:add("AutoFeed", 5, autoFeed)
sched:add("AutoHatch", 6, autoHatch)
sched:add("CheckQuest", 10, checkQuest)
sched:add("AutoPrinter", 8, autoPrinter)

sched:add("ClaimStickers", 12, function()
    autoClaimStickers(25)
end)

sched:add("DeleteStickers", 25, function()
    autoDeleteStickers(12)
end)

sched:run()

