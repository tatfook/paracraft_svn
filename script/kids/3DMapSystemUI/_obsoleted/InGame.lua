--[[
Title: Additional in game UI for 3D Map system
Author(s): WangTian
Date: 2007/8/30
Desc: Show the additional in game UI
Note: The additional UI works as a complementary UI to the original kids movie UI
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/InGame.lua");
Map3DSystem.UI.LoadInGameUI();
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/3DMapSystem_Data.lua");

local L = CommonCtrl.Locale("Kids3DMap");

function Map3DSystem.UI.LoadInGameUI()

	Map3DSystem.UI.MainBar.InitMainBar()
	local userURL = "ABC";
	local naviURL = "BCD";
	
	-- TODO: make this a function in the table to prevent the data redundancy
	if(userURL ~= nil and naviURL ~= nil) then
		if( userURL == naviURL ) then
			Map3DSystem.World.IsOwner = true;
		else
			Map3DSystem.World.IsOwner = false;
		end
	end
	
	local _this, _parent;
	
	local _width, _height = 200, 600;
	local _height_Icon = 100;
	local _height_Info = 100;
	local _height_Board = 200;
	
	_this = ParaUI.CreateUIObject("container", "Kids3DMap_Ingame_LeftBox","_lt", 0, 0, _width, _height);
	_this.background = "";
	_this:AttachToRoot();
	_parent = _this;
	
	_this = ParaUI.CreateUIObject("container", "Kids3DMap_Ingame_LeftBox_Icon", "_lt", 0, 0, _height_Icon, _height_Icon)
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("container", "Kids3DMap_Ingame_LeftBox_Info", "_lt", 0, _height_Icon, _width, _height_Info)
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("container", "Kids3DMap_Ingame_LeftBox_Board", "_lt", 0, _height_Icon + _height_Info, _width, _height_Board)
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("text", "Kids3DMap_Ingame_LeftBox_InfoText", "_lt", 10, _height_Icon + 10, _width - 20, _height_Info - 20)
	_this.text = "Info";
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("text", "Kids3DMap_Ingame_LeftBox_BoardText", "_lt", 10, _height_Icon + _height_Info + 10, _width - 20, _height_Board - 20)
	_this.text = "Board";
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("button", "Kids3DMap_Ingame_LeftBox_Postbutton", "_lt", 10, _height_Icon + _height_Info - 40, 128, 32)
	_this.text = "Save table";
	_this.onclick = ";Map3DSystem.UI.PrintMap3DSystemTable();";
	_parent:AddChild(_this);
	
	_this = ParaUI.CreateUIObject("button", "Kids3DMap_Ingame_LeftBox_Postbutton", "_lt", 10, _height_Icon + _height_Info, 128, 32)
	_this.text = "DressUp";
	_this.onclick = ";Map3DSystem.UI.DressUp();";
	_parent:AddChild(_this);
	
	Map3DSystem.UI.GetSpaceInfo_Callback(naviURL);
	

end


-- web service call back
function Map3DSystem.UI.GetSpaceInfo_Callback(SpaceURL)

	Map3DSystem.World.OwnerLevel = 100;
	Map3DSystem.World.Views = 2180;
	
	local _this = ParaUI.GetUIObject("Kids3DMap_Ingame_LeftBox_InfoText");

	if(_this:IsValid()) then
		_this.text = L"User Level:" .. Map3DSystem.World.OwnerLevel .."\r\n"
					.. L"Space Views:" .. Map3DSystem.World.Views;
	end
end



function Map3DSystem.UI.PrintMap3DSystemTable()
	-- print Map3DSystem table
	Map3DSystem.Misc.SaveTableToFile(Map3DSystem, "TestTable/Map3DSystem.ini");
	Map3DSystem.Misc.SaveTableToFile(kids_db, "TestTable/Kids_DB.ini");
	Map3DSystem.Misc.SaveTableToFile(KidsUI, "TestTable/KidsUI.ini");
	--commonlib.SaveTableToFile(Kids, "TestTable/Map3DSystem.ini");
end

function Map3DSystem.UI.DressUp()
	-- TODO: call this function on enter space
	CCS_db.CurrentCharacterInfo = Map3DSystem.Misc.CopyTable(Map3DSystem.User.Players.AppearanceInfo["CharacterSlot"..Map3DSystem.Player.CurrentSelectedCharacterIndex]);
	CCS_db.LoadCharacterCCSInfo(Map3DSystem.User.Name);
end