cmake_minimum_required(VERSION 3.16)

project(Telemetry2 VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.2 REQUIRED COMPONENTS Quick)
find_package(Qt6 5.15 REQUIRED COMPONENTS Location)
find_package(Qt6 REQUIRED COMPONENTS Positioning)
find_package(Qt6 REQUIRED COMPONENTS Charts)
find_package(Qt6 REQUIRED COMPONENTS SerialPort)
find_package(Qt6 REQUIRED COMPONENTS Core Gui DataVisualization)

qt_add_executable(appTelemetry2
    main.cpp
)

qt_add_qml_module(appTelemetry2
    URI Telemetry2
    VERSION 1.0
    QML_FILES Main.qml
    RESOURCES Resources.qrc
    RESOURCES TopPanel.qml
    RESOURCES MiddleLayout.qml
    RESOURCES MidPanel1.qml
    RESOURCES GaugePanel.qml
    RESOURCES PlotPanel.qml
    RESOURCES RT_Chart.qml
    RESOURCES SideMenu.qml
    RESOURCES RotationPanel.qml
    RESOURCES MapHandler.qml
    RESOURCES MapPanel.qml
    RESOURCES BottomPanel.qml
    RESOURCES RadialBarShape.qml
    RESOURCES GridRectAux.qml
    RESOURCES ConfigurePage.qml
    RESOURCES SerialConfigPage.qml
    RESOURCES SettingConfig.qml
    RESOURCES OtherSettings.qml

    RESOURCES mainAuxFunctions.js

    SOURCES Headers/radialbar.h
    SOURCES radialbar.cpp
    SOURCES Headers/SerialHandler.h
    SOURCES SerialHandler.cpp
    SOURCES Headers/CsvHandler.hpp
    SOURCES CsvHandler.cpp

    RESOURCES Gubi.png
    RESOURCES Thermometer.png 
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appTelemetry2 PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appTelemetry2
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appTelemetry2
    PRIVATE Qt6::Quick
    Qt6::Location
    Qt6::Positioning
    Qt6::Charts
    Qt6::SerialPort
)

include(GNUInstallDirs)
install(TARGETS appTelemetry2
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
