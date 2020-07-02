--[[

Title: a central place per application for selling and buying tradable items. 

Author(s): LiXizhi, CYF

Date: 2008/1/21

Desc: 

use the lib:

------------------------------------------------------------

NPL.load("(gl)script/kids/3DMapSystemApp/API/test/paraworld.map.test.lua");

paraworld.map.UploadFileEx_Test()

paraworld.map.UploadFile_Test()

paraworld.map.RemoveWorld_Test()

paraworld.map.RemoveWorld_Test_NotData()

paraworld.map.UpdateWorld_Test()

paraworld.map.GetWorldByID_Test()

paraworld.map.PublishWorld_Test()

paraworld.map.UpdateTile_Test_NotData()

paraworld.map.UpdateTile_Test()

paraworld.map.GetTileByID_Test_NotData()

paraworld.map.GetTileByID_Test()

paraworld.map.AddTile_Test()

paraworld.map.SearchMapMark_Test()

paraworld.map.RemoveModel_Test()

paraworld.map.RemoveModel_Test_NotData()

paraworld.map.UpdateModel_Test_ErrorData()

paraworld.map.UpdateModel_Test()

paraworld.map.GetModelByID_Test_NotData()

paraworld.map.GetModelByID_Test()

paraworld.map.AddModel_Test_ErrorData()

paraworld.map.AddModel_Test()

paraworld.map.RemoveMapMark_Test()

paraworld.map.RemoveMapMark_Test_Errorsessionkey()

paraworld.map.RemoveMapMark_Test_NotData()

paraworld.map.UpdateMapMark_Test_Errorsessionkey()

paraworld.map.UpdateMapMark_Test_NotData()

paraworld.map.UpdateMapMark_Test()

paraworld.map.AddMapMark_Test()

paraworld.map.GetMapMarkByID_Test_ErrorID()

paraworld.map.GetMapMarkByID_Test()

paraworld.map.GetTilesInRegion_Test()

paraworld.map.GetMapModelOfPage_Test()

paraworld.map.GetMapModelByIDs_Test()

paraworld.map.GetMapMarksInRegion_Test()

paraworld.map.GetMapMarksInRegion_Test_NotData()

paraworld.map.GetMapMarkOfPage_Test()

paraworld.map.Test()

-------------------------------------------------------

]]



NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");



function paraworld.map.Test()

end



--[[



]]





--passed: 取得某用户的某种类型的MapMark中某一页的数据

-- %TESTCASE{"map.GetMapMarkOfPage", func = "paraworld.map.GetMapMarkOfPage_Test", input ={ownerUserID = "fae5feb1-9d4f-4a78-843a-1710992d4e70", markType = 0, pagesize = 5, pageindex = 0,}}%

function paraworld.map.GetMapMarkOfPage_Test(input)

	local msg = {

		ownerUserID = input.ownerUserID,

		markType = input.markType,

		pagesize = input.pagesize,

		pageindex = input.pageindex,

	};

	paraworld.map.GetMapMarkOfPage(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end);

end





--passed: 返回指定区域内指定类?指定数量的map mark,按标记等级从高到底排序（有数据的区域?

-- %TESTCASE{"map.GetMapMarksInRegion", func = "paraworld.map.GetMapMarksInRegion_Test", input ={x = 0.38818359375, y = 0.7000732421875, width = 0.0030517578125, height = 0.0030517578125,}}%

function paraworld.map.GetMapMarksInRegion_Test(input)

	local msg = {

		x = input.x,

		y = input.y,

		width = input.width,

		height = input.height

	};

	paraworld.map.GetMapMarksInRegion(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end);

end







--passed: 返回指定区域内指定类?指定数量的map mark,按标记等级从高到底排序（没有数据的区域）

function paraworld.map.GetMapMarksInRegion_Test_NotData()

	local msg = {

		operation = "get",

		x = 0,

		y = 0,

		width = 0.00030517578125,

		height = 0.00030517578125

	};

	paraworld.map.GetMapMarksInRegion(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end);

end







--passed: 依据一组MapModel的ID取出这些MapModel的相关信?

function paraworld.map.GetMapModelByIDs_Test()

	local msg = {

		operation = "get",

		modelIDs = {33, 55, 66}

	};

	paraworld.map.GetMapModelByIDs(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end);

end







--passed: 取得Model的某一页的数据

function paraworld.map.GetMapModelOfPage_Test()

	local msg = {

		operation = "get",

		pageNum = 2,

		pageindex = 3

	};

	paraworld.map.GetMapModelOfPage(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end);

