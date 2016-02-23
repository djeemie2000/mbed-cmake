# ------------------------------------------------------------------------------
# Copyright by Uwe Arzt mailto:mail@uwe-arzt.de, https://uwe-arzt.de
# under BSD License, see https://uwe-arzt.de/bsd-license/
# ------------------------------------------------------------------------------
CMAKE_MINIMUM_REQUIRED(VERSION 2.8.10)

# ------------------------------------------------------------------------------
# git checkout and build location of mbed libraries
set(MBED_PATH "/home/pj/Repos/mbed/build")

# location where the arm toolset is installed
message(STATUS "${ARM_GCC_PATH} is where toolchain is installed")

# ------------------------------------------------------------------------------
# custom target for copying to mbed device
add_custom_target(upload
  ${ARM_GCC_PATH}arm-none-eabi-objcopy -O binary ${BIN} ${BIN}.bin
  COMMAND cp ${BIN}.bin ${MBEDMOUNT}
)

# ------------------------------------------------------------------------------
# custom target for creating bin file that can be uploaded to mbed device
add_custom_target(createupload
  ${ARM_GCC_PATH}arm-none-eabi-objcopy -O binary ${BIN} ${BIN}.bin
)

# ------------------------------------------------------------------------------
# custom target for opening serial console
add_custom_target(sercon
  command screen ${SERCON} 9600
)

# ------------------------------------------------------------------------------
# setup processor settings add aditional boards here
#  LPC1768, LPC11U24, NRF51822, K64F

# TARGET -> has to be set in CMakeLists.txt
#
# MBED_VENDOR -> CPU Manufacturer
#
message(STATUS "building for ${MBED_TARGET}")
# the settings for mbed is really messed up ;)
if(MBED_TARGET MATCHES "LPC1768")
  set(MBED_VENDOR "NXP")
  set(MBED_FAMILY "LPC176X")
  set(MBED_CPU "MBED_LPC1768")
  set(MBED_CORE "cortex-m3")
  set(MBED_INSTRUCTIONSET "M3")

  set(MBED_STARTUP "startup_LPC17xx.o")
  set(MBED_SYSTEM "system_LPC17xx.o")
  set(MBED_LINK_TARGET ${MBED_TARGET})

elseif(MBED_TARGET MATCHES "LPC11U24")
  set(MBED_VENDOR "NXP")
  set(MBED_FAMILY "LPC11UXX")
  set(MBED_CPU "LPC11U24_401")
  set(MBED_CORE "cortex-m0")
  set(MBED_INSTRUCTIONSET "M0")

  set(MBED_STARTUP "startup_LPC11xx.o")
  set(MBED_SYSTEM "system_LPC11Uxx.o")
  set(MBED_LINK_TARGET ${MBED_TARGET})

elseif(MBED_TARGET MATCHES "RBLAB_NRF51822")
  set(MBED_VENDOR "NORDIC")
  set(MBED_FAMILY "MCU_NRF51822")
  set(MBED_CPU "RBLAB_NRF51822")
  set(MBED_CORE "cortex-m0")
  set(MBED_INSTRUCTIONSET "M0")

  set(MBED_STARTUP "startup_NRF51822.o")
  set(MBED_SYSTEM "system_nrf51822.o")
  set(MBED_LINK_TARGET "NRF51822")

elseif(MBED_TARGET MATCHES "NUCLEO_F411RE")
  set(MBED_VENDOR "STM")
  set(MBED_FAMILY "STM32F4")
  set(MBED_CPU "NUCLEO_F411RE")
  set(MBED_CORE "cortex-m4")
  set(MBED_INSTRUCTIONSET "M4")

  set(MBED_STARTUP "startup_stm32f411xe.o")
  set(MBED_SYSTEM "system_stm32f4xx.o")
  set(MBED_LINK_TARGET "STM32F411XE")

