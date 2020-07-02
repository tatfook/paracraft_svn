--[[
Title: building customization system main entrance
Author(s): WangTian
Date: 2007/7/24
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/BCS/BCS_UI_Main.lua");
-------------------------------------------------------
]]


-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/BCS/BCS_db.lua");

NPL.load("(gl)script/kids/ui/middle_container.lua");
NPL.load("(gl)script/ide/object_editor.lua");

-- Debug purpose
NPL.load("(gl)script/ide/gui_helper.lua");

if(not BCS_main) then BCS_main={}; end

BCS_main.CurrentMarkerValid = false;
BCS_main.CurrentMarkerPosX = nil;
BCS_main.CurrentMarkerPosY = nil;
BCS_main.CurrentMarkerPosZ = nil;
BCS_main.CurrentMarkerFacing = nil;
BCS_main.CurrentMarkerType = nil;
BCS_main.CurrentMarkerLocalMatrix = nil;

BCS_main.CurrentEdit = nil;

function BCS_main.XRefShowType()
	--debug purpose
	if(BCS_main.CurrentMarkerType == BCS_db.MARKER_FREE_POINT) then
		_guihelper.MessageBox("Free Point");
	elseif(BCS_main.CurrentMarkerType == BCS_db.MARKER_WALL_POINT) then
		_guihelper.MessageBox("Wall Point");
	elseif(BCS_main.CurrentMarkerType == BCS_db.MARKER_BLOCKTOP_POINT) then
		_guihelper.MessageBox("Blocktop Point");
	elseif(BCS_main.CurrentMarkerType == BCS_db.MARKER_GROUND_POINT) then
		_guihelper.MessageBox("Ground Point");
	end
end

-- Called by each point(line) marker, already update the current marker info
function BCS_main.OnEnterEditMarker(msg)
	--_guihelper.MessageBox("Enter Marker");
	--BCS_main.XRefShowType();
	
	-- remove selected object, not delete
	ObjEditor.SetCurrentObj(nil);
	CommonCtrl.CKidLeftContainer.SwitchUI("environment");
	
	-- remove arrow from old character, if any
	if(KidsUI.LastSelectedCharacterName~=nil) then
		local lastplayer = ParaScene.GetCharacter(KidsUI.LastSelectedCharacterName);
		if(lastplayer:IsValid()==true)then
			lastplayer:ToCharacter():RemoveAttachment(11);
			KidsUI.LastSelectedCharacterName = nil;
		end
	end
	
	--reserved = {};
	--reserved.localMatrix = BCS_main.CurrentMarkerLocalMatrix;
	--reserved.facing = BCS_main.CurrentMarkerFacing;
	--BCS_main.CurrentEdit = ObjEditor.CreatePhysicsObject("EditMarkerPoint", 
		--"model/common/marker_point/marker_point.x", 
		--BCS_main.CurrentMarkerPosX, BCS_main.CurrentMarkerPosY, BCS_main.CurrentMarkerPosZ,
		--true, reserved);
		--
	--BCS_main.CurrentEdit:SetScaling(1.5);
	
	--ObjEditor.AutoCreateObject("n", ModelFilePath,pos,nil,true,localmatrix);

	-- Show user interface;
	CommonCtrl.CKidMiddleContainer.SwitchUI("BCSMenu");
	BCS_main.ShowUI();

	-- On***Click(): unmount old building block, mount ***ID building block
end

-- Called by each point(line) marker, already update the current marker info
function BCS_main.OnChangeEditMarker(msg)
	--BCS_main.XRefShowType();
	--_guihelper.MessageBox("Change Marker");
	CommonCtrl.CKidMiddleContainer.SwitchUI("BCSMenu");
	
	--BCS_main.CurrentEdit:SetPosition(BCS_main.CurrentMarkerPosX, BCS_main.CurrentMarkerPosY, BCS_main.CurrentMarkerPosZ);
	
	--local obj = ObjEditor.GetObject("EditMarkerPoint");
	--obj:SetPosition(BCS_main.CurrentMarkerPosX, BCS_main.CurrentMarkerPosY, BCS_main.CurrentMarkerPosZ);
	
	-- Show user interface;
	BCS_main.ShowUI();
	
	-- On***Click(): unmount old building block, mount ***ID building block
