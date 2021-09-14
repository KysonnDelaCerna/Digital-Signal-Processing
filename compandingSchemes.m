filename = 'file';
make = true;
[originalSignal, Fs] = audioread(strcat(filename, '.wav'));

% calculate time step and number of time steps
dt = 1 / Fs;
len = length(originalSignal);
t = 0 : dt : (len * dt) - dt;
% calculate Xmax
absoluteSignal = abs(originalSignal);
Xmax = max(absoluteSignal);

% compress the signal
compressed255Signal = sign(originalSignal) .* log(1 + 255 * (absoluteSignal / Xmax)) / log(256);
compressed511Signal = sign(originalSignal) .* log(1 + 511 * (absoluteSignal / Xmax)) / log(512);
compressedSqrtSignal = sign(originalSignal) .* sqrt(absoluteSignal / Xmax);
compressedCurtSignal = nthroot(originalSignal ./ Xmax, 3);
compressedAtanSignal = atan(originalSignal ./ Xmax) ./ atan(1);

% 8-bit  linear  midtread  quantizer
bits = 8;
% calculate delta
delta = (2) / (2 ^ bits - 1);
maxDelta = 2 ^ (bits - 1) - 1;

% quantize speech
quantized255Signal = nearest(compressed255Signal / delta);
% constrain signal to -maxDelta to maxDelta
quantized255Signal(compressed255Signal > maxDelta) = maxDelta;
quantized255Signal(compressed255Signal < -maxDelta) = -maxDelta;
quantized255Signal = quantized255Signal * delta;
% quantize speech
quantized511Signal = nearest(compressed511Signal / delta);
% constrain signal to -maxDelta to maxDelta
quantized511Signal(compressed511Signal > maxDelta) = maxDelta;
quantized511Signal(compressed511Signal < -maxDelta) = -maxDelta;
quantized511Signal = quantized511Signal * delta;
% quantize speech
quantizedSqrtSignal = nearest(compressedSqrtSignal / delta);
% constrain signal to -maxDelta to maxDelta
quantizedSqrtSignal(compressedSqrtSignal > maxDelta) = maxDelta;
quantizedSqrtSignal(compressedSqrtSignal < -maxDelta) = -maxDelta;
quantizedSqrtSignal = quantizedSqrtSignal * delta;
% quantize speech
quantizedCurtSignal = nearest(compressedCurtSignal / delta);
% constrain signal to -maxDelta to maxDelta
quantizedCurtSignal(compressedCurtSignal > maxDelta) = maxDelta;
quantizedCurtSignal(compressedCurtSignal < -maxDelta) = -maxDelta;
quantizedCurtSignal = quantizedCurtSignal * delta;
% quantize speech
quantizedAtanSignal = nearest(compressedAtanSignal / delta);
% constrain signal to -maxDelta to maxDelta
quantizedAtanSignal(compressedAtanSignal > maxDelta) = maxDelta;
quantizedAtanSignal(compressedAtanSignal < -maxDelta) = -maxDelta;
quantizedAtanSignal = quantizedAtanSignal * delta;

% expand signal
expanded255Signal = (256 .^ abs(quantized255Signal) - 1) / 255 .* sign(quantized255Signal) * Xmax;
expanded511Signal = (512 .^ abs(quantized511Signal) - 1) / 511 .* sign(quantized511Signal) * Xmax;
expandedSqrtSignal = sign(quantizedSqrtSignal) .* (quantizedSqrtSignal .^ 2) .* Xmax;
expandedCurtSignal = (quantizedCurtSignal .^ 3) .* Xmax;
expandedAtanSignal = tan(quantizedAtanSignal .* atan(1)) * Xmax;

% write to file
if make
    audiowrite(strcat(filename, '-255.wav'), expanded255Signal, Fs);
    audiowrite(strcat(filename, '-511.wav'), expanded511Signal, Fs);
    audiowrite(strcat(filename, '-Sqrt.wav'), expandedSqrtSignal, Fs);
    audiowrite(strcat(filename, '-Curt.wav'), expandedCurtSignal, Fs);
    audiowrite(strcat(filename, '-Atan.wav'), expandedAtanSignal, Fs);
end

% get quantized error
quantizationError255 = expanded255Signal - originalSignal;
quantizationError511 = expanded511Signal - originalSignal;
quantizationErrorSqrt = expandedSqrtSignal - originalSignal;
quantizationErrorCurt = expandedCurtSignal - originalSignal;
quantizationErrorAtan = expandedAtanSignal - originalSignal;

% SNR
SNR255 = sum(originalSignal .^ 2) / sum(quantizationError255 .^ 2);
SNR255 = 10 * log10(SNR255);
disp('SNR 255 (db):');
disp(SNR255);
% SNR
SNR511 = sum(originalSignal .^ 2) / sum(quantizationError511 .^ 2);
SNR511 = 10 * log10(SNR511);
disp('SNR 511 (db):');
disp(SNR511);
% SNR
SNRSqrt = sum(originalSignal .^ 2) / sum(quantizationErrorSqrt .^ 2);
SNRSqrt = 10 * log10(SNRSqrt);
disp('SNR Sqrt (db):');
disp(SNRSqrt);
% SNR
SNRCurt = sum(originalSignal .^ 2) / sum(quantizationErrorCurt .^ 2);
SNRCurt = 10 * log10(SNRCurt);
disp('SNR Curt (db):');
disp(SNRCurt);
% SNR
SNRAtan = sum(originalSignal .^ 2) / sum(quantizationErrorAtan .^ 2);
SNRAtan = 10 * log10(SNRAtan);
disp('SNR Atan (db):');
disp(SNRAtan);