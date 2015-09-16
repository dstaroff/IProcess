program Test;

uses
  IProcess;

var
  img: IBitmap := new IBitmap('one.jpg');

begin
  
  img.StartEdit();
  img.Tint(64, 0, 0);
  img.Contrast(15);
  img.FinishEdit();
  img.Save('two.jpg');
  
end.