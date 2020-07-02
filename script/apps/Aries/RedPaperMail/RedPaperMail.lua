--[[
Title: RedPaperMail
Author(s): Leio
Date: 2010/02/06
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/RedPaperMail/RedPaperMail.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Desktop/GUIHelper/CustomMessageBox.lua");

local GameObject = MyCompany.Aries.Quest.GameObject;
local NPC = MyCompany.Aries.Quest.NPC;

local ItemManager = System.Item.ItemManager;
local hasGSItem = ItemManager.IfOwnGSItem;
local equipGSItem = ItemManager.IfEquipGSItem;

local RedPaperMail = {

};
commonlib.setfield("MyCompany.Aries.RedPaperMail", RedPaperMail);
RedPaperMail.questions = {
	{ label = "2010年是什么虎年？", option = {"己丑年","庚寅年","丁亥年",}, answer = 2,},
	
	{ label = "农历把每月初一叫做什么日？", option = {"朔日","望日",}, answer = 1,},
	
	{ label = "元日是农历的那一天？", option = {"正月初一","正月初五","元旦 ",}, answer = 1,},
	
	{ label = "新年第一天（正月初一）要吃什么？", option = {"饺子","馒头","面条",}, answer = 1,},
	
	{ label = "正月十五是什么节日？", option = {"中秋节","元宵节","除夕",}, answer = 2,},
	
	{ label = "元宵节习俗主要有哪两个？", option = {"吃饺子  放鞭炮","吃饺子  贴对联","吃元宵  点灯笼",}, answer = 3,},
	
	{ label = "“春风不度玉门关”这句诗的作者是谁？", option = {"王焕之","杜甫","李白",}, answer = 1,},
	
	{ label = "南岳衡山的最高峰是？", option = {"天都峰","祝融峰","莲花峰",}, answer = 2,},
	
	{ label = "鞭炮的制作形成规模是在哪个朝代？", option = {"唐朝","宋朝","清朝",}, answer = 2,},
	
	{ label = "下面哪种炊具对人体健康最有益？", option = {"不锈钢锅","铁锅","铝锅",}, answer = 2,},
	
	{ label = "过年大家都爱听相声，我国的相声是？", option = {"北方曲种","南方曲种",}, answer = 1,},
	
	{ label = "太阳系中最大的行星是？", option = {"土星","火星","木星",}, answer = 3,},
	
	{ label = "纯羊绒的含绒量在？", option = {"51%","70%","95%",}, answer = 3,},
	
	{ label = "用微波炉煮荷包蛋时要用牙签在蛋清、蛋黄上扎孔主要是为了什么？", option = {"容易入味","防止爆裂","受热均匀",}, answer = 2,},
	
	{ label = "总角之交是指？", option = {"少年之交","顽童之交","忘年之交",}, answer = 1,},
}
RedPaperMail.pages = {
	{ npc_label = "苏菲", icon = "Texture/Aries/PENote/npcs/sophie_32bits.png", reward_label = "抱抱龙美食迎春饺子", exID = 302, text = "虎年第一天，苏菲给你拜年了！给你虎虎的祝福，虎虎的健康，虎虎的快乐，虎虎的心情，虎虎的幸福。再给你一道新年知识问答题，答对了我有好礼相送哦。", },
	{ npc_label = "苏苏", icon = "Texture/Aries/PENote/npcs/susu_32bits.png", reward_label = "魅舞眼罩", exID = 303, text = "在新的一年祝你虎年大吉，虎气冲天！身体健康如虎！总之一切虎！虎！虎！快来转动你的小脑瓜，回答今天的有奖问答吧，答对了才有奖励哦！", },
	{ npc_label = "莫卡", icon = "Texture/Aries/PENote/npcs/moka_32bits.png", reward_label = "家园物品七彩树", exID = 304, text = "又是一年春来到，莫卡来给小哈奇拜年了！祝你新的一年健健康康，快快乐乐，虎虎生威呀！快来回答我今天出的有奖问答吧，答对了我给你惊喜哦。", },
	{ npc_label = "帕帕", icon = "Texture/Aries/PENote/npcs/papa_32bits.png", reward_label = "5000奇豆", exID = 305, text = "马蹄碎碎声，虎年已到，帕帕的祝福也悄然而至了，新的一年里祝你在哈奇小镇收获更多的快乐，快来回答我的问题吧，答对有奖哦。", },
	{ npc_label = "希尔警长", icon = "Texture/Aries/PENote/npcs/hill_32bits.png", reward_label = "神勇墨镜", exID = 306, text = "新春之际，我代表所有的警员来给你拜年了，在新的一年里，祝你更加英明神武。我的问题来了，准备好了吗？", },
	{ npc_label = "多克特博士", icon = "Texture/Aries/PENote/npcs/drdoctor_32bits.png", reward_label = "家园物品雷震云", exID = 307, text = "新年到咯，我也来拜年啦！希望你在新的一年里更加懂事，我也会为你们发明更多的好东西！好了，准备好来回答我今天的题目吧。", },
	{ npc_label = "伍迪", icon = "Texture/Aries/PENote/npcs/wudi_32bits.png", reward_label = "抱抱龙美食甜心蛋糕", exID = 308, text = "新年又来了，我给你送来吉祥如意的祝福！在新年里希望你的抱抱龙在你的照顾下长得越来越壮。快来回答我的问题吧，答对有好礼。", },
	{ npc_label = "呼噜大叔", icon = "Texture/Aries/PENote/npcs/hulu_32bits.png", reward_label = "5颗梅花种子", exID = 309, text = "呼呼呼，新年疾驶而来，时间真是过得飞快呀！新年我祝你各方面都有大丰收，我的农场也要收获丰硕的果实。快来回答我的问题吧，答对送好礼。", },
	{ npc_label = "威克", icon = "Texture/Aries/PENote/npcs/wike_32bits.png", reward_label = "家园物品晃晃稻草人", exID = 310, text = "当当当当，虎年扬虎威，威克给你拜年了，祝你在新的一年在哈奇小镇收获更多的快乐，也将快乐传播给更多的朋友。准备好回答我今天的问题吧，答对有奖哦。", },
	{ npc_label = "丹瑟", icon = "Texture/Aries/PENote/npcs/dancer_32bits.png", reward_label = "托马斯达人套装", exID = 311, text = "虎年行好运，舞出你精彩，我来给你拜大年咯！祝你在新年里精彩过每一天，舞动奇迹！我今天的问题也有了，快来回答吧。", },
	{ npc_label = "古奇", icon = "Texture/Aries/PENote/npcs/gucci_32bits.png", reward_label = "抱抱龙美食五香饭团", exID = 312, text = "哐哐哐，锣鼓震天响，新年又来到，祝你在新的一年发现哈奇小镇里更多的神秘和惊喜。现在就回答我的问答题吧，我也有惊喜给你哦！", },
	{ npc_label = "拉拉", icon = "Texture/Aries/PENote/npcs/lala_32bits.png", reward_label = "机械舞达人套装", exID = 313, text = "啦啦啦，拉拉给你拜年了！祝你在新的一年里有好运气，也祝你的家族在新的一年里更加兴旺，如果还没加入家族，在新的一年也赶快加入一个家族吧！下面请来回答我的有奖问答吧。", },
	{ npc_label = "多多", icon = "Texture/Aries/PENote/npcs/duoduo_32bits.png", reward_label = "5颗晶晶石", exID = 314, text = "哟嚯，虎年来了，多多给你拜年了！祝你在虎年更加生龙活虎，虎虎生威！今天我来出题，答对有好礼！", },
	{ npc_label = "冬冬", icon = "Texture/Aries/PENote/npcs/dongdong_32bits.png", reward_label = "抱抱龙美食蔬菜三明治", exID = 315, text = "爆竹声中一岁除，冬冬来给你拜年了！祝你在虎年如虎添翼，展翅高飞。我的新年有奖问答也来了，快准备好答题吧。", },
	{ npc_label = "涂涂", icon = "Texture/Aries/PENote/npcs/tutu_32bits.png", reward_label = "鸵鸟变形药丸", exID = 316, text = "春光春色源春意，新年到，春回大地，我涂涂来给你拜年了！祝你新年吉祥如意！快快转动的小脑瓜，回答我的有奖问答题吧。", },
}
--在2-14 到 2-28 可以发送拜年邮件
function RedPaperMail.CanSendMail()
	local self = RedPaperMail;
	local today = self.GetServerDate();
	if(today)then
		local __,__,year,mon,day = string.find(today,"(.+)-(.+)-(.+)");
		mon = tonumber(mon);
		day = tonumber(day);
		if(mon and day and mon == 2 and day >=14 and day <= 28)then
			return true,mon,day;
		end
	end
end
function RedPaperMail.GetQuest()
	local self = RedPaperMail;
	local canSend,mon,day = self.CanSendMail();
	if(canSend)then
		local index = day - 14 + 1;
		local page = self.pages[index];
		local question = self.questions[index];
		return page,question;
	end
end
function RedPaperMail.GetQuestByIndex(index)
	local self = RedPaperMail;
	if(not index)then return end
	local page = self.pages[index];
	local question = self.questions[index];
	return page,question;
end
function RedPaperMail.GetServerDate()
	commonlib.echo("==========remote server date is enabled in RedPaperMailPage");
	local file = ParaIO.open("redpaper.txt", "r");
	if(file:IsValid()) then
		today = ParaGlobal.GetDateFormat("yyyy-MM-dd");
	else
		today = MyCompany.Aries.Scene.GetServerDate() or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	end
	commonlib.echo(today);
	return today;
end
--今天是否已经发送过邮件
function RedPaperMail.IsSendedToday()
	local self = RedPaperMail;
	
	-- NOTE: change of daily obtain count from 17078_NewYearCoupon to 50277_LimitObtain_NewYearCoupon
	local gsObtain = ItemManager.GetGSObtainCntInTimeSpanInMemory(50277);
	if(gsObtain and gsObtain.inday > 0)then
		return true;
	end
end