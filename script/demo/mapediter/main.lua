--[[ 
Title: Terrain editing UI for ParaEngine
Author(s): LiXizhi
Date: 2005/12
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/demo/mapediter/main.lua");
------------------------------------------------------------
]]
--Require:
NPL.load("(gl)script/ide/terrain_editor.lua");
NPL.load("(gl)script/ide/visibilityGroup.lua");
NPL.load("(gl)script/ide/gui_helper.lua");

--DemoTerrainEditorUI
if(not DemoTerrainEditorUI) then DemoTerrainEditorUI={}; end

-- update UI according to parameters
function DemoTerrainEditorUI.updateUI()
	local fValue,radiobuttons;
	
	-- elevation radius
	fValue = TerrainEditorUI.elevModifier.radius;
	radiobuttons = {"elev_radius_size_s","elev_radius_size_m","elev_radius_size_l"};
	if(fValue<=10) then 
		_guihelper.CheckRadioButtons(radiobuttons, "elev_radius_size_s", "255 0 0");
	elseif(fValue<=25) then 
		_guihelper.CheckRadioButtons(radiobuttons, "elev_radius_size_m", "255 0 0");
	elseif(fValue>=50) then 
		_guihelper.CheckRadioButtons(radiobuttons, "elev_radius_size_l", "255 0 0");
	end
	_guihelper.SafeSetText("elev_radius", tostring(fValue));
	
	-- brush radius
	fValue = TerrainEditorUI.brush.radius;
	radiobuttons = {"tex_radius_size_s","tex_radius_size_m","tex_radius_size_l"};
	if(fValue<=1) then 
		_guihelper.CheckRadioButtons(radiobuttons, "tex_radius_size_s", "255 0 0");
	elseif(fValue<=2) then 
		_guihelper.CheckRadioButtons(radiobuttons, "tex_radius_size_m", "255 0 0");
	elseif(fValue>=3) then 
		_guihelper.CheckRadioButtons(radiobuttons, "tex_radius_size_l", "255 0 0");
	end
	_guihelper.SafeSetText("brush_radius", tostring(fValue));
	
	-- brush textures
	local i;
	for i = 1,6 do
		local objName = "brush_tex_slot"..i;
		local temp = ParaUI.GetUIObject(objName);
		if(temp:IsValid()==true) then 
			if(TerrainEditorUI.textures[i]~=nil and TerrainEditorUI.textures[i].filename~=nil) then
				temp.background = TerrainEditorUI.textures[i].filename;
			end
		end
	end
end

local function activate()
local __this,__parent,__font,__texture;

local temp = ParaUI.GetUIObject("mapediter");
if (temp:IsValid() == true) then
	CommonCtrl.VizGroup.Show("group1", not temp.visible, "mapediter");
else
CommonCtrl.VizGroup.Show("group1", false);
CommonCtrl.VizGroup.AddToGroup("group1", "mapediter");

__this=ParaUI.CreateUIObject("container","mapediter", "_lt",50,80,360,540);
__this:AttachToRoot();
__this.background="Texture/user_bro.png";
__this.candrag=true;

__this=ParaUI.CreateUIObject("button","1", "_lt",200,25,60,30);
__parent=ParaUI.GetUIObject("mapediter");__parent:AddChild(__this);
__this.text="存盘";
__this.background="Texture/b_up.png;";
__this.onclick=";TerrainEditorUI.SaveToDisk();";
	
__this=ParaUI.CreateUIObject("button","1", "_lt",265,25,60,30);
__parent=ParaUI.GetUIObject("mapediter");__parent:AddChild(__this);
__this.text="撤销";
__this.background="Texture/b_up.png;";
__this.onclick="";

__this=ParaUI.CreateUIObject("text","ca_text", "_lt",30,50,382,38);
__parent=ParaUI.GetUIObject("mapediter");__parent:AddChild(__this);
__this.text="修改地形：";
__this.autosize=true;
__this.background="Texture/dxutcontrols.dds;0 0 0 0";