end







--passed: 取得一个区域内所有的Tile

-- %TESTCASE{"map.GetTilesInRegion", func = "paraworld.map.GetTilesInRegion_Test", input ={x = 0.59503173828125, y = 0.595062255859375, width = 0.0030517578125, height = 0.0030517578125,}}%

function paraworld.map.GetTilesInRegion_Test(input)

	local msg = {

		x = input.x or 0.59503173828125,

		y = input.y or 0.595062255859375,

		width = input.width or 0.0030517578125,

		height = input.height or 0.0030517578125

	};

	paraworld.map.GetTilesInRegion(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end);

end







--passed: 依据ID取得一个MapMark

function paraworld.map.GetMapMarkByID_Test()

	local msg = {

		markID = 8

	};

	paraworld.map.GetMapMarkByID(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end);

end







--passed: 依据ID取得一个MapMark（错误的ID参数?

function paraworld.map.GetMapMarkByID_Test_ErrorID()

	local msg = {

		markID = "abc"

	};

	paraworld.map.GetMapMarkByID(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end);

end







--passed: 新增一个MapMark

function paraworld.map.AddMapMark_Test()

	local msg = {

		operation = "login",

		username = "LiXizhi",

		Password = "anything"

	};

	paraworld.auth.AuthUser(msg, "test", function(msg)

		local sessionkey = msg.sessionkey;

		

		local msg = {

			sessionkey = sessionkey,

			markType = 1,

			markStyle = 21,

			markTitle = "This is a NPL Test AAA",

			startTime = "2008-1-1",

			x = 0,

			y = 0,

			rank = 1,

			ageGroup = 1

		};

		paraworld.map.AddMapMark(msg, "test", function(msg)

			log(commonlib.serialize(msg));

		end);

	end);

end







--passed: 新增一个MapMark（错误的数据?

function paraworld.map.AddMapMark_Test_ErrorData()

	local msg = {

		operation = "login",

		username = "LiXizhi",

		Password = "anything"

	};

	paraworld.auth.AuthUser(msg, "test", function(msg)

		local sessionkey = msg.sessionkey;

		

		local msg = {

			sessionkey = sessionkey,

			markType = 1,

			markStyle = 1,

			markTitle = "This is a NPL Test AAA",

			startTime = "2008-1-1",

			x = 0,

			y = 0,

			rank = 1,

			ageGroup = 1

		};

		paraworld.map.AddMapMark(msg, "test", function(msg)

			log(commonlib.serialize(msg));

		end);

	end);

end







--passed: 更新一个MapMark

function paraworld.map.UpdateMapMark_Test()

	local msg = {

		operation = "login",

		username = "LiXizhi",

		Password = "anything"

	};

	paraworld.auth.AuthUser(msg, "test", function(msg)

		local sessionkey = msg.sessionkey;

		local msg = {

			sessionkey = sessionkey,

			markID = 12,

			markTitle = "This is a NPL Test BBB"

		};

		paraworld.map.UpdateMapMark(msg, "test", function(msg)

			log(commonlib.serialize(msg));

		end);

	end);

end







--passed: 更新一个MapMark（更新一个不存在的MapMark?

function paraworld.map.UpdateMapMark_Test_NotData()

	local msg = {

		operation = "login",

		username = "LiXizhi",

		Password = "anything"

	};

	paraworld.auth.AuthUser(msg, "test", function(msg)

		local sessionkey = msg.sessionkey;

		local msg = {

			sessionkey = sessionkey,

			markID = 10,

			markTitle = "This is a NPL Test BBB"

		};

		paraworld.map.UpdateMapMark(msg, "test", function(msg)

			log(commonlib.serialize(msg));

		end);

	end);

end







--passed: 更新一个MapMark（错误的sessionkey?

function paraworld.map.UpdateMapMark_Test_Errorsessionkey()

	local msg = {

		sessionkey = "D7E55EAE-2FD7-4877-9893-50E5B35EDDAE",

		markID = 12,

		markTitle = "This is a NPL Test AAA"

	};

	paraworld.map.UpdateMapMark(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end);

end







--passed: 删除一个MapMark

function paraworld.map.RemoveMapMark_Test()

	local msg = {

		operation = "login",

		username = "LiXizhi",

		Password = "anything"

	};

	paraworld.auth.AuthUser(msg, "test", function(msg)

		local sessionkey = msg.sessionkey;

		local msg = {

			sessionkey = sessionkey;

			markID = 8

		};

		paraworld.map.RemoveMapMark(msg, "test", function(msg)

			log(commonlib.serialize(msg));

		end);

	end)

