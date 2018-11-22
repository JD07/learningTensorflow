function s = sv(frange,as,SSC,density)

% SSC = 0.795;        %kg/m^3
% density = 2650;     %kg/m^3;
c = 1500;
wL = c./frange;

aN = length(as);
wN = length(frange);
s = zeros(wN,aN);

dr = 2.6;
kr = 0.1;
cons = ((5*dr-2)/(2*dr+1)-kr)^2;
for i = 1:wN
    s(i,:) = 10*log10((2*pi./wL(i)).^4.*as.^3.*SSC./3./density.*cons./4./pi);
end