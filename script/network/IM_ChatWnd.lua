--[[
Title: template: windows form or modeless dialog
Author(s): [your name], original template by LiXizhi
Date: 2007/2/7
Parameters:
	IM_ChatWnd: it needs to be a valid name, such as MyDialog
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/network/IM_ChatWnd.lua");
local ctl = CommonCtrl.IM_ChatWnd:new{
	name = "IM_ChatWnd1",
	alignment = "_lt",
	left=0, top=0,
	width = 512,
	height = 290,
	parent = nil,
	to_JID = "lixizhi@paraweb3d.com"
};
ctl:Show();
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/network/IM_Main.lua");

-- define a new control in the common control libary

-- default member attributes
local IM_ChatWnd = {
	-- the top level control name
	name = "IM_ChatWnd1",
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 512,
	height = 290, 
	parent = nil,
	to_JID = nil, -- string of JID with which this chat session is talking with. 
}
CommonCtrl.IM_ChatWnd = IM_ChatWnd;

-- constructor
function IM_ChatWnd:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function IM_ChatWnd:Destroy ()
	ParaUI.Destroy(self.name);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function IM_ChatWnd:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("IM_ChatWnd instance name can not be nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		--_this.background="Texture/whitedot.png;0 0 0 0";
		_this.candrag = true;
		_parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);

		_this = ParaUI.CreateUIObject("button", "btnTopIcon", "_lt", 4, 4, 32, 32)
		_this.text = "icon";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnClose", "_rt", -27, 4, 24, 24)
		_this.text = "X";
		_this.onclick=string.format([[;CommonCtrl.IM_ChatWnd.OnClose("%s");]],self.name);
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnToggleSize", "_rt", -52, 4, 24, 24)
		_this.text = "T";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnHide", "_rt", -77, 4, 24, 24)
		_this.text = "_";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label1", "_lt", 42, 8, 315, 14)
		_this.text = self.to_JID;
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label2", "_lt", 42, 22, 315, 12)
		_this.text = string.format("<%s>", self.to_JID);
		_this:GetFont("text").color = "128 128 128";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnReceiverIcon", "_rt", -73, 44, 64, 64)
		_this.text = "";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnActionList", "_lb", 4, -111, 32, 32)
		_this.text = "icon";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnMyIcon", "_rb", -73, -111, 64, 64)
		_this.text = "button1";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnShakeScreen", "_lb", 42, -111, 32, 32)
		_this.text = "icon";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnReceiverMenu", "_rt", -33, 110, 24, 24)
		_this.text = ">";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnSendMyLocation", "_lb", 80, -111, 32, 32)
		_this.text = "icon";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button1", "_rb", -33, -45, 24, 24)
		_this.text = ">";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.TreeView:new{
			name = self.name.."treeViewChatHistory",
			alignment = "_fi",
			left = 4,
			top = 42,
			width = 79,
			height = 117,
			parent = _parent,
			container_bg = "Texture/tooltip_text.PNG",
			DefaultIndentation = 5,
			DefaultNodeHeight = 22,
		};
		local node = ctl.RootNode;
		ctl:Show();

		NPL.load("(gl)script/ide/MultiLineEditbox.lua");
		local ctl = CommonCtrl.MultiLineEditbox:new{
			name = self.name.."textBoxSendText",
			alignment = "_mb",
			left = 4,
			top = 11,
			width = 133,
			height = 66,
			parent = _parent,
			line_count = 2,
		};
		ctl:Show();

		_this = ParaUI.CreateUIObject("button", "btnSend", "_rb", -123, -77, 44, 28)
		_this.text = "send";
		_this.onclick=string.format([[;CommonCtrl.IM_ChatWnd.OnSendMessage_static("%s");]],self.name);
		_parent:AddChild(_this);

	else
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	end	
end

-- close the given control
function IM_ChatWnd.OnClose(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting IM_ChatWnd instance "..sCtrlName.."\r\n");
		return;
	end
	ParaUI.Destroy(self.name);
end

	
-- add a line of text to the chat history
function IM_ChatWnd:AddTextToChatHistory(from, subject, body)
	local ctl = CommonCtrl.GetControl(self.name.."treeViewChatHistory");
	if(ctl==nil)then
		log("error getting IM_ChatWnd instance "..self.name.."treeViewChatHistory".."\r\n");
		return;
	end
	ctl.RootNode:AddChild(string.format("%s 说: %s", tostring(from), tostring(body)));
	ctl:Update(true); -- true to scroll to last element.
end

-- called when received a message from server
function IM_ChatWnd:OnReceiveMessage(from, subject, body)
	self:AddTextToChatHistory(from, subject, body)
end

-- called to send a message 
function IM_ChatWnd:SendChatMessage(to, body)
	local jc = IM_Main.GetConnectedClient();
	if(jc~=nil) then
		self:AddTextToChatHistory("我", nil, body)
		jc:Message(to, body);
	end
end

-- static
function IM_ChatWnd.OnSendMessage_static(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting IM_ChatWnd instance "..sCtrlName.."\r\n");
		return;
	end
	
	-- get text
	local ctl = CommonCtrl.GetControl(self.name.."textBoxSendText");
	if(ctl==nil)then
		log("error getting IM_ChatWnd instance "..self.name.."textBoxSendText".."\r\n");
		return;
	end
	
	local text = ctl:GetText();
	self:SendChatMessage(tostring(self.to_JID), text);
end