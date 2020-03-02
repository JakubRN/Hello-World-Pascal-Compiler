program example(input, output);
var x, y: integer;
var g,h:real;

function f(a:integer;b:real):integer;
begin
 f:=a+10+3.5*b
end;

begin
 x:=f(3,12.0);
 write(x)
end.
