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
	title (*) ����
	url (*) �������ַ��������http��ͷ
	comment �û���������
	summary ժҪ
	images ͼƬ��ַ��������ͼƬ�����ߣ�|���ָ�
pCallbackFun: ��ѡ�������Ļص�����������һ��������Ϊ����״̬�롣0:�ɹ���1:���дʻ㣻2:����Ƶ��̫�ߣ�3:�ռ䱻��
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




