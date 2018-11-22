function [rv rs rw] = rv_rs_rw(f,as,density,SSC)
    c = 1500;
    dratio = 2.65/1.025;
    dratioI = 3*(2.65-1.025)/(2*2.65+1.025);
    kr = (0.93^2 + (dratioI)^2/3)/6;

    vp = 4/3*pi*as.^3;
    massp = vp.*density;
    N = SSC./massp;
    volumeC = N.*vp;%0.03/100;

    kv = 1.01e-6;

    rs = zeros(length(f),length(as));
    rv = zeros(length(f),length(as));
    for index = 1:length(f) 
        beta = sqrt(2*pi.*f(index)./2./kv);
        k = 2*pi*f(index)/c;
        x = k.*as;
    
        feta = 0.5*(1+9./(2*beta.*as));
        s = (9./(4*beta.*as)).*(1+1./(beta.*as));
    
        rv(index,:) = (10*log10(exp(2)))*(volumeC.*k.*(dratio-1)^2./2.*(s./(s.^2 + (dratio + feta).^2)));
        rs(index,:) = (10*log10(exp(2)))*(volumeC.*kr.*(x.^4))./(1 + 1.3 * x.^2 + 4/3*kr*x.^4)./as;
    end

    T = 10;         %温度10摄氏度
    S = 35;         %盐度35ppt
    Z = 0;          %深度0km
    PH = 8;

    f1 = 780*exp(T/29);
    f2 = 42000*exp(T/18);
    A = 0.083*(S/35)*exp(T/31 - Z/91 + 1.8*(PH-8));
    B = 22*(S/35)*exp(T/14 - Z/6);
    C = 4.9*10^(-10)*exp(-T/26 - Z/25);

    rw = (A ./ (f1^2 + f.^2) + B ./ (f2^2 + f.^2) + C).*f.^2./1000;
    rw = rw'*ones(1,length(as));