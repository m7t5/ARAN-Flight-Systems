function style_legend(lg, axc)
try
    set(lg,'Color',axc,'EdgeColor',[0.5 0.5 0.5],'TextColor','w');
catch
    try
        set(findobj(lg,'Type','text'),'Color','w');
    catch
    end
end
end