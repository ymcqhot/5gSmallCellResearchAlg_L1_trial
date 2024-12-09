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
% File           gi_nrPhySimTestUlGenResource.m
%
% Description    Generate UL resources and cases
%
% -------------------------------------------------------------------------------
%
% Change log
%
% Date          Author       Action
%
% 2021.08.21    Yi He        Created 
%
% -------------------------------------------------------------------------------
%

%% clear all variants
clear all;
clc;

%% Add path
addpath('..\Common');
addpath(genpath('..\UL\UlTx'));
addpath(genpath('..\UL\UlRx'));
addpath(genpath('..\Utils'));

%% Call gi_nrPhySimUlTxMain
gi_nrPhySimUlTxMain('D:\Workspace\5gSmallCellCase_L1\ulTxData',...
                    'D:\Workspace\5gSmallCellResearchAlg_L1',...
                    'testList.txt',...
                    'puschTxTestReport.txt');