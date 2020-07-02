# Author: LiXizhi
# Company: ParaEngine
# Date: 2011.6.9
# Desc: this requires Aries_haqi_teen.nsi
# We will add all files to the temp/cache_teen_40MB folder

!define OutputFileName  "Release/Haqi2CacheSmall.exe"

##-----------------------------------------
## where we shall include the cache folder, but excluding any files with extension
##-----------------------------------------
!define CacheFolderPath	"temp/cache_teen_40MB"

!include Aries_haqi_teen.nsi
