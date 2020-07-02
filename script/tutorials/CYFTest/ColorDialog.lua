-- author
-- note
-- desc
----------------------------------------------------------------
-- NPL.load("(gl)script/tutorials/CYFTest/ColorDialog.lua");
		--local ctl = CommonCtrl.ColorDialog:new{
			--name = "btnColorSele222",
			--alignment = "_lt",
			--left = 0,
			--top = 250,
			--width = 200,
			--height = 50,
			--parent = nil,
			--isChecked = false,
			--text = "Select Color",
		--};
		--ctl:Show();
----------------------------------------------------------------

-- common library
NPL.load("(gl)script/ide/common_control.lua");

local colorDialog = {
	name = "colorDialog1",
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 150,
	height = 26,
	parent = nil,
	text = "Select Color",
	selectedColor = "0 0 0"
}
CommonCtrl.ColorDialog = colorDialog;


function colorDialog:new (o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function colorDialog:Destroy ()
	ParaUI.Destroy(self.name);
end

function colorDialog:Show(bShow)
	local _this,_parent;
	if(self.name == nil)then
		log("colorDialog instance name can not be nil -_-b \r\n");
		return;
	end
	
	_this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		_this = ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		_this.background = "";
		_parent = _this;
		
		if(self.parent == nil)then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		
		CommonCtrl.AddControl(self.name,self);
		
		_this = ParaUI.CreateUIObject("button",self.name.."btnSelectColor","_lt",0,0,self.width,self.height);
	    local texture=_this:GetTexture("background");
        texture.color = "0 0 0 50";
		_this.text = self.text;
		_this:GetFont("text").color = self.selectedColor.." 255"; -- "255 255 255 255" "R G B A"
		_this.onclick = string.format([[;CommonCtrl.ColorDialog.ShowDialog("%s");]],self.name);
		_parent:AddChild(_this);
		
		-- TODO: refrence:
		-- function _guihelper.SetVistaStyleButton(uiobject, foregroundImage, backgroundImage)
		
	else
		if(bShow == nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end		
	end
end

function colorDialog:ShowDialog(ctrName)
	local _self = CommonCtrl.GetControl(ctrName);
	local btn = ParaUI.GetUIObject("btnSelectColor");
	if(_self == nil or btn == nil)then
		log("err getting ColorDialog instance"..ctrName.." -_-b \r\n");
		return;
	end
	
	local btnColorSele,text,containerB
	local x,y = ParaUI.GetMousePosition()
	--local x, y, btnW, btnH = btn:GetAbsPosition();
	local tLeft, tTop, w, h = 5, 5, 351, 162;
	if(x >= w) then
		tLeft = x - w
	elseif(x >= w/2) then
		tLeft = x - w/2
	else
		tLeft = 0
	end
	if(y >= h) then
		tTop = y - h
	else
		tTop = y
	end
	containerB = ParaUI.CreateUIObject("container",self.name.."containerB","_lt",tLeft,tTop,w,h)
	containerB.color = "0 0 0"
	if(_self.parent == nil) then
		containerB:AttachToRoot()
	else
		_self.parent:AddChild(containerB)
	end
		
	btnColorSele = ParaUI.CreateUIObject("button","colorList","_lt",0,0,w,h)
	btnColorSele.background = "Texture/selectcolor.png"
	btnColorSele.onclick = ";CommonCtrl.ColorDialog.GetColor();"
	btnColorSele.onmousemove =";CommonCtrl.ColorDialog.ShowRBG();"
	containerB:AddChild(btnColorSele)
	text = ParaUI.CreateUIObject("text","txt","_lt",tLeft + 20,h + 5,150,10)
	containerB:AddChild(text)
end	

function colorDialog:ShowRBG()
	local btnT = ParaUI.GetUIObject("colorList")
	local txtT = ParaUI.GetUIObject("txt")
	local colorList = ParaUI.GetUIObject(self.name.."containerB")
	if(btnT:IsValid() == true) then
		local x,y = ParaUI.GetMousePosition()
		
		local r1,r2,r3
		r1 = 255
		r2 = 255
		r3 = 255
		
		local r,c
		r = math.floor((y - btnT.y - colorList.y)/16)
		c = math.floor((x - btnT.x - colorList.x)/16)
		
		local index
		index = r * 22 + c
		
		local n1,n2,n3
		n2 = math.floor(index/6)
		n1 = math.floor(n2/6)
		if(n1 > 5) then
			n1 = 5
		end
		n2 = n2 - n1 * 6
		if(n2 > 5) then
			n2 = 5
		end
		n3 = index - n1 * 6 * 6 - n2 * 6
		if(n3 > 5) then
			n3 = 5
		end
		
		r1 = 255 - 51 * n1
		r2 = 255 - 51 * n2
		r3 = 255 - 51 * n3
		
		txtT.text = r1 .. " " .. r2 .. " " .. r3
	end
end

function colorDialog.GetColor()
	local btnT = ParaUI.GetUIObject("btnSelectColor")
	local txtT = ParaUI.GetUIObject("txt")
	btnT:GetFont("text").color = "255 0 0";
	local x,y = ParaUI.GetMousePosition()
	txtT.text = x.."**"..y;

	--return txtT.text
end
		
		