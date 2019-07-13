transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+D:/HDA/2_sem/1_ComplexDigitalArchitecture/Assignment/Quartus_Project {D:/HDA/2_sem/1_ComplexDigitalArchitecture/Assignment/Quartus_Project/state_machine_toplevel_framework.sv}
vlog -sv -work work +incdir+D:/HDA/2_sem/1_ComplexDigitalArchitecture/Assignment/Quartus_Project {D:/HDA/2_sem/1_ComplexDigitalArchitecture/Assignment/Quartus_Project/sha_1.sv}

vlog -sv -work work +incdir+D:/HDA/2_sem/1_ComplexDigitalArchitecture/Assignment/Quartus_Project {D:/HDA/2_sem/1_ComplexDigitalArchitecture/Assignment/Quartus_Project/state_machine_toplevel_framework_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  state_machine_toplevel_framework_tb

add wave *
view structure
view signals
run -all
