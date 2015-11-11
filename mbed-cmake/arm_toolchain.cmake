# ------------------------------------------------------------------------------
# Copyright by Uwe Arzt mailto:mail@uwe-arzt.de, https://uwe-arzt.de
# under BSD License, see https://uwe-arzt.de/bsd-license/
# ------------------------------------------------------------------------------
INCLUDE(CMakeForceCompiler)
 
#-------------------------------------------------------------------------------
SET(CMAKE_SYSTEM_NAME Generic)
 
#-------------------------------------------------------------------------------
# specify the cross compiler, later on we will set the correct path??
set(TOOLCHN_PATH /home/pj/ToolChains/gcc-arm-none-eabi-4_9-2015q3/bin)

CMAKE_FORCE_C_COMPILER(${TOOLCHN_PATH}/arm-none-eabi-gcc GNU)
CMAKE_FORCE_CXX_COMPILER(${TOOLCHN_PATH}/arm-none-eabi-g++ GNU)


#-------------------------------------------------------------------------------
set(TOOLCHAIN TOOLCHAIN_GCC_ARM)

#-------------------------------------------------------------------------------
# define presets
set(USE_RTOS false)
set(USE_NET false)
set(USE_USB true)
set(USE_DSP true)

