--[[
Title: code behind for page CreationTab.html
Author(s): LiXizhi
Date: 2008/11/2
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aquarius/Desktop/CreationTab.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/Encoding.lua");
local CreationTab = {};
commonlib.setfield("MyCompany.Aquarius.CreationTab", CreationTab)

local page;
---------------------------------
-- page event handlers
---------------------------------

-- init
function CreationTab.OnInit()
	page = document:GetPageCtrl()
	-- register a onshow event
	commonlib.setfield("MyCompany.Aquarius.RibbonControl.OnShowCreationTab", function (bShow)
		if(bShow) then
			System.UI.AppDesktop.ChangeMode("edit");
			local filter = page:GetNodeValue("selection_filter", "0");
			CreationTab.SetPickingFilter(filter);
			
			-- hook into the "object" messages, so that we get informed whenever a object is selected/deselected in the scene.
			CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
				callback = CreationTab.Hook_SceneObjectSelected, 
				hookName = "HelloCreationSelectionHook", appName = "scene", wndName = "object"});
		else
			System.UI.AppDesktop.ChangeMode("chat");
			CreationTab.SetPickingFilter(nil);
			
			-- unhook from the "object"
			CommonCtrl.os.hook.UnhookWindowsHook({hookName = "HelloCreationSelectionHook", hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET})
			-- hide selection ribbon control
			if(CreationTab.rcEditObjTabs) then
				CreationTab.rcEditObjTabs:ShowTab(nil);
			end	
			
			-- NOTE: andy's BCS legacy code. When BCS is removed, also remove this
			if(type(commonlib.getfield("System.UI.Creator.OnDeactivate")) == "function") then
				System.UI.Creator.OnDeactivate();
			end
		end		
	end);
end

-- private: return shortName, longName
local function GetAssetDisplayName(obj)
	-- set name: first try the dynamic property, then the name property, finally the asset name
	local name = obj:GetAttributeObject():GetDynamicField("name", "");
	local assetname = obj:GetPrimaryAsset():GetKeyName();
	if(name=="") then name = obj.name end
	if(name == nil or name == "") then
		local _,_, assetnameShort = string.find(assetname, ".*[/\\]([^/\\]+)%..*$");
		if(assetnameShort~=nil) then 
			name = commonlib.Encoding.DefaultToUtf8(assetnameShort)
		end
	end
	return name, assetname;
end

-- "scene" object window hook. we will show object page accordingly. 
function CreationTab.Hook_SceneObjectSelected(nCode, appName, msg)
	
	if(msg.type == System.msg.OBJ_DeselectObject or msg.type == System.msg.OBJ_DeleteObject) then
		-- hide selection ribbon control
		if(CreationTab.rcEditObjTabs) then
			CreationTab.rcEditObjTabs:ShowTab(nil);
		end	
		-- NOTE: andy's BCS legacy code. When BCS is removed, also remove this
		if(type(commonlib.getfield("System.UI.Creator.OnDeactivate")) == "function") then
			System.UI.Creator.OnDeactivate();
		end
	elseif(msg.type == System.msg.OBJ_SelectObject) then
		-- shown selection ribbon control
		local obj = System.obj.GetObjectInMsg(msg);
		if(obj) then 
			--
			-- show the selection ribben control for the selected object: rcEditObjTabs
			--
			-- create ribbon manager for toolbar ribbon tabs
			if(not CreationTab.rcEditObjTabs) then
				NPL.load("(gl)script/ide/RibbonControl.lua");
				CreationTab.rcEditObjTabs = CommonCtrl.RibbonControl:new({
					name = "Aquarius.Creation.SelectRibbonControl",
					alignment = "_lb",
					left = 350+3,
					top = -35-46-38-4,
					width = 500,
					height = 38,
					parent = nil,
					tabs = {
						["CharEditTab"] = {file="script/apps/Aquarius/Roles/CharEditTab.html", onshow=nil, },
						["ModelEditTab"] = {file="script/apps/Aquarius/Roles/ModelEditTab.html", onshow=nil, },
					},
				});
			end
			
			if(obj:IsCharacter()) then
				-- show CharPropertyPage if none-player is selected. 
				CreationTab.rcEditObjTabs:ShowTab("CharEditTab");
				-- update name
				local _this = ParaUI.GetUIObject("Aquarius_edit_char_objname");
				if(_this:IsValid()) then
					local name, assetname = GetAssetDisplayName(obj)
					_this.text, _this.tooltip = name, "点击查看:"..tostring(assetname);
				end
			else -- model
				CreationTab.rcEditObjTabs:ShowTab("ModelEditTab");
				-- update name
				local _this = ParaUI.GetUIObject("Aquarius_edit_model_objname");
				if(_this:IsValid()) then
					local name, assetname = GetAssetDisplayName(obj)
					_this.text, _this.tooltip = name, "点击查看:"..tostring(assetname);
				end
				if(obj:GetNumReplaceableTextures() > 0) then
					-- CreationTab.rcEditObjTabs:ShowTab("ModelTextureEditTab");
				end
			end
		end	
		
		-- a different object is selected. we will update panel UI
        System.App.Commands.Call("Creation.UpdatePanels");
	end	
	return nCode
