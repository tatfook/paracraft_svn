--[[
Author(s): Leio
Date: 2007/12/17
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/SnakeGameMain.lua");
------------------------------------------------------------
		
]]
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/SnakeGameBody.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/SnakeGameLevel.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/SnakeGameScene.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/SnakeGameStart.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/SnakeGame/DBSnakeGame.lua");
if(not Map3DSystem.UI.SnakeGameMain) then Map3DSystem.UI.SnakeGameMain={}; end

function Map3DSystem.UI.SnakeGameMain.Init(_parentWnd)
	local   self=Map3DSystem.UI.SnakeGameMain;
	local	left,top,width,height=0,0,780,540;
	local   _this,_parent=nil,_parentWnd;
	        _this=ParaUI.CreateUIObject("container","AllContainer", "_lt",left,top,width,height);
			_this.background="Texture/whitedot.png;0 0 0 0";
			_this:AttachToRoot();
			_parent:AddChild(_this);
			_parent = _this;
			
			---MainContainer
			_this=ParaUI.CreateUIObject("container","MainContainer", "_lt",left,top,width,height);
			_this.background="Texture/3DMapSystem/SnakeGame/start_main_bg.png";
			_parent:AddChild(_this);
			---PlayContainer
			_this=ParaUI.CreateUIObject("container","PlayContainer", "_lt",left,top,width,height);
			_this.background="Texture/3DMapSystem/SnakeGame/help_bg.png";
			_parent:AddChild(_this);
			---HelpContainer
			_this=ParaUI.CreateUIObject("container","HelpContainer", "_lt",left,top,width,height);
			_this.background="Texture/3DMapSystem/SnakeGame/help_bg.png";
			_parent:AddChild(_this);
			---ScoreContainer
			_this=ParaUI.CreateUIObject("container","ScoreContainer", "_lt",left,top,width,height);
			_this.background="Texture/3DMapSystem/SnakeGame/help_bg.png";
			_parent:AddChild(_this);
			---NextLevelContainer
			_this=ParaUI.CreateUIObject("container","NextLevelContainer", "_lt",left,top,width,height);
			_this.background="Texture/3DMapSystem/SnakeGame/title_bg.png";
			_parent:AddChild(_this);
			---LostContainer
			_this=ParaUI.CreateUIObject("container","LostContainer", "_lt",left,top,width,height);
			_this.background="Texture/3DMapSystem/SnakeGame/title_bg.png";
			_parent:AddChild(_this);
			--------------------------------------------#########
			_parent=ParaUI.GetUIObject("MainContainer");
			---PlayBtn
	 	    left,top,width,height=132,208,512,64;
			_this=ParaUI.CreateUIObject("button","PlayBtn", "_lt",left,top,width,height);
			_parent:AddChild(_this);
			_this.background="Texture/3DMapSystem/SnakeGame/start_game_btn.png"
			_this.onclick = ";Map3DSystem.UI.SnakeGameMain.Play();"
			---ScoreBtn
			left,top,width,height=132,277,512,64;
			_this=ParaUI.CreateUIObject("button","ScoreBtn", "_lt",left,top,width,height);
			_parent:AddChild(_this);
			_this.background="Texture/3DMapSystem/SnakeGame/high_score_btn.png"
			_this.onclick = ";Map3DSystem.UI.SnakeGameMain.GotoScore();"
			---HelpBtn
			left,top,width,height=132,346,512,64;
			_this=ParaUI.CreateUIObject("button","HelpBtn", "_lt",left,top,width,height);
			_parent:AddChild(_this);
			_this.background="Texture/3DMapSystem/SnakeGame/how_to_play_btn.png"
			_this.onclick = ";Map3DSystem.UI.SnakeGameMain.GotoHelp();"
			--------------------------------------------#########
			_parent=ParaUI.GetUIObject("PlayContainer");
			
			---SceneContainer
			left,top,width,height=0,0,780,540;
			_this=ParaUI.CreateUIObject("container","SceneContainer", "_lt",left,top,width,height);
			_this.background="Texture/whitedot.png;0 0 0 0";
			_parent:AddChild(_this);
			---PlayContainer_title_bg
			left,top,width,height=334,0,512,64;
			_this=ParaUI.CreateUIObject("container","PlayContainer_title_bg", "_lt",left,top,width,height);
			_this.background="Texture/3DMapSystem/SnakeGame/title_btn_bg.png";
			_parent:AddChild(_this);
			---CurLevel_txt
			left,top,width,height=429,19,200,50;
			_this=ParaUI.CreateUIObject("text","CurLevel_txt", "_lt",left,top,width,height);
			_this.font = "System;32;norm";
			--_this:GetFont("text").format=36; -- single line and vertical align
			_parent:AddChild(_this);
			---CurScore_txt
			left,top,width,height=530,19,200,50;
			_this=ParaUI.CreateUIObject("text","CurScore_txt", "_lt",left,top,width,height);
			_this.font = "System;32;norm";
			--_this:GetFont("text").format=36; -- single line and vertical align
			_parent:AddChild(_this);
			--------------------------------------------#########
			_parent=ParaUI.GetUIObject("HelpContainer");
			---help_bg_txt
			left,top,width,height=130,-19,512,512;
			_this=ParaUI.CreateUIObject("container","help_bg_txt", "_lt",left,top,width,height);
			_this.background="Texture/3DMapSystem/SnakeGame/help_txt.png";
			_parent:AddChild(_this);
			
			---HelpContainer_BackBtn 
			left,top,width,height=588,480,128,64;
			_this=ParaUI.CreateUIObject("button","HelpContainer_BackBtn", "_lt",left,top,width,height);
			_parent:AddChild(_this);
			_this.background="Texture/3DMapSystem/SnakeGame/back_btn.png"
			_this.onclick = ";Map3DSystem.UI.SnakeGameMain.GotoMain();"
			
			--------------------------------------------#########
			_parent=ParaUI.GetUIObject("ScoreContainer");
			---score_bg_txt
			left,top,width,height=129,-13,512,512;
			_this=ParaUI.CreateUIObject("container","score_bg_txt", "_lt",left,top,width,height);
			_this.background="Texture/3DMapSystem/SnakeGame/score_txt.png";
			_parent:AddChild(_this);
			---scorelist_bg
			left,top,width,height=0,0,780,540;
			_this=ParaUI.CreateUIObject("container","scorelist_bg", "_lt",left,top,width,height);
			_this.background="Texture/3DMapSystem/SnakeGame/scorelist_bg.png";
			_parent:AddChild(_this);
			---ScoreContainer_BackBtn 
			left,top,width,height=588,480,128,64;
			_this=ParaUI.CreateUIObject("button","ScoreContainer_BackBtn", "_lt",left,top,width,height);
			_parent:AddChild(_this);
			_this.background="Texture/3DMapSystem/SnakeGame/back_btn.png"
			_this.onclick = ";Map3DSystem.UI.SnakeGameMain.GotoMain();"
			---ScoreContainer_text
			left,top,width,height=385,122,250,40;
			for i=1,6 do
				_this=ParaUI.CreateUIObject("text","ScoreContainer_text_"..i, "_lt",left,top,width,height);
				--_this:GetFont("text").color = "105 105 105";
				_this.font = "System;25;norm";
				_this:GetFont("text").format=1+256;
				_parent:AddChild(_this);
				top=top+60
			end
			
			
			--------------------------------------------#########
			_parent=ParaUI.GetUIObject("NextLevelContainer");
			---Title_NextLevel
			left,top,width,height=165,25,512,64;
			_this=ParaUI.CreateUIObject("container","Title_NextLevel", "_lt",left,top,width,height);
			_this.background="Texture/3DMapSystem/SnakeGame/title_continue.png";
			_parent:AddChild(_this);
			---NextLevelContainer_NextBtn
			left,top,width,height=280,229,256,64;
			_this=ParaUI.CreateUIObject("button","NextLevelContainer_NextBtn", "_lt",left,top,width,height);
			_parent:AddChild(_this);
			_this.background="Texture/3DMapSystem/SnakeGame/next_btn.png"
			_this.onclick = ";Map3DSystem.UI.SnakeGameMain.NextLevel();"
			--------------------------------------------#########
			_parent=ParaUI.GetUIObject("LostContainer");
			---Title_Lost
			left,top,width,height=165,25,512,64;
			_this=ParaUI.CreateUIObject("container","Title_Lost", "_lt",left,top,width,height);
			_this.background="Texture/3DMapSystem/SnakeGame/title_gameover.png";
			_parent:AddChild(_this);
			---LostContainer_BackBtn 
			left,top,width,height=588,480,128,64;
			_this=ParaUI.CreateUIObject("button","LostContainer_BackBtn", "_lt",left,top,width,height);
			_parent:AddChild(_this);
			_this.background="Texture/3DMapSystem/SnakeGame/back_btn.png"
			_this.onclick = ";Map3DSystem.UI.SnakeGameMain.SaveScore();"
			---LostContainer_CurScore_txt
			left,top,width,height=299,229,200,50;
			_this=ParaUI.CreateUIObject("text","LostContainer_CurScore_txt", "_lt",left,top,width,height);
			--_this:GetFont("text").color = "105 105 105";
			_this.font = "System;32;norm";
			_this:GetFont("text").format=1+256;
			_parent:AddChild(_this);
