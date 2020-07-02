--[[
Title: mimetypes
Author: LiXizhi
Date: 2015/6/12
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/WebServer/mimetypes.lua");
local mimetypes = commonlib.gettable("WebServer.mimetypes");
mimetypes:guess_type("*.html");
-----------------------------------------------
]]

local mimetypes = commonlib.gettable("WebServer.mimetypes");

mimetypes.types_map = {
	["html"] = "text/html",
	["htm"] = "text/html",
	["page"] = "text/html",
	["npl"] = "text/html",
	["lua"] = "text/html",
	["css"] = "text/css",
	["js"] = "application/javascript",
	["woff"] = "application/octet-stream",
	["woff2"] = "application/octet-stream",
	["ttf"] = "application/octet-stream",
	["stl"] = "application/octet-stream",
	shtml = 'text/html',
	css = 'text/css',
	xml = 'text/xml',
	gif = 'image/gif',
	jpeg = 'image/jpeg',
	jpg = 'image/jpeg',
	-- js = 'application/x-javascript',
	json = 'application/json',
	atom = 'application/atom+xml',
	rss = 'application/rss+xml',
	mml = 'text/mathml',
	txt = 'text/plain',
	jad = 'text/vnd.sun.j2me.app-descriptor',
    wml = 'text/vnd.wap.wml',
    htc = 'text/x-component',
    png = 'image/png',
    tif = 'image/tiff',
	tiff = 'image/tiff',
	wbmp = 'image/vnd.wap.wbmp',
    ico = 'image/x-icon',
    jng = 'image/x-jng',
    bmp = 'image/x-ms-bmp',
    svg = 'image/svg+xml',
	svgz = 'image/svg+xml',
    webp = 'image/webp',
    jar = 'application/java-archive',
	war = 'application/java-archive',
	ear = 'application/java-archive',
    hqx = 'application/mac-binhex40',
	doc = 'application/msword',
	pdf = 'application/pdf',
    ps = 'application/postscript',
	eps = 'application/postscript',
	ai = 'application/postscript',
    rtf = 'application/rtf',
    xls = 'application/vnd.ms-excel',
	ppt = 'application/vnd.ms-powerpoint',
    wmlc = 'application/vnd.wap.wmlc',
    kml = 'application/vnd.google-earth.kml+xml',
    kmz = 'application/vnd.google-earth.kmz',
    ['7z'] = 'application/x-7z-compressed',
    cco = 'application/x-cocoa',
    jardiff = 'application/x-java-archive-diff',
    jnlp = 'application/x-java-jnlp-file',
    run = 'application/x-makeself',
	pl = 'application/x-perl',
	pm = 'application/x-perl',
    prc = 'application/x-pilot',
	pdb = 'application/x-pilot',
    rar = 'application/x-rar-compressed',
    rpm = 'application/x-redhat-package-manager',
	xea = 'application/x-sea',
    swf = 'application/x-shockwave-flash',
    sit = 'application/x-stuffit',
    tcl = 'application/x-tcl',
	tk = 'application/x-tcl',
	der = 'application/x-x509-ca-cert',
	pem = 'application/x-x509-ca-cert',
	crt = 'application/x-x509-ca-cert',
	xpi = 'application/x-xpinstall',
    xhtml = 'application/xhtml+xml',
    zip = 'application/zip',
    bin = 'application/octet-stream',
	exe = 'application/octet-stream',
	dll = 'application/octet-stream',
	deb = 'application/octet-stream',
	dmg = 'application/octet-stream',
    eot = 'application/octet-stream',
	iso = 'application/octet-stream',
	img = 'application/octet-stream',
    msi = 'application/octet-stream',
	msp = 'application/octet-stream',
	msm = 'application/octet-stream',
    mid = 'audio/midi',
	midi = 'audio/midi',
	kar = 'audio/midi',
	mp3 = 'audio/mpeg',
    ogg = 'audio/ogg',
    m4a = 'audio/x-m4a',
    ra = 'audio/x-realaudio',
    ['3gpp'] = 'video/3gpp',
	['3gp'] = 'video/3gpp',
	mp4 = 'video/mp4',
    mpeg = 'video/mpeg',
	mpg = 'video/mpeg',
    mov = 'video/quicktime',
    webm = 'video/webm',
    flv = 'video/x-flv',
    m4v = 'video/x-m4v',
	mng = 'video/x-mng',
    asx = 'video/x-ms-asf',
	asf = 'video/x-ms-asf',
	wmv = 'video/x-ms-wmv',
    avi = 'video/x-msvideo'
};

-- set mime type for a given file
-- @param value: if nil, it will remove the type
function mimetypes:set_type(name, value)
	self.types_map[name] = value;
end

-- gets the mimetype from the filename's extension
-- @param path: filepath 
function mimetypes:guess_type(path, bStrict)
	local extension = string.match (path, "%.([^.]*)$")
	if extension then
		return self.types_map[extension];
	else
		return nil
	end
end
