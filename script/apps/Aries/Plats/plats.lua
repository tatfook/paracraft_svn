--[[
NPL.load("(gl)script/apps/Aries/Plats/plats.lua");
local Platforms = commonlib.gettable("MyCompany.Aries.SNS.Platforms");
]]

NPL.load("(gl)script/ide/socket/url.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");
-- local plats = commonlib.gettable("MyCompany.Aries.plats");
-- commonlib.module("commonlib.plats");

local PLATS = {FB = 1, QQ = 2};

local Platforms = commonlib.gettable("MyCompany.Aries.SNS.Platforms");
local HOST_MAIN = "http://haqi2.paraengine.com";

local PLAT_CNF_QQ = {
	auth_callback_url = "http://qqlogin.paraengine.com/qq_callback.htm"
};


function Platforms.SetPlat(pPlatId)
	System.User.Plat = pPlatId;
end

function Platforms.GetPlat()
	return System.User.Plat;
end

function Platforms.SetOID(pOID)
	System.User.OID = pOID;
end

function Platforms.GetOID()
	return System.User.OID;
end

function Platforms.SetToken(pToken)
	System.User.Token = pToken;
end

function Platforms.GetToken()
	return System.User.Token;
end

function Platforms.SetAppId(pAppId)
	System.User.AppId = pAppId;
end

function Platforms.GetAppId()
	return System.User.AppId;
end


function Platforms.show_login_window()
	local p = Platforms.GetPlat();
	if p == PLATS.QQ then
		local url = commonlib.gettable("commonlib.socket.url");
		local str = "http://openapi.qzone.qq.com/oauth/show?which=ConfirmPage&client_id=100302176&response_type=token&scope=all&redirect_uri=" .. url.escape(PLAT_CNF_QQ.auth_callback_url);
		ParaGlobal.ShellExecute("open", "iexplore.exe", str, "", 1);
	end
end


--[[
pMsg: table
	title (*) 标题
	url (*) 分享的网址，必须以http开头
	comment 用户评论内容
	summary 摘要
	images 图片地址集，多张图片以竖线（|）分隔
pCallbackFun: 可选，分享后的回调方法，其有一个参数，为分享状态码。0:成功；1:敏感词汇；2:分享频率太高；3:空间被封
]]
function Platforms.postToFeed(pMsg, pCallbackFun)
	local p = Platforms.GetPlat();
	if p == PLATS.QQ then
		if not paraworld.postFeedQQ then
			paraworld.CreateRESTJsonWrapper("paraworld.postFeedQQ", "https://graph.qq.com/share/add_share", 
				function (self, msg, id, callback_func, callbackParams, postMsgTranslator)
					--
				end,
				function (self, msg)
					--
				end
			);
		end
		pMsg.access_token = Platforms.GetToken();
		pMsg.oauth_consumer_key = Platforms.GetAppId();
		pMsg.openid = Platforms.GetOID();
		paraworld.postFeedQQ(pMsg, "myfeed", function(msg)
			-- NPL.FromJson(msg, out)
			-- commonlib.Json.Encode
			log("paraworld.postFeedQQ callback msg: " .. commonlib.Json.Encode(msg));
			local re = msg.ret;
			if re == 3006 then
				re = 1;
			elseif re == 3006 or re == 3046 then
				re = 2;
			elseif re == 3034 then
				re = 3;
			end
			if pCallbackFun then
				pCallbackFun(re);
			end
		end);
	end
end