--[[
			local   _this,_parent=nil,_parentWnd;
	        _this=ParaUI.CreateUIObject("container","RobotShopContainer", "_lt",0,0,512,512);
			_this.background="Texture/whitedot.png;0 0 0 0";
			_this:AttachToRoot();
			_parent:AddChild(_this);
			_parent = _this;
			
			
				  
--]]
			Map3DSystem.UI.SnakeGameMain.GotoMain()	  
			
end
function Map3DSystem.UI.SnakeGameMain.InitTileList()
	local   self=Map3DSystem.UI.SnakeGameMain;
				
				local SceneContainer_child=ParaUI.GetUIObject("SceneContainer_child");
				if (SceneContainer_child:IsValid()==true) then
					ParaUI.Destroy("SceneContainer_child");
				end
				local	left,top,width,height=0,0,780,540;
				local   _this=ParaUI.CreateUIObject("container","SceneContainer_child", "_lt",left,top,width,height);
						_this.background="Texture/whitedot.png;0 0 0 0";
						SceneContainer=ParaUI.GetUIObject("SceneContainer");
						SceneContainer:AddChild(_this);
						SceneContainer_child=_this;

				
				Map3DSystem.UI.SnakeGameScene.Init(SceneContainer_child);
end
function Map3DSystem.UI.SnakeGameMain.GotoPlay()
	local   self=Map3DSystem.UI.SnakeGameMain;
	local   MainContainer=ParaUI.GetUIObject("MainContainer");
	local   PlayContainer=ParaUI.GetUIObject("PlayContainer");
	local   HelpContainer=ParaUI.GetUIObject("HelpContainer");
	local   ScoreContainer=ParaUI.GetUIObject("ScoreContainer");
	local   NextLevelContainer=ParaUI.GetUIObject("NextLevelContainer");
	local   LostContainer=ParaUI.GetUIObject("LostContainer");
			MainContainer.visible=false;
			PlayContainer.visible=true;
			HelpContainer.visible=false;
			ScoreContainer.visible=false;
			NextLevelContainer.visible=false;
			LostContainer.visible=false;
				
			
