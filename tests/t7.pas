program example(input, output);
var x, y: integer;
var g,h:real;

function f(a:integer;b:real):integer;
begin
 f:=a+10
end;

begin
 g:=1;
 x:=2;
 x:=f(g,x);
 write(x)
end.