end

-- Called by each point(line) marker, already update the current marker info
function BCS_main.OnLeaveEditMarker()
	--_guihelper.MessageBox("Leave Marker");
	BCS_main.CurrentMarkerValid = false;
	BCS_main.CurrentMarkerPosX = nil;
	BCS_main.CurrentMarkerPosY = nil;
	BCS_main.CurrentMarkerPosZ = nil;
	BCS_main.CurrentMarkerFacing = nil;
	BCS_main.CurrentMarkerType = nil;
	
	--local obj = ObjEditor.GetObject("EditMarkerPoint");
	--ObjEditor.DelObject(obj);
	
	--ParaScene.Detach(BCS_main.CurrentEdit);
	--ParaScene.Delete(BCS_main.CurrentEdit);
	--
	--BCS_main.CurrentEdit = nil;
end

function BCS_main.UnmountCurrentMarkerBuildingBlock()
	local pos = {BCS_main.CurrentMarkerPosX,
			BCS_main.CurrentMarkerPosY,
			BCS_main.CurrentMarkerPosZ};
	local obj = ParaScene.GetObject(pos[1], pos[2], pos[3]);
	if(obj:IsValid() == true) then
		if(not CKidLeftContainer) then
			ObjEditor.DelObject(obj);
		else
			CKidLeftContainer.OnDeleteObject(obj);
		end
	end
end

function BCS_main.MountBuildingBlock(ID)
	local path = BCS_main.PathList[ID];
	local pos = {BCS_main.CurrentMarkerPosX,
			BCS_main.CurrentMarkerPosY,
			BCS_main.CurrentMarkerPosZ};
	reserved = {};
	reserved.localMatrix = BCS_main.CurrentMarkerLocalMatrix;
	reserved.facing = BCS_main.CurrentMarkerFacing;
	
	BCS_main.UnmountCurrentMarkerBuildingBlock()
	
	CommonCtrl.CKidItemsContainer.CreateItem(path, pos, nil, reserved);
end

function BCS_main.ShowUI()

	local BCSMainMenu = ParaUI.GetUIObject("kidui_bcs_container");

	ParaUI.Destroy("kidui_bcs_sub_container");
	
	local BCSIcon=ParaUI.CreateUIObject("container","kidui_bcs_sub_container","_fi",0,0,0,0);
	BCSMainMenu:AddChild(BCSIcon);
	BCSIcon.background="Texture/whitedot.png;0 0 0 0";
	
	_parent = BCSIcon;
	

_this = ParaUI.CreateUIObject("button", "btnBCSReset", "_rb", -64, -68, 64, 64)
--_this.text = "Reset";
_this.background="Texture/kidui/CCS/btn_BCS_Reset.png";
_this.onclick = ";BCS_main.UnmountCurrentMarkerBuildingBlock();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btnBCSPageRight", "_lt", 107, 3, 32, 32)
--_this.text = "->";
_this.background="Texture/kidui/CCS/btn_CCS_CF_Page_Right.png";
_this.onclick = ";BCS_main.PageRight();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("button", "btnBCSPageLeft", "_lt", 23, 3, 32, 32)
--_this.text = "<-";
_this.background="Texture/kidui/CCS/btn_CCS_CF_Page_Left.png";
_this.onclick = ";BCS_main.PageLeft();";
_parent:AddChild(_this);

