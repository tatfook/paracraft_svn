--[[
Title: keepwork.wintercamp.test
Author(s): pbb
Date: 2021/1/14
Desc:  
Use Lib:
-------------------------------------------------------
local test = NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/test/keepwork.wintercamp.test.lua");
test.FinishEnterCamp()
test.FinishStudy()
test.FinishCertificate()
test.GetSchoolRank()
test.GetVipRest()
--]]

NPL.load("(gl)script/apps/Aries/Creator/HttpAPI/KeepWorkAPI.lua");
local test = NPL.export()

function test.FinishEnterCamp()
    keepwork.wintercamp.joincamp({
        gsId=90004,        
    },function(err, msg, data)
        print("test.FinishEnterCamp")
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);    
    end)
end

function test.FinishStudy()
    keepwork.wintercamp.finishcourse({
        gsId=90004,
        courseGsId=60013,
    },function(err, msg, data)
        print("test.FinishStudy")
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end

function test.FinishCertificate()
    keepwork.wintercamp.finishcertificate({
        gsId=90004,
        certificateGsId=60026,
    },function(err, msg, data)
        print("test.FinishCertificate")
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end

function test.GetSchoolRank()
    keepwork.wintercamp.rank({
        gsId = 90004,
        top = 10,
    },function(err, msg, data)
        print("test.GetSchoolRank")
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end

function test.GetVipRest()
    keepwork.wintercamp.restvip({},function(err, msg, data)
        print("test.GetVipRest")
        commonlib.echo(err);
        commonlib.echo(msg);
        commonlib.echo(data,true);
    end)
end