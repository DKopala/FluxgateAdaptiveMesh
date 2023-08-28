# The MIT License (MIT)
#
# Copyright (c) 2023 Dominika Kopala
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# 
#
# DESCRIPTION:
# NETGEN .geo file connected with the paper:
# D. Kopala, R. Szewczyk, A. Ostaszewska-Lizewska
# "Improved accuracy of FEM fluxgate models based on adaptive meshing"

## Vacquier fluxgate sensor model
## two cores, two manetizing coils, one sensing coil
#
algebraic3d

## First core and magnetizing coil
##
## Ferromagnetic core1; Cylinder with length 60 mm and radius - 2 mm;

solid Core_1 = cylinder(-4, 0, -40; -4, 0, 40; 2)
            and plane(0, 0, 30; 0, 0, 1)
            and plane(0, 0, -30; 0, 0, -1) -maxh=0.2;

## Magnetizing Coil; Hollow cylinder with length 60 mm and wall thickness - 1 mm

solid MagCoilIn_1 = cylinder(-4, 0, -40; -4, 0, 40; 2.5)
                  and plane(0, 0, 36; 0, 0, 1)
                  and plane(0, 0, -36; 0, 0, -1);

solid MagCoilOut_1 = cylinder(-4, 0, -40; -4, 0, 40; 3.5)
                  and plane(0, 0, 30; 0, 0, 1)
                  and plane(0, 0, -30; 0, 0, -1);

solid MagCoil_1 = MagCoilOut_1 and not MagCoilIn_1 -maxh=0.4;

## Second core and magnetizing coil
##
## Ferromagnetic core2; Cylinder with length 60 mm and radius - 2 mm;

solid Core_2 = cylinder(4, 0, -40; 4, 0, 40; 2)
            and plane(0, 0, 30; 0, 0, 1)
            and plane(0, 0, -30; 0, 0, -1) -maxh=0.2;
			
## Magnetizing Coil; Hollow cyilnder with length 60 mm and wall thickness - 1 mm

solid MagCoilIn_2 = cylinder(4, 0, -40; 4, 0, 40; 2.5)
                  and plane(0, 0, 36; 0, 0, 1)
                  and plane(0, 0, -36; 0, 0, -1);

solid MagCoilOut_2 = cylinder(4, 0, -40; 4, 0, 40; 3.5)
                  and plane(0, 0, 30; 0, 0, 1)
                  and plane(0, 0, -30; 0, 0, -1);

solid MagCoil_2 = MagCoilOut_2 and not MagCoilIn_2 -maxh=0.4;

## Sensing Coil; Hollow cyilnder with length 20 mm and wall thickness - 1 mm

solid SensCoilOut_1 = cylinder(-4, 0, -15; -4, 0, 15; 5)
                  and plane(0, 0, 11; 0, 0, 1)
                  and plane(0, 0, -11; 0, 0, -1);

solid SensCoilOut_2 = cylinder(4, 0, -15; 4, 0, 15; 5)
                  and plane(0, 0, 11; 0, 0, 1)
                  and plane(0, 0, -11; 0, 0, -1);
				  
solid SensCoilBridgeOut = orthobrick(-4, -5, -11; 4, 5, 11);
                
				  
solid SensCoilOut = SensCoilBridgeOut or SensCoilOut_1 or SensCoilOut_2;
 
solid SensCoilOut_ready = SensCoilOut
					and plane(0, 0, 10; 0, 0, 1)
					and plane(0, 0, -10; 0, 0, -1);		

solid SensCoilIn_1 = cylinder(-4, 0, -15; -4, 0, 15; 4)
                  and plane(0, 0, 12; 0, 0, 1)
                  and plane(0, 0, -12; 0, 0, -1);
				  
solid SensCoilIn_2 = cylinder(4, 0, -15; 4, 0, 15; 4)
                  and plane(0, 0, 12; 0, 0, 1)
                  and plane(0, 0, -12; 0, 0, -1);				  
				  
solid SensCoilBridgeIn = orthobrick(-4, -4, -12; 4, 4, 12);

solid SensCoil= SensCoilOut_ready and not SensCoilIn_1 and not SensCoilIn_2 and not SensCoilBridgeIn -maxh=0.4;
				
## Air
solid Air = sphere(0, 0, 0; 300)
            and not MagCoil_1
            and not MagCoil_2
            and not SensCoil
            and not Core_1
            and not Core_2;
 
tlo MagCoil_1 -col=[0, 0, 1] -transparent;
tlo MagCoil_2 -col=[0, 0, 1] -transparent;
tlo SensCoil -col=[0, 1, 0];
tlo Core_1 -col=[1, 0, 0];
tlo Core_2 -col=[1, 0, 0];
## tlo Air -transparent;
## uncomment in case you want to use the model for FEM simulations