end







--passed: 删除一个MapMark（错误的Session Key?

function paraworld.map.RemoveMapMark_Test_Errorsessionkey()

	local msg = {

		sessionkey = "D7E55EAE-2FD7-4877-9893-50E5B35EDDAE";

		markID = 8

	};

	paraworld.map.RemoveMapMark(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end);

end







--passed: 删除一个MapMark（不存在的数据）

function paraworld.map.RemoveMapMark_Test_NotData()

	local msg = {

		operation = "login",

		username = "LiXizhi",

		Password = "anything"

	};

	paraworld.auth.AuthUser(msg, "test", function(msg)

		local sessionkey = msg.sessionkey;

		local msg = {

			sessionkey = sessionkey;

			markID = 10

		};

		paraworld.map.RemoveMapMark(msg, "test", function(msg)

			log(commonlib.serialize(msg));

		end);

	end)

end







--passed: 新增一个MapMark

function paraworld.map.AddModel_Test()

	local msg = {

		operation = "login",

		username = "LiXizhi",

		Password = "anything"

	};

	paraworld.auth.AuthUser(msg, "test", function(msg)

		local sessionkey = msg.sessionkey;

		local msg = {

			sessionkey = sessionkey,

			modelType = 1,

			picURL = "picURL",

			manufacturerType = 1,

			version = "1-2-2",

			directions = "0,2,4"

		};

		paraworld.map.AddModel(msg, "test", function(msg)

			log(commonlib.serialize(msg));

		end);

	end);

end







--passed: 新增一个MapMark（错误的数据?

function paraworld.map.AddModel_Test_ErrorData()

	local msg = {

		operation = "login",

		username = "LiXizhi",

		Password = "anything"

	};

	paraworld.auth.AuthUser(msg, "test", function(msg)

		local sessionkey = msg.sessionkey;

		local msg = {

			sessionkey = sessionkey,

			modelType = "ErrorData",

			picURL = "picURL",

			manufacturerType = 1,

			version = "1-2-2",

			directions = "0,2,4"

		};

		paraworld.map.AddModel(msg, "test", function(msg)

			log(commonlib.serialize(msg));

		end);

	end);

end







--passed: 依主键获得一个Model的信?

-- %TESTCASE{"map.GetModelByID", func = "paraworld.map.GetModelByID_Test", input ={modelID = 85, isSimple = false;}}%

function paraworld.map.GetModelByID_Test(input)

	local msg = {

		modelID = input.modelID or 83,

		isSimple = input.isSimple or false

	};

	paraworld.map.GetModelByID(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end);

end







--passed: 依主键获得一个Model的信息（不存在的数据?

function paraworld.map.GetModelByID_Test_NotData()

	local msg = {

		modelID = 10000

	};

	paraworld.map.GetModelByID(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end);

end







--passed: 修改一个Model

function paraworld.map.UpdateModel_Test()

	local msg = {

		operation = "login",

		username = "LiXizhi",

		password = "anything"

	};

	paraworld.auth.AuthUser(msg, "test", function(msg)

		local sessionkey = msg.sessionkey;

		local msg = {

			sessionkey = sessionkey,

			modelID = 85,

			price = 100,

			modelPath = "ModelPath"

		};

		paraworld.map.UpdateModel(msg, "test", function(msg)

			log(commonlib.serialize(msg));

		end);

	end);

end







--passed: 修改一个Model（错误的数据?

function paraworld.map.UpdateModel_Test_ErrorData()

	local msg = {

		operation = "login",

		username = "LiXizhi",

		password = "anything"

	};

	paraworld.auth.AuthUser(msg, "test", function(msg)

		local sessionkey = msg.sessionkey;

		local msg = {

			sessionkey = sessionkey,

			modelID = 85,

			price = "ErrorData",

			modelPath = "ModelPath"

		};

		paraworld.map.UpdateModel(msg, "test", function(msg)

			log(commonlib.serialize(msg));

		end);

	end);

end







--passed: 删除一个Model

function paraworld.map.RemoveModel_Test()

	local msg = {

		operation = "login",

		username = "LiXizhi",

		password = "anything"

	};

	paraworld.auth.AuthUser(msg, "test", function(msg)

		local sessionkey = msg.sessionkey;

		local msg = {

			sessionkey = sessionkey,

			modelID = 85

		};

		paraworld.map.RemoveModel(msg, "test", function(msg)

			log(commonlib.serialize(msg));

		end);

	end);

