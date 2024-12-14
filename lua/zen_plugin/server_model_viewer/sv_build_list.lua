module("zen", package.seeall)

---@param callback? fun()
local function BackupModels(callback)
    local _iCounterAll = 0

    local t_SpawnList = {}

    local t_Pathes = {"models/"}
    local path_index = 0

    print("Backup start")

    local _iStartSysTime = SysTime()

    local function OnSuccess()
        local t_Spawn = {
            parentid = 0,
            icon = "icon16/report_disk.png",
            id = 0,
            contents = t_SpawnList,
            name = "Fetched Models",
            version = 3
        }

        file.Write("models_backup.txt", util.TableToKeyValues(t_Spawn))

        if file.Exists("models_backup.txt", "DATA") then
            print("Saved backup to models_backup.txt")
        else
            print("Failed to save backup file")
        end

        if callback then
            callback()
        end
    end

    hook.Add("Tick", "zen_plugin.server_model_viewer", function()
        path_index = path_index + 1

        local path = t_Pathes[path_index]
        if !path then
            print("Backup end")
            print("Model ALL:  ", _iCounterAll)
            print("Time take: ", SysTime() - _iStartSysTime)

            hook.Remove("Tick", "zen_plugin.server_model_viewer")

            OnSuccess()

            return
        end

        local files = file.Find(path .. "*.mdl", "GAME")
        if files then
            for _, v in pairs(files) do
                local mdl = path .. v

                _iCounterAll = _iCounterAll + 1

                table.insert(t_SpawnList, {
                    model = mdl,
                    type = "model"
                })

            end
        end

        local _, folders = file.Find(path .. "*", "GAME")
        if folders then
            for k, v in ipairs(folders) do
                table.insert(t_Pathes, path .. v .. "/")
            end
        end
    end)
end

/*
if !_L.ModelBackped then
    BackupModels(function()
        _L.ModelBackped = true
    end)
end
*/