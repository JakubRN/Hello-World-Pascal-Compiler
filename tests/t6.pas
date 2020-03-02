program example(input, output);
var x, y: integer;
var g,h:real;

function f(a:integer;b:real):integer;
begin
 f:=a+10
end;

procedure p(a:integer;b:real);
begin
 b:=a+10
end;


begin
 p(g,x);
 x:=f(x,g)
end.
