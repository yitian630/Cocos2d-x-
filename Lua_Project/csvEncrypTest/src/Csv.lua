local crypto = require ("framework.crypto")

local Csv = class("Csv" , function()
    return cc.Layer:create()
end)
path=cc.FileUtils:getInstance():getWritablePath()
cc.FileUtils:getInstance():addSearchResolutionsOrder("src")
cc.FileUtils:getInstance():addSearchResolutionsOrder("res")
Csv.__index = Csv

function Csv.create()
    local mainMenu = Csv.new()
    if mainMenu then
        mainMenu:init() 
    end
    return mainMenu
end
--读取csv文件
function loadCsvFile(filePath,keys) 

    -- 读取文件  
    local data = cc.FileUtils:getInstance():getStringFromFile(filePath)

    --[[即string.find()函数帮助我们查找该段字符串，并返回该段字符串出现的索引值
    这样我们就可以根据这个发现的结果截取字符串，来组成一个新的字符串
    string.sub(str,截取的开始位置，截取的结束位置，闭区间)
    表示从某处开始截取，到某处结束截取操作
    ]]--

    -- 按行划分  
    local lineStr = split(data, '\n\r');  
    --[[  
    从第2行开始保存（第一行是标题，后面的行才是内容）   

    用二维数组保存：arr[ID][属性标题字符串]  
    ]]  

    local titles = split(lineStr[1], ",");  
    local ID = 1;  
    local arrs = {};  
    for i = 2, #lineStr, 1 do  
        -- 一行中，每一列的内容  
        local content = split(lineStr[i], ",");  

        -- 以标题作为索引，保存每一列的内容，取值的时候这样取：arrs[1].Title  
        arrs[ID] = {};  
        for j = 1, #titles, 1 do  
            print("content[j]=="..content[j])
            -- 此处把每一行每一列内容都加密,"csv"为签名，在解密时要对应
            content[j] = crypto.encryptXXTEA(content[j],keys)
            arrs[ID][titles[j]] = content[j]  
        end  

        ID = ID + 1;  
    end  

    return #lineStr,#titles,titles,arrs;--行数，列数，标题table表，除标题外的table表  
end
--字符串分割功能
function split(str,reps) 
    local resultStrsList={} 
    string.gsub(str, '[^' .. reps ..']+', function(w) table.insert(resultStrsList, w) end )
    return resultStrsList 
end

local function get_file_name(str)
    str = str:match(".+/([^/]*%.%w+)$")
    local idx = str:match(".+()%.%w+$")
    if idx then
        return str:sub(1, idx-1)
    else
        return str
    end
end

-- 加密文件
function encrypCsvFile(filePath,putFilePath,keys)
    -- 文件名
    local filename = get_file_name(filePath)
    -- 输出路径
    local outpath = putFilePath.."/"..filename..".csv"
    local row,column,biaoti,csvConfig = loadCsvFile(filePath,keys)
    local f = io.open(outpath, "w")
    if f ~= nil then
        --do    
        for i = 1, column do
            if i ~= column then
                f:write(string.format("%s%s",biaoti[i],","))
            else
                f:write(string.format("%s",biaoti[i]))
                f:write(string.char(10))
            end
        end
        for j = 1, row-1 do
            for k = 1, column do      
                if(k ~=column)then
                    f:write(string.format("%s%s",csvConfig[j][biaoti[k]],","))
                else
                    f:write(string.format("%s",csvConfig[j][biaoti[k]]))
                    f:write(string.char(10))
                end
            end
        end
    end
    f:close()
end

return Csv