--[[
Title: object modification page code behind file
Author(s): LiXizhi
Date: 2008/6/11
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/Creator/ObjModifyPage.lua");
-- call below to load window
Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
	url="script/kids/3DMapSystemUI/Creator/ObjModifyPage.html", name="ObjModifyPage", 
	app_key=Map3DSystem.App.appkeys["Creator"], 
	isShowTitleBar = false, 
	isShowToolboxBar = false, 
	isShowStatusBar = false, 
	initialWidth = 200, 
	alignment = "Left", 
});
Map3DSystem.App.Creator.ObjModifyPage.UpdatePanelUI()
------------------------------------------------------------
]]

local ObjModifyPage = {};
commonlib.setfield("Map3DSystem.App.Creator.ObjModifyPage", ObjModifyPage)

--
function ObjModifyPage.OnInit()

end

-- update the tranlation rotation scaling shift reset and canvas UI according to the current selected object
function ObjModifyPage.UpdatePanelUI()
	local _translate = ParaUI.GetUIObject("map3dsystem_modify_translate_btn");
	if(_translate:IsValid()) then
		local _rotate = ParaUI.GetUIObject("map3dsystem_modify_rotate_btn");
		local _magnify = ParaUI.GetUIObject("map3dsystem_modify_magnify_btn");
		local _minify = ParaUI.GetUIObject("map3dsystem_modify_minify_btn");
		local _here = ParaUI.GetUIObject("map3dsystem_modify_here_btn");
		local _reset = ParaUI.GetUIObject("map3dsystem_modify_reset_btn");
		local _possession = ParaUI.GetUIObject("map3dsystem_modify_possession_btn");
		local _property = ParaUI.GetUIObject("map3dsystem_modify_property_btn");
		local _delete = ParaUI.GetUIObject("map3dsystem_modify_delete_btn");
	
		local obj = Map3DSystem.obj.GetObjectParams(Map3DSystem.App.Creator.target);
		if(obj ~= nil) then
			if(obj.IsCharacter) then
				_translate.enabled = false;
				_rotate.enabled = false;
				_magnify.enabled = true;
				_minify.enabled = true;
				_here.enabled = false;
				_reset.enabled = false;
				_possession.enabled = true;
				_property.enabled = true;
				_delete.enabled = true;
			else
				_translate.enabled = true;
				_rotate.enabled = true;
				_magnify.enabled = true;
				_minify.enabled = true;
				_here.enabled = true;
				_reset.enabled = true;
				_possession.enabled = false;
				_property.enabled = true;
				_delete.enabled = true;
			end
		else
			_translate.enabled = false;
			_rotate.enabled = false;
			_magnify.enabled = false;
			_minify.enabled = false;
			_here.enabled = false;
			_reset.enabled = false;
			_possession.enabled = false;
			_property.enabled = false;
			_delete.enabled = false;
		end
		
		-- update the object canvas with selected object
		local ctl = CommonCtrl.GetControl("Map3dsystem_Modify_Obj_Canvas3D");
		if(ctl ~= nil) then
			if(obj == nil) then
				ctl:ShowModel();
			else
				local setBackName = obj.name;
				obj.name = nil;
				ctl:ShowModel(obj);
				obj.name = setBackName;
			end
		end
	end	
end


function ObjModifyPage.BeginMouseHoldTimer(params)
	if(params) then
		ObjModifyPage.last_obj_params = {type = params.type, obj_params = params.obj_params, pos_delta_camera = params.pos_delta_camera, rot_delta = params.rot_delta};
	end
	ObjModifyPage.mouse_timer = ObjModifyPage.mouse_timer or commonlib.Timer:new({callbackFunc = ObjModifyPage.OnMouseHoldTimer})
	ObjModifyPage.mouse_timer:Change(300, 100);
end

function ObjModifyPage.EndMouseHoldTimer()
	if(ObjModifyPage.mouse_timer) then
		ObjModifyPage.mouse_timer:Change();
	end
end

function ObjModifyPage.OnMouseHoldTimer()
	if(ObjModifyPage.last_obj_params) then
		Map3DSystem.SendMessage_obj({
			type = ObjModifyPage.last_obj_params.type,
			obj_params = ObjModifyPage.last_obj_params.obj_params, --  Map3DSystem.obj.GetObjectParams(Map3DSystem.App.Creator.target),
			pos_delta_camera = ObjModifyPage.last_obj_params.pos_delta_camera,
			rot_delta = ObjModifyPage.last_obj_params.rot_delta,
		});
	end
end

