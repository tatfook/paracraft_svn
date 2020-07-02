--[[
Author(s): Leio
Date: 2007/12/7
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/RobotShop/RobotUIBase.lua");
------------------------------------------------------------
		
]]
if(not Map3DSystem.UI.RobotUIBase) then Map3DSystem.UI.RobotUIBase={}; end
Map3DSystem.UI.RobotUIBase.RobotInfos=nil;
Map3DSystem.UI.RobotUIBase.SmallTileLength=10;
Map3DSystem.UI.RobotUIBase.CurIndex=0;
Map3DSystem.UI.RobotUIBase.PageLen=0;
Map3DSystem.UI.RobotUIBase.RobotInfoLen=0;
Map3DSystem.UI.RobotUIBase.ControlType={"Buy","Sale","Use"};
Map3DSystem.UI.RobotUIBase.CurControlType=nil;
Map3DSystem.UI.RobotUIBase.SelectedRobotInfo=nil;

function Map3DSystem.UI.RobotUIBase.Init(_parentWnd)
	local	self=Map3DSystem.UI.RobotUIBase;
			
	local   _this,_parent=nil,_parentWnd;
	        _this=ParaUI.CreateUIObject("container","RobotShopContainer", "_lt",0,0,795,570);
			_this.background="Texture/whitedot.png;0 0 0 0";
			_this:AttachToRoot();
			_parent:AddChild(_this);
			_parent = _this;
	local   left,top,width,height=2,437,57,57;
	--group tile bg
			left,top,width,height=4,436,624,57;
			_this=ParaUI.CreateUIObject("container","groupTileBG", "_lt",left,top,width,height);
			_this.background="Texture/3DMapSystem/RobotShop/groupTileBG.png";
			_this:AttachToRoot();
			_parent:AddChild(_this);
	
	--group tile
		    left,top,width,height=7,439,48,48;
			for i=1,self.SmallTileLength do
			
			if (i==1) then left=7 else left=left+63 end;
			_this=ParaUI.CreateUIObject("button","btn"..i, "_lt",left,top,width,height);
			_parent:AddChild(_this);
			end
	--pre next btn
		    left,top,width,height=492,497,36,36;
			_this=ParaUI.CreateUIObject("button","Pre_btn", "_lt",left,top,width,height);
			_parent:AddChild(_this);
			_this.background="Texture/3DMapSystem/RobotShop/btn_Page_Left.png"
			_this.onclick = ";Map3DSystem.UI.RobotUIBase.PrePage();"
			left,top,width,height=578,497,36,36;
			_this=ParaUI.CreateUIObject("button","Next_btn", "_lt",left,top,width,height);
			_parent:AddChild(_this);
			_this.background="Texture/3DMapSystem/RobotShop/btn_Page_Right.png"
			_this.onclick = ";Map3DSystem.UI.RobotUIBase.NextPage();"
	--PageNum_text
	        left,top,width,height=534,503,36,36;
	        _this=ParaUI.CreateUIObject("text","PageNum_text", "_lt",left,top,width,height);
	        _this.text="##";
	        _parent:AddChild(_this);
	--Sure_btn
	        left,top,width,height=630,439,151,93;
	        _this=ParaUI.CreateUIObject("button","Sure_btn", "_lt",left,top,width,height);
	        _this.text="点击";
	        _this.onclick = ";Map3DSystem.UI.RobotUIBase.DoClick();"
	        _parent:AddChild(_this);
	--Race_btn
	        left,top,width,height=7,399,46,24;
	        _this=ParaUI.CreateUIObject("button","Race_btn_human", "_lt",left,top,width,height);
	        _this.text="人物";
	        _this.onclick = ";Map3DSystem.UI.RobotUIBase.RaceBtnClick_human();"
	        _parent:AddChild(_this);
	        
	        left,top,width,height=63,399,46,24;
	        _this=ParaUI.CreateUIObject("button","Race_btn_animal", "_lt",left,top,width,height);
	        _this.text="动物";
	        _this.onclick = ";Map3DSystem.UI.RobotUIBase.RaceBtnClick_animal();"
	        _parent:AddChild(_this);
	 --StateInfo_text
			left,top,width,height=669,399,96,20;
	        _this=ParaUI.CreateUIObject("text","StateInfo_text", "_lt",left,top,width,height);
	        _parent:AddChild(_this);
	  --Control_btn
	        left,top,width,height=7,7,200,35;
	        _this=ParaUI.CreateUIObject("button","Buy_btn", "_lt",left,top,width,height);
	        _this.text="我要购买";
	        _this.onclick = ";Map3DSystem.UI.RobotUIBase.BuyBtnClick();"
	        _parent:AddChild(_this);
	        
	        left,top,width,height=227,7,200,35;
	        _this=ParaUI.CreateUIObject("button","Sale_btn", "_lt",left,top,width,height);
	        _this.text="我要出售";
	        _this.onclick = ";Map3DSystem.UI.RobotUIBase.SaleBtnClick();"
	        _parent:AddChild(_this);  
	        
	       left,top,width,height=447,7,200,35;
	        _this=ParaUI.CreateUIObject("button","Use_btn", "_lt",left,top,width,height);
	        _this.text="我要使用";
	        _this.onclick = ";Map3DSystem.UI.RobotUIBase.UseBtnClick();"
	        _parent:AddChild(_this);   
	 --PropertyInfo bg
			left,top,width,height=14,70,107,224;
			_this=ParaUI.CreateUIObject("container","PropertyInfo_bg", "_lt",left,top,width,height);
			_this.background="Texture/3DMapSystem/RobotShop/propertyInfo_bg.png";
			_parent:AddChild(_this);
	 --PropertyInfo text
	 	    left,top,width,height=140,75,140,36;
	        _this=ParaUI.CreateUIObject("text","PropertyInfo_name", "_lt",left,top,width,height);
	        _this.text="##";
	        _parent:AddChild(_this);
	        left,top,width,height=140,124,140,36;
	        _this=ParaUI.CreateUIObject("text","PropertyInfo_race", "_lt",left,top,width,height);
	        _this.text="##";
	        _parent:AddChild(_this);
	        left,top,width,height=140,173,140,36;
	        _this=ParaUI.CreateUIObject("text","PropertyInfo_price", "_lt",left,top,width,height);
	        _this.text="##";
	        _parent:AddChild(_this);
	        left,top,width,height=140,222,140,36;
	        _this=ParaUI.CreateUIObject("text","PropertyInfo_used", "_lt",left,top,width,height);
	        _this.text="##";
	        _parent:AddChild(_this);
	        left,top,width,height=140,272,280,72;
	        _this=ParaUI.CreateUIObject("text","PropertyInfo_specialty", "_lt",left,top,width,height);
	        _this.text="##";
	        _parent:AddChild(_this);
	 --Map3DCanvas_cont
			left,top,width,height=450,60,256,256;
			_this=ParaUI.CreateUIObject("container","Map3DCanvas_cont", "_lt",left,top,width,height);
			--_this.background="Texture/3DMapSystem/RobotShop/propertyInfo_bg.png";
			
			_this.background="Texture/whitedot.png;0 0 0 0";
			_parent:AddChild(_this);
	--RobotAnimation_container
			left,top,width,height=674,364,0,0;
			_this=ParaUI.CreateUIObject("container","RobotAnimation_container", "_lt",left,top,width,height);
			_this.background="Texture/whitedot.png;0 0 0 0";	
			_parent:AddChild(_this);
	
	NPL.load("(gl)script/kids/3DMapSystemUI/RobotShop/RobotScene.lua");
	Map3DSystem.UI.RobotScene.Init();
	local Map3DCanvas_cont=ParaUI.GetUIObject("Map3DCanvas_cont");
	Map3DSystem.UI.RobotScene.SetContainer(Map3DCanvas_cont);

	NPL.load("(gl)script/kids/3DMapSystemUI/RobotShop/RobotAnimation.lua");
	Map3DSystem.UI.RobotAnimation.Init(ParaUI.GetUIObject("RobotAnimation_container"));
	
