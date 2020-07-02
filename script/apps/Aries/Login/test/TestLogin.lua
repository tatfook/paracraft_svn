--[[
Title: Test login to keepwork
Author(s): leio
Date: 2017/7/11
Desc:  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Login/test/TestLogin.lua");
local TestLogin = commonlib.gettable("MyCompany.Aries.test.TestLogin");
TestLogin.login(username,password,client_id,client_secret);
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/os/GetUrl.lua");
local TestLogin = commonlib.gettable("MyCompany.Aries.test.TestLogin");

function TestLogin.login(username,password,client_id,client_secret)
    TestLogin.client_id = client_id;
    TestLogin.client_secret = client_secret;

    local url = "http://keepwork.com/api/wiki/models/user/login";
    System.os.GetUrl({
        url = url,
        json = true,
        form = {
            username = username,
		    password = password,
        }
    }, function(err, msg, data)
        commonlib.echo("===========login callback");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data);
        if(err == 200)then
            if(data.data and data.data.token)then
                token = data.data.token;
                commonlib.echo("===========token");
                commonlib.echo(token);

                local userinfo = data.data.userinfo;
                if(userinfo and userinfo.defaultSiteDataSource)then
                    --call agreeOauth
                    TestLogin.agreeOauth(username,TestLogin.client_id,token)
                end
            end
        end
    end);
end
function TestLogin.agreeOauth(username,client_id,token)
    local url = "http://keepwork.com/api/wiki/models/oauth_app/agreeOauth";
    System.os.GetUrl({
        url = url,
        json = true,
        form = {
            username = username,
		    client_id = client_id,
        },
        headers = {
            ["Authorization"] = " Bearer " .. token,
        },
    }, function(err, msg, data)
        commonlib.echo("===========agreeOauth callback");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data);
        if(err == 200)then
            local code = data.data.code;
            --call getTokenByCode
            TestLogin.getTokenByCode(code,client_id,TestLogin.client_secret);
        end
    end);
end
function TestLogin.getTokenByCode(code,client_id,client_secret)
    local url = "http://keepwork.com/api/wiki/models/oauth_app/getTokenByCode";
    System.os.GetUrl({
        url = url,
        json = true,
        form = {
            code = code,
            client_id = client_id,
            client_secret = client_secret,
        },
    }, function(err, msg, data)
        commonlib.echo("===========getTokenByCode callback");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data);
        if(err == 200)then
            local token = data.token;
            commonlib.echo("============oauth token");
            commonlib.echo(token);
            TestLogin.getProfile(token);
        end
    end);
end
function TestLogin.getProfile(token)
    local url = "http://keepwork.com/api/wiki/models/user/getProfile";
    System.os.GetUrl({
        url = url,
        json = true,
        headers = {
            ["Authorization"] = " Bearer " .. token,
        },
    }, function(err, msg, data)
        commonlib.echo("===========getProfile callback");
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data);
        if(err == 200)then
        end
    end);
end