end







--passed: 删除一个Model（不存在的数据）

function paraworld.map.RemoveModel_Test_NotData()

	local msg = {

		operation = "login",

		username = "LiXizhi",

		password = "anything"

	};

	paraworld.auth.AuthUser(msg, "test", function(msg)

		local sessionkey = msg.sessionkey;

		local msg = {

			sessionkey = sessionkey,

			modelID = 10000

		};

		paraworld.map.RemoveModel(msg, "test", function(msg)

			log(commonlib.serialize(msg));

		end);

	end);

end







--passed: 返回符合或包含关键字的第N页经过认证的map mark, 按标记等级从高到底排?

function paraworld.map.SearchMapMark_Test()

	local msg = {

		keywords = "描述",

		type = "Desc",

		isApproved = true

	};

	paraworld.map.SearchMapMark(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end);

end







--passed: 新增一个Tile

-- %TESTCASE{"map.AddTile", func = "paraworld.map.AddTile_Test", input ={x = 0, y = 0, z = 0, tileType = 5, allowEdit = false}}%

function paraworld.map.AddTile_Test(input)

	local msg = {

		operation = "login",

		username = "LiXizhi",

		password = "anything"

	};

	paraworld.auth.AuthUser(msg, "test", function(msg)

		local sessionkey = msg.sessionkey;

		local msg = {

			sessionkey = sessionkey,

			x = input.x or 0,

			y = input.y or 0,

			z = input.z or 0,

			tileType = input.tileType or 5,

			allowEdit = input.allowEdit or false,

		};

		paraworld.map.AddTile(msg, "test", function(msg)

			log(commonlib.serialize(msg));

		end);

	end);

end







--passed: 依据Tile的ID取得一个Tile的信?

-- %TESTCASE{"map.GetTileByID", func = "paraworld.map.GetTileByID_Test", input ={tileID = 337,}}%

function paraworld.map.GetTileByID_Test(input)

	local msg = {

		tileID = input.tileID or 337

	};

	paraworld.map.GetTileByID(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end);

end







--passed: 依据Tile的ID取得一个Tile的信息（不存在的数据?

function paraworld.map.GetTileByID_Test_NotData()

	local msg = {

		tileID = 10000

	};

	paraworld.map.GetTileByID(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end);

end







--passed: 修改指定的Tile

-- %TESTCASE{"map.UpdateTile", func = "paraworld.map.UpdateTile_Test", input ={tileID = 339, price = 200, ranking = 3}}%

function paraworld.map.UpdateTile_Test(input)

	local msg = {

		operation = "login",

		username = "LiXizhi",

		password = "anything"

	};

	paraworld.auth.AuthUser(msg, "test", function(msg)

		local sessionkey = msg.sessionkey;

		local msg = {

			sessionkey = sessionkey,

			tileID = input.tileID or 339,

			ranking = input.ranking or 3

		};

		paraworld.map.UpdateTile(msg, "test", function(msg)

			log(commonlib.serialize(msg));

		end);

	end);

end









--passed: 修改指定的Tile（不存在的数据）

function paraworld.map.UpdateTile_Test_NotData()

	local msg = {

		operation = "login",

		username = "LiXizhi",

		password = "anything"

	};

	paraworld.auth.AuthUser(msg, "test", function(msg)

		local sessionkey = msg.sessionkey;

		local msg = {

			sessionkey = sessionkey,

			tileID = 1000,

			ranking = 5

		};

		paraworld.map.UpdateTile(msg, "test", function(msg)

			log(commonlib.serialize(msg));

		end);

	end);

end









--passed: 发布（即新增）一个World

-- %TESTCASE{"map.PublishWorld", func = "paraworld.map.PublishWorld_Test", input ={sessionkey = "6ea1ce24-bdf7-4893-a053-eb5fd2a74281", name = "test world", desc = "this is a test world.",}}%

function paraworld.map.PublishWorld_Test(input)

	local msg = {

		sessionkey = input.sessionkey,

		name = input.name,

		desc = input.desc,

	};

	paraworld.map.PublishWorld(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end)

end







--passed: 依据ID取得一个World

-- %TESTCASE{"map.GetWorldByID", func = "paraworld.map.GetWorldByID_Test", input ={worldid = "9",}}%

function paraworld.map.GetWorldByID_Test(input)

	local msg = {

		worldid = input.worldid,

	};

	paraworld.map.GetWorldByID(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end);

end







--passed: 修改一个World

