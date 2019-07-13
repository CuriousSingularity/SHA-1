transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+D:/HDA/2_sem/1_ComplexDigitalArchitecture/Assignment/3_Assignment/Quartus_Project {D:/HDA/2_sem/1_ComplexDigitalArchitecture/Assignment/3_Assignment/Quartus_Project/sha_1.sv}
vlog -sv -work work +incdir+D:/HDA/2_sem/1_ComplexDigitalArchitecture/Assignment/3_Assignment/Quartus_Project {D:/HDA/2_sem/1_ComplexDigitalArchitecture/Assignment/3_Assignment/Quartus_Project/sha_1_core.sv}

vlog -sv -work work +incdir+D:/HDA/2_sem/1_ComplexDigitalArchitecture/Assignment/3_Assignment/Quartus_Project {D:/HDA/2_sem/1_ComplexDigitalArchitecture/Assignment/3_Assignment/Quartus_Project/sha_1_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  sha_1_tb

add wave *
view structure
view signals
run -all
