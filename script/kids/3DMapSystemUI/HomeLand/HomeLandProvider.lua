--[[
Title: HomeLandProvider
Author(s): Leio
Date: 2009/11/8
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandProvider.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Player/main.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/homeland/paraworld.homeland.petevolved.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandNodeParser.lua");
local HomeLandProvider = commonlib.gettable("Map3DSystem.App.HomeLand.HomeLandProvider");
HomeLandProvider.loadedFunc = nil;
HomeLandProvider.savedFunc = nil;

function HomeLandProvider.LoadXmlFromServer(nid,callbackFunc)
	if(nid == Map3DSystem.User.nid) then
		-- my homeland
		HomeLandProvider.LoadMyHomeLand(nid,callbackFunc);
	else
		-- other's homeland
		HomeLandProvider.LoadOPCHomeLand(nid,callbackFunc);
	end
end
function HomeLandProvider.LoadOPCHomeLand(nid,callbackFunc)
	local ItemManager = Map3DSystem.Item.ItemManager;
	ItemManager.LoadHomeLandItems(nid, function(msg)
		local count = ItemManager.GetHomelandItemCount(nid);
		local dataXmlStr = "";
		local i;
		local s = string.format("=====================clientdata in home:%d",nid or -1);
		commonlib.echo(s);
		for i = 1, count do
			local item = ItemManager.GetHomelandItemByOrder(nid, i);
			if(item ~= nil) then
				local data = item.clientdata;
				---------------debug
				local output_test = {
					data = data or "",
					gsid = item.gsid,
					guid = item.guid,
				}
				commonlib.echo(output_test);
				----------------
				if(data) then
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid)
					if(gsItem) then
						--data = string.gsub(data, "$guid$", tostring(item.guid));
						if(string.find(data,[[guid=".-"]]))then
							data = string.gsub(data, "guid=\".-\" ", "guid=\""..tostring(item.guid).."\" ");
						else
							data = string.gsub(data, "/>", "guid=\""..tostring(item.guid).."\" />");
						end
						data = string.gsub(data, "AssetFile=\"$assetfile$\" ", "AssetFile=\""..tostring(gsItem.assetfile).."\" ");
						dataXmlStr = dataXmlStr..data;
					end
				end
			end
		end
		commonlib.echo("==========dataXmlStr");
		--<HomeLandObj_B visible=\"true\" IsCharacter=\"false\" y=\"30.00\" x=\"19958.40\" name=\"20110430T080054.595790-229\" z=\"20314.57\" 
		-- scaling=\"1.00\" AssetFile=\"model/06props/v5/03quest/StoneFunitrue/StoneFunitrue_Table.x\" facing=\"0.00\" 
		-- HomeLandObj=\"OutdoorOther\" GridInfo=\"\" belongto_outdoor_uid=\"\" guid=\"534\" gsid=\"30066\" music_isplaying=\"false\" />
		commonlib.echo(dataXmlStr);	
		HomeLandProvider.CatchString(dataXmlStr,callbackFunc)
	end);
end

function HomeLandProvider.LoadMyHomeLand(nid,callbackFunc)
	local ItemManager = Map3DSystem.Item.ItemManager;
	ItemManager.LoadHomeLandItems(nil, function(msg)
		local s = string.format("=====================clientdata in home:%d",nid or -1);
		commonlib.echo(s);
		local count = ItemManager.GetHomelandItemCount();
		local dataXmlStr = "";
		local i;
		local empty_clientdata  = {};
		for i = 1, count do
			local item = ItemManager.GetHomelandItemByOrder(nil, i);
			if(item ~= nil) then
				local data = item.clientdata;
				---------------debug
				local output_test = {
					data = data or "nil",
					gsid = item.gsid,
					guid = item.guid,
				}
				commonlib.echo(output_test);
				----------------
				if(data) then
					if(data ~= "")then
						local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid)
						--commonlib.echo(gsItem);
						if(gsItem) then
							--data = string.gsub(data, "$guid$", tostring(item.guid));
							if(string.find(data,[[guid=".-"]]))then
								data = string.gsub(data, "guid=\".-\" ", "guid=\""..tostring(item.guid).."\" ");
							else
								data = string.gsub(data, "/>", "guid=\""..tostring(item.guid).."\" />");
							end
							data = string.gsub(data, "AssetFile=\"$assetfile$\" ", "AssetFile=\""..tostring(gsItem.assetfile).."\" ");
							dataXmlStr = dataXmlStr..data;
						end
					else
						table.insert(empty_clientdata,{guid = item.guid, });
					end
				end
			end
		end
		commonlib.echo("=======================empty_clientdata");
		commonlib.echo(empty_clientdata);
		--回收空字符串的item
		function removeItem(index,empty_clientdata)
			if(not empty_clientdata)then return end
			local o = empty_clientdata[index]
			if(not o or not o.guid)then
				return;
			end
			local guid = o.guid;
			commonlib.echo(guid);
			--回收仓库
			local ItemManager = Map3DSystem.Item.ItemManager;
			ItemManager.RemoveHomeLandItem(guid, function(msg)
				commonlib.echo("removed");
				index = index + 1;
				removeItem(index,empty_clientdata);
			end);
		end
		commonlib.echo("==================start remove empty clientdata");
		--removeItem(1,empty_clientdata);
		commonlib.echo("==================end remove empty clientdata");
		
		commonlib.echo("==========dataXmlStr");
		commonlib.echo(dataXmlStr);		
		HomeLandProvider.CatchString(dataXmlStr,callbackFunc)

	end);
	--HomeLandProvider.CatchString(HomeLandProvider.Test(),callbackFunc)
