function [ q, beta ] = murray_law( Q_T, gamma, r )
%MURRAY_LAW Computes the Murray's law.
% Given an exponent (gamma), a value of total flow (Q_T in cm³/s) and a list
% of radius values (in cm), computes and returns the coefficient (beta) and a
% list of flow per terminal (q).
%
% Parameters:
% Q_T:   The total flow, in cm³/s.
% gamma: The Murray's exponent.
% r:     An array with the radius per terminal, in cm.
%
% Returns:
% q:     The list of flows per terminal (in the order of the r argument), in cm³/s.
% beta:  The Murray's coefficient.
%

beta = Q_T / sum(r.^gamma);

q = beta * (r.^gamma);

end
