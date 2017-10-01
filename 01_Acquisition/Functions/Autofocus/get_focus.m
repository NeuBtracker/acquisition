function focusMeasure=get_focus(buf2,resize_factor,ofst)
    buf2=imresize(buf2,resize_factor);
    DH1 = buf2;
    DV1 = buf2;       
    DH=DH1(1:end-ofst,1:end-ofst)-DH1((ofst+1):end,1:end-ofst);
    DV=DV1(1:end-ofst,1:end-ofst)-DV1(1:end-ofst,(ofst+1):end);
    FM=max(DH,DV);
    focusMeasure = mean(mean((FM)));  
end