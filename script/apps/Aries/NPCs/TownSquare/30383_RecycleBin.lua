--[[
Title: RecycleBin
Author(s): Leio
Date: 2009/12/7

use the lib:

------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30383_RecycleBin.lua");
local place_square = 1;
local place_index = 1;
Map3DSystem.GSL_client:SendRealtimeMessage("s30383", {body="[Aries][ServerObject30383]TryPickObj:"..place_square..":"..place_index..":"..answer_prop});

------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/NPCs/TownSquare/30383_RecycleBin_panel.lua");
-- create class
local libName = "RecycleBin";
local RecycleBin = {
	cur_place_square = nil,
	place_index = nil,
};
commonlib.setfield("MyCompany.Aries.Quest.NPCs.RecycleBin", RecycleBin);
local assets_map = {
	--可回收垃圾
	[101] = { label = "废纸片", item_id = 101, prop = 1, assetFile = "model/06props/v5/03quest/Garbage/WastePaper/WastePaper.x", },
	[102] = { label = "废塑料", item_id = 102, prop = 1, assetFile = "model/06props/v5/03quest/Garbage/Plastic/Plastic.x", },
	[103] = { label = "玻璃块", item_id = 103, prop = 1, assetFile = "model/06props/v5/03quest/Garbage/Glass/Glass.x", },
	[104] = { label = "锈铁皮", item_id = 104, prop = 1, assetFile = "model/06props/v5/03quest/Garbage/RustyIron/RustyIron.x", },
	[105] = { label = "小布片", item_id = 105, prop = 1, assetFile = "model/06props/v5/03quest/Garbage/Cloth/Cloth.x", },
	--厨房垃圾
	[201] = { label = "破蛋壳", item_id = 201, prop = 2, assetFile = "model/06props/v5/03quest/Garbage/Eggshell/Eggshell.x", },
	[202] = { label = "烂菜叶", item_id = 202, prop = 2, assetFile = "model/06props/v5/03quest/Garbage/Leaf/Leaf.x", },
	--有害垃圾
	[301] = { label = "废电池", item_id = 301, prop = 3, assetFile = "model/06props/v5/03quest/Garbage/Batteries/Batteries.x", },
	[302] = { label = "废灯泡", item_id = 302, prop = 3, assetFile = "model/06props/v5/03quest/Garbage/Bulb/Bulb.x", },
	[303] = { label = "过期药丸", item_id = 303, prop = 3, assetFile = "model/06props/v5/03quest/Garbage/Bentazon/Bentazon.x", },
	--其他垃圾
	[401] = { label = "破陶罐", item_id = 401, prop = 4, assetFile = "model/06props/v5/03quest/Garbage/Gallipot/Gallipot.x", },
	[402] = { label = "渣土", item_id = 402, prop = 4, assetFile = "model/06props/v5/03quest/Garbage/Clay/Clay.x", },
}
local local_items_map = {

}
--小镇广场
local rubbish_1_holes = {
{ 20106.251953125, 0.97303223609924, 19824.755859375 },
{ 19996.283203125, 0.1473296135664, 19761.595703125 },
{ 19991.1875, 0.50159287452698, 19855.404296875 },
{ 20050.1796875, 0.00068846251815557, 19880.25390625 },
{ 20134.013671875, 0.53891468048096, 19881.078125 },
{ 20077.2421875, 0.6898221373558, 19832.697265625 },
{ 20140.35546875, 0.36467155814171, 19793.578125 },
{ 20187.15234375, 0.81538903713226, 19780.3984375 },
{ 20267.10546875, 0.023194832727313, 19786.591796875 },
{ 20243.9765625, 0.22420030832291, 19762.072265625 },
{ 20287.23046875, -0.028133744373918, 19763.078125 },
{ 20172.765625, 3.4874444007874, 19734.736328125 },
}
--local k;
--local x,y,z = 20057, 0.6, 19731 ;
--for k = 1,12 do
	--x = x + 4
	--rubbish_1_holes[k] = {x,y,z};
--end
------------
--生命之泉
local rubbish_2_holes = {
{ 20012.259765625, -2.1376843452454, 19999.03515625 },
{ 20028.25, -1.9961605072021, 20024.87890625 },
{ 19937.361328, -0.008965, 19994.671875, },
{ 19941.369141, 4.074012, 20032.183594, },
{ 20035.0234375, -3.9233260154724, 19997.255859375 },
{ 19933.494141, 2.221310, 20011.062500, },
{ 20067.57421875, -2.4659647941589, 20016.794921875 },
{ 20069.228515625, -2.991227388382, 20045.45703125 },
{ 20081.087890625, -1.7445302009583, 20071.798828125 },
{ 20079.31640625, 1.0929799079895, 20055.548828125 },
{ 20099.82421875, -2.5653023719788, 19984.203125 },
{ 20083.681640625, -1.3469817638397, 19997.5078125 },
}
--local k;
--local x,y,z = 20057, 0.6, 19729 ;
--for k = 1,12 do
	--x = x + 4
	--rubbish_2_holes[k] = {x,y,z};
--end
------------
--游乐场
local rubbish_3_holes = {
{ 20353.466797, 0.577973, 19842.191406, },
{ 20365.939453, 0.581303, 19843.039063, },
{ 20389.939453, 0.581303, 19838.285156, },
{ 20365.457031, 0.581302, 19880.814453, },
{ 20385.679688, 0.581302, 19899.355469, },
{ 20390.833984, 0.581301, 19918.140625, },
{ 20429.238281, 0.581301, 19917.025391, },
{ 20404.908203, 0.581301, 19933.148438, },
{ 20409.609375, 0.586899, 19962.603516, },
{ 20372.617188, 0.581301, 19927.207031, },
{ 20392.707031, 0.581302, 19890.023438, },
{ 20416.435547, 0.581302, 19894.472656, },
}
--local k;
--local x,y,z = 20057, 0.6, 19727 ;
--for k = 1,12 do
	--x = x + 4
	--rubbish_3_holes[k] = {x,y,z};
--end
local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;
local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;
-- RecycleBin.main
function RecycleBin.main_item()
end

function RecycleBin.PreDialog_item(npc_id, instance)
	local self = RecycleBin;
	local place_square,place_index = RecycleBin.ParseID(npc_id);
	if(place_square and place_index)then
		self.place_square = place_square;
		self.place_index = place_index;
		
		local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
		-- show the panel
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Aries/NPCs/TownSquare/30383_RecycleBin_panel.html", 
			app_key = MyCompany.Aries.app.app_key, 
			name = "30383_RecycleBin_panel", 
			isShowTitleBar = false,
			DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
			style = style,
			zorder = 2,
			allowDrag = false,
			isTopLevel = true,
			directPosition = true,
				align = "_ct",
				x = -655/2,
				y = -512/2,
				width = 655,
				height = 550,
		});
    end
	return false;