__this=ParaUI.CreateUIObject("container","edit", "_lt",30,70,299,130);
__parent=ParaUI.GetUIObject("mapediter");__parent:AddChild(__this);
__this.background="Texture/speak_box.png;";
__this.candrag=false;
__this.receivedrag = true;

	__this=ParaUI.CreateUIObject("text","terraRadius_text", "_lt",10,15,382,38);
	__parent=ParaUI.GetUIObject("edit");__parent:AddChild(__this);
	__this.text="设定面积：";
	__this.autosize=true;
	__this.tooltip=[[选择地形的修改半径.一般要比
实际的半径大1倍,使得边缘可以平滑过渡]];
	
	__this=ParaUI.CreateUIObject("button","elev_radius_size_s", "_lt",100,10,30,30);
	__parent=ParaUI.GetUIObject("edit");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/mapediter/size_s.png;";
	__this.onclick=";TerrainEditorUI.elevModifier.radius=10;DemoTerrainEditorUI.updateUI();";
	
	__this=ParaUI.CreateUIObject("button","elev_radius_size_m", "_lt",140,10,30,30);
	__parent=ParaUI.GetUIObject("edit");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/mapediter/size_m.png;";
	__this.onclick=";TerrainEditorUI.elevModifier.radius=20;DemoTerrainEditorUI.updateUI();";
	
	__this=ParaUI.CreateUIObject("button","elev_radius_size_l", "_lt",180,10,30,30);
	__parent=ParaUI.GetUIObject("edit");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/mapediter/size_l.png;";
	__this.onclick=";TerrainEditorUI.elevModifier.radius=50;DemoTerrainEditorUI.updateUI();";
	
	__this=ParaUI.CreateUIObject("editbox","elev_radius", "_lt",220,10,40,30);
	__parent=ParaUI.GetUIObject("edit");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/box.png;";
	__this.readonly=false;
	
    __this=ParaUI.CreateUIObject("text","ca_text", "_lt",260,15,38,38);
	__parent=ParaUI.GetUIObject("edit");__parent:AddChild(__this);
	__this.text="米";
	__this.autosize=true;
	
	__this=ParaUI.CreateUIObject("text","terraHeight__text", "_lt",10,55,382,38);
	__parent=ParaUI.GetUIObject("edit");__parent:AddChild(__this);
	__this.text="坑/平地/山：";
	__this.autosize=true;
	__this.tooltip=[[创建峡谷,平地,山丘.
点击右边的按钮.]];
	
	__this=ParaUI.CreateUIObject("button","terraElev_minus2_text", "_lt",100,50,30,30);
	__parent=ParaUI.GetUIObject("edit");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/mapediter/1.png;";
	__this.onclick=";TerrainEditorUI.GaussianHill(-2);";
	__this.tooltip="降低2米";
	__this.candrag=true;
	
	__this=ParaUI.CreateUIObject("button","terraElev_minus0_text", "_lt",130,50,30,30);
	__parent=ParaUI.GetUIObject("edit");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/mapediter/2.png;";
	__this.onclick=";TerrainEditorUI.GaussianHill(-1);";
	__this.tooltip="降低1米";
	__this.candrag=true;
	
	__this=ParaUI.CreateUIObject("button","terraElev_text", "_lt",160,50,30,30);
	__parent=ParaUI.GetUIObject("edit");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/mapediter/3.png;";
	__this.onclick=";TerrainEditorUI.Flatten();";
	__this.tooltip="平地";
	__this.candrag=true;
	
	__this=ParaUI.CreateUIObject("button","terraElev_plus1_text", "_lt",190,50,30,30);
	__parent=ParaUI.GetUIObject("edit");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/mapediter/4.png;";
	__this.onclick=";TerrainEditorUI.GaussianHill(1);";
	__this.tooltip="增高1米";
	__this.candrag=true;
	
	__this=ParaUI.CreateUIObject("button","terraElev_plus2_text", "_lt",220,50,30,30);
	__parent=ParaUI.GetUIObject("edit");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/mapediter/5.png;";
	__this.onclick=";TerrainEditorUI.GaussianHill(2);";
	__this.tooltip="增高2米";
	__this.candrag=true;
	
	
	__this=ParaUI.CreateUIObject("button","terraElev_plus2_text", "_lt",255,50,35,30);
	__parent=ParaUI.GetUIObject("edit");__parent:AddChild(__this);
	__this.text="恢复";
	__this.background="Texture/b_up.png;";
	__this.onclick=";TerrainEditorUI.GaussianHill(2);";
	__this.tooltip="铲平地表";
	__this.candrag=true;
	
	__this=ParaUI.CreateUIObject("text","ca_text", "_lt",10,95,382,38);
	__parent=ParaUI.GetUIObject("edit");__parent:AddChild(__this);
	__this.text="边缘处理：";
	__this.autosize=true;
	
	__this=ParaUI.CreateUIObject("button","1", "_lt",100,90,60,30);
	__parent=ParaUI.GetUIObject("edit");__parent:AddChild(__this);
	__this.text="平滑";
	__this.background="Texture/b_up.png;";
	__this.onclick=";TerrainEditorUI.Roughen_Smooth(false);";
	
	__this=ParaUI.CreateUIObject("button","1", "_lt",170,90,60,30);
	__parent=ParaUI.GetUIObject("edit");__parent:AddChild(__this);
	__this.text="锐化";
	__this.background="Texture/b_up.png;";
	__this.onclick=";TerrainEditorUI.Roughen_Smooth(true);";
