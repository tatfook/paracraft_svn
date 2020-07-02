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
  ["rootpath"] = "model/01building/",
  ["name"] = "建筑",
  icon = L"asset_icon_building",
  text = L"asset_text_building",
  tooltip = L"asset_tooltip_building",
}
,
  [2] = {
  ["rootpath"] = "model/02furniture/",
  ["name"] = "家具",
  icon = L"asset_icon_furniture",
  text = L"asset_text_furniture",
  tooltip = L"asset_tooltip_furniture",
}
,
  [3] = {
  ["rootpath"] = "model/03tools/",
  ["name"] = "生活",
  icon = L"asset_icon_everyday",
  text = L"asset_text_everyday",
  tooltip = L"asset_tooltip_everyday",
}
,
  [4] = {
  ["rootpath"] = "model/04deco/",
  ["name"] = "装饰",
  icon = L"asset_icon_makeup",
  text = L"asset_text_makeup",
  tooltip = L"asset_tooltip_makeup",  
}
,
  [5] = {
  ["rootpath"] = "model/05plants/",
  ["name"] = "花草",
  icon = L"asset_icon_grass",
  text = L"asset_text_grass",
  tooltip = L"asset_tooltip_grass",  
}
,
  [6] = {
  ["rootpath"] = "model/06props/",
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
  ["rootpath"] = "model/05plants/",
  ["name"] = "树木",
  icon = L"asset_icon_trees",
  text = L"asset_text_trees",
  tooltip = L"asset_tooltip_trees",  
}
,
  [9] = {
  ["rootpath"] = "model/06props/",
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
  ["rootpath"] = "model/06props/",
  ["name"] = "props",
}
,
  [16] = {
  ["rootpath"] = "model/",
  ["name"] = "MODEL",
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
  ["Price"]=0,
  ["IconAssetName"] = L"小床",
  ["ModelFilePath"] = "model/06props/shared/pops/xiaochuang.x",
  ["IconFilePath"] = "model/06props/shared/pops/xiaochuang.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"桌子",
  ["ModelFilePath"] = "model/06props/shared/pops/桌子1.x",
  ["IconFilePath"] = "model/06props/shared/pops/桌子1.x.png",
}
,
 {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"桌子",
  ["ModelFilePath"] = "model/02furniture/v1/glasstable.x",
  ["IconFilePath"] = "model/02furniture/v1/glasstable.x.png",
}
,
 {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"石凳",
  ["ModelFilePath"] = "model/06props/shared/pops/石凳1.x",
  ["IconFilePath"] = "model/06props/shared/pops/石凳1.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"长椅",
  ["ModelFilePath"] = "model/06props/v1/chair/chair.x",
  ["IconFilePath"] = "model/06props/v1/chair/chair.x.png",
}
,
{
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"长椅",
  ["ModelFilePath"] = "model/02furniture/v1/chair.x",
  ["IconFilePath"] = "model/02furniture/v1/chair.x.png",
}
,
{
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"长椅",
  ["ModelFilePath"] = "model/02furniture/v1/chair2.x",
  ["IconFilePath"] = "model/02furniture/v1/chair2.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"垃圾桶",
  ["ModelFilePath"] = "model/06props/v1/garbagecan/garbagecan.x",
  ["IconFilePath"] = "model/06props/v1/garbagecan/garbagecan.x.png",
}
,
{
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"电视机",
  ["ModelFilePath"] = "model/02furniture/v1/tv/tv.x",
  ["IconFilePath"] = "model/02furniture/v1/tv/tv.x.png",
}
,
{
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"微波炉",
  ["ModelFilePath"] = "model/02furniture/v1/weibolu/weibolu.x",
  ["IconFilePath"] = "model/02furniture/v1/weibolu/weibolu.x.png",
}
,
{
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"计算机",
  ["ModelFilePath"] = "model/02furniture/v1/computer/computer.x",
  ["IconFilePath"] = "model/02furniture/v1/computer/computer.x.png",
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
  ["Price"]=0,
  ["IconAssetName"] = L"宠物屋",
  ["ModelFilePath"] = "model/01building/v1/02other/doghouse/宠物屋.x",
  ["IconFilePath"] = "model/01building/v1/02other/doghouse/宠物屋.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"茅草亭",
  ["ModelFilePath"] = "model/06props/shared/pops/maocaoting.x",
  ["IconFilePath"] = "model/06props/shared/pops/maocaoting.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"水井",
  ["ModelFilePath"] = "model/06props/shared/pops/水井.x",
  ["IconFilePath"] = "model/06props/shared/pops/水井.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"信箱",
  ["ModelFilePath"] = "model/03tools/v1/post/信箱.x",
  ["IconFilePath"] = "model/03tools/v1/post/信箱.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"木笼",
  ["ModelFilePath"] = "model/06props/v1/woodcage/木头笼子.x",
  ["IconFilePath"] = "model/06props/v1/woodcage/木头笼子.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"桶",
  ["ModelFilePath"] = "model/06props/v1/barrel/桶.x",
  ["IconFilePath"] = "model/06props/v1/barrel/桶.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"瓶子",
  ["ModelFilePath"] = "model/06props/v1/wases/瓶子_a.x",
  ["IconFilePath"] = "model/06props/v1/wases/瓶子_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"盘子",
  ["ModelFilePath"] = "model/06props/v1/dish/盘子_a.x",
  ["IconFilePath"] = "model/06props/v1/dish/盘子_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"碗",
  ["ModelFilePath"] = "model/06props/v1/bowl/碗_a.x",
  ["IconFilePath"] = "model/06props/v1/bowl/碗_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"木桶",
  ["ModelFilePath"] = "model/06props/shared/pops/木桶.x",
  ["IconFilePath"] = "model/06props/shared/pops/木桶.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"木桶",
  ["ModelFilePath"] = "model/06props/shared/pops/木桶2.x",
  ["IconFilePath"] = "model/06props/shared/pops/木桶2.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"桶",
  ["ModelFilePath"] = "model/06props/shared/pops/桶.x",
  ["IconFilePath"] = "model/06props/shared/pops/桶.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"箱子",
  ["ModelFilePath"] = "model/06props/shared/pops/xiangzi1.x",
  ["IconFilePath"] = "model/06props/shared/pops/xiangzi1.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"箱子",
  ["ModelFilePath"] = "model/06props/shared/pops/xiangzi2.x",
  ["IconFilePath"] = "model/06props/shared/pops/xiangzi2.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"箱子",
  ["ModelFilePath"] = "model/06props/shared/pops/xiangzi3.x",
  ["IconFilePath"] = "model/06props/shared/pops/xiangzi3.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"箱子",
  ["ModelFilePath"] = "model/06props/shared/pops/箱子.x",
  ["IconFilePath"] = "model/06props/shared/pops/箱子.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"箱子",
  ["ModelFilePath"] = "model/06props/shared/pops/箱子2.x",
  ["IconFilePath"] = "model/06props/shared/pops/箱子2.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"箱子",
  ["ModelFilePath"] = "model/06props/shared/pops/箱子3.x",
  ["IconFilePath"] = "model/06props/shared/pops/箱子3.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"箱子",
  ["ModelFilePath"] = "model/06props/shared/pops/箱子4.x",
  ["IconFilePath"] = "model/06props/shared/pops/箱子4.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"码头",
  ["ModelFilePath"] = "model/01building/v1/01house/码头2.x",
  ["IconFilePath"] = "model/01building/v1/01house/码头2.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"绳子",
  ["ModelFilePath"] = "model/06props/v1/rope/绳子1_a.x",
  ["IconFilePath"] = "model/06props/v1/rope/绳子1_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"绳子",
  ["ModelFilePath"] = "model/06props/v1/rope/绳子2_a.x",
  ["IconFilePath"] = "model/06props/v1/rope/绳子2_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"小舟",
  ["ModelFilePath"] = "model/03tools/v1/bateau/小舟.x",
  ["IconFilePath"] = "model/03tools/v1/bateau/小舟.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"船浆",
  ["ModelFilePath"] = "model/03tools/v1/bateau/小舟船浆.x",
  ["IconFilePath"] = "model/03tools/v1/bateau/小舟船浆.x.png",
}
,
 {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"海盗船",
  ["ModelFilePath"] = "model/03tools/v1/ship/Pirate ship_v.x",
  ["IconFilePath"] = "model/03tools/v1/ship/Pirate ship_v.x.png",
}
,
{
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"帆船",
  ["ModelFilePath"] = "model/03tools/v1/fanchuan/帆船_v.x",
  ["IconFilePath"] = "model/03tools/v1/fanchuan/帆船_v.x.png",
}
,
}
,
  [3] = {
{
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.3",
  ["Reserved2"] = "1.2",
  ["Price"]=0,
  ["IconAssetName"] = L"旗子",
  ["ModelFilePath"] = "model/06props/shared/pops/flag_a.x",
  ["IconFilePath"] = "model/06props/shared/pops/flag_a.x.png",
}
,
{
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"云彩",
  ["ModelFilePath"] = "model/02furniture/v1/yun/yun.x",
  ["IconFilePath"] = "model/02furniture/v1/yun/yun.x.png",
}
,
{
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"路灯",
  ["ModelFilePath"] = "model/06props/shared/pops/路灯1.x",
  ["IconFilePath"] = "model/06props/shared/pops/路灯1.x.png",
}
,
{
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.3",
  ["Reserved2"] = "1.2",
  ["Price"]=10,
  ["IconAssetName"] = L"灯笼",
  ["ModelFilePath"] = "model/06props/shared/pops/灯笼.x",
  ["IconFilePath"] = "model/06props/shared/pops/灯笼.x.png",
}
,
{
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.3",
  ["Reserved2"] = "1.2",
  ["Price"]=10,
  ["IconAssetName"] = L"传送站",
  ["ModelFilePath"] = "model/06props/shared/pops/传送站.x",
  ["IconFilePath"] = "model/06props/shared/pops/传送站.x.png",
}
,
{
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.3",
  ["Reserved2"] = "1.2",
  ["Price"]=10,
  ["IconAssetName"] = L"喷泉",
  ["ModelFilePath"] = "model/06props/shared/pops/喷泉.x",
  ["IconFilePath"] = "model/06props/shared/pops/喷泉.x.png",
}
,
{
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"烤鸡",
  ["ModelFilePath"] = "model/06props/v1/kaoji/kaoji.x",
  ["IconFilePath"] = "model/06props/v1/kaoji/kaoji.x.png",
}
,
{
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"烤羊",
  ["ModelFilePath"] = "model/06props/v1/kaoyang/ARRUIL.x",
  ["IconFilePath"] = "model/06props/v1/kaoyang/ARRUIL.x.png",
}
,
{
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"篝火",
  ["ModelFilePath"] = "model/06props/shared/fire/fire_p.x",
  ["IconFilePath"] = "model/06props/shared/fire/fire_p.x.png",
}
,
 {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"火堆",
  ["ModelFilePath"] = "model/06props/shared/pops/火堆1.x",
  ["IconFilePath"] = "model/06props/shared/pops/火堆1.x.png",
}
,
 {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"气球",
  ["ModelFilePath"] = "model/06props/v1/balloon/气球.x",
  ["IconFilePath"] = "model/06props/v1/balloon/气球.x.png",
}
,
{
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.3",
  ["Reserved2"] = "1.2",
  ["Price"]=10,
  ["IconAssetName"] = L"方向牌",
  ["ModelFilePath"] = "model/06props/shared/pops/方向牌.x",
  ["IconFilePath"] = "model/06props/shared/pops/方向牌.x.png",
}
,
 {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = "board 画板",--TODO
  ["ModelFilePath"] = "model/06props/shared/pops/Instructions.x",
  ["IconFilePath"] = "model/06props/shared/pops/Instructions.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = "board 画板",--TODO
  ["ModelFilePath"] = "model/06props/shared/pops/guanggaopai.x",
  ["IconFilePath"] = "model/06props/shared/pops/guanggaopai.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = "board 画板",--TODO
  ["ModelFilePath"] = "model/06props/shared/pops/huaban.x",
  ["IconFilePath"] = "model/06props/shared/pops/huaban.x.png",
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
  ["Price"]=0,
  ["IconAssetName"] = L"绿色灌木",
  ["ModelFilePath"] = "model/05plants/01flower/03grass/草1_a_v.x",
  ["IconFilePath"] = "model/05plants/01flower/03grass/草1_a_v.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"绿色灌木",
  ["ModelFilePath"] = "model/05plants/03shrub/绿色灌木1_a.x",
  ["IconFilePath"] = "model/05plants/03shrub/绿色灌木1_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"绿色灌木",
  ["ModelFilePath"] = "model/05plants/03shrub/绿色灌木2_a.x",
  ["IconFilePath"] = "model/05plants/03shrub/绿色灌木2_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"绿色灌木",
  ["ModelFilePath"] = "model/05plants/03shrub/绿色灌木3_a.x",
  ["IconFilePath"] = "model/05plants/03shrub/绿色灌木3_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"大蘑菇",
  ["ModelFilePath"] = "model/05plants/04other/大蘑菇1.x",
  ["IconFilePath"] = "model/05plants/04other/大蘑菇1.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"大蘑菇",
  ["ModelFilePath"] = "model/05plants/04other/大蘑菇2.x",
  ["IconFilePath"] = "model/05plants/04other/大蘑菇2.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"大蘑菇",
  ["ModelFilePath"] = "model/05plants/04other/大蘑菇3.x",
  ["IconFilePath"] = "model/05plants/04other/大蘑菇3.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"大蘑菇",
  ["ModelFilePath"] = "model/05plants/04other/大蘑菇4.x",
  ["IconFilePath"] = "model/05plants/04other/大蘑菇4.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"草",
  ["ModelFilePath"] = "model/05plants/01flower/01flower/flower001_a_v.x",
  ["IconFilePath"] = "model/05plants/01flower/01flower/flower001_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"草",
  ["ModelFilePath"] = "model/05plants/01flower/01flower/flower002_a_v.x",
  ["IconFilePath"] = "model/05plants/01flower/01flower/flower002_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"草",
  ["ModelFilePath"] = "model/05plants/01flower/01flower/flower003_a_v.x",
  ["IconFilePath"] = "model/05plants/01flower/01flower/flower003_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"草",
  ["ModelFilePath"] = "model/05plants/01flower/01flower/flower004_a_v.x",
  ["IconFilePath"] = "model/05plants/01flower/01flower/flower004_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"草",
  ["ModelFilePath"] = "model/05plants/01flower/01flower/flower005_a_v.x",
  ["IconFilePath"] = "model/05plants/01flower/01flower/flower005_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"草",
  ["ModelFilePath"] = "model/05plants/01flower/01flower/flower006_a_v.x",
  ["IconFilePath"] = "model/05plants/01flower/01flower/flower006_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"草",
  ["ModelFilePath"] = "model/05plants/01flower/01flower/flower007_a_v.x",
  ["IconFilePath"] = "model/05plants/01flower/01flower/flower007_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"草",
  ["ModelFilePath"] = "model/05plants/01flower/01flower/flower008_a_v.x",
  ["IconFilePath"] = "model/05plants/01flower/01flower/flower008_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"草",
  ["ModelFilePath"] = "model/05plants/01flower/01flower/flower009_a_v.x",
  ["IconFilePath"] = "model/05plants/01flower/01flower/flower009_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"草",
  ["ModelFilePath"] = "model/05plants/01flower/01flower/flower009b_a_v.x",
  ["IconFilePath"] = "model/05plants/01flower/01flower/flower009b_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"草",
  ["ModelFilePath"] = "model/05plants/01flower/01flower/flower009c_a_v.x",
  ["IconFilePath"] = "model/05plants/01flower/01flower/flower009c_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"草",
  ["ModelFilePath"] = "model/05plants/01flower/01flower/flower010_a_v.x",
  ["IconFilePath"] = "model/05plants/01flower/01flower/flower010_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"草",
  ["ModelFilePath"] = "model/05plants/01flower/01flower/flower011_a_v.x",
  ["IconFilePath"] = "model/05plants/01flower/01flower/flower011_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"草",
  ["ModelFilePath"] = "model/05plants/01flower/01flower/flower012_a_v.x",
  ["IconFilePath"] = "model/05plants/01flower/01flower/flower012_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"草",
  ["ModelFilePath"] = "model/05plants/01flower/01flower/flower013_a_v.x",
  ["IconFilePath"] = "model/05plants/01flower/01flower/flower013_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"花草",
  ["ModelFilePath"] = "model/05plants/01flower/02flower/花草11_a.x",
  ["IconFilePath"] = "model/05plants/01flower/02flower/花草11_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"花草",
  ["ModelFilePath"] = "model/05plants/01flower/02flower/花草12_a.x",
  ["IconFilePath"] = "model/05plants/01flower/02flower/花草12_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"花草",
  ["ModelFilePath"] = "model/05plants/01flower/02flower/花草13.x",
  ["IconFilePath"] = "model/05plants/01flower/02flower/花草13.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"花草",
  ["ModelFilePath"] = "model/05plants/01flower/02flower/花草15_a.x",
  ["IconFilePath"] = "model/05plants/01flower/02flower/花草15_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"花草",
  ["ModelFilePath"] = "model/05plants/01flower/02flower/花草28_a.x",
  ["IconFilePath"] = "model/05plants/01flower/02flower/花草28_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"花草",
  ["ModelFilePath"] = "model/05plants/01flower/02flower/花草30_a.x",
  ["IconFilePath"] = "model/05plants/01flower/02flower/花草30_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"花草群",
  ["ModelFilePath"] = "model/05plants/01flower/02flower/花草群1_a.x",
  ["IconFilePath"] = "model/05plants/01flower/02flower/花草群1_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"花草群",
  ["ModelFilePath"] = "model/05plants/01flower/02flower/花草群2_a.x",
  ["IconFilePath"] = "model/05plants/01flower/02flower/花草群2_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"花草群",
  ["ModelFilePath"] = "model/05plants/01flower/02flower/花草群4_a.x",
  ["IconFilePath"] = "model/05plants/01flower/02flower/花草群4_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"花草群",
  ["ModelFilePath"] = "model/05plants/01flower/02flower/花草群8_a.x",
  ["IconFilePath"] = "model/05plants/01flower/02flower/花草群8_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"花草群",
  ["ModelFilePath"] = "model/05plants/01flower/02flower/花草群9_a.x",
  ["IconFilePath"] = "model/05plants/01flower/02flower/花草群9_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"草",
  ["ModelFilePath"] = "model/05plants/01flower/02flower/花草19_a.x",
  ["IconFilePath"] = "model/05plants/01flower/02flower/花草19_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"草",
  ["ModelFilePath"] = "model/05plants/01flower/02flower/花草20_a.x",
  ["IconFilePath"] = "model/05plants/01flower/02flower/花草20_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"仙人掌",
  ["ModelFilePath"] = "model/05plants/03shrub/xianrenzhang/仙人掌01_a.x",
  ["IconFilePath"] = "model/05plants/03shrub/xianrenzhang/仙人掌01_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"仙人掌",
  ["ModelFilePath"] = "model/05plants/03shrub/xianrenzhang/仙人掌14_a.x",
  ["IconFilePath"] = "model/05plants/03shrub/xianrenzhang/仙人掌14_a.x.png",
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
  ["Price"]=0,
  ["IconAssetName"] = L"围栏",
  ["ModelFilePath"] = "model/06props/shared/pops/weilan.x",
  ["IconFilePath"] = "model/06props/shared/pops/weilan.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"围栏",
  ["ModelFilePath"] = "model/06props/shared/pops/weilan4.x",
  ["IconFilePath"] = "model/06props/shared/pops/weilan4.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"围栏",
  ["ModelFilePath"] = "model/06props/shared/pops/weilan5.x",
  ["IconFilePath"] = "model/06props/shared/pops/weilan5.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"围栏",
  ["ModelFilePath"] = "model/06props/shared/pops/weilan6.x",
  ["IconFilePath"] = "model/06props/shared/pops/weilan6.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"栅栏",
  ["ModelFilePath"] = "model/06props/shared/pops/栅栏.x",
  ["IconFilePath"] = "model/06props/shared/pops/栅栏.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"栅栏",
  ["ModelFilePath"] = "model/06props/shared/pops/栅栏3.x",
  ["IconFilePath"] = "model/06props/shared/pops/栅栏3.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"栅栏",
  ["ModelFilePath"] = "model/06props/shared/pops/栅栏4.x",
  ["IconFilePath"] = "model/06props/shared/pops/栅栏4.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"栅栏",
  ["ModelFilePath"] = "model/06props/shared/pops/栅栏5.x",
  ["IconFilePath"] = "model/06props/shared/pops/栅栏5.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"石头",
  ["ModelFilePath"] = "model/06props/shared/01stone/shitou2.x",
  ["IconFilePath"] = "model/06props/shared/01stone/shitou2.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"石头",
  ["ModelFilePath"] = "model/06props/shared/01stone/shitou3.x",
  ["IconFilePath"] = "model/06props/shared/01stone/shitou3.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"石头",
  ["ModelFilePath"] = "model/06props/shared/pops/shitou1.x",
  ["IconFilePath"] = "model/06props/shared/pops/shitou1.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"大围栏石",
  ["ModelFilePath"] = "model/06props/shared/01stone/大围栏石1.x",
  ["IconFilePath"] = "model/06props/shared/01stone/大围栏石1.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"大围栏石",
  ["ModelFilePath"] = "model/06props/shared/01stone/大围栏石2.x",
  ["IconFilePath"] = "model/06props/shared/01stone/大围栏石2.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"大围栏石",
  ["ModelFilePath"] = "model/06props/shared/01stone/大围栏石3.x",
  ["IconFilePath"] = "model/06props/shared/01stone/大围栏石3.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"小围栏石",
  ["ModelFilePath"] = "model/06props/shared/01stone/小围栏石2.x",
  ["IconFilePath"] = "model/06props/shared/01stone/小围栏石2.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"小围栏石",
  ["ModelFilePath"] = "model/06props/shared/01stone/小围栏石3.x",
  ["IconFilePath"] = "model/06props/shared/01stone/小围栏石3.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"石头",
  ["ModelFilePath"] = "model/06props/shared/01stone/shitou.x",
  ["IconFilePath"] = "model/06props/shared/01stone/shitou.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"喷泉",
  ["ModelFilePath"] = "model/06props/shared/penquan/penquan_t_d_a.x",
  ["IconFilePath"] = "model/06props/shared/penquan/penquan_t_d_a.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"马车拖车",
  ["ModelFilePath"] = "model/03tools/v1/dragcar/马车的拖车载货.x",
  ["IconFilePath"] = "model/03tools/v1/dragcar/马车的拖车载货.x.png",
}
,
}
,
  [6] = {
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.3",
  ["Reserved2"] = "1.2",
  ["Price"]=0,
  ["IconAssetName"] = L"青蛙",
  ["ModelFilePath"] = "character/v1/02animals/01land/guagua/guagua.x",
  ["IconFilePath"] = "character/v1/02animals/01land/guagua/guagua.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.3",
  ["Reserved2"] = "1.2",
  ["Price"]=0,
  ["IconAssetName"] = L"蜘蛛",
  ["ModelFilePath"] = "character/v1/02animals/01land/chengcheng/cheng.x",
  ["IconFilePath"] = "character/v1/02animals/01land/chengcheng/cheng.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.3",
  ["Reserved2"] = "1.2",
  ["Price"]=10,
  ["IconAssetName"] = L"小狗",
  ["ModelFilePath"] = "character/v1/02animals/01land/chevalier/chevalier.x",
  ["IconFilePath"] = "character/v1/02animals/01land/chevalier/chevalier.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.3",
  ["Reserved2"] = "1.2",
  ["Price"]=10,
  ["IconAssetName"] = L"小猪",
  ["ModelFilePath"] = "character/v1/02animals/01land/luobin/luobin.x",
  ["IconFilePath"] = "character/v1/02animals/01land/luobin/luobin.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.3",
  ["Reserved2"] = "1.2",
  ["Price"]=0,
  ["IconAssetName"] = L"蛇",
  ["ModelFilePath"] = "character/v1/02animals/01land/snake/snake.x",
  ["IconFilePath"] = "character/v1/02animals/01land/snake/snake.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.3",
  ["Reserved2"] = "1.2",
  ["Price"]=50,
  ["IconAssetName"] = L"松鼠",
  ["ModelFilePath"] = "character/v1/02animals/01land/songshu/shongshu.x",
  ["IconFilePath"] = "character/v1/02animals/01land/songshu/shongshu.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.3",
  ["Reserved2"] = "1.2",
  ["Price"]=0,
  ["IconAssetName"] = L"蜗牛",
  ["ModelFilePath"] = "character/v1/02animals/01land/woniu/woniu.x",
  ["IconFilePath"] = "character/v1/02animals/01land/woniu/woniu.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.3",
  ["Reserved2"] = "1.2",
  ["Price"]=50,
  ["IconAssetName"] = L"蝎子",
  ["ModelFilePath"] = "character/v1/02animals/01land/xiezi/xiezi.x",
  ["IconFilePath"] = "character/v1/02animals/01land/xiezi/xiezi.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.3",
  ["Reserved2"] = "1.2",
  ["Price"]=50,
  ["IconAssetName"] = L"龙",
  ["ModelFilePath"] = "character/v1/01human/long/long.x",
  ["IconFilePath"] = "character/v1/01human/long/long.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.3",
  ["Reserved2"] = "1.2",
  ["Price"]=10,
  ["IconAssetName"] = L"Eva",
  ["ModelFilePath"] = "character/v1/01human/eva/eva1.x",
  ["IconFilePath"] = "character/v1/01human/eva/eva1.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.3",
  ["Reserved2"] = "1.2",
  ["Price"]=50,
  ["IconAssetName"] = L"玛丽亚",
  ["ModelFilePath"] = "character/v1/01human/erluoshi/erluoshi.x",
  ["IconFilePath"] = "character/v1/01human/erluoshi/erluoshi.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.3",
  ["Reserved2"] = "1.2",
  ["Price"]=10,
  ["IconAssetName"] = L"丹尼",
  ["ModelFilePath"] = "character/v1/01human/danni/danni.x",
  ["IconFilePath"] = "character/v1/01human/danni/danni.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.3",
  ["Reserved2"] = "1.2",
  ["Price"]=0,
  ["IconAssetName"] = L"baru",
  ["ModelFilePath"] = "character/v1/01human/baru/baru.x",
  ["IconFilePath"] = "character/v1/01human/baru/baru.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"男孩",
  ["ModelFilePath"] = "character/v1/01human/boy/boy.x",
  ["IconFilePath"] = "character/v1/01human/boy/boy.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"小狗",
  ["ModelFilePath"] = "character/v1/02animals/01land/dog/dog.x",
  ["IconFilePath"] = "character/v1/02animals/01land/dog/dog.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"女孩",
  ["ModelFilePath"] = "character/v1/01human/girl/girl.x",
  ["IconFilePath"] = "character/v1/01human/girl/girl.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"小牛",
  ["ModelFilePath"] = "character/v1/02animals/01land/niu/niu.x",
  ["IconFilePath"] = "character/v1/02animals/01land/niu/niu.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"小猪",
  ["ModelFilePath"] = "character/v1/02animals/01land/pigmen/pig.x",
  ["IconFilePath"] = "character/v1/02animals/01land/pigmen/pig.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"兔子",
  ["ModelFilePath"] = "character/v1/02animals/01land/cony1/cony1.x",
  ["IconFilePath"] = "character/v1/02animals/01land/cony1/cony1.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"小猫",
  ["ModelFilePath"] = "character/v1/02animals/01land/cat/cat.x",
  ["IconFilePath"] = "character/v1/02animals/01land/cat/cat.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"小鱼",
  ["ModelFilePath"] = "character/v1/02animals/03sea/fish/fish01.x",
  ["IconFilePath"] = "character/v1/02animals/03sea/fish/fish01.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"小鱼",
  ["ModelFilePath"] = "character/v1/02animals/03sea/fish04/fish04.x",
  ["IconFilePath"] = "character/v1/02animals/03sea/fish04/fish04.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"小鱼",
  ["ModelFilePath"] = "character/v1/02animals/03sea/fish05/fish05.x",
  ["IconFilePath"] = "character/v1/02animals/03sea/fish05/fish05.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"海星",
  ["Price"]=0,
  ["ModelFilePath"] = "character/v1/02animals/03sea/haixing03/haixing03.x",
  ["IconFilePath"] = "character/v1/02animals/03sea/haixing03/haixing03.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["IconAssetName"] = L"蝴蝶",
  ["Price"]=0,
  ["ModelFilePath"] = "character/v1/02animals/02fly/hudie01/hudie01.x",
  ["IconFilePath"] = "character/v1/02animals/02fly/hudie01/hudie01.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.3",
  ["Reserved2"] = "1.2",
  ["Price"]=50,
  ["IconAssetName"] = L"宝箱",
  ["ModelFilePath"] = "character/v1/06other/baoxiang/baoxiang.x",
  ["IconFilePath"] = "character/v1/06other/baoxiang/baoxiang.x.png",
}
,
{
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.3",
  ["Reserved2"] = "1.2",
  ["Price"]=50,
  ["IconAssetName"] = L"秋千",
  ["ModelFilePath"] = "character/v1/03vehicles/01land/qiuqian/qiuqian.x",
  ["IconFilePath"] = "character/v1/03vehicles/01land/qiuqian/qiuqian.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "1",
  ["Reserved2"] = "0.2",
  ["IconAssetName"] = L"直升机",
  ["Price"]=0,
  ["ModelFilePath"] = "character/v1/03vehicles/02fly/heli/heli01.x",
  ["IconFilePath"] = "character/v1/03vehicles/02fly/heli/heli01.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"卡丁车",
  ["ModelFilePath"] = "character/v1/03vehicles/01land/kadingche/ka.x",
  ["IconFilePath"] = "character/v1/03vehicles/01land/kadingche/ka.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.5",
  ["Reserved2"] = "0.3",
  ["Price"]=10,
  ["IconAssetName"] = L"帆船",
  ["ModelFilePath"] = "character/v1/03vehicles/03sea/Pirate ship/Pirate ship NPC.x",
  ["IconFilePath"] = "character/v1/03vehicles/03sea/Pirate ship/Pirate ship NPC.x.png",
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
  ["Price"]=0,
  ["IconAssetName"] = L"树",
  ["ModelFilePath"] = "model/05plants/02tree/01树/树11.x",
  ["IconFilePath"] = "model/05plants/02tree/01树/树11.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"树",
  ["ModelFilePath"] = "model/05plants/02tree/01树/树13.x",
  ["IconFilePath"] = "model/05plants/02tree/01树/树13.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"椰子树",
  ["ModelFilePath"] = "model/05plants/02tree/06椰子树/椰树_new1_v.x",
  ["IconFilePath"] = "model/05plants/02tree/06椰子树/椰树_new1.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"椰子树",
  ["ModelFilePath"] = "model/05plants/02tree/06椰子树/椰树_new2_v.x",
  ["IconFilePath"] = "model/05plants/02tree/06椰子树/椰树_new2.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"竹林",
  ["ModelFilePath"] = "model/05plants/02tree/05竹林/竹群1.x",
  ["IconFilePath"] = "model/05plants/02tree/05竹林/竹群1.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"竹林",
  ["ModelFilePath"] = "model/05plants/02tree/05竹林/竹群2.x",
  ["IconFilePath"] = "model/05plants/02tree/05竹林/竹群2.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"竹林",
  ["ModelFilePath"] = "model/05plants/02tree/05竹林/竹群3.x",
  ["IconFilePath"] = "model/05plants/02tree/05竹林/竹群3.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"柳树",
  ["ModelFilePath"] = "model/05plants/02tree/01tree/tree01/tree01_v.x",
  ["IconFilePath"] = "model/05plants/02tree/01tree/tree01/tree01.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"柳树",
  ["ModelFilePath"] = "model/05plants/02tree/01tree/tree01/tree011_v.x",
  ["IconFilePath"] = "model/05plants/02tree/01tree/tree01/tree011.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"树",
  ["ModelFilePath"] = "model/05plants/02tree/01tree/tree02/tree020_v.x",
  ["IconFilePath"] = "model/05plants/02tree/01tree/tree02/tree020.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"树",
  ["ModelFilePath"] = "model/05plants/02tree/01tree/tree02/tree021_v.x",
  ["IconFilePath"] = "model/05plants/02tree/01tree/tree02/tree021.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"树",
  ["ModelFilePath"] = "model/05plants/02tree/01tree/tree02/tree022_v.x",
  ["IconFilePath"] = "model/05plants/02tree/01tree/tree02/tree022.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"树",
  ["ModelFilePath"] = "model/05plants/02tree/01tree/tree02/tree023_v.x",
  ["IconFilePath"] = "model/05plants/02tree/01tree/tree02/tree023.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"树",
  ["ModelFilePath"] = "model/05plants/02tree/01tree/tree04/tree04_v.x",
  ["IconFilePath"] = "model/05plants/02tree/01tree/tree04/tree04.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"树",
  ["ModelFilePath"] = "model/05plants/02tree/01tree/tree04/tree05_v.x",
  ["IconFilePath"] = "model/05plants/02tree/01tree/tree04/tree05.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"树",
  ["ModelFilePath"] = "model/05plants/02tree/01tree/tree03/tree03_v.x",
  ["IconFilePath"] = "model/05plants/02tree/01tree/tree03/tree03.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"松树",
  ["ModelFilePath"] = "model/05plants/02tree/04曲松/松树1.x",
  ["IconFilePath"] = "model/05plants/02tree/04曲松/松树1.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"松树",
  ["ModelFilePath"] = "model/05plants/02tree/04曲松/松树2.x",
  ["IconFilePath"] = "model/05plants/02tree/04曲松/松树2.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"松树",
  ["ModelFilePath"] = "model/05plants/02tree/04曲松/松树5.x",
  ["IconFilePath"] = "model/05plants/02tree/04曲松/松树5.x.png",
}
,
}
,
  [0] = {
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.35",
  ["Reserved2"] = "1.2",
  ["Price"]=0,
  ["IconAssetName"] = L"民房",
  ["ModelFilePath"] = "model/01building/v1/01house/mingfang/mingfang.x",
  ["IconFilePath"] = "model/01building/v1/01house/mingfang/mingfang.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.35",
  ["Reserved2"] = "1.2",
  ["Price"]=0,
  ["IconAssetName"] = L"民房",
  ["ModelFilePath"] = "model/01building/v1/01house/minfang2/minfang2.x",
  ["IconFilePath"] = "model/01building/v1/01house/minfang2/minfang2.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.35",
  ["Reserved2"] = "1.2",
  ["Price"]=0,
  ["IconAssetName"] = L"民房",
  ["ModelFilePath"] = "model/01building/v1/01house/mingfang3/mingfang3.x",
  ["IconFilePath"] = "model/01building/v1/01house/mingfang3/mingfang3.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.35",
  ["Reserved2"] = "1.2",
  ["Price"]=0,
  ["IconAssetName"] = L"民房",
  ["ModelFilePath"] = "model/01building/v1/01house/mingfang4/mingfang4.x",
  ["IconFilePath"] = "model/01building/v1/01house/mingfang4/mingfang4.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"民房",
  ["ModelFilePath"] = "model/01building/v1/01house/民房1.x",
  ["IconFilePath"] = "model/01building/v1/01house/民房1.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"民房",
  ["ModelFilePath"] = "model/01building/v1/01house/民房2.x",
  ["IconFilePath"] = "model/01building/v1/01house/民房2.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.35",
  ["Reserved2"] = "1.2",
  ["Price"]=0,
  ["IconAssetName"] = L"草房",
  ["ModelFilePath"] = "model/01building/v1/01house/farmhouse/farmhouse.x",
  ["IconFilePath"] = "model/01building/v1/01house/farmhouse/farmhouse.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"市场",
  ["ModelFilePath"] = "model/01building/v1/01house/市场.x",
  ["IconFilePath"] = "model/01building/v1/01house/市场.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"杂货铺",
  ["ModelFilePath"] = "model/01building/v1/01house/杂货铺.x",
  ["IconFilePath"] = "model/01building/v1/01house/杂货铺.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"药店",
  ["ModelFilePath"] = "model/01building/v1/01house/药店.x",
  ["IconFilePath"] = "model/01building/v1/01house/药店.x.png",
}
,
{
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"民房1",
  ["ModelFilePath"] = "model/06props/v1/zawu/zawu1.x",
  ["IconFilePath"] = "model/06props/v1/zawu/zawu1.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.35",
  ["Reserved2"] = "1.2",
  ["Price"]=10,
  ["IconAssetName"] = L"古老银行",
  ["ModelFilePath"] = "model/01building/v1/01house/oldbank/oldbank.x",
  ["IconFilePath"] = "model/01building/v1/01house/oldbank/oldbank.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"酒馆",
  ["ModelFilePath"] = "model/01building/v1/01house/酒馆.x",
  ["IconFilePath"] = "model/01building/v1/01house/酒馆.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"风车",
  ["ModelFilePath"] = "model/01building/v1/01house/windwheel/windwheel.x",
  ["IconFilePath"] = "model/01building/v1/01house/windwheel/windwheel.x.png",
}
,
{
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"风车",
  ["ModelFilePath"] = "model/01building/v1/01house/windwheel/windwheel1.x",
  ["IconFilePath"] = "model/01building/v1/01house/windwheel/windwheel1.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"码头",
  ["ModelFilePath"] = "model/01building/v1/01house/码头.x",
  ["IconFilePath"] = "model/01building/v1/01house/码头.x.png",
}
,
{
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.3",
  ["Reserved2"] = "1.2",
  ["Price"]=50,
  ["IconAssetName"] = L"哨塔",
  ["ModelFilePath"] = "model/06props/shared/pops/哨塔.x",
  ["IconFilePath"] = "model/06props/shared/pops/哨塔.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"水车",
  ["ModelFilePath"] = "model/06props/shared/pops/shuiche.x",
  ["IconFilePath"] = "model/06props/shared/pops/shuiche.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"高脚屋",
  ["ModelFilePath"] = "model/01building/v1/01house/高脚屋2.x",
  ["IconFilePath"] = "model/01building/v1/01house/高脚屋2.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=0,
  ["IconAssetName"] = L"马棚",
  ["ModelFilePath"] = "model/01building/v1/01house/马棚.x",
  ["IconFilePath"] = "model/01building/v1/01house/马棚.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"城镇中心",
  ["ModelFilePath"] = "model/01building/v1/01house/城镇中心.x",
  ["IconFilePath"] = "model/01building/v1/01house/城镇中心.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "1",
  ["Reserved1"] = "0.35",
  ["Reserved2"] = "1.2",
  ["IconAssetName"] = L"教堂",
  ["Price"]=50,
  ["ModelFilePath"] = "model/01building/v1/01house/fane/fane.x",
  ["IconFilePath"] = "model/01building/v1/01house/fane/fane.x.png",
}
,
  {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=10,
  ["IconAssetName"] = L"树屋",
  ["ModelFilePath"] = "model/01building/v1/01house/树屋.x",
  ["IconFilePath"] = "model/01building/v1/01house/树屋.x.png",
}
,
 {
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"城堡",
  ["ModelFilePath"] = "model/01building/v1/01house/castle/castle.x",
  ["IconFilePath"] = "model/01building/v1/01house/castle/castle.x.png",
}
,
{
  ["Reserved4"] = "R4",
  ["Reserved3"] = "R3",
  ["Reserved1"] = "R1",
  ["Reserved2"] = "R2",
  ["Price"]=50,
  ["IconAssetName"] = L"木桥",
  ["ModelFilePath"] = "model/01building/v1/02other/brigde/木桥2_v.x",
  ["IconFilePath"] = "model/01building/v1/02other/brigde/木桥2.x.png",
}
,
}
,
}
