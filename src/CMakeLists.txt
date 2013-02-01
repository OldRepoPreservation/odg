
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake ${PROJECT_SOURCE_DIR}/cmake/vala)
find_package(Vala REQUIRED)
include("${VALA_USE_FILE}")
vala_add_library(odg SHARED
                 alarm.vala control_if.vala gauge.vala
                 gauge_control.vala gauge_factory.vala resources.vala
                 message_source.vala
                 round_meter.vala half_round_meter.vala numeric_meter.vala
                 LIBRARY odg
                 GENERATE_VAPI odg.vapi
                 COMPILE_FLAGS --target-glib=2.34
                 GENERATE_HEADER odg.h
                 PACKAGES gtk+-3.0 gio-2.0 json-glib-1.0
                 OUTPUT_DIR gen
                 LINK_WITH m)
