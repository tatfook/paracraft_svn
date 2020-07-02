

local SwitchFrameController = {
	name = "SwitchFrameCmd",
	mainWnd = nil,
}
Map3DApp.SwitchFrameController = SwitchFrameController;

function SwitchFrameController:new(o)
	o = o or {};
	setmetatable(o,self);
	self.__index = self;
	return o;
end

function SwitchFrameController:Destroy()
	self.name = nil;
end

function SwitchFrameController:SetMainFrame(mainFrame)
	self.mainFrame = mainFrame;
end

function SwitchFrameController:AddTrigger(subject)
	if(subject and subject.AddListener)then
		subject:AddListener(self.name,self);
	end
end

function SwitchFrameController:SetMessage(sender,msg,data)
	if(msg == Map3DApp.Msg.onEditTile)then
		if(self.mainWnd and self.mainWnd.SwitchFrame)then
			self.mainWnd:SwitchFrame("edit");
		end
	elseif(msg == Map3DApp.Msg.onEditTileDone)then
		if(self.mainWnd and self.mainWnd.SwitchFrame)then
			self.mainWnd:SwitchFrame("map");
		end
	end	
end