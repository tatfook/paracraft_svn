--[[
Title: kid ui item bar container
Author(s): LiXizhi
Date: 2006/7/7
Desc: CommonCtrl.CKidItemsContainer displays the right container of the ui
use the lib:
For character models in ItemDB table in KidsDB, we will extract data from the reserved words by follows.
	Reserved1: physics radius, such as 0.35
	Reserved2: density, such as 1.2
	Reserved3: scaling, such as 1
------------------------------------------------------------
NPL.load("(gl)script/kids/ui/itembar_container.lua");
CommonCtrl.CKidItemsContainer.Initialize();
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/kids_db.lua");
NPL.load("(gl)script/ide/object_editor.lua");
-- common control library
NPL.load("(gl)script/ide/common_control.lua");

local L = CommonCtrl.Locale("KidsUI");

-- define a new control in the common control libary

-- default member attributes
local CKidItemsContainer = {
	-- normal window size
	obj_btn_width=32,
	visible = false;
	name = "kiditembarcontainer",
	contName="kidui_itembar_container",
	-- display attribute 
	ItemType = 0,
	ItemPage = 0,
	ItemPageSize = 16,
}
CommonCtrl.CKidItemsContainer = CKidItemsContainer;
CommonCtrl.AddControl(CKidItemsContainer.name, CKidItemsContainer);

-- get the indexed item at the current page and type
function CKidItemsContainer:GetItemByIndex(nIndex)
	if(kids_db.items[self.ItemType]~=nil) then
		local item = kids_db.items[self.ItemType][self.ItemPage*self.ItemPageSize+nIndex+1];
		return item;
	end
end

-- update the item icons, according to current ItemType, ItemPage, and ItemPageSize
function CKidItemsContainer.Update()
	local self = CommonCtrl.GetControl("kiditembarcontainer");
	if(self==nil)then
		log("err getting control kiditembarcontainer\r\n");
		return;
	end
	
	local _this;
	local i,item;
	for i=0, (self.ItemPageSize-1) do 
		_this = ParaUI.GetUIObject("kidui_itembar_btn"..i);
		item = self:GetItemByIndex(i);
		if(item~=nil) then
			if(not item.IconFilePath) then
				item.IconFilePath = item.ModelFilePath..".png";
			end	
			_this.background = item.IconFilePath;
			_this.tooltip = item.IconAssetName; -- TODO: use description field, so that it is language neutual.
			if(item.Price~=nil and item.Price>0) then
				if(ParaEngine.IsProductActivated()==false) then
					_this.animstyle = 0; -- button animation for unenabled items
					_this.enabled = false;
				else
					_this.animstyle = 14; -- button animation.		
					_this.enabled = true;
				end
			else	
				_this.animstyle = 14; -- button animation.
				_this.enabled = true;
			end
			
			_this.visible = true;
		else
			_this.visible = false;
		end
	end
	ObjEditor.CurrentAssetIndex = self.ItemType+1;
	
	_this = ParaUI.GetUIObject("kidui_itembar_pagenumber");
	_this.text = tostring(self.ItemPage+1);
end

-- @param bShow: true to show the item bar.
function CKidItemsContainer.show(bShow)
	local self = CommonCtrl.GetControl("kiditembarcontainer");
	if(self==nil)then
		log("err getting control kiditembarcontainer\r\n");
		return;
	end
	self.visible = bShow;
	
	local _this;
	_this=ParaUI.GetUIObject(self.contName);
	if(_this:IsValid() == true) then
		_this.visible = bShow;
	end
	
	_this=ParaUI.GetUIObject(self.contName.."bg");
	if(_this:IsValid() == true) then
		_this.visible = bShow;
	end
end

function CKidItemsContainer.Initialize()
	local self = CommonCtrl.GetControl("kiditembarcontainer");
	if(self==nil)then
		log("err getting control kiditembarcontainer\r\n");
		return;
	end
	local _this,_parent;
	_parent=ParaUI.GetUIObject(self.contName);
	if(_parent:IsValid()) then
		return;
	end
	
	self.visible = false;
	self.ItemType = 0;
	self.ItemPage = 0;
	
--background images 
	local top = 0;
	_parent=ParaUI.CreateUIObject("container",self.contName.."bg","_rt",-128,top,128,512);
	_parent:AttachToRoot();
	_parent.enabled = false;
	_parent.background="Texture/kidui/rightup/bg.png";
	
	--[[ the following are for auto row increasable background
	_this=ParaUI.CreateUIObject("container","bg","_lt",0,top,128,211);
	_parent:AddChild(_this);
	_this.enabled = false;
	_this.background="Texture/kidui/rightup/up.png;0 0 128 211";
	local i,j;
	top = top+211;
	for i = 1, nRepeats do
		_this=ParaUI.CreateUIObject("container","bg","_lt",0,top,128,125);
		_parent:AddChild(_this);
		_this.enabled = false;
		_this.background="Texture/kidui/rightup/mid.png;0 0 128 125";
		top = top+125;
	end
	_this=ParaUI.CreateUIObject("container","bg","_lt",0,top,128,160);
	_parent:AddChild(_this);
	_this.enabled = false;
	_this.background="Texture/kidui/rightup/down.png;0 0 128 160";
	]]
	
	-- create buttons.
	_parent=ParaUI.CreateUIObject("container",self.contName,"_rt",-105,46,84,450);
	_parent:AttachToRoot();
	_parent.background="Texture/whitedot.png;0 0 0 0";--"Texture/whitedot.png";
	--_parent.background="Texture/alphadot.png"; -- for testing container position
	
	local left,top=4,7;
	local nRows = self.ItemPageSize/2;
	local nCols = 2;
	for i=1, nRows do
		left=4;
		for j=1, nCols do
			local nIndex = (i-1)*nCols+j-1;
			_this=ParaUI.CreateUIObject("button","kidui_itembar_btn"..nIndex,"_lt",left,top,self.obj_btn_width,self.obj_btn_width);
			_parent:AddChild(_this);
			_this.background="Texture/kidui/right/btn_bg1.png";
			_this.animstyle = 14; -- button animation.
			_this.onclick=string.format([[;CommonCtrl.CKidItemsContainer.OnItemClick(%s);]],nIndex);
			left=left+self.obj_btn_width+9;
		end
		top=top+self.obj_btn_width+13;
	end
	
	-- page number and arrow buttons, etc.	
	left = 4;
	top = top+10;
	
	_this=ParaUI.CreateUIObject("button","left_arrow","_lt",left,top,self.obj_btn_width,self.obj_btn_width);
	_parent:AddChild(_this);
	_this.onclick=string.format([[;CommonCtrl.CKidItemsContainer.OnFlipPage(%d);]],0);
	_this.background="Texture/kidui/rightup/left_arr.png";
	
	_this=ParaUI.CreateUIObject("text","kidui_itembar_pagenumber","_lt",left+29,top-5,20,15);
	_parent:AddChild(_this);
	
	left=left+self.obj_btn_width+9;
	_this=ParaUI.CreateUIObject("button","right_arrow","_lt",left,top,self.obj_btn_width,self.obj_btn_width);
	_parent:AddChild(_this);
	_this.onclick=string.format([[;CommonCtrl.CKidItemsContainer.OnFlipPage(%d);]],1);
	_this.background="Texture/kidui/rightup/right_arr.png";
	
	CKidItemsContainer.Update();
	CKidItemsContainer.show(self.visible);
end

function CKidItemsContainer.CreateItem(ModelFilePath, pos, CategoryName, localmatrix)
	local nServerState = ParaWorld.GetServerState();
	if(nServerState == 0) then
		-- it is in standalone mode
		local obj = ObjEditor.AutoCreateObject("n", ModelFilePath,pos,nil,true,localmatrix);
	else
		if(nServerState == 1) then
			-- this is a server. 
			server.BroadcastObjectCreation("n", ModelFilePath, pos, CategoryName, localmatrix);
		elseif(nServerState == 2) then
			-- this is a client.
			client.RequestObjectCreation("n", ModelFilePath, pos, CategoryName, localmatrix);
		end
	end
end

function CKidItemsContainer.OnItemClick(nIndex)
	local self = CommonCtrl.GetControl("kiditembarcontainer");
	if(self==nil)then
		log("err getting control kiditembarcontainer\r\n");
		return;
	end
	ParaAudio.PlayUISound("Btn2");
	if(not kids_db.User.CheckRight("Create")) then return end
	
	local item = self:GetItemByIndex(nIndex);
	if(item~=nil) then
		local nServerState = ParaWorld.GetServerState();
		--self.ItemType==6 means it is a character
		if(nServerState == 0 or self.ItemType==6) then
			-- it is in standalone mode or a character. 
			
			-- if the price of the model is not free
			if(item.Price~=nil and item.Price>10) then
				if(ParaEngine.IsProductActivated()==false) then
					_guihelper.MessageBox(L"need a license to use");
					return
				end
			end
			
			local obj = ObjEditor.AutoCreateObject("n", item.ModelFilePath);
			if(obj~=nil and obj:IsValid()==true and self.ItemType == 6) then
				-- this is a character
				local fNum = tonumber(item.Reserved3);
				if(fNum~=nil) then
					obj:SetScaling(fNum);
				end
				local fNum = tonumber(item.Reserved1);
				if(fNum~=nil) then
					obj:SetPhysicsRadius(fNum);
				end
				local fNum = tonumber(item.Reserved2);
				if(fNum~=nil) then
					obj:SetDensity(fNum);
				end
				-- make a newly created character NPC type. 
				local att = obj:GetAttributeObject();
				att:SetField("GroupID", CommonCtrl.CKidMiddleContainer.char_type[2].GroupID);
				att:SetField("SentientField", CommonCtrl.CKidMiddleContainer.char_type[2].SentientField);
			end	
		else
			-- for standard mesh object only  
			local player = ParaScene.GetPlayer();
			local pos = {};
			pos[1], pos[2], pos[3] = player:GetPosition();
			
			if(nServerState == 1) then
				-- this is a server. 
				server.BroadcastObjectCreation("n", item.ModelFilePath, pos, ObjEditor.GetCurrentCategoryName());
			elseif(nServerState == 2) then
				-- this is a client. 
				client.RequestObjectCreation("n", item.ModelFilePath, pos, ObjEditor.GetCurrentCategoryName());
			end
		end
	end
end

--[[@param nLeftRight: 0 for left, 1 for right]]
function CKidItemsContainer.OnFlipPage(nLeftRight)
	local self = CommonCtrl.GetControl("kiditembarcontainer");
	if(self==nil)then
		log("err getting control kiditembarcontainer\r\n");
		return;
	end
	ParaAudio.PlayUISound("Btn1");
	
	if(nLeftRight == 0)then
		if( self.ItemPage>0) then
			self.ItemPage = self.ItemPage-1;
			self:Update();
		end
	else
		-- only flip if there is still items on the next page.
		local item = self:GetItemByIndex(self.ItemPageSize);
		if( item~=nil) then
			self.ItemPage = self.ItemPage+1;
			self:Update();
		end
	end
end