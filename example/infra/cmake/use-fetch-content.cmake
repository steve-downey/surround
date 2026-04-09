cmake_minimum_required(VERSION 3.24)

include(FetchContent)

if(NOT BEMAN_USE_FETCH_CONTENT_LOCKFILE)
    set(BEMAN_USE_FETCH_CONTENT_LOCKFILE
        "lockfile.json"
        CACHE FILEPATH
        "Path to the dependency lockfile for the Beman Exemplar."
    )
endif()

set(BemanUseFetchContent_projectDir "${CMAKE_CURRENT_LIST_DIR}/../..")
message(TRACE "BemanUseFetchContent_projectDir=\"${BemanUseFetchContent_projectDir}\"")

message(TRACE "BEMAN_USE_FETCH_CONTENT_LOCKFILE=\"${BEMAN_USE_FETCH_CONTENT_LOCKFILE}\"")
file(
    REAL_PATH "${BEMAN_USE_FETCH_CONTENT_LOCKFILE}"
    BemanUseFetchContent_lockfile
    BASE_DIRECTORY "${BemanUseFetchContent_projectDir}"
    EXPAND_TILDE
)
message(DEBUG "Using lockfile: \"${BemanUseFetchContent_lockfile}\"")

# Force CMake to reconfigure the project if the lockfile changes
set_property(
    DIRECTORY "${BemanUseFetchContent_projectDir}"
    APPEND
    PROPERTY CMAKE_CONFIGURE_DEPENDS "${BemanUseFetchContent_lockfile}"
)