end
function Map3DSystem.UI.RobotUIBase.Update()
	local self=Map3DSystem.UI.RobotUIBase;
	
	if(robotInfos==nil) then
	return
	end
   
	self.SetTileList();	
end
function Map3DSystem.UI.RobotUIBase.Clear()
	local self=Map3DSystem.UI.RobotUIBase;
	for i=1,self.SmallTileLength do
		--log(string.format("%s\n",i+startIndex));
		--local robotinfo=self.RobotInfos[i];
		local btn=ParaUI.GetUIObject("btn"..i);
			btn.onclick="";
			btn.tooltip="";
			btn.background="";			
	end
	local PropertyInfo_name=ParaUI.GetUIObject("PropertyInfo_name");
	local PropertyInfo_race=ParaUI.GetUIObject("PropertyInfo_race");
	local PropertyInfo_price=ParaUI.GetUIObject("PropertyInfo_price");
	local PropertyInfo_used=ParaUI.GetUIObject("PropertyInfo_used");
	local PropertyInfo_specialty=ParaUI.GetUIObject("PropertyInfo_specialty");
	PropertyInfo_name.text="";
	PropertyInfo_race.text="";
	PropertyInfo_price.text="";
	PropertyInfo_used.text="";
	PropertyInfo_specialty.text="";
	
	self.SelectedRobotInfo=nil;
	
	Map3DSystem.UI.RobotScene.RemovePlayer();
