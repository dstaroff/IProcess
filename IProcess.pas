unit IProcess;

interface

{$reference System.Drawing.dll}

function GetData(address: integer): byte;
procedure SetData(address: integer; data: byte);

type
  IBitmap = class
  private 
    bmp: System.Drawing.Bitmap;
    bmpData: System.Drawing.Imaging.BitmapData;
    bytesPerPixel, height, width: integer;
    ptrFirstPixel: integer;
    locked: boolean;
    isEditExc: Exception := new Exception('This example of IBitmap is not editable. Use "StartEdit" method to do that.');
    
    procedure _Lock();
    procedure _Unlock();
  
  public 
    constructor Create(fileName: string);
    procedure StartEdit();
    procedure FinishEdit();
    function GetR(x, y: integer): byte;
    function GetG(x, y: integer): byte;
    function GetB(x, y: integer): byte;
    procedure SetR(x, y: integer; red: byte);
    procedure SetG(x, y: integer; green: byte);
    procedure SetB(x, y: integer; blue: byte);
    procedure Negative();
    procedure Shift(rShift, gShift, bShift: smallint);
    procedure Grayscale();
    procedure Threshold(level: byte);
    procedure Threshold(rLevel, gLevel, bLevel: byte);
    procedure BiTonal(rD, gD, bD, rL, gL, bL, level: byte);
    procedure Tint(rTint, gTint, bTint: byte);
    procedure Contrast(threshold: byte);
    procedure ColorBalance(rBal, gBal, bBal: byte);
    procedure ColorShading(rShade, gShade, bShade: byte);
    procedure Save(fileName: string);
    property Image: System.Drawing.Bitmap read bmp;
    property Editable: boolean read locked;
  end;

implementation

//Gets data from the memory with chosen address
function GetData(address: integer): byte;
var
  ptr: ^byte;
begin
  ptr := pointer(address);
  Result := ptr^;
end;

//Sets data to the memory with chosen address
procedure SetData(address: integer; data: byte);
var
  ptr: ^byte;
begin
  ptr := pointer(address);
  ptr^ := data;
end;

constructor IBitmap.Create(fileName: string);
var
  tempRectangle: System.Drawing.Rectangle;
begin
  
  try
    bmp := new System.Drawing.Bitmap(fileName);
    tempRectangle := new System.Drawing.Rectangle(0, 0, bmp.Width, bmp.Height);
    bytesPerPixel := System.Drawing.Bitmap.GetPixelFormatSize(bmp.PixelFormat) div 8;
    height := bmp.Height;
    width := bmp.Width;
    locked := false;
  except
    on e: System.Exception do
      raise new Exception('Can not to create an example of IBitmap. ' + e.Message);
  end;
end;

procedure IBitmap._Lock();
var
  tempRectangle: System.Drawing.Rectangle;
begin
  if (not locked) then
  begin
    tempRectangle := new System.Drawing.Rectangle(0, 0, bmp.Width, bmp.Height);
    bmpData := bmp.LockBits(tempRectangle, System.Drawing.Imaging.ImageLockMode.ReadWrite, bmp.PixelFormat);
    
    // TODO: support of all PixelFormats
    //
    if self.bmpData.PixelFormat <> System.Drawing.Imaging.PixelFormat.Format24bppRgb then
      raise new Exception('Can not to create an example of IBitmap');
    //
    
    ptrFirstPixel := bmpData.Scan0.ToInt32;
    locked := true;
  end
  else raise new Exception('This example of IBitmap is already editable.');
end;

procedure IBitmap._Unlock();
begin
  if (locked) then
  begin
    bmp.UnlockBits(bmpData);
    locked := false;
  end
  else raise new Exception('This example of IBitmap is already uneditable.');
end;

procedure IBitmap.StartEdit();
begin
  _Lock();
end;

procedure IBitmap.FinishEdit();
begin
  _Unlock();
end;

function IBitmap.GetR(x, y: integer): byte;
begin
  if (self.Editable) then
  begin
    try
      GetR := GetData(self.ptrFirstPixel + (y - 1) * self.bmpData.Stride + (x - 1) * self.bytesPerPixel + 2);
    except
      on e: System.Exception do
        raise new Exception('Can not to use "GetR" method. ' + e.Message);
    end;
  end
  else
    raise self.isEditExc;
end;

function IBitmap.GetG(x, y: integer): byte;
begin
  if (self.Editable) then
  begin
    try
      GetG := GetData(self.ptrFirstPixel + (y - 1) * self.bmpData.Stride + (x - 1) * self.bytesPerPixel + 1)
    except
      on e: System.Exception do
        raise new Exception('Can not to use "GetG" method. ' + e.Message);
    end;
  end
  else
    raise self.isEditExc;
