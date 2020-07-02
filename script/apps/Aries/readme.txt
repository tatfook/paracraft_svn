---+ Aries for Haqi
The aries project is a kids mmo project started on 2009.3. On 2011.3, we decided to derive two concurrent versions 
with two different UI systems but almost identical backend logics to different audiences. 
- The Kids version is for the kids ranging from 7-14 years old
- The Tean version is a general version for people of all ages, yet always with the tean users in mind. 
It is a chanllenge to keep two versions of the same product in the same script/apps/aries folder. 
We even allow the user to switch versions within the game. 

command line params
| version | "" pops a dialog for version selection, "kids" force kids version, "tean" force tean version |
| visit_url | "nid@slot_id" |

---++ kids and teen version Programming Guide
Both versions shares 99% code with each other. The entry point configuration files differs, but the second level configuration files may be shared. 
This section provides the guideline of how to program the two together. 
---+++ UI guideline
The basic ideas is to share same folder unless absolutely necessary to create a tean version folder. 
---++++ Texture path
| shared UI theme texture | Texture/Aries/Common/ThemeTean/*.* |
| large file categories can create a sub folder | e.g. Texture/Aries/Desktop/ThemeTean/*.* |
| small file categories can mix in the same folder | e.g. Texture/Aries/Desktop/CameraMode/*.*(Both Kids and Tean versions are here) |
---++++ 3D path
| main character | character/v3/Elftean/*.* |
| all other files can share same folder | e.g. character/v5/ |
| terrain files can share same folder with sub folders| e.g. Texture/tileset/generic/ |

---+++ Runtime code switch
The runtime variable "System.options.isKid" is set when game start or maybe set shorted after game start(the user toggles game version).
The user interface API should also change thereafterwards. 
System.options.version contains either "teen" or "kids" depending on the usage
<verbatim>
	if(System.options.isKid) then
		-- kids version
	else
		-- tean version
	end
</verbatim>
---++++ When Performance Count!
for code that may be call over one hundard times per second, we can pre-cache the value in a local variable in the file scope. 
However, it loses the property of being dynamically adjust versions at runtime. So use it spareingly at right place(such as network framemove update code, etc).
<verbatim>
	local isKid = System.options.isKid
	if(isKid) then
		-- kids version
	else
		-- tean version
	end
</verbatim>

---++++ Helper functions
Sometimes, all we need is to display a different mcml page of the same size. so we can use a if_else function. 
<verbatim>
local url = if_else(System.options.isKid, "mcml_page.html", "mcml_page.tean.html")
</verbatim>

---++++ MCML Pages
In most cases, we will either use the same mcml page without changes or we will create a separate side-by-side mcml page, such as:
"mcml_page_url.mcml(lua)" is the original kids version, and "mcml_page_url.tean.mcml(lua)" is the tean version. 
However, in some rare, we may share the same mcml page file with slightly different logics. 
<verbatim>
	<pe:if condition='<%=System.options.isKid%>'>
		kids version
	</pe:if>
	<pe:if condition='<%=not System.options.isKid%>'>
		tean version
	</pe:if>
</verbatim>

---+++ Special Module Implementation
Some module deserves special attention. 

---++++ Desktop UI 

---++++ Main Player View Sync

---++++ Server Side Config

---++++ Quest System


---++ Introduction


---++ Client Log files 
May be used to analize user behavior

