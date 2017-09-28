# Domoticz_LogoControl
Lua script to control Siemens Logo oba7/oba8

-- LogoControl script v1.0.1 by DewGew --

A dzVents script to control and monitor Siemens Logo PLC 0Ba7 or OBa8 using 
LogoControl by frickelzeugs as a bridge between domoticz and PLC.
Download LogoControl and manual: http://www.frickelzeugs.de/
	
Control Domoticz devices thrue LogoControl I use shell script within LogoControl.
./home/pi/LogoControl/Scripts/yourscriptfile.sh
Switch Device 123 on or off:

	#!/bin/bash
	ip=127.0.0.1 #Domoticz ipadress
	port=8080	#Domoticz port
	switchidx=123
	curl "http://$ip:$port/json.htm?type=command&param=switchlight&idx=$switchidx&switchcmd=On"
	or
	curl "http://$ip:$port/json.htm?type=command&param=switchlight&idx=$switchidx&switchcmd=Off"
	 
then add 'trigger' in your LogoControl config file, example on PLC output Q1 (device 1 in LogoControl):
	
	<device id="1" name="Bedroom Light" type="light">
		<attribute id="1" name="Status" plc="myLogo" address="Q1" valueTextConverter="on_off" />
		<method id="1" name="on" plc="myLogo" address="Q1" script="Q1_on.sh" />
		<trigger plc="myLogo" address="150.0" datatype="bit">
        	<onValue value="1" method="1" />
   		</trigger>														  
		<method id="2" name="off" plc="myLogo" address="Q1" script="Q1_off.sh" />
		<trigger plc="myLogo" address="150.1" datatype="bit">
    		<onValue value="2" method="2" />
   		</trigger>	
	</device>
