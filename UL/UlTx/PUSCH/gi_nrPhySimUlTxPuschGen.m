%%
% ------------------------------------------------------------------------------
%
%                     ©Copyright GiRive Institute 2021                      
%
%      The software herein is furnished under license and may be used         
%
%      or copied only in accordance with the terms of such license.
%
% -------------------------------------------------------------------------------
%
% File           gi_nrPhySimUlTxPuschGen.m
%
% Description    UL TX PUSCH signal generation
%
% -------------------------------------------------------------------------------
%
% Change log
%
% Date          Author       Action
%
% 2021.09.16    Yi He        Created 
% 2021.11.03    Mian Yang    Changed 
% 2022.05.28    Mian Yang    Changed
%
% -------------------------------------------------------------------------------
%

%% gi_nrPhySimUlTxPuschGen
% -------------------------------------------------------------------------------
%
% *gi_nrPhySimUlTxPuschGen* - UL TX PUSCH generation
%
% -------------------------------------------------------------------------------
%
% *puschTbSource* - TB bit
%
% Param [In]    
%
% Format is [tbSize], bit stream.
%
% *simUlTxUeInterS* - gi_nrPhySimUlTxUeInter_s
%
% Param [In]    
%
% Format is [1], struct.
%
% *simPuschPduS* - gi_nrPhySimPuschPdu_s
%
% Param [In]    
%
% Format is [1], struct.
%
% *slot* - Slot number of processing slot.
%
% Param [In]    
%
% Format is [1], integer.
%
% *dataGrid* - Whole data grid
%
% Param [Inout]    
%
% Format is [numScGrid, numSymSlot, nrOfPorts], complex, float.
%
% *simUlRefInputS* - gi_nrPhySimUlTxRefInput_s
%
% Param [Inout]    
%
% Format is [1], struct.
%
% *puschUeTbRecord* - UE TB bits record for retransmission
%
% Param [Inout]    
%
% Format is [tbSize], bit stream.
%
% -------------------------------------------------------------------------------
%
function [dataGrid, simUlRefInputS, puschUeTbRecord] = gi_nrPhySimUlTxPuschGen(puschTbSource, simUlTxUeInterS, simPuschPduS, slot, dataGrid, simUlRefInputS,...
                                                                               puschUeTbRecord)
%% Declare macro
gi_nrPhySimMacroDefine;

%% Parameter check
%Unnecessary to check

%% Parameters parser
[simUlTxPuschInterS] = gi_nrPhySimUlTxPuschParamParser(simPuschPduS, simUlTxUeInterS.gridSize);

%% Input parameter for reference generation
if 1 == GI_NR_PHY_SIM_UL_REF_INPUT_PARAM
    [simUlRefInputS] = gi_nrPhySimUlTxPuschRefInputParam(simPuschPduS, simUlTxPuschInterS, simUlRefInputS);
end

%% DMRS sequence generation
[puschDmrsSeqInit] = gi_nrPhySimUlTxPuschDmrsSeqGen(simUlTxPuschInterS.numDmrsPort, simUlTxPuschInterS.numSymDmrsSlot, simUlTxPuschInterS.dmrsSymIndex,...
                                                    simUlTxPuschInterS.scOffsetDmrsSym, simUlTxPuschInterS.numScDmrsSym, slot, simUlTxUeInterS.numSymSlot,...
                                                    simUlTxPuschInterS.nScidBar, simUlTxPuschInterS.puschDmrsScramblingIdBar, simUlTxPuschInterS.cdmGroupBar);
                                                
%% DMRS orthogonalization                                             
[puschDmrsSeqOrthogonal] = gi_nrPhySimUlTxPuschDmrsOrthogonal(puschDmrsSeqInit, simUlTxPuschInterS.numDmrsPort, simUlTxPuschInterS.numSymDmrsSlot,... 
                                                              simUlTxPuschInterS.numScDmrsSym, simUlTxPuschInterS.dmrsDuration,...
                                                              simUlTxPuschInterS.timeOrthogonalCode, simUlTxPuschInterS.freqOrthogonalCode);

