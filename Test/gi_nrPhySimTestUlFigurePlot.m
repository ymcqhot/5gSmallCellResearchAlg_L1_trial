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
% File           gi_nrPhySimTestUlFigurePlot.m
%
% Description    Plot UL simulation result
%
% -------------------------------------------------------------------------------
%
% Change log
%
% Date          Author       Action
%
% 2022.07.09    Mian Yang    Created 
%
% -------------------------------------------------------------------------------
%

%% Clear all variants
clear all;
close all;
clc;

%% Add path
addpath(genpath('..\Utils'));

%% Call gi_utilsFigurePlot
gi_utilsFigurePlot('D:\Workspace\5gSmallCellCase_L1_trial\ulTxData',...
                   'D:\Workspace\5gSmallCellResearchAlg_L1_trial',...
                   'testList.txt', ...
                   'puschRxTestReport.txt');