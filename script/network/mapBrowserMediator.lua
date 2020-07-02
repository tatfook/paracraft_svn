NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/network/explorerWnd.lua");
NPL.load("(gl)script/ide/CheckBox.lua");
NPL.load("(gl)script/network/mapSet.lua");
NPL.load("(gl)script/mapMarkProvider.lua");
NPL.load("(gl)script/network/mapMarkWnd.lua");


local mapExplorerMediator = {
	ctrMapBrowser = nil,
	ctrSideBar = nil,
	midBar = nil,
	state = 1,
	activeMarkID = nil,
	keywords = "",
}
CommonCtrl.mapExplorerMediator = mapExplorerMediator;

function mapExplorerMediator:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function mapExplorerMediator:OnMarkClick(ctrName)
	if( self.ctrMapBrowser == nil or self.ctrSideBar == nil)then
		log("mapExplorerMediator members can not be nil-_-# \r\n");
		return
	end
	
	local mark = CommonCtrl.GetControl(ctrName);
	if( mark == nil)then
		log("err getting mapMark instance -_- \r\n");
		return;
	end	
	 
	local mapContainer = ParaUI.GetUIObject(self.ctrMapBrowser.name);
	if( mapContainer:IsValid() == false)then
		log(self.ctrMapBrowser.name.." can not found -_- \r\n");
		return;
	end
	
	local __,__,width,height = mapContainer:GetAbsPosition();
	local _left,_top = mark:GetPosition(); 
	
	if( (width - _left - 20) < markDetailWnd:GetWidth())then
		_left = _left - markDetailWnd:GetWidth() - 20;
	else
		_left = _left + 20;
	end
	
	if( (height - _top) < markDetailWnd:GetHeight())then
		_top = _top - markDetailWnd:GetHeight();
	end
	
	markDetailWnd:SetPosition(_left,_top);
	markDetailWnd:SetData(mark:GetMarkInfo());
	markDetailWnd:Show(true);

	ParaUI.GetUIObject(self.ctrMapBrowser.name.."markLable").visible = false;
end
 
function mapExplorerMediator:OnEnterMark(ctrName)
	if( self.ctrMapBrowser == nil or self.ctrSideBar == nil)then
		log("mapExplorerMediator members can not be nil-_-# \r\n");
		return
	end
	
	local mark = CommonCtrl.GetControl(ctrName);
	if( mark == nil)then
		log("err getting mapMark instance -_- \r\n");
		return;
	end
	
	local mapContainer = ParaUI.GetUIObject(self.ctrMapBrowser.name);
	if( mapContainer:IsValid() == false)then
		log(self.ctrMapBrowser.name.." can not found -_- \r\n");
		return;
	end
	
	local __,__,width,height = mapContainer:GetAbsPosition();
	local _left,_top = mark:GetPosition();

	_left = ( _left < (width/2) and (_left + 30)) or (_left - 40);
	_top = ( _top < (width/2) and (_top + 30)) or _top;
	
	local _markLable = ParaUI.GetUIObject(self.ctrMapBrowser.name.."markLable");
	_markLable.x = _left;
	_markLable.y = _top;
	_markLable.text = mark:GetMarkInfo():GetMarkID();
	_markLable.visible = true;
end

function mapExplorerMediator:OnLeaveMark(ctrName)
	if( self.ctrMapBrowser == nil or self.ctrSideBar == nil)then
		log("mapExplorerMediator members can not be nil-_-# \r\n");
		return
	end
	
	local _markLable = ParaUI.GetUIObject(self.ctrMapBrowser.name.."markLable");
	_markLable.visible = false;
end

function mapExplorerMediator:ShowMyWorld(ctrName)
	markDetailWnd:Show(false);
	markInfo_db.ActiveLocalDB(true);
	self.state = 2;	
	self.ctrMapBrowser:ResetViewRegion();
	
	local _listbox = ParaUI.GetUIObject(self.ctrSideBar.name.."myWorldWndlbMyFavor");
	if(_listbox:IsValid() == false)then
		log("err getting myWorldWnd listbox -_-# \r\n");
		return;
	end
	
	_listbox:RemoveAll();
	 local marks = markInfo_db.SearchAll("");
	 if(marks ~= nil)then
		 local i = 1;
		 while( marks[i]~=nil )do
			_listbox:AddTextItem(marks[i]:GetMarkID());
			i = i+1;
		end
	end
end

function mapExplorerMediator:ShowWorldMap(ctrName)
	markDetailWnd:Show(false);
	markInfo_db.ActiveLocalDB(false);
	self.state = 1;
	self.ctrMapBrowser:ResetViewRegion();
end

function mapExplorerMediator:OnItemClick( itemText )
	if (itemText == "" or itemText ==nil)then
		log("error getting select markid -_-# \r\rn");
		return;
	end
	
	self.activeMarkID = itemText;
	local activeMark = markInfo_db.Select(itemText);
	if( activeMark == nil)then
		log("activeMark can not be nil\r\n");
		return;
	end

	if( self.ctrMapBrowser:IsInViewRegion(activeMark:GetCoordinate()))then

	end
	
	local activeMark = self.ctrMapBrowser:GetMarkByID(itemText);
	if( activeMark ~= nil)then
		self:OnMarkClick(activeMark.name);
	end
end

