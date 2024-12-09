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
% File           gi_nrPhySimMacroDefine.m
%
% Description    The Macro definition.
%
% -------------------------------------------------------------------------------
%
% Change log
%
% Date          Author       Action
%
% 2021.08.24    Yi He        Created 
% 2022.05.27    Mian Yang    Changed
%
% -------------------------------------------------------------------------------
%

%% Macro of control
GI_NR_PHY_SIM_UL_REF_INPUT_PARAM = 0;
GI_NR_PHY_SIM_DL_REF_INPUT_PARAM = 0;
GI_NR_PHY_SIM_UL_SIMULATION = 0;

%% Macro of Simulation
GI_NR_PHY_SIM_NUM_SNR = 40;

%% Macro of UE
GI_NR_PHY_SIM_UL_PUSCH_NUM_PDU = 16;
GI_NR_PHY_SIM_UL_PUCCH_NUM_PDU = 16; %Temp value;
GI_NR_PHY_SIM_UL_SRS_NUM_PDU = 16; %Temp value;
GI_NR_PHY_SIM_UL_PRACH_NUM_PDU = 16; %Temp value;
GI_NR_PHY_SIM_UL_NUM_PDU = (GI_NR_PHY_SIM_UL_PUSCH_NUM_PDU + GI_NR_PHY_SIM_UL_PUCCH_NUM_PDU + GI_NR_PHY_SIM_UL_SRS_NUM_PDU + GI_NR_PHY_SIM_UL_PRACH_NUM_PDU);
GI_NR_PHY_SIM_ATTACH_UE = 3000; %System capacity

%% Macro of System
GI_NR_PHY_SIM_NUM_SCS = 5;
GI_NR_PHY_SIM_NUM_SYM_NORMAL_CP = 14;
GI_NR_PHY_SIM_NUM_SYM_EXTEND_CP = 12;
GI_NR_PHY_SIM_GRID_NUM_RB = 273;
GI_NR_PHY_SIM_NUM_SC_RB = 12;
GI_NR_PHY_SIM_GRID_NUM_SC = (GI_NR_PHY_SIM_GRID_NUM_RB * GI_NR_PHY_SIM_NUM_SC_RB);
GI_NR_PHY_SIM_UL_NUM_PORT = 4;
GI_NR_PHY_SIM_DL_NUM_PORT = 8;
GI_NR_PHY_SIM_BPSK_BIT = 1;
GI_NR_PHY_SIM_QPSK_BIT = 2; 
GI_NR_PHY_SIM_16QAM_BIT = 4;
GI_NR_PHY_SIM_64QAM_BIT = 6;
GI_NR_PHY_SIM_256QAM_BIT = 8;

%% Macro of PUSCH
GI_NR_PHY_SIM_PUSCH_NUM_LAYER = 4; 
GI_NR_PHY_SIM_PUSCH_NUM_PORT = 4;
GI_NR_PHY_SIM_PUSCH_NUM_SYM__NORMAL_CP = 12;
GI_NR_PHY_SIM_PUSCH_NUM_SYM__EXTEND_CP = 10;
GI_NR_PHY_SIM_PUSCH_NUM_SC = (GI_NR_PHY_SIM_GRID_NUM_SC);
GI_NR_PHY_SIM_PUSCH_NUM_CB = 152; %mcsIndex = 27, mcsTable = 1, targetCodeRate = 948/1024, 
                                  %qamModOrder = 8, payloadSize = 1,277,992, nrOfLayers = 4, rbSize = 273, 
                                  %ulDmrsSymbPos = 2052(2, 11), startSymbolIndex = 0, nrOfSymbols = 14 
                                  %ceil((1,277,992 + 24)/(8448 - 24)) = 152 ~= 160
GI_NR_PHY_SIM_PUSCH_NUM_HARQ = 16;
GI_NR_PHY_SIM_PUSCH_NUM_REPEAT = 4;
GI_NR_PHY_SIM_PUSCH_MAX_ZC = 384;
GI_NR_PHY_SIM_PUSCH_TB_SIZE = 160000; %mcsIndex = 27, mcsTable = 1, targetCodeRate = 948/1024, 
                                      %qamModOrder = 8, payloadSize = 1,277,992, nrOfLayers = 4, rbSize = 273, 
                                      %ulDmrsSymbPos = 2052(2, 11), startSymbolIndex = 0, nrOfSymbols = 14 
                                      %1,277,992/8 = 159,749 ~= 160,000