end
function RecycleBin.GetSelectedItem()
	local self = RecycleBin;
	if(not self.place_square or not self.place_index)then return end
	local item_key = string.format("%d_%d",self.place_square,self.place_index);
	local item = local_items_map[item_key];
	local item_info;
	if(item)then
		item_info = assets_map[item.item_id];
	end
	return item,item_info;
end
function RecycleBin.DoAnswer(answer_prop)
	local self = RecycleBin;
	local place_square,place_index = self.place_square,self.place_index;
	if(place_square and place_index and answer_prop)then
		Map3DSystem.GSL_client:SendRealtimeMessage("s30383", {body="[Aries][ServerObject30383]TryPickObj:"..place_square..":"..place_index..":"..answer_prop});
	end
end
function RecycleBin.MadeID(place_square,place_index)
	if(not place_square or not place_index)then return end
	local head = 30383;
	place_square = string.format("%.2d",place_square);--最多100个区域
	place_index = string.format("%.2d",place_index);--每个区域最多100个位置，超过数量，解析将会出错
	local id = tostring(head)..place_square..place_index;
	return tonumber(id);
end
function RecycleBin.ParseID(id)
	id = tostring(id);
	if(not id)then return end
	local place_square,place_index = string.match(id,"30383(%d%d)(%d%d)");
	place_square = tonumber(place_square);
	place_index = tonumber(place_index);
	return place_square,place_index;
