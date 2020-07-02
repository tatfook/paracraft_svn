local function activate()

ParaUI.Destroy("TerrainSkinContainer");
ParaUI.Destroy("SkyContainer");
ParaUI.Destroy("TerrainContainer");

local __this,__parent,__font,__texture;
__this=ParaUI.CreateUIObject("container","EnvironmentContainer", "_lt",375,500,80,160);
__this:AttachToRoot();
__this.scrollable=false;
__this.background="Texture/player/outputbox.png";
__this.candrag=false;
__this.receivedrag=false;

__this.scrollbarwidth=20;
__this=ParaUI.CreateUIObject("button","Forest", "_lt",5,5,70,30);
__parent=ParaUI.GetUIObject("EnvironmentContainer");__parent:AddChild(__this);
__this.text="树林";
__this.background="Texture/b_up.png";
__this.onclick="(gl)/script/kids/EnvironmentSet/EnvironmentButtons/Forest.lua";
__this.candrag=false;
__this.font="System;15;norm";
__this=ParaUI.CreateUIObject("button","GrassLand", "_lt",5,45,70,30);
__parent=ParaUI.GetUIObject("EnvironmentContainer");__parent:AddChild(__this);
__this.text="草原";
__this.background="Texture/b_up.png";
__this.onclick="(gl)/script/kids/EnvironmentSet/EnvironmentButtons/GrassLand.lua";
__this.candrag=false;
__this.font="System;15;norm";
__this=ParaUI.CreateUIObject("button","Village", "_lt",5,85,70,30);
__parent=ParaUI.GetUIObject("EnvironmentContainer");__parent:AddChild(__this);
__this.text="村庄";
__this.background="Texture/b_up.png";
__this.onclick="(gl)/script/kids/EnvironmentSet/EnvironmentButtons/Village.lua";
__this.candrag=false;
__this.font="System;15;norm";
__this=ParaUI.CreateUIObject("button","Park", "_lt",5,125,70,30);
__parent=ParaUI.GetUIObject("EnvironmentContainer");__parent:AddChild(__this);
__this.text="公园";
__this.background="Texture/b_up.png";
__this.onclick="(gl)/script/kids/EnvironmentSet/EnvironmentButtons/Park.lua";
__this.candrag=false;
__this.font="System;15;norm";
end
NPL.this(activate);
