module("zen", package.seeall)

material = _GET("material")

material.iCounter = material.iCounter or 0

---@return number
function material.GetCounter()
    material.iCounter = material.iCounter + 1
    return material.iCounter
end


---@param material_path string
---@param color Color
---@return IMaterial
function material.GetMaterialModelColored(material_path, color)
    assert(type(material_path) == "string", "material_path must be a string")
    assert(IsColor(color), "color must be a valid Color")

    local mat_id = material.GetCounter()
    local new_math_name = string.format("%s_zen_%s", material_path, mat_id)
    local mat_default = Material(material_path)

    if !mat_default or mat_default:IsError() then
        error("Failed to load material: " .. tostring(material_path))
    end

    return CreateMaterial(new_math_name, mat_default:GetShader(), {
        ["$basetexture"] = mat_default:GetTexture("$basetexture"),
        ["$color2"] = "{" .. color.r .. " " .. color.g .. " " .. color.b .. "}",
    })
end