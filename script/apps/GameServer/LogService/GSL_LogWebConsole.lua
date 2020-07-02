NPL.load("(gl)script/apps/WebServer/httpd/wsapi_request.lua");
local request = commonlib.gettable("commonlib.wsapi.request");


module(..., package.seeall)

-- the function to be called when request arrives
-- @param wsapi_env: 
-- {DOCUMENT_ROOT="script/apps/WebServer/test",
--  CONTENT_LENGTH="",
--  SCRIPT_NAME="/helloworld.lua",
--  SCRIPT_FILENAME="script/apps/WebServer/test/helloworld.lua",
--  PATH_INFO="/",
--  PATH_TRANSLATED="script/apps/WebServer/test/helloworld.lua",
--  error="",
--  input={length=0,},
--  }

local nMaxTickCount = 5;

function run(wsapi_env)
	local headers = { ["Content-type"] = "text/html" }
	
	local function hello_text()		
		coroutine.yield("TODO: GSL_LogWebConsole");
	end

	return 200, headers, coroutine.wrap(hello_text)

end
