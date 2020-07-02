--[[
Title: character customization UI plug-in. 
Author(s): LiXizhi
Date: 2007/7/7
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/CCS/CCS_UI_Predefined.lua");
CCS_UI_Predefined.Show(_parent);
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/kids/CCS/CCS_db.lua");


-- Debug purpose
NPL.load("(gl)script/ide/gui_helper.lua");

if(not CCS_UI_Predefined) then CCS_UI_Predefined={}; end

-- create, init and display the inner control
--@param parent: ParaUIObject which is the parent container
function CCS_UI_Predefined.Show(parent)
	local _this,_parent;
	
	_this=ParaUI.GetUIObject("CCS_UI_Predefined_cont");
	if(_this:IsValid() == false) then
		-- CCS_UI_Predefined_cont
		_this=ParaUI.CreateUIObject("container","CCS_UI_Predefined_cont","_fi",0,0,0,0);
		_this.background="Texture/whitedot.png;0 0 0 0";
		if(parent== nil) then
			_this:AttachToRoot();
		else
			parent:AddChild(_this);
		end
			
		_parent = _this;

		_this = ParaUI.CreateUIObject("button", "button1", "_lt", 19, 37, 75, 23)
		_this.text = "男孩";
		_this.onclick = [[;CCS_UI_Predefined.ResetBaseModel("character/v3/Child/", "Male");]]
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button9", "_lt", 100, 37, 75, 23)
		_this.text = "女孩";
		_this.onclick = [[;CCS_UI_Predefined.ResetBaseModel("character/v3/Child/", "Female");]]
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button2", "_lt", 19, 66, 75, 23)
		_this.text = "脸型";
		_this.onclick = [[;CCS_UI_Predefined.NextFaceType();]]
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button10", "_lt", 100, 66, 75, 23)
		_this.text = "发型";
		_this.onclick = [[;CCS_UI_Predefined.NextHairStyle();]]
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button12", "_lt", 181, 66, 75, 23)
		_this.text = "发色";
		_this.onclick = [[;CCS_UI_Predefined.NextHairColor();]]
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button3", "_lt", 98, 381, 75, 23)
		_this.text = "衣服";
		_this.onclick = [[;CCS_UI_Predefined.ShowNextShirt();]]
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button11", "_lt", 17, 381, 75, 23)
		_this.text = "无衣服";
		_this.onclick = [[;CCS_UI_Predefined.ShowNextShirt(0);]]
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button4", "_lt", 17, 410, 75, 23)
		_this.text = "无披风"
		_this.onclick = [[;CCS_UI_Predefined.ShowNextCape(0);]]
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button13", "_lt", 98, 410, 75, 23)
		_this.text = "披风图";
		_this.onclick = [[;CCS_UI_Predefined.ShowNextCape();]]
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "button23", "_lt", 211, 323, 98, 23)
		_this.text = "左手插件";
		_this.onclick = [[;CCS_UI_Predefined.ShowNextHandSlot(nil);]]
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button24", "_lt", 327, 323, 98, 23)
		_this.text = "右手插件";
		_this.onclick = [[;CCS_UI_Predefined.ShowNextHandSlot(true);]]
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "button26", "_lt", 211, 290, 98, 23)
		_this.text = "左肩插件";
		_this.onclick = [[;CCS_UI_Predefined.ShowNextShoulderAtt();]]
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button27", "_lt", 327, 290, 98, 23)
		_this.text = "右肩插件";
		_this.onclick = [[;CCS_UI_Predefined.ShowNextShoulderAtt();]]
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "button28", "_lt", 268, 261, 98, 23)
		_this.text = "头部插件";
		_this.onclick = [[;CCS_UI_Predefined.ShowNextHeadAtt();]]
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button30", "_lt", 211, 408, 98, 23)
		_this.text = "左脚插件";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button31", "_lt", 327, 408, 98, 23)
		_this.text = "右脚插件";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button25", "_lt", 268, 352, 98, 23)
		_this.text = "背部";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button29", "_lt", 268, 381, 98, 23)
		_this.text = "腰部";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button5", "_lt", 17, 106, 123, 23)
		_this.text = "手臂上部";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button18", "_lt", 209, 106, 123, 23)
		_this.text = "躯干上部";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button14", "_lt", 18, 222, 137, 23)
		_this.text = "面部上半部毛发";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button6", "_lt", 17, 135, 123, 23)
		_this.text = "手臂下部";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button19", "_lt", 209, 135, 123, 23)
		_this.text = "躯干下部";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button15", "_lt", 18, 251, 123, 23)
		_this.text = "面部下半部";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button7", "_lt", 17, 164, 123, 23)
		_this.text = "手部";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button20", "_lt", 209, 164, 123, 23)
		_this.text = "腿上部";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button16", "_lt", 18, 280, 137, 23)
		_this.text = "面部下半部毛发";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button8", "_lt", 17, 193, 123, 23)
		_this.text = "面部上半部";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button21", "_lt", 209, 193, 123, 23)
		_this.text = "腿下部";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button22", "_lt", 209, 222, 123, 23)
		_this.text = "脚部";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button17", "_lt", 18, 309, 155, 23)
		_this.text = "顶部下半部的毛发";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label1", "_lt", 17, 13, 216, 16)
		_this.text = "ParaEngine人物测试专用界面";
		_parent:AddChild(_this);
	end	
	-- init the control values.
