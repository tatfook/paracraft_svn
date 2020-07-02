--[[
Title: 
Author(s): Spring
Date: 2010/12/17
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Help/GemHelp/GemHelp.lua");
MyCompany.Aries.Help.GemHelp.ShowPage();
------------------------------------------------------------
--]]
local GemHelp = commonlib.gettable("MyCompany.Aries.Help.GemHelp");

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;

local gem_words={["addAttack"]={},["addShield"]={},["addAccuracy"]={},["addPipsHP"]={},};
local gemlist={
	["addAttack"]={
		-- 黄晶石 1-5级
		[1]=26006,[2]=26007,[3]=26008,[4]=26009,[5]=26010,
		-- 蓝晶石 1-5级
		[6]=26011,[7]=26012,[8]=26013,[9]=26014,[10]=26015,
		-- 绿晶石 1-5级
		[11]=26016,[12]=26017,[13]=26018,[14]=26019,[15]=26020,
		-- 黑晶石 1-5级
		[16]=26021,[17]=26022,[18]=26023,[19]=26024,[20]=26025,
		-- 紫晶石 1-5级
		[21]=26026,[22]=26027,[23]=26028,[24]=26029,[25]=26030,
		},
	["addShield"]={
		-- 黄和玉 1-5级
		[1]=26031,[2]=26032,[3]=26033,[4]=26034,[5]=26035,
		-- 蓝和玉 1-5级
		[6]=26036,[7]=26037,[8]=26038,[9]=26039,[10]=26040,
		-- 绿和玉 1-5级
		[11]=26041,[12]=26042,[13]=26043,[14]=26044,[15]=26045,
		-- 黑和玉 1-5级
		[16]=26046,[17]=26047,[18]=26048,[19]=26049,[20]=26050,
		-- 紫和玉 1-5级
		[21]=26051,[22]=26052,[23]=26053,[24]=26054,[25]=26055,
		},
	["addAccuracy"]={
		-- 黄玄珠 1-5级
		[1]=26056,[2]=26057,[3]=26058,[4]=26059,[5]=26060,
		-- 蓝玄珠 1-5级
		[6]=26061,[7]=26062,[8]=26063,[9]=26064,[10]=26065,
		-- 黑玄珠 1-5级
		[11]=26066,[12]=26067,[13]=26068,[14]=26069,[15]=26070,
		-- 紫玄珠 1-5级
		[16]=26071,[17]=26072,[18]=26073,[19]=26074,[20]=26075,
		},
	["addPipsHP"]={
		-- 血精玺 1-5级
		[1]=26001,[2]=26002,[3]=26003,[4]=26004,[5]=26005,
		-- 月光镜 1-5级
		[6]=26076,[7]=26077,[8]=26078,[9]=26079,[10]=26080,
		},
};

function GemHelp.GemStat_word(gsid)
	gsid = tonumber(gsid);
	local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
	local stat_word = "";
	if(gsItem.template.class == 3 and gsItem.template.subclass == 6) then
		-- SocketableGem
		local type, value;
		for type, value in pairs(gsItem.template.stats) do
			local word = MyCompany.Aries.Combat.GetStatWord_OfTypeValue(type, value);
			if(word) then
				stat_word = stat_word..word;
			end
		end
	end
	return stat_word;
end

function GemHelp.GemStat_DS_Init(gemtype)
	if (table.maxn(gem_words[gemtype])==0) then
	gem_words[gemtype]={};
	for i,each_gsid in ipairs(gemlist[gemtype]) do
		if ((i%5)==1) then
			local gsItem = System.Item.ItemManager.GetGlobalStoreItemInMemory(each_gsid);
			local name = string.gsub(gsItem.template.name,"%d.","")
			local item = {stat=name};
			table.insert(gem_words[gemtype],item);
		end
		local gem_word = GemHelp.GemStat_word(each_gsid);
		local item = {stat=gem_word};
		table.insert(gem_words[gemtype],item);		
	end
	commonlib.echo(gem_words);
	end
end

function GemHelp.GemStat_DS(gemtype,index)
	if(index == nil) then
        return 1;
	else
		return gem_words[gemtype][index];
	end	
end

function GemHelp.ShowPage()
	local style = commonlib.deepcopy(CommonCtrl.WindowFrame.ContainerStyle);
	 System.App.Commands.Call("File.MCMLWindowFrame", {
        url = "script/apps/Aries/Help/GemHelp/GemHelp.html", 
        app_key = MyCompany.Aries.app.app_key, 
        name = "GemHelp.ShowPage", 
        isShowTitleBar = false,
        DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		enable_esc_key = true,
        style = style,
        zorder = 2,
        allowDrag = false,
		isTopLevel = true,
        directPosition = true,
            align = "_ct",
            x = -762/2,
            y = -488/2,
            width = 762,
            height = 487,
    });
end
