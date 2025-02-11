-- Using lua to parse CSV file to a table.

local error = error
local setmetatable = setmetatable
local lines = io.lines
local insert = table.insert
local concat = table.concat
local ipairs = ipairs
local string = string
local print = print
local tonumber = tonumber

module(...)

string.split = function(str, pattern)
    local tb = {}
    local s = 1
    local e = 1
    while true do
        s,e = str:find(",", 1, true)
        if not s then
            break
        end
        local sub = str:sub(1, s-1)
        str = str:sub(e+1)
        insert(tb, sub)
    end

    return tb
end
-- 返回标题table
local function parse_title(title, sep)
    local desc = title:split("[^" .. sep .. "]+")
    local class_mt = {}
    for k, v in ipairs(desc) do
        class_mt[v] = k
    end
    return class_mt
end

local function parse_line(mt, line, sep)
    local data = line:split("[^" .. sep .. "]+")
    setmetatable(data, mt)
    return data
end

local function trim_right(line)
    return line:gsub("%s+$", "")
end

local function make_line_end(line)
    if line:sub(-1)~=',' then
        line = line .. ","
    end

    return line
end

function load(path, sep)
    local tag, sep, mt, data = false, sep or '|', nil, {}
    local i = 1
    local keys = {}
    local attrs = {}
    local last_key = nil
    local info = ""

    for line in lines(path) do
        line = make_line_end( trim_right(line) )
        if i==1 then
            if not tag then
                tag = true
                mt = parse_title(line, sep)
                mt.__index = function(t, k) if mt[k] then return t[mt[k]] else return nil end end
                mt.__newindex = function(t, k, v) error('attempt to write to undeclare variable "' .. k .. '"') end
            end
            -- get keys 标题table
            keys = parse_line(mt, line, sep)
            for k,v in ipairs(keys) do
                if v == "ID" then
                    --do
                    if attrs[v] then
                        info = "too many " .. v
                        return nil, info
                    end
                    attrs[v] = k
                end
            end
        elseif i>1 then      
            if not attrs.ID then
                info = "no ID"
                return nil, info
            end

            if attrs.ID then
                info = "ID: " .. keys[attrs.ID]
            end

            local tvalue = parse_line(mt, line, sep)
            local row = {}
            for k,v in ipairs(tvalue) do
                local key = keys[k]
                if key and #key>=2 then
                    row[key] = v
                end
            end
            if attrs.ID then
                -- single key
                local kidx = attrs.ID
                local kv = tvalue[kidx]
                if not tonumber(kv) then
                    -- random configure type
                    kv = last_key
                    row[keys[kidx]] = kv
                else
                    last_key = kv
                end
                -- table表格式不同
                -- data[kv] = data[kv] or {}
                -- insert(data[kv], row)
                insert(data, row)
            end
        end
        i = i+1
    end
    return data, info
end

local class_mt = {
    __newindex = function(t, k, v)
        error('attempt to write to undeclare variable "' .. k .. '"')
    end
}

setmetatable(_M, class_mt)
