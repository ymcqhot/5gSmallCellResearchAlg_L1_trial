%%
% ------------------------------------------------------------------------------
%
%                     ©Copyright GiRive Institute 2023                      
%
%      The software herein is furnished under license and may be used         
%
%      or copied only in accordance with the terms of such license.
%
% -------------------------------------------------------------------------------
%
% File           gi_nrPhySimDlTxSignalGen.m
%
% Description    Wrapper of DL TX signal generation
%
% -------------------------------------------------------------------------------
%
% Change log
%
% Date          Author       Action
%
% 2023.06.08    Mian Yang    Created
%
% -------------------------------------------------------------------------------
%

%% gi_nrPhySimDlTxSignalGen
% -------------------------------------------------------------------------------
%
% *gi_nrPhySimDlTxSignalGen* - Wrapper of DL TX signal generation
%
% -------------------------------------------------------------------------------
%
% *simSysS* - gi_nrPhySimSys_s
%
% Param [In]   
%
% Format is [1], struct.
%
% *simDlTxSysInterS* - gi_nrPhySimDlTxSysInter_s
%
% Param [In]   
%
% Format is [1], struct.
%
% *simDlSortSlotS* - gi_nrPhySimDl_s removing invalid ue parameters and sort ue parameters
%
% Param [In]    
%
% Format is [1], struct.
%
% *repeatIdx* - Repeat index
%
% Param [In]   
%
% Format is [1], integer.
%
% *numSlot* - Number of slot in on repeat
%
% Param [In]   
%
% Format is [1], integer.
%
% *caseAddr* - Address of one case
%
% Param [In]   
%
% Format is [1], string.
%
% *dataTime* - Timing data
%
% Param [Out]    
%
% Format is [timeLenSlot, nrOfPorts], complex, float.
%
% *pdschCw1Record* - CW1 bits record for retransmission
%
% Param [Inout]    
%
% Format is [GI_NR_PHY_SIM_ATTACH_UE, GI_NR_PHY_SIM_PDSCH_NUM_HARQ, GI_NR_PHY_SIM_PDSCH_TB_SIZE], bit stream.
%
% *pdschCw2Record* - CW2 bits record for retransmission
%
% Param [Inout]    
%
% Format is [GI_NR_PHY_SIM_ATTACH_UE, GI_NR_PHY_SIM_PDSCH_NUM_HARQ, GI_NR_PHY_SIM_PDSCH_TB_SIZE], bit stream.
%
% -------------------------------------------------------------------------------
%
function [dataTime, pdschCw1Record, pdschCw2Record] = gi_nrPhySimDlTxSignalGen(simSysS, simDlTxSysInterS, simDlSortSlotS, repeatIdx, numSlot, caseAddr,...
                                                                               pdschCw1Record, pdschCw2Record)

%% Declare macro
gi_nrPhySimMacroDefine;

%% Declare struct;
gi_nrPhySimStructDefine;

%% Parameter check
%Unnecessary to check

%% Sort PDU order as SSB, PDCCH, CSI-RS, PDSCH
%Initialize
ssbPduIndex = [];
pdcchPduIndex = [];
csiRsPduIndex = [];
pdschPduIndex = [];

%PDU loop
for pduIdx = 1:simDlSortSlotS.nPDUs
    %Fetch PDU
    simDlPduS = simDlSortSlotS.simDlPduS(pduIdx);
    
    %Processing according to different PDU type
    if 0 == simDlPduS.pduType %PDCCH
        pdcchPduIndex = [pdcchPduIndex, pduIdx]; %Index start from 1
    elseif 1 == simDlPduS.pduType %PDSCH
        pdschPduIndex = [pdschPduIndex, pduIdx];
    elseif 2 == simDlPduS.pduType %CSI-RS
        csiRsPduIndex = [csiRsPduIndex, pduIdx];
    elseif 3 == simDlPduS.pduType %SSB
        ssbPduIndex = [ssbPduIndex, pduIdx];
    else
        %Do nothing;
    end %if, simDlPduS.pduType
end %for, pduIdx

%Combine PDU index after sort
sortPduIndex = [ssbPduIndex, pdcchPduIndex, csiRsPduIndex, pdschPduIndex]; %Index start from 1

%Fetch numTxAnt
numTxAnt = simSysS.numTxAnt;

