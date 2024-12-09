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
% File           gi_nrPhySimTestDlGenResource.m
%
% Description    Generate the DL resources and cases
%
% -------------------------------------------------------------------------------
%
% Change log
%
% Date          Author       Action
%
% 2023.07.21    Mian Yang    Created 
%
% -------------------------------------------------------------------------------
%

%% clear all variants.
clear all;
clc;

%% Add path
addpath('..\Common');
addpath(genpath('..\DL\DlTx'));
addpath(genpath('..\Utils'));

%% Call gi_nrPhySimDlTxMain
gi_nrPhySimDlTxMain('D:\Workspace\5gSmallCellCase_L1\dlTxData',...
                    'D:\Workspace\5gSmallCellResearchAlg_L1',...
                    'testList.txt',...
                    'dlTxTestReport.txt');