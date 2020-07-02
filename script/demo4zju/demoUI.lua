--[[
Title: The demo bar UI
Author(s): LiYu (art&UI), LiXizhi(code&logic)
Date: 2006/1/18
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/demo4zju/demoUI.lua");
------------------------------------------------------------
]]

-- DemoUI: demo UI library 
if(not DemoUI) then DemoUI={}; end

-- set window text
function DemoUI.SetStartUpText(item)
	local tmp = ParaUI.GetUIObject("demo_startup_text")
	if(tmp:IsValid() == true) then 
		if(item == "copyright") then
		tmp.text = [[网络游戏开放式开发平台软件
	- ParaEngine 分布式游戏引擎
    Jan. 17th, 2006
	
- 立体的互联网 web 3D
- 无处不在的物理仿真
- 高效流畅的3D图形引擎
- 不断扩展的游戏世界
- 创建个人虚拟世界
- NPL网络脚本系统

版权说明和基本使用方法见
菜单(File)->View readme
]];
		elseif (item=="team") then
		tmp.text = [[
将全世界的网上力量和资源团结起来，共同创建属于每一个人的游戏世界。
   - ParaEngine 宗旨
 
          制作成员
    监制：
          李黎轩
    程序：
          李西峙
          刘伟力
          王  田
    策划: 
          李  宇
          刘  赫 
    美术：
          刘  琦
    脚本: 
          李西峙
          刘  赫
]];
		elseif (item=="scene2") then
		tmp.text = [[此场景２不存在
测试用户可编辑
"script/usertest.lua"
测试ＮＰＬ脚本相关的功能]];
		end
	end
end

--[[Load empty scene ]]
function DemoUI.SimpleWorld()
	NPL.load("sample/sample.onload.lua", true);
	ParaUI.Destroy("KidsUI_Startup_cont");
end

--[[Load Demo Scene 1]]
function DemoUI.Demo1()
	NPL.load("script/demo4zju/loadscene1.lua", true);
	ParaUI.Destroy("KidsUI_Startup_cont");
end

-- create the main window
function DemoUI.CreateStartupWnd()
	local __this,__parent,__font,__texture;
	
	if(ParaUI.GetUIObject("KidsUI_Startup_cont"):IsValid() == true) then 
		log("demo startup recreated\n");
		return
	end
	
	__this=ParaUI.CreateUIObject("container","KidsUI_Startup_cont", "_lt",0,0,1024,768);
	__this:AttachToRoot();
	__this.scrollable=false;
	__this.background="Texture/demo/bg.png";
	__this.candrag=false;

	--开创世界
	__this=ParaUI.CreateUIObject("button","create", "_lt",360,330,310,40);
	__parent=ParaUI.GetUIObject("KidsUI_Startup_cont");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/demo4teen/create.png;";
	__this.onclick=";KidsUI.Startup_OnNewWorld();";

	--读取世界
	__this=ParaUI.CreateUIObject("button","demo1", "_lt",360,375,310,40);
	__parent=ParaUI.GetUIObject("KidsUI_Startup_cont");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/demo4teen/load.png;";
	__this.onclick=";KidsUI.Startup_LoadWorld();";

	--演示1
	__this=ParaUI.CreateUIObject("button","demo2", "_lt",465,420,125,35);
	__parent=ParaUI.GetUIObject("KidsUI_Startup_cont");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/demo/demo1.png;";
	__this.onclick=";DemoUI.Demo1();";
	
	--系统设置
	__this=ParaUI.CreateUIObject("button","gui", "_lt",360,465,310,40);
	__parent=ParaUI.GetUIObject("KidsUI_Startup_cont");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/demo4teen/setting.png;";
	__this.onclick=";KidsUI.SysSetting();";


	--退出
	__this=ParaUI.CreateUIObject("button","para", "_lt",360,510,310,40);
	__parent=ParaUI.GetUIObject("KidsUI_Startup_cont");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/demo4teen/exit.png;";
	__this.onclick=";KidsUI.OnExit();";
	
	--制作群
	__this=ParaUI.CreateUIObject("button","para", "_lt",465,550,125,35);
	__parent=ParaUI.GetUIObject("KidsUI_Startup_cont");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/demo/para.png;";
	__this.onclick=[[;KidsUI.SetStartUpText("team");]];
	
	--GUI演示
	__this=ParaUI.CreateUIObject("button","gui", "_lt",465,590,125,35);
	__parent=ParaUI.GetUIObject("KidsUI_Startup_cont");__parent:AddChild(__this);
	__this.text="";
	__this.background="Texture/demo/gui.png;";
	__this.onclick=";KidsUI.DemoGUI();";
	
		__this=ParaUI.CreateUIObject("text","ver", "_lt",15,715,500,38);
	__parent=ParaUI.GetUIObject("KidsUI_Startup_cont");__parent:AddChild(__this);
	__this:GetFont("text").color = "255 255 0";
	__this.text="浙江大学,浙江工商大学,浙江省教育厅　专用测试版 V"..ParaEngine.GetVersion();
	__this.autosize=true;

	__this=ParaUI.CreateUIObject("text","copyright", "_lt",15,735,382,38);
	__parent=ParaUI.GetUIObject("KidsUI_Startup_cont");__parent:AddChild(__this);
	__this:GetFont("text").color = "255 255 0";
	__this.text="2006 Copyright @ ParaEngine";
	__this.autosize=true;

	__this=ParaUI.CreateUIObject("container","text_main_cont", "_lt",35,260,240,350);
	__parent=ParaUI.GetUIObject("KidsUI_Startup_cont");__parent:AddChild(__this);
	__this.scrollable=true;
	__this.background="Texture/demo/c_bg.png";
	__this.candrag=false;
	
	__this=ParaUI.CreateUIObject("text","demo_startup_text", "_lt",10,10,220,20);
	__parent=ParaUI.GetUIObject("text_main_cont");__parent:AddChild(__this);
	__this:GetFont("text").color = "255 255 255";
	__this.text="";
	DemoUI.SetStartUpText("copyright");
	__this.autosize=true;
end