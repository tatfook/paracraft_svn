--[[
Title: Facebook login page
Author(s): LiXizhi
Date: 2012/10/25
Desc: Facebook login page
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Partners/facebook/FacebookLogin.lua");
local FacebookLogin = commonlib.gettable("MyCompany.Aries.Partners.Facebook.FacebookLogin");
FacebookLogin.ShowPage(url)
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Partners/PartnerPlatforms.lua");
local Platforms = commonlib.gettable("MyCompany.Aries.Partners.Platforms");
local FacebookLogin = commonlib.gettable("MyCompany.Aries.Partners.Facebook.FacebookLogin");

function FacebookLogin.OnInit()
end

function FacebookLogin.OnClosed()
end

-- @param url: the initial url to open
-- @param callback:  a callback function(result) end,  where result is a table {}. containing login result.
--  it defaults to FacebookLogin.OnProcessResultDefault
function FacebookLogin.ShowPage(url, callback)
	callback = callback or FacebookLogin.OnProcessResultDefault;
	FacebookLogin.url = url;
	FacebookLogin.callback = callback;
	FacebookLogin.result = {};

	local width, height = 960, 560;
	local params = {
		url = "script/apps/Aries/Partners/facebook/FacebookLogin.html", 
		name = "Facebook.FacebookLoginPage", 
		isShowTitleBar = false,
		DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
		style = CommonCtrl.WindowFrame.ContainerStyle,
		enable_esc_key = true,
		isTopLevel = true,
		directPosition = true,
			align = "_ct",
			x = -width/2,
			y = -height/2,
			width = width,
			height = height,
	};
	
	System.App.Commands.Call("File.MCMLWindowFrame", params);

	params._page.OnClose = function()
		if(callback) then
			callback(FacebookLogin.result)
		end
	end
end

-- bind current user to Facebook account.
function FacebookLogin.OnProcessResultDefault(result)
	if(not result) then
		return
	end
	LOG.std(nil, "system", "FacebookLogin.result", result);
	if(result.errorcode) then
		_guihelper.MessageBox("认证失败了, 请重新尝试");
	elseif(result.uid and result.token and tonumber(result.plat) == Platforms.PLATS.FB) then
		local url_cmdParams = result;

		local _plat = tonumber(url_cmdParams.plat); -- 平台ID，1:Facebook；2:Facebook
		-- _guihelper.MessageBox(url_cmdParams.nid);
		local _nid = tonumber(url_cmdParams.nid) or -1; -- 平台绑定的NID，如果为-1，则表示还未有与NID绑定
		-- _guihelper.MessageBox(_nid);
		local _uid = url_cmdParams.uid; -- 平台的用户ID，如Facebook的OpenID，Facebook的EMail.....
		-- _guihelper.MessageBox(url_cmdParams.uid);
		local _token = url_cmdParams.token; -- 平台的认证凭证
		local _appid = url_cmdParams.app_id; -- 平台的AppID
		local _bl = false;
				
		local function OnLoggedIn_()
			if(_bl) then
				_bl = false;
				Platforms.SetPlat(_plat);
				Platforms.SetOID(_uid);
				Platforms.SetToken(_token);
				Platforms.SetAppId(_appid);
				-- invoke callback.
				Platforms.OnLoginCallback();
			end
		end

		if _nid < 0 then -- 未与NID绑定
			if (System.User.IsAuthenticated) then -- 当前为登录状态
				if not paraworld.users.NIDRelationOtherAccount then
					paraworld.create_wrapper("paraworld.users.NIDRelationOtherAccount", "%MAIN%/API/Users/NIDRelationOtherAccount",
						function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
							LOG.std(nil, "debug", "NIDRelationOtherAccount", "begin binding");
						end,
						function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
							LOG.std(nil, "debug", "NIDRelationOtherAccount", "end binding");
						end
					);
				end
				_guihelper.MessageBox("我们需要将您的哈奇角色与Facebook帐号建立关联, 方便您下次分享. 是否同意？", function()
					paraworld.users.NIDRelationOtherAccount({plat = _plat, oid = _uid}, "users.NIDRelationOtherAccount", function(msg)
						local _err = msg.errorcode;
						if _err == 0 then -- 帐户绑定成功
							_bl = true;
							-- TODO: 给用户提示
							_guihelper.MessageBox("您的角色已经成功绑定Facebook号, 可以开始分享了！");
							OnLoggedIn_()
						elseif _err == 417 then -- 该NID已绑定过此平台帐户
							-- TODO: 给用户提示
							_guihelper.MessageBox("您的角色已绑定过其他Facebook帐户，请用您绑定的Facebook号登陆");
						elseif _err == 433 then -- 该平台帐户已被其它NID绑定
							-- TODO: 给用户提示
							_guihelper.MessageBox("您输入的Facebook帐号已经与其他哈奇角色绑定过了, 请用其他Facebook号分享");
						else -- 其它错误
							-- TODO: 给用户提示
							_guihelper.MessageBox("登录出错了, 位置错误:%s"..tostring(_err));
						end
					end);
				end)
						
			else -- 当前为未登录状态
				-- TODO: 系统自动为其注册一个米米号，默认密码。
				-- 注册成功后，告知用户其米米号及密码。
				-- 使用米米号登录，登录参数中须包含以下几个参数：plat:平台ID;oid:平台的用户ID
				_bl = true;
				_guihelper.MessageBox("请先用一个角色登录再分享！");
			end
		else
			if System.User.IsAuthenticated then -- 当前为登录状态
				if _nid == tonumber(Map3DSystem.User.nid) then
						-- _guihelper.MessageBox("已经绑定过了，不必重复绑定！");
					_bl = true;
				else
					_guihelper.MessageBox("您刚刚输入的Facebook账号已经与其它角色绑定过了！目前暂时不支持一个Facebook号绑定多个角色～");
				end
			else
				NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");
				paraworld.auth.AuthUser({loginplat = _plat, token = _token, oid = _uid});
				-- TODO: go on with login procedure
			end
		end

		if _bl then
			OnLoggedIn_();
		end
	end
end