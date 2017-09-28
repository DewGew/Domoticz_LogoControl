--[[ 
	-- LogoControl script v1.0.1 --
	        by DewGew
	
	A dzVents script to control and monitor Siemens Logo PLC 0Ba7 or OBa8 using 
	LogoControl by frickelzeugs as a bridge between domoticz and PLC.
	Download LogoControl and manual: http://www.frickelzeugs.de/
	
	Control Domoticz devices thrue LogoControl I use shell script within LogoControl.
	./home/pi/LogoControl/Scripts/yourscriptfile.sh

	Switch Device 123 on or off:

	#!/bin/bash
	ip=127.0.0.1 	#Domoticz ipaddress
	port=8080	#Domoticz port
	switchidx=123
	curl "http://$ip:$port/json.htm?type=command&param=switchlight&idx=$switchidx&switchcmd=On"
	or
	curl "http://$ip:$port/json.htm?type=command&param=switchlight&idx=$switchidx&switchcmd=Off"
	 
	then add 'trigger' in your LogoControl config file, example on PLC output Q1 (device 1 in LogoControl):
	
	<device id="1" name="Bedroom Light" type="light">
	<attribute id="1" name="Status" plc="myLogo" address="Q1" valueTextConverter="on_off" />
	<method id="1" name="on" plc="myLogo" address="150.0" script="Q1_on.sh" />
	<trigger plc="myLogo" address="Q1" datatype="bit">
    		<onValue value="1" method="1" />
	</trigger>														  
	<method id="2" name="off" plc="myLogo" address="150.1" script="Q1_off.sh" />
	<trigger plc="myLogo" address="Q1" datatype="bit">
			<onValue value="0" method="2" />
	</trigger>	
</device>
		
	Framework: dzVents 2.2.0
	Datum: 2017-09-18
]]
return {

	active = true,

	on = {
	    devices = {
	        'Q1',	-- Add domoticz devices that will trigger the script
	        'Q2',
		--'Q3'	-- etc
	   }
	},
	logging = {
	-- level = domoticz.LOG_DEBUG,
	marker = "LogoControl script" -- prefix added to every log message
	},

	execute = function(domoticz, device)
		local logoControlIP = "127.0.0.1"	-- LogoControl Ipadress
		local logoControlport = "8088"		-- LogoControl Port
		local logoControlDeviceNr = ""
		local logoControlDeviceAttrNr = ""
	 
	    	if device.name == "Q1" then logoControlDeviceNr = 1 end		-- pair domoticz device with LogoControl device
	    	if device.name == "Q1" then logoControlDeviceAttrNr = 1 end	-- pair domoticz device with LogoControl device Attribute eg. table at http://logocontrol:8088/rest/attributes (on/off status or value)
	   	if device.name == "Q2" then logoControlDeviceNr = 5 end
	    	if device.name == "Q2" then logoControlDeviceAttrNr = 6 end
      		-- if device.name =="Q3" then logoControlDeviceNr = 3 end	   -- etc.
	    	-- if device.name =="Q3" then logoControlDeviceAttrNr = 3 end

	    	json = (loadfile "/home/pi/domoticz/scripts/lua/JSON.lua")()
      		local file=assert(io.popen('curl http://' .. logoControlIP ..':' .. logoControlport .. '/rest/attributes'))
      		local raw = file:read('*all')
     		file:close()   
      		local logoControlAttributes = json:decode(raw)
     		local logoOutputDevice = logoControlAttributes.attributeUpdates[logoControlDeviceAttrNr].D
     		local logoOutput = logoControlAttributes.attributeUpdates[logoControlDeviceAttrNr].V
      		local logoOutputText = logoControlAttributes.attributeUpdates[logoControlDeviceAttrNr].T
      
      		domoticz.log('Checking status -- Device ' .. logoOutputDevice .. ' status  is ' .. logoOutput .. ' (' .. logoOutputText .. ')', domoticz.LOG_INFO)
        
        	if device.state == 'On' and logoOutput == 0 then
            		domoticz.openURL('http://' .. logoControlIP .. ':' .. logoControlport .. '/rest/devices/' .. logoControlDeviceNr .. '/methods/1')
		    	domoticz.log('Switching on domoticz device ' .. device.name .. ' and LogoControl device ' .. logoControlDeviceNr,domoticz.LOG_INFO)
      
        	elseif device.state == 'Off' and logoOutput == 1 then
            		domoticz.openURL('http://' .. logoControlIP .. ':' .. logoControlport .. '/rest/devices/' .. logoControlDeviceNr .. '/methods/2')
		    	domoticz.log('Switching off domoticz device ' .. device.name .. ' and LogoControl device ' .. logoControlDeviceNr,domoticz.LOG_INFO)
	    	end
    	end
}