end;

function IBitmap.GetB(x, y: integer): byte;
begin
  if (self.Editable) then
  begin
    try
      GetB := GetData(self.ptrFirstPixel + (y - 1) * self.bmpData.Stride + (x - 1) * self.bytesPerPixel)
    except
      on e: System.Exception do
        raise new Exception('Can not to use "GetB" method. ' + e.Message);
    end;
  end
  else
    raise self.isEditExc;
end;

procedure IBitmap.SetR(x, y: integer; red: byte);
begin
  if (self.Editable) then
  begin
    try
      SetData(self.ptrFirstPixel + (y - 1) * self.bmpData.Stride + (x - 1) * self.bytesPerPixel + 2, red)
    except
      on e: System.Exception do
        raise new Exception('Can not to use "SetR" method. ' + e.Message);
    end;
  end
  else
    raise self.isEditExc;
end;

procedure IBitmap.SetG(x, y: integer; green: byte);
begin
  if (self.Editable) then
  begin
    try
      SetData(self.ptrFirstPixel + (y - 1) * self.bmpData.Stride + (x - 1) * self.bytesPerPixel + 1, green)
    except
      on e: System.Exception do
        raise new Exception('Can not to use "SetG" method. ' + e.Message);
    end;
  end
  else
    raise self.isEditExc;
end;

procedure IBitmap.SetB(x, y: integer; blue: byte);
begin
  if (self.Editable) then
  begin
    try
      SetData(self.ptrFirstPixel + (y - 1) * self.bmpData.Stride + (x - 1) * self.bytesPerPixel, blue)
    except
      on e: System.Exception do
        raise new Exception('Can not to use "SetB" method. ' + e.Message);
    end;
  end
  else
    raise self.isEditExc;
end;

procedure IBitmap.Negative();
begin
  if (self.Editable) then
  begin
    try
      for var y: integer := 1 to self.height do
      begin
        for var x: integer := 1 to self.width do
        begin
          self.SetR(x, y, 255 - GetR(x, y));
          self.SetG(x, y, 255 - GetG(x, y));
          self.SetB(x, y, 255 - GetB(x, y));
        end;
      end;
    except
      on e: System.Exception do
        raise new Exception('Can not to use "Invert" method. ' + e.Message);
    end;
  end
  else
    raise self.isEditExc;
end;

        // r, g, b: -255 - 255
procedure IBitmap.Shift(rShift, gShift, bShift: smallint);
begin
  if (self.Editable) then
  begin
    if ((rShift > 255) or (rShift < -255) or
                    (gShift > 255) or (gShift < -255) or
                    (bShift > 255) or (bShift < -255)) then
    begin
      raise new Exception('Wrong argument in method "Shift".');
    end;
    
    try
      for var y: integer := 1 to self.height do
      begin
        for var x: integer := 1 to self.width do
        begin
          var newR: byte := self.GetR(x, y);
          var newG: byte := self.GetG(x, y);
          var newB: byte := self.GetB(x, y);
          
          if (rShift >= 0) then
            if (newR + rShift > 255) then newR := 255 else newR += rShift
                        else
          if (newR + rShift < 0) then newR := 0 else newR += rShift;
          
          if (gShift >= 0) then
            if (newG + gShift > 255) then newG := 255 else newG += gShift
                        else
          if (newG + gShift < 0) then newG := 0 else newG += gShift;
          
          if (bShift >= 0) then
            if (newB + bShift > 255) then newB := 255 else newB += bShift
                        else
          if (newB + bShift < 0) then newB := 0 else newB += bShift;
          
          self.SetR(x, y, newR);
          self.SetG(x, y, newG);
          self.SetB(x, y, newB);
        end;
      end;
    except
      on e: System.Exception do
        raise new Exception('Can not to use "Shift" method. ' + e.Message);
    end;
  end
  else
    raise self.isEditExc;
end;

procedure IBitmap.Grayscale();
begin
  if (self.Editable) then
  begin
    try
      for var y: integer := 1 to self.height do
      begin
        for var x: integer := 1 to self.width do
        begin
          var newR: byte := self.GetR(x, y);
          var newG: byte := self.GetG(x, y);
          var newB: byte := self.GetB(x, y);
          
          newR := Round((newR + newG + newB) / 3);
          
          self.SetR(x, y, newR);
          self.SetG(x, y, newR);
          self.SetB(x, y, newR);
        end;
      end;
    except
      on e: System.Exception do
        raise new Exception('Can not to use "Grayscale" method. ' + e.Message);
    end;
  end
  else
    raise self.isEditExc;
end;

       // level: 0 - 255
