%%
% ------------------------------------------------------------------------------
%
%                     ©Copyright GiRive Institute 2022                      
%
%      The software herein is furnished under license and may be used         
%
%      or copied only in accordance with the terms of such license.
%
% -------------------------------------------------------------------------------
%
% File           gi_nrPhySimUlTxSignalGen.m
%
% Description    Wrapper of UL TX signal generation
%
% -------------------------------------------------------------------------------
%
% Change log
%
% Date          Author       Action
%
% 2022.01.20    Mian Yang    Created 
% 2022.05.28    Mian Yang    Changed
%
% -------------------------------------------------------------------------------
%

%% gi_nrPhySimUlTxSignalGen
% -------------------------------------------------------------------------------
%
% *gi_nrPhySimUlTxSignalGen* - Wrapper of TX signal generation
%
% -------------------------------------------------------------------------------
%
% *simSysS* - gi_nrPhySimSys_s
%
% Param [In]   
%
% Format is [1], struct.
%
% *simUlTxSysInterS* - gi_nrPhySimUlTxSysInter_s
%
% Param [In]   
%
% Format is [1], struct.
%
% *simUlSortSlotS* - gi_nrPhySimUlSort_s
%
% Param [Out]    
%
% Format is [1], struct.
%
% *simUlChanS* - gi_nrPhySimUlChan_s
%
% Param [In]   
%
% Format is [numUe], struct.
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
% *pucchAllAckFlag* - Flag for PUCCH sending all ACK
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
% *dataChan* - Time data applying channel 
%
% Param [Out]    
%
% Format is [timeLenSlot, numRxAnt], complex, float.
%
% *puschTbRecord* - TB bit record for retransmission
%
% Param [Inout]    
%
% Format is [GI_NR_PHY_SIM_ATTACH_UE, GI_NR_PHY_SIM_PUSCH_NUM_HARQ, GI_NR_PHY_SIM_PUSCH_TB_SIZE], bit stream.
%
% *pucchPart1TbRecord* - PUCCH part1 information record
%
% Param [Inout]    
%
% Format is [GI_NR_PHY_SIM_ATTACH_UE, GI_NR_PHY_SIM_PUCCH_TB_SIZE], bit stream.
%
% *pucchPart2TbRecord* - PUCCH part2 information record
%
% Param [Inout]    
%
% Format is [GI_NR_PHY_SIM_ATTACH_UE, GI_NR_PHY_SIM_PUCCH_TB_SIZE], bit stream.
%
% *pucchDTXsentRecord* - Indication of DTX sent
%
% Param [Inout]    
%
% Format is [GI_NR_PHY_SIM_ATTACH_UE], integer.
%
% -------------------------------------------------------------------------------
%
function [dataChan, puschTbRecord, pucchPart1TbRecord, pucchPart2TbRecord, pucchDTXsentRecord] =...
    gi_nrPhySimUlTxSignalGen(simSysS, simUlTxSysInterS, simUlSortSlotS, simUlChanS, repeatIdx, numSlot, pucchAllAckFlag, caseAddr, puschTbRecord,...
                             pucchPart1TbRecord, pucchPart2TbRecord, pucchDTXsentRecord)

%% Declare macro
gi_nrPhySimMacroDefine;

%% Declare struct;
gi_nrPhySimStructDefine;

%% Parameter check
%Unnecessary to check

