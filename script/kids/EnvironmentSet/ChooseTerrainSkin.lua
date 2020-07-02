local function activate()

ParaUI.Destroy("SkyContainer");
ParaUI.Destroy("EnvironmentContainer");
ParaUI.Destroy("TerrainContainer");

local __this,__parent,__font,__texture;
__this=ParaUI.CreateUIObject("container","TerrainSkinContainer", "_lt",205,500,80,160);
__this:AttachToRoot();
__this.scrollable=false;
__this.background="Texture/player/outputbox.png";
__this.candrag=false;
__this.receivedrag=false;

__this.scrollbarwidth=20;
__this=ParaUI.CreateUIObject("button","Grass", "_lt",5,5,70,30);
__parent=ParaUI.GetUIObject("TerrainSkinContainer");__parent:AddChild(__this);
__this.text="草地";
__this.background="Texture/b_up.png";
__this.onclick="(gl)/script/kids/EnvironmentSet/TerrainSkinButtons/Grass.lua";
__this.candrag=false;
__this.font="System;15;norm";
__this=ParaUI.CreateUIObject("button","Desert", "_lt",5,45,70,30);
__parent=ParaUI.GetUIObject("TerrainSkinContainer");__parent:AddChild(__this);
__this.text="沙地";
__this.background="Texture/b_up.png";
__this.onclick="(gl)/script/kids/EnvironmentSet/TerrainSkinButtons/Desert.lua";
__this.candrag=false;
__this.font="System;15;norm";
__this=ParaUI.CreateUIObject("button","SmallBlocks", "_lt",5,85,70,30);
__parent=ParaUI.GetUIObject("TerrainSkinContainer");__parent:AddChild(__this);
__this.text="碎石地";
__this.background="Texture/b_up.png";
__this.onclick="(gl)/script/kids/EnvironmentSet/TerrainSkinButtons/SmallBlocks.lua";
__this.candrag=false;
__this.font="System;15;norm";
__this=ParaUI.CreateUIObject("button","Snow", "_lt",5,125,70,30);
__parent=ParaUI.GetUIObject("TerrainSkinContainer");__parent:AddChild(__this);
__this.text="雪地";
__this.background="Texture/b_up.png";
__this.onclick="(gl)/script/kids/EnvironmentSet/TerrainSkinButtons/Snow.lua";
__this.candrag=false;
__this.font="System;15;norm";
end
NPL.this(activate);