end
function HomeLandProvider.Test()
	local s = [[<HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.177110671997" x="19998.681640625" name="20091106T062106.875000-3524" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/PineAppleTree/PineAppleTreeStage0.x" z="20309.20703125" HomeLandObj="PlantE" GridInfo="20091106T062036.812500-3204|1" DoorPlate="" guid="287" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.001176834106" x="19974.45703125" name="20091106T061943.312500-2904" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20289.10546875" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="279" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.001029968262" x="19977.51953125" name="20091106T061750.687500-1459" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20292.306640625" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="275" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.000974655151" x="19970.580078125" name="20091106T061739.390625-1364" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20291.181640625" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="272" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.176624298096" x="19973.080078125" name="20091106T061730.546875-1276" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/Bamboo/BambooStage0.x" z="20295.9296875" HomeLandObj="PlantE" GridInfo="20091106T061631.062500-634|1" DoorPlate="" guid="270" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.000719070435" x="19973.080078125" name="20091106T061631.062500-634" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20295.9296875" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="268" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.000719070435" x="19973.080078125" name="20091106T061630.265625-559" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20295.9296875" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="266" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.176658630371" x="19969.701171875" name="20091105T015321.125000-901" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/Bamboo/BambooStage0.x" z="20303.251953125" HomeLandObj="PlantE" GridInfo="20091026T055237.609375-1420|1" DoorPlate="" guid="237" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.176645278931" x="19964.828125" name="20091105T015319.187500-871" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/PurpleCaneTree/PurpleCaneTreeStage0.x" z="20301.13671875" HomeLandObj="PlantE" GridInfo="20091105T015309.546875-678|1" DoorPlate="" guid="236" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.176645278931" x="19968.55078125" name="20091105T015317.234375-841" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/PurpleCaneTree/PurpleCaneTreeStage0.x" z="20297.275390625" HomeLandObj="PlantE" GridInfo="20091105T015311.578125-720|1" DoorPlate="" guid="235" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.00074005127" x="19968.55078125" name="20091105T015311.578125-720" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20297.275390625" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="234" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.00074005127" x="19964.828125" name="20091105T015309.546875-678" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20301.13671875" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="233" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.001308441162" x="19953.734375" name="20091026T055239.625000-1464" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20307.64453125" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="173" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.00075340271" x="19969.701171875" name="20091026T055237.609375-1420" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20303.251953125" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="172" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.176630020142" x="19964.751953125" name="20091026T054910.765625-1320" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/PineAppleTree/PineAppleTreeStage0.x" z="20309.171875" HomeLandObj="PlantE" GridInfo="20091026T054853.265625-1135|1" DoorPlate="" guid="171" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.176507949829" x="19960.71875" name="20091026T054902.015625-1282" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/PineAppleTree/PineAppleTreeStage0.x" z="20313.478515625" HomeLandObj="PlantE" GridInfo="20091026T054856.218750-1177|1" DoorPlate="" guid="170" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.000602722168" x="19960.71875" name="20091026T054856.218750-1177" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20313.478515625" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="169" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.00072479248" x="19964.751953125" name="20091026T054853.265625-1135" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20309.171875" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="168" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.176378250122" x="19953.99609375" name="20091022T081914.656250-1260" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/CherryTree/CherryTreeStage0.x" z="20316.943359375" HomeLandObj="PlantE" GridInfo="20091022T081821.437500-878|1" DoorPlate="" guid="137" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.175956726074" x="19945.34375" name="20091022T081910.390625-1225" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/CherryTree/CherryTreeStage0.x" z="20315.421875" HomeLandObj="PlantE" GridInfo="20091022T081818.109375-832|1" DoorPlate="" guid="136" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.176061630249" x="19949.236328125" name="20091022T081908.421875-1201" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/CherryTree/CherryTreeStage0.x" z="20312.052734375" HomeLandObj="PlantE" GridInfo="20091022T081811.406250-774|1" DoorPlate="" guid="135" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.176202774048" x="19949.779296875" name="20091022T081902.984375-1166" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/PineAppleTree/PineAppleTreeStage0.x" z="20319.826171875" HomeLandObj="PlantE" GridInfo="20091022T081808.093750-738|1" DoorPlate="" guid="134" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.17654800415" x="19933.83984375" name="20091022T081901.140625-1142" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/PineAppleTree/PineAppleTreeStage0.x" z="20315.53515625" HomeLandObj="PlantE" GridInfo="20091022T081805.171875-702|1" DoorPlate="" guid="133" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.176435470581" x="19938.490234375" name="20091022T081859.218750-1118" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/PineAppleTree/PineAppleTreeStage0.x" z="20319.896484375" HomeLandObj="PlantE" GridInfo="20091022T081716.281250-666|1" DoorPlate="" guid="132" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.176343917847" x="19950.396484375" name="20091022T081856.140625-1094" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/Bamboo/BambooStage0.x" z="20324.185546875" HomeLandObj="PlantE" GridInfo="20091022T081708.843750-620|1" DoorPlate="" guid="131" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.176357269287" x="19944.24609375" name="20091022T081854.343750-1070" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/Bamboo/BambooStage0.x" z="20324.39453125" HomeLandObj="PlantE" GridInfo="20091022T081705.171875-584|1" DoorPlate="" guid="130" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.176601409912" x="19938.025390625" name="20091022T081852.500000-1046" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/Bamboo/BambooStage0.x" z="20324.7421875" HomeLandObj="PlantE" GridInfo="20091022T081632.500000-369|1" DoorPlate="" guid="129" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.176820755005" x="19950.994140625" name="20091022T081850.578125-1022" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/PurpleCaneTree/PurpleCaneTreeStage0.x" z="20328.248046875" HomeLandObj="PlantE" GridInfo="20091022T081630.234375-333|1" DoorPlate="" guid="128" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.176900863647" x="19945.22265625" name="20091022T081848.468750-998" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/PurpleCaneTree/PurpleCaneTreeStage0.x" z="20328.767578125" HomeLandObj="PlantE" GridInfo="20091022T081634.703125-405|1" DoorPlate="" guid="127" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.176845550537" x="19939.26953125" name="20091022T081838.468750-963" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/PurpleCaneTree/PurpleCaneTreeStage0.x" z="20329.443359375" HomeLandObj="PlantE" GridInfo="20091022T081628.062500-297|1" DoorPlate="" guid="126" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.000473022461" x="19953.99609375" name="20091022T081821.437500-878" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20316.943359375" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="125" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.000051498413" x="19945.34375" name="20091022T081818.109375-832" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20315.421875" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="124" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.000156402588" x="19949.236328125" name="20091022T081811.406250-774" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20312.052734375" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="123" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.000297546387" x="19949.779296875" name="20091022T081808.093750-738" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20319.826171875" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="122" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.000642776489" x="19933.83984375" name="20091022T081805.171875-702" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20315.53515625" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="121" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.00053024292" x="19938.490234375" name="20091022T081716.281250-666" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20319.896484375" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="120" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.000438690186" x="19950.396484375" name="20091022T081708.843750-620" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20324.185546875" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="119" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.000452041626" x="19944.24609375" name="20091022T081705.171875-584" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20324.39453125" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="118" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.000995635986" x="19945.22265625" name="20091022T081634.703125-405" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20328.767578125" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="116" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.000696182251" x="19938.025390625" name="20091022T081632.500000-369" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20324.7421875" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="115" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.000915527344" x="19950.994140625" name="20091022T081630.234375-333" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20328.248046875" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="114" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.000940322876" x="19939.26953125" name="20091022T081628.062500-297" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20329.443359375" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="113" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.176645278931" x="19961.283203125" name="20091022T081054.531250-566" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/Bamboo/BambooStage0.x" z="20297.126953125" HomeLandObj="PlantE" GridInfo="20091022T081041.890625-448|1" DoorPlate="" guid="112" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.176696777344" x="19956.099609375" name="20091022T081052.906250-542" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/Bamboo/BambooStage0.x" z="20295.26953125" HomeLandObj="PlantE" GridInfo="20091022T081039.859375-412|1" DoorPlate="" guid="111" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.176670074463" x="19952" name="20091022T081050.328125-518" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/Bamboo/BambooStage0.x" z="20295.021484375" HomeLandObj="PlantE" GridInfo="20091022T081037.453125-376|1" DoorPlate="" guid="110" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.00074005127" x="19961.283203125" name="20091022T081041.890625-448" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20297.126953125" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="109" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.000791549683" x="19956.099609375" name="20091022T081039.859375-412" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20295.26953125" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="108" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.000764846802" x="19952" name="20091022T081037.453125-376" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20295.021484375" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="107" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.1771068573" x="19955.03125" name="20091022T080910.484375-300" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/PineAppleTree/PineAppleTreeStage0.x" z="20300.259765625" HomeLandObj="PlantE" GridInfo="20090925T072521.062500-266|1" DoorPlate="" guid="106" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.176645278931" x="19959.107421875" name="20091015T133446.171875-330" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/PineAppleTree/PineAppleTreeStage0.x" z="20301.00390625" HomeLandObj="PlantE" GridInfo="20091015T084358.750000-259|1" DoorPlate="" guid="99" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.176643371582" x="19959.345703125" name="20091015T133438.500000-306" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/08homelandPlant/PurpleCaneTree/PurpleCaneTreeStage0.x" z="20305.525390625" HomeLandObj="PlantE" GridInfo="20091015T084400.953125-295|1" DoorPlate="" guid="98" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.000738143921" x="19959.345703125" name="20091015T084400.953125-295" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20305.525390625" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="93" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.00074005127" x="19959.107421875" name="20091015T084358.750000-259" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20301.00390625" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="92" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="30.001201629639" x="19955.03125" name="20090925T072521.062500-266" facing="0" homezone="" scaling="1" AssetFile="model/05plants/v5/07parterre/SiennaWoodyPile/SiennaWoodyPile_1.x" z="20300.259765625" HomeLandObj="Grid" GridInfo="" DoorPlate="" guid="67" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="0.094581604003906" x="2.6775512695313" name="20090807T103112.171875-515" facing="0" homezone="" scaling="1" AssetFile="model/02furniture/v1/chair.x" z="3.30908203125" HomeLandObj="Furniture" GridInfo="" DoorPlate="" guid="18" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="0.094581604003906" x="0.3480224609375" name="20090807T103110.046875-500" facing="0" homezone="" scaling="1" AssetFile="model/02furniture/v1/tv/tv.x" z="1.474853515625" HomeLandObj="Furniture" GridInfo="" DoorPlate="" guid="17" /><HomeLandObj_B visible="true" IsCharacter="false" alpha="1" y="0.00061023735906929" x="19992.2421875" name="20090807T103049.296875-429" facing="0" homezone="" scaling="1" AssetFile="model/01building/v5/01house/PoliceStation/PoliceStation.x" z="19995.607421875" HomeLandObj="RoomEntry" GridInfo="" DoorPlate="" guid="16" />]]
	return s;