-- %TESTCASE{"map.UpdateWorld", func = "paraworld.map.UpdateWorld_Test", input ={sessionkey = "6ea1ce24-bdf7-4893-a053-eb5fd2a74281", worldid = "3", name = "new name", desc = "new desc"}}%

function paraworld.map.UpdateWorld_Test(input)

	local msg = {

		sessionkey = input.sessionkey,

		worldid = input.worldid,

		name = input.name,

		desc = input.desc,

	};

	paraworld.map.UpdateWorld(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end);

end







--passed: 某用户加入指定的World，即成为此World的一个成?

-- %TESTCASE{"map.JoinWorld", func = "paraworld.map.JoinWorld_Test", input ={sessionkey = "6ea1ce24-bdf7-4893-a053-eb5fd2a74281", worldid = "3"}}%

function paraworld.map.JoinWorld_Test(input)

	local msg = {

		sessionkey = input.sessionkey,

		worldid = input.worldid,

	};

	paraworld.map.JoinWorld(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end);

end







--passed: 某用户离开指定的World，即不再是此World的成?

-- %TESTCASE{"map.LeaveWorld", func = "paraworld.map.LeaveWorld_Test", input ={sessionkey = "6ea1ce24-bdf7-4893-a053-eb5fd2a74281", worldid = "3"}}%

function paraworld.map.LeaveWorld_Test(input)

	local msg = {

		sessionkey = input.sessionkey,

		worldid = input.worldid,

	};

	paraworld.map.LeaveWorld(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end);

end







--passed: 某用户离开指定的World，即不再是此World的成?

-- %TESTCASE{"map.VisitWorld", func = "paraworld.map.VisitWorld_Test", input ={sessionkey = "6ea1ce24-bdf7-4893-a053-eb5fd2a74281", worldid = "3"}}%

function paraworld.map.VisitWorld_Test(input)

	local msg = {

		sessionkey = input.sessionkey,

		worldid = input.worldid,

	};

	paraworld.map.VisitWorld(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end);

end









--passed: 删除指定的World

-- %TESTCASE{"map.RemoveWorld", func = "paraworld.map.RemoveWorld_Test", input ={sessionkey = "6ea1ce24-bdf7-4893-a053-eb5fd2a74281", worldid = "1"}}%

function paraworld.map.RemoveWorld_Test(input)

	local msg = {

		sessionkey = input.sessionkey,

		worldid = input.worldid,

	};

	paraworld.map.RemoveWorld(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end);

end







--passed: 删除指定的World（不存在的数据）

function paraworld.map.RemoveWorld_Test_NotData()

	local msg = {

		operation = "login",

		username = "LiXizhi",

		password = "anything"

	};

	paraworld.auth.AuthUser(msg, "test", function(msg)

		local sessionkey = msg.sessionkey;

		local msg = {

			sessionkey = sessionkey,

			worldid = 1000

		};

		paraworld.map.RemoveWorld(msg, "test", function(msg)

			log(commonlib.serialize(msg));

		end);

	end);

end







--passed: 上传文件

-- %TESTCASE{"map.UploadFile", func = "paraworld.map.UploadFile_Test", input ={sessionkey = "", file = "R0lGODlhBwAJAIABAAAzzP///yH5BAEAAAEALAAAAAAHAAkAAAIMjI+Am9yhoDRRVnoKADs=", overwrite = 1, extension = ".jpg",}}%
function paraworld.map.UploadFile_Test()

	local msg = {
		sessionkey = Map3DSystem.User.sessionkey,
		file = "R0lGODlhBwAJAIABAAAzzP///yH5BAEAAAEALAAAAAAHAAkAAAIMjI+Am9yhoDRRVnoKADs=",
		filepath = "photo.txt",
		overwrite = 1,
	};
	paraworld.map.UploadFile(msg, "test", function(msg)
		log(commonlib.serialize(msg));
	end)
end

--passed: 依据文件的逻辑路径删除一个用户文?

-- %TESTCASE{"file.DeleteFile", func = "paraworld.file.DeleteFile_Test", input ={sessionkey = "6ea1ce24-bdf7-4893-a053-eb5fd2a74281", filepath = "map/map1.jpg",}}%

function paraworld.file.DeleteFile_Test(input)

	local msg = {

		sessionkey = input.sessionkey or "6ea1ce24-bdf7-4893-a053-eb5fd2a74281",

		filepath = input.filepath or nil,

	};

	paraworld.file.DeleteFile(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end)

end





--passed: 依据文件逻辑地址取得一个用户文件的数据

