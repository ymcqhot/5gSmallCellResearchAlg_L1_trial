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
% File           gi_nrPhySimDlTxPdcchGen.m
%
% Description    DL TX PDCCH signal generation
%
% -------------------------------------------------------------------------------
%
% Change log
%
% Date          Author       Action
%
% 2023.06.26    Mian Yang    Created 
%
% -------------------------------------------------------------------------------
%

%% gi_nrPhySimDlTxPdcchGen
% -------------------------------------------------------------------------------
%
% *gi_nrPhySimDlTxPdcchGen* - DL TX PDCCH signal generation
%
% -------------------------------------------------------------------------------
%
% *simDlTxGridInterS* - gi_nrPhySimDlTxGridInter_s
%
% Param [In]    
%
% Format is [1], struct.
%
% *simPdcchPduS* - gi_nrPhySimPdcchPdu_s
%
% Param [In]    
%
% Format is [1], struct.
%
% *slot* - Slot number of processing slot
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
% *simDlRefInputS* - gi_nrPhySimDlTxRefInput_s
%
% Param [Inout]    
%
% Format is [1], struct.
%
% -------------------------------------------------------------------------------
%
function [dataGrid, simDlRefInputS] = gi_nrPhySimDlTxPdcchGen(simDlTxGridInterS, simPdcchPduS, slot, dataGrid, simDlRefInputS)

%% Declare macro
gi_nrPhySimMacroDefine;

%% Parameter check
%Unnecessary to check

%% Coreset parameter calculation
[simDlTxCoresetInterS] = gi_nrPhySimDlTxCoresetParamParser(simPdcchPduS);

%% Input parameter for reference generation
if 1 == GI_NR_PHY_SIM_DL_REF_INPUT_PARAM
   [simDlRefInputS] = gi_nrPhySimDlTxCoresetRefInputParam(simPdcchPduS, simDlRefInputS);
end

%% DMRS sequence generation
[pdcchDmrsSeq] = gi_nrPhySimDlTxPdcchDmrsSeqGen(slot, simDlTxGridInterS.numSymSlot, simDlTxCoresetInterS.numSymCoreset,...
                                                simDlTxCoresetInterS.symIndexCoreset, simPdcchPduS.nIdPdcch,...
                                                simDlTxCoresetInterS.minScOffsetDmrsCoresetRefPoint, simDlTxCoresetInterS.numScDmrsAcrossCoreset);

%% DMRS mapping to coreset, betaPdcchDmrs = 1
if 1 == simPdcchPduS.precoderGranularity
    [dataGrid] = gi_nrPhySimDlTxPdcchDmrsMap(pdcchDmrsSeq, simDlTxCoresetInterS.numSymCoreset, simDlTxCoresetInterS.symIndexCoreset,...
                                             simDlTxCoresetInterS.numRbCoreset, simDlTxCoresetInterS.rbIndexCoreset, simDlTxCoresetInterS.rbIndexCoreset, 1,...
                                             dataGrid);
end

%% DCI data generation
for dciIdx = 1:simPdcchPduS.numDlDci
    [dataGrid, simDlRefInputS] = gi_nrPhySimDlTxDciGen(pdcchDmrsSeq, simPdcchPduS, simDlTxCoresetInterS, simPdcchPduS.simDlDci(dciIdx), slot, dataGrid,...
                                                       simDlRefInputS);
end

end %gi_nrPhySimDlTxPdcchGen()