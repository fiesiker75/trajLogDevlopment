function [angle] = Varian2IEC(VarianScaleAngle)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if (VarianScaleAngle<180) 
      angle=180-VarianScaleAngle;
else
     angle=540-VarianScaleAngle;
end

end