-- %TESTCASE{"file.GetFile", func = "paraworld.file.GetFile_Test", input ={sessionkey = "6ea1ce24-bdf7-4893-a053-eb5fd2a74281", filepath = "map/map1.jpg", fileID = "0",}}%

function paraworld.file.GetFile_Test(input)

	local msg = {

		sessionkey = input.sessionkey or "6ea1ce24-bdf7-4893-a053-eb5fd2a74281",

		filepath = input.filepath or nil,

		fileID = input.fileID or 0,

	};

	paraworld.file.GetFile(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end)

end





--passed: 依据文件逻辑地址取得一个用户文件的数据

-- %TESTCASE{"file.RenameFile", func = "paraworld.file.RenameFile_Test", input ={sessionkey = "6ea1ce24-bdf7-4893-a053-eb5fd2a74281", filepath = "map/map1.jpg", newFilePath = "map/map1.jpg"}}%

function paraworld.file.RenameFile_Test(input)

	local msg = {

		sessionkey = input.sessionkey or "6ea1ce24-bdf7-4893-a053-eb5fd2a74281",

		filepath = input.filepath or nil,

		newFilePath = input.newFilePath or nil,

	};

	paraworld.file.RenameFile(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end)

end





--passed: 依据指定的逻辑地址查找用户文件

-- %TESTCASE{"file.FindFile", func = "paraworld.file.FindFile_Test", input ={sessionkey = "6ea1ce24-bdf7-4893-a053-eb5fd2a74281", filepath = "map/map1.jpg"}}%

function paraworld.file.FindFile_Test(input)

	local msg = {

		sessionkey = input.sessionkey or "6ea1ce24-bdf7-4893-a053-eb5fd2a74281",

		filepath = input.filepath or nil,

	};

	paraworld.file.FindFile(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end)

end







--passed: 购买Tile

-- %TESTCASE{"map.BuyTile", func = "paraworld.map.BuyTile_Test", input ={sessionkey = "6ea1ce24-bdf7-4893-a053-eb5fd2a74281", x = 0.706329345703125, y = 0.4027099609375, z = 0, terrainType = 1, texture = "testA"}}%

function paraworld.map.BuyTile_Test(input)

	local msg = {

		sessionkey = input.sessionkey or "6ea1ce24-bdf7-4893-a053-eb5fd2a74281",

		x = input.x or nil,

		y = input.y or nil,

		z = input.z or nil,

		terrainType = input.terrainType or 1,

		texture = input.texture or nil,

	};

	paraworld.map.BuyTile(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end)

end







--passed: 创建用户文件?

-- %TESTCASE{"file.CreateFile", func = "paraworld.file.CreateFile_Test", input ={sessionkey = "6ea1ce24-bdf7-4893-a053-eb5fd2a74281", fileURL="http://www.pala5.com/img/test.jpg", filepath = "map/map1.jpg", overwrite = 1}}%

function paraworld.file.CreateFile_Test(input)

	local msg = {

		sessionkey = input.sessionkey or "6ea1ce24-bdf7-4893-a053-eb5fd2a74281",

		fileURL = input.fileURL or nil,

		filepath = input.filepath or nil,

		overwrite = input.overwrite or 0,

	};

	paraworld.file.CreateFile(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end)

end







--passed: 创建用户文件?

-- %TESTCASE{"map.GetWorlds", func = "paraworld.map.GetWorlds_Test", input ={uid = "6ea1ce24-bdf7-4893-a053-eb5fd2a74281",}}%

function paraworld.map.GetWorlds_Test(input)

	local msg = {

		uid = input.uid,

	};

	paraworld.map.GetWorlds(msg, "test", function(msg)

		log(commonlib.serialize(msg));

	end)

end



--passed: 上传文件 by Blocks

-- %TESTCASE{"map.UploadFileEx", func = "paraworld.map.UploadFileEx_Test", input ={src = "changes.txt", filepath = "upload/UploadFileEx_test.txt"}}%

function paraworld.map.UploadFileEx_Test(input)

	local msg = {

		src = "changes.txt",

		overwrite = 1,

		filepath = "upload/UploadFileEx_test.txt",

	};

	if(input and input.src) then	

		msg.src = input.src;

		msg.filepath = input.filepath or msg.filepath;

	end

	paraworld.map.UploadFileEx(msg, "test", function(msg)

		commonlib.echo(msg);

	end)

	

	-- test another

	--local msg = {

		--isphoto = true,

		--src = "temp/myphoto.jpg",

		--overwrite = 1,

		--filepath = "profiles/myphoto1.jpg",

	--};

	--paraworld.map.UploadFileEx(msg, "test1", function(msg)

		--commonlib.echo(msg);

	--end)

