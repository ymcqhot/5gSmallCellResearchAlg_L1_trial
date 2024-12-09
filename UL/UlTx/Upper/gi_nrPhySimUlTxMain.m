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
% File           gi_nrPhySimUlTxMain.m
%
% Description    UL TX main function
%
% -------------------------------------------------------------------------------
%
% Change log
%
% Date          Author       Action
%
% 2021.08.19    Yi He        Created 
% 2021.11.03    Mian Yang    Changed 
% 2022.05.28    Mian Yang    Changed
%
% -------------------------------------------------------------------------------
%

%% gi_nrPhySimUlTxMain
% -------------------------------------------------------------------------------
%
% *gi_nrPhySimUlTxMain* - UL TX main function
%
% -------------------------------------------------------------------------------
%
% *testPath* - The base address of the resources.
%
% For example: 'D:\Workspace\5gSmallCellCase_L1\ulTxData'.
%
% Param [In]   
%
% Format is [1], string.
%
% *testTemplatePath* - The base address of the test Template parameters.
%
% For example: 'D:\Workspace\5gSmallCellResearchAlg_L1'.
%
% Param [In]   
%
% Format is [1], string.
%
% *testList* - A .txt file that the list of resources need to be generated.
%
% For example: 'testList.txt'
%
% Param [In]     
%
% Format is [1], string.
%
% *testReport* - A .txt file that the report records the test result.
%
% For example: 'testReport.txt'
%
% Param [In]    
%
% Format is [1], string.
%
% *Void* - The return is void
%
% Param [Out]    
%
% Format is [1], .
%
% -------------------------------------------------------------------------------
%
function gi_nrPhySimUlTxMain(testPath, testTemplatePath, testList, testReport)

%% Declare macro
gi_nrPhySimMacroDefine;

%% Declare buffer
gi_nrPhySimBufferDefine;

%% Declare struct;
gi_nrPhySimStructDefine;

%% Declare table
gi_nrPhySimTableDefine;

%% Parameter check
%Compensate '\' to testRscPath
if testPath(end) ~= '\' && testPath(end) ~= '/'
    testPath(end + 1) = '\';
end

%Compensate '\' to testTemplatePath
if testTemplatePath(end) ~= '\' && testTemplatePath(end) ~= '/'
    testTemplatePath(end + 1) = '\';
end

% Check whether the testRscReport.txt exists. if it doesn't exists, create it;
% and if it exists, then empty the txt file.
testRscReportAddr = sprintf('%s%s', testPath, testReport);
fid = fopen(testRscReportAddr, 'w');% 'w':Open or create a new file to write and discard existing content (if any)
if(-1 ~= fid)
    fclose(fid);
else
    error('The file %s is not created or empty!!!', testRscReportAddr);
end

%% Get test list.
[caseList] = gi_utilsGetTestRscOrCaseList(testPath, testList);

%% Test loop
for testIdx = 1 : length(caseList)
    %Print caseNo
    file = fopen(testRscReportAddr, 'a+');
    fprintf(1, '%s%s', caseList{testIdx}, newline);
    fprintf(file, '%s%s', caseList{testIdx}, newline);
    fclose(file);
    
    %% Read simUlTx.xlsx, simSys.xlsx, simUl.xlsx 
    %Generate address  
    caseAddr = sprintf('%s%s', testPath, caseList{testIdx});
    configAddr = sprintf('%s%s', caseAddr, '\Config\');
    templateAddr = sprintf('%s%s', testTemplatePath, 'Template\');
    sysTemplateAddr = sprintf('%s%s', templateAddr, 'systemTemplate\');
    frcTemplateAddr = sprintf('%s%s', templateAddr, 'frcTemplate\');
    channelTemplateAddr = sprintf('%s%s', templateAddr, 'channelTemplate\');
    
    %Read simUlTx
    [simUlTxS] = gi_utilsReadExcel(configAddr, 'simUlTx.xlsx');

    %Determine whether the template of parameters are used, simSysS
    if(~strcmp(simUlTxS.simUlTemplateS.systemTemplate, 'Disable'))
        [simSysS] = gi_utilsReadExcel(sysTemplateAddr, ['simSys_' simUlTxS.simUlTemplateS.systemTemplate '.xlsx']);
    else
        [simSysS] = gi_utilsReadExcel(configAddr, 'simSys.xlsx');
    end

    %Determine whether the template of parameters are used, simUlS
    if(~strcmp(simUlTxS.simUlTemplateS.frcTemplate, 'Disable'))
        [simUlS] = gi_utilsReadExcel(frcTemplateAddr, ['simUl_' simUlTxS.simUlTemplateS.frcTemplate '.xlsx']);
    else
        [simUlS] = gi_utilsReadExcel(configAddr, 'simUl.xlsx');
    end

    %% Set BWPSize according to bandwidth
    %bandwidth index
    bandwidth = find(gi_nrPhySimTransmissionBandwidthTbl == simSysS.uplinkBandwidth) - 1;

    %Slot loop
    for slotIdx = 1:simUlTxS.numSlot
        %PDU loop
        for pduIdx = 1:simUlS(slotIdx).nPDUs
            %Fetch PDU
            simPduU = simUlS(slotIdx).simPduU(pduIdx);
            
            %Processing according to different PDU type
            switch simPduU.pduType
                case 0 %PRACH
                    %
                case 1 %PUSCH
                    if strcmp(simUlS(slotIdx).simPduU(pduIdx).simPuschPduS.BWPSize, 'bandwidth')
                        simUlS(slotIdx).simPduU(pduIdx).simPuschPduS.BWPSize =...
                            gi_nrPhySimTransmissionBandwidthNrbFr1Tbl{simPduU.simPuschPduS.subcarrierSpacing + 1, bandwidth + 1}; %+1 for matlab index        
                    end %if, bandwidth
                case 2 %PUCCH
                    if strcmp(simUlS(slotIdx).simPduU(pduIdx).simPucchPduS.BWPSize, 'bandwidth')
                        simUlS(slotIdx).simPduU(pduIdx).simPucchPduS.BWPSize =...
                            gi_nrPhySimTransmissionBandwidthNrbFr1Tbl{simPduU.simPucchPduS.subcarrierSpacing + 1, bandwidth + 1}; %+1 for matlab index        
                    end %if, bandwidth 
                case 3 %SRS
                    %         
                otherwise
                    error('Wrong pduType = %d!!!', simPduU.pduType);
            end %switch, simPduU.pduType
        end %for, pduIdx
    end %for, slotIdx

    %Determine whether the template of parameters are used, simUlChanS
    if(~strcmp(simUlTxS.simUlTemplateS.channelTemplate, 'Disable'))
        [simUlChanS] = gi_utilsReadExcel(channelTemplateAddr, ['simUlChan_' simUlTxS.simUlTemplateS.channelTemplate '.xlsx']);
    else
        [simUlChanS] = gi_utilsReadExcel(configAddr, 'simUlChan.xlsx');
    end

    %Interference parameters
    if 1 == simUlTxS.interferenceEnable
        %Determine whether the template of interference parameters are used, simSysS
        if(~strcmp(simUlTxS.simUlInfTemplateS.systemTemplate, 'Disable'))
            [simSysInfS] = gi_utilsReadExcel(sysTemplateAddr, ['simSys_' simUlTxS.simUlInfTemplateS.systemTemplate '.xlsx']);
        else
            [simSysInfS] = gi_utilsReadExcel(configAddr, 'simSysInf.xlsx');
        end
        
        %Determine whether the template of parameters are used, simUlS
        if(~strcmp(simUlTxS.simUlInfTemplateS.frcTemplate, 'Disable'))
            [simUlInfS] = gi_utilsReadExcel(frcTemplateAddr, ['simUl_' simUlTxS.simUlInfTemplateS.frcTemplate '.xlsx']);
        else
            [simUlInfS] = gi_utilsReadExcel(configAddr, 'simUlInf.xlsx');
        end

        %Determine whether the template of parameters are used, simUlChanS
        if(~strcmp(simUlTxS.simUlInfTemplateS.channelTemplate, 'Disable'))
            [simUlChanInfS] = gi_utilsReadExcel(channelTemplateAddr, ['simUlChan_' simUlTxS.simUlInfTemplateS.channelTemplate '.xlsx']);
        else
            [simUlChanInfS] = gi_utilsReadExcel(configAddr, 'simUlChanInf.xlsx');
        end        
    end %if, interferenceEnable

    %Determine whether need send All ACK
    if isfield(simUlTxS, 'pucchACKmissedSNR')
        pucchAllAckFlag = 1; %Test of 'ACK missed' need TB source are all ACKs
    else
        pucchAllAckFlag = 0;
    end

    %% Remove invalid PDU type and sort the UE level config
    [simUlSortS, simUlTxS] = gi_nrPhySimUlTxUeConfigRemoveAndSort(simUlS, simUlTxS);

    %% UL TX system parameters parser
    [simUlTxSysInterS] = gi_nrPhySimUlTxSysParamParser(simSysS);

    %% FAPI interface generaton
    [fapiCfgReqS, fapiUlS] = gi_nrPhySimUlTxFapiGen(simSysS, simUlS, simUlTxS.numSlot);

    %% UL RX system parameter calculation(FAPI)
    if 1 == GI_NR_PHY_SIM_UL_SIMULATION
        [simUlRxSysInterS] = gi_nrPhySimUlRxSysParamParser(fapiCfgReqS);
    end

    %% Delete .mat and .bin files
    %Generate address
    resourceAddr = sprintf('%s%s', caseAddr, '\Resource\');
    matAddr = sprintf('%s%s%s', resourceAddr, '*', '.mat');
    binAddr = sprintf('%s%s%s', resourceAddr, '*', '.bin');
    
    %Delete old files
    delete(matAddr);
    delete(binAddr);

    %% Slot-level processing
    %Initialize simUlRxStatistic
    if 1 == GI_NR_PHY_SIM_UL_SIMULATION
        simUlRxStatisticS = gi_nrPhySimUlRxStatistic_s;
    end

    %Repeat loop
    for repeatIdx = 1:simUlTxS.numRepeat
        %Slot loop
        for slotIdx = 1:simUlTxS.numSlot
            %Print slotIdx
            file = fopen(testRscReportAddr, 'a+');
            fprintf(1, 'repeatIdx%d, slotIdx%d%s', repeatIdx - 1, slotIdx - 1, newline); %-1 for start from 0
            fprintf(file, 'repeatIdx%d, slotIdx%d%s', repeatIdx - 1, slotIdx - 1, newline); %-1 for start from 0                
            fclose(file);

           %% Signal generation
            [dataChan, puschTbRecord, pucchPart1TbRecord, pucchPart2TbRecord, pucchDTXsentRecord] =...
                gi_nrPhySimUlTxSignalGen(simSysS, simUlTxSysInterS, simUlSortS(slotIdx), simUlChanS, repeatIdx, simUlTxS.numSlot, pucchAllAckFlag, caseAddr,...
                                         puschTbRecord, pucchPart1TbRecord, pucchPart2TbRecord, pucchDTXsentRecord);

           %% Interference generation
            %gi_nrPhySimUlTxInterferenceGen();
            
           %% Noise applying           
            %SNR loop
            for SNR = simUlTxS.snrStart:simUlTxS.snrStep:simUlTxS.snrEnd %Loop for simulation, while just one value in situation of case generation. 
                %Print SNR
                %fprintf(1, '%2.1fdB%s', SNR, newline);

                %Get snrIdx
                snrIdx = find((simUlTxS.snrStart:simUlTxS.snrStep:simUlTxS.snrEnd) == SNR);

                %Add noise according to SNR
                [dataChanNoise] = gi_nrPhySimUlTxNoiseApply(dataChan, SNR);

               %% Interference applying
                if 1 == simUlTxS.interferenceEnable %Interference exsit
                    %CIR loop
                    for cir = simUlChanS.cirStart:simUlChanS.cirStep:simUlChanS.cirEnd %Loop for simulation, while just one value in situation of case generation. 
                        %Add interference according to cir
                        dataChanNI = dataChanNoise;

                        %% Signal processing
                        if 1 == GI_NR_PHY_SIM_UL_SIMULATION
                            [simUlRxPuschSnrMetricS, simUlRxPucchSnrMetricS, SFN, slot, puschLlrCombine] =...
                                gi_nrPhySimUlRxSignalProcesing(dataChanNI, simUlRxSysInterS, fapiUlS(slotIdx), repeatIdx, simUlTxS.numSlot, snrIdx, puschLlrCombine);
                        end 
                    end
                else %No interference
                  %% Signal processing
                    if 1 == GI_NR_PHY_SIM_UL_SIMULATION
                        [simUlRxPuschSnrMetricS, simUlRxPucchSnrMetricS, SFN, slot, puschLlrCombine] =.... 
                            gi_nrPhySimUlRxSignalProcesing(dataChanNoise, simUlRxSysInterS, fapiUlS(slotIdx), repeatIdx, simUlTxS.numSlot, snrIdx, puschLlrCombine);
                    end
                end %if, interferenceEnable
                
                %% Collect metrics in all SNR
                if 1 == GI_NR_PHY_SIM_UL_SIMULATION
                    gi_nrPhySimUlRxMetric_s.numSNR = gi_nrPhySimUlRxMetric_s.numSNR + 1;
                    gi_nrPhySimUlRxMetric_s.SNR(snrIdx) = SNR;   
                    gi_nrPhySimUlRxMetric_s.simUlRxPuschSnrMetricS(snrIdx) = simUlRxPuschSnrMetricS;   
                    gi_nrPhySimUlRxMetric_s.simUlRxPucchSnrMetricS(snrIdx) = simUlRxPucchSnrMetricS;
                end
            end %for, SNR

            %% Collect slot level parameters into metrics
            if 1 == GI_NR_PHY_SIM_UL_SIMULATION
                gi_nrPhySimUlRxMetric_s.SFN = SFN;
                gi_nrPhySimUlRxMetric_s.Slot = slot;
                simUlRxMetricS = gi_nrPhySimUlRxMetric_s;

                %Clear gi_nrPhySimUlRxMetric_s
                gi_nrPhySimUlRxMetric_s.numSNR = 0;
            end

            %% Statistic
            if 1 == GI_NR_PHY_SIM_UL_SIMULATION
                [simUlRxStatisticS, puschTransmissionStatus] = gi_nrPhySimUlRxStatistic(simUlRxMetricS, simUlTxS, simUlChanS, puschTbRecord,...
                                                                                        pucchPart1TbRecord, pucchPart2TbRecord, pucchDTXsentRecord,...
                                                                                        simUlRxStatisticS, puschTransmissionStatus);       
            end
        end %for, slotIdx
    end %for, repeatIdx

    %% Generate simUlRxStatistic.mat
    if 1 == GI_NR_PHY_SIM_UL_SIMULATION
        %Generate address
        resourceAddr = sprintf('%s%s', caseAddr, '\Resource\');
        statisticAddr = sprintf('%s%s', resourceAddr, 'simUlRxStatistic.mat');

        %Save config file
        save(statisticAddr, 'simUlRxStatisticS');
    end  
end %for, testIdx

end %gi_nrPhySimUlTxMain()