end
function HomeLandProvider.CatchString(dataXmlStr,callbackFunc)
	local result = string.format([[
	<Room>
		<Config>
			
		</Config>
		<Data>
			<TemplateValue>
			</TemplateValue>
			<CustomValue>
				<Sprite3D>
					%s
				</Sprite3D>
			</CustomValue>
		</Data>
	</Room>
	]], dataXmlStr);
	
	local custom_sprite3D = HomeLandProvider.DoParse(result);
	local msg = {};
	msg.bSucceed = true;
	msg.custom_sprite3D = custom_sprite3D;
	if(callbackFunc and type(callbackFunc) == "function")then
		callbackFunc(msg);
	end
end


--初始化自己坐骑的远程数据和坐骑语言
-- This function in called at UserLoginProcess.Proc_VerifyPet login process
-- @nid: nid of the user mount pet
-- @callbackFunc: callback function after the pet data is retrieved
function HomeLandProvider.PetInit(nid, callbackFunc)
	if(System.options.mc) then
		return;
	end
	NPL.load("(gl)script/kids/3DMapSystemUI/HomeLand/HomeLandGateway.lua");
	-- NOTE andy 2009/11/14: i expose the config loading to the user login procedure

	--初始化自己的坐骑
	MyCompany.Aries.Pet.InitMyDragonPet(callbackFunc);
