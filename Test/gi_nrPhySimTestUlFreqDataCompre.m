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
% File           gi_nrPhySimTestUlFreqDataCompare.m
%
% Description    Compare UL TX freq data
%
% -------------------------------------------------------------------------------
%
% Change log
%
% Date          Author       Action
%
% 2022.10.13    Mian Yang        Created 
%
% -------------------------------------------------------------------------------
%

%% Clear all variants
clear all;
clc;

%% Add path
addpath(genpath('..\Utils'));

%% Call gi_utilsFreqDataGen
gi_utilsUlFreqDataCompare('D:\Workspace\5gSmallCellCase_L1\ulTxData',...
                          'testList.txt', ...
                          'puschTxCompareReport.txt');