%% DMRS pre-mapping
[puschDmrsPreMapping] = gi_nrPhySimUlTxPuschDmrsPreMap(puschDmrsSeqOrthogonal, simUlTxPuschInterS.numDmrsPort, simUlTxPuschInterS.deltaScDmrs,...
                                                       simUlTxPuschInterS.numSymDmrsSlot, simUlTxPuschInterS.numScSym,...
                                                       simUlTxPuschInterS.numDmrsMappingGranularity, simUlTxPuschInterS.dmrsMappingGranularity,...
                                                       simUlTxPuschInterS.dmrsMappingIntervalScGroup);
                                                   
%% DMRS precoding
[puschDmrsPreCoding] = gi_nrPhySimUlTxPuschDmrsPrecode(puschDmrsPreMapping, simUlTxPuschInterS.numSymDmrsSlot, simUlTxPuschInterS.numScSym,...
                                                       simPuschPduS.nrOfPorts, simUlTxPuschInterS.betaDmrs, simUlTxPuschInterS.precodingMatrix);
                                                   
%% DMRS mapping
[dataGrid] = gi_nrPhySimUlTxPuschDmrsMap(puschDmrsPreCoding, simPuschPduS.nrOfPorts, simUlTxPuschInterS.numSymDmrsSlot, simUlTxPuschInterS.dmrsSymIndex,...
                                         simUlTxPuschInterS.scOffsetSym, simUlTxPuschInterS.numScSym, dataGrid);
                                     
%% Data encoding
[puschTbRatematch, puschUeTbRecord] = gi_nrPhySimUlTxPuschDataEncode(puschTbSource, simUlTxPuschInterS.newData, simUlTxPuschInterS.tbCrcLen,...
                                                                     simUlTxPuschInterS.numCb, simUlTxPuschInterS.Kinit, simUlTxPuschInterS.cbCrcLen,...
                                                                     simUlTxPuschInterS.K, simUlTxPuschInterS.N, simUlTxPuschInterS.ldpcBaseGraph,...
                                                                     simUlTxPuschInterS.Zc, simUlTxPuschInterS.ErFloor, simUlTxPuschInterS.ErCeil,...
                                                                     simUlTxPuschInterS.numCbFloor, simUlTxPuschInterS.numCbCeil, simUlTxPuschInterS.rvK0,...
                                                                     simUlTxPuschInterS.Qm, simUlTxPuschInterS.G, puschUeTbRecord);
                                                
%% Data scrambling
[puschTbScrambling] = gi_nrPhySimUlTxPuschDataScramble(puschTbRatematch, simPuschPduS.RNTI, simPuschPduS.nIdPusch, simUlTxPuschInterS.G);

%% Data modulation
[puschDataModulation] = gi_nrPhySimUlTxPuschDataMod(puschTbScrambling, simUlTxPuschInterS.numSymModulation, simUlTxPuschInterS.Qm);
                                                
%% Data layer mapping
[puschDataLayerMapping] = gi_nrPhySimUlTxPuschDataLayerMap(puschDataModulation, simPuschPduS.nrOfLayers, simUlTxPuschInterS.numSymLayer);

%% Data precoding
[puschDataPrecoding] = gi_nrPhySimUlTxPuschDataPrecode(puschDataLayerMapping, simPuschPduS.nrOfLayers, simPuschPduS.nrOfPorts,...
                                                       simUlTxPuschInterS.precodingMatrix);
                                                   
%% Data mapping                                              
[dataGrid] = gi_nrPhySimUlTxPuschDataMap(puschDataPrecoding, simPuschPduS.nrOfPorts, simUlTxUeInterS.numSymSlot, simUlTxPuschInterS.dataSymIndex,...
                                         simUlTxPuschInterS.dmrsSymIndex, simUlTxPuschInterS.scOffsetSym, simUlTxPuschInterS.numScSym,...
                                         simUlTxPuschInterS.numDataScDmrsSym, simUlTxPuschInterS.numCdmGroupPusch, simUlTxPuschInterS.deltaScPusch,...
                                         simUlTxPuschInterS.numDmrsMappingGranularity, simUlTxPuschInterS.dmrsMappingGranularity,...
                                         simUlTxPuschInterS.dmrsMappingIntervalScGroup, dataGrid);         
                                     
end %gi_nrPhySimUlTxPuschProc()