end

-- destroy the control
function CCS_UI_Predefined.OnDestroy()
	ParaUI.Destroy("CCS_UI_Predefined_cont");
end

-- reset the base model, e.g.
-- CCS_UI_Predefined.ResetBaseModel("character/v3/Child/", "Male");
-- CCS_UI_Predefined.ResetBaseModel("character/v3/Child/", "Female");
function CCS_UI_Predefined.ResetBaseModel(ModelDir, Gender)
	local player, playerChar = CCS_db.GetPlayerChar();
	if(playerChar~=nil) then
		CCS_db.ResetBaseModel(ModelDir, Gender);
		
		-- only reset the base model if it is different than the current one. 
		if(CCS_db.ModelPath ~=  player:GetPrimaryAsset():GetKeyName()) then
			local asset = ParaAsset.LoadParaX("", CCS_db.ModelPath);
			playerChar:ResetBaseModel(asset);
		end
	end	
end


-- reset the base model, e.g.
-- CCS_UI_Predefined.ResetBaseModel("character/v3/Child/", "Male");
-- CCS_UI_Predefined.ResetBaseModel("character/v3/Child/", "Female");
function CCS_UI_Predefined.ResetBaseModel2(name, ModelDir, Gender)

	local playerOriginal = ObjEditor.GetCurrentObj();
	local temp = ParaScene.GetObject(name);
	if(temp~=nil and temp:IsValid()==true) then
		if(temp:IsCharacter()) then
		
			ObjEditor.SetCurrentObj(temp);
		end
	end	
	
	local player, playerChar = CCS_db.GetPlayerChar();
	if(playerChar~=nil) then
		CCS_db.ResetBaseModel(ModelDir, Gender);
		
		-- only reset the base model if it is different than the current one. 
		if(CCS_db.ModelPath ~=  player:GetPrimaryAsset():GetKeyName()) then
			local asset = ParaAsset.LoadParaX("", CCS_db.ModelPath);
			playerChar:ResetBaseModel(asset);
		end
	end
	
	ObjEditor.SetCurrentObj(playerOriginal);	
end

CCS_UI_Predefined.HairColor = 0;
CCS_UI_Predefined.MaxHairColor = 3;
function CCS_UI_Predefined.NextHairColor()
	local player, playerChar = CCS_db.GetPlayerChar();
	if(playerChar~=nil) then
		--playerChar:SetDisplayOptions(-1,-1,1);
		CCS_UI_Predefined.HairColor = math.mod(CCS_UI_Predefined.HairColor+1, CCS_UI_Predefined.MaxHairColor);
		if (playerChar:GetBodyParams(3) == 0) then
			playerChar:SetBodyParams(-1,-1, CCS_UI_Predefined.HairColor, 1, -1);
			CCS_UI_Predefined.HairStyle = 1;
		else
			playerChar:SetBodyParams(-1,-1, CCS_UI_Predefined.HairColor, -1, -1);
		end
		
	end
