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

function dynConstants

	%Number of leaf pairs
	global varianNumLeaves;
	varianNumLeaves = 60;

	%Widths of leaves in mm
	global varianLeafWidth;
	varianLeafWidth(1:10) = 10;
	varianLeafWidth(11:50) = 5;
	varianLeafWidth(51:60) = 10;
	
	%Time interval between records in dynalog file (in seconds)
	global recordSpacing;
	recordSpacing = 0.05;
	
	%Projected leaf size at isocenter (as a fraction of real leaf size)
	global leafScaleFactor
	leafScaleFactor = 1.96614;
	
	%Prevent the "Implicit conversion of matrix to string" warning in Octave when printing plots
	setenv('GSC','GSC'); 
	
end