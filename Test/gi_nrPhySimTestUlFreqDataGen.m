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
% File           gi_nrPhySimTestUlFreqDataGen.m
%
% Description    Generate UL TX freq data
%
% -------------------------------------------------------------------------------
%
% Change log
%
% Date          Author       Action
%
% 2021.12.28    Mian Yang        Created 
%
% -------------------------------------------------------------------------------
%

%% Clear all variants
clear all;
clc;

%% Add path
addpath(genpath('..\Utils'));

%% Call gi_utilsFreqDataGen
gi_utilsUlFreqDataGen('D:\Workspace\5gSmallCellCase_L1\ulTxData',...
                      'testList.txt', ...
                      'puschTxRefGenReport.txt');