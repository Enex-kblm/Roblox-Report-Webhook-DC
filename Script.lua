local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local WEBHOOK_BUG = "" -- GANTI SAMA URL WEBHOOK DISCORD
local WEBHOOK_PLAYER = "" -- GANTI SAMA URL WEBHOOK DISCORD

local ReportEvent = ReplicatedStorage:WaitForChild("ReportEvent")
local AntiSpamEvent = ReplicatedStorage:WaitForChild("AntiSpamEvent")

local COOLDOWN = 30
local lastReportTime = {}
local spamCounter = {}
local reportHistory = {}
local spamLog = {}

local function logSpamSilently(player, actionType, data)
	local timestamp = os.time()
	local logEntry = {
		timestamp = timestamp,
		dateTime = os.date("%Y-%m-%d %H:%M:%S", timestamp),
		playerId = player.UserId,
		playerName = player.Name,
		actionType = actionType,
		data = data
	}

	if not spamLog[player.UserId] then
		spamLog[player.UserId] = {
			playerName = player.Name,
			totalSpamAttempts = 0,
			firstSpamTime = timestamp,
			lastSpamTime = timestamp,
			spamHistory = {},
			patternDetections = 0
		}
	end

	local playerLog = spamLog[player.UserId]
	playerLog.totalSpamAttempts = playerLog.totalSpamAttempts + 1
	playerLog.lastSpamTime = timestamp

	table.insert(playerLog.spamHistory, logEntry)

	if #playerLog.spamHistory > 50 then
		table.remove(playerLog.spamHistory, 1)
	end

	print("[SPAM LOG]", player.Name, actionType, HttpService:JSONEncode(data))
end

local function calculateSimilarity(str1, str2)
	if not str1 or not str2 then return 0 end
	str1, str2 = str1:lower(), str2:lower()

	if str1 == str2 then return 1.0 end

	if str1:find(str2, 1, true) or str2:find(str1, 1, true) then
		return 0.8
	end

	local words1 = {}
	local words2 = {}
	for word in str1:gmatch("%w+") do words1[word] = true end
	for word in str2:gmatch("%w+") do words2[word] = true end

	local commonWords = 0
	local totalWords = 0
	for word in pairs(words1) do
		totalWords = totalWords + 1
		if words2[word] then commonWords = commonWords + 1 end
	end
	for word in pairs(words2) do
		if not words1[word] then totalWords = totalWords + 1 end
	end

	return totalWords > 0 and (commonWords / totalWords) or 0
end

local function detectRepeatedPattern(player, reportType, content)
	local userId = player.UserId
	if not reportHistory[userId] then 
		reportHistory[userId] = {} 
	end

	local recentReports = reportHistory[userId]
	local maxSimilarity = 0
	local similarReport = nil

	for i = math.max(1, #recentReports - 9), #recentReports do
		local oldReport = recentReports[i]
		if oldReport.type == reportType then
			local similarity = calculateSimilarity(content, oldReport.content)
			if similarity > maxSimilarity then
				maxSimilarity = similarity
				similarReport = oldReport
			end
		end
	end

	table.insert(recentReports, {
		timestamp = os.time(),
		type = reportType,
		content = content or ""
	})

	return {
		isRepeated = maxSimilarity > 0.7, 
		similarity = maxSimilarity,
		matchedContent = similarReport and similarReport.content or nil
	}
end

local function sendWebhook(url, data)
	pcall(function()
		HttpService:PostAsync(url, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
	end)
end

local function applyRateLimit(player, reportType)
	local userId = player.UserId

	local baseCD = COOLDOWN
	local spamCount = spamCounter[userId] or 0

	if spamCount >= 5 then
		lastReportTime[userId] = os.time() + (baseCD * 3) -- 90 second cooldown
	elseif spamCount >= 3 then
		lastReportTime[userId] = os.time() + (baseCD * 2) -- 60 second cooldown
	else
		lastReportTime[userId] = os.time() + baseCD -- 30 second cooldown
	end
end

ReportEvent.OnServerEvent:Connect(function(player, reportType, info)
	local now = os.time()
	local userId = player.UserId

	lastReportTime[userId] = lastReportTime[userId] or 0
	spamCounter[userId] = spamCounter[userId] or 0

	local timeDiff = now - lastReportTime[userId]
	local remainingCooldown = math.max(0, COOLDOWN - timeDiff)

	local reportContent = ""
	if reportType == "bug" then
		reportContent = info.Deskripsi or ""
	elseif reportType == "player" then
		reportContent = (info.Target or "") .. " " .. (info.Reason or "")
	end

	local patternResult = detectRepeatedPattern(player, reportType, reportContent)

	if timeDiff < COOLDOWN then
		spamCounter[userId] = spamCounter[userId] + 1

		logSpamSilently(player, "spam_attempt", {
			reportType = reportType,
			remainingTime = remainingCooldown,
			patternDetected = patternResult.isRepeated,
			similarity = patternResult.similarity,
			spamCount = spamCounter[userId],
			reportContent = reportContent
		})

		if patternResult.isRepeated then
			logSpamSilently(player, "pattern_detected", {
				reportType = reportType,
				similarity = patternResult.similarity,
				matchedContent = patternResult.matchedContent
			})

			if spamLog[userId] then
				spamLog[userId].patternDetections = spamLog[userId].patternDetections + 1
			end
		end

		applyRateLimit(player, reportType)

		return
	end


	lastReportTime[userId] = now
	spamCounter[userId] = 0

	if reportType == "bug" then
		local data = {
			["username"] = "?? Roblox Report System",
			["embeds"] = {{
				["title"] = "?? Bug Report",
				["description"] = "Seseorang menemukan bug di map!\n**-----------------------**",
				["color"] = 16776960,
				["fields"] = {
					{["name"] = "?? Reporter", ["value"] = info.Reporter, ["inline"] = true},
					{["name"] = "?? Koordinat", ["value"] = info.Coords, ["inline"] = true},
					{["name"] = "?? Deskripsi", ["value"] = info.Deskripsi ~= "" and info.Deskripsi or "_(Tidak ada deskripsi)_"},
					{["name"] = "?? Server", ["value"] = info.ServerId, ["inline"] = true}
				},
				["footer"] = {["text"] = "Bug Report • " .. os.date("%Y-%m-%d %H:%M:%S")},
			}}
		}
		sendWebhook(WEBHOOK_BUG, data)

	elseif reportType == "player" then
		local data = {
			["username"] = "?? Roblox Report System",
			["embeds"] = {{
				["title"] = "?? Player Report",
				["description"] = "Ada pemain yang dilaporkan!\n**-----------------------**",
				["color"] = 15158332,
				["fields"] = {
					{["name"] = "?? Reporter", ["value"] = info.Reporter, ["inline"] = true},
					{["name"] = "?? Target", ["value"] = info.Target, ["inline"] = true},
					{["name"] = "?? Alasan", ["value"] = info.Reason ~= "" and info.Reason or "_(Tidak ada alasan)_"},
					{["name"] = "?? Server", ["value"] = info.ServerId, ["inline"] = true}
				},
				["footer"] = {["text"] = "Player Report • " .. os.date("%Y-%m-%d %H:%M:%S")},
			}}
		}
		sendWebhook(WEBHOOK_PLAYER, data)
	end
end)
