img = imread('./plates/plate5.png');
img_f = rgb2gray(img);
imgfinal = imbinarize(img_f, 0.5);
imgfinal = imcomplement(imgfinal);
figure, imshow(imgfinal);
stats = regionprops(imgfinal);
str = '';
for index=1:length(stats)
if stats(index).Area > 100
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