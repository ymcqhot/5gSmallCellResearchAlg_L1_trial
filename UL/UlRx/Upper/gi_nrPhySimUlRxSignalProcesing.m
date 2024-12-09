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
% File           gi_nrPhySimUlRxSignalProcesing.m
%
% Description    Wrapper of UL RX signal generation
%
% -------------------------------------------------------------------------------
%
% Change log
%
% Date          Author       Action
%
% 2022.04.07    Mian Yang    Changed 
% 2022.05.28    Mian Yang    Changed
%
% -------------------------------------------------------------------------------
%

%% gi_nrPhySimUlRxSignalProcesing
% -------------------------------------------------------------------------------
%
% *gi_nrPhySimUlRxSignalProcesing* - Wrapper of UL RX signal processing
%
% -------------------------------------------------------------------------------
%
% *dataChanNI* - Data with interference and noise
%
% Param [In]   
%
% Format is [timeLenSlot, numRxAnt], complex, float.
%
% *simUlRxSysInterS* - gi_nrPhySimUlRxSysInter_s
%
% Param [In]   
%
% Format is [1], struct.
%
% *fapiUlSlotS* - gi_nrPhyFapiUl_s
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
% *snrIdx* - Index of SNR, starting from 1
%
% Param [In]   
%
% Format is [1], integer.
%
% *simUlRxPuschSnrMetricS* - gi_nrPhySimUlRxPuschSnrMetric_s
%
% Param [Out]    
%
% Format is [1], struct.
%
% *simUlRxPucchSnrMetricS* - gi_nrPhySimUlRxPucchSnrMetric_s
%
% Param [Out]    
%
% Format is [1], struct.
%
% *SFN* - SFN updated
%
% Param [Out]   
%
% Format is [1], integer.
%
% *slot* - Slot number updated
%
% Param [Out]   
%
% Format is [1], integer.
%
% *puschLlrCombine* - LLR after HARQ combine
%
% Param [Inout]    
%
% Format is [GI_NR_PHY_SIM_ATTACH_UE, GI_NR_PHY_SIM_PUSCH_NUM_HARQ, GI_NR_PHY_SIM_PUSCH_NUM_CB, GI_NR_PHY_SIM_PUSCH_CB_LDPC_SIZE], float.
%
% -------------------------------------------------------------------------------
%
function [simUlRxPuschSnrMetricS, simUlRxPucchSnrMetricS, SFN, slot, puschLlrCombine] =...
    gi_nrPhySimUlRxSignalProcesing(dataChanNI, simUlRxSysInterS, fapiUlSlotS, repeatIdx, numSlot, snrIdx, puschLlrCombine)

%% Declare struct;
gi_nrPhySimStructDefine;

%% Parameter check
%Unnecessary to check

%% Collect all PUCCH PDUs
%Initialize pucchPduIndex
pucchPduIndex = 1;

%PDU loop
for pduIdx = 1:fapiUlSlotS.uint16_nPDUs
    %Fetch fapi PDU
    fapiUlPduU = fapiUlSlotS.fapiUlPduU(pduIdx);

    %Pick up PUCCH
    if 2 == fapiUlPduU.uint16_pduType
        %First PDU need create allPucchPduS
        if 1 == pucchPduIndex
            allPucchPduS = fapiUlPduU.fapiPucchPduS;
        else
            allPucchPduS(pucchPduIndex) = fapiUlPduU.fapiPucchPduS;
        end

        %pucchPduIndex increase
        pucchPduIndex = pucchPduIndex + 1;
    end %if, uint16_pduType
end %for, pduIdx

