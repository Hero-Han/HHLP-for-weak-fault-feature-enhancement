%% 
clc
clear all
close all
addpath(genpath(fileparts(mfilename('fullpath'))));
%% Figure initialization
FontSize = 10;   FontName = 'Times New Roman';
MarkerSize = 4;  LineWidth = 1;
%% Simulation
Fs = 20480;
N = 409600;
Linchao = 2 * QuasiPeiodicImpulseResponse_AM(N,Fs);
Sig_Impulse = Linchao(:);
t = (0 : N-1) / Fs;
t = t(:);



%% Setting the TQWT Parameters
Q = 2;
r = 5;
J = 10;
AH = @(Sig) tqwt_radix2(Sig, Q, r, J);   
A = @(w) itqwt_radix2(w, Q, r , N);
now = ComputeNow(4096,Q,r,J,'radix2');
Temp = [];
Energy = zeros(100, J+1);
%% ���źŷֳ�100�����С��ϵ����Ȼ����и������
for j = 1 : 100
    x = AH(Sig_Impulse((j-1)*4096+1:j*4096));
    Temp1 = [];
    for i = 1:numel(x)
        Temp1 = [Temp1; x{i}(:) / now(i)];
        Energy(j, i) = norm(x{i}(:) / now(i));
    end    
    Temp = [Temp; Temp1];
end
Temp = Temp - mean(Temp);


%% Fitting the probability distribution
[Number,edges] = histcounts(Temp, 2000, 'Normalization', 'probability');
for i = 1 : length(Number)
    Points(i) = (edges(i + 1) + edges(i))/2;
end

%% Calculate the probability
% plot(Points,log2(N),'r-','LineWidth',1.5)
% axis([-0.4, 0.4, -15, 0])
% hold on
y = -1.5:0.01:1.5;
g = max(Number);
% gaussian
k1 = 40;
f1 = exp(-abs(y).^2.*k1) * (g);
% laplacian
k2 = 18;
f2 = exp(-abs(y).^1.*k2) * (g);
% hyper-laplacian 0.2
k3 = 10;  
f3 = exp(-abs(y).^0.2.*k3) * (g);
% hyper-laplacian 0.5
k4 = 12;     %16
f4 = exp(-abs(y).^0.5.*k4) * (g);  



%% Print the time domain
figure();clf;
hold on
ph(1) = plot(Points, log2(Number), 'b-*', 'LineWidth', LineWidth + 1,'MarkerIndices',914);
ph(2) = plot(y, log2(f1), 'k->', 'LineWidth', LineWidth + 1,'MarkerIndices',130);
ph(3) = plot(y, log2(f2), 'g-o', 'LineWidth', LineWidth + 1,'MarkerIndices',130);
ph(4) = plot(y, log2(f3), 'r-^', 'LineWidth', LineWidth + 1,'MarkerIndices',140);
ph(5) = plot(y, log2(f4), 'm-d', 'LineWidth', LineWidth + 1,'MarkerIndices',130);
hold off
box off
legend1 = legend(ph, 'Empirical' , 'Gaussian(p=2)', 'Laplacian(p=1)', 'Hyper-Laplacian(p=0.2)', 'Hyper-Laplacian(p=0.5)');
set(legend1,'position',[0.355753208674833 0.188045033873465 0.52916665433556 0.329710135749285],'Orientation','vertical', 'FontSize',FontSize,'FontName',FontName)
legend boxoff
xlim_min = -0.6; xlim_max = 0.6;
ylim_min = -20;            ylim_max = 0;  
xylim = [xlim_min,xlim_max,ylim_min,ylim_max]; axis(xylim);



filename = ['Results', filesep, sprintf('Impulse_Probability.pdf')];
print(filename, '-dpdf');

