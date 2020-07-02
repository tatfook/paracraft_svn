# Author: LiXizhi
# Company: ParaEngine
# Date: 2011.6.9
# Desc: this requires Aries_RedistParaEngineClient.nsi
# We will add all files to the temp/cache_15MB folder
# We will add all files to the temp/cache_200MB folder


!define OutputFileName	"Release/HaqiInstallerV1003Cache15mb.exe"

##-----------------------------------------
## where we shall include the cache folder, but excluding any files with extension
##-----------------------------------------
!define CacheFolderPath	"temp/cache_15MB"

!include Aries_RedistParaEngineClient.nsi