_this = ParaUI.CreateUIObject("text", "labelBCSPage", "_lt", 61, 14, 40, 16)
_this.text = "0/0";
_parent:AddChild(_this);


		--local faceSectionType = BCS_mainComponent.GetFaceSection();
		
		BCS_main.PathList = BCS_db.GetBCSBlockPathList(BCS_main.CurrentMarkerType);
		local nCount = table.getn(BCS_main.PathList);

		--BCS_main.totalPage = 5;
		BCS_main.totalIcons = nCount;
		BCS_main.iconsPerPage = 16; -- 2*8 matrix
		
		local remain = math.mod(nCount, BCS_main.iconsPerPage);
		if(remain == 0) then
			BCS_main.totalPage = nCount / BCS_main.iconsPerPage;
		else
			BCS_main.totalPage = (nCount-remain) / BCS_main.iconsPerPage + 1;
		end
		
		if(nCount == 0) then
			BCS_main.totalPage = 1;
		end
		
		BCS_main.currentPage = 1;
		BCS_main.PageLeft();
		
end

-- Page Left
function BCS_main.PageLeft()

	local _this,_parent;
	
	if(BCS_main.currentPage > 0) then
	
		BCS_main.currentPage = BCS_main.currentPage - 1;
		local _thisCont = ParaUI.GetUIObject("kidui_bcs_sub_container");
		
		_this = _thisCont:GetChild("labelBCSPage");
		_this.text = (BCS_main.currentPage+1).."/"..BCS_main.totalPage;
		
		if(_thisCont:IsValid()) then
			local _container = _thisCont:GetChild("kidui_bcs_iconmatrix_container");
			local _currentIconNum;
			_currentIconNum = (BCS_main.currentPage)*(BCS_main.iconsPerPage);
			ParaUI.Destroy("kidui_bcs_iconmatrix_container");
			
			_this = ParaUI.CreateUIObject("container", "kidui_bcs_iconmatrix_container", "_lt", 0,47,500,150)
			_this.background="Texture/whitedot.png;0 0 0 0";
			_thisCont:AddChild(_this);
			
			_parent = _this;
			
			local initialTop = 0;
			local initialLeft = 20;
			local initialIconSize = 48;
			local initialMatrixX = 8;
			local initialMatrixY = 2;
			local initialGap = 3;
			local initialBGSize = 57;
			local initialIconOffset = 3;
			local posX, posY;
			
			for y=0, initialMatrixY-1 do
				for x=0, initialMatrixX-1 do
					if(_currentIconNum < BCS_main.totalIcons) then
						posX = initialLeft + x * (initialBGSize+initialGap);
						posY = initialTop + y * (initialBGSize+initialGap);
						_this = ParaUI.CreateUIObject("button", "btnMatrixBG"..y..x, "_lt", posX, posY, initialBGSize, initialBGSize)
						_this.background="Texture/kidui/CCS/btn_BCS_Icon_Slot.png";
						_parent:AddChild(_this);
						_this = ParaUI.CreateUIObject("button", "btnMatrix"..y..x, "_lt", posX+initialIconOffset, posY+initialIconOffset, initialIconSize, initialIconSize)
						--_this.text = "F"..(_currentIconNum+1);
						local page = BCS_main.currentPage;
						local pathNum = page*(BCS_main.iconsPerPage)+y*initialMatrixX+x+1;
						_this.background = BCS_main.PathList[pathNum]..".png";
						_this.animstyle = 22;
						_this.onclick = ";BCS_main.OnIconMatrixClick"..y..x.."();";
						_parent:AddChild(_this);
						_currentIconNum = _currentIconNum + 1;
					else
						posX = initialLeft + x * (initialBGSize+initialGap);
						posY = initialTop + y * (initialBGSize+initialGap);
						--_this = ParaUI.CreateUIObject("button", "btnMatrix"..y..x, "_lt", posX, posY, initialIconSize, initialIconSize)
						----_this.text = "F"..(_currentIconNum+1);
						--_this.background="Texture/kidui/CCS/btn_CCS_CF_CartoonSlot_Empty.png";
						_this = ParaUI.CreateUIObject("button", "btnMatrixBG"..y..x, "_lt", posX, posY, initialBGSize, initialBGSize)
						_this.background="Texture/kidui/CCS/btn_BCS_Icon_Slot_empty.png";
						_parent:AddChild(_this);
						_currentIconNum = _currentIconNum + 1;
					end
				end
			end
			
			
		end -- if(_this:IsValid()) then
		
	end -- if(BCS_main.currentPage > 1) then
	
