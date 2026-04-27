local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local AyatData = require(Shared:WaitForChild("AyatData"))

local GameManager = {}

local function normalizeText(text)
    local lowered = string.lower(text)
    lowered = string.gsub(lowered, "[^%w%s']", "")
    lowered = string.gsub(lowered, "%s+", " ")
    return string.gsub(lowered, "^%s*(.-)%s*$", "%1")
end

function GameManager.getRandomAyat()
    if #AyatData == 0 then
        return nil
    end
    return AyatData[math.random(1, #AyatData)]
end

function GameManager.checkAnswer(inputPlayer, answerExpected)
    if typeof(inputPlayer) ~= "string" or typeof(answerExpected) ~= "string" then
        return false
    end
    return normalizeText(inputPlayer) == normalizeText(answerExpected)
end

return GameManager