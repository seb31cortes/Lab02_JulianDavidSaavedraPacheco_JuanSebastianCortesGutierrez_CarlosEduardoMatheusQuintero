## Zybo Z7 Rev. B; pines comunes Z7-10 y Z7-20. RGB LD6.
## Fuente: https://github.com/Digilent/digilent-xdc/blob/master/Zybo-Z7-Master.xdc
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -name sys_clk -period 8.000 [get_ports clk]
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports {SW[0]}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {SW[1]}]
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {SW[2]}]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports {SW[3]}]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports {BTN[0]}]
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33} [get_ports {BTN[1]}]
set_property -dict {PACKAGE_PIN K19 IOSTANDARD LVCMOS33} [get_ports {BTN[2]}]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports {BTN[3]}]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {LED[0]}]
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports {LED[1]}]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports {LED[2]}]
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports {LED[3]}]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports RGB_R]
set_property -dict {PACKAGE_PIN F17 IOSTANDARD LVCMOS33} [get_ports RGB_G]
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33} [get_ports RGB_B]

## Entradas humanas asincronas: solo se exceptua el camino hasta la primera
## etapa. El camino meta -> synced SI se temporiza y conserva ASYNC_REG.
set first_stage [get_cells -hier -regexp {.*u_(sw|btn)_sync/meta_reg\[[0-3]\]}]
set_false_path -from [get_ports {SW[*] BTN[*]}] -to [get_pins -of_objects $first_stage -filter {REF_PIN_NAME == D}]
## LEDs observados por personas; no hay receptor externo sincrono.
set_false_path -to [get_ports {LED[*] RGB_R RGB_G RGB_B}]