end
function Map3DSystem.UI.RobotUIBase.Reset()
	local	self=Map3DSystem.UI.RobotUIBase;
			self.CurIndex=0;
end
function Map3DSystem.UI.RobotUIBase.SetRobotInfos(robotInfos)
	local self=Map3DSystem.UI.RobotUIBase;
	if(robotInfos==nil) then
	return
	end
	self.RobotInfos=robotInfos;
	self.RobotInfoLen=table.getn(robotInfos);
	self.PageLen=math.floor((self.RobotInfoLen-1)/self.SmallTileLength);
end

function Map3DSystem.UI.RobotUIBase.SetTileList()
    local self=Map3DSystem.UI.RobotUIBase;
		  self.Clear();
	local startIndex=self.CurIndex * self.SmallTileLength;
	for i=1,self.SmallTileLength do
		local btn=ParaUI.GetUIObject("btn"..i);
		local temp=i+startIndex;
		local robotinfo=self.RobotInfos[temp];
		if(robotinfo~=nil)then
			btn.background=robotinfo.PicURL;	
			if(robotinfo.Used==0) then
			btn.onclick=string.format(";Map3DSystem.UI.RobotUIBase.DoSelected(%d);",temp);
			btn.color = "255 255 255 255" -- "R G B A"
			btn.enabled=true;
			btn.tooltip=robotinfo.Name;
			else
			btn.background=robotinfo.PicURL;
			btn.color = "255 255 255 50" -- "R G B A"
			btn.enabled=false;
			btn.tooltip="正在被使用！";
			end
			
			
		end
		
	end
	self.SetText();
end
function Map3DSystem.UI.RobotUIBase.DoSelected(i)
	local self=Map3DSystem.UI.RobotUIBase;
	local robotinfo=self.RobotInfos[i];
	if(robotinfo==nil) then return end;
	local PropertyInfo_name=ParaUI.GetUIObject("PropertyInfo_name");
	local PropertyInfo_race=ParaUI.GetUIObject("PropertyInfo_race");
	local PropertyInfo_price=ParaUI.GetUIObject("PropertyInfo_price");
	local PropertyInfo_used=ParaUI.GetUIObject("PropertyInfo_used");
	local PropertyInfo_specialty=ParaUI.GetUIObject("PropertyInfo_specialty");
	PropertyInfo_name.text=robotinfo.Name;
	PropertyInfo_race.text=self.ConvertRace(robotinfo.Race);
	PropertyInfo_price.text=robotinfo.Price;
	PropertyInfo_used.text=self.ConvertUsed(robotinfo.Used);
	PropertyInfo_specialty.text=robotinfo.Specialty;
	
	--SelectedRobotInfo
	self.SelectedRobotInfo=robotinfo;
	Map3DSystem.UI.RobotScene.SetAssetChar(robotinfo.ModelPath);
end

function Map3DSystem.UI.RobotUIBase.DoClick()
	local self=Map3DSystem.UI.RobotUIBase;
	local robotinfo=self.SelectedRobotInfo;
	if(robotinfo==nil)then return end;
	
	--buy
	if(self.CurControlType==self.ControlType[1]) then
		Map3DSystem.Map.RobotDB.AddUserRobot(robotinfo);
		Map3DSystem.UI.RobotAnimation.Play(1);
	--sale
	elseif(self.CurControlType==self.ControlType[2]) then
		Map3DSystem.Map.RobotDB.RemoveUserRobot(robotinfo.ID);
		Map3DSystem.UI.RobotUIBase.RaceBtnClick_human();
		Map3DSystem.UI.RobotAnimation.Play(2);
	--use
	elseif(self.CurControlType==self.ControlType[3]) then
	    if(robotinfo.Used==0)then robotinfo.Used=1; end;
		Map3DSystem.Map.RobotDB.UpdateUserRobot(robotinfo);
		Map3DSystem.UI.RobotUIBase.RaceBtnClick_human();
		Map3DSystem.UI.RobotAnimation.Play(3);
	end
end
function Map3DSystem.UI.RobotUIBase.PrePage()
	local self=Map3DSystem.UI.RobotUIBase;
	if(self.CurIndex>0) then
		self.CurIndex=self.CurIndex-1;
	else
		self.CurIndex=self.PageLen;
	end
	
	self.SetTileList();
end
function Map3DSystem.UI.RobotUIBase.NextPage()
	local self=Map3DSystem.UI.RobotUIBase;
	if(self.CurIndex<self.PageLen) then
		self.CurIndex=self.CurIndex+1;
	else
		self.CurIndex=0;
	end
	
	self.SetTileList();