elseif(MBED_TARGET MATCHES "NUCLEO_F446RE")
  set(MBED_VENDOR "STM")
  set(MBED_FAMILY "STM32F4")
  set(MBED_CPU "NUCLEO_F446RE")
  set(MBED_CORE "cortex-m4")
  set(MBED_INSTRUCTIONSET "M4")

  set(MBED_STARTUP "startup_stm32f446xx.o")
  set(MBED_SYSTEM "system_stm32f4xx.o")
  set(MBED_LINK_TARGET "STM32F446XE")

else()
   message(FATAL_ERROR "No MBED_TARGET specified or available. Full stop :(")
endif()

# ------------------------------------------------------------------------------
# compiler settings
SET(COMMON_FLAGS "${COMMON_FLAGS} -Wall -Wextra -Wno-unused-parameter -Wno-missing-field-initializers -fno-exceptions -fno-builtin -MMD -MP -fno-delete-null-pointer-checks")
SET(COMMON_FLAGS "${COMMON_FLAGS} -mcpu=${MBED_CORE} -O2 -mthumb -fno-exceptions -msoft-float -ffunction-sections -fdata-sections -fno-common -fmessage-length=0")
#SET(COMMON_FLAGS "${COMMON_FLAGS} -g") # use debug symbols
#fpu defines!!
SET(COMMON_FLAGS "${COMMON_FLAGS} -mfpu=fpv4-sp-d16 -mfloat-abi=softfp")


SET(MBED_DEFINES "${MBED_DEFINES} -DTARGET_${MBED_FAMILY}")
SET(MBED_DEFINES "${MBED_DEFINES} -DTARGET_${MBED_TARGET}")
SET(MBED_DEFINES "${MBED_DEFINES} -DTARGET_${MBED_INSTRUCTIONSET}")
SET(MBED_DEFINES "${MBED_DEFINES} -DTARGET_${MBED_VENDOR}")
SET(MBED_DEFINES "${MBED_DEFINES} -DTOOLCHAIN_GCC_ARM")
SET(MBED_DEFINES "${MBED_DEFINES} -DTOOLCHAIN_GCC")
#additional defines from generated makefiles
SET(MBED_DEFINES "${MBED_DEFINES} -D__FPU_PRESENT=1 -D__MBED__=1 -DTARGET_FF_MORPHO -DARM_MATH_CM4")

SET(CMAKE_CXX_FLAGS "${COMMON_FLAGS} ${MBED_DEFINES} -std=c++11")
SET(CMAKE_C_FLAGS "${COMMON_FLAGS} ${MBED_DEFINES} -std=gnu99")


