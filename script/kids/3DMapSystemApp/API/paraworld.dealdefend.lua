--[[
Title:
Author(s): Leio
Date: 2012/3/26
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/API/paraworld.dealdefend.lua");
local dealdefend = commonlib.gettable("paraworld.dealdefend");
-------------------------------------------------------
]]
local dealdefend = commonlib.gettable("paraworld.dealdefend");
--[[
/// <summary>
/// �������ð�ȫ����
/// ���ղ�����
///     sessionkey
/// ����ֵ��
///     issuccess
///     [ errorcode ] 403:��ȫ����Ĵ𰸲���ȷ��493:��������ȷ��419:�û�������
/// </summary>

--]]
paraworld.create_wrapper("paraworld.dealdefend.ApplyResetSecPass", "%MAIN%/API/Users/ApplyResetSecPass");
--[[
/// <summary>
/// ���ָ���û��İ�ȫ�����Ƿ���ͨ����֤
/// ���ղ�����
///     sessionkey
/// ����ֵ��
///     issuccess
/// </summary>

--]]
paraworld.create_wrapper("paraworld.dealdefend.CheckSecPass", "%MAIN%/API/Users/CheckSecPass");
--[[
/// <summary>
/// �޸İ�ȫ����
/// ���ղ�����
///     sessionkey
///     oldsecpass �ɰ�ȫ����
///     newsecpass �°�ȫ����
///     newsecpasspt �°�ȫ�������ʾ��Ϣ
/// ����ֵ��
///     issuccess
///     [ errorcode ] 419:�û������ڣ�493:��������420:�ṩ�ľ����벻��ȷ
/// </summary>

--]]
paraworld.create_wrapper("paraworld.dealdefend.ChgSecPass", "%MAIN%/API/Users/ChgSecPass");
--[[
/// <summary>
/// ���ð�ȫ����
/// ���ղ�����
///     sessionkey
///     logonpass ��¼����
///     secapt ��ȫ����𰸵���ʾ��Ϣ ������ȫ�������ʾ��Ϣ
///     secpass ��ȫ����
///     [ from ] = number �Ǵ��ĸ�ƽ̨�������û���0:TM 1:���档Ĭ��Ϊ��
/// ����ֵ��
///     issuccess
///     [ errorcode ] 419:�û������ڣ�417:�����ù��ˣ�493:��������407:��¼���벻��ȷ
/// </summary>

--]]
paraworld.create_wrapper("paraworld.dealdefend.SetSecPass", "%MAIN%/API/Users/SetSecPass.ashx",
-- PreProcessor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator)
	LOG.std(nil, "debug", "SetSecPass.begin", msg);
end,
-- Post Processor
function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator, raw_msg, inputMsg)
	LOG.std(nil, "debug", "SetSecPass.result", msg);
end
);

--[[
/// <summary>
/// ��֤��ȫ����
/// ���ղ�����
///     sessionkey
///     secpass ��ȫ����
/// ����ֵ��
///     issuccess
///     [ errorcode ] 419:�û������ڣ�493:��������420:��ȫ���벻��ȷ
/// </summary>

--]]
paraworld.create_wrapper("paraworld.dealdefend.VerifySecPass", "%MAIN%/API/Users/VerifySecPass");
--[[
/// <summary>
/// ȡ��ָ���û��Ķ���������ʾ��Ϣ
/// ���ղ�����
///     sessionkey
/// ����ֵ��
///     secpasspt �û��Ķ���������ʾ��Ϣ
///     [ errorcode ] 493:�������� 419:�û�������
/// </summary>

--]]
paraworld.create_wrapper("paraworld.dealdefend.GetSecPassPt", "%MAIN%/API/Users/GetSecPassPt");