end
function Map3DSystem.UI.RobotUIBase.SetText()
	local self=Map3DSystem.UI.RobotUIBase;
	local PageNum_text=ParaUI.GetUIObject("PageNum_text");
	PageNum_text.text=string.format("%s/%s",(self.CurIndex+1),(self.PageLen+1));
end
function Map3DSystem.UI.RobotUIBase.GetRobotInfos(type)
	local self=Map3DSystem.UI.RobotUIBase;
	local	robots=nil;
	--buy
			if(self.CurControlType==self.ControlType[1]) then
				robots=Map3DSystem.Map.RobotDB.GetSystemRobots(type);
			--sale
			elseif(self.CurControlType==self.ControlType[2]) then
				robots=Map3DSystem.Map.RobotDB.GetUserRobots(type);
			--use
			elseif(self.CurControlType==self.ControlType[3]) then
				robots=Map3DSystem.Map.RobotDB.GetUserRobots(type);
			end
	return robots;
end
function Map3DSystem.UI.RobotUIBase.RaceBtnClick_human()
	local	robots=Map3DSystem.UI.RobotUIBase.GetRobotInfos(0);
			Map3DSystem.UI.RobotUIBase.Reset()
			Map3DSystem.UI.RobotUIBase.SetRobotInfos(robots)
			Map3DSystem.UI.RobotUIBase.SetTileList()
	local	StateInfo_text=ParaUI.GetUIObject("StateInfo_text");
			StateInfo_text.text="当前为：人物";		
end
function Map3DSystem.UI.RobotUIBase.RaceBtnClick_animal()
	local	robots=Map3DSystem.UI.RobotUIBase.GetRobotInfos(1)
			Map3DSystem.UI.RobotUIBase.Reset()
			Map3DSystem.UI.RobotUIBase.SetRobotInfos(robots)
			Map3DSystem.UI.RobotUIBase.SetTileList()
	local	StateInfo_text=ParaUI.GetUIObject("StateInfo_text");
			StateInfo_text.text="当前为：动物";
	
end
function Map3DSystem.UI.RobotUIBase.BuyBtnClick()
	local self=Map3DSystem.UI.RobotUIBase;
		  self.CurControlType=self.ControlType[1];
	      self.RaceBtnClick_human();
	      self.ControlBtnState();
end
function Map3DSystem.UI.RobotUIBase.SaleBtnClick()
	local self=Map3DSystem.UI.RobotUIBase;
		  self.CurControlType=self.ControlType[2];
		  self.RaceBtnClick_human();
		  self.ControlBtnState();
end
function Map3DSystem.UI.RobotUIBase.UseBtnClick()
	local self=Map3DSystem.UI.RobotUIBase;
		  self.CurControlType=self.ControlType[3];
		  self.RaceBtnClick_human();
		  self.ControlBtnState();
end

function Map3DSystem.UI.RobotUIBase.ControlBtnState()
	local self=Map3DSystem.UI.RobotUIBase;
	local Buy_btn=ParaUI.GetUIObject("Buy_btn");
	local Sale_btn=ParaUI.GetUIObject("Sale_btn");
	local Use_btn=ParaUI.GetUIObject("Use_btn");
	local Sure_btn=ParaUI.GetUIObject("Sure_btn");
	local texture=nil;
	--buy
	if(self.CurControlType==self.ControlType[1]) then
	--[[
		self.SetAlpha(Buy_btn,255);
		self.SetAlpha(Sale_btn,50);
		self.SetAlpha(Use_btn,50);
		--]]
		Sure_btn.text="我要购买";
		
	--sale
	elseif(self.CurControlType==self.ControlType[2]) then
	--[[
		self.SetAlpha(Buy_btn,50);
		self.SetAlpha(Sale_btn,255);
		self.SetAlpha(Use_btn,50);
		--]]
		Sure_btn.text="我要出售";
	--use
	elseif(self.CurControlType==self.ControlType[3]) then
	--[[
		self.SetAlpha(Buy_btn,50);
		self.SetAlpha(Sale_btn,50);
		self.SetAlpha(Use_btn,255);
		--]]
		Sure_btn.text="我要使用";
	end
end

function Map3DSystem.UI.RobotUIBase.ConvertRace(v)
	if(v==0) then
		return "人物"
	else
		return "动物"
	end
end
function Map3DSystem.UI.RobotUIBase.ConvertUsed(v)
	if(v==0) then
		return "可以"
	else
		return "不可以"
	end
end

function Map3DSystem.UI.RobotUIBase.SetAlpha(container,alpha)
	local texture=container:GetTexture("background");
	texture.transparency=alpha;--[0-255]
end
