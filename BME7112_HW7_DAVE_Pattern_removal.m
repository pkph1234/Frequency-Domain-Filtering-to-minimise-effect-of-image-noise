% Matlab Code for removing FPN
% HW 7- Medical Image Processing Hemal Dave
% this code has 2 commented thing int he peak detection loop, make sure
% that same image USER SHOULD TAKE same image peak detection threshold 


clc;
close all;
clear all;
%% Read the Image.
Image = im2double(imread('BME7112_Data_File_7A.tif'));
%% FFT Or original & Cutoff Images
[x,y] = size(Image);
pts = x;
cutoff = 0.15;
FFT_Original_Image= fftshift(fft2(double(Image),pts,pts)); % Obtain Image FFT
[f1,f2] = freqspace([pts pts],'meshgrid'); % Define regular 2D array
Hw=ones(pts,pts); % Generate Filter Mask
r = sqrt(f1.^2+f2.^2); % Define filter Radius
Hw(r<cutoff) = 0; % Design Low-Pass Filter
IFFT_Cutoff_Image = (FFT_Original_Image.*Hw); % Suppress Low Frequencies
%% Ploting the FFT FOr both Images
figure(1)
subplot(1,2,1)
imshow(FFT_Original_Image);
title('2D FFT of original image')
subplot(1,2,2)
imshow(IFFT_Cutoff_Image)
title(['2d FFT after Cutoff Freq = ',num2str(cutoff)])
%% Ploting the IFFT for both Iamges
figure(2)
h = (ifftshift(FFT_Original_Image));
IFFT_Original_Image = ifft2(h);
as = max(IFFT_Original_Image(:));
as1 = min(IFFT_Original_Image(:));
subplot(1,2,1)
imshow(IFFT_Original_Image)
colormap gray
caxis([as1 as])
title('Reconstruction of original Image')
subplot(1,2,2)
f2 = (ifftshift(IFFT_Cutoff_Image));
IFFT_Cutoff_Image = ifft2(f2);
ad = max(IFFT_Cutoff_Image(:));
ad1 = min(IFFT_Cutoff_Image(:));
imshow(IFFT_Cutoff_Image)
caxis([ad1 ad])
colormap gray
title('Reconstruction of original Image after cutoff the frequency')
%% Calculating of PSD of both iamges to visulise better fft.
PSD_Original_Image = log10(abs(fftshift(fft2(IFFT_Original_Image))).^2 );
PSD_Cutoff_Image = log10(abs(fftshift(fft2(IFFT_Cutoff_Image))).^2 );
%% Ploting the PSD for both Images
figure(3)
subplot(1,3,1)
imagesc(PSD_Cutoff_Image)
title('PSD Image')
colormap gray
subplot(1,3,2)
mesh(PSD_Cutoff_Image)
title('Mash of PSD')
colormap gray
subplot(1,3,3)
plot(PSD_Cutoff_Image(500,:))
title('Each row PSD ')
figure(4)
subplot(1,3,1)
imagesc(PSD_Original_Image)
title('PSD Image')
colormap gray
subplot(1,3,2)
mesh(PSD_Original_Image)
title('Mash of PSD')
colormap gray
subplot(1,3,3)
plot(PSD_Original_Image(500,:))
title('Each row PSD ')
PSD_Reconstructed_Image_alt = zeros(x,y);
PSD_Reconstructed_Image = ones(x,y);
Pattern_Location = zeros(x,y);
%% Removing the noise peaks in PSD
for i = 1:300% finding the peaks for first 300 rows
    w = PSD_Cutoff_Image(i,:);% save all the row data in temp. variable
%     [pks,location] = findpeaks(w,'MinPeakHeight',2,'MinPeakDistance',150);% find the peaks & location
  [pks,location] = findpeaks(w,'MinPeakHeight',2,'MinPeakDistance',100);
  %for Image A
      Pattern_Location(i,location) = 2;% At the location constant value 2 is given
end
for i = 301:600% finding peaks for row 301 to 600
    w = PSD_Cutoff_Image(i,:);
%     [pks,location] = findpeaks(w,'MinPeakHeight',3,'MinPeakDistance',400);
  [pks,location] = findpeaks(w,'MinPeakHeight',3,'MinPeakDistance',400);
      Pattern_Location(i,location) = 2;
end
for i = 601:901% finding peaks from 601:901 rows
    w = PSD_Cutoff_Image(i,:);
%     [pks,location] = findpeaks(w,'MinPeakHeight',2,'MinPeakDistance',150);
  [pks,location] =findpeaks(w,'MinPeakHeight',2,'MinPeakDistance',100);
  % FOr Image A
      Pattern_Location(i,location) = 2;
end
% adding the same data for horizontal & vaertical central line from
% original PSD(without cut-off psd)
Pattern_Location(447:455,1:383) = PSD_Reconstructed_Image_alt(447:455,1:383);
Pattern_Location(447:455,519:901) = PSD_Reconstructed_Image_alt(447:455,519:901);
Pattern_Location(1:383,447:455) = PSD_Reconstructed_Image_alt(1:383,447:455);
Pattern_Location(519:901,447:455) = PSD_Reconstructed_Image_alt(519:901,447:455);
figure(5)
subplot(1,2,1)
imagesc(Pattern_Location)
title('Before')
% MAking 7x7 kernel of ones and multiply with the peaks sorrounding matrix,
% Here I save the peaks value 2 in upper part because I want to MAke that
% matrix value 1 and invert the whole matrix
for i = 3:x-3
    for j = 3:y-3
    if Pattern_Location(i,j) == 2
        for k = 1:6
            for l = 1:6
                Pattern_Location(i+k-3,j+l-3) = 1;
            end
        end
    end
    end
end
Pattern_Location(420:520,420:520) = 0;
subplot(1,2,2)
imagesc(Pattern_Location) 
title('After')
 Pattern_Location(Pattern_Location>=1) = 1;% make sure that all the peak values are 1
 Pattern_Location = ~Pattern_Location;% invert the mask ans make all the peaks to zero
FFT_Original_Image = FFT_Original_Image.*Pattern_Location;% multiply the mask with the PSD
PSD_Original_Image = PSD_Original_Image.*Pattern_Location;
%% FInding the angle of the FPN
COmplex = FFT_Original_Image(600,417);
Angle = angle(COmplex);
angleInDegrees = radtodeg(Angle);


   %% Ploting the reconstructed Image
figure(6)
subplot(1,2,1)
imagesc(PSD_Original_Image)
title('Remove fixed pattern')
h3 = (ifftshift(FFT_Original_Image));
Construction_Original_Image = abs(ifft2(h3));
subplot(1,2,2)
imshow(Construction_Original_Image)
as = max(Construction_Original_Image(:));
as1 = min(Construction_Original_Image(:));
caxis([as1 as])
title('Reconstructed Image');