end

-- called whenever selected
local function OnObjectSelected_CallBack(curObj)
	if(curObj) then
	    local obj = System.obj.GetObject("selection");
	    local bSameAsLast;
        if(obj and obj:IsValid()) then
            -- deselect old one
            if(not obj:equals(curObj)) then
	            System.SendMessage_obj({type = System.msg.OBJ_DeselectObject, obj = nil});
	        else
	            bSameAsLast = true;
	        end
	    end 
		-- select current
		if(not bSameAsLast) then
			-- send select message
            System.SendMessage_obj({type = System.msg.OBJ_SelectObject, obj=curObj, group=-1, effect = "boundingbox"});
        end
    end
	return true;
end

-- called when picking filter changes.
function CreationTab.SetPickingFilter(filter)
    System.SendMessage_obj({type = System.msg.OBJ_PickObject, 
		filter = filter,
		-- callback. return true if allow next selection. 
		callbackFunc = OnObjectSelected_CallBack, 
	});
end


--------------
-- page event 
--------------
function CreationTab.OnSelectPickingFilter()
    local page = document:GetPageCtrl()
    local filter = page:GetUIValue("selection_filter", "0");
    page:SetNodeValue("selection_filter", filter);
    CreationTab.SetPickingFilter(filter);
end

function CreationTab.OnSelectionEdit()
   System.App.Commands.Call("Creation.Modify");
end

function CreationTab.OnSelectionProperty()
    -- change target. 
    local target = "selection"
    local selectObj = System.obj.GetObject(target);
    System.App.Creator.target = target;
	
	if(selectObj ~= nil and selectObj:IsValid()) then
		if(selectObj:IsCharacter()) then
			-- show CharPropertyPage if none-player is selected. 
			System.App.Commands.Call("Creation.CharProperty");
		else -- model
			if(selectObj:GetNumReplaceableTextures() > 0) then
				-- show ObjModifyPage as well
				System.App.Commands.Call("Creation.Modify");
				-- show ObjTexPropertyPage if model with replaceable texture (r2) is selected. 
				System.App.Commands.Call("Creation.ObjTexProperty");
			end
		end
	else
		-- close all panels if no object is selected. 
		System.App.Commands.Call("Creation.Modify", {bShow=false})
		System.App.Commands.Call("Creation.CharProperty", {bShow=false})
		System.App.Commands.Call("Creation.ObjTexProperty", {bShow=false})
	end
end

function CreationTab.OnSelectionDelete()
    local obj_params = System.obj.GetObjectParams("selection");
	if(obj_params~=nil) then
		System.SendMessage_obj({type = System.msg.OBJ_DeleteObject, obj_params = obj_params});
	end
end

function CreationTab.OnSelectionBuy()
end

function CreationTab.OnSelectionInfo()
	System.App.Commands.Call("File.MCMLWindowFrame", {
		url="script/apps/Aquarius/Assets/AssetInfoViewer.html",
		name = "HelloModelViewer",
		app_key = MyCompany.Aquarius.app.app_key, 
		text = "模型信息",
		icon = "Texture/3DMapSystem/common/lock.png",
		DestroyOnClose = true,
		directPosition = true,
			align = "_ct",
			x = -350/2,
			y = -480/2,
			width = 350,
			height = 480,
		bAutoSize = true,
	})
end