⚠️ **Work in progress** ⚠️

# ESP Terra

Control your terrarium's temperature and light with an ESP32.
This software is powered by [ESPHome](https://github.com/esphome/esphome)

# Folder structure

- [**radiator**](./radiator/README.md) - 3D printable terrarium radiator
- **src** - ESPHome config files

## Safety notice

Use this software at your own risk. This project uses a 3D Printer's hotend to heat a terrarium. The hotend could catch something on fire or harm your pet. 

### Security measures

The following limits can be set inside [`config.yml`](./config.yaml) to make it a bit safer.

- `max_heading_time`(default: 15s): The maximum time the hotend can be switched on
- `max_temp`(default: 100°C): Maximum temperature of the hotend

If one of those limits is exceeded the software will go into a standby mode.

## Features

- Web interface
- Home Assistant Integration

## Components

- ESP32
- [IRFZ44N](https://www.infineon.com/dgdl/Infineon-IRFZ44N-DataSheet-v01_01-EN.pdf?fileId=5546d462533600a40153563b3a9f220d)
- 3D Printer Hotend

## TODO

- Add PID controller https://github.com/esphome/feature-requests/issues/1871

## Articles

- [High-Power Control: Arduino + N-Channel MOSFET](https://adam-meyer.com/arduino/N-Channel_MOSFET) <br /> by Adam meyer