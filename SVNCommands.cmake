# Subversion subcommands
# ----------------------
#

find_package(Subversion)

if(SUBVERSION_FOUND)
    set(SVN_BIN ${Subversion_SVN_EXECUTABLE})

	macro(svn_subcommand _COMMAND _OPTIONS)
		set(_SAVED_LC_ALL "$ENV{LC_ALL}")
		set(ENV{LC_ALL} C)
		
		execute_process(COMMAND ${SVN_BIN} "${_COMMAND} ${_OPTIONS}"
			OUTPUT_VARIABLE _OUTPUT
            RESULT_VARIABLE _RESULT
            OUTPUT_STRIP_TRAILING_WHITESPACE)
		
		if(NOT ${_RESULT} EQUAL 0)
            message(FATAL_ERROR "Command \"${SVN_BIN} ${_COMMAND} ${_OPTIONS}\" failed with output:\n${_OUTPUT}")
        endif()
		
		set(ENV{LC_ALL} ${_SAVED_LC_ALL})
	endmacro()

    macro(svn_resolve _DIR)
		svn_subcommand(resolve "${_DIR} -R --accept theirs-full")
        message(STATUS "Resolve \"${_DIR}\"")
    endmacro()

    macro(svn_revert _DIR)
		svn_subcommand(revert "${_DIR} -R")
		message(STATUS "Reverte \"${_DIR}\"")
    endmacro()

    macro(svn_cleanup _DIR)
        svn_subcommand(cleanup "${_DIR} --include-externals")
		#svn_subcommand(cleanup "${_DIR} --include-externals --remove-unversioned")
        message(STATUS "Cleanup \"${_DIR}\"")
    endmacro()

    macro(svn_update _DIR _REVISION)
		svn_subcommand(update "${_DIR} -r ${_REVISION} --force --accept theirs-full")
        message(STATUS "Update \"${_DIR}\"")
    endmacro()

    ## List all svn:externals recursively
	svn_subcommand(propget "svn:externals -R")
    string(REPLACE "\n" ";" EXTERNALS_LINES ${_OUTPUT})

	foreach(_LINE ${EXTERNALS_LINES})
        string(REGEX MATCH "[a-zA-Z0-9_/\\]+$" _EXTERNALS ${_LINE})
        list(APPEND ENTERNALS_LIST "client/Assets/${_EXTERNALS}")
    endforeach()

    ## Resolve working copy and external links
    foreach(_EXTERNALS ${ENTERNALS_LIST})
        svn_resolve(${_EXTERNALS})
    endforeach()
    svn_resolve(.)

    ## Revert working copy and external links
    foreach(_EXTERNALS ${ENTERNALS_LIST})
        svn_revert(${_EXTERNALS})
    endforeach()
    svn_revert(.)

    ## Cleanup working copy and external links
    foreach(_EXTERNALS ${ENTERNALS_LIST})
        svn_cleanup(${_EXTERNALS})
    endforeach()
    svn_cleanup(.)

    ## Update working copy and external links
    if (NOT REVISION)
        set(REVISION HEAD)
    endif()

    foreach(_EXTERNALS ${ENTERNALS_LIST})
        svn_update(${_EXTERNALS} ${REVISION})
    endforeach()
    svn_update(. ${REVISION})

    ## Cleanup working copy and external links
    foreach(_EXTERNALS ${ENTERNALS_LIST})
        svn_cleanup(${_EXTERNALS})
    endforeach()
    svn_cleanup(.)

    ## Test working copy and external links is ok?
    foreach(_EXTERNALS ${ENTERNALS_LIST})
        svn_status(${_EXTERNALS})
    endforeach()
    svn_status(.)
endif()
