NPL.load("(gl)script/apps/WebServer/httpd/wsapi_request.lua");
local request = commonlib.gettable("commonlib.wsapi.request");

NPL.load("(gl)script/apps/PayServer/PayServer.lua");

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

		local req=request.new(wsapi_env);

		local url, outputmsg_s;
		local request,inputmsg,output={},{},{};

		local seq_id = PayServer.get_next_seq();
		PayServer.requests_pool[seq_id] = {seq=seq_id, };

		--commonlib.echo("================GET_POST====")
		--commonlib.echo(req.GET)
		if (next(req.GET)~=nil and req.GET.url) then
			url=string.lower(req.GET.url);
			request=req.GET;
		end

		--commonlib.echo(req.POST)
		if (next(req.POST)~=nil and req.POST.url) then
			url=string.lower(req.POST.url);
			request=req.POST;
		end
		if (next(request)~=nil) then
			if (url=="querycount") then
				local _nid=string.match(request.user_nid,"(%d+)");
				inputmsg={
					url="QueryCount",
					seq= seq_id,
					req={
						user_nid= tonumber(_nid),
						gsid= tonumber(request.gsid),
						from = tonumber(request.from),
						},
					callback="(ws)script/apps/PayServer/web/HttpPayBack.lua",
					}
			elseif (url=="querynid") then
				local _nid = request.user_oid;
				inputmsg={
					url="QueryNid",
					seq= seq_id,
					req={
						plat = tonumber(request.platid),
						oid = _nid,
						},
					callback="(ws)script/apps/PayServer/web/HttpPayBack.lua",
					}
			elseif (url=="pay") then
				local _nid=string.match(request.user_nid,"(%d+)");
				local gsidtype;
				if (request.type) then
					gsidtype = tonumber(request.type);
				else
					gsidtype = 0;
				end
				
					inputmsg={
						url="Pay",
						seq= seq_id,
						req={
							user_nid = tonumber(_nid),
							gsid = tonumber(request.gsid),
							count = tonumber(request.count),
							bonus = request.bonus,
							money = tonumber(request.money),
							method = tonumber(request.method),
							type = gsidtype,
							is_test = tonumber(request.is_test),
							orderno = request.orderno,	
							from = tonumber(request.from),
							},
						callback="(ws)script/apps/PayServer/web/HttpPayBack.lua",
						}
				
			end

			if (url =="querycount" or url == "pay" or url == "querynid") then
				local inputmsg_s = commonlib.serialize_compact(inputmsg);
				LOG.std(nil, "debug", "WebServer inputmsg", inputmsg);
				NPL.activate("(rest)script/apps/GameServer/rest.lua",inputmsg);

				local bHasAsyncCallFinished = false;
				local nTickCount = 0;
				repeat
					coroutine.yield("",0.5); 
					local request_tmp = PayServer.requests_pool[seq_id];
					if(request_tmp and request_tmp.has_result) then
						bHasAsyncCallFinished = true;
						output = request_tmp.result;
						--PayServer.requests_pool[seq_id] = nil;
					end
					nTickCount = nTickCount + 1
				until bHasAsyncCallFinished and nTickCount < nMaxTickCount

				if(not bHasAsyncCallFinished) then
					-- timeout
					output={seq=seq_id,result=501};
				end
			else -- wrong url
				output = {seq=seq_id, result=502};
			end
		else  -- no request
			output = {seq=seq_id, result=503};
		end --  if (next(request)~=nil)

		outputmsg_s = commonlib.serialize_compact(output);
		coroutine.yield(outputmsg_s);
	end

	return 200, headers, coroutine.wrap(hello_text)

end
