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
% File           gi_nrPhySimDlTxMain.m
%
% Description    DL TX main function
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

%% gi_nrPhySimDlTxMain
% -------------------------------------------------------------------------------
%
% *gi_nrPhySimDlTxMain* - DL tx main function.
%
% -------------------------------------------------------------------------------
%
% *testPath* - The base address of the resources.
%
% For example: 'D:\Workspace\5gSmallCellCase_L1\dlTxData'.
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
function gi_nrPhySimDlTxMain(testPath, testTemplatePath, testList, testReport)

%% Declare macro
gi_nrPhySimMacroDefine;

%% Declare buffer
gi_nrPhySimBufferDefine;

%% Declare struct;
gi_nrPhySimStructDefine;

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
    
    %% Read simDlTx.xlsx, simSys.xlsx, simUl.xlsx 
    %Generate address  
    caseAddr = sprintf('%s%s', testPath, caseList{testIdx});
    configAddr = sprintf('%s%s', caseAddr, '\Config\');
    templateAddr = sprintf('%s%s', testTemplatePath, 'Template\');
    sysTemplateAddr = sprintf('%s%s', templateAddr, 'systemTemplate\');
    
    %Read simDlTx
    [simDlTxS] = gi_utilsReadExcel(configAddr, 'simDlTx.xlsx');

    %Determine whether the template of parameters are used, simSysS
    if(~strcmp(simDlTxS.simDlTemplateS.systemTemplate, 'Disable'))
        [simSysS] = gi_utilsReadExcel(sysTemplateAddr, ['simSys_' simUlTxS.simUlTemplateS.systemTemplate '.xlsx']);
    else
        [simSysS] = gi_utilsReadExcel(configAddr, 'simSys.xlsx');
    end

    %Read simDls
    [simDlS] = gi_utilsReadExcel(configAddr, 'simDl.xlsx');

    %% Remove invalid PDU and sort
    [simDlSortS, simDlTxS] = gi_nrPhySimDlTxPduRemoveAndSort(simDlS, simDlTxS);

    %% DL TX system parameters parser
    [simDlTxSysInterS] = gi_nrPhySimDlTxSysParamParser(simSysS);

    %% FAPI interface generaton
    %[fapiCfgReqS, fapiUlS] = gi_nrPhySimDlTxFapiGen(simSysS, sortSimDlS, simDlTxS.numSlot);

    %% DL TX system parameter calculation(FAPI)
    %[simDlRxSysInterS] = gi_nrPhySimDlRxSysParamParser(fapiCfgReqS);

    %% Delete .mat and .bin files
    %Generate address
    resourceAddr = sprintf('%s%s', caseAddr, '\Resource\');
    matAddr = sprintf('%s%s%s', resourceAddr, '*', '.mat');
    binAddr = sprintf('%s%s%s', resourceAddr, '*', '.bin');
    
    %Delete old files
    delete(matAddr);
    delete(binAddr);

    %% Slot-level processing
    %Repeat loop
    for repeatIdx = 1:simDlTxS.numRepeat
        %Slot loop
        for slotIdx = 1:simDlTxS.numSlot
            %Print slotIdx
            file = fopen(testRscReportAddr, 'a+');
            fprintf(1, 'repeatIdx%d, slotIdx%d%s', repeatIdx - 1, slotIdx - 1, newline); %-1 for start from 0
            fprintf(file, 'repeatIdx%d, slotIdx%d%s', repeatIdx - 1, slotIdx - 1, newline); %-1 for start from 0                
            fclose(file);

            %% Signal generation
            [dataTime, pdschCw1Record, pdschCw2Record] = gi_nrPhySimDlTxSignalGen(simSysS, simDlTxSysInterS, simDlSortS(slotIdx), repeatIdx,...
                                                                                  simDlTxS.numSlot, caseAddr, pdschCw1Record, pdschCw2Record);
        end %for, slotIdx
    end %for, repeatIdx
end %for, testIdx

end %gi_nrPhySimDlTxMain()