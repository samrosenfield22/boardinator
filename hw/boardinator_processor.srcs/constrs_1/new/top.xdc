
#IO standards
set_property IOSTANDARD LVCMOS33    [get_ports gpio_pins]
set_property IOSTANDARD LVCMOS33    [get_ports clk]
set_property IOSTANDARD LVCMOS33    [get_ports ext_rst]

#pinout
set_property PACKAGE_PIN P134   [get_ports {gpio_pins[0]}]
set_property PACKAGE_PIN P133   [get_ports {gpio_pins[1]}]
set_property PACKAGE_PIN P132   [get_ports {gpio_pins[2]}]
set_property PACKAGE_PIN P131   [get_ports {gpio_pins[3]}]
set_property PACKAGE_PIN P127   [get_ports {gpio_pins[4]}]
set_property PACKAGE_PIN P126   [get_ports {gpio_pins[5]}]
set_property PACKAGE_PIN P124   [get_ports {gpio_pins[6]}]
set_property PACKAGE_PIN P123   [get_ports {gpio_pins[7]}]

set_property PACKAGE_PIN P56    [get_ports clk]
set_property PACKAGE_PIN P60    [get_ports ext_rst]

