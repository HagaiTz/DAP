%%%%%%%
function plotTractParams(fg,vals)

	
    radius = 5; subdiv = 30; cmap = 'jet';
    numfib = 100;
    
    if(isempty(fg.fibers)), return; end
    core = dtiComputeSuperFiberRepresentation(fg,[],numfib);
    coords = core.fibers{1};
    
    crange = [min(vals)*0.9 1.1*max(vals)];
    AFQ_RenderFibers(fg,'numfibers',numfib);
    AFQ_RenderTractProfile(coords,radius,vals,subdiv,cmap,crange);
end