end

-- @param callbackFunc: on succeed callback function
function HomeLandProvider.Save(s, callbackFunc)
	commonlib.echo("=============save");
	commonlib.echo(s);
	if(not s)then return end
	
	------------------------------------------------------------------------
	------ 1 parse all clientdata for all modified item
	------------------------------------------------------------------------
	local ItemManager = Map3DSystem.Item.ItemManager;
	HomeLandProvider.MadeClientdata(ItemManager,s,"HomeLandObj_B");
	
	---- NOTE 2009/12/6: leio, i remove the following line to the callback function
	--ItemManager.EndHomeLandEditing();
	
	ItemManager.SaveHomeLandItems(function(issucceed)
		if(issucceed == true) then
			ItemManager.EndHomeLandEditing();
			if(callbackFunc and type(callbackFunc) == "function")then
				callbackFunc();
			end
		else
			_guihelper.MessageBox([[<div style="margin-left:40px;margin-top:30px;">保存家园出错，请尝试重新保存。</div>]]);
		end
	end)
	
	------------------------------------------------------
end
function HomeLandProvider.MadeClientdata(ItemManager,s,tag)
	if(not ItemManager or not s or not tag)then return end
	local clientdata;
	local p = string.format([[<%s[^,]-/>]],tag);
	commonlib.echo("==================start made clientdata");
	for clientdata in string.gmatch(s, p) do	
		local __,__,guid = string.find(clientdata,[[guid%s*=%s*"%s*(.-)%s*"]]);
		guid = tonumber(guid);
		commonlib.echo("guid");
		commonlib.echo(guid);
		if(guid)then
				local item = ItemManager.GetItemByGUID(guid);
				if(item) then
					local gsItem = ItemManager.GetGlobalStoreItemInMemory(item.gsid)
					commonlib.echo("gsid");
					commonlib.echo(item.gsid);
					commonlib.echo(clientdata);
					if(gsItem) then
						clientdata = string.gsub(clientdata, "AssetFile=[^:]- ", "AssetFile=\"$assetfile$\" ");
						--------------------------------------------------------------------
						-- 2 modify the clientdata locally
						--------------------------------------------------------------------
						-- save each modified clientdata
						--commonlib.echo("@@@"..guid.."---"..clientdata);
						ItemManager.ModifyHomeLandItem(guid, clientdata);
					end
				end
		end
	end
	commonlib.echo("==================end made clientdata");
end


function HomeLandProvider.DoParse(s)
	if(not s)then return end;
	local template_sprite3D,custom_sprite3D;
	local xmlRoot = ParaXML.LuaXML_ParseString(s);
	--local xmlRoot = ParaXML.LuaXML_ParseFile(s);
	if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
		xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
		NPL.load("(gl)script/ide/XPath.lua");	
			
		custom_sprite3D = HomeLandProvider.DoParse_Sprite3D(xmlRoot,"//CustomValue");
		
	end
	return custom_sprite3D;
end
function HomeLandProvider.DoParse_Sprite3D(xmlRoot,nodeName)
	local rootNode;
	local sprite3D;
	for rootNode in commonlib.XPath.eachNode(xmlRoot, nodeName) do
		if(rootNode) then
			local child;
			for child in rootNode:next() do
				if(child)then
					sprite3D = Map3DSystem.App.HomeLand.HomeLandNodeParser.create(child);
				end
				break;		
			end	
		end
		break;	
	end	
	return sprite3D;	
end