%Grid loop, u for FR1
for u = 0:2 
    %CP loop
    for cp = 0:1
        %Initialize for flag of Grid & CP existing
        exitFlag = 0;

        %Jump situation of extended CP but u is not 2
        if 1 == cp && u ~= 2
            continue;
        end

        %Update the SFN and Slot number each slot
        [SFN, slot] = gi_nrPhySimSfnAndSlotUpdate(repeatIdx, numSlot, u, cp, simDlSortSlotS.SFN, simDlSortSlotS.Slot);
    
        %% Grid level parameter calculation
        [simDlTxGridInterS] = gi_nrPhySimDlTxGridParamParser(simSysS, u, cp); 
    
        %% Input parameter for reference generation, grid part
        if 1 == GI_NR_PHY_SIM_DL_REF_INPUT_PARAM
            [simDlRefInputS] = gi_nrPhySimDlTxGridRefInputParam(simSysS, simDlTxGridInterS, u, cp, slot);
        else
            simDlRefInputS = gi_nrPhySimDlTxRefInput_s;
        end
       
        %Initialize dataGrid of each grid, frequency dta of SSB, simUlTxCsiRsInterS
        dataGrid = zeros(simDlTxGridInterS.numScGrid, simDlTxGridInterS.numSymSlot, GI_NR_PHY_SIM_DL_NUM_PORT); %Accroding to MALAB habit
        dataGridSsb = zeros(simDlTxGridInterS.numScGrid, simDlTxGridInterS.numSymSlot, 1); %Accroding to MALAB habit
        simUlTxCsiRsInterS = [];
    
        % PDU loop in one grid
        for pduIdx = 1:simDlSortSlotS.nPDUs
            %Get PDU index
            pduIndex = sortPduIndex(pduIdx);
    
            %Fetch PDU
            simDlPduS = simDlSortSlotS.simDlPduS(pduIndex);
            
            %Processing according to different PDU type
            if 0 == simDlPduS.pduType && u == simDlPduS.simPdcchPduS.SubcarrierSpacing && cp == simDlPduS.simPdcchPduS.CyclicPrefix %PDCCH
                %Set flag of Grid & CP existing
                exitFlag = 1;

                %Fetch PDCCH config
                simPdcchPduS = simDlPduS.simPdcchPduS;
    
                %% PDCCH frequency data generation
                [dataGrid, simDlRefInputS] = gi_nrPhySimDlTxPdcchGen(simDlTxGridInterS, simPdcchPduS, slot, dataGrid, simDlRefInputS);
            elseif 1 == simDlPduS.pduType && u == simDlPduS.simPdschPduS.SubcarrierSpacing && cp == simDlPduS.simPdschPduS.CyclicPrefix %PDSCH
                %Set flag of Grid & CP existing
                exitFlag = 1;

                %Fetch PDSCH config, UE TB record
                simPdschPduS = simDlPduS.simPdschPduS;
    
                %UE TB record
                if 1 == simPdschPduS.NrOfCodewords
                    pdschUeCw1Record = pdschCw1Record{simPdschPduS.userIndex + 1, simPdschPduS.simPdschCwS(1).harqProcessID + 1}; %+ 1 for matlab index
                    pdschUeCw2Record = [];
                elseif 2 == simPdschPduS.NrOfCodewords
                    pdschUeCw1Record = pdschCw1Record{simPdschPduS.userIndex + 1, simPdschPduS.simPdschCwS(1).harqProcessID + 1}; %+ 1 for matlab index
                    pdschUeCw2Record = pdschCw2Record{simPdschPduS.userIndex + 1, simPdschPduS.simPdschCwS(2).harqProcessID + 1};                 
                else
                    error('Wrong NrOfCodewords = %d!!!', simPdschPduS.NrOfCodewords);                
                end
    
                %% PDSCH Tb generation
                [pdschCw1Source, pdschCw2Source] = gi_nrPhySimDlTxPdschTbGen(simPdschPduS);
    
                %% PDSCH frequency data generation
                [dataGrid, simDlRefInputS, pdschUeCw1Record, pdschUeCw2Record] =...
                    gi_nrPhySimDlTxPdschGen(pdschCw1Source, pdschCw2Source, simDlTxGridInterS, simPdschPduS, simUlTxCsiRsInterS, simDlSortSlotS.nPDUsOfCsiRs,...
                                            slot, dataGrid, simDlRefInputS, pdschUeCw1Record, pdschUeCw2Record);
    
                %Update TB bits record
                if 1 == simPdschPduS.NrOfCodewords
                    pdschCw1Record{simPdschPduS.userIndex + 1, simPdschPduS.simPdschCwS(1).harqProcessID + 1} = pdschUeCw1Record; %+ 1 for matlab index
                elseif 2 == simPdschPduS.NrOfCodewords
                    pdschCw1Record{simPdschPduS.userIndex + 1, simPdschPduS.simPdschCwS(1).harqProcessID + 1} = pdschUeCw1Record; %+ 1 for matlab index
                    pdschCw2Record{simPdschPduS.userIndex + 1, simPdschPduS.simPdschCwS(2).harqProcessID + 1} = pdschUeCw2Record;                 
                else
                    error('Wrong NrOfCodewords = %d!!!', simPdschPduS.NrOfCodewords);                
                end
            elseif 2 == simDlPduS.pduType && u == simDlPduS.simCsiRsPduS.SubcarrierSpacing && cp == simDlPduS.simCsiRsPduS.CyclicPrefix %CSI-RS
                %Set flag of Grid & CP existing
                exitFlag = 1;

                %Fetch PDU config
                simCsiRsPduS = simDlPduS.simCsiRsPduS;
    
                %% CSI-RS frequency data generation
                [dataGrid, simUlTxCsiRsInterS, simDlRefInputS] = gi_nrPhySimDlTxCsiRsGen(simDlTxGridInterS, simCsiRsPduS, SFN, slot, dataGrid, simDlRefInputS);
            elseif 3 == simDlPduS.pduType && u == simDlPduS.simSsbPduS.SubcarrierSpacing && cp == 0 %SSB ??Must be normal CP??
                %Set flag of Grid & CP existing
                exitFlag = 1;

                %Fetch PDU config
                simSsbPduS = simDlPduS.simSsbPduS;
    
                %% PBCH source bits generation
                [pbchTbSource] = gi_nrPhySimDlTxPbchTbGen(GI_NR_PHY_SIM_PBCH_MIB_SIZE);
    
                %% SSB frequency data generation
                [dataGridSsb, simDlRefInputS] = gi_nrPhySimDlTxSsbGen(pbchTbSource, simSysS, simSsbPduS, SFN, slot, dataGridSsb, simDlRefInputS);          
            else
                %Do nothing;
            end %if, simDlPduS.pduType
        end %for, pduIdx
    
        %% Generate simDlRefInput.mat, dlTxDataFreq.bin, locating in this position due to case for TX reference usually has 1 slot. 
        if 1 == GI_NR_PHY_SIM_DL_REF_INPUT_PARAM && 1 == exitFlag
            %Generate address
            resourceAddr = sprintf('%s%s', caseAddr, '\Resource\');
            refInputAddr = sprintf('%s%s%s%d%s%d%s', resourceAddr, 'simDlRefInput', 'Grid', u, 'Cp', cp, '.mat');

            %Save config file
            save(refInputAddr, 'simDlRefInputS');
    
            %Save SSB data file
%             [mantissa, exp] = gi_utilsNorm(dataGridSsb, [1, 1, length(dataGridSsb(:))], [1, 0, 15]);
%             gi_utilsWriteBin(resourceAddr, 'dlTxSsbDataFreq', 'Grid', u, 'Cp', cp, mantissa, 5, 0, [1, 0, 15]); 
%             gi_utilsWriteBin(resourceAddr, 'dlTxSsbDataFreqExp', 'Grid', u, 'Cp', cp, exp, 2, 0, [1, 31, 0]);        
            
            %Save data file
            [mantissa, exp] = gi_utilsNorm(dataGrid, [1, 1, length(dataGrid(:))], [1, 0, 15]);
            gi_utilsWriteBin(resourceAddr, 'dlTxDataFreq', 'Grid', u, 'Cp', cp, mantissa, 5, 0, [1, 0, 15]); 
            gi_utilsWriteBin(resourceAddr, 'dlTxDataFreqExp', 'Grid', u, 'Cp', cp, exp, 2, 0, [1, 31, 0]);
        end
    
        %IFFT and accumulation in time domain
        if 1 == exitFlag
            %% IFFT + CP, half SC offset recovering in time domain 
%             [dataTimeSsb] = gi_nrPhySimDlTxSsbTimeDataGen(dataGridSsb, simDlTxSysInterS.numFftPoint, simDlTxSysInterS.scs, simDlTxSysInterS.sampleRate,...
%                                                           simDlTxSysInterS.slotInterval, simDlTxSysInterS.timeLenSlot, slot, numTxAnt,...
%                                                           simDlTxGridInterS.numScGrid, simDlTxGridInterS.numSymSlot, simDlTxGridInterS.numFftPoint,...
%                                                           simDlTxGridInterS.cpSymType, simDlTxGridInterS.cpLenLong, simDlTxGridInterS.cpLenShort,...
%                                                           simDlTxGridInterS.guardband, simDlTxGridInterS.scs, simDlTxGridInterS.sampleRate,...
%                                                           simDlTxGridInterS.slotInterval, simDlTxGridInterS.timeLenSlot, simDlRefInputS.ssbHalfScOffset);
        
            %% Time data generation, IFFT + CP
            [dataTimeScs] = gi_nrPhySimTxTimeDataGen(dataGrid, simDlTxSysInterS.numFftPoint, simDlTxSysInterS.scs, simDlTxSysInterS.sampleRate,...
                                                     simDlTxSysInterS.slotInterval, simDlTxSysInterS.timeLenSlot, slot, numTxAnt,... 
                                                     simDlTxGridInterS.numScGrid, simDlTxGridInterS.numSymSlot, simDlTxGridInterS.numFftPoint,...
                                                     simDlTxGridInterS.cpSymType, simDlTxGridInterS.cpLenLong, simDlTxGridInterS.cpLenShort,...
                                                     simDlTxGridInterS.guardband, simDlTxGridInterS.scs, simDlTxGridInterS.sampleRate,...
                                                     simDlTxGridInterS.slotInterval, simDlTxGridInterS.timeLenSlot);
        
    
            %Combine grid data to system data
            if ~exist('dataTime', 'var')
%                 dataTime = dataTimeScs + dataTimeSsb;
                dataTime = dataTimeScs;
            else
                dataTime = dataTime + dataTimeScs + dataTimeSsb;
            end
        end %if, exitFlag
    end %for, cp
end %for, u

end %gi_nrPhySimUlTxSignalGen()