function vaporwaveLoFi(inputName, varargin)
    % handle parameters
    p = inputParser;
    p.KeepUnmatched = true;
    addRequired(p,'inputName');
    addParameter(p,'outputName','output.wav');
    addParameter(p,'wetDryMix',0.4);
    addParameter(p,'lowpassCutoff',1000);
    addParameter(p,'lowpassTransition',9000);
    addParameter(p,'highpassCutoff',2000);
    addParameter(p,'highpassTransition',1000);
    addParameter(p,'normalizeFactor',0.9);
    parse(p,inputName,varargin{:})
    
    % read audio
    [y, Fs]=audioread(inputName);
    
    % speed change
    Fs=Fs*0.9;
    
    % reverb
    reverb=reverberator('PreDelay',0,'WetDryMix',p.Results.wetDryMix);
    y=reverb(y);
    
    % lowpass
    f1=p.Results.lowpassCutoff/Fs;
    b1=p.Results.lowpassTransition/Fs;
    L1=round(6.1/(2*b1),0);
    if mod(L1,2) == 0
        L1=L1+1;
    end
    M1=L1-1;
    n1=1:M1/2;
    h1=(sin(n1*2*pi*f1)./(n1*pi)).*(2-2*(n1+M1/2)/M1);
    h1=[flip(h1),2*f1,h1];
    y=conv2(y',h1,'valid')';
    
    %h ighpass
    f2=p.Results.highpassCutoff/Fs;
    b2=p.Results.highpassTransition/Fs;
    L2=round(6.2/(2*b2),0);
    if mod(L2,2) == 0
        L2=L2+1;
    end
    M2=L2-1;
    n2=1:M2/2;
    h2=(-sin(n2*2*pi*f2)./(n2*pi)).*(0.5-0.5*cos(2*pi*(n2+M2/2)/M2));
    h2=[flip(h2),1-2*f2,h2];
    y=conv2(y',h2,'valid')';
    
    % normalize
    y=p.Results.normalizeFactor*(y/max(abs(y(:))));
    
    % write audio
    audiowrite(p.Results.outputName,y,Fs);
end