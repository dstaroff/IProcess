# IProcess
Remastered version of Pascal Image Processing Library. It's the unit module for Pascal ABC.Net.
Now this is the alpha version but it will be extended as often as I can.

It works with using a LockBits method, required from System.Drawing.dll, for the images with 24bpp RGB Pixel Format.
Supports such methods of image processing as:
• Negative
• Grayscale
• RGB Shift
• Threshold
• BiTonal
• Tint
• Color Shading
• Contrast
x Color Balance

For creating an example of IBitmap class you can use this construction:
  var
    iBitmap: IBitmap := new IBitmap(filepath);
  
For starting with processing you must enable Editable mode with StartEdit() method:
  iBitmap.StartEdit();
  
After that you can use all the methods of IBitmap class, related to processing.
Also you can get info about example of this class with its parameter Editable and get an example of System.Drawing.Bitmap with parameter Image:
  if (!iBitmap.Editable) then
    iBitmap.Image.Save('Edited image.jpg');
NB: You always can get an actual example of image with Image method

After processing you should disable Editable mode with FinishEdit() method:
  iBitmap.FinishEdit();
  
After that you can save your image to file with Save() method:
  iBitmap.Save(filepath);
NB: Save() method can not be used if the example of IBitmap is in Editable mode.

TODO: 
  • Add support of other Pixel Formats
  • Add new necessary methods like:
    ○ Saturation
    ○ Hue
    ○ Levels
    ○ Gradient map
    ○ Image Convolution
    ○ Blur Filter
    ○ Sharpen Filter
    ○ Noise Filter
    ♥ Oil-painted Filter e.t.c.
