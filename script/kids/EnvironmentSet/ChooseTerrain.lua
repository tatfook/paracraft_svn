local function activate()

ParaUI.Destroy("TerrainSkinContainer");
ParaUI.Destroy("SkyContainer");
ParaUI.Destroy("EnvironmentContainer");

local __this,__parent,__font,__texture;
__this=ParaUI.CreateUIObject("container","TerrainContainer", "_lt",35,500,80,160);
__this:AttachToRoot();
__this.scrollable=false;
__this.background="Texture/player/outputbox.png";
__this.candrag=false;
__this.receivedrag=false;

__this.scrollbarwidth=20;
__this=ParaUI.CreateUIObject("button","Island", "_lt",5,5,70,30);
__parent=ParaUI.GetUIObject("TerrainContainer");__parent:AddChild(__this);
__this.text="湖心岛";
__this.background="Texture/b_up.png";
__this.onclick="(gl)/script/kids/EnvironmentSet/TerrainButtons/Island.lua";
__this.candrag=false;
__this.font="System;15;norm";
__this=ParaUI.CreateUIObject("button","Mountain", "_lt",5,45,70,30);
__parent=ParaUI.GetUIObject("TerrainContainer");__parent:AddChild(__this);
__this.text="高山";
__this.background="Texture/b_up.png";
__this.onclick="(gl)/script/kids/EnvironmentSet/TerrainButtons/Mountain.lua";
__this.candrag=false;
__this.font="System;15;norm";
__this=ParaUI.CreateUIObject("button","FlatLand", "_lt",5,85,70,30);
__parent=ParaUI.GetUIObject("TerrainContainer");__parent:AddChild(__this);
__this.text="平原";
__this.background="Texture/b_up.png";
__this.onclick="(gl)/script/kids/EnvironmentSet/TerrainButtons/FlatLand.lua";
__this.candrag=false;
__this.font="System;15;norm";
__this=ParaUI.CreateUIObject("button","Hills", "_lt",5,125,70,30);
__parent=ParaUI.GetUIObject("TerrainContainer");__parent:AddChild(__this);
__this.text="丘陵";
__this.background="Texture/b_up.png";
__this.onclick="(gl)/script/kids/EnvironmentSet/TerrainButtons/Hills.lua";
__this.candrag=false;
__this.font="System;15;norm";
end
NPL.this(activate);