procedure IBitmap.Threshold(level: byte);
begin
  if (self.Editable) then
  begin
    if ((level > 255) or (level < 0)) then
    begin
      raise new Exception('Wrong argument in method "Threshold".');
    end;
    
    try
      self.Grayscale();
      for var y: integer := 1 to self.height do
      begin
        for var x: integer := 1 to self.width do
        begin
          var newR: byte := self.GetR(x, y);
          
          if (newR < level) then newR := 0 else newR := 255;
          
          self.SetR(x, y, newR);
          self.SetG(x, y, newR);
          self.SetB(x, y, newR);
        end;
      end;
    except
      on e: System.Exception do
        raise new Exception('Can not to use "Threshold" method. ' + e.Message);
    end;
  end
  else
    raise self.isEditExc;
end;

       // r, g, b: 0 - 255
procedure IBitmap.Threshold(rLevel, gLevel, bLevel: byte);
begin
  if (self.Editable) then
  begin
    if ((rLevel > 255) or (rLevel < 0) or
            (gLevel > 255) or (gLevel < 0) or
            (bLevel > 255) or (bLevel < 0)) then
    begin
      raise new Exception('Wrong argument in method "Threshold".');
    end;
    
    try
      for var y: integer := 1 to self.height do
      begin
        for var x: integer := 1 to self.width do
        begin
          var newR: byte := self.GetR(x, y);
          var newG: byte := self.GetG(x, y);
          var newB: byte := self.GetB(x, y);
          
          if (newR < rLevel) then newR := 0 else newR := 255;
          if (newG < gLevel) then newG := 0 else newG := 255;
          if (newB < bLevel) then newB := 0 else newB := 255;
          
          self.SetR(x, y, newR);
          self.SetG(x, y, newG);
          self.SetB(x, y, newB);
        end;
      end;
    except
      on e: System.Exception do
        raise new Exception('Can not to use "Threshold" method. ' + e.Message);
    end;
  end
  else
    raise self.isEditExc;
end;

procedure IBitmap.BiTonal(rD, gD, bD, rL, gL, bL, level: byte);
begin
  if (self.Editable) then
  begin
    if (((level > 255) or (level < 0)) or
              (rD > 255) or (rD < 0) or
              (gD > 255) or (gD < 0) or
              (bD > 255) or (bD < 0) or
              (rL > 255) or (rL < 0) or
              (gL > 255) or (gL < 0) or
              (bL > 255) or (bL < 0)) then
    begin
      raise new Exception('Wrong argument in method "BiTonal".');
    end;
    
    try
      self.Grayscale();
      for var y: integer := 1 to self.height do
      begin
        for var x: integer := 1 to self.width do
        begin
          var newR: byte := GetR(x, y);
          var newG: byte;
          var newB: byte;
          
          if (newR < level) then
          begin
            newR := rD;
            newG := gD;
            newB := bD;
          end
              else
          begin
            newR := rL;
            newG := gL;
            newB := bL;
          end;
          
          self.SetR(x, y, newR);
          self.SetG(x, y, newG);
          self.SetB(x, y, newB);
        end;
      end;
    except
      on e: System.Exception do
        raise new Exception('Can not to use "BiTonal" method. ' + e.Message);
    end;
  end
  else
    raise self.isEditExc;
end;

        // r, g, b: 0 - 255
procedure IBitmap.Tint(rTint, gTint, bTint: byte);
begin
  if (self.Editable) then
  begin
    if ((rTint > 255) or (rTint < 0) or
                    (gTint > 255) or (gTint < 0) or
                    (bTint > 255) or (bTint < 0)) then
    begin
      raise new Exception('Wrong argument in method "Tint".');
    end;
    
    try
      for var y: integer := 1 to self.height do
      begin
        for var x: integer := 1 to self.width do
        begin
          var R: byte := self.GetR(x, y);
          var G: byte := self.GetG(x, y);
          var B: byte := self.GetB(x, y);
          
          var rT: real := rTint / 255;
          var gT: real := gTint / 255;
          var bT: real := bTint / 255;
          
          var newR: real := R + (255 - R) * rT;
          var newG: real := G + (255 - G) * gT;
          var newB: real := B + (255 - B) * bT;
          
          if (newR > 255) then newR := 255;
          if (newG > 255) then newG := 255;
          if (newB > 255) then newB := 255;
          
          self.SetR(x, y, Round(newR));
          self.SetG(x, y, Round(newG));
          self.SetB(x, y, Round(newB));
        end;
      end;
    except
      on e: System.Exception do
        raise new Exception('Can not to use "Tint" method. ' + e.Message);
    end;
  end
  else
    raise self.isEditExc;
