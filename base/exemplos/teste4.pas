program comandoWhile;
var n, k: integer;
	f1, f2, f3:integer;
begin
	f1:=0; f2:=1; k:=1;
	read(f2, k);
	write(f2,k+2+1+n,3);
	while (k <= 6) do
		begin
			f3:=f2+f1;
			f1:=f2;
			f2:=f3;
			k:=k+1;
			while (k <= 3) do 
				k:=k;
		end;
end.