%User loop
for userIdx = 1:simUlSortSlotS.numUser
    %Fetch parameters
    numPdu = simUlSortSlotS.simUlUeS(userIdx).nPDUs;
    userIndex = simUlSortSlotS.simUlUeS(userIdx).userIndex;
    nrOfPorts = simUlSortSlotS.simUlUeS(userIdx).nrOfPorts;

    %Update the SFN and Slot number each slot
    [SFN, slot] = gi_nrPhySimSfnAndSlotUpdate(repeatIdx, numSlot, simUlSortSlotS.simUlUeS(userIdx).subcarrierSpacing,...
                                              simUlSortSlotS.simUlUeS(userIdx).cyclicPrefix, simUlSortSlotS.SFN, simUlSortSlotS.Slot);

    %% UE parameter calculation
    [simUlTxUeInterS] = gi_nrPhySimUlTxUeParamParser(simSysS, simUlSortSlotS.simUlUeS(userIdx));

    %% Input parameter for reference generation, UE part
    if 1 == GI_NR_PHY_SIM_UL_REF_INPUT_PARAM
        [simUlRefInputS] = gi_nrPhySimUlTxUeRefInputParam(simSysS, simUlSortSlotS.simUlUeS(userIdx), simUlTxUeInterS, slot);
    else
        simUlRefInputS = gi_nrPhySimUlTxRefInput_s;
    end

    %Initialize dataGrid of each user
    dataGrid = zeros(simUlTxUeInterS.numScGrid, simUlTxUeInterS.numSymSlot, GI_NR_PHY_SIM_UL_NUM_PORT); %Accroding to MALAB habit
    
    %PDU loop in one user
    for pduIdx = 1:numPdu
        %Fetch PDU
        simPduU = simUlSortSlotS.simUlUeS(userIdx).simPduU(pduIdx);
        
        %Processing according to different PDU type
        switch simPduU.pduType
            case 0 %PRACH
                %
            case 1 %PUSCH
                %Fetch PDU config, UE TB record
                simPuschPduS = simPduU.simPuschPduS;
                puschUeTbRecord = puschTbRecord{simPuschPduS.userIndex + 1, simPuschPduS.harqProcessID + 1}; %+ 1 for matlab index

                %% PUSCH Tb generation
                [puschTbSource] = gi_nrPhySimUlTxPuschTbGen(simPuschPduS.payloadSize);
                
                %% PUSCH frequency data generation
                [dataGrid, simUlRefInputS, puschUeTbRecord] = gi_nrPhySimUlTxPuschGen(puschTbSource, simUlTxUeInterS, simPuschPduS, slot, dataGrid,...
                                                                                      simUlRefInputS, puschUeTbRecord);

                %Update TB bit record
                puschTbRecord{simPuschPduS.userIndex + 1, simPuschPduS.harqProcessID + 1} = puschUeTbRecord;
            case 2 %PUCCH
                %Fetch PDU config
                simPucchPduS = simPduU.simPucchPduS;

                %% PUCCH payload generation
                [pucchPart1TbSource, pucchPart2TbSource] = gi_nrPhySimUlTxPucchTbGen(slot, simPucchPduS.BitLenHarq, simPucchPduS.SRFlag,...
                                                                                     simPucchPduS.BitLenSr, simPucchPduS.csiPart1BitLength,...
                                                                                     simPucchPduS.csiPart2BitLength, pucchAllAckFlag);

                %% PUCCH frequency data generation
                if ~isfield(simPucchPduS, 'DTX') || (isfield(simPucchPduS, 'DTX') && 0 == simPucchPduS.DTX ) %Consider situation of PUCCH DTX
                    [dataGrid, simUlRefInputS] = gi_nrPhySimUlTxPucchGen(pucchPart1TbSource, pucchPart2TbSource, simUlTxUeInterS, simPucchPduS, slot,...
                                                                         dataGrid, simUlRefInputS);      
                end

                %Update TB bit record, DTX sent
                pucchPart1TbRecord{simPucchPduS.userIndex + 1} = pucchPart1TbSource;
                pucchPart2TbRecord{simPucchPduS.userIndex + 1} = pucchPart2TbSource;
                pucchDTXsentRecord(simPucchPduS.userIndex + 1) = simPucchPduS.DTX;
            case 3 %SRS
                %         
            otherwise
                error('Wrong pduType = %d!!!', simPduU.pduType);
        end %switch, simPduU.pduType
    end %for, pduIdx

    %% Generate simUlRefInput.mat, ulTxDataFreq.bin, locating in this position due to case for TX reference usually has 1 slot. 
    if 1 == GI_NR_PHY_SIM_UL_REF_INPUT_PARAM
        %Generate address
        resourceAddr = sprintf('%s%s', caseAddr, '\Resource\');
        refInputAddr = sprintf('%s%s%s%d%s', resourceAddr, 'simUlRefInput', 'User', userIndex, '.mat');
        
        %Save config file
        save(refInputAddr, 'simUlRefInputS');
        
        %Save data file
        [mantissa, exp] = gi_utilsNorm(dataGrid, [1, 1, length(dataGrid(:))], [1, 0, 15]);
        gi_utilsWriteBin(resourceAddr, 'ulTxDataFreq', 'User', userIndex, mantissa, 5, 0, [1, 0, 15]); 
        gi_utilsWriteBin(resourceAddr, 'ulTxDataFreqExp', 'User', userIndex, exp, 2, 0, [1, 31, 0]);
    end
    
    %% Time data generation, IFFT + CP
    [dataTime] = gi_nrPhySimTxTimeDataGen(dataGrid, simUlTxSysInterS.numFftPoint, simUlTxSysInterS.scs, simUlTxSysInterS.sampleRate,...
                                          simUlTxSysInterS.slotInterval, simUlTxSysInterS.timeLenSlot, slot, nrOfPorts, simUlTxUeInterS.numScGrid,...
                                          simUlTxUeInterS.numSymSlot, simUlTxUeInterS.numFftPoint, simUlTxUeInterS.cpSymType, simUlTxUeInterS.cpLenLong,...
                                          simUlTxUeInterS.cpLenShort, simUlTxUeInterS.guardband, simUlTxUeInterS.scs, simUlTxUeInterS.sampleRate,...
                                          simUlTxUeInterS.slotInterval, simUlTxUeInterS.timeLenSlot);

    %% Channel applying, TDL, TO, FO
    [dataChanUe] = gi_nrPhySimUlTxChannelApply(dataTime, simUlChanS(userIdx), nrOfPorts, simSysS.numRxAnt, simUlTxSysInterS.sampleRate);

    %Combine UE data to system data
    if 1 == userIdx %First user
        dataChan = dataChanUe;
    else
        dataChan = dataChan + dataChanUe;
    end
end %for, userIdx

end %gi_nrPhySimUlTxSignalGen()