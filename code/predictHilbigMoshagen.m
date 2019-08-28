function theta = HilbigMoshagenPredictions(epsilon)
% theta = HilbigMoshagenPredictions(epsilon)
%   generate 6 x 3 matrix theta with predictions (given 9 epsilon values)
%   for six models (guess, ttb, tally, wadd, waddprob, saturated) for each
%   of the three Hilbig and Moshagen (2014) stimulus types

% Guess
theta(1, 1) = 0.5;
theta(1, 2) = 0.5;
theta(1, 3) = 0.5;
% TTB
theta(2, 1) = 1 - epsilon(1);
theta(2, 2) = 1 - epsilon(1);
theta(2, 3) = 1 - epsilon(1);
%TALLY
theta(3, 1) = 1 - epsilon(2);
theta(3, 2) = epsilon(2);
theta(3, 3) = 0.5;
% WADD
theta(4, 1) = 1 - epsilon(3);
theta(4, 2) = epsilon(3);
theta(4, 3) = 1 - epsilon(3);
% WADDprob
theta(5, 1) = 1 - epsilon(4);
theta(5, 2) = epsilon(6);
theta(5, 3) = 1 - epsilon(5);
% Saturated
theta(6, 1) = epsilon(7);
theta(6, 2) = epsilon(8);
theta(6, 3) = epsilon(9);
end

