load("ThomasGraphWeights.mat");

electrode = electrodes(:,1:2); % Example data

% Extract unique combinations
unique_combinations = unique(sort(electrode, 2), 'rows'); % Sort each row before finding unique combinations

% Create a mapping from unique combinations to values ranging from 1 to the number of unique combinations
combination_map = containers.Map('KeyType', 'char', 'ValueType', 'int32');
combination_count = size(unique_combinations, 1);
for i = 1:combination_count
    combination_map(sprintf('%d%d', unique_combinations(i, 1), unique_combinations(i, 2))) = i;
end

% Convert each pair to combination identifier
converted_array = zeros(size(electrode, 1), 1);
for i = 1:size(electrode, 1)
    sorted_pair = sort(electrode(i, :));
    combination_key = sprintf('%d%d', sorted_pair(1), sorted_pair(2));
    converted_array(i) = combination_map(combination_key);
end



electrode = electrodes(:,3:4); % Example data

% Extract unique combinations
unique_combinations = unique(sort(electrode, 2), 'rows'); % Sort each row before finding unique combinations

% Create a mapping from unique combinations to values ranging from 1 to the number of unique combinations
combination_map = containers.Map('KeyType', 'char', 'ValueType', 'int32');
combination_count = size(unique_combinations, 1);
for i = 1:combination_count
    combination_map(sprintf('%d%d', unique_combinations(i, 1), unique_combinations(i, 2))) = i;
end

% Convert each pair to combination identifier

for i = 1:size(electrode, 1)
    sorted_pair = sort(electrode(i, :));
    combination_key = sprintf('%d%d', sorted_pair(1), sorted_pair(2));
    converted_array(i,2) = combination_map(combination_key);
end



% 
% I=zeros(3358*2,4);
% 
% I(1:end/2,2)=pca;
% 
% I(1:240,1)=analytic;
% 
% 
% 
% I(1:2:end,4)=combs2;
% I(2:2:end,4)=combs2_y;
% 
% [B,I(1:2:end,3)] = sort(weights,'descend');
% 
% [B,I(2:2:end,3)] = sort(weights_y,'descend');
% 
%  len=240;
% 
% 
% 
% 
% asd=I(:,1);
%  for i = 1:len
%      a=0;
%      if asd(i)>1679
%          asd(i)=asd(i)-1679;
%          a=28;
%      end
%      s(i)=converted_array(asd(i),1);
%     t(i)=converted_array(asd(i),2);
%      %pause();
%      %clf
%  end
% 
%    G = graph(s,t);
%    h= plot(G);
% layout(h,'circle')
% 
% 
% figure;
% 
% 
% 
% asd=I(:,2);
%  for i = 1:len
%      a=0;
%      if asd(i)>1679
%          asd(i)=asd(i)-1679;
%          a=28;
%      end
%      s(i)=converted_array(asd(i),1);
%     t(i)=converted_array(asd(i),2);
%      %pause();
%      %clf
%  end
% 
%    G = graph(s,t);
%    h= plot(G);
% layout(h,'circle')
% 
% figure;
% 
% asd=I(:,3);
%  for i = 1:len
%      a=0;
%      if asd(i)>1679
%          asd(i)=asd(i)-1679;
%          a=28;
%      end
%      s(i)=converted_array(asd(i),1);
%     t(i)=converted_array(asd(i),2);
%      %pause();
%      %clf
%  end
% 
%    G = graph(s,t);
%    h= plot(G);
% layout(h,'circle')
% 
% 
% figure;
% 
% asd=I(:,4);
%  for i = 1:len
%      a=0;
%      if asd(i)>1679
%          asd(i)=asd(i)-1679;
%          a=28;
%      end
%      s(i)=converted_array(asd(i),1);
%     t(i)=converted_array(asd(i),2);
%      %pause();
%      %clf
%  end
% 
%    G = graph(s,t);
%    h= plot(G);
% layout(h,'circle')
% 
% 
% 
% 
% 
% 
% 
%  len=928;
% 
% 
% asd=adadinds;
%  for i = 1:len
%      a=0;
%      if asd(i)>863040/2
%          asd(i)=asd(i)-863040/2;
%          a=28;
%      end
%      s(i)=converted_array(asd(i),1);
%     t(i)=converted_array(asd(i),2);
%      %pause();
%      %clf
%  end
% 
%    G = graph(s,t);
%    h= plot(G);
% layout(h,'force','UseGravity',true)

%% David adding

 len=928;
 
  
% asd=adadinds;
asd=combinedranking(1:928);
 for i = 1:len
     a=0;
     if asd(i)>863040/2
         asd(i)=asd(i)-863040/2;
         a=28;
     end
     s(i)=converted_array(asd(i),1);
    t(i)=converted_array(asd(i),2);
     %pause();
     %clf
 end

   G = graph(s,t);
   h= plot(G);
% layout(h,'force','UseGravity',true)
layout(h,'subspace3');


