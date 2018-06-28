# 
#
# FUNCTION: set_amrex_compilers
# 
# Set the compiler flags for target "amrex".
# This function requires target "amrex" to be already existent.
#
# Author: Michele Rosso
# Date  : June 26, 2018
#
# 
function ( set_amrex_compilers )

   # 
   # Check if target "amrex" has been defined before
   # calling this macro
   #
   if ( NOT TARGET amrex )
      message (FATAL_ERROR "Target 'amrex' must be defined before calling function 'set_amrex_compilers'" )
   endif ()

   #
   # Check wether the compiler ID has been defined
   # 
   if (  NOT (DEFINED CMAKE_Fortran_COMPILER_ID) OR
	 NOT (DEFINED CMAKE_C_COMPILER_ID) OR 
	 NOT (DEFINED CMAKE_CXX_COMPILER_ID) )
      message ( FATAL_ERROR "Compiler ID is UNDEFINED" )
   endif ()

   #
   # Check the same compiler suite is used for all languages
   # 
   
   if (  NOT (${CMAKE_C_COMPILER_ID} STREQUAL ${CMAKE_Fortran_COMPILER_ID}) OR
	 NOT (${CMAKE_C_COMPILER_ID} STREQUAL ${CMAKE_CXX_COMPILER_ID}) )
      message ( FATAL_ERROR "C compiler ID does not match Fortran/C++ compiler ID" )
   endif ()


   
   #
   # Set Fortran Flags
   # 
   if ( CMAKE_Fortran_FLAGS )
      target_compile_options ( amrex
	 PUBLIC
	 $<$<COMPILE_LANGUAGE:Fortran>:${CMAKE_Fortran_FLAGS}> )
   else () # Set defaults
      target_compile_options ( amrex
	 PUBLIC
	 # GNU Debug
	 $<$<CONFIG:Debug>:$<$<C_COMPILER_ID:GNU>:$<$<COMPILE_LANGUAGE:Fortran>:
	 -g -O0 -ggdb -fbounds-check -fbacktrace -Wuninitialized -Wunused -finit-real=snan -finit-integer=2147483647>>>
	 # GNU Release
	 $<$<CONFIG:Release>:$<$<C_COMPILER_ID:GNU>:$<$<COMPILE_LANGUAGE:Fortran>:
	 -O3>>>
	 # Intel Debug
	 $<$<CONFIG:Debug>:$<$<C_COMPILER_ID:Intel>:$<$<COMPILE_LANGUAGE:Fortran>:
	 -g -O0 -traceback -check bounds,uninit,pointers>>>
	 # Intel Release
	 $<$<CONFIG:Release>:$<$<C_COMPILER_ID:Intel>:$<$<COMPILE_LANGUAGE:Fortran>:
	 -O3 -ip -qopt-report=5 -qopt-report-phase=vec>>>
	 # Cray Debug
	 $<$<CONFIG:Debug>:$<$<C_COMPILER_ID:Cray>:$<$<COMPILE_LANGUAGE:Fortran>:
	 -g -O0 -e i >>>
	 # Cray Release 
	 $<$<CONFIG:Release>:$<$<C_COMPILER_ID:Cray>:$<$<COMPILE_LANGUAGE:Fortran>:
	 -O2>>>
	 # PGI Debug
	 $<$<CONFIG:Debug>:$<$<C_COMPILER_ID:PGI>:$<$<COMPILE_LANGUAGE:Fortran>:
	 -g -O0 -Mbounds -Mchkptr>>>
	 # PGI Release
	 $<$<CONFIG:Release>:$<$<C_COMPILER_ID:PGI>:$<$<COMPILE_LANGUAGE:Fortran>:
	 -gopt -fast>>>
	 )	  
   endif ()


   #
   # Set C++ Flags
   # 
   if ( CMAKE_CXX_FLAGS )
      target_compile_options ( amrex
	 PUBLIC
	 $<$<COMPILE_LANGUAGE:CXX>:${CMAKE_CXX_FLAGS}> )
   else () # Set defaults
      target_compile_options ( amrex
	 PUBLIC
	 # GNU Debug
	 $<$<CONFIG:Debug>:$<$<C_COMPILER_ID:GNU>:$<$<COMPILE_LANGUAGE:CXX>:
	 -g -O0 -fno-inline -ggdb -Wall -Wno-sign-compare>>>
	 # GNU Release
	 $<$<CONFIG:Release>:$<$<C_COMPILER_ID:GNU>:$<$<COMPILE_LANGUAGE:CXX>:
	 -O3>>>
	 # Intel Debug
	 $<$<CONFIG:Debug>:$<$<C_COMPILER_ID:Intel>:$<$<COMPILE_LANGUAGE:CXX>:
	 -g -O0 -traceback -Wcheck>>>
	 # Intel Release
	 $<$<CONFIG:Release>:$<$<C_COMPILER_ID:Intel>:$<$<COMPILE_LANGUAGE:CXX>:
	 -O3 -ip -qopt-report=5 -qopt-report-phase=vec>>>
	 # Cray Debug
	 $<$<CONFIG:Debug>:$<$<C_COMPILER_ID:Cray>:$<$<COMPILE_LANGUAGE:CXX>:
	 -g -O0>>>
	 # Cray Release 
	 $<$<CONFIG:Release>:$<$<C_COMPILER_ID:Cray>:$<$<COMPILE_LANGUAGE:CXX>:
	 -O2>>>
	 # PGI Debug
	 $<$<CONFIG:Debug>:$<$<C_COMPILER_ID:PGI>:$<$<COMPILE_LANGUAGE:CXX>:
	 -O0 -Mbounds>>>
	 # PGI Release
	 $<$<CONFIG:Release>:$<$<C_COMPILER_ID:PGI>:$<$<COMPILE_LANGUAGE:CXX>:
	 -gopt -fast>>>
	 )	  
   endif ()

   #
   # Floating-point exceptions flags only if enabled
   # (I think these flags could be added tp both Fortran and
   # c++ without differentiating by language)
   # 
   if (DEFINED ENABLE_FPE)
      if (ENABLE_FPE)
   	 target_compile_options ( amrex
   	    PUBLIC
	    # GNU
	    $<$<C_COMPILER_ID:GNU>:$<$<COMPILE_LANGUAGE:Fortran>:
	    -ffpe-trap=invalid,zero -ftrapv>>
	    $<$<C_COMPILER_ID:GNU>:$<$<COMPILE_LANGUAGE:CXX>:
	    -ftrapv>>
	    # Intel
	    $<$<C_COMPILER_ID:GNU>:$<$<COMPILE_LANGUAGE:Fortran>:
	    -fpe3>>
	    $<$<C_COMPILER_ID:GNU>:$<$<COMPILE_LANGUAGE:CXX>:
	    -fpe3>>
	    # Cray
	    $<$<C_COMPILER_ID:GNU>:$<$<COMPILE_LANGUAGE:Fortran>:
	    -K trap=fp>>
	    $<$<C_COMPILER_ID:GNU>:$<$<COMPILE_LANGUAGE:CXX>:
	    -K trap=fp>>
	    #  PGI
	    $<$<C_COMPILER_ID:GNU>:$<$<COMPILE_LANGUAGE:Fortran>:
	    -Ktrap=divz,inv>>
	    $<$<C_COMPILER_ID:GNU>:$<$<COMPILE_LANGUAGE:CXX>:
	    >> )
      endif ()
   else ()
      message (AUTHOR_WARNING "Variable ENABLE_FPE is not defined")
   endif ()

   # Until "cxx_std_11" and similar options are available (CMake >= 3.8 )
   # add c++11 support manually in order to have transitive property
   target_compile_options ( amrex PUBLIC
      $<$<C_COMPILER_ID:Cray>:$<$<COMPILE_LANGUAGE:CXX>:-h std=c++11>>
      $<$<C_COMPILER_ID:PGI>:$<$<COMPILE_LANGUAGE:CXX>:-std=c++11>>
      $<$<C_COMPILER_ID:GNU>:$<$<COMPILE_LANGUAGE:CXX>:-std=c++11>>
      $<$<C_COMPILER_ID:Intel>:$<$<COMPILE_LANGUAGE:CXX>:-std=c++11>> )
   