end -- function BCS_main.PageLeft()


-- Page Right
function BCS_main.PageRight()

	local _this,_parent;
		
	if(BCS_main.currentPage < (BCS_main.totalPage-1) ) then
	
		BCS_main.currentPage = BCS_main.currentPage + 1;
		local _thisCont = ParaUI.GetUIObject("kidui_bcs_sub_container");
		
		_this = _thisCont:GetChild("labelBCSPage");
		_this.text = (BCS_main.currentPage+1).."/"..BCS_main.totalPage;
		
		
		if(_thisCont:IsValid()) then
			local _container = _thisCont:GetChild("kidui_bcs_iconmatrix_container");
			local _currentIconNum;
			_currentIconNum = (BCS_main.currentPage)*(BCS_main.iconsPerPage);
			ParaUI.Destroy("kidui_bcs_iconmatrix_container");
			
			_this = ParaUI.CreateUIObject("container", "kidui_bcs_iconmatrix_container", "_lt", 0,47,500,150)
			_this.background="Texture/whitedot.png;0 0 0 0";
			_thisCont:AddChild(_this);
			
			_parent = _this;
			
			local initialTop = 0;
			local initialLeft = 20;
			local initialIconSize = 48;
			local initialMatrixX = 8;
			local initialMatrixY = 2;
			local initialGap = 3;
			local initialBGSize = 57;
			local initialIconOffset = 3;
			local posX, posY;
			local posX, posY;
			
			for y=0, initialMatrixY-1 do
				for x=0, initialMatrixX-1 do
					if(_currentIconNum < BCS_main.totalIcons) then
						posX = initialLeft + x * (initialBGSize+initialGap);
						posY = initialTop + y * (initialBGSize+initialGap);
						_this = ParaUI.CreateUIObject("button", "btnMatrixBG"..y..x, "_lt", posX, posY, initialBGSize, initialBGSize)
						_this.background="Texture/kidui/CCS/btn_BCS_Icon_Slot.png";
						_parent:AddChild(_this);
						_this = ParaUI.CreateUIObject("button", "btnMatrix"..y..x, "_lt", posX+initialIconOffset, posY+initialIconOffset, initialIconSize, initialIconSize);
						--_this.text = "F"..(_currentIconNum+1);
						local page = BCS_main.currentPage;
						local pathNum = page*(BCS_main.iconsPerPage)+y*initialMatrixX+x+1;
						_this.background = BCS_main.PathList[pathNum]..".png";
						_this.animstyle = 22;
						_this.onclick = ";BCS_main.OnIconMatrixClick"..y..x.."();";
						_parent:AddChild(_this);
						_currentIconNum = _currentIconNum + 1;
					else
						posX = initialLeft + x * (initialBGSize+initialGap);
						posY = initialTop + y * (initialBGSize+initialGap);
						--_this = ParaUI.CreateUIObject("button", "btnMatrix"..y..x, "_lt", posX, posY, initialIconSize, initialIconSize)
						----_this.text = "F"..(_currentIconNum+1);
						--_this.background="Texture/kidui/CCS/btn_CCS_CF_CartoonSlot_Empty.png";
						
						_this = ParaUI.CreateUIObject("button", "btnMatrixBG"..y..x, "_lt", posX, posY, initialBGSize, initialBGSize)
						_this.background="Texture/kidui/CCS/btn_BCS_Icon_Slot_empty.png";
						_parent:AddChild(_this);
						_currentIconNum = _currentIconNum + 1;
					end
				end
			end
			
			
		end -- if(_this:IsValid()) then
		
	end -- if(BCS_main.currentPage < (BCS_main.totalPage-1) ) then
	
end -- function BCS_main.PageRight()


-- function[16]: icon matrix onclick function
function BCS_main.OnIconMatrixClick00()
	local page = BCS_main.currentPage;
	local pathNum = page*(BCS_main.iconsPerPage)+1;
	BCS_main.MountBuildingBlock(pathNum)
end

function BCS_main.OnIconMatrixClick01()
	local page = BCS_main.currentPage;
	local pathNum = page*(BCS_main.iconsPerPage)+2;
	BCS_main.MountBuildingBlock(pathNum)
end

function BCS_main.OnIconMatrixClick02()
	local page = BCS_main.currentPage;
	local pathNum = page*(BCS_main.iconsPerPage)+3;
	BCS_main.MountBuildingBlock(pathNum)
end

function BCS_main.OnIconMatrixClick03()
	local page = BCS_main.currentPage;
	local pathNum = page*(BCS_main.iconsPerPage)+4;
	BCS_main.MountBuildingBlock(pathNum)
end

function BCS_main.OnIconMatrixClick04()
	local page = BCS_main.currentPage;
	local pathNum = page*(BCS_main.iconsPerPage)+5;
	BCS_main.MountBuildingBlock(pathNum)
end

function BCS_main.OnIconMatrixClick05()
	local page = BCS_main.currentPage;
	local pathNum = page*(BCS_main.iconsPerPage)+6;
	BCS_main.MountBuildingBlock(pathNum)
end

function BCS_main.OnIconMatrixClick06()
	local page = BCS_main.currentPage;
	local pathNum = page*(BCS_main.iconsPerPage)+7;
	BCS_main.MountBuildingBlock(pathNum)
end

function BCS_main.OnIconMatrixClick07()
	local page = BCS_main.currentPage;
	local pathNum = page*(BCS_main.iconsPerPage)+8;
	BCS_main.MountBuildingBlock(pathNum)
end


function BCS_main.OnIconMatrixClick10()
	local page = BCS_main.currentPage;
	local pathNum = page*(BCS_main.iconsPerPage)+9;
	BCS_main.MountBuildingBlock(pathNum)
end

function BCS_main.OnIconMatrixClick11()
	local page = BCS_main.currentPage;
	local pathNum = page*(BCS_main.iconsPerPage)+10;
	BCS_main.MountBuildingBlock(pathNum)
end

function BCS_main.OnIconMatrixClick12()
	local page = BCS_main.currentPage;
	local pathNum = page*(BCS_main.iconsPerPage)+11;
	BCS_main.MountBuildingBlock(pathNum)
end

function BCS_main.OnIconMatrixClick13()
	local page = BCS_main.currentPage;
	local pathNum = page*(BCS_main.iconsPerPage)+12;
	BCS_main.MountBuildingBlock(pathNum)
end

function BCS_main.OnIconMatrixClick14()
	local page = BCS_main.currentPage;
	local pathNum = page*(BCS_main.iconsPerPage)+13;
	BCS_main.MountBuildingBlock(pathNum)
end

function BCS_main.OnIconMatrixClick15()
	local page = BCS_main.currentPage;
	local pathNum = page*(BCS_main.iconsPerPage)+14;
	BCS_main.MountBuildingBlock(pathNum)
end

function BCS_main.OnIconMatrixClick16()
	local page = BCS_main.currentPage;
	local pathNum = page*(BCS_main.iconsPerPage)+15;
	BCS_main.MountBuildingBlock(pathNum)
end

function BCS_main.OnIconMatrixClick17()
	local page = BCS_main.currentPage;
	local pathNum = page*(BCS_main.iconsPerPage)+16;
	BCS_main.MountBuildingBlock(pathNum)
end
