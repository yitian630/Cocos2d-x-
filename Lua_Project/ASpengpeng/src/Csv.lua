require "Cocos2d"
require "Cocos2dConstants"
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
function loadCsvFile(filePath) 
  
    -- 读取文件  
    local data = cc.FileUtils:getInstance():getStringFromFile(filePath);  
  
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
            arrs[ID][titles[j]] = content[j];  
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

--得到分数
function getGrade()
local tag = cc.FileUtils:getInstance():isFileExist(path.."Grade.csv")
    if tag == false then
        saveGrade(0)
    end
  local row,column,biaoti,csvConfig=loadCsvFile(path.."Grade.csv")
    local myGrade=csvConfig[1].value
     return myGrade
end
--得到当前分数
function getLevel()
local tag = cc.FileUtils:getInstance():isFileExist(path.."Level.csv")
    if tag == false then
        saveLevel(0)
    end
  local row,column,biaoti,csvConfig=loadCsvFile(path.."Level.csv")
    local mypresentGrade=csvConfig[1].value
     return mypresentGrade
end
--得到金币
function getGold()
   local tag = cc.FileUtils:getInstance():isFileExist(path.."Gold.csv")
    if tag == false then
        saveGold(0)
    end
  local row,column,biaoti,csvConfig=loadCsvFile(path.."Gold.csv")
    local myGold=csvConfig[1].value
     return myGold
end
--得到临时金币
function getCurrentGrade()
   local tag = cc.FileUtils:getInstance():isFileExist(path.."currentGrade.csv")
    if tag == false then
        saveCurrentGrade(0)
    end
  local row,column,biaoti,csvConfig=loadCsvFile(path.."currentGrade.csv")
    local myGold=csvConfig[1].value
     return myGold
end
--读取等级csv
function getNextLevelGold(i)
  local row,column,biaoti,csvConfig=loadCsvFile("upLevel.csv")
    local needExperience=csvConfig[i+1].value
     return needExperience
end

--获取音效值
function getEffect()
     local tag = cc.FileUtils:getInstance():isFileExist(path.."SoundEffect.csv")
     if tag == false then
        saveSoundEffect(1)
     end
  local row,column,biaoti,csvConfig=loadCsvFile(path.."SoundEffect.csv")
    local myEffect=csvConfig[1].value
     return myEffect
end
--获取音乐值
function getMusic()
     local tag = cc.FileUtils:getInstance():isFileExist(path.."SoundEffect.csv")
     if tag == false then
        saveSoundEffect(1)
     end
  local row,column,biaoti,csvConfig=loadCsvFile(path.."SoundEffect.csv")
    local myMusic=csvConfig[2].value
     return myMusic
end

--设置音效
function saveSoundEffect(c)
    -- body
     local row,column,biaoti,csvConfig=loadCsvFile("soundEffect.csv")
    myFile = io.open(path.."SoundEffect.csv","w")
    if(myFile ~= nil)then
            for i = 1, column do
                if i ~= column then
                    myFile:write(string.format("%s%s",biaoti[i],","))
                else
                    myFile:write(string.format("%s",biaoti[i]))
                    myFile:write(string.char(10))
                end
            end
            for j = 1, row-1 do
                for k = 1, column do
                    if (k==3) then                         
                          myFile:write(string.format("%s",c))  
                           myFile:write(string.char(10))        
                    elseif(k ~=column)then
                          myFile:write(string.format("%s%s",csvConfig[j][biaoti[k]],","))
                    else
                        myFile:write(string.format("%s",csvConfig[j][biaoti[k]]))
                        myFile:write(string.char(10))
                    end
                end
            end 
    end 
    io.close(myFile)
 end
 
 --设置音乐
function saveMusic(c)
    -- body
       local tag = cc.FileUtils:getInstance():isFileExist(path.."SoundEffect.csv")
     if tag == false then
        saveSoundEffect(1)
     end
     local row,column,biaoti,csvConfig=loadCsvFile(path.."SoundEffect.csv")
    myFile = io.open(path.."SoundEffect.csv","w")
    if(myFile ~= nil)then
            for i = 1, column do
                if i ~= column then
                    myFile:write(string.format("%s%s",biaoti[i],","))
                else
                    myFile:write(string.format("%s",biaoti[i]))
                    myFile:write(string.char(10))
                end
            end
            for j = 1, row-1 do
                for k = 1, column do
                        if (k==3) then                         
                               if(j==1) then
                               myFile:write(string.format("%s",csvConfig[j][biaoti[k]])) 
                              myFile:write(string.char(10))
                              elseif(j==2) then
                              myFile:write(string.format("%s",c))
                              myFile:write(string.char(10))
                             end        
                        elseif(k ~=column)then
                              myFile:write(string.format("%s%s",csvConfig[j][biaoti[k]],","))
                        else
                            myFile:write(string.format("%s",csvConfig[j][biaoti[k]]))
                            myFile:write(string.char(10))
                        end
                end
            end 
    end 
    io.close(myFile)
 end
 
--保存金币
function saveGold(c)
    -- body
     local row,column,biaoti,csvConfig=loadCsvFile("gold.csv")
    myFile = io.open(path.."Gold.csv","w")
    if(myFile ~= nil)then
            for i = 1, column do
                if i ~= column then
                    myFile:write(string.format("%s%s",biaoti[i],","))
                else
                    myFile:write(string.format("%s",biaoti[i]))
                    myFile:write(string.char(10))
                end
            end
            for j = 1, row-1 do
                for k = 1, column do
                    if (k==3) then                         
                          myFile:write(string.format("%s",c))  
                           myFile:write(string.char(10))        
                    elseif(k ~=column)then
                          myFile:write(string.format("%s%s",csvConfig[j][biaoti[k]],","))
                    else
                        myFile:write(string.format("%s",csvConfig[j][biaoti[k]]))
                        myFile:write(string.char(10))
                    end
                end
            end 
    end 
    io.close(myFile)
 end
 --保存当前金币
function saveCurrentGrade(c)
    -- body
     local row,column,biaoti,csvConfig=loadCsvFile("grade.csv")
    myFile = io.open(path.."currentGrade.csv","w")
    if(myFile ~= nil)then
            for i = 1, column do
                if i ~= column then
                    myFile:write(string.format("%s%s",biaoti[i],","))
                else
                    myFile:write(string.format("%s",biaoti[i]))
                    myFile:write(string.char(10))
                end
            end
            for j = 1, row-1 do
                for k = 1, column do
                    if (k==3) then                         
                          myFile:write(string.format("%s",c))  
                           myFile:write(string.char(10))        
                    elseif(k ~=column)then
                          myFile:write(string.format("%s%s",csvConfig[j][biaoti[k]],","))
                    else
                        myFile:write(string.format("%s",csvConfig[j][biaoti[k]]))
                        myFile:write(string.char(10))
                    end
                end
            end 
    end 
    io.close(myFile)
 end
 --保存分数
 function saveGrade(c)
    -- body
     local row,column,biaoti,csvConfig=loadCsvFile("grade.csv")
    myFile = io.open(path.."Grade.csv","w")
    if(myFile ~= nil)then
            for i = 1, column do
                if i ~= column then
                    myFile:write(string.format("%s%s",biaoti[i],","))
                else
                    myFile:write(string.format("%s",biaoti[i]))
                    myFile:write(string.char(10))
                end
            end
            for j = 1, row-1 do
                for k = 1, column do
                    if (k==3) then                         
                          myFile:write(string.format("%s",c))  
                           myFile:write(string.char(10))        
                    elseif(k ~=column)then
                          myFile:write(string.format("%s%s",csvConfig[j][biaoti[k]],","))
                    else
                        myFile:write(string.format("%s",csvConfig[j][biaoti[k]]))
                        myFile:write(string.char(10))
                    end
                end
            end
    end 
    io.close(myFile)
 end
 --保存当前分数
 function saveLevel(d)
    -- body
     local row,column,biaoti,csvConfig=loadCsvFile("level.csv")
    myFile = io.open(path.."Level.csv","w")
    if(myFile ~= nil)then
            for i = 1, column do
                if i ~= column then
                    myFile:write(string.format("%s%s",biaoti[i],","))
                else
                    myFile:write(string.format("%s",biaoti[i]))
                    myFile:write(string.char(10))
                end
            end
            for j = 1, row-1 do
                for k = 1, column do
                    if (k==3) then                         
                          myFile:write(string.format("%s",d))  
                           myFile:write(string.char(10))        
                    elseif(k ~=column)then
                          myFile:write(string.format("%s%s",csvConfig[j][biaoti[k]],","))
                    else
                        myFile:write(string.format("%s",csvConfig[j][biaoti[k]]))
                        myFile:write(string.char(10))
                    end
                end
            end
    end 
    io.close(myFile)
 end
--local function main()
--  path=cc.FileUtils:getInstance():getWritablePath()
--    cc.FileUtils:getInstance():addSearchResolutionsOrder("src")
--    cc.FileUtils:getInstance():addSearchResolutionsOrder("res")
--   row,column,biaoti,csvConfig=loadCsvFile("data.csv")--行数，列数，标题table表，除标题外的table表 
--   saveGoldAndGrade(200,1111111111)
--   saveSoundEffect(100)
--
--end


      
return Csv