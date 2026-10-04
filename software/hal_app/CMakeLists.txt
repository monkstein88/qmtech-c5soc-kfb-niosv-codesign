cmake_minimum_required(VERSION 3.14)

add_subdirectory(../hal_bsp hal_bsp)

include(../hal_bsp/toolchain.cmake)

project(blinky)

enable_language(ASM)
enable_language(C)
enable_language(CXX)

add_executable(blinky.elf)

target_sources(blinky.elf
    PRIVATE
        src/main.c
        inc/main.h
)

target_include_directories(blinky.elf
    PRIVATE
        inc
    PUBLIC
)

target_link_libraries(blinky.elf
    PRIVATE
        -T "${BspLinkerScript}" -nostdlib
        "${ExtraArchiveLibraries}"
        -Wl,--start-group "${BspLibraryName}" -lc -lstdc++ -lgcc -lm -Wl,--end-group
)

# Create objdump from ELF.
set(objdump blinky.elf.objdump)
add_custom_command(
    OUTPUT "${objdump}"
    DEPENDS blinky.elf
    COMMAND "${ToolchainObjdump}" "${ToolchainObjdumpFlags}" blinky.elf >
            "${objdump}"
    COMMENT "Creating ${objdump}."
    VERBATIM
)
add_custom_target(create-objdump ALL DEPENDS "${objdump}")

# Report space free for stack + heap. Note that the file below is never created
# so the report is always output on build.
set(stack_report_file blinky.elf.stack_report)
add_custom_command(
    OUTPUT "${stack_report_file}"
    DEPENDS blinky.elf
    COMMAND niosv-stack-report -p "${ToolchainPrefix}" blinky.elf
    COMMENT "Reporting memory available for stack + heap in blinky.elf."
    VERBATIM
)
add_custom_target(niosv-stack-report ALL DEPENDS "${stack_report_file}")

# Generate HEX file(s) from blinky.elf using elf2hex tool.
# Note : If ECC Full is enabled, width of 39 is set for NiosV TCM. Otherwise, 32.
add_custom_command(
    OUTPUT "niosvitcm1.hex"
    DEPENDS blinky.elf
    COMMAND elf2hex blinky.elf -o niosvitcm1.hex -b 0x00000000 -w 32 -e 0x0001FFFF -r 4
    COMMENT "Creating niosvitcm1.hex."
    VERBATIM
)
add_custom_command(
    OUTPUT "niosvdtcm1.hex"
    DEPENDS blinky.elf
    COMMAND elf2hex blinky.elf -o niosvdtcm1.hex -b 0x20000000 -w 32 -e 0x20007FFF -r 4
    COMMENT "Creating niosvdtcm1.hex."
    VERBATIM
)
add_custom_target(create-hex ALL DEPENDS "niosvitcm1.hex" "niosvdtcm1.hex")