%Grid loop, u for FR1
for u = 1 %Only support 30kHz, normal CP
    %Update the SFN and Slot number each slot
    [SFN, slot] = gi_nrPhySimSfnAndSlotUpdate(repeatIdx, numSlot, u, 0, fapiUlSlotS.uint16_SFN, fapiUlSlotS.uint16_Slot);

    %% Grid level parameter calculation
    [simUlRxGridInterS] = gi_nrPhySimUlRxGridParamParser(simUlRxSysInterS, u, 0);    

    %% Remove CP + FFT
    [dataGridRx] = gi_nrPhySimUlRxFreqDataGen(dataChanNI, simUlRxSysInterS.numFftPoint, simUlRxSysInterS.scs, simUlRxSysInterS.sampleRate,...
                                              simUlRxSysInterS.slotInterval, simUlRxSysInterS.timeLenSlot, slot, simUlRxSysInterS.numRxAnt,...
                                              simUlRxGridInterS.numScGrid, simUlRxGridInterS.numSymSlot, simUlRxGridInterS.numFftPoint,...
                                              simUlRxGridInterS.cpSymType, simUlRxGridInterS.cpLenLong, simUlRxGridInterS.cpLenShort,...
                                              simUlRxGridInterS.guardband, simUlRxGridInterS.scs, simUlRxGridInterS.sampleRate,...
                                              simUlRxGridInterS.slotInterval, simUlRxGridInterS.timeLenSlot);

    %PDU loop
    for pduIdx = 1:fapiUlSlotS.uint16_nPDUs
        %Fetch fapi PDU
        fapiUlPduU = fapiUlSlotS.fapiUlPduU(pduIdx);
    
        %Processing according to different PDU type
        if 0 == fapiUlPduU.uint16_pduType && u == fapiUlPduU.fapiPrachPduS.uint8_subcarrierSpacing && 0 == fapiUlPduU.fapiPrachPduS.uint8_cyclicPrefix %PRACH
            %
        elseif 1 == fapiUlPduU.uint16_pduType && u == fapiUlPduU.fapiPuschPduS.uint8_subcarrierSpacing && 0 == fapiUlPduU.fapiPuschPduS.uint8_cyclicPrefix %PUSCH
            %Fetch fapi PDU config, UE HARQ LLR
            fapiPuschPduS = fapiUlPduU.fapiPuschPduS;
            puschUeLlrCombine = puschLlrCombine{snrIdx, fapiPuschPduS.uint16_userId + 1, fapiPuschPduS.uint8_harqProcessID + 1}; %+ 1 for matlab index

            %% PUSCH data processing
            [simUlRxPuschMetricS, puschUeLlrCombine] = gi_nrPhySimUlRxPuschProcessing(dataGridRx, simUlRxSysInterS, simUlRxGridInterS, fapiPuschPduS, slot,...
                                                                                      puschUeLlrCombine);

            %Update HARQ LLR
            puschLlrCombine{snrIdx, fapiPuschPduS.uint16_userId + 1, fapiPuschPduS.uint8_harqProcessID + 1} = puschUeLlrCombine; %+ 1 for matlab index

            %% Evaluate to gi_nrPhySimUlRxPuschSnrMetric_s
            gi_nrPhySimUlRxPuschSnrMetric_s.numPusch = gi_nrPhySimUlRxPuschSnrMetric_s.numPusch + 1;
            gi_nrPhySimUlRxPuschSnrMetric_s.simUlRxPuschMetricS(pduIdx) = simUlRxPuschMetricS;
        elseif 2 == fapiUlPduU.uint16_pduType && u == fapiUlPduU.fapiPucchPduS.uint8_subcarrierSpacing && 0 == fapiUlPduU.fapiPucchPduS.uint8_cyclicPrefix %PUCCH
            %Fetch fapi PDU config
            fapiPucchPduS = fapiUlPduU.fapiPucchPduS;

            %% Remove current PUCCH PDU
            for pucchIdx = 1:length(allPucchPduS)
                %Fetch fapi PDU from allPucchPduS
                otherPucchPduS = allPucchPduS(pucchIdx); 

                %Judge if it is same PDU with current PDU
                if otherPucchPduS.uint16_pduOrder == fapiPucchPduS.uint16_pduOrder
                    allPucchPduS(pucchIdx) = [];    
                end %if, uint16_pduOrder
            end %for, pduIdx

            %% PUCCH data processing
            [simUlRxPucchMetricS] = gi_nrPhySimUlRxPucchProcessing(dataGridRx, simUlRxSysInterS, simUlRxGridInterS, fapiPucchPduS, allPucchPduS, slot);

            %% Evaluate to  gi_nrPhySimUlRxPucchSnrMetric_s
            gi_nrPhySimUlRxPucchSnrMetric_s.numPucch = gi_nrPhySimUlRxPucchSnrMetric_s.numPucch + 1;
            gi_nrPhySimUlRxPucchSnrMetric_s.simUlRxPucchMetricS(pduIdx) = simUlRxPucchMetricS;
        elseif 3 == fapiUlPduU.uint16_pduType && u == fapiUlPduU.fapiSrsPduS.uint8_subcarrierSpacing && 0 == fapiUlPduU.fapiSrsPduS.uint8_cyclicPrefix %SRS
            %       
        else
            %Do nothing;
        end %if, fapiUlPdu.uint16_pduType
        
        %% Indication
    
    end %pduIdx
end %for, u

%Evaluate to simUlRxPuschSnrMetricS, simUlRxPucchSnrMetricS
simUlRxPuschSnrMetricS = gi_nrPhySimUlRxPuschSnrMetric_s;
simUlRxPucchSnrMetricS = gi_nrPhySimUlRxPucchSnrMetric_s;

end %gi_nrPhySimUlRxSignalProcesing()