end;

        // threshold: 0 - 100;
procedure IBitmap.Contrast(threshold: byte);
var
  contrastLevel: real;
begin
  if (self.Editable) then
  begin
    if ((threshold > 255) or (threshold < 0)) then
    begin
      raise new Exception('Wrong argument in method "Contrast".');
    end;
    
    try
      contrastLevel := Sqr((100 + threshold) / 100);
      
      for var y: integer := 1 to height do
      begin
        for var x: integer := 1 to width do
        begin
          var newR: real := ((((self.GetR(x, y) / 255) - 0.5) * contrastLevel) + 0.5) * 255;
          var newG: real := ((((self.GetG(x, y) / 255) - 0.5) * contrastLevel) + 0.5) * 255;
          var newB: real := ((((self.GetB(x, y) / 255) - 0.5) * contrastLevel) + 0.5) * 255;
          
          if (newR > 255) then
            newR := 255
          else if (newR < 0) then
            newR := 0;
          
          if (newG > 255) then
            newG := 255
          else if (newG < 0) then
            newG := 0;
          
          if (newB > 255) then
            newB := 255
          else if (newB < 0) then
            newB := 0;
          
          self.SetR(x, y, Round(newR));
          self.SetG(x, y, Round(newG));
          self.SetB(x, y, Round(newB));
        end;
      end;
    except
      on e: System.Exception do
        raise new Exception('Can not to use "Contrast" method. ' + e.Message);
    end;
  end
  else
    raise self.isEditExc;
end;

    // r, g, b: 0 - 255
procedure IBitmap.ColorBalance(rBal, gBal, bBal: byte);
begin
  if (self.Editable) then
  begin
    if ((rBal > 255) or (rBal < 0) or
                    (gBal > 255) or (gBal < 0) or
                    (bBal > 255) or (bBal < 0)) then
    begin
      raise new Exception('Wrong argument in method "ColorBalance".');
    end;
    
    try
      for var y: integer := 1 to self.height do
      begin
        for var x: integer := 1 to self.width do
        begin
          var newR: byte := self.GetR(x, y);
          var newG: byte := self.GetG(x, y);
          var newB: byte := self.GetB(x, y);
          
          if (rBal = 0) then rBal := 1;
          if (gBal = 0) then gBal := 1;
          if (bBal = 0) then bBal := 1;
          
          newR := Round(255 / rBal * newR);
          newG := Round(255 / gBal * newG);
          newB := Round(255 / bBal * newB);
          
          if (newR > 255) then 
            newR := 255
          else if (newR < 0) then
            newR := 0;
          
          if (newG > 255) then 
            newG := 255
          else if (newG < 0) then
            newG := 0;
          
          if (newB > 255) then 
            newB := 255
          else if (newB < 0) then
            newB := 0;
          
          self.SetR(x, y, newR);
          self.SetG(x, y, newG);
          self.SetB(x, y, newB);
        end;
      end;
    except
      on e: System.Exception do
        raise new Exception('Can not to use "ColorBalance" method. ' + e.Message);
    end;
  end
  else
    raise self.isEditExc;
end;

    // r, g, b: 
procedure IBitmap.ColorShading(rShade, gShade, bShade: byte);
begin
  if (self.Editable) then
  begin
    if ((rShade > 255) or (rShade < 0) or
                    (gShade > 255) or (gShade < 0) or
                    (bShade > 255) or (bShade < 0)) then
    begin
      raise new Exception('Wrong argument in method "ColorShading".');
    end;
    
    try
      for var y: integer := 1 to self.height do
      begin
        for var x: integer := 1 to self.width do
        begin
          var R: byte := self.GetR(x, y);
          var G: byte := self.GetG(x, y);
          var B: byte := self.GetB(x, y);
          
          var rS: real := rShade / 255;
          var gS: real := gShade / 255;
          var bS: real := bShade / 255;
          
          var newR: real := R * rS;
          var newG: real := G * gS;
          var newB: real := B * bS;
          
          if (newR < 0) then newR := 0;
          if (newG < 0) then newG := 0;
          if (newB < 0) then newB := 0;
          
          self.SetR(x, y, Round(newR));
          self.SetG(x, y, Round(newG));
          self.SetB(x, y, Round(newB));
        end;
      end;
    except
      on e: System.Exception do
        raise new Exception('Can not to use "ColorShading" method. ' + e.Message);
    end;
  end
  else
    raise self.isEditExc;
end;

procedure IBitmap.Save(fileName: string);
begin
  try
    self.bmp.Save(fileName);
  except
    on e: System.Exception do
      raise new Exception('Can not to use "Save" method. ' + e.Message);
  end;
end;

end.