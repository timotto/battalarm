# Battery Alarm

A device to alert you in case you forget to plug in the starter-battery charger into your vehicle.

## Why

Usually a vehicle's starter battery is charged when the engine is running. 
But some utility vehicles contain many on-board electronics and accessory chargers,
draining the starter-battery when the vehicle sits idle for some time. 
In some cases just a weekend is enough.

## How does it work

Battery Alarm consists of two devices:
1. the alarm adapter to be plugged into the vehicle's cigarette lighter port  
2. a radio beacon to mount in the garage

The alarm adapter monitors the vehicle's starter-battery voltage. 
It will sound an audible alarm when the vehicle is close to the garage radio beacon, 
the starter-battery's voltage is below charging level, and some time has passed.

## How is it made

The firmware is written using Arduino and targets the ESP32 controller.

The alarm adapter has a small custom PCB to connect a voltage divider, a 5V power supply, and a buzzer to the ESP32.

The radio beacon is just a plain ESP32 board with no additional electronics but a wall plug to provide power.
