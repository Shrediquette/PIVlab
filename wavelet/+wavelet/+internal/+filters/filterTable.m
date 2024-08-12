function wavtabl = filterTable(ftype)
% This function is for internal use only. It may change or be removed in a
% future release.
%
%   %Example: Find all wavelet filters close in frequency separation to
%   "db4"
%   [~,~,LoR,HiR] = wfilters("db4");
%   fsep = wavelet.internal.filters.qmfFreqsep(LoR,HiR);
%   wavtabl = wavelet.internal.filters.filterTable(1);
%   Stabl = sortrows(wavtabl,"Frequency Separation","descend");
%   [~,idx] = min(abs(fsep-Stabl.("Frequency Separation")));
%   Nh = height(Stabl);
%   Stabl(max(1,idx-2):min(Nh,idx+2),:)

%   Copyright 2022 The MathWorks, Inc.

arguments
    ftype {mustBeMember(ftype,[1,2])} = 1
end

wavelets = {};
idx = 1;
wav_info = wavemngr('rescue');
Nfamily = length(wav_info);
for ii = 1:Nfamily
    if wav_info(ii).type == ftype
        wname = string(wav_info(ii).familyShortName);
        wavnumbers = strip(string(wav_info(ii).tabNums));
        sz = size(wavnumbers,1);
        if sz == 1
            wavelets{idx} = wname; %#ok<*AGROW>
            idx = idx+1;
        elseif sz > 1
            for jj = 1:length(wavnumbers)
                snum = strip(string(wav_info(ii).tabNums(jj,:)));
                if ~isnan(str2double(snum))
                    wavelets{idx} = wname+snum;
                    idx = idx+1;
                end
            end
        end
    end
end


if ftype == 1
    wavtabl = orthfilterTable(wavelets);
else
    wavtabl = biorthfilterTable(wavelets);
end       
end

function wavtabl = orthfilterTable(wavelets)
        numwav = length(wavelets);
        names = string(repmat("",numwav,1));
        filtlengths = zeros(numwav,1);
        effSupport = zeros(numwav,1);
        timevar = zeros(numwav,1);
        freqsep = zeros(numwav,1);
        wavtabl = table(names,filtlengths,effSupport,timevar,freqsep,'VariableNames',...
            {'Wavelet Name','Filter Length','Effective Support','Time Variance','Frequency Separation'});
        for ii = 1:numwav
            wavtabl.("Wavelet Name")(ii) = wavelets{ii};
            [Lo,Hi] = wfilters(wavelets{ii});
            wavtabl.("Filter Length")(ii) = length(Lo);
            wavtabl.("Effective Support")(ii) = nnz(abs(Lo)> eps(1));
            wavtabl.("Time Variance")(ii) = wavelet.internal.filters.normalizedVar(Lo);
            wavtabl.("Frequency Separation")(ii) = wavelet.internal.filters.qmfFreqsep(Lo,Hi);
        end
end

function wavtabl = biorthfilterTable(wavelets)
        numwav = length(wavelets);
        names = string(repmat("",numwav,1));
        analysisEffSupport = zeros(numwav,2);
        synthesisEffSupport = zeros(numwav,2);
        analysisTimevar = zeros(numwav,2);
        synthesisTimevar = zeros(numwav,2);
        analysisFreqsep = zeros(numwav,1);
        synthesisFreqsep = zeros(numwav,1);
        wavtabl = table(names,analysisEffSupport,synthesisEffSupport,analysisTimevar,...
            synthesisTimevar,analysisFreqsep,synthesisFreqsep,...
            'VariableNames',...
            {'Wavelet Name','Analysis Filter Support',...
            'Synthesis Filter Support',...
            'Analysis Time Variance', 'Synthesis Time Variance',...
            'Analysis Frequency Separation','Synthesis Frequency Separation'});
        for ii = 1:numwav
            wavtabl.("Wavelet Name")(ii) = wavelets{ii};
            [LoD,HiD,LoR,HiR] = wfilters(wavelets{ii});
            wavtabl.("Analysis Filter Support")(ii,:) = [nnz(abs(LoD)>eps(1)) nnz(abs(HiD)>eps(1))];
            wavtabl.("Synthesis Filter Support")(ii,:) = [nnz(abs(LoR)>eps(1)) nnz(abs(HiR)>eps(1))];
            wavtabl.("Analysis Time Variance")(ii,:) = [wavelet.internal.filters.normalizedVar(LoD) wavelet.internal.filters.normalizedVar(HiD)];
            wavtabl.("Synthesis Time Variance")(ii,:) = wavelet.internal.filters.normalizedVar(LoR);
            wavtabl.("Analysis Frequency Separation")(ii) = wavelet.internal.filters.qmfFreqsep(LoD,HiD);
            wavtabl.("Synthesis Frequency Separation")(ii) = wavelet.internal.filters.qmfFreqsep(LoR,HiR);
        end
    end
