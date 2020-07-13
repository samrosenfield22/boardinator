
#IO standards
set_property IOSTANDARD LVTTL    [get_ports gpio_pins]
#set_property IOSTANDARD LVTTL    [get_ports clk]
set_property IOSTANDARD LVTTL    [get_ports ext_rst]

set_property IOSTANDARD LVTTL   [get_ports test_out]

create_clock -period 20         [get_ports clk]

#pinout
set_property PACKAGE_PIN P134   [get_ports {test_out[0]}]
set_property PACKAGE_PIN P133   [get_ports {test_out[1]}]
set_property PACKAGE_PIN P132   [get_ports {test_out[2]}]
set_property PACKAGE_PIN P131   [get_ports {test_out[3]}]
set_property LOC P127   [get_ports {test_out[4]}]
set_property LOC P126   [get_ports {test_out[5]}]
set_property LOC P124   [get_ports {test_out[6]}]
set_property LOC P123   [get_ports {test_out[7]}]

set_property PACKAGE_PIN P56    [get_ports clk]
set_property PACKAGE_PIN P60    [get_ports ext_rst]

