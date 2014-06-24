function [MU_CP_E,MU_CP_A] = getMU(snapShotCurrentCP,snapShotPreviousCP)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

MU_CP_E=snapShotCurrentCP.MU_E-snapShotPreviousCP.MU_E;
MU_CP_A=snapShotCurrentCP.MU_A-snapShotPreviousCP.MU_A;

end