end
function Map3DSystem.UI.SnakeGameMain.Play()
	local   self=Map3DSystem.UI.SnakeGameMain;
		    self.GotoPlay()
            self.InitLevel()
end
function Map3DSystem.UI.SnakeGameMain.GotoScore()
	local   self=Map3DSystem.UI.SnakeGameMain;
	local   MainContainer=ParaUI.GetUIObject("MainContainer");
	local   PlayContainer=ParaUI.GetUIObject("PlayContainer");
	local   HelpContainer=ParaUI.GetUIObject("HelpContainer");
	local   ScoreContainer=ParaUI.GetUIObject("ScoreContainer");
	local   NextLevelContainer=ParaUI.GetUIObject("NextLevelContainer");
	local   LostContainer=ParaUI.GetUIObject("LostContainer");
	
			MainContainer.visible=false;
			PlayContainer.visible=false;
			HelpContainer.visible=false;
			ScoreContainer.visible=true;	
			NextLevelContainer.visible=false;
			LostContainer.visible=false;
			
			local list=Map3DSystem.UI.DBSnakeGame.GetScoreList();
			for i=1,6 do
				local t=ParaUI.GetUIObject("ScoreContainer_text_"..i);
				if(list[i]~=nil)then
					t.text=list[i];
				end
			end
end
function Map3DSystem.UI.SnakeGameMain.GotoHelp()
	local   self=Map3DSystem.UI.SnakeGameMain;
	local   MainContainer=ParaUI.GetUIObject("MainContainer");
	local   PlayContainer=ParaUI.GetUIObject("PlayContainer");
	local   HelpContainer=ParaUI.GetUIObject("HelpContainer");
	local   ScoreContainer=ParaUI.GetUIObject("ScoreContainer");
	local   NextLevelContainer=ParaUI.GetUIObject("NextLevelContainer");
	local   LostContainer=ParaUI.GetUIObject("LostContainer");
			MainContainer.visible=false;
			PlayContainer.visible=false;
			HelpContainer.visible=true;
			ScoreContainer.visible=false;
			NextLevelContainer.visible=false;
			LostContainer.visible=false;
			
end
function Map3DSystem.UI.SnakeGameMain.GotoMain()
	local   self=Map3DSystem.UI.SnakeGameMain;
	local   MainContainer=ParaUI.GetUIObject("MainContainer");
	local   PlayContainer=ParaUI.GetUIObject("PlayContainer");
	local   HelpContainer=ParaUI.GetUIObject("HelpContainer");
	local   ScoreContainer=ParaUI.GetUIObject("ScoreContainer");
	local   NextLevelContainer=ParaUI.GetUIObject("NextLevelContainer");
	local   LostContainer=ParaUI.GetUIObject("LostContainer");
			MainContainer.visible=true;
			PlayContainer.visible=false;
			HelpContainer.visible=false;
			ScoreContainer.visible=false;
			NextLevelContainer.visible=false;
			LostContainer.visible=false;
			
