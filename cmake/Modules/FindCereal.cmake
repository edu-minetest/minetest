# Look for Cereal, with fallback to bundeled version

mark_as_advanced(CEREAL_INCLUDE_DIR)
option(ENABLE_SYSTEM_CEREAL "Enable using a system-wide Cereal" TRUE)
set(USE_SYSTEM_CEREAL FALSE)

if(ENABLE_SYSTEM_CEREAL)
  find_path(CEREAL_INCLUDE_DIR "cereal.hpp"
    PATH_SUFFIXES cereal
    HINTS
      "${CEREAL_LOCATION}/include"
      "$ENV{CEREAL_LOCATION}/include"
    PATHS
      /usr/local/include/
      /usr/include/
      /opt/local/include/
      /sw/include/
      "$ENV{PROGRAMFILES}/cereal/include"
      "$ENV{PROGRAMFILES}/CEREAL/include"
    DOC
      "The directory where headers files of Cereal resides"
  )

  if(CEREAL_INCLUDE_DIR)
    message(STATUS "Using Cereal provided by system.")
    set(USE_SYSTEM_CEREAL TRUE)
  endif()
endif()

if(NOT USE_SYSTEM_CEREAL)
  set(CEREAL_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/lib/cereal/include")
  message(STATUS "Using bundled Cereal library.")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CEREAL DEFAULT_MSG CEREAL_INCLUDE_DIR)
if(WIN32)
  # must add this when cross-compile
  include_directories("${CEREAL_INCLUDE_DIR}")
endif()
