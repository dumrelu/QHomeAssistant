cmake_minimum_required(VERSION 3.14)

project(QHomeAssistant VERSION 0.1 LANGUAGES CXX)

# CMake options
option(BUILD_EXAMPLE_PROJECT "Build example project" ON)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Quick Svg)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Quick Svg)

add_library(QHomeAssistant STATIC
    qml/qhomeassistant.qrc

    include/QHomeAssistantPlugin.h src/QHomeAssistantPlugin.cpp
    include/homeassistantimageprovider.h src/homeassistantimageprovider.cpp
    include/homeassistantapi.h src/homeassistantapi.cpp
    include/homeassistantimpl.h src/homeassistantimpl.cpp
)

# Enable all warnings
if(MSVC)
  target_compile_options(QHomeAssistant PRIVATE /W4 /WX)
else()
  target_compile_options(QHomeAssistant PRIVATE -Wall -Wextra -Wpedantic -Werror)
endif()

if(BUILD_EXAMPLE_PROJECT)
    add_subdirectory(ExampleProject)
endif()

target_include_directories(QHomeAssistant PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
target_link_libraries(QHomeAssistant
  PRIVATE 
    Qt${QT_VERSION_MAJOR}::Core Qt${QT_VERSION_MAJOR}::Quick Qt${QT_VERSION_MAJOR}::Svg
)
