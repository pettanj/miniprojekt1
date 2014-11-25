function [A,nodes]=GenerateMatrix(gname)

% [A, source_nodes] = GeneratMatrix(gname)
% Matlabfunktion som skapar en koefficientmatris A och source_nodes
% som innehaller nummer pa de noder som ar kallor (vattentorn).
% Inparametern gname maste vara en textstrang. Programmet skapar aven en 
% graf over ledningssystemet, med bla punkter for oppna kranar (sankor) och 
% roda punkter for vattentorn (kallor).
%
% Data som kravs ska finnas lagrade i tre textfiler: 
%   gname.graph    eller  gname_graph.txt 
%   gname.coords   eller  gname_coords.txt
%   gname.source   eller  gname_source.txt 
% dar gname ?r en textstrang som innehaller forsta delen (prefixet) av
% namnet pa filerna. De tre filerna maste finnas i samma katalog som
% GenerateMatrix.
% Filerna ska inneh?lla
%   gname_coords.txt - En lista over x- och y-koordinaterna for de olika 
%                      noderna i natet. Nodens radnummer blir dess index i 
%                      natet och i losningsvektorn.
%   gname_graph.txt  - En lista over alla kopplingar i natet. Pa varje rad 
%                      star index (radnumren) for de tva noder som ar 
%                      sammankopplade.
%   gname_source.txt - En lista over kallor och sankor i natet. Pa varje 
%                      rad anges index for kallan/sankan, foljt av 1 om det 
%                      ar en kalla (vattentorn) respektive 0 om det ar en 
%                      sanka (oppen kran).
%
% Exempel:
%   Data for vattenledningsnatet i MinStad ligger lagrat i de tre filerna
%   MinStad_coords.txt, MinStad_graph.txt, MinStad_source.txt. Anropet 
%   (kommandot)
%      [A, k_noder] = GenerateMatrix('MinStad')
%   ger resulatet en matris med variabelnamnet A och vektor med index over
%   med variabelnamn k_noder.
%
% Jarmo Rantakokko, Karl Ljungkvist, Josefin Ahlkrona, Stefan Palsson
%
% Date: Jun 18, 2012. Revised Sept 2013


K = 0.001;

% Create file names
% Create .graph-file
if exist([gname '_graph.txt'],'file')
    gfile = [gname '_graph.txt'];
elseif exist([gname,'.graph'],'file')
    gfile = [gname '.graph'];
else
    error(['No file ',gname,'.graph or ' gname,'_graph.txt exist']);
end

% Create .coords-file
if exist([gname '_coords.txt'],'file')
    cfile = [gname '_coords.txt'];
elseif exist([gname,'.coords'],'file')
    cfile = [gname '.coords'];
else
    error(['No file ',gname,'.coords or ' gname,'_coords.txt exist']);
end

% Create .source-file
if exist([gname '_source.txt'],'file')
    sfile = [gname '_source.txt'];
elseif exist([gname,'.source'],'file')
    sfile = [gname '.source'];
else
    error(['No file ',gname,'.source or ' gname,'_source.txt exist']);
end

% Read the graph coordinates
  fcoord = fopen(cfile,'r');
  if fcoord == -1
      error(['No such file ' cfile]);
  end

  % skip comments
  skip = '%';
  while (skip == '%')
      ag = fgets(fcoord);
      skip = sscanf(ag,'%s',1);
  end
  gfirst = sscanf(ag,'%e %e',2);
  G = fscanf(fcoord,'%e %e',[2, inf]);
  G = [ gfirst'; G'];
  fclose(fcoord);
  [n, m] = size(G);


% Read the graph file with adjacency information
  A = zeros(n,n);
  fgraph = fopen(gfile,'r');
  if fgraph == -1
      error(['No such file ' gfile]);
  end

  % skip comments
  skip = '%';
  while (skip == '%')
    ag = fgets(fgraph);
    skip = sscanf(ag,'%s',1);
  end


  acfirst = sscanf(ag,'%u %u',2);
  acs = fscanf(fgraph,'%u %u',[2, inf]);
  acs = [ acfirst'; acs'];
  for i=1:size(acs,1)
      i1 = acs(i,1);
      i2 = acs(i,2);
      dist = sqrt(sum((G(i1,:) - G(i2,:)).^2));
      A(i1,i2) = K*dist;
      A(i2,i1) = K*dist;
  end


  % acfirst = sscanf(ag,'%u',inf);
  % A(1,acfirst') = K*sqrt(sum((ones(length(acfirst),1)*G(1,:) - G(acfirst,:)).^2,2))';

  % for i = 2:n
  %   ag = fgets(fgraph);
  %   ac = sscanf(ag,'%u',inf);

  %   A(i,ac') = K*sqrt(sum((ones(length(ac),1)*G(i,:) - G(ac,:)).^2,2))';
  %   % A(i,ac') = ones(1,length(ac));
  % end


  fclose(fgraph);


% Display the graph
  clf;
  whitebg('w'); hold on;
  gplot(A,G,'k-'); plot(G(:,1),G(:,2),'ko');
  scale=max(50,n);
  xmax=max(G(:,1));xmin=min(G(:,1)); dx=(xmax-xmin)/scale;
  ymax=max(G(:,2));ymin=min(G(:,2)); dy=(ymax-ymin)/scale;
  if n < 40
      for i=1:n
          text(G(i,1)+dx,G(i,2)+dy,num2str(i));
      end
  end


% Compute diagonal
  for i=1:n
      s=sum(A(i,:));
      A(i,i)=-s;
  end

% Set sources and sinks
 fsink = fopen(sfile,'r');
 if fsink == -1
      error(['No such file ' sfile]);
  end

  skip = '%';
  while (skip == '%')
    ag = fgets(fsink);
    skip = sscanf(ag,'%s',1);
  end

  sfirst = sscanf(ag,'%d %d',2)';
  sink = fscanf(fsink,'%d %d',[2, inf])';
  fclose(fsink);
  sink = [sfirst ; sink];

  nodescounter=0;
  nsink=size(sink,1);
  for i=1:nsink
      row=sink(i,1);
      A(row,:)=0; A(row,row)=1;
      if (sink(i,2)>0)
        plot(G(row,1),G(row,2),'r.','MarkerSize',10);
        nodescounter=nodescounter+1;
        nodes(nodescounter)=sink(i,1);

      else
          plot(G(row,1),G(row,2),'b.','MarkerSize',10);
      end
  end

  xspace=(xmax-xmin)*0.05;yspace=(ymax-ymin)*0.05;
  axis([xmin-xspace xmax+xspace ymin-yspace ymax+yspace]);
  hold off;

  nodes=nodes';