function mapExplorerMediator:Search()
	self:FillWorldMapMarks();
	
	local inputWnd = ParaUI.GetUIObject(self.ctrSideBar.name.."mapSearchWndedtKeyword");
	if( inputWnd == nil)then
		log("err getting input edit instance -_- \r\n");
		return;
	end
	self.keywords = inputWnd.text;
	
	local _listbox = ParaUI.GetUIObject(self.ctrSideBar.name.."mapSearchWndsearchResult");
	if(_listbox:IsValid() == false)then
		log("err getting worldWnd listbox -_-# \r\n");
		return;
	end
	
	--fill the listbox with rearch result
	_listbox:RemoveAll();
	local marks = markInfo_db.SearchAll(self.keywords,true);
	local i = 1;	
	if( marks ~= nil)then
		while( i<200 and marks[i]~= nil)do
			_listbox:AddTextItem( marks[i]:GetMarkID());
			i = i + 1;
		end
	end
	
	if( i < 200)then
		marks = markInfo_db.SearchAll(self.keywords,false);
		if( marks ~= nil)then
			local j = 1;
			while( i < 200 and marks[j] ~=nil)do
				_listbox:AddTextItem( marks[j]:GetMarkID() );
				i = i + 1;
				j = j + 1;
			end
		end
	end
end

function mapExplorerMediator:OnViewRegionChange(ctrName)
	local inputWnd = ParaUI.GetUIObject(self.ctrSideBar.name.."mapSearchWndedtKeyword");
	if( inputWnd == nil)then
		log("err getting input edit instance -_- \r\n");
		return;
	end
	
	local marks = {};
	
	--for world map
	if( self.state == 1)then
		self:FillWorldMapMarks();
	--for my map
	elseif( self.state == 2)then
		marks = markInfo_db.SelectMarkInRegion(self.ctrMapBrowser:GetViewRegion());
		if( marks ~= nil)then
			for i,v in ipairs(marks) do
				v:SetEditable(true);
			end
		end
		self.ctrMapBrowser:UpdateMapMarks(marks);			
	end
end

function mapExplorerMediator:OnZoomInBtnClick()
	if(self.ctrMapBrowser == nil)then
		return;
	end
	
	self.ctrMapBrowser:Zoom( self.ctrMapBrowser:GetZoomSpan());
end

function mapExplorerMediator:OnZoomOutBtnClick()
	if(self.ctrMapBrowser == nil)then
		return;
	end
	
	self.ctrMapBrowser:Zoom( -self.ctrMapBrowser:GetZoomSpan());	
end

function mapExplorerMediator:OnResetBtnClick()
	if(self.ctrMapBrowser == nil)then
		return;
	end
	self.keywords = "";	
	self.ctrMapBrowser:ResetViewRegion();
	
	if(self.ctrSideBar == nil)then
		return;
	end
	self.ctrSideBar.ShowWorldMap(self.ctrSideBar.name)
	
	local _this = CommonCtrl.GetControl(self.ctrSideBar.name.."mapSearchWnd");
	if( _this == nil)then
		return;
	end
	_this:ShowStartUpWnd(true);
	
	local _this = ParaUI.GetUIObject(_this.name.."edtKeyword");
	if( _this:IsValid() == false)then
		log("nil\n");
		return;
	end
	_this.text = "";
end

function mapExplorerMediator:FillWorldMapMarks()
	if( self.ctrMapBrowser == nil)then
		return;
	end
	
	if( self.keywords == nil)then
		log("keywords can not be nil..-_-#\r\n");
		return;
	end
	
	--search marks in current view region,
	--if the keyworld ~= "", then change the mark color to red
	local i = 1;
	local marks = markInfo_db.SearchMarkInRegion(self.keywords,true,self.ctrMapBrowser:GetViewRegion());
	if( marks ~= nil)then
		if(self.keywords ~= "")then
			while( marks[i]~=nil )do
				marks[i]:SetMarkStyle("Texture/worldMap/mark_5.png");
				marks[i]:SetEditable(false);
				i = i+1;
			end
		end
		
		--if the matched marks in current view region less than max mark number,
		--fill the rest marks with unmatched mark
		i = table.getn(marks);
		local others;
		if( i < self.ctrMapBrowser:GetMaxMarkCount())then
			others = markInfo_db.SearchMarkInRegion(self.keywords,false,self.ctrMapBrowser:GetViewRegion());
			if( others ~= nil)then
				local  j = 1;
				while( i < self.ctrMapBrowser:GetMaxMarkCount() and others[j] ~= nil)do
					i = i + 1;
					others[j]:SetEditable(false);
					marks[i] = others[j];
					j = j + 1;
				end
			end
		end
	end
	self.ctrMapBrowser:UpdateMapMarks(marks);
end

function mapExplorerMediator:AddMark2Favor(_markID)
	local mark = markInfo_db.Select(_markID);
	markInfo_db.ActiveLocalDB(true);
	markInfo_db.Insert(mark);
	markInfo_db.ActiveLocalDB(false);
end

function mapExplorerMediator:ChangeMarkPos(x,y,markInfo)
	local ctnParent = ParaUI.GetUIObject( self.ctrMapBrowser.name);
	if( ctnParent:IsValid()==false)then
		return;
	end
	local left,top = ctnParent:GetAbsPosition();
	x = x - left + self.ctrMapBrowser.cellPos_lt.x;
	y = y - top + self.ctrMapBrowser.cellPos_lt.y;
	x = (x + 16)*self.ctrMapBrowser.cell2TexScale.x * math.pow( 2,self.ctrMapBrowser.mapset:GetLayerCount() - self.ctrMapBrowser.mapset:GetActiveLayerCount());
	y = (y + 32)*self.ctrMapBrowser.cell2TexScale.y * math.pow( 2,self.ctrMapBrowser.mapset:GetLayerCount() - self.ctrMapBrowser.mapset:GetActiveLayerCount());
	
	markInfo:SetCoordinate(x,y);
	markInfo_db.Update(markInfo);
end

function mapExplorerMediator:EditMyMap()
end

