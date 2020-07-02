--[[
Title: product log page UI, 
Author(s): LiXizhi
Date: 2006/12/1
Desc: this page is shown when application starts or exits. User needs to press anykey to exit. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/ui/product_logo.lua");
KidsUI.ShowLogoPage(1);
------------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/OneTimeAsset.lua");

local L = CommonCtrl.Locale:new("KidsUI");

if(not KidsUI) then KidsUI={}; end
KidsUI.CurrentLogoPage = nil;
KidsUI.LogoTimerID = 11234;
KidsUI.LogoTimerCount = 0;
KidsUI.pageindex = nil;
KidsUI.LogoTimerKeyDownCount = 240;
KidsUI.LastAssetName = nil;
KidsUI.items = {
	["logo"] = L"Texture/ParaEngineLogo.png",
	["product cover"] = L"Texture/productcover.png",
	["product exit"] = L"Texture/product_exitpage.png",
}

-- @param KeyDownCount: if this is nil, the page will always be displayed until the user presses a key,
-- otherise KeyDownCount can be the frame number after which a virtual key down event will be fired. 30 means a second
function KidsUI.NextLogoPage(KeyDownCount)
	if(KidsUI.CurrentLogoPage == nil) then
		KidsUI.ShowLogoPage(1,KeyDownCount)
	else	
		KidsUI.ShowLogoPage(KidsUI.CurrentLogoPage+1,KeyDownCount)
	end
end

-- @param pageindex: if nil, the logo page will be closed
-- @param KeyDownCount: if this is nil, the page will always be displayed until the user presses a key,
-- otherise KeyDownCount can be the frame number after which a virtual key down event will be fired. 30 means a second
function KidsUI.ShowLogoPage(pageindex, KeyDownCount)
	local _this,_parent,__font,__texture;
	KidsUI.pageindex = pageindex;
	KidsUI.LogoTimerKeyDownCount = KeyDownCount;
	if(pageindex == nil) then
		ParaUI.Destroy("KidsUI_logo_cont");
		KidsUI.CurrentLogoPage =nil;
	elseif(pageindex>=1 and pageindex <=2 or pageindex==101) then
		KidsUI.CurrentLogoPage = pageindex;
		ParaUI.Destroy("KidsUI_logo_cont");
		_parent=ParaUI.CreateUIObject("container","KidsUI_logo_cont", "_fi",0,0,0,0);
		_parent.background="Texture/whitedot.png;0 0 0 0";
		_parent:AttachToRoot();
		
		if(pageindex == 1) then
			-- ParaEngine Studio Logo Page
			
			
			_this=ParaUI.CreateUIObject("container","PE logo", "_ct",-256,-128,512,256);
			_this.background=KidsUI.items["logo"];
			_parent:AddChild(_this);
			CommonCtrl.OneTimeAsset.Add("PE Logo", KidsUI.items["logo"])
			
			-- a white canvas to gradually fade-in the screen content.
			if(ParaUI.GetUIObject("white_canvas"):IsValid() == false) then
				_this=ParaUI.CreateUIObject("container","white_canvas", "_lt",0,0,_parent.width,_parent.height);
				_this.background="Texture/whitedot.png";
				_parent:AddChild(_this);
				-- register a timer for updates
				NPL.SetTimer(KidsUI.LogoTimerID, 0.03, ";KidsUI.LogoTimer();");
			end	
			
			-- Any key click to continue
			_this=ParaUI.CreateUIObject("text","any_key_tocontinue", "_rb",-200,-30,200,25);
			_parent:AddChild(_this);
			--_this.text=L"Press Any Key to Continue";
			--_guihelper.SetUIColor(_this, "255 255 100 50");
			
			-- any mouse click to continue, this is rather application specific, remove this line.
			_this=ParaUI.CreateUIObject("button","b", "_fi",0,0,0,0);
			_parent:AddChild(_this);
			_this.background="Texture/whitedot.png;0 0 0 0";
			_this.onclick = ";KidsUI_OnKeyDownEvent()";
			
			KidsUI.LogoTimerCount = 0;
		elseif(pageindex == 2) then
			
			_this=ParaUI.CreateUIObject("container","PE logo", "_fi",0,0,0,0);
			_this.background=KidsUI.items["product cover"];
			_parent:AddChild(_this);
			CommonCtrl.OneTimeAsset.Add("PE Logo", KidsUI.items["product cover"])
			
			-- a white canvas to gradually fade-in the screen content.
			if(ParaUI.GetUIObject("white_canvas"):IsValid() == false) then
				_this=ParaUI.CreateUIObject("container","white_canvas", "_lt",0,0,_parent.width,_parent.height);
				_this.background="Texture/whitedot.png";
				_parent:AddChild(_this);
				-- register a timer for updates
				NPL.SetTimer(KidsUI.LogoTimerID, 0.03, ";KidsUI.LogoTimer();");
			end	
			
			-- Any key to continue
			_this=ParaUI.CreateUIObject("text","any_key_tocontinue", "_rb",-200,-30,200,25);
			_parent:AddChild(_this);
			--_this.text=L"Press Any Key to Continue";
			_this.background="Texture/whitedot.png;0 0 0 0";
			--_guihelper.SetUIColor(_this, "255 255 100 50");
			
			-- any mouse click to continue, this is rather application specific, remove this line.
			_this=ParaUI.CreateUIObject("button","b", "_fi",0,0,0,0);
			_parent:AddChild(_this);
			_this.background="Texture/whitedot.png;0 0 0 0";
			_this.onclick = ";KidsUI_OnKeyDownEvent()";
			
			KidsUI.LogoTimerCount = 0;
		
		elseif(pageindex==101) then	
			-- for exiting page to be displayed last
			_this=ParaUI.CreateUIObject("container","PE logo", "_fi",0,0,0,0);
			_this.background=KidsUI.items["product exit"];
			_parent:AddChild(_this);
			CommonCtrl.OneTimeAsset.Add("PE Logo", KidsUI.items["product exit"])
			
			-- a white canvas to gradually fade-in the screen content.
			if(ParaUI.GetUIObject("white_canvas"):IsValid() == false) then
				_this=ParaUI.CreateUIObject("container","white_canvas", "_lt",0,0,_parent.width,_parent.height);
				_this.background="Texture/whitedot.png";
				_parent:AddChild(_this);
				-- register a timer for updates
				NPL.SetTimer(KidsUI.LogoTimerID, 0.03, ";KidsUI.LogoTimer();");
			end	
			
			-- Any key to continue
			_this=ParaUI.CreateUIObject("text","any_key_tocontinue", "_rb",-200,-30,200,25);
			_parent:AddChild(_this);
			--_this.text=L"Press Any Key to Continue";
			_this.background="Texture/whitedot.png;0 0 0 0";
			--_guihelper.SetUIColor(_this, "255 255 100 50");
			
			-- any mouse click to continue, this is rather application specific, remove this line.
			_this=ParaUI.CreateUIObject("button","b", "_fi",0,0,0,0);
			_parent:AddChild(_this);
			_this.background="Texture/whitedot.png;0 0 0 0";
			_this.onclick = ";KidsUI_OnKeyDownEvent()";
			
			KidsUI.LogoTimerCount = 0;
		end	
	else
		ParaUI.Destroy("KidsUI_logo_cont");
		KidsUI.CurrentLogoPage =nil;
	end
	if(KidsUI.CurrentLogoPage~=nil) then
		KidsUI.PushState("product_logo");
	else
		CommonCtrl.OneTimeAsset.Add("PE Logo", nil);
		KidsUI.PopState("product_logo");
	end	
end

function KidsUI.LogoTimer()
	local temp = ParaUI.GetUIObject("KidsUI_logo_cont");
	if(temp:IsValid() == false) then
		NPL.KillTimer(KidsUI.LogoTimerID);
	end
	
	KidsUI.LogoTimerCount = KidsUI.LogoTimerCount+1;
	
	if(KidsUI.LogoTimerKeyDownCount~=nil and KidsUI.LogoTimerKeyDownCount<KidsUI.LogoTimerCount) then
		KidsUI.LogoTimerKeyDownCount = nil;
		virtual_key = Event_Mapping.EM_KEY_SPACE;
		KidsUI_OnKeyDownEvent(); -- fire a virtual event
		return
	end
	
	temp = ParaUI.GetUIObject("white_canvas");
	if(temp:IsValid() == true) then
		local texture;
		local alpha = KidsUI.LogoTimerCount*5;
		if(alpha>255) then
			alpha = 255;
			ParaUI.Destroy("white_canvas");
			return
		end	
		alpha = 255-alpha;
		local color=string.format("255 255 255 %d", alpha);
		texture=temp:GetTexture("background");
		texture.color=color;		
	end
end

