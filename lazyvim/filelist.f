// Main filelist example for automatic-verilog in LazyVim.
// Environment variables are supported.
// Nested filelists are supported through -f.

-f ./filelist_ip.f

// Direct source files
$PROJECT_ROOT/rtl/top.sv
$PROJECT_ROOT/rtl/core/alu.sv

// Search directories
-y $PROJECT_ROOT/rtl/peripheral
+incdir+$PROJECT_ROOT/include

// Extra extensions if needed
+libext+.sv
+libext+.v