GI_NR_PHY_SIM_PUSCH_CB_LDPC_SIZE = (66*GI_NR_PHY_SIM_PUSCH_MAX_ZC);
GI_NR_PHY_SIM_PUSCH_RATE_MATCH_SIZE = (GI_NR_PHY_SIM_GRID_NUM_RB*GI_NR_PHY_SIM_NUM_SC_RB*(GI_NR_PHY_SIM_NUM_SYM_NORMAL_CP - 1)*...
                                       GI_NR_PHY_SIM_256QAM_BIT*GI_NR_PHY_SIM_PUSCH_NUM_LAYER); %-1means at leat one DMRS symbol
GI_NR_PHY_SIM_PUSCH_SCRAMBLE_SIZE = (GI_NR_PHY_SIM_PUSCH_RATE_MATCH_SIZE);
GI_NR_PHY_SIM_PUSCH_MODULATION_SIZE = (GI_NR_PHY_SIM_GRID_NUM_RB*GI_NR_PHY_SIM_NUM_SC_RB*(GI_NR_PHY_SIM_NUM_SYM_NORMAL_CP - 1)*...
                                       GI_NR_PHY_SIM_PUSCH_NUM_LAYER); %-1means at leat one DMRS symbol
GI_NR_PHY_SIM_PUSCH_LAYER_SIZE = (GI_NR_PHY_SIM_GRID_NUM_RB*GI_NR_PHY_SIM_NUM_SC_RB*(GI_NR_PHY_SIM_NUM_SYM_NORMAL_CP - 1)); %-1means at leat one DMRS symbol
GI_NR_PHY_SIM_PUSCH_PORT_SIZE = (GI_NR_PHY_SIM_PUSCH_LAYER_SIZE);

%% Macro of PUSCH DMRS
GI_NR_PHY_SIM_PUSCH_DMRS_NUM_PORT = (GI_NR_PHY_SIM_PUSCH_NUM_LAYER);
GI_NR_PHY_SIM_PUSCH_DMRS_NUM_SYM_NO_DURATION = 4;
GI_NR_PHY_SIM_PUSCH_DMRS_NUM_SYM_DURATION = 8;
GI_NR_PHY_SIM_PUSCH_DMRS_NUM_SC = (GI_NR_PHY_SIM_GRID_NUM_SC/2);

%% Macro of PUCCH
GI_NR_PHY_SIM_PUCCH_NUM_ACK_BYTE = 32; %Should be 1706, now only support 256 bits
GI_NR_PHY_SIM_PUCCH_NUM_CSI_BYTE = 32; %Should be 1706, now only support 256 bits

%% Macro of PDCCH
GI_NR_PHY_SIM_DL_NUM_DCI_L1_CORESET = 8;
GI_NR_PHY_SIM_DL_NUM_DCI_L2_CORESET = 8;
GI_NR_PHY_SIM_DL_NUM_DCI_L4_CORESET = 8;
GI_NR_PHY_SIM_DL_NUM_DCI_L8_CORESET = 8;
GI_NR_PHY_SIM_DL_NUM_DCI_L16_CORESET = 8;
GI_NR_PHY_SIM_DL_NUM_DCI_CORESET = (GI_NR_PHY_SIM_DL_NUM_DCI_L1_CORESET + GI_NR_PHY_SIM_DL_NUM_DCI_L2_CORESET + GI_NR_PHY_SIM_DL_NUM_DCI_L4_CORESET +...
                                    GI_NR_PHY_SIM_DL_NUM_DCI_L8_CORESET + GI_NR_PHY_SIM_DL_NUM_DCI_L16_CORESET);
GI_NR_PHY_SIM_DL_NUM_REG_CCE = 6;

%% Macro of PDSCH
GI_NR_PHY_SIM_PDSCH_NUM_CW = 2;
GI_NR_PHY_SIM_PDSCH_NUM_HARQ = 16;

%% Macro of PBCH
GI_NR_PHY_SIM_PBCH_MIB_SIZE = 24;
GI_NR_PHY_SIM_PBCH_PAYLOAD_SIZE = 32;
