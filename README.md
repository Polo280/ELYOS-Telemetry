# ELYOS Telemetry GUI

This repository contains a Graphical User Interface built in **QT Quick** which allows to visualize, process and store data from a telemetry system of an electric vehicle running in **Shell Eco Marathon (SEM)**.

![Disconnected GUI](https://drive.google.com/uc?export=view&id=1YMaeUjbUg5M78gDKPuQDN8KgPO6znQfN)

## Requirements

In order to run this app, you must have **Qt6** locally installed.

To build, you need to create a **build** folder and run CMake configuration file `CMakeLists.txt` provided in this repository.

```bash
mkdir build
cd build
cmake ..
```

## Testing the App

To test data visualization and store, you must be connected to a base station or device via USB port of your computer. Use the **configure window** to set desired baud rate and serial port.

## Additional Notes

Before building, you must change the output path for generated CSV to an existing local path on your computer. This is configured in `Main.qml` at line 356.

```C++
CsvHandler.openCsv("C:/Users/jorgl/OneDrive/Escritorio/testqt.csv");
```