# ------------------------------------------------------------------------------
# setup precompiled mbed files which will be needed for all projects
file(GLOB MBED_OBJECTS ${MBED_PATH}/mbed/TARGET_${MBED_TARGET}/${TOOLCHAIN}/*.o)

# ------------------------------------------------------------------------------
# libraries for mbed
set(MBED_LIBS mbed stdc++ supc++ m gcc g c nosys rdimon)

# ------------------------------------------------------------------------------
# linker settings
set(CMAKE_EXE_LINKER_FLAGS "-Wl,--gc-sections -Wl,--wrap,main --specs=nano.specs  -u _printf_float -u _scanf_float")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} \"-T${MBED_PATH}/mbed/TARGET_${MBED_TARGET}/${TOOLCHAIN}/${MBED_LINK_TARGET}.ld\" -static")

# ------------------------------------------------------------------------------
# add mbed headers so they will show in your IDE
file(GLOB MBED_HEADERS ${MBED_PATH}/mbed/*.h)

# ------------------------------------------------------------------------------
# mbed
include_directories("${MBED_PATH}/mbed/")
include_directories("${MBED_PATH}/mbed/TARGET_${MBED_TARGET}/")
include_directories("${MBED_PATH}/mbed/TARGET_${MBED_TARGET}/${TOOLCHAIN}")
include_directories("${MBED_PATH}/mbed/TARGET_${MBED_TARGET}/TARGET_${MBED_VENDOR}/TARGET_${MBED_FAMILY}/")
include_directories("${MBED_PATH}/mbed/TARGET_${MBED_TARGET}/TARGET_${MBED_VENDOR}/TARGET_${MBED_FAMILY}/TARGET_${MBED_CPU}")

link_directories("${MBED_PATH}/mbed/TARGET_${MBED_TARGET}/${TOOLCHAIN}")

# add networking
if(${USE_NET} STREQUAL "true")
  include_directories("${MBED_PATH}/net/eth/")
  include_directories("${MBED_PATH}/net/eth/EthernetInterface")
  include_directories("${MBED_PATH}/net/eth/Socket")
  include_directories("${MBED_PATH}/net/eth/TARGET_${MBED_TARGET}/")
  include_directories("${MBED_PATH}/net/eth/TARGET_${MBED_TARGET}/${TOOLCHAIN}")

  include_directories("${MBED_PATH}/net/eth/lwip")
  include_directories("${MBED_PATH}/net/eth/lwip/include")
  include_directories("${MBED_PATH}/net/eth/lwip/include/ipv4")
  include_directories("${MBED_PATH}/net/eth/lwip-sys")
  include_directories("${MBED_PATH}/net/eth/lwip-eth/arch/TARGET_${MBED_VENDOR}")

  link_directories("${MBED_PATH}/net/eth/TARGET_${MBED_TARGET}/${TOOLCHAIN}")
  set(MBED_LIBS ${MBED_LIBS} eth)

  # supress lwip warnings with 0x11
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-literal-suffix")

  set(USE_RTOS true)
endif()

# add rtos
if(${USE_RTOS} STREQUAL "true")
  include_directories("${MBED_PATH}/rtos/")
  include_directories("${MBED_PATH}/rtos/TARGET_${MBED_TARGET}/")
  include_directories("${MBED_PATH}/rtos/TARGET_${MBED_TARGET}/${TOOLCHAIN}")

  link_directories("${MBED_PATH}/rtos/TARGET_${MBED_TARGET}/${TOOLCHAIN}")
  set(MBED_LIBS ${MBED_LIBS} rtos rtx)
endif()

# add usb
if(${USE_USB} STREQUAL "true")
  include_directories("${MBED_PATH}/usb/USBDevice/")
  include_directories("${MBED_PATH}/usb/USBDevice/TARGET_${MBED_TARGET}/")
  include_directories("${MBED_PATH}/usb/USBDevice/TARGET_${MBED_TARGET}/${TOOLCHAIN}")

  include_directories("${MBED_PATH}/usb/")
  include_directories("${MBED_PATH}/usb/USBMIDI")
  include_directories("${MBED_PATH}/usb/USBSerial")
  include_directories("${MBED_PATH}/usb/USBMSD")
  include_directories("${MBED_PATH}/usb/USBHID")
  include_directories("${MBED_PATH}/usb/USBAudio")

  link_directories("${MBED_PATH}/usb/TARGET_${MBED_TARGET}/${TOOLCHAIN}")
  set(MBED_LIBS ${MBED_LIBS} USBDevice)

  # add mbed usb headers so they will show in your IDE
  file(GLOB MBED_HEADERS ${MBED_PATH}/usb/*.h)
endif()

# add dsp
if(${USE_DSP} STREQUAL "true")
  include_directories("${MBED_PATH}/dsp/")
  include_directories("${MBED_PATH}/dsp/TARGET_${MBED_TARGET}/")
  include_directories("${MBED_PATH}/dsp/TARGET_${MBED_TARGET}/${TOOLCHAIN}")

  link_directories("${MBED_PATH}/dsp/TARGET_${MBED_TARGET}/${TOOLCHAIN}")
  set(MBED_LIBS ${MBED_LIBS} cmsis_dsp dsp)

  # add mbed dsp headers so they will show in your IDE
  file(GLOB MBED_HEADERS ${MBED_PATH}/dsp/*.h)
endif()

# print all include directories
get_property(dirs DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY INCLUDE_DIRECTORIES)
message(STATUS "Include Directories")
foreach(dir ${dirs})
  message(STATUS "  ${dir}")
endforeach()