end
function RecycleBin.CreateRubbish(place_square,place_index,prop,item_id)
	local id = RecycleBin.MadeID(place_square,place_index);
	local item_info = assets_map[item_id];
	
	local pos = RecycleBin.GetItemPos(place_square,place_index);
	if(not id or not item_info or not pos)then return end
	
	local npcChar = NPC.GetNpcCharacterFromIDAndInstance(id);
	if(npcChar and npcChar:IsValid() == true) then
		return;
	end
	local label = string.format("%d:%d",place_square,place_index);
	--local label = string.format("%s:%d",item_info.label,item_info.prop);
	--暂时用西瓜资源
	local assetFile = item_info.assetFile or "model/06props/v5/05other/Watermelon/Watermelon.x";
	local params = { 
		name = label,
		position = pos,
		facing = 0.89258199930191,
		scaling = 1,
		isalwaysshowheadontext = false,
		scaling_char = 1,
		assetfile_char = "character/common/dummy/cube_size/cube_size.x",
		assetfile_model = assetFile,
		cursor = "Texture/Aries/Cursor/Pick.tga",
		main_script = "script/apps/Aries/NPCs/TownSquare/30383_RecycleBin.lua",
		main_function = "MyCompany.Aries.Quest.NPCs.RecycleBin.main_item();",
		predialog_function = "MyCompany.Aries.Quest.NPCs.RecycleBin.PreDialog_item",
		isdummy = true,
		autofacing = false,
	};
	NPC.CreateNPCCharacter(id, params);
	local npcChar, _model = NPC.GetNpcCharModelFromIDAndInstance(id);
	if(npcChar and npcChar:IsValid())then
		npcChar:SnapToTerrainSurface(0);
		if(_model and _model:IsValid())then
			local x,y,z = npcChar:GetPosition();
			_model:SetPosition(x,y,z);
		end
	end	
	--记录所有创建的物品
	local item_key = string.format("%d_%d",place_square,place_index);
	local_items_map[item_key] = {
		item_id = item_id,
		prop = prop,
	}
end
function RecycleBin.DestroyInstance(place_square,place_index)
	local id = RecycleBin.MadeID(place_square,place_index);
	if(not id)then return end
	NPC.DeleteNPCCharacter(id);
	
	--清除物品
	local item_key = string.format("%d_%d",place_square,place_index);
	local_items_map[item_key] = nil
end
function RecycleBin.GetItemPos(place_square,place_index)
	if(place_square and place_index)then
		local holes;
		if(place_square == 1)then
			holes = rubbish_1_holes;
		elseif(place_square == 2)then
			holes = rubbish_2_holes;
		elseif(place_square == 3)then
			holes = rubbish_3_holes;
		end
		if(holes)then
			return holes[place_index];
		end
	end
end
function RecycleBin.RecvCallBack(args)
	local s;
	if(args == "AnswerCorrect")then
		s = "<div style='margin-left:5px;margin-top:0px;'>恭喜你垃圾分类正确，奖励给你一朵小红花吧！如果你正确分类垃圾达到一定数量，还可以领取环保卫士徽章呢。希望你为美化哈奇小镇做更多贡献！</div>";
		
	elseif(args == "AnswerWrong")then
		local __,item_info = RecycleBin.GetSelectedItem();
		local label = "";
		if(item_info and item_info.label)then
			label = item_info.label;
		end
		s = string.format("<div style='margin-left:5px;margin-top:10px;'>哎呀，%s可不应该扔进这个垃圾箱呀，再想想吧，下次捡到了垃圾，要扔到相应的垃圾箱里去呀！</div>",label);
	elseif(args == "Faild")then
		s = "<div style='margin-left:15px;margin-top:20px;text-align:center'>你的动作慢了一步，这个垃圾已经被别的哈奇捡走了，你再去看看别的垃圾哦。</div>";
	end
	if(s)then
		NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");
		_guihelper.Custom_MessageBox(s,function(result)
			if(result == _guihelper.DialogResult.OK)then
				commonlib.echo("OK");
				if(args == "AnswerCorrect")then
					--增加一个小红花
					commonlib.echo("===================before get 17096_LittleRedFlower");
					ItemManager.PurchaseItem(17096, 1, function(msg) end, function(msg)
						commonlib.echo("===================after get 17096_LittleRedFlower");
						if(msg) then
						end
					end);
					--正确分类次数+1
					commonlib.echo("===================before get  50306_SortCollectedGarbageOnce");
					ItemManager.PurchaseItem(50306, 1, function(msg) end, function(msg)
						commonlib.echo("===================after get  50306_SortCollectedGarbageOnce");
						if(msg) then
						
						end
					end);
				end
			end
		end,_guihelper.MessageBoxButtons.OK,{ok = "Texture/Aries/Common/IKnow_32bits.png; 0 0 153 49"});
	end
end