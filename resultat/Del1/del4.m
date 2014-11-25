row1 = [1.0 0 0 0 0 0];
row2 = [0.3 -1.3 0.5 0.5 0 0];
row3 = [0 0.5 -1.6 0.6 0 0.5];
row4 = [0 0.5 0.6 -1.6 0.5 0];
row5 = [0 0 0 0 1.0 0];
row6 = [0 0 0 0 0 1.0];

A = [row1; row2; row3; row4; row5; row6];

medeltryckZ = 0;
a = 0;
while(medeltryckZ < 20)
   
   v1 = [a; 0; 0; 0; 0; 0];
   z = A\v1;
   a = a+1;
   medeltryckZ = mean(z);
end
disp('Tryck för att uppnå medeltryck>20: ');
disp(a-1);
disp('medeltrycket: ');
disp(medeltryckZ);
disp(z);