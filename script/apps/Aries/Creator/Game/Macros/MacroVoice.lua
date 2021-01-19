--[[
Title: Macro Voice
Author(s): LiXizhi
Date: 2021/1/19
Desc: voices

Use Lib:
-------------------------------------------------------
GameLogic.Macros.voice("text to speech")
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Macros/MacroPlayer.lua");
local MacroPlayer = commonlib.gettable("MyCompany.Aries.Game.Tasks.MacroPlayer");
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local Macros = commonlib.gettable("MyCompany.Aries.Game.GameLogic.Macros")

local voices = {
["����Ҫͬʱ����2������"] = "Audio/Haqi/creator/MacroPlayer/macrotip_1.ogg",
["��ס��������Ҫ���֣� ͬʱ�϶���굽Ŀ���"] = "Audio/Haqi/creator/MacroPlayer/macrotip_2.ogg",
["����ƶ����������Ҫ���"] = "Audio/Haqi/creator/MacroPlayer/macrotip_3.ogg",
["��Ҫ������, ���ǹ�������м�Ĺ���"] = "Audio/Haqi/creator/MacroPlayer/macrotip_4.ogg",
["�밴��ָʾ��������"] = "Audio/Haqi/creator/MacroPlayer/macrotip_5.ogg",
["�밴ס���̵�ָ����ť��Ҫ���֣�ͬʱ������"] = "Audio/Haqi/creator/MacroPlayer/macrotip_6.ogg",
["������ȷ����갴��"] = "Audio/Haqi/creator/MacroPlayer/macrotip_7.ogg",
["�뽫����ƶ���Ŀ��㣬�ٰ�����"] = "Audio/Haqi/creator/MacroPlayer/macrotip_8.ogg",
["�϶����ʱ��Ҫ����ȷ�İ���"] = "Audio/Haqi/creator/MacroPlayer/macrotip_9.ogg",
["���϶���굽Ŀ���"] = "Audio/Haqi/creator/MacroPlayer/macrotip_10.ogg",
["��������һ�������������м�Ĺ���"] = "Audio/Haqi/creator/MacroPlayer/macrotip_11.ogg",
["success"] = "Audio/Haqi/creator/ArtWar/success.mp3",
}

-- @param text: play text to speech
function Macros.voice(text)
	if(not text or text == "") then
		return
	end
	local filename = voices[text]

	if(filename) then
		GameLogic.RunCommand("sound", format("macroplayer %s", filename))
	else
		GameLogic.RunCommand("voice", text)
	end
end





