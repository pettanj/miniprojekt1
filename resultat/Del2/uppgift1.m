prompt = 'Vilken stad vill du köra? ';
city = input(prompt,'s');
[A, nodes] = GenerateMatrix(city);
%prompt = 'Vilket tryck ska vara i vattentornet? ';
%result = input(prompt);
n = size(A,1);
b = zeros(n, 1);
mode = 1;

while true
    prompt = 'Vilket tryck ska vara i vattentornet? ';
    result = input(prompt);
    %sätta in vattentorn
    i = 1;
    while i <= length(nodes)
       b(nodes(i),1) = result;
       i = i+1;
    end      
    x = A\b;
    %beräkna medeltryck och tryckvariation
    medeltryck = mean(x);
    tryckvariation = std(x);
    %printa medeltryck och variation
    disp('Medeltryck: ');
    disp(medeltryck);
    disp('Tryckvariation: ');
    disp(tryckvariation);
    prompt = 'Vill du skriva ut diagram? ';
    result = input(prompt, 's');
    switch result
        case 'ja'
            %skriva ut diagrammet
            bar(x, 'G')
            title('Lösning')
            ylabel('tryckvärden')
            xlabel('Knutpunkter')
    end
    prompt = 'fortsätta? ';
    result = input(prompt,'s');
    switch result
        case 'nej'
            break;
    end

end


