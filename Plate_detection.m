img = imread('C:\Users\Welcome\Desktop\New folder\7.jpg');
figure, imshow(img);
img = rgb2gray(img);

imh = imadjust(img, [], [0.0 1.0]);
imh1 = histeq(img);

SE = strel('disk', 15);
img2 = imopen(imh1, SE);

img_f = imsubtract(imh1, img2);

BW = imbinarize(img_f, 0.7);
figure, imshow(BW);

BW = edge(BW,'sobel');

RE = [0 1 0; 1 1 1; 0 1 0];
BW = imdilate(BW, RE);
BW = imfill(BW, 'holes');

Iprops=regionprops(BW,'BoundingBox', 'Area');
maxa = Iprops(1).Area;
count = numel(Iprops);
boundingBox = Iprops.BoundingBox;

for i=1:count
   if maxa<Iprops(i).Area
      maxa=Iprops(i).Area;
      boundingBox=Iprops(i).BoundingBox;
   end
end

im = imcrop(img, boundingBox);

%imwrite(im, './plates/plate27.png');
figure, imshow(im);
im = imadjust(im, [], [0.0 1.0]);
imh1 = histeq(im);
imh1 = imbinarize(imh1);
BW = edge(imh1, 'canny');
%figure, imshow(BW);
[H, T, R] = hough(BW);
P = houghpeaks(H, 5, 'threshold', ceil(.3*max(H(:))));
x = T(P(:,2));
y = R(P(:,1));
lines = houghlines(BW, T, R, P,'FillGap',6,'MinLength',5);
figure, imshow(im), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   len = norm(lines(k).point1 - lines(k).point2);
    if (len > max_len)
       max_len = len;
       xy_long = xy;
    end
end
%plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
disp(xy_long);
angle = (xy_long(1, 2)-xy_long(2, 2))/(xy_long(1, 1)-xy_long(2, 1));
Y = angle;
disp((180/3.14)*angle);
imgfinal = imrotate(imh1, (180/3.14)*angle, 'bicubic', 'loose');
imgfinal = imresize(imgfinal, [200 600]);
imgfinal = imcomplement(imgfinal);
figure, imshow(imgfinal);
stats = regionprops(imgfinal);
str = '';
for index=1:length(stats)
if stats(index).Area > 100 && stats(index).BoundingBox(3)*stats(index).BoundingBox(4) < 70000
      x = ceil(stats(index).BoundingBox(1));
      y= ceil(stats(index).BoundingBox(2));
      widthX = floor(stats(index).BoundingBox(3)-1);
      widthY = floor(stats(index).BoundingBox(4)-1);
      subimage(index) = {imgfinal(y:y+widthY,x:x+widthX,:)}; 
      padsize = 20;
      padvalue = 0;
      padimg = padarray(subimage{index}, [padsize, padsize], padvalue);
      padimg = imresize(padimg, [50 50]);
      disp(ocr(padimg,'CharacterSet','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ','TextLayout','word').Text);
      str = strcat(str, ocr(padimg,'CharacterSet','0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ','TextLayout','word').Text);
      figure, imshow(padimg);
end
end

disp(str);