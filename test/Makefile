double64:
	verilator -Wno-fatal -cc \
	../rtl/bsg_defines.v \
	../rtl/bsg_adder_carry_save.v \
	../rtl/bsg_adder_carry_save_4_2.v \
	../rtl/bsg_adder_wallace_tree.v \
	../rtl/bsg_fma_aux_adder.v \
	../rtl/bsg_fma.v \
	--top-module bsg_fma \
	-Gexp_p=11 -Gsig_p=52 \
	-exe ./test_bsg_64.cpp 

	make -C obj_dir -f Vbsg_fma.mk


float32:
	verilator -Wno-fatal -cc \
	../rtl/bsg_defines.v \
	../rtl/bsg_adder_carry_save.v \
	../rtl/bsg_adder_carry_save_4_2.v \
	../rtl/bsg_adder_wallace_tree.v \
	../rtl/bsg_fma_aux_adder.v \
	../rtl/bsg_fma.v \
	--top-module bsg_fma \
	-exe ./test_bsg_32.cpp 

	make -C obj_dir -f Vbsg_fma.mk

clean:
	rm -rf obj_dir