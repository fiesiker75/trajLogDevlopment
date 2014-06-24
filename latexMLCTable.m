function latexCommands = latexMLCTable( MLCdata )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
header={'\begin{table}';
        '\centering';
        '\begin{tabular}{c c}';
        '\hline\hline';
        'Deviation & Cumulative \% \\';
        '\hline';
        };

    

for i=1:numberDataRows
rowStr = [rowStr,' & ',input.tableColumnHeaders{i}];    
$\pm$ 0.01mm & 65.21 \\
$\pm$ 0.02mm & 76.38 \\
$\pm$ 0.05mm & 90.83 \\
$\pm$ 0.10mm & 100 \\[1ex]
end

& [mm] \\
\hline\hline
Mean & 0.0030119 \\
$\sigma$ & 0.027974 \\
footer={'\hline\hline';
        '\end{tabular}';
        }

end