-- Event handler: on object translation
function ObjModifyPage.OnTranslationMouseDown2()
	ParaAudio.PlayUISound("Btn5");
	
	local temp = ParaUI.GetUIObject("map3dsystem_modify_translate_btn_2");
	
	if(temp:IsValid()==true) then
		-- get relative click position in control
		local x,y, width, height = temp:GetAbsPosition();
		x,y = mouse_x - x, mouse_y - y;
		
		x, y = x * 128 / width, y * 128 / height; -- scale 128/controlsize
		
		-- we will use distance to array heads to determine which arrow is being selected. 
		local dist1,dist2;
		local nSel = 1;
		dist1 = (x-16)^2+(y-36)^2; --1
		dist2 = (x-14)^2+(y-90)^2; --2
		if(dist2<dist1) then nSel = 2;dist1 = dist2; end
		dist2 = (x-64)^2+(y-114)^2; --3
		if(dist2<dist1) then nSel = 3;dist1 = dist2; end
		dist2 = (x-113)^2+(y-91)^2; --4
		if(dist2<dist1) then nSel = 4;dist1 = dist2; end
		dist2 = (x-113)^2+(y-35)^2; --5
		if(dist2<dist1) then nSel = 5;dist1 = dist2; end
		dist2 = (x-64)^2+(y-14)^2; --6
		if(dist2<dist1) then nSel = 6;dist1 = dist2; end
		
		local pos = {x=0,y=0,z=0};
		if(nSel==1) then
			pos.x = -0.05;
			-- 左移
		elseif(nSel==2) then
			pos.z = -0.05;
			-- 移近
		elseif(nSel==3) then
			pos.y = -0.05;
			-- 下移
		elseif(nSel==4) then
			pos.x = 0.05;
			-- 右移
		elseif(nSel==5) then
			pos.z = 0.05;
			-- 移远
		elseif(nSel==6) then
			pos.y = 0.05;
			-- 上移
		end

		local params = {type = Map3DSystem.msg.OBJ_ModifyObject, obj_params = Map3DSystem.obj.GetObjectParams(Map3DSystem.App.Creator.target), pos_delta_camera={dx=pos.x,dy=pos.y,dz=pos.z}}
		ObjModifyPage.BeginMouseHoldTimer(params);
		Map3DSystem.SendMessage_obj(params);
	end
end



-- Event handler: on object rotation
function ObjModifyPage.OnRotationMouseDown2()
	ParaAudio.PlayUISound("Btn5");
	
	local temp = ParaUI.GetUIObject("map3dsystem_modify_rotate_btn_2");
	
	if(temp:IsValid()==true) then 
		local x,y, width, height = temp:GetAbsPosition();
		x,y = mouse_x - x, mouse_y - y;
		
		x, y = x * 128 / width, y * 128 / height; -- scale 128/controlsize
		
		-- _guihelper.MessageBox("clicked "..x..","..y.."\r\n");
		
		-- we will use distance to array heads to determine which arrow is being selected. 
		local dist1,dist2;
		local nSel = 1;
		dist1 = (x-28)^2+(y-21)^2; --1
		dist2 = (x-12)^2+(y-79)^2; --2
		if(dist2<dist1) then nSel = 2;dist1 = dist2; end
		dist2 = (x-30)^2+(y-112)^2; --3
		if(dist2<dist1) then nSel = 3;dist1 = dist2; end
		dist2 = (x-69)^2+(y-110)^2; --4
		if(dist2<dist1) then nSel = 4;dist1 = dist2; end
		dist2 = (x-112)^2+(y-54)^2; --5
		if(dist2<dist1) then nSel = 5;dist1 = dist2; end
		dist2 = (x-94)^2+(y-17)^2; --6
		if(dist2<dist1) then nSel = 6;dist1 = dist2; end
		local angledelta = 0.05
		local rot = {x=0,y=0,z=0};
		if(nSel==1) then
			rot.z=angledelta; -- z pos
		elseif(nSel==2) then
			rot.y = angledelta; -- Y pos
		elseif(nSel==3) then
			rot.x = -angledelta; -- x neg
		elseif(nSel==4) then
			rot.z = -angledelta; -- z neg
		elseif(nSel==5) then
			rot.y = -angledelta; -- Y neg
		elseif(nSel==6) then
			rot.x = angledelta; -- x pos
		end
		local params = {type = Map3DSystem.msg.OBJ_ModifyObject, obj_params = Map3DSystem.obj.GetObjectParams(Map3DSystem.App.Creator.target), rot_delta={dx=rot.x,dy=rot.y,dz=rot.z}};
		ObjModifyPage.BeginMouseHoldTimer(params);
		Map3DSystem.SendMessage_obj(params);
	end
end

