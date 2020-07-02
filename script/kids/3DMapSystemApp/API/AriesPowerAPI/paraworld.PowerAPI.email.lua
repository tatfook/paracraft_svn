--[[
Title: power api payment
Author(s): YAN DONGODNG
Date: 2013/4/10
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/AriesPowerAPI/paraworld.PowerAPI.email.lua");
-------------------------------------------------------
]]

-- create class
local email = commonlib.gettable("paraworld.PowerAPI.email"); 

-- here is a sample of creating payment API
--[[
/// <summary>
/// �����ʼ����Ǵ�ͳ������Email��ָ��Ϸ�ڲ����ʼ���
/// ���ղ�����
///		nid     0  ϵͳ����
///		_nid	0  ϵͳ����
///     tonid �����˵�NID
///     title ����
///     content ����
///     attaches ������guid,cnt|guid,cnt|guid,cnt|.....��guid==0:E�ң�guid==-1:P��
/// ����ֵ��
///     issuccess
///     [ errorcode ] 493:��������ȷ 419:�û������� 427:��Ʒ���� 426:̫Ƶ�� 433:��������
/// </summary>
]]
paraworld.createPowerAPI("paraworld.PowerAPI.email.Send", "Email.Send",
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	
	LOG.std(nil, "debug","PowerAPI", "paraworld.PowerAPI.email.send msg_in:");
	LOG.std(nil, "debug","PowerAPI", msg);
	
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg, originalMsg)
	LOG.std(nil, "debug","PowerAPI", "paraworld.PowerAPI.email.send return")
	LOG.std(nil, "debug","PowerAPI", msg);
end);