end

CCS_UI_Predefined.HairStyle = 0;
CCS_UI_Predefined.MaxHairStyle = 3;
function CCS_UI_Predefined.NextHairStyle()
	local player, playerChar = CCS_db.GetPlayerChar();
	if(playerChar~=nil) then
		CCS_UI_Predefined.HairStyle = math.mod(CCS_UI_Predefined.HairStyle+1, CCS_UI_Predefined.MaxHairStyle);
		playerChar:SetBodyParams(-1,-1, -1, CCS_UI_Predefined.HairStyle, -1);
		
	end
end


CCS_UI_Predefined.FaceType = 0;
CCS_UI_Predefined.MaxFaceType = 2;
function CCS_UI_Predefined.NextFaceType()
	local player, playerChar = CCS_db.GetPlayerChar();
	if(playerChar~=nil) then
		CCS_UI_Predefined.FaceType = math.mod(CCS_UI_Predefined.FaceType+1, CCS_UI_Predefined.MaxFaceType);
		playerChar:SetBodyParams(-1,CCS_UI_Predefined.FaceType, -1,-1, 0);
		
	end
end

CCS_UI_Predefined.CartoonFaceType = 1;
CCS_UI_Predefined.MaxCartoonFaceType = 2;
function CCS_UI_Predefined.NextCartoonFaceType()
	local player, playerChar = CCS_db.GetPlayerChar();
	if(playerChar:GetGender() == 0 and playerChar:GetRace() == 2) then
		CCS_UI_Predefined.MaxCartoonFaceType = 1;
	end
	if(playerChar~=nil) then
		playerChar:SetBodyParams(-1,-1, -1,-1, CCS_UI_Predefined.CartoonFaceType);
		CCS_UI_Predefined.CartoonFaceType = 1+math.mod(CCS_UI_Predefined.CartoonFaceType, CCS_UI_Predefined.MaxCartoonFaceType);
		
	end
end


-- CurrentFaceType == "CartoonFace": cartoon face
-- CurrentFaceType == "CharacterFace": character face
CCS_UI_Predefined.CurrentFaceType = "CharacterFace";

function CCS_UI_Predefined.ToggleFace()
	local player, playerChar = CCS_db.GetPlayerChar();
	if (CCS_UI_Predefined.CurrentFaceType == "CartoonFace") then
		-- set to character face
		CCS_UI_Predefined.CurrentFaceType = "CharacterFace";
		playerChar:SetBodyParams(-1,CCS_UI_Predefined.FaceType, -1,-1, 0);
		
		local obj = ObjEditor.GetCurrentObj();
		headon_speech.Speek(obj.name, "我可以更换人物脸型了...", 2);
	elseif (CCS_UI_Predefined.CurrentFaceType == "CharacterFace") then
		-- set to cartoon face
		CCS_UI_Predefined.CurrentFaceType = "CartoonFace";
		playerChar:SetBodyParams(-1,-1, -1,-1, CCS_UI_Predefined.CartoonFaceType);
		
		local obj = ObjEditor.GetCurrentObj();
		headon_speech.Speek(obj.name, "我可以编辑卡通脸了...", 2);
	end
end


-- itemid: it can be nil to iterate through all available ones in the database
function CCS_UI_Predefined.ShowNextShirt(itemid)
	local player, playerChar = CCS_db.GetPlayerChar();
	if(playerChar~=nil) then
		
		if(not itemid) then
			-- TODO: iterate through all available ones in the database
			-- test 2 is a shirt
			local samples = CCS_db.GetItemIdListByType(CCS_db.IT_SHIRT);
			if(not CCS_UI_Predefined.ShirtType) then
				CCS_UI_Predefined.ShirtType = 0;
			else
				CCS_UI_Predefined.ShirtType = math.mod(CCS_UI_Predefined.ShirtType+1, table.getn(samples));
			end	
			itemid = samples[CCS_UI_Predefined.ShirtType+1];
		end
		playerChar:SetCharacterSlot(CCS_db.CS_SHIRT, itemid);
		
	end
