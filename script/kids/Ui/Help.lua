--[[
Title: quick help 
Author(s): LiXizhi
Date: 2006/12/3
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/ui/Help.lua");
KidsUI.ShowQuickHelp();
-------------------------------------------------------
]]
NPL.load("(gl)script/movie/VideoPlayerCtrl.lua");
local L = CommonCtrl.Locale("KidsUI");

-- KidsUI: Kids UI library 
if(not KidsUI) then KidsUI={}; end

-- toggle the display of the quick help window
-- @param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function KidsUI.ShowQuickHelp(bShow)
	local _this,_parent;
	
	local _this = ParaUI.GetUIObject("KidsUI_Quickhelp_cont")
	if(_this:IsValid() == false) then 
		if(bShow == false) then return	end
		
		_this=ParaUI.CreateUIObject("container","KidsUI_Quickhelp_cont", "_ct",-512,-384,1024,768);
		_this.background="Texture/whitedot.png;0 0 0 0";
		_this:SetTopLevel(true);
		_this:AttachToRoot();
		_parent = _this;
		
		-- tips of the day control is displayed here
		NPL.load("(gl)script/kids/ui/TipsOfDay.lua");
		local ctl = CommonCtrl.TipsOfDay:new{
			name = "quickhelp_F1",
			title = nil,
			alignment = "_ct",
			left=-512, top=-384,
			width = 1024,
			height = 768,
			imageLeft = 0,
			imageTop = 0,
			imageWidth = 1024,
			imageHeight = 768,
			pageindex = 1,
			content = kids_db.db_quickhelp,
			parent = _parent,
		};
		ctl:Show();

		-- the close button
		_this=ParaUI.CreateUIObject("button","btn", "_rb",-120, -50,100, 36);
		_parent:AddChild(_this);
		_this.onclick=";KidsUI.ShowQuickHelp(false);";
		_this.text = L"Close";
		_this = _parent;
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
	end
	
	if(_this.visible == true) then
		_this:SetTopLevel(true);
		KidsUI.PushState({name = "help", OnEscKey = "KidsUI.ShowQuickHelp(false);"});
	else
		KidsUI.PopState("help");
	end
end


-- show or hide an in-game video player.
-- @param filename: the media file to play, if nil, it will close the media player. 
function KidsUI.ShowInGameVideo(filename)
	local _this,_parent;
	
	local _this = ParaUI.GetUIObject("KidsUI_InGameVideo_cont");
	if(_this:IsValid() == false) then 
		if(not filename) then return end
		
		local width, height = 324,307;
		_this=ParaUI.CreateUIObject("container","KidsUI_InGameVideo_cont", "_lb",5,-500,width,height);
		_this.background="Texture/whitedot1.png;0 0 310 250";
		_this:AttachToRoot();
		_parent = _this;
		
		-- video player control is here
		local ctl = CommonCtrl.VideoPlayerCtrl:new{
			-- normal window size
			alignment = "_lt",
			left = 2,
			top = 30,
			width = 320,
			height = 272,
			videowidth = 320,
			videoheight = 240,
			-- parent UI object, nil will attach to root.
			parent = _parent,
			-- the top level control name
			name = "InGameVideo",
		}
		ctl:Show();
		
		-- the close button
		_this=ParaUI.CreateUIObject("button","btn", "_lt",width-32, 0,32, 32);
		_this.background="Texture/player/close.png";
		_parent:AddChild(_this);
		_this.onclick=";KidsUI.ShowInGameVideo(false);";
		_this = _parent;
	else
		if(filename == nil) then
			if(_this.visible == true) then
				_this.visible = false;
			else
				_this.visible = true;
			end
		else
			if(filename == false) then
				_this.visible = false;
			else
				_this.visible = true;
			end	
		end
	end
	if(_this.visible == true) then
		KidsUI_ShowMovieBox(false);
	end
	local ctl = CommonCtrl.GetControl("InGameVideo");
	if(ctl~=nil) then
		if(not filename) then
			ctl:LoadFile(nil);
		else
			ctl:LoadFile(filename);	
		end	
	end
end

-- show the tips of day icon on the right side control
function KidsUI.ShowTipsIcon(bShow)
	local _this;
	
	local _this = ParaUI.GetUIObject("KidsUI_TipsIcon");
	if(_this:IsValid() == false) then 
		if(bShow==false) then return end
		
		local width, height = 40,40;
		_this=ParaUI.CreateUIObject("button","KidsUI_TipsIcon", "_rb",-100,-240,width,height);
		_this.background="Texture/kidui/main/tips_icon.png";
		_this.tooltip = L"tips of the day";
		--_this.highlightstyle="4outsideArrow";
		_this.animstyle = 12;
		
		_this.onclick = [[;KidsUI.ShowTipsOfDay(nil, 1);]]
		_this:AttachToRoot();
	else
		if(bShow == nil) then
			if(_this.visible == true) then
				_this.visible = false;
			else
				_this.visible = true;
			end
		else
			_this.visible = bShow;
		end
	end
end

-- display the tips of day window
-- @param pageindex: the first page to display, such as 1.
function KidsUI.ShowTipsOfDay(bShow, pageindex)

	local _this;
	local _this = ParaUI.GetUIObject("KidsUI_TipsOfDay");
	if(_this:IsValid() == false) then 
		if(bShow==false) then return end
		
		local width, height=403, 331
		--_this=ParaUI.CreateUIObject("container","KidsUI_TipsOfDay", "_ct",90-width/2,-height/2,width, height);
		_this=ParaUI.CreateUIObject("container","KidsUI_TipsOfDay", "_lt",3,10,width, height);
		_this:AttachToRoot();
		_this.background="Texture/whitedot.png;0 0 0 0";
		--_guihelper.SetUIColor(_this, "255 255 255 20")
		_this.candrag = true;
		_parent = _this;
		
		local left, top = 0, 0
		width, height=190,41
		_this=ParaUI.CreateUIObject("container","c", "_lt",left, top, width, height);
		_this.background=L"Texture/kidui/main/tipsofday.png";
		_parent:AddChild(_this);
		
		_this=ParaUI.CreateUIObject("button","b", "_lt",left+width+30, 0, 40, 40);
		_this.background="Texture/player/close.png";
		_this.onclick = ";KidsUI.ShowTipsOfDay(false);";
		_parent:AddChild(_this);
		top = top + height;
		
		-- tips of the day control is displayed here
		NPL.load("(gl)script/kids/ui/TipsOfDay.lua");
		
		local ctl = CommonCtrl.TipsOfDay:new{
			name = "KidsUI_TipsOfDay_ctl",
			title = "",
			alignment = "_1t",
			left=0, top=top,
			width = 403,
			height = 290,
			imageWidth = 403,
			imageHeight = 256,
			pageindex = pageindex,
			content = kids_db.tipsofday,
			parent = _parent,
		};
		ctl:Show();	
		
		
	else
		if(bShow == nil) then
			if(_this.visible == true) then
				_this.visible = false;
			else
				_this.visible = true;
			end
		else
			_this.visible = bShow;
		end
	end
end