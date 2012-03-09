function [bmld_out] = bmld(coherence,phase_target,phase_int,fc)
%[fc phase_target phase_int coherence ]
k = (1 + 0.25^2) * exp((2*pi*fc)^2 * 0.000105^2);
bmld_out = 10 * log10 ((k - cos(phase_target-phase_int))/(k - coherence));
if bmld_out < 0;
    bmld_out = 0;
end
return