end


-- IsleftHand: nil if right hand, otherwise left one
-- itemid: it can be nil to iterate through all available ones in the database
function CCS_UI_Predefined.ShowNextHandSlot(IsleftHand, itemid)
	local player, playerChar = CCS_db.GetPlayerChar();
	if(playerChar~=nil) then
		
		if(not itemid) then
			-- TODO: iterate through all available ones in the database
			local samples = CCS_db.GetItemIdListByType(CCS_db.IT_1HANDED);
			if(not CCS_UI_Predefined.WeaponType) then
				CCS_UI_Predefined.WeaponType = 0;
			else
				CCS_UI_Predefined.WeaponType = math.mod(CCS_UI_Predefined.WeaponType+1, table.getn(samples));
			end	
			itemid = samples[CCS_UI_Predefined.WeaponType+1];
		end
		if(not IsleftHand) then
			playerChar:SetCharacterSlot(CCS_db.CS_HAND_RIGHT, itemid);
		else
			playerChar:SetCharacterSlot(CCS_db.CS_HAND_LEFT, itemid);
		end	
		
	end
end

-- itemid: it can be nil to iterate through all available ones in the database
function CCS_UI_Predefined.ShowNextCape(itemid)
	local player, playerChar = CCS_db.GetPlayerChar();
	if(playerChar~=nil) then
		
		if(not itemid) then
			-- TODO: iterate through all available ones in the database
			local samples = CCS_db.GetItemIdListByType(CCS_db.IT_CAPE);
			if(not CCS_UI_Predefined.CapeType) then
				CCS_UI_Predefined.CapeType = 0;
			else
				CCS_UI_Predefined.CapeType = math.mod(CCS_UI_Predefined.CapeType+1, table.getn(samples));
			end	
			itemid = samples[CCS_UI_Predefined.CapeType+1];
		end
		playerChar:SetCharacterSlot(CCS_db.CS_CAPE, itemid);
		
	end
end

-- itemid: it can be nil to iterate through all available ones in the database
function CCS_UI_Predefined.ShowNextHeadAtt(itemid)
	local player, playerChar = CCS_db.GetPlayerChar();
	if(playerChar~=nil) then
		
		if(not itemid) then
			-- TODO: iterate through all available ones in the database
			local samples = CCS_db.GetItemIdListByType(CCS_db.IT_HEAD);
			if(not CCS_UI_Predefined.HeadAttType) then
				CCS_UI_Predefined.HeadAttType = 0;
			else
				CCS_UI_Predefined.HeadAttType = math.mod(CCS_UI_Predefined.HeadAttType+1, table.getn(samples));
			end	
			itemid = samples[CCS_UI_Predefined.HeadAttType+1];
		end
		playerChar:SetCharacterSlot(CCS_db.CS_HEAD, itemid);
		
	end
end

-- itemid: it can be nil to iterate through all available ones in the database
function CCS_UI_Predefined.ShowNextShoulderAtt(itemid)
	local player, playerChar = CCS_db.GetPlayerChar();
	if(playerChar~=nil) then
		
		if(not itemid) then
			-- TODO: iterate through all available ones in the database
			local samples = {
				0, 7, -- some test item id
			}
			if(not CCS_UI_Predefined.ShoulderAttType) then
				CCS_UI_Predefined.ShoulderAttType = 0;
			else
				CCS_UI_Predefined.ShoulderAttType = math.mod(CCS_UI_Predefined.ShoulderAttType+1, table.getn(samples));
			end	
			itemid = samples[CCS_UI_Predefined.ShoulderAttType+1];
		end
		playerChar:SetCharacterSlot(CCS_db.CS_SHOULDER, itemid);
		
	end
end

