function [ q, Q_T ] = inverse_murray_law( beta, gamma, r )
%IVERSE_MURRAY_LAW Computes the total flow given by Murray's law.
% Given an exponent (gamma), a coefficient (beta) and a list
% of radius values (in cm), computes and returns the total flow and the
% list of flow per terminal (q).
%
% Parameters:
% beta:  The Murray's coefficient.
% gamma: The Murray's exponent.
% r:     An array with the radius per terminal, in cm.
%
% Returns:
% q:     The list of flows per terminal (in the order of the r argument), in cm³/s.
% Q_T:   The total flow, in cm³/s.
%

q = beta * (r.^gamma);

Q_T = sum(q);

end