endfunction () 


# # 
# #
# # MACRO:  load_compiler_defaults
# # 
# # Set the following variables to the default compiler flags:
# #
# # AMREX_<lang>_FLAGS_<CMAKE_BUILD_TYPE>
# # AMREX_<lang>_FLAGS_FPE
# # 
# # where <lang> is either C or Fortran.
# #
# # The *_FPE flags enable floating point exceptions
# #
# # Author: Michele Rosso
# # Date  : June 26, 2018
# #
# # 
# macro ( load_compiler_defaults )

#    #
#    # Check wether the compiler ID has been defined
#    # 
#    if (  NOT (DEFINED CMAKE_Fortran_COMPILER_ID) OR
# 	 NOT (DEFINED CMAKE_C_COMPILER_ID) OR 
# 	 NOT (DEFINED CMAKE_CXX_COMPILER_ID) )
#       message ( FATAL_ERROR "Compiler ID is UNDEFINED" )
#    endif ()

#    #
#    # Check the same compiler suite is used for all languages
#    # 
   
#    if (  NOT (${CMAKE_C_COMPILER_ID} STREQUAL ${CMAKE_Fortran_COMPILER_ID}) OR
# 	 NOT (${CMAKE_C_COMPILER_ID} STREQUAL ${CMAKE_CXX_COMPILER_ID}) )
#       message ( FATAL_ERROR "C compiler ID does not match Fortran/C++ compiler ID" )
#    endif ()

   
#    #
#    # Load defaults
#    # 
#    if ( ${CMAKE_C_COMPILER_ID} STREQUAL "GNU")  ### GNU compiler ###
      
