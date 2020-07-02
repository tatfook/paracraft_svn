local function activate()

ParaUI.Destroy("TerrainSkinContainer");
ParaUI.Destroy("EnvironmentContainer");
ParaUI.Destroy("TerrainContainer");

local __this,__parent,__font,__texture;
__this=ParaUI.CreateUIObject("container","SkyContainer", "_lt",545,500,80,160);
__this:AttachToRoot();
__this.scrollable=false;
__this.background="Texture/player/outputbox.png";
__this.candrag=false;
__this.receivedrag=false;

__this.scrollbarwidth=20;
__this=ParaUI.CreateUIObject("button","Sunny", "_lt",5,5,70,30);
__parent=ParaUI.GetUIObject("SkyContainer");__parent:AddChild(__this);
__this.text="晴天";
__this.background="Texture/b_up.png";
__this.onclick="(gl)/script/kids/EnvironmentSet/SkyButtons/Sunny.lua";
__this.candrag=false;
__this.font="System;15;norm";
__this=ParaUI.CreateUIObject("button","Cloudy", "_lt",5,45,70,30);
__parent=ParaUI.GetUIObject("SkyContainer");__parent:AddChild(__this);
__this.text="云彩";
__this.background="Texture/b_up.png";
__this.onclick="(gl)/script/kids/EnvironmentSet/SkyButtons/Cloudy.lua";
__this.candrag=false;
__this.font="System;15;norm";
__this=ParaUI.CreateUIObject("button","Stars", "_lt",5,85,70,30);
__parent=ParaUI.GetUIObject("SkyContainer");__parent:AddChild(__this);
__this.text="繁星";
__this.background="Texture/b_up.png";
__this.onclick="(gl)/script/kids/EnvironmentSet/SkyButtons/Stars.lua";
__this.candrag=false;
__this.font="System;15;norm";
__this=ParaUI.CreateUIObject("button","Evening", "_lt",5,125,70,30);
__parent=ParaUI.GetUIObject("SkyContainer");__parent:AddChild(__this);
__this.text="黄昏";
__this.background="Texture/b_up.png";
__this.onclick="(gl)/script/kids/EnvironmentSet/SkyButtons/Evening.lua";
__this.candrag=false;
__this.font="System;15;norm";
end
NPL.this(activate);
