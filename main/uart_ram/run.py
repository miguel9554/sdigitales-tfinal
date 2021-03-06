from vunit import VUnit

VU = VUnit.from_argv()
VU.add_osvvm()
VU.add_verification_components()

# Create library 'lib'
lib = VU.add_library("lib")

# Add all files ending in .vhd in current working directory to library
lib.add_source_files("*.vhdl")
lib.add_source_files("../../ram/src/*.vhdl")
lib.add_source_files("../../ram/implementation/*.vhdl")
lib.add_source_files("../../uart/src/*.vhdl")
lib.add_source_files("../../uart/implementation/*.vhdl")

VU.main()