end







-- passed: 2008.12.8 

-- %TESTCASE{"paraworld.file.Create_Rest", func = "paraworld.file.Create_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", fileUrl = "http://pala5.cn/file/test1", filepath = "/file/test1", overwrite = "1", format = "1"}}%

function paraworld.file.Create_Rest(input)

	local url = "http://files.test.pala5.cn/Create.ashx";

	

	log("post "..url.."\n")

	local c = cURL.easy_init()

	

	c:setopt_url(url)

	c:post(input)

	c:perform({writefunction = function(str) 

			log("-->:"..str.."\r\n")

		 end})

		 

	log("\r\nDone!\r\n")

end





-- passed: 2008.12.8 

-- %TESTCASE{"paraworld.file.Delete_Rest", func = "paraworld.file.Delete_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", filepath = "/file/test1", format = "1"}}%

function paraworld.file.Delete_Rest(input)

	local url = "http://files.test.pala5.cn/Delete.ashx";

	

	log("post "..url.."\n")

	local c = cURL.easy_init()

	

	c:setopt_url(url)

	c:post(input)

	c:perform({writefunction = function(str) 

			log("-->:"..str.."\r\n")

		 end})

		 

	log("\r\nDone!\r\n")

end





-- passed: 2008.12.8 

-- %TESTCASE{"paraworld.file.Find_Rest", func = "paraworld.file.Find_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", filepath = "/file/*", format = "1"}}%

function paraworld.file.Find_Rest(input)

	local url = "http://files.test.pala5.cn/Find.ashx";

	

	log("post "..url.."\n")

	local c = cURL.easy_init()

	

	c:setopt_url(url)

	c:post(input)

	c:perform({writefunction = function(str) 

			log("-->:"..str.."\r\n")

		 end})

		 

	log("\r\nDone!\r\n")

end





-- passed: 2008.12.8 

-- %TESTCASE{"paraworld.file.Get_Rest", func = "paraworld.file.Get_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", filepath = "/file/test1", format = "1"}}%

function paraworld.file.Get_Rest(input)

	local url = "http://files.test.pala5.cn/Get.ashx";

	

	log("post "..url.."\n")

	local c = cURL.easy_init()

	

	c:setopt_url(url)

	c:post(input)

	c:perform({writefunction = function(str) 

			log("-->:"..str.."\r\n")

		 end})

		 

	log("\r\nDone!\r\n")

end





-- passed: 2008.12.8 

-- %TESTCASE{"paraworld.file.Rename_Rest", func = "paraworld.file.Rename_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", filepath = "/file/test1", newFilePath = "/file/newTest1", format = "1"}}%

function paraworld.file.Rename_Rest(input)

	local url = "http://files.test.pala5.cn/Rename.ashx";

	

	log("post "..url.."\n")

	local c = cURL.easy_init()

	

	c:setopt_url(url)

	c:post(input)

	c:perform({writefunction = function(str) 

			log("-->:"..str.."\r\n")

		 end})

		 

	log("\r\nDone!\r\n")

end













-- passed: 2008.12.8 

-- %TESTCASE{"paraworld.map.GetWorldByID_Rest", func = "paraworld.map.GetWorldByID_Rest", input={worldid = "1", format = "1"}}%

function paraworld.map.GetWorldByID_Rest(input)

	local url = "http://map.test.pala5.cn/GetWorldByID.ashx";

	

	log("post "..url.."\n")

	local c = cURL.easy_init()

	

	c:setopt_url(url)

	c:post(input)

	c:perform({writefunction = function(str) 

			log("-->:"..str.."\r\n")

		 end})

		 

	log("\r\nDone!\r\n")

end





-- passed: 2008.12.8 

-- %TESTCASE{"paraworld.map.GetWorlds_Rest", func = "paraworld.map.GetWorlds_Rest", input={uid = "e03b3286-2e42-49d6-8a74-736223bfedca", format = "1"}}%

function paraworld.map.GetWorlds_Rest(input)

	local url = "http://map.test.pala5.cn/GetWorlds.ashx";

	

	log("post "..url.."\n")

	local c = cURL.easy_init()

	

	c:setopt_url(url)

	c:post(input)

	c:perform({writefunction = function(str) 

			log("-->:"..str.."\r\n")

		 end})

		 

	log("\r\nDone!\r\n")

