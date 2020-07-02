--[[
Title: default asset
Author(s): LiXizhi
Date: 2005/11
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/3Ddev/AssetLib.lua");
ObjEditor.LoadDefaultAsset();
------------------------------------------------------------
]]
if(_3Ddev==nil) then _3Ddev={}; end

--[[ load default asset into _3Ddev.assets]]
function _3Ddev.LoadDefaultAsset()
	ParaAsset.OpenArchive ("xmodels/TextureWOW.zip");
	ParaAsset.OpenArchive ("xmodels/XmodelWOW.zip");
	local objlist={};
	objlist["树木"]="WOW/World/Azeroth/Westfall/PassiveDoodads/Trees/WestFallTree04.mdx.x";
	objlist["花"]="WOW/World/Azeroth/elwynn/PassiveDoodads/Detail/elwynnflower01.mdx.x";
	objlist["草"]="WOW/World/Azeroth/elwynn/PassiveDoodads/Detail/elwynngrass02/elwynngrass02.mdx.x";
	objlist["蘑菇"]="WOW/World/Azeroth/elwynn/PassiveDoodads/Detail/elwynnmushroom01/elwynnmushroom01.mdx.x";
	objlist["灌木"]="WOW/World/Azeroth/Westfall/PassiveDoodads/Detail/WestFallBush01.mdx.x";
	objlist["岩石1"]="WOW/World/Azeroth/Westfall/PassiveDoodads/Rocks/WestFallBoulder01.mdx.x";
	objlist["岩石2"]="WOW/World/Azeroth/elwynn/PassiveDoodads/CliffRocks/elwynnCliffRock01.mdx.x";
	_3Ddev.assets["植物"] = objlist;
	objlist={};
	objlist["床"]="WOW/World/Azeroth/Westfall/PassiveDoodads/Furniture/westfallbed01.mdx.x";
	objlist["枕头"]="WOW/World/Azeroth/Westfall/PassiveDoodads/HaremPillow02/HaremPillow02.mdx.x";
	objlist["桌子"]="WOW/World/Azeroth/Westfall/PassiveDoodads/WestfallTable/WestfallTable.mdx.x";
	objlist["凳子"]="WOW/World/Azeroth/Westfall/PassiveDoodads/WestfallChair/WestfallChair.mdx.x";
	objlist["椅子"]="WOW/World/generic/human/Passive_Doodads/chairs/generalchairloend01.mdx.x";
	objlist["碗"]="WOW/World/Azeroth/Westfall/PassiveDoodads/Utensils/Bowl.mdx.x";
	objlist["碟"]="WOW/World/Azeroth/Westfall/PassiveDoodads/Utensils/Plate.mdx.x";
	objlist["杯子"]="WOW/World/Azeroth/Westfall/PassiveDoodads/Utensils/Stein.mdx.x";
	objlist["陶罐"]="WOW/World/Azeroth/elwynn/PassiveDoodads/jars/jar01.mdx.x";
	objlist["书架"]="WOW/World/generic/human/Passive_Doodads/bookshelves/abbeyshelf01.mdx.x";
	objlist["柜子"]="WOW/World/generic/human/Passive_Doodads/wardrobe/duskwoodwardrobe01.mdx.x";
	objlist["吊灯"]="WOW/World/generic/human/Passive_Doodads/hanginglanterns/generalhanginglantern01.mdx.x";
	_3Ddev.assets["家具"] = objlist;
	objlist={};
	--[[
	objlist["桶"]="刘峰/桶/barrel.x"
	objlist["鸟巢"]="刘峰/鸟巢/birdnest.x"
	objlist["箱子"]="刘峰/箱子/box.x"
	objlist["小舟"]="刘峰/小舟/boat.x"
	objlist["浆"]="刘峰/小舟/boatpad.x"
	objlist["篝火"]="刘峰/篝火/campfire.x"
	objlist["骷髅"]="刘峰/骷髅/骷髅.x"
	objlist["地毯2"]="刘峰/地毯/地毯2.x"
	objlist["岩石"]="刘峰/岩石/stone.x"
	objlist["绳梯"]="刘峰/绳梯/ropeladder1.x"
	objlist["绳子"]="刘峰/绳子/rope1.x"
	objlist["绳网"]="刘峰/绳网/ropenet1.x"
	objlist["背包"]="刘峰/背包/pack.x"
	objlist["锅"]="刘峰/锅/boiler.x"
	objlist["花盆"]="刘峰/花盆/flowerpot.x"
	objlist["告示牌"]="刘峰/告示牌/notificationboard.x"
	
	objlist["盘子"]="刘峰/盘子/dish.x"
	objlist["瓶子"]="刘峰/瓶子/bottle.x"
	objlist["锅"]="刘峰/锅/boiler.x"
	objlist["碗"]="刘峰/碗/bowl.x"
	objlist["筷子"]="刘峰/碗/sticks.x"
	objlist["枕头"]="刘峰/枕头/pillow.x"
	objlist["鱼杆"]="刘峰/鱼杆/fishingrod.x"
	objlist["猪头"]="刘峰/猪头/sacrifice.x"
	objlist["铁砧"]="刘峰/铁砧/stithy.x"
	objlist["烛台"]="刘峰/烛台/candleholder.x"
	objlist["书本"]="刘峰/书本/books1.x"
	objlist["书本"]="刘峰/书本/books2.x"
	objlist["水槽"]="刘峰/水槽/flume.x"
	
	objlist["水井"]="刘峰/水井/well.x"
	objlist["小棚子"]="刘峰/小棚子/canopy.x"
	objlist["小石屋"]="刘峰/小型房屋/石头/cabin_stone.x"
	objlist["小砖屋"]="刘峰/小型房屋/砖石/cabin_brick.x"
	objlist["布帐篷"]="刘峰/帐篷/布/tent_cloth.x"
	objlist["枝叶帐篷"]="刘峰/帐篷/枝叶/tent_leaves.x"
	objlist["木桥"]="刘峰/桥/木/bridge_wood.x"
	objlist["石头桥"]="刘峰/桥/石头/bridge_stone.x"
	objlist["竹子"]="刘峰/桥/竹子/bridge_bamboo.x"
	
	objlist["岗亭"]="刘峰/岗亭/sentrybox.x"
	objlist["绞刑架"]="刘峰/绞刑架/scaffold.x"
	objlist["流动的售货房屋"]="刘峰/流动的售货房屋/booth.x"
	objlist["路灯"]="刘峰/路灯/streetlamp.x"
	objlist["起重机"]="刘峰/起重机/crane.x"
	objlist["风车"]="刘峰/风车/windmill.x"
	objlist["木篱笆"]="刘峰/篱笆/木/fense_wood.x"
	objlist["石篱笆"]="刘峰/篱笆/石头/fense_stone.x"
	]]
	
	objlist["仓库"]="刘峰/仓库/storage.x"
	objlist["碉堡"]="刘峰/碉堡/blockhouse.x"
	objlist["钟楼"]="刘峰/钟楼/clochard.x"
	objlist["哨塔"]="刘峰/哨塔/sentry.x"
	objlist["建筑废墟"]="刘峰/建筑废墟/ruin.x"
	objlist["灯塔"]="刘峰/灯塔/lighthouse.x"
	
	
	_3Ddev.assets["测试"] = objlist;
	objlist={};
	objlist["喷泉"]="WOW/World/Azeroth/Westfall/PassiveDoodads/WestfallFountain/WestfallFountain.mdx.x";
	objlist["稻草人"]="WOW/World/Azeroth/Westfall/PassiveDoodads/Scarecrow/WestFallScarecrow.mdx.x";
	objlist["狮子"]="WOW/World/Azeroth/elwynn/PassiveDoodads/statue/lionstatue.mdx.x";
	objlist["猎人"]="WOW/World/generic/human/Passive_Doodads/statues/statuealleria.mdx.x";
	objlist["法师"]="WOW/World/generic/human/Passive_Doodads/statues/statuekhadgar.mdx.x";
	objlist["战士"]="WOW/World/generic/human/Passive_Doodads/statues/statuedanath.mdx.x";
	
	_3Ddev.assets["雕像"] = objlist;
	objlist={};
	objlist["布幕"]="WOW/World/Azeroth/Westfall/PassiveDoodads/Rugracks/Rugrack01.mdx.x";
	objlist["稻草堆"]="WOW/World/Azeroth/Westfall/PassiveDoodads/HayStack/WestFallHayStack01.mdx.x";
	objlist["旅馆牌"]="WOW/World/Azeroth/elwynn/PassiveDoodads/signs/shop/humaninnsign.mdx.x";
	objlist["营火"]="WOW/World/Azeroth/elwynn/PassiveDoodads/campfire/elwynncampfire.mdx.x";
	objlist["斧头"]="WOW/World/Azeroth/elwynn/PassiveDoodads/battlegladepolearmskull/battlegladepolearmskull.mdx.x";
	objlist["剑"]="WOW/World/Azeroth/elwynn/PassiveDoodads/battlegladesword/battlegladesword.mdx.x";
	objlist["地球仪"]="WOW/World/generic/human/Passive_Doodads/globes/globe01.mdx.x";
	objlist["花坛"]="WOW/World/generic/human/Passive_Doodads/planterboxes/stormwindwindowplanterA.mdx.x";
	objlist["地毯"]="WOW/World/generic/human/Passive_Doodads/rugs/karazahnrugred.mdx.x";
	objlist["箱子"]="WOW/World/generic/human/Passive_Doodads/crates/replacecrate02.mdx.x";
	objlist["窗帘"]="WOW/World/generic/human/Passive_Doodads/drapery/drapery02.mdx.x";
	_3Ddev.assets["装饰"] = objlist;
	objlist={};
	objlist["风车"]="WOW/World/Azeroth/Westfall/Buildings/WindMill/westfallwindmill.mdx.x";
	objlist["灯"]="WOW/World/Azeroth/Westfall/PassiveDoodads/LampPost/WestfallLampPost.mdx.x";
	objlist["小木屋"]="WOW/World/Azeroth/Westfall/PassiveDoodads/Outhouse/Outhouse.mdx.x";
	objlist["灯塔"]="WOW/World/Azeroth/Westfall/Buildings/lighthouse/Westfalllighthouse.mdx.x";
	objlist["小房子"]="WOW/World/Azeroth/Westfall/Buildings/Shed/WestfallShed.mdx.x";
	_3Ddev.assets["建筑"] = objlist;
end

--[[ load default asset into _3Ddev.assets]]
function _3Ddev.LoadAssetSet0()
	local objlist={};
	objlist["tree1"]="sample/trees/tree1.x";
	objlist["tree2"]="sample/trees/tree1.x";
	objlist["tree3"]="sample/trees/tree1.x";
	objlist["tree4"]="sample/trees/tree1.x";
	_3Ddev.assets["trees"] = objlist;
	_3Ddev.assets["furniture"] = {"sample/trees/tree1.x", "sample/trees/tree1.x"};
	_3Ddev.assets["buildings"] = {"sample/trees/tree1.x", "sample/trees/tree1.x"};
end