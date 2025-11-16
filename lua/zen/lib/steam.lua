module("zen")

---@class zen.steam
steam = _GET("steam")

local file_Exists = file.Exists
local file_CreateDir = file.CreateDir
local file_Write = file.Write
local file_Time = file.Time
local Material = Material
local http_Fetch = http.Fetch
local os_time = os.time

--- Cache meta functions
local STRING_match = string.match

--- Load Steam Avatar Image and save as PNG
---@param steamid64 string
---@param callback fun(mat: IMaterial, path: string)
---@param onFailed? fun(...: string)
function steam.LoadSteamAvatar(steamid64, callback, onFailed)

    local folder = "steam/steam_avatars"
    local filename = folder .. "/" .. steamid64 .. ".png"

    local future_path = "data/" .. filename

    -- Ensure the folder exists
    if not file_Exists(folder, "DATA") then
        file_CreateDir(folder)
    end

    -- Check if the file already exists, and file.Time less 1 day
    if file_Exists(filename, "DATA") and file_Time(filename, "DATA") > os_time() - 86400 then
        local mat = Material(future_path, "noclamp smooth")
        callback(mat, future_path)
        return
    end

    -- Fetch the avatar from Steam
    local url = "https://steamcommunity.com/profiles/" .. steamid64 .. "?xml=1"
    http_Fetch(url, function(body)
        local avatar_url = STRING_match(body, "<avatarFull><!%[CDATA%[(.-)%]%]></avatarFull>")
        if not avatar_url then
            print("Failed to find avatar URL for SteamID: ", steamid64)
            if onFailed then onFailed("Failed to find avatar URL for SteamID: ", steamid64) end
            return
        end

        http_Fetch(avatar_url, function(avatar_data)
            file_Write(filename, avatar_data)
            local mat = Material(future_path, "noclamp smooth")
            callback(mat, future_path)
        end, function()
            print("Failed to download avatar image for SteamID: ", steamid64)
            if onFailed then onFailed("Failed to download avatar image for SteamID: ", steamid64) end
        end)
    end, function()
        print("Failed to fetch Steam profile for SteamID: ", steamid64)
        if onFailed then onFailed("Failed to fetch Steam profile for SteamID: ", steamid64) end
    end)

    return future_path
end