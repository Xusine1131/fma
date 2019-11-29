main:
	verilator -Wno-fatal -cc \
	../rtl/bsg_defines.v \
	../rtl/bsg_adder_carry_save.v \
	../rtl/bsg_adder_carry_save_4_2.v \
	../rtl/bsg_adder_wallace_tree.v \
	../rtl/bsg_fma_aux_adder.v \
	../rtl/fma_test.v \
	--top-module fma_test \
	-exe ./test_bsg.cpp 

	make -C obj_dir -f Vfma_test.mk

clean:
	rm -rf obj_dir