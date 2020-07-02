--[[
Title: PENoteLibs
Author(s): Leio
Date: 2009/9/25
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/PENote/PENoteLibs.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/PENote/PENoteTemplate.lua");
local PENoteLibs = {
	["pet_dead"]  = {
		{ to_label = "亲爱的%name%",from_label = "你可爱的%name%",to_nid = nil,from_nid = nil,content = "我觉得自己快要不行了。我真的好舍不得你。",date = nil,show_template = Map3DSystem.App.PENote.PENoteTemplate.GOHOME,},
	 },
	 ["gift_send_succeed"] = {
		{ to_label = "%name%:",from_label = "%name%",to_nid = nil,from_nid = nil,content = "我留下了一点小礼物在你的礼物盒里，希望你能喜欢哦！",date = nil,show_template = Map3DSystem.App.PENote.PENoteTemplate.GOHOME,},
	 },
	 ["gift_send_fail"] = {
		{ to_label = "%name%:",from_label = "%name%",to_nid = nil,from_nid = nil,content = "我想送礼物给你，可是你的礼物盒已经满了，不能再收礼物了。快去清理一下礼物盒吧。",date = nil,show_template = Map3DSystem.App.PENote.PENoteTemplate.GOHOME,},
	 },
	 ["time_is_21"] = {
		{ to_label = "亲爱的%name%:",from_label = "%name%",to_nid = nil,from_nid = nil,content = " 熬夜加班是星星和月亮的事，你要早点休息了哦！现在都21：00啦，快快刷牙，洗脸，早点休息吧，明天一定又是幸福快乐的一天！",date = nil,show_template = Map3DSystem.App.PENote.PENoteTemplate.TIMEREMIND,},
	 },
	  ["time_is_23_45"] = {
		{ to_label = "亲爱的%name%:",from_label = "%name%",to_nid = nil,from_nid = nil,content = "  这里的夜晚静悄悄啦，小哈奇也该上床休息了哦！为了小哈奇正常的作息，并且不影响明天的学习生活，公民管理处把哈奇小镇的开放时间设定为6：00-24：00，现在还有15分钟哦！",date = nil,show_template = Map3DSystem.App.PENote.PENoteTemplate.TIMEREMIND,},
	 },
	  ["time_is_23_55"] = {
		{ to_label = "亲爱的%name%:",from_label = "%name%",to_nid = nil,from_nid = nil,content = "  这里的夜晚静悄悄啦，小哈奇也该上床休息了哦！为了小哈奇正常的作息，并且不影响明天的学习生活，公民管理处把哈奇小镇的开放时间设定为6：00-24：00，现在还有5分钟哦！",date = nil,show_template = Map3DSystem.App.PENote.PENoteTemplate.TIMEREMIND,},
	 },
	 ["series_onlineTime_45"] = {
		--连续在线45分钟
		{ to_label = "亲爱的%name%:",from_label = "%name%",to_nid = nil,from_nid = nil,content = " 你已经在哈奇小镇玩了45分钟，是不是已经坐累了？上网太长时间，对眼睛和身体都不好。<br />快快站起身来，活动一下身体，做做眼保健操吧。",date = nil,show_template = Map3DSystem.App.PENote.PENoteTemplate.TIMEREMIND,},
	 },
	  ["total_onlineTime_today_2"] = {
		--今天总共在线时间
		{ to_label = "亲爱的%name%:",from_label = "%name%",to_nid = nil,from_nid = nil,content = " 你今天已经在哈奇小镇玩了2个小时。上网太长时间，对眼睛和身体都不好。<br />赶快休息一下，或者去复习一下功课吧。明天再来继续哈奇小镇的精彩之旅。",date = nil,show_template = Map3DSystem.App.PENote.PENoteTemplate.TIMEREMIND,},
	 },
	  ["total_onlineTime_today_5"] = {
		--今天总共在线时间
		{ to_label = "亲爱的%name%:",from_label = "%name%",to_nid = nil,from_nid = nil,content = " 你今天已经在哈奇小镇玩了5个小时。上网太长时间，对眼睛和身体都不好。<br />赶快休息一下，或者去复习一下功课吧。明天再来继续哈奇小镇的精彩之旅。",date = nil,show_template = Map3DSystem.App.PENote.PENoteTemplate.TIMEREMIND,},
	 },
	 ["total_onlineTime_today_6"] = {
		--今天总共在线时间
		{ to_label = "亲爱的%name%:",from_label = "%name%",to_nid = nil,from_nid = nil,content = " 你今天已经在哈奇小镇玩了6个小时。上网太长时间，对眼睛和身体都不好。<br />赶快休息一下，或者去复习一下功课吧。明天再来继续哈奇小镇的精彩之旅。",date = nil,show_template = Map3DSystem.App.PENote.PENoteTemplate.TIMEREMIND,},
	 },
	 ["from_manager_to_10000"] = {
		--发送给10000号的消息
		{ tag = nil,show_template = Map3DSystem.App.PENote.PENoteTemplate.FromManagerTo10000,},
	 },
	 ["marry_christmas_2009"] = {
		--圣诞节快乐
		{ to_label = "亲爱的%name%:",from_label = "%name%",to_nid = nil,from_nid = nil,content = " 今天是哈奇小镇的第一个圣诞节，感谢你能陪着我们一起度过，也祝愿你和小伙伴们在哈奇小镇拥有更多快乐和幸福的时光！",date = nil,show_template = Map3DSystem.App.PENote.PENoteTemplate.TIMEREMIND,},
	 },
	 ["happy_new_year_2010_1_1"] = {
		--元旦快乐
		{ to_label = "亲爱的%name%:",from_label = "%name%",to_nid = nil,from_nid = nil,content = " 元旦快乐！2010年从今天开始咯，小哈奇们也都又大一岁啦！祝愿所有的小哈奇健康快乐的成长，哈奇小镇也一定用更多的惊喜陪伴大家度过快乐的童年！",date = nil,show_template = Map3DSystem.App.PENote.PENoteTemplate.TIMEREMIND,},
	 },
	  ["happy_new_year_2010_1_2"] = {
		--元旦快乐
		{ to_label = "亲爱的%name%:",from_label = "%name%",to_nid = nil,from_nid = nil,content = " 今天是元旦假期的第2天啦，小哈奇们有没有去户外运动运动呢？新的一年里，大家不要忘记多多锻炼哦，有个棒棒的身体才能更好的学习和生活呢！",date = nil,show_template = Map3DSystem.App.PENote.PENoteTemplate.TIMEREMIND,},
	 },
	  ["happy_new_year_2010_1_3"] = {
		--元旦快乐
		{ to_label = "亲爱的%name%:",from_label = "%name%",to_nid = nil,from_nid = nil,content = " 今天是元旦假期最后1天啦，小哈奇们的假期的作业都完成了吗？新的一年里，大家要多注意劳逸结合，在哈奇小镇快乐游戏的同时也要好好学习哦！",date = nil,show_template = Map3DSystem.App.PENote.PENoteTemplate.TIMEREMIND,},
	 },
	  ["earthquake_2010"] = {
		--地震
		{ to_label = "亲爱的%name%:",from_label = "%name%",to_nid = nil,from_nid = nil,content = " 近期哈奇小镇时常发生原因不明的晃动，罗德镇长已安排哈奇探查原因；遇到晃动请不要慌张，出行时请多注意安全！",date = nil,show_template = Map3DSystem.App.PENote.PENoteTemplate.TIMEREMIND,},
	 },
	 ["pet_level_5"] = {
		--抱抱龙5级
		{ to_label = "亲爱的%name%:",from_label = "%name%",to_nid = nil,from_nid = nil,content = "你的抱抱龙长大了，也该让他去学点本领啦！雪山顶的技能学院正在教建造技能，快带他去好好学习吧！",date = nil,show_template = Map3DSystem.App.PENote.PENoteTemplate.GOTOPLACE,},
	 },
	  ["challenged"] = {
		--在家园挑战 挑战之旗
		{ tag = nil,show_template = Map3DSystem.App.PENote.PENoteTemplate.CHALLENGEFLAG,},
	 },
	 ["redpaper"] = {
		--拜年邮件
		{ tag = nil,show_template = Map3DSystem.App.PENote.PENoteTemplate.REDPAPER_TEMPLATE,},
	 },
	  ["catch_pet"] = {
		--宠物捕捉任务
		{ to_label = "亲爱的%name%:",from_label = "%name%",to_nid = nil,from_nid = nil,content = "12生肖变身宠物偷偷从涂涂那里跑出来，然后在小镇里得意的变来变去；涂涂可是焦头烂额了，快快去找她问问，看看能不能帮上点忙吧！",date = nil,show_template = Map3DSystem.App.PENote.PENoteTemplate.GOTOPLACE,},
	 },
	  ["spring_bottle"] = {
		--到生机瓶附近 
		{ to_label = "亲爱的%name%:",from_label = "%name%",to_nid = nil,from_nid = nil,content = " 哈奇小镇面临严重危机，春天的气息被神秘怪物偷走并深藏起来，整个小镇将永远变成一个只有冬天的冰冷世界；<br />我们需要赶在12号前寻找到足够的气息放入生机瓶中召唤春天，否则春天将真的永远不会降临！聪明的小哈奇快来吧，我们需要你的帮助！！！",date = nil,show_template = Map3DSystem.App.PENote.PENoteTemplate.GOTOPLACE,},
	 },
	  ["children_research"] = {
		--哈奇小镇小调查
		{ to_label = "亲爱的%name%:",from_label = "%name%",to_nid = nil,from_nid = nil,content = "帕帕姐姐想了解一下哈奇的一些情况，告诉帕帕能获得2000奇豆哦！",date = nil,show_template = Map3DSystem.App.PENote.PENoteTemplate.CHILDREN_RESEARCH,},
	 },
	 ["catch_bunny"] = {
		--宠物水晶兔
		{ to_label = "亲爱的%name%:",from_label = "%name%",to_nid = nil,from_nid = nil,content = "我是帮多克特博士制造怪怪蛋的水晶兔，但是我犯了一个大错，我不知道该怎么弥补，我不敢见到多克特博士，他肯定会教训我的，谁来帮帮我呀！呜呜呜~",date = nil,show_template = Map3DSystem.App.PENote.PENoteTemplate.GOTOPLACE,},
	 },
}
commonlib.setfield("Map3DSystem.App.PENote.PENoteLibs",PENoteLibs);
--msg = {to_nid = to_nid, from_nid = from_nid, note = "pet_dead", doFunc = PENoteTest.doFunc, funcArgs = {"a","b","c"} }
function PENoteLibs.GetNote(msg)
	if(not msg)then return end
	local self = PENoteLibs;
	local key = msg.note;
	local to_nid = msg.to_nid;
	local from_nid = msg.from_nid;
	local date = msg.date;
	local doFunc = msg.doFunc;
	local funcArgs = msg.funcArgs;
	local tag = msg.tag;
	local libs = self[key];
	if(libs)then
		local len = #libs;
		local index = math.random(len);
		local note = libs[index];
		if(note)then
			note = commonlib.deepcopy(note);
			note.key = key;
			note.to_nid = to_nid;
			note.from_nid = from_nid;
			note.date = date;
			note.tag = tag;
			return note;
		end	
	end
end
--["petDead"] = {type = Map3DSystem.App.PENote.msg.PENote_Pet, to_nid = "",from_nid = "你可爱的" , content = "亲爱的小主人，我已经病了10天了，我觉得自己快要不行了。我真的好舍不得你。", buttons = _guihelper.MessageBoxButtons.YesNo, customLabels = {Yes = "马上回家", No = "以后再说"}, action = "gohome", },
--["petSick"] = {type = Map3DSystem.App.PENote.msg.PENote_Pet, to_nid = "",from_nid = "你可爱的" , content = "亲爱的小主人，我生病了，不能再带着你驰骋了，只能先回家等你了。你快点回来给我治病，好吗？", buttons = _guihelper.MessageBoxButtons.YesNo, customLabels = {Yes = "马上回家", No = "以后再说"}, action = "gohome", },
--["petHungry_1"] = {type = Map3DSystem.App.PENote.msg.PENote_Pet, to_nid = "",from_nid = "你可爱的" , content = "亲爱的小主人，我肚子好饿，好想吃你亲手烹调的美味大餐啊！", buttons = _guihelper.MessageBoxButtons.YesNo, customLabels = {Yes = "马上喂食", No = "以后再说"}, action = "dofeed", },
--["petHungry_2"] = {type = Map3DSystem.App.PENote.msg.PENote_Pet, to_nid = "",from_nid = "你可爱的" , content = "头晕晕，眼花花，肚子饿的咕咕叫！亲爱的主人，你在哪里啊？", buttons = _guihelper.MessageBoxButtons.YesNo, customLabels = {Yes = "马上喂食", No = "以后再说"}, action = "dofeed", },
--["petHungry_3"] = {type = Map3DSystem.App.PENote.msg.PENote_Pet, to_nid = "",from_nid = "你可爱的" , content = "亲爱的主人，我知道你很爱我，我也很爱你，你能给我一份营养便当嘛？我饿快要动不了了！", buttons = _guihelper.MessageBoxButtons.YesNo, customLabels = {Yes = "马上喂食", No = "以后再说"}, action = "dofeed", },
--["petDirty_1"] = {type = Map3DSystem.App.PENote.msg.PENote_Pet, to_nid = "",from_nid = "你可爱的" , content = "亲爱的小主人，我不想和苍蝇、跳蚤作朋友，快来帮我洗洗干净吧！", buttons = _guihelper.MessageBoxButtons.YesNo, customLabels = {Yes = "洗澡", No = "以后再说"}, action = "dowash", },
--["petDirty_2"] = {type = Map3DSystem.App.PENote.msg.PENote_Pet, to_nid = "",from_nid = "你可爱的" , content = "左挠挠，右挠挠，我的身上好痒痒，主人，快来帮我洗洗干净吧！", buttons = _guihelper.MessageBoxButtons.YesNo, customLabels = {Yes = "洗澡", No = "以后再说"}, action = "dowash", },
--["petDirty_3"] = {type = Map3DSystem.App.PENote.msg.PENote_Pet, to_nid = "",from_nid = "你可爱的" , content = "爱干净、勤洗澡是好习惯，主人，我有多久没洗澡了？", buttons = _guihelper.MessageBoxButtons.YesNo, customLabels = {Yes = "洗澡", No = "以后再说"}, action = "dowash", },
--["petAngry"] = {type = Map3DSystem.App.PENote.msg.PENote_Pet, to_nid = "",from_nid = "你可爱的" , content = "主人，我真的很想你，很想和你一起玩。你有很久没陪我玩了，我心里好难受，你什么时候才能陪我玩呢？", buttons = _guihelper.MessageBoxButtons.OK, customLabels = {OK = "知道了"}, action = "donothing", },
---- Daily
--["dailyRemind_1"] = {type = Map3DSystem.App.PENote.msg.PENote_Daily, to_nid = "亲爱的",from_nid = "苏菲姐姐" , content = "抱抱龙是小哈奇最好的伙伴，你要用心照顾他哦！如果遇到什么困难，可以来精灵乐园找我！", buttons = _guihelper.MessageBoxButtons.OK, customLabels = {OK = "知道了"}, action = "donothing", },
--["dailyRemind_2"] = {type = Map3DSystem.App.PENote.msg.PENote_Daily, to_nid = "亲爱的",from_nid = "希尔警长" , content = " 最近警署多次接到米米号被盗的案件，提醒各位小哈奇，主要上网安全，不要将密码告诉任何人！", buttons = _guihelper.MessageBoxButtons.OK, customLabels = {OK = "知道了"}, action = "donothing", },
---- Timing
--["timing_1"] = {type = Map3DSystem.App.PENote.msg.PENote_Timing, to_nid = "",from_nid = "" , content = "现在已经10点半了，小哈奇们该上床睡觉了，作个好梦，养足精神吧！", buttons = _guihelper.MessageBoxButtons.OK, customLabels = {OK = "知道了"}, action = "donothing", },
--["timing_2"] = {type = Map3DSystem.App.PENote.msg.PENote_Timing, to_nid = "",from_nid = "" , content = "上课时间就快到了，小哈奇赶快准备一下去上课吧，下午放学再来哈奇小镇吧！", buttons = _guihelper.MessageBoxButtons.OK, customLabels = {OK = "知道了"}, action = "donothing", },
---- Gift
--["giftRemind_succeed"] = {type = Map3DSystem.App.PENote.msg.PENote_Gift, to_nid = "亲爱的",from_nid = "" , content = "我留下了一点小礼物在你的礼物盒里，希望你能喜欢哦！", buttons = _guihelper.MessageBoxButtons.YesNo, customLabels = {Yes = "马上回家", No = "以后再说"}, action = "gohome", },
--["giftRemind_failed"] = {type = Map3DSystem.App.PENote.msg.PENote_Gift, to_nid = "亲爱的",from_nid = "" , content = "我想送礼物给你，可是你的礼物盒已经满了，不能再收礼物了。快去清理一下礼物盒吧。", buttons = _guihelper.MessageBoxButtons.YesNo, customLabels = {Yes = "马上回家", No = "以后再说"}, action = "gohome", },
---- Operation
--["operation_1"] = {type = Map3DSystem.App.PENote.msg.PENote_Operation, to_nid = "勇敢的",from_nid = "希尔警官" , content = "农场周围发现了奇怪的大脚印，为了保卫哈奇小镇的安全，每个勇敢的警官都应该行动起来，赶快到警署报道吧！", buttons = _guihelper.MessageBoxButtons.OK, customLabels = {OK = "知道了"}, action = "donothing", },
--["operation_2"] = {type = Map3DSystem.App.PENote.msg.PENote_Operation, to_nid = "亲爱的",from_nid = "罗德镇长" , content = "圣诞节到了，圣诞老人在哈奇小镇的各个角落藏下了很多礼物，快去寻找属于你的圣诞礼物吧！希望你在哈奇小镇过个快乐的圣诞节！", buttons = _guihelper.MessageBoxButtons.OK, customLabels = {OK = "知道了"}, action = "donothing", },