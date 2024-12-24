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
% File           gi_nrPhySimTestDlFreqDataCompare.m
%
% Description    Compare DL TX freq data
%
% -------------------------------------------------------------------------------
%
% Change log
%
% Date          Author       Action
%
% 2023.08.07    Mian Yang        Created 
%
% -------------------------------------------------------------------------------
%

%% Clear all variants
clear all;
clc;

%% Add path
addpath(genpath('..\Utils'));

%% Call gi_utilsDlFreqDataCompare
gi_utilsDlFreqDataCompare('D:\Workspace\5gSmallCellCase_L1_trial\dlTxData',...
                          'testList.txt',...
                          'dlTxCompareReport.txt');