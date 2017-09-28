--[[ 
	-- LogoControl temp script v1.0.0 --
	        by DewGew
	
	dzVents script to control and monitor Siemens Logo PLC 0Ba7 or OBa8 using 
	LogoControl by frickelzeugs as a bridge between domoticz and PLC.
	LogoControl download and manual: http://www.frickelzeugs.de/
	
	This script is updating a virtual temp device e.g domoticz.devices('Temp Logo')
	
	Framework: dzVents 2.2.0
	Datum: 2017-09-18
]]
return {

	active = true,

	on = {
	    timer = {
	        'every 30 minutes'
	   }
	},
	
	execute = function(domoticz)
  
    local logoControlIP = "127.0.0.1"	-- LogoControl Ipadress
    local logoControlport = "8088"		-- LogoControl Port
		local tempDevice = domoticz.devices('Temp Logo')
		local logoControlDeviceNr = 4
    local logoControlDeviceAttrNr = "5"
    
    json = (loadfile "/home/pi/domoticz/scripts/lua/JSON.lua")()
		local file=assert(io.popen('curl http://' .. logoControlIP ..':' .. logoControlport .. '/rest/attributes'))
		local raw = file:read('*all')
		file:close()
    local logoControlAttributes = json:decode(raw)
		local logoOutputDevice = logoControlAttributes.attributeUpdates[logoControlDeviceAttrNr].D
		local logoOutput = logoControlAttributes.attributeUpdates[logoControlDeviceAttrNr].V
				
		domoticz.log('Checking status -- Device ' .. logoOutputDevice .. ' value is ' .. logoOutput, domoticz.LOG_INFO)
    tempDevice.updateTemperature(logoOutput)
        
    end
}
