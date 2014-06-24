% ---------------------------------------------------------
% dynConstants
% ---------------------------------------------------------
% Dynalog Analysis Package
% Michael Hughes 2010-2011
% ---------------------------------------------------------
% Allows the user to specifiy constants used by other
% functions.
%
% You can create multiple versions of this file to model
% different systems.
%
% Then simply call the relevant function file at the top of
% your analysis script.
% ---------------------------------------------------------

function trajConstants

	%Number of leaf pairs
	global varianNumLeaves;
	varianNumLeaves = 60;

	%Widths of leaves in mm
	global varianLeafWidth;
	varianLeafWidth(1:14) = 5;
	varianLeafWidth(15:46) = 2.5;
	varianLeafWidth(47:60) = 5;
    
    global leafBoundariesHD;
    leafBoundariesHD=[0,5,10,15,20,25,30,35,40,45,50,55,60,65,...                
                  67.5,70,72.5,75,77.5,80,82.5,85,87.5,90,...
                  92.5,95,97.5,100,102.5,105,107.5,110,...
                  112.5,115,117.5,120,122.5,125,127.5,130,...
                  132.5,135,137.5,140,142.5,145,...
                  150,155,160,165,170,175,180,185,190,195,200,...
                  205,210,215,220];
    
	
	%Time interval between records in dynalog file (in seconds)
	global recordSpacing;
	recordSpacing = 0.020;
	
	%Projected leaf size at isocenter (as a fraction of real leaf size)
	global leafScaleFactor
	leafScaleFactor = 1.96614;
	
	%Prevent the "Implicit conversion of matrix to string" warning in Octave when printing plots
	setenv('GSC','GSC'); 
	
end