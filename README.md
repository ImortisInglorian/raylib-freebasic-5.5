# raylib-freebasic-5.5

Updated headers, examples, and binaries for raylib 5.5 for the freeBasic programming language.

To use the raylib examples in Windows, just drop the DLLs in the folder with the examples.  In Linux, you will need to copy the .so files to folder your distro uses for libraries.

If you want to move the .bi files into the same folder as the examples, you will need to change the include lines in each example.

Included are binaries for 32 and 64bit Windows, but only 64bit Linux as I don't have a 32bit distro to compile them on.

# Changes from Base Raylib
* I combined the raylib and raymath headers as it seems unlikely you will want to use raymath by itself.
* The raylib Color type has been renamed to RLColor.