end





-- passed: 2008.12.8 

-- %TESTCASE{"paraworld.map.JoinWorld_Rest", func = "paraworld.map.JoinWorld_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", worldid = "1", format = "1"}}%

function paraworld.map.JoinWorld_Rest(input)

	local url = "http://map.test.pala5.cn/JoinWorld.ashx";

	

	log("post "..url.."\n")

	local c = cURL.easy_init()

	

	c:setopt_url(url)

	c:post(input)

	c:perform({writefunction = function(str) 

			log("-->:"..str.."\r\n")

		 end})

		 

	log("\r\nDone!\r\n")

end





-- passed: 2008.12.8 

-- %TESTCASE{"paraworld.map.LeaveWorld_Rest", func = "paraworld.map.LeaveWorld_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", worldid = "1", format = "1"}}%

function paraworld.map.LeaveWorld_Rest(input)

	local url = "http://map.test.pala5.cn/LeaveWorld.ashx";

	

	log("post "..url.."\n")

	local c = cURL.easy_init()

	

	c:setopt_url(url)

	c:post(input)

	c:perform({writefunction = function(str) 

			log("-->:"..str.."\r\n")

		 end})

		 

	log("\r\nDone!\r\n")

end





-- passed: 2008.12.8 

-- %TESTCASE{"paraworld.map.PublishWorld_Rest", func = "paraworld.map.PublishWorld_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", name = "test world name", desc = "this is a test world", format = "1"}}%

function paraworld.map.PublishWorld_Rest(input)

	local url = "http://map.test.pala5.cn/PublishWorld.ashx";

	

	log("post "..url.."\n")

	local c = cURL.easy_init()

	

	c:setopt_url(url)

	c:post(input)

	c:perform({writefunction = function(str) 

			log("-->:"..str.."\r\n")

		 end})

		 

	log("\r\nDone!\r\n")

end







-- passed: 2008.12.8 

-- %TESTCASE{"paraworld.map.RemoveWorld_Rest", func = "paraworld.map.RemoveWorld_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", worldid = "1", format = "1"}}%

function paraworld.map.RemoveWorld_Rest(input)

	local url = "http://map.test.pala5.cn/RemoveWorld.ashx";

	

	log("post "..url.."\n")

	local c = cURL.easy_init()

	

	c:setopt_url(url)

	c:post(input)

	c:perform({writefunction = function(str) 

			log("-->:"..str.."\r\n")

		 end})

		 

	log("\r\nDone!\r\n")

end





-- passed: 2008.12.8 

-- %TESTCASE{"paraworld.map.UpdateWorld_Rest", func = "paraworld.map.UpdateWorld_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", worldid = "1", name = "new test world name", desc = "this is a new test world", format = "1"}}%

function paraworld.map.UpdateWorld_Rest(input)

	local url = "http://map.test.pala5.cn/UpdateWorld.ashx";

	

	log("post "..url.."\n")

	local c = cURL.easy_init()

	

	c:setopt_url(url)

	c:post(input)

	c:perform({writefunction = function(str) 

			log("-->:"..str.."\r\n")

		 end})

		 

	log("\r\nDone!\r\n")

end





-- passed: 2008.12.8 

-- %TESTCASE{"paraworld.map.VisitWorld_Rest", func = "paraworld.map.VisitWorld_Rest", input={sessionkey = "3e3404f4-7a52-44c3-8821-fff92de734e9", worldid = "1", format = "1"}}%

function paraworld.map.VisitWorld_Rest(input)

	local url = "http://map.test.pala5.cn/VisitWorld.ashx";

	

	log("post "..url.."\n")

	local c = cURL.easy_init()

	

	c:setopt_url(url)

	c:post(input)

	c:perform({writefunction = function(str) 

			log("-->:"..str.."\r\n")

		 end})

		 

	log("\r\nDone!\r\n")

end


-- passed: 2008.12.8 

-- %TESTCASE{"paraworld.map.MqlQuery_Rest", func = "paraworld.map.MqlQuery_Rest", input={query = "select top 2 * from WorldMembers", format = "1"}}%

function paraworld.map.MqlQuery_Rest(input)

	local url = "http://map.test.pala5.cn/Query.ashx";

	

	log("post "..url.."\n")

	local c = cURL.easy_init()

	

	c:setopt_url(url)

	c:post(input)

	c:perform({writefunction = function(str) 

			log("-->:"..str.."\r\n")

		 end})

		 

	log("\r\nDone!\r\n")

end