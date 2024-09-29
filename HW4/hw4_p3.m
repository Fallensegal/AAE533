% AAE 533: Homework 4
% Author: Wasif Islam
% Date: Sep 28th, 2024

%% Initialization
clear;
clc;

% Import Constants
addpath(genpath('..'));   % Add homework parent directory to import shared functions
load("constants.mat");

%% Problem 3

% Generate Random Variables
varOne = normrnd(5, 2.0, 500);
varTwo = normrnd(10, 3.0, 500);

% Combined Random Variable
Z = varOne + varTwo;

% Plot
figure(1)
histogram(varOne)
hold on
histogram(varTwo)
histogram(Z)
hold off
grid on
legend('\mu = 5, \sigma^{2} = 2.0', '\mu = 10, \sigma^{2} = 3.0', 'Combined Gaussian Variable')
title("Adding Two Gaussian Variables")
xlabel("Random Variable Value [Unit-less]")
ylabel("Sample Count")