-- Event handler: on object translation
function ObjModifyPage.OnTranslationMouseDown()
	ParaAudio.PlayUISound("Btn5");
	
	local temp = ParaUI.GetUIObject("map3dsystem_modify_translate_btn");
	
	if(temp:IsValid()==true) then
		-- get relative click position in control
		local x,y, width, height = temp:GetAbsPosition();
		x,y = mouse_x - x, mouse_y - y;
		
		x, y = x * 128 / width, y * 128 / height; -- scale 128/controlsize
		
		-- we will use distance to array heads to determine which arrow is being selected. 
		local dist1,dist2;
		local nSel = 1;
		dist1 = (x-16)^2+(y-36)^2; --1
		dist2 = (x-14)^2+(y-90)^2; --2
		if(dist2<dist1) then nSel = 2;dist1 = dist2; end
		dist2 = (x-64)^2+(y-114)^2; --3
		if(dist2<dist1) then nSel = 3;dist1 = dist2; end
		dist2 = (x-113)^2+(y-91)^2; --4
		if(dist2<dist1) then nSel = 4;dist1 = dist2; end
		dist2 = (x-113)^2+(y-35)^2; --5
		if(dist2<dist1) then nSel = 5;dist1 = dist2; end
		dist2 = (x-64)^2+(y-14)^2; --6
		if(dist2<dist1) then nSel = 6;dist1 = dist2; end
		
		local pos = {x=0,y=0,z=0};
		if(nSel==1) then
			pos.x = -0.1732;
			pos.z = 0.1;
			-- 左移
		elseif(nSel==2) then
			pos.x = -0.1732;
			pos.z = -0.1;
			-- 移近
		elseif(nSel==3) then
			pos.y = -0.2;
			-- 下移
		elseif(nSel==4) then
			pos.x = 0.1732;
			pos.z = -0.1;
			-- 右移
		elseif(nSel==5) then
			pos.x = 0.1732;
			pos.z = 0.1;
			-- 移远
		elseif(nSel==6) then
			pos.y = 0.2;
			-- 上移
		end
		local params = {type = Map3DSystem.msg.OBJ_ModifyObject, obj_params = Map3DSystem.obj.GetObjectParams(Map3DSystem.App.Creator.target), pos_delta_camera={dx=pos.x,dy=pos.y,dz=pos.z}};
		ObjModifyPage.BeginMouseHoldTimer(params);
		Map3DSystem.SendMessage_obj(params);
	end
	
end

-- Event handler: on object rotation
function ObjModifyPage.OnRotationMouseDown()
	ParaAudio.PlayUISound("Btn5");
	
	local temp = ParaUI.GetUIObject("map3dsystem_modify_rotate_btn");
	
	if(temp:IsValid()==true) then 
		local x,y, width, height = temp:GetAbsPosition();
		x,y = mouse_x - x, mouse_y - y;
		
		x, y = x * 128 / width, y * 128 / height; -- scale 128/controlsize
		
		-- _guihelper.MessageBox("clicked "..x..","..y.."\r\n");
		
		-- we will use distance to array heads to determine which arrow is being selected. 
		local dist1,dist2;
		local nSel = 1;
		dist1 = (x-28)^2+(y-21)^2; --1
		dist2 = (x-12)^2+(y-79)^2; --2
		if(dist2<dist1) then nSel = 2;dist1 = dist2; end
		dist2 = (x-30)^2+(y-112)^2; --3
		if(dist2<dist1) then nSel = 3;dist1 = dist2; end
		dist2 = (x-69)^2+(y-110)^2; --4
		if(dist2<dist1) then nSel = 4;dist1 = dist2; end
		dist2 = (x-112)^2+(y-54)^2; --5
		if(dist2<dist1) then nSel = 5;dist1 = dist2; end
		dist2 = (x-94)^2+(y-17)^2; --6
		if(dist2<dist1) then nSel = 6;dist1 = dist2; end
		local angledelta = 0.104719753
		local rot = {x=0,y=0,z=0};
		if(nSel==1) then
			rot.z=angledelta; -- z pos
		elseif(nSel==2) then
			rot.y = angledelta; -- Y pos
		elseif(nSel==3) then
			rot.x = -angledelta; -- x neg
		elseif(nSel==4) then
			rot.z = -angledelta; -- z neg
		elseif(nSel==5) then
			rot.y = -angledelta; -- Y neg
		elseif(nSel==6) then
			rot.x = angledelta; -- x pos
		end

		local params = {type = Map3DSystem.msg.OBJ_ModifyObject, obj_params = Map3DSystem.obj.GetObjectParams(Map3DSystem.App.Creator.target), rot_delta={dx=rot.x,dy=rot.y,dz=rot.z}};
		ObjModifyPage.BeginMouseHoldTimer(params);
		Map3DSystem.SendMessage_obj(params);
	end
