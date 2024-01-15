
s={touchsingle touch presshuman pressrobot steelbolts plasticcaps melting damages};

for i=1:8

  figure;
   subplot(1,3,1)
    Y=tsne(s{1,i}.rms10k);
    scatter(Y(:,1),Y(:,2),'filled')
    hold on
    Y=tsne(s{1,i}.phase10k);
    scatter(Y(:,1),Y(:,2),'filled')
    hold on
    subplot(1,3,2)
      Y=tsne( s{1,i}.rms50k);
       scatter(Y(:,1),Y(:,2),'filled')
    hold on
    Y=tsne(s{1,i}.phase50k);
    scatter(Y(:,1),Y(:,2),'filled')
    hold on
    subplot(1,3,3)
       Y=tsne(s{1,i}.rms100k);
       scatter(Y(:,1),Y(:,2),'filled')
    hold on
    Y=tsne(s{1,i}.phase100k);
    scatter(Y(:,1),Y(:,2),'filled')
    hold on
end

%%

asd=[];
for i=1:8
   asd=[asd  ;(s{1,i}.rms10k)];
end

Y=tsne(asd);
j=1;
for i=1:8
    len=size((s{1,i}.rms10k),1);
    scatter(Y(j:j+len-1,1),Y(j:j+len-1,2),'filled')
    j=j+len;
    hold on
end