---------------------------------------------------------------------
	
__this=ParaUI.CreateUIObject("text","ca_text", "_lt",30,205,382,38);
__parent=ParaUI.GetUIObject("mapediter");__parent:AddChild(__this);
__this.text="地表贴图：";
__this.autosize=true;
__this.candrag=false;

__this=ParaUI.CreateUIObject("container","texture", "_lt",30,225,299,150);
__parent=ParaUI.GetUIObject("mapediter");__parent:AddChild(__this);
__this.scrollable=false;
__this.background="Texture/speak_box.png;";
__this.receivedrag = true;

	__this=ParaUI.CreateUIObject("text","terraText_radius_text", "_lt",10,15,382,38);
	__parent=ParaUI.GetUIObject("texture");__parent:AddChild(__this);
	__this.text="设定面积：";
	__this.autosize=true;
	__this.tooltip=[[选择地表纹理的作用半径.一般要比
实际的半径大1倍,使得边缘可以平滑过渡]];
	
	__this=ParaUI.CreateUIObject("button","tex_radius_size_s", "_lt",100,10,30,30);
	__parent=ParaUI.GetUIObject("texture");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/mapediter/size_s.png;";
	__this.onclick=";TerrainEditorUI.brush.radius=1;DemoTerrainEditorUI.updateUI();";
	
	__this=ParaUI.CreateUIObject("button","tex_radius_size_m", "_lt",140,10,30,30);
	__parent=ParaUI.GetUIObject("texture");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/mapediter/size_m.png;";
	__this.onclick=";TerrainEditorUI.brush.radius=2;DemoTerrainEditorUI.updateUI();";
	
	__this=ParaUI.CreateUIObject("button","tex_radius_size_l", "_lt",180,10,30,30);
	__parent=ParaUI.GetUIObject("texture");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/mapediter/size_l.png;";
	__this.onclick=";TerrainEditorUI.brush.radius=3;DemoTerrainEditorUI.updateUI();";
	
	__this=ParaUI.CreateUIObject("editbox","brush_radius", "_lt",220,10,40,30);
	__parent=ParaUI.GetUIObject("texture");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/box.png;";
	__this.readonly=false;
	
    __this=ParaUI.CreateUIObject("text","ca_text", "_lt",260,15,38,38);
	__parent=ParaUI.GetUIObject("texture");__parent:AddChild(__this);
	__this.text="米";
	__this.autosize=true;
	
	__this=ParaUI.CreateUIObject("text","terraText_text", "_lt",10,55,382,38);
	__parent=ParaUI.GetUIObject("texture");__parent:AddChild(__this);
	__this.text="设定贴图：";
	__this.autosize=true;
	__this.tooltip="左键点击贴图,绘制地表.右键点击为删除";
	
	__this=ParaUI.CreateUIObject("button","brush_tex_slot1", "_lt",100,50,40,40);
	__parent=ParaUI.GetUIObject("texture");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/item.png;";
	__this.onclick=";TerrainEditorUI.Paint(1);";
	__this.candrag=true;
	
	__this=ParaUI.CreateUIObject("button","brush_tex_slot2", "_lt",160,50,40,40);
	__parent=ParaUI.GetUIObject("texture");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/item.png;";
	__this.onclick=";TerrainEditorUI.Paint(2);";
	__this.candrag=true;
	
	__this=ParaUI.CreateUIObject("button","brush_tex_slot3", "_lt",220,50,40,40);
	__parent=ParaUI.GetUIObject("texture");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/item.png;";
	__this.onclick=";TerrainEditorUI.Paint(3);";
	__this.candrag=true;
	
	__this=ParaUI.CreateUIObject("button","brush_tex_slot4", "_lt",100,100,40,40);
	__parent=ParaUI.GetUIObject("texture");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/item.png;";
	__this.onclick=";TerrainEditorUI.Paint(4);";
	__this.candrag=true;
	
	__this=ParaUI.CreateUIObject("button","brush_tex_slot5", "_lt",160,100,40,40);
	__parent=ParaUI.GetUIObject("texture");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/item.png;";
	__this.onclick=";TerrainEditorUI.Paint(5);";
	__this.candrag=true;
	
	__this=ParaUI.CreateUIObject("button","brush_tex_slot6", "_lt",220,100,40,40);
	__parent=ParaUI.GetUIObject("texture");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/item.png;";
	__this.onclick=";TerrainEditorUI.Paint(6);";
	
	--[[
	__this=ParaUI.CreateUIObject("button","1", "_lt",100,170,100,30);
	__parent=ParaUI.GetUIObject("texture");__parent:AddChild(__this);
	__this.text="更改贴图";
	__this.background="Texture/b_up.png;";
	]]
	
	----------------------------------------------------------------------------------
	
	__this=ParaUI.CreateUIObject("text","ca_text", "_lt",30,380,382,38);
	__parent=ParaUI.GetUIObject("mapediter");__parent:AddChild(__this);
	__this.text="海洋设定：";
	__this.autosize=true;
	__this.candrag=false;
	
	__this=ParaUI.CreateUIObject("text","waterlevel__text", "_lt",100,380,382,38);
	__parent=ParaUI.GetUIObject("mapediter");__parent:AddChild(__this);
	__this.text = string.format("当前海面高度%.1f米", ParaScene.GetGlobalWaterLevel());
	__this.autosize=true;
	__this.tooltip="当前海面高度";

	__this=ParaUI.CreateUIObject("container","sea", "_lt",30,400,299,50);
	__parent=ParaUI.GetUIObject("mapediter");__parent:AddChild(__this);
	__this.scrollable=false;
	__this.background="Texture/speak_box.png;";
	__this.receivedrag = true;
	
	__this=ParaUI.CreateUIObject("text","terraHeight__text", "_lt",10,15,382,38);
	__parent=ParaUI.GetUIObject("sea");__parent:AddChild(__this);
	__this.text="海面高度：";
	__this.autosize=true;
	__this.tooltip="设定海面高度";
	
	__this=ParaUI.CreateUIObject("button","terraElev_minus2_text", "_lt",100,10,30,30);
	__parent=ParaUI.GetUIObject("sea");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/mapediter/1.png;";
	__this.onclick=";TerrainEditorUI.WaterLevel(-2, true);";
	__this.tooltip="降低2米";
	__this.candrag=true;
	
	__this=ParaUI.CreateUIObject("button","terraElev_minus0_text", "_lt",130,10,30,30);
	__parent=ParaUI.GetUIObject("sea");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/mapediter/2.png;";
	__this.onclick=";TerrainEditorUI.WaterLevel(-1, true);";
	__this.tooltip="降低1米";
	__this.candrag=true;
	
	__this=ParaUI.CreateUIObject("button","terraElev_text", "_lt",160,10,30,30);
	__parent=ParaUI.GetUIObject("sea");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/mapediter/3.png;";
	__this.onclick=";TerrainEditorUI.WaterLevel(0, true);";
	__this.tooltip="当前人物高度";
	__this.candrag=true;
	
	__this=ParaUI.CreateUIObject("button","terraElev_plus1_text", "_lt",190,10,30,30);
	__parent=ParaUI.GetUIObject("sea");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/mapediter/4.png;";
	__this.onclick=";TerrainEditorUI.WaterLevel(1, true);";
	__this.tooltip="增高1米";
	__this.candrag=true;
	
	__this=ParaUI.CreateUIObject("button","terraElev_plus2_text", "_lt",220,10,30,30);
	__parent=ParaUI.GetUIObject("sea");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/mapediter/5.png;";
	__this.onclick=";TerrainEditorUI.WaterLevel(2, true);";
	__this.tooltip="增高2米";
	__this.candrag=true;
	
	-----------------------------------------------------------------------------------
	
	__this=ParaUI.CreateUIObject("button","close_button", "_lt",240,470,60,30);
	__parent=ParaUI.GetUIObject("mapediter");__parent:AddChild(__this);
	__this.text="关闭";
	__this.background="Texture/b_up.png;";
	--__this.onclick=";ParaUI.Destroy(\"mapediter\");";
	__this.onclick="(gl)script/demo/mapediter/main.lua";
	
	-- update UI
	DemoTerrainEditorUI.updateUI();
end

end
NPL.this(activate);