# For more on the protocol for this function, see:
# https://cmake.org/cmake/help/latest/command/cmake_language.html#provider-commands
function(BemanUseFetchContent_provideDependency method package_name)
    # Read the lockfile
    file(READ "${BemanUseFetchContent_lockfile}" BemanUseFetchContent_rootObj)

    # Get the "dependencies" field and store it in BemanUseFetchContent_dependenciesObj
    string(
        JSON BemanUseFetchContent_dependenciesObj
        ERROR_VARIABLE BemanUseFetchContent_error
        GET "${BemanUseFetchContent_rootObj}"
        "dependencies"
    )
    if(BemanUseFetchContent_error)
        message(FATAL_ERROR "${BemanUseFetchContent_lockfile}: ${BemanUseFetchContent_error}")
    endif()

    # Get the length of the libraries array and store it in BemanUseFetchContent_dependenciesObj
    string(
        JSON BemanUseFetchContent_numDependencies
        ERROR_VARIABLE BemanUseFetchContent_error
        LENGTH "${BemanUseFetchContent_dependenciesObj}"
    )
    if(BemanUseFetchContent_error)
        message(FATAL_ERROR "${BemanUseFetchContent_lockfile}: ${BemanUseFetchContent_error}")
    endif()

    if(BemanUseFetchContent_numDependencies EQUAL 0)
        return()
    endif()

    # Loop over each dependency object
    math(EXPR BemanUseFetchContent_maxIndex "${BemanUseFetchContent_numDependencies} - 1")
    foreach(BemanUseFetchContent_index RANGE "${BemanUseFetchContent_maxIndex}")
        set(BemanUseFetchContent_errorPrefix
            "${BemanUseFetchContent_lockfile}, dependency ${BemanUseFetchContent_index}"
        )

        # Get the dependency object at BemanUseFetchContent_index
        # and store it in BemanUseFetchContent_depObj
        string(
            JSON BemanUseFetchContent_depObj
            ERROR_VARIABLE BemanUseFetchContent_error
            GET "${BemanUseFetchContent_dependenciesObj}"
            "${BemanUseFetchContent_index}"
        )
        if(BemanUseFetchContent_error)
            message(
                FATAL_ERROR
                "${BemanUseFetchContent_errorPrefix}: ${BemanUseFetchContent_error}"
            )
        endif()

        # Get the "name" field and store it in BemanUseFetchContent_name
        string(
            JSON BemanUseFetchContent_name
            ERROR_VARIABLE BemanUseFetchContent_error
            GET "${BemanUseFetchContent_depObj}"
            "name"
        )
        if(BemanUseFetchContent_error)
            message(
                FATAL_ERROR
                "${BemanUseFetchContent_errorPrefix}: ${BemanUseFetchContent_error}"
            )
        endif()

        # Get the "package_name" field and store it in BemanUseFetchContent_pkgName
        string(
            JSON BemanUseFetchContent_pkgName
            ERROR_VARIABLE BemanUseFetchContent_error
            GET "${BemanUseFetchContent_depObj}"
            "package_name"
        )
        if(BemanUseFetchContent_error)
            message(
                FATAL_ERROR
                "${BemanUseFetchContent_errorPrefix}: ${BemanUseFetchContent_error}"
            )
        endif()

        # Get the "git_repository" field and store it in BemanUseFetchContent_repo
        string(
            JSON BemanUseFetchContent_repo
            ERROR_VARIABLE BemanUseFetchContent_error
            GET "${BemanUseFetchContent_depObj}"
            "git_repository"
        )
        if(BemanUseFetchContent_error)
            message(
                FATAL_ERROR
                "${BemanUseFetchContent_errorPrefix}: ${BemanUseFetchContent_error}"
            )
        endif()

        # Get the "git_tag" field and store it in BemanUseFetchContent_tag
        string(
            JSON BemanUseFetchContent_tag
            ERROR_VARIABLE BemanUseFetchContent_error
            GET "${BemanUseFetchContent_depObj}"
            "git_tag"
        )
        if(BemanUseFetchContent_error)
            message(
                FATAL_ERROR
                "${BemanUseFetchContent_errorPrefix}: ${BemanUseFetchContent_error}"
            )
        endif()

        if(method STREQUAL "FIND_PACKAGE")
            if(package_name STREQUAL BemanUseFetchContent_pkgName)
                string(
                    APPEND BemanUseFetchContent_debug
                    "Redirecting find_package calls for ${BemanUseFetchContent_pkgName} "
                    "to FetchContent logic.\n"
                )
                string(
                    APPEND BemanUseFetchContent_debug
                    "Fetching ${BemanUseFetchContent_repo} at "
                    "${BemanUseFetchContent_tag} according to ${BemanUseFetchContent_lockfile}."
                )
                message(DEBUG "${BemanUseFetchContent_debug}")
                FetchContent_Declare(
                    "${BemanUseFetchContent_name}"
                    GIT_REPOSITORY "${BemanUseFetchContent_repo}"
                    GIT_TAG "${BemanUseFetchContent_tag}"
                    EXCLUDE_FROM_ALL
                )
                set(INSTALL_GTEST OFF) # Disable GoogleTest installation
                FetchContent_MakeAvailable("${BemanUseFetchContent_name}")

                # Catch2's CTest integration module isn't on CMAKE_MODULE_PATH
                # when brought in via FetchContent. Add it so that
                # `include(Catch)` works.
                if(BemanUseFetchContent_pkgName STREQUAL "Catch2")
                    list(
                        APPEND CMAKE_MODULE_PATH
                        "${${BemanUseFetchContent_name}_SOURCE_DIR}/extras"
                    )
                    set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" PARENT_SCOPE)
                endif()

                # Important! <PackageName>_FOUND tells CMake that `find_package` is
                # not needed for this package anymore
                set("${BemanUseFetchContent_pkgName}_FOUND" TRUE PARENT_SCOPE)
            endif()
        endif()
    endforeach()
endfunction()

cmake_language(
    SET_DEPENDENCY_PROVIDER BemanUseFetchContent_provideDependency
    SUPPORTED_METHODS FIND_PACKAGE
)

# Add this dir to the module path so that `find_package(beman-install-library)` works
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_LIST_DIR}")