end
function Map3DSystem.UI.SnakeGameMain.GotoNextLevel()
	local   self=Map3DSystem.UI.SnakeGameMain;
	
	local   MainContainer=ParaUI.GetUIObject("MainContainer");
	local   PlayContainer=ParaUI.GetUIObject("PlayContainer");
	local   HelpContainer=ParaUI.GetUIObject("HelpContainer");
	local   ScoreContainer=ParaUI.GetUIObject("ScoreContainer");
	local   NextLevelContainer=ParaUI.GetUIObject("NextLevelContainer");
	local   LostContainer=ParaUI.GetUIObject("LostContainer");
			MainContainer.visible=false;
			PlayContainer.visible=false;
			HelpContainer.visible=false;
			ScoreContainer.visible=false;
			NextLevelContainer.visible=true;
			LostContainer.visible=false;
			
			self.ClearTimeIDList()
			
end
function Map3DSystem.UI.SnakeGameMain.GotoLost()
	local   self=Map3DSystem.UI.SnakeGameMain;
	local   MainContainer=ParaUI.GetUIObject("MainContainer");
	local   PlayContainer=ParaUI.GetUIObject("PlayContainer");
	local   HelpContainer=ParaUI.GetUIObject("HelpContainer");
	local   ScoreContainer=ParaUI.GetUIObject("ScoreContainer");
	local   NextLevelContainer=ParaUI.GetUIObject("NextLevelContainer");
	local   LostContainer=ParaUI.GetUIObject("LostContainer");
			MainContainer.visible=false;
			PlayContainer.visible=false;
			HelpContainer.visible=false;
			ScoreContainer.visible=false;
			NextLevelContainer.visible=false;
			LostContainer.visible=true;
			
			self.ClearTimeIDList()
			Map3DSystem.UI.DBSnakeGame.SaveScore(Map3DSystem.UI.SnakeGameStart.Score);
	local   LostContainer_CurScore_txt=ParaUI.GetUIObject("LostContainer_CurScore_txt");
	        LostContainer_CurScore_txt.text=string.format("总共：%s分",Map3DSystem.UI.SnakeGameStart.Score);
end
function Map3DSystem.UI.SnakeGameMain.SaveScore()
	local self=Map3DSystem.UI.SnakeGameMain;
	
	      self.GotoMain()
end
function Map3DSystem.UI.SnakeGameMain.InitLevel()
	local self=Map3DSystem.UI.SnakeGameMain;
		  self.InitTileList();
	local SnameGameScene,GameLevel,TotalEatNum,Score=Map3DSystem.UI.SnakeGameScene,Map3DSystem.UI.SnakeGameStart.StartLevel,Map3DSystem.UI.SnakeGameStart.StartEatNum,Map3DSystem.UI.SnakeGameStart.StartScore;
		  Map3DSystem.UI.SnakeGameStart.Init(SnameGameScene,GameLevel,TotalEatNum,Score);
		  self.UpdateText(GameLevel,Score)
end
function Map3DSystem.UI.SnakeGameMain.NextLevel()
	local self=Map3DSystem.UI.SnakeGameMain;
		  self.GotoPlay();
		  self.InitTileList();
		  
	
	local SnameGameScene=Map3DSystem.UI.SnakeGameStart.SnameGameScene;
	local GameLevel=Map3DSystem.UI.SnakeGameStart.GameLevel+1;		
	local TotalEatNum=Map3DSystem.UI.SnakeGameStart.StartEatNum+math.floor(GameLevel/5);
	--local TotalEatNum=Map3DSystem.UI.SnakeGameStart.TotalEatNum+1;
	local Score=Map3DSystem.UI.SnakeGameStart.Score;
		  Map3DSystem.UI.SnakeGameStart.Init(SnameGameScene,GameLevel,TotalEatNum,Score);
		  
		  self.UpdateText(GameLevel,Score)
		 
end
function Map3DSystem.UI.SnakeGameMain.ClearTimeIDList()
	 Map3DSystem.UI.SnakeGameStart.ClearTimeIDList();
end
function Map3DSystem.UI.SnakeGameMain.UpdateText(gameLevel,gameScore)
	local self=Map3DSystem.UI.SnakeGameMain;
	local CurLevel_txt=ParaUI.GetUIObject("CurLevel_txt");
	local CurScore_txt=ParaUI.GetUIObject("CurScore_txt");
		  CurLevel_txt.text=string.format("第%s关",gameLevel);
		  CurScore_txt.text=string.format("总共：%s分",gameScore);
		  Map3DSystem.UI.SnakeGameStart.Score=gameScore;
end