#       set ( AMREX_Fortran_FLAGS_Release -O3)
#       set ( AMREX_Fortran_FLAGS_Debug
# 	 -g -O0 -ggdb -fbounds-check -fbacktrace -Wuninitialized -Wunused -finit-real=snan -finit-integer=2147483647)
#       set ( AMREX_Fortran_FLAGS_FPE -ffpe-trap=invalid,zero -ftrapv)
      

#       set ( AMREX_CXX_FLAGS_Debug -g -O0 -fno-inline -ggdb -Wall -Wno-sign-compare)
#       set ( AMREX_CXX_FLAGS_Release -O3 )
#       set ( AMREX_CXX_FLAGS_FPE -ftrapv )
      
#    elseif ( ${CMAKE_C_COMPILER_ID} STREQUAL "Intel")  ### Intel compiler ###

#       set ( AMREX_Fortran_FLAGS_Debug -g -O0 -traceback -check bounds,uninit,pointers)
#       set ( AMREX_Fortran_FLAGS_Release -O3 -ip -qopt-report=5 -qopt-report-phase=vec)
#       set ( AMREX_Fortran_FLAGS_FPE -fpe3 )
      
#       set ( AMREX_CXX_FLAGS_Debug     -g -O0 -traceback -Wcheck)
#       set ( AMREX_CXX_FLAGS_Release   -O3 -ip -qopt-report=5 -qopt-report-phase=vec)
#       set ( AMREX_CXX_FLAGS_FPE -fpe3 )
      
#    elseif ( ${CMAKE_C_COMPILER_ID} STREQUAL "PGI")  ### PGI compiler ###

#       set ( AMREX_Fortran_FLAGS_Debug -g -O0 -Mbounds -Ktrap=divz,inv -Mchkptr)
#       set ( AMREX_Fortran_FLAGS_Release -gopt -fast)
#       set ( AMREX_Fortran_FLAGS_FPE )
      
#       set ( AMREX_CXX_FLAGS_Debug -O0 -Mbounds)
#       set ( AMREX_CXX_FLAGS_Release -gopt -fast)
#       set ( AMREX_CXX_FLAGS_FPE )

#    elseif ( ${CMAKE_C_COMPILER_ID} STREQUAL "Cray")  ### Cray compiler ###

#       set ( AMREX_Fortran_FLAGS_Debug -g -O0 -e i)
#       set ( AMREX_Fortran_FLAGS_Release -O2)
#       set ( AMREX_Fortran_FLAGS_FPE -K trap=fp )
      
#       set ( AMREX_CXX_FLAGS_Debug -g -O0)
#       set ( AMREX_CXX_FLAGS_Release -O2)
#       set ( AMREX_CXX_FLAGS_FPE -K trap=fp )
      
#    elseif ()

#       set ( AMREX_Fortran_FLAGS_Debug )
#       set ( AMREX_Fortran_FLAGS_Release )
#       set ( AMREX_Fortran_FLAGS_FPE )
      
#       set ( AMREX_CXX_FLAGS_Debug )
#       set ( AMREX_CXX_FLAGS_Release )
#       set ( AMREX_CXX_FLAGS_FPE )

#       message ( WARNING "Compiler NOT recognized: ID is ${CMAKE_C_COMPILER_ID}. No default flags are loaded!" )
      
#    endif ()
   
# endmacro ()