end

function ObjModifyPage.OnMinifyClick()
	ParaAudio.PlayUISound("Btn5");
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_ModifyObject, obj_params = Map3DSystem.obj.GetObjectParams(Map3DSystem.App.Creator.target), scale_delta=0.9})
end

function ObjModifyPage.OnMagnifyClick()
	ParaAudio.PlayUISound("Btn5");
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_ModifyObject, obj_params = Map3DSystem.obj.GetObjectParams(Map3DSystem.App.Creator.target), scale_delta=1.1})
end

function ObjModifyPage.OnResetClick()
	ParaAudio.PlayUISound("Btn5");
	Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_ModifyObject, obj_params = Map3DSystem.obj.GetObjectParams(Map3DSystem.App.Creator.target), reset=true})
end

function ObjModifyPage.OnMoveHereClick()
	ParaAudio.PlayUISound("Btn5");
	local player = ParaScene.GetObject("<player>");
	local px,py,pz = player:GetPosition();
	if(player:IsValid()==true) then
		Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_ModifyObject, obj_params = Map3DSystem.obj.GetObjectParams(Map3DSystem.App.Creator.target), pos={x=px,y=py,z=pz}})
	end
end

function ObjModifyPage.OnDeleteClick()
	-- delete the object on BCSXRef
	if(Map3DSystem.UI.Creator.isBCSActive == true) then
		local obj = ParaScene.GetObject(
				Map3DSystem.UI.Creator.CurrentMarkerPosX, 
				Map3DSystem.UI.Creator.CurrentMarkerPosY, 
				Map3DSystem.UI.Creator.CurrentMarkerPosZ);
				
		if(obj:IsValid() == true) then
			Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeleteObject, obj = obj});
		end
		return;
	end
	
	-- delete the current selection
	local curObj = Map3DSystem.obj.GetObject(Map3DSystem.App.Creator.target);
	if(curObj ~= nil) then
		if(curObj:IsCharacter()) then
			-- ask user for confirmation
			--_guihelper.MessageBox("您确定要删除当前选择的人物么?", ObjModifyPage.OnDeleteSelectionImmediate);
			ObjModifyPage.OnDeleteSelectionImmediate();
		else
			-- delete immediately for message object
			ObjModifyPage.OnDeleteSelectionImmediate();
		end
	end	
end

function ObjModifyPage.OnDeleteSelectionImmediate()
	local curObj = Map3DSystem.obj.GetObject(Map3DSystem.App.Creator.target);
	if(curObj ~= nil) then
		Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeleteObject, obj = curObj});
	end
end

function ObjModifyPage.OnSwitchToObject()
	local objParam = Map3DSystem.obj.GetObjectParams(Map3DSystem.App.Creator.target);
	Map3DSystem.SwitchToObject(objParam);
end

function ObjModifyPage.OnLogObject()
	local objParam = Map3DSystem.obj.GetObjectParams(Map3DSystem.App.Creator.target);
	commonlib.echo(objParam);
	--local rotation = objParam.rotation or {};
	--local s = string.format([[scaling_char = %f,position = { %f, %f, %f },rotation = { x = %f, y = %f, z = %f, w = %f, },assetfile_model = "%s",]],
	--objParam.scaling,objParam.x,objParam.y,objParam.z,rotation.x or 0,rotation.y or 0,rotation.z or 0,rotation.w or 0,objParam.AssetFile);
	--ParaMisc.CopyTextToClipboard(s);
	ParaMisc.CopyTextToClipboard(objParam.x..", "..objParam.y..", "..objParam.z)
end

function ObjModifyPage.OnShowAndCopyAssetBtn()
	local objParam = Map3DSystem.obj.GetObjectParams(Map3DSystem.App.Creator.target);
	_guihelper.MessageBox(objParam.AssetFile..[[<br/>路径已经复制到剪切板，可以Ctrl+V复制成文本]]);
	ParaMisc.CopyTextToClipboard(objParam.AssetFile);
end

function ObjModifyPage.OnChangeModelAsset()
	local _obj = Map3DSystem.obj.GetObject(Map3DSystem.App.Creator.target);
	if(_obj ~= nil and _obj:IsValid())then
		local newasset = document:GetPageCtrl():GetUIValue("newasset");
		if(newasset) then
			commonlib.ResetModelAsset(_obj, newasset)
		end
	end	
end

-- close panel
function ObjModifyPage.OnClose()
	local command = Map3DSystem.App.Commands.GetCommand("Creation.Modify");
	if(command) then
		command:Call({bShow=false});
	end
end