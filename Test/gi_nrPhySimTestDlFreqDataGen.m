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
% File           gi_nrPhySimTestDlFreqDataGen.m
%
% Description    Generate DL TX freq data
%
% -------------------------------------------------------------------------------
%
% Change log
%
% Date          Author       Action
%
% 2023.08.06    Mian Yang        Created 
%
% -------------------------------------------------------------------------------
%

%% Clear all variants
clear all;
clc;

%% Add path
addpath(genpath('..\Utils'));

%% Call gi_utilsFreqDataGen
gi_utilsDlFreqDataGen('D:\Workspace\5gSmallCellCase_L1\dlTxData',...
                      'testList.txt', ...
                      'dlTxRefGenReport.txt');