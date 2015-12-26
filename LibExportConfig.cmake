set(CURRENT_DIR ${CMAKE_CURRENT_LIST_DIR})

macro(lib_export_config _LIB)
	target_include_directories(${_LIB} PUBLIC ${CMAKE_CURRENT_BINARY_DIR})
	string(TOUPPER ${_LIB} _LIB)
	configure_file(${CURRENT_DIR}/LibExportConfig.h.in export_config.h)
endmacro()
