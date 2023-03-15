function [yd,yi] = hex2dec_swfc(x,swfc,sz23,pkbits,wordbits)
% function [yd,yi] = hex2dec_swfc(x,swfc,sz23,pkbits,wordbits);
% Create decimal representation according to swfc convention 
% x - hexidecimal reprentation input [Mx1] if real, [2Mx1] if complex
%     or integer equivalent
% swfc - [s w f c] of <sw.f>(complex?) convention, where ...
%   s  - sign bit enable flag (1 = signed quantity allowed, 0 = unsigned)
%   w  - bits allocated left of decimal
%   f  - bits allocated right of decimal
%   c  - complex number flag (1 = complex quantity, 0 (default) = real)
% sz23 - (optional) size of output dim2 or [dim2,dim3] for reshaping
% pkbits - (optional) triggers treating only backbit lsbs of hex word as valid 
%          and assumption that swfc of data is packed by powers of 2 into them
%          note, complex treated as interleaved, not I/Q as one value
% wordbits - (optional) bits represented in each hexidecimal word (default = 32)
% yd - decimal representation output [Mx1]
% yi - (optional) integer representation [Mx1]
% RCL 060121

if ~exist('wordbits','var'), wordbits = 32; end
s=swfc(1); w=swfc(2); f=swfc(3); c=swfc(4);

% convert to decimal (integer) if truly hex passed
if ischar(x),
    y = hex2dec(x);
else
    y = double(x(:));
end

if exist('pkbits','var') && ~isempty(pkbits)
    s1 = size(y,1);
    dbt = sum(swfc(1:3)); % data bits
    if dbt > wordbits; 
        error('data format exceeds available bits in word');
    end;
    dpf = 2^floor(log2(pkbits/dbt)); % number of data values packed into word
    dpb = floor(pkbits/dpf); % number of bits per packed segment
    for i = dpf:-1:1,
        yt = bitshift(y,wordbits-dpb*i,wordbits); % shift high bits off top
        yt = bitshift(yt,dpb-wordbits); % shift low bits off bottom (and align)
        yi(i:dpf:dpf*s1,1) = yt; % pack into expanded yi;
    end
else
    yi = y;
end

if s,
    % compensate for twos compliment
    yd = yi-2^(w+f+1).*(yi>=2^(w+f));
else
    yd = yi;
end

if c,
    % de-interleave real/imaginary
    yi = yi(1:2:end) + j*yi(2:2:end);
    yd = yd(1:2:end) + j*yd(2:2:end);
end

% multiply integer representation by quanta
yd = yd*2^-f;

ln = length(yi);
if exist('sz23','var'),
    if length(sz23)==1,
        if mod(ln,sz23)==0,
            % reshape according to 2nd dim size passed
            yd = reshape(yd,[],sz23);
            yi = reshape(yi,[],sz23);
        else
            warning(['could not reshape, samples read (',...
                num2str(ln),') does not divide evenly by 2nd dim size passed (',...
                num2str(sz23),'); returning column vector']);
        end;
    elseif length(sz23)==2,
        if mod(ln,prod(sz23))==0,
            % reshape according to 2nd and 3rd dim sizes passed
            yd = reshape(yd,[],sz23(1),sz23(2));
            yi = reshape(yi,[],sz23(1),sz23(2));
        else
            warning(['could not reshape, samples read (',...
                num2str(ln),') does not divide evenly by product of 2nd and 3rd dim size passed (',...
                num2str(sz23(1)),',',num2str(sz23(2)),'); returning column vector']);
        end;
    else
        error('can not interpret sz23');
    end
end
