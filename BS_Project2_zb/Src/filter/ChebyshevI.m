function Hd = ChebyshevI
%CHEBYSHEVI Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 9.4 and DSP System Toolbox 9.6.
% Generated on: 02-Apr-2018 19:03:18

% Chebyshev Type I Lowpass filter designed using FDESIGN.LOWPASS.

% All frequency values are in Hz.
Fs = 360;  % Sampling Frequency

N     = 16;  % Order
Fpass = 50;  % Passband Frequency
Apass = 1;   % Passband Ripple (dB)

% Construct an FDESIGN object and call its CHEBY1 method.
h  = fdesign.lowpass('N,Fp,Ap', N, Fpass, Apass, Fs);
Hd = design(h, 'cheby1');

% [EOF]
