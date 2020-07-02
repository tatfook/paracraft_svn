--[[
Title: The kidsmovie database table for assets
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/db_assets.lua");
------------------------------------------------------------
]]
local L = CommonCtrl.Locale:new("KidsUI");

if(not ObjEditor) then ObjEditor={}; end
if(not kids_db) then kids_db={}; end
-- asset database
ObjEditor.assets = 
{
  [1] = {
  ["rootpath"] = "model/01建筑/",
  ["name"] = "建筑",
  icon = L"asset_icon_building",
  text = L"asset_text_building",
  tooltip = L"asset_tooltip_building",
}
,
  [2] = {
  ["rootpath"] = "model/02家具/",
  ["name"] = "家具",
  icon = L"asset_icon_furniture",
  text = L"asset_text_furniture",
  tooltip = L"asset_tooltip_furniture",
}
,
  [3] = {
  ["rootpath"] = "model/03生活/",
  ["name"] = "生活",
  icon = L"asset_icon_everyday",
  text = L"asset_text_everyday",
  tooltip = L"asset_tooltip_everyday",
}
,
  [4] = {
  ["rootpath"] = "model/04装饰/",
  ["name"] = "装饰",
  icon = L"asset_icon_makeup",
  text = L"asset_text_makeup",
  tooltip = L"asset_tooltip_makeup",  
}
,
  [5] = {
  ["rootpath"] = "model/05植物/",
  ["name"] = "花草",
  icon = L"asset_icon_grass",
  text = L"asset_text_grass",
  tooltip = L"asset_tooltip_grass",  
}
,
  [6] = {
  ["rootpath"] = "model/pops/",
  ["name"] = "杂物",
  icon = L"asset_icon_props",
  text = L"asset_text_props",
  tooltip = L"asset_tooltip_props",  
}
,
  [7] = {
  ["rootpath"] = "character/",
  ["name"] = "人物",
  icon = L"asset_icon_character",
  text = L"asset_text_character",
  tooltip = L"asset_tooltip_character",  
}
,
  [8] = {
  ["rootpath"] = "model/05植物/",
  ["name"] = "树木",
  icon = L"asset_icon_trees",
  text = L"asset_text_trees",
  tooltip = L"asset_tooltip_trees",  
}
,
  [9] = {
  ["rootpath"] = "model/06矿石/",
  ["name"] = "矿石",
}
,
  [10] = {
  ["rootpath"] = "model/test/",
  ["name"] = "测试",
}
,
  [11] = {
  ["rootpath"] = "model/others/terrain/",
  ["name"] = "地形",
}
,
  [12] = {
  ["rootpath"] = "model/others/light/",
  ["name"] = "灯光",
}
,
  [13] = {
  ["rootpath"] = "model/others/script/",
  ["name"] = "脚本",
}
,
  [14] = {
  ["rootpath"] = "model/test/",
  ["name"] = "test",
}
,
  [15] = {
  ["rootpath"] = "model/pops/",
  ["name"] = "pops",
}
,
}

-- item database
kids_db.items = 
{
  [1] = {
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"computer",
  ["ModelFilePath"] = "model/02家具/computer/computer.x",
  ["IconFilePath"] = "model/02家具/computer/computer.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"小床",
  ["ModelFilePath"] = "model/pops/xiaochuang.x",
  ["IconFilePath"] = "model/pops/xiaochuang.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"桌子",
  ["ModelFilePath"] = "model/pops/桌子1.x",
  ["IconFilePath"] = "model/pops/桌子1.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"石凳",
  ["ModelFilePath"] = "model/pops/石凳1.x",
  ["IconFilePath"] = "model/pops/石凳1.x.png",
}
,
}
,
  [2] = {
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"信箱",
  ["ModelFilePath"] = "model/03生活/信箱.x",
  ["IconFilePath"] = "model/03生活/信箱.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"木笼",
  ["ModelFilePath"] = "model/03生活/木头笼子.x",
  ["IconFilePath"] = "model/03生活/木头笼子.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"桶",
  ["ModelFilePath"] = "model/03生活/桶.x",
  ["IconFilePath"] = "model/03生活/桶.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"盘子",
  ["ModelFilePath"] = "model/03生活/盘子_a.x",
  ["IconFilePath"] = "model/03生活/盘子_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"罐子",
  ["ModelFilePath"] = "model/03生活/罐子.x",
  ["IconFilePath"] = "model/03生活/罐子.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"火堆",
  ["ModelFilePath"] = "model/04装饰/火堆1.x",
  ["IconFilePath"] = "model/04装饰/火堆1.x.png",
}
,
}
,
  [3] = {
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"地毯",
  ["ModelFilePath"] = "model/02家具/09地毯/地毯1.x",
  ["IconFilePath"] = "model/02家具/09地毯/地毯1.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"竹篮",
  ["ModelFilePath"] = "model/03生活/竹篮1.x",
  ["IconFilePath"] = "model/03生活/竹篮1.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"鼓",
  ["ModelFilePath"] = "model/04装饰/01乐器/鼓.x",
  ["IconFilePath"] = "model/04装饰/01乐器/鼓.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"气球",
  ["ModelFilePath"] = "model/04装饰/气球.x",
  ["IconFilePath"] = "model/04装饰/气球.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"稻草人",
  ["ModelFilePath"] = "model/04装饰/稻草人.x",
  ["IconFilePath"] = "model/04装饰/稻草人.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"鸟巢",
  ["ModelFilePath"] = "model/04装饰/鸟巢.x",
  ["IconFilePath"] = "model/04装饰/鸟巢.x.png",
}
,
}
,
  [4] = {
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"艳丽小花",
  ["ModelFilePath"] = "model/05植物/01花草/01花/小艳花1_a.x",
  ["IconFilePath"] = "model/05植物/01花草/01花/小艳花1_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"艳丽小花",
  ["ModelFilePath"] = "model/05植物/01花草/01花/小艳花3_a.x",
  ["IconFilePath"] = "model/05植物/01花草/01花/小艳花3_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"花草",
  ["ModelFilePath"] = "model/05植物/01花草/01花/花草5_a.x",
  ["IconFilePath"] = "model/05植物/01花草/01花/花草5_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"花草",
  ["ModelFilePath"] = "model/05植物/01花草/01花/花草8_a.x",
  ["IconFilePath"] = "model/05植物/01花草/01花/花草8_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"大蘑菇",
  ["ModelFilePath"] = "model/pops/大蘑菇4.x",
  ["IconFilePath"] = "model/pops/大蘑菇4.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"草",
  ["ModelFilePath"] = "model/pops/草_a.x",
  ["IconFilePath"] = "model/pops/草_a.x.png",
}
,
}
,
  [5] = {
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"箱子",
  ["ModelFilePath"] = "model/pops/箱子.x",
  ["IconFilePath"] = "model/pops/箱子.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"箱子",
  ["ModelFilePath"] = "model/pops/箱子4.x",
  ["IconFilePath"] = "model/pops/箱子4.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"草垛",
  ["ModelFilePath"] = "model/03生活/草垛.x",
  ["IconFilePath"] = "model/03生活/草垛.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"水井",
  ["ModelFilePath"] = "model/pops/水井.x",
  ["IconFilePath"] = "model/pops/水井.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"栅栏",
  ["ModelFilePath"] = "model/pops/栅栏.x",
  ["IconFilePath"] = "model/pops/栅栏.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"木桶",
  ["ModelFilePath"] = "model/pops/木桶.x",
  ["IconFilePath"] = "model/pops/木桶.x.png",
}
,
}
,
  [6] = {
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = "Eva",
  ["ModelFilePath"] = "character/human/Female/eva/eva1.x",
  ["IconFilePath"] = "character/human/Female/eva/eva1.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = "Baru",
  ["ModelFilePath"] = "character/human/Male/baru/baru.x",
  ["IconFilePath"] = "character/human/Male/baru/baru.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = "Dog",
  ["ModelFilePath"] = "character/dog/dog.x",
  ["IconFilePath"] = "character/dog/dog.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = "Fighter",
  ["ModelFilePath"] = "character/human/Male/fightermale/fighter.x",
  ["IconFilePath"] = "character/human/Male/fightermale/fighter.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"小鱼",
  ["ModelFilePath"] = "character/fish09/fish09.x",
  ["IconFilePath"] = "character/fish09/fish09.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"蝴蝶(动态)",
  ["ModelFilePath"] = "character/hudie16/hudie16.x",
  ["IconFilePath"] = "character/hudie16/hudie16.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"卡丁车",
  ["ModelFilePath"] = "character/kadingche/ka.x",
  ["IconFilePath"] = "character/kadingche/ka.x.png",
}
,
}
,
  [7] = {
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"椰子树",
  ["ModelFilePath"] = "model/05植物/03树/06椰子树/椰树_new1.x",
  ["IconFilePath"] = "model/05植物/03树/06椰子树/椰树_new1.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"树",
  ["ModelFilePath"] = "model/05植物/03树/01树/树11.x",
  ["IconFilePath"] = "model/05植物/03树/01树/树11.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"松树",
  ["ModelFilePath"] = "model/05植物/03树/04曲松/松树1.x",
  ["IconFilePath"] = "model/05植物/03树/04曲松/松树1.x.png",
}
,
}
,
  [0] = {
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"城镇中心",
  ["ModelFilePath"] = "model/01建筑/01房屋/城镇中心.x",
  ["IconFilePath"] = "model/01建筑/01房屋/城镇中心.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"市场",
  ["ModelFilePath"] = "model/01建筑/01房屋/市场 2.x",
  ["IconFilePath"] = "model/01建筑/01房屋/市场.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"民房1",
  ["ModelFilePath"] = "model/01建筑/01房屋/民房1.x",
  ["IconFilePath"] = "model/01建筑/01房屋/民房1.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"民房2",
  ["ModelFilePath"] = "model/01建筑/01房屋/民房2.x",
  ["IconFilePath"] = "model/01建筑/01房屋/民房2.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"马棚",
  ["ModelFilePath"] = "model/01建筑/01房屋/马棚.x",
  ["IconFilePath"] = "model/01建筑/01房屋/马棚.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"宠物屋",
  ["ModelFilePath"] = "model/03生活/宠物屋.x",
  ["IconFilePath"] = "model/03生活/宠物屋.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"shuiche",
  ["ModelFilePath"] = "model/pops/shuiche.x",
  ["IconFilePath"] = "model/pops/shuiche.x.png",
}
,
}
,
}