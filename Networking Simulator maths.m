clc;
clear;
close all;

%%\ =========================================================
%       NETWORK ROUTING SIMULATOR USING GRAPH THEORY
%       Own Implementation of Dijkstra's Algorithm
% ==========================================================

fprintf('===============================================\n');
fprintf('       NETWORK ROUTING SIMULATOR\n');
fprintf('       Using Graph Theory & Dijkstra\n');
fprintf('===============================================\n');

%%\ STEP 1: Number of Routers
n = getNumber('Enter number of routers: ');
if n < 2 || floor(n) ~= n
    error('Number of routers must be an integer greater than 1.');
end

%%\ STEP 2: Number of Network Connections
m = getNumber('Enter number of connections: ');
if m < 1 || floor(m) ~= m
    error('Number of connections must be a positive integer.');
end

%%\ STEP 3: Create Adjacency Matrix
A = zeros(n);

fprintf('Enter each connection on ONE line: Router1 Router2 Distance\n');
fprintf('Example: 1 2 4   (or 1,2,4)\n');

for i = 1:m

    vals = [];
    while numel(vals) ~= 3
        txt = input(sprintf('Connection %d: ', i), 's');
        parts = regexp(strtrim(txt), '[\s,]+', 'split');
        vals = str2double(parts);
        if numel(vals) ~= 3 || any(isnan(vals))
            fprintf('  Please enter exactly 3 numbers.\n');
            vals = [];
        end
    end

    u = vals(1);
    v = vals(2);
    w = vals(3);

    if u < 1 || u > n || v < 1 || v > n || floor(u) ~= u || floor(v) ~= v
        error('Router number must be an integer between 1 and %d.', n);
    end
    if u == v
        error('A router cannot be connected to itself.');
    end
    if w <= 0
        error('Distance/Cost must be greater than 0.');
    end

    A(u,v) = w;
    A(v,u) = w;

end

%%\ STEP 4: Display Adjacency Matrix
fprintf('\n===============================================\n');
fprintf('             ADJACENCY MATRIX\n');
fprintf('===============================================\n');
disp(A);

%%\ STEP 5: Source and Destination
source = getNumber('Enter source router: ');
destination = getNumber('Enter destination router: ');

if source < 1 || source > n || ...
   destination < 1 || destination > n || ...
   floor(source) ~= source || floor(destination) ~= destination
    error('Source/Destination must be valid router numbers.');
end
if source == destination
    error('Source and destination must be different.');
end

%%\ STEP 6: Check Network Connectivity (BFS)
visited = false(1,n);
queue = source;
visited(source) = true;

while ~isempty(queue)
    current = queue(1);
    queue(1) = [];
    for j = 1:n
        if A(current,j) > 0 && ~visited(j)
            visited(j) = true;
            queue(end+1) = j;
        end
    end
end

if all(visited)
    networkStatus = 'CONNECTED';
else
    networkStatus = 'NOT CONNECTED';
end

%%\ STEP 7: Run Dijkstra
[distance, previous] = myDijkstra(A, source);

%%\ STEP 8: Destination unreachable
if isinf(distance(destination))

    fprintf('\n===============================================\n');
    fprintf('Destination cannot be reached.\n');
    fprintf('===============================================\n');

    plotNetwork(A, n, source, destination, [], Inf, networkStatus);
    return;

end

%%\ STEP 9: Reconstruct Shortest Path
path = destination;
current = destination;

while current ~= source
    current = previous(current);
    path = [current path];
end

totalCost = distance(destination);

%%\ STEP 10: Display Results (console)
pathStr = char(strjoin("Router " + string(path), " -> "));

fprintf('\n===============================================\n');
fprintf('              ROUTING RESULT\n');
fprintf('===============================================\n');
fprintf('Source Router      : Router %d\n', source);
fprintf('Destination Router : Router %d\n', destination);
fprintf('Shortest Path      : %s\n', pathStr);
fprintf('Total Cost         : %.2f\n', totalCost);
fprintf('Network Status     : %s\n', networkStatus);
fprintf('===============================================\n');

%%\ STEP 11: Draw the graph
plotNetwork(A, n, source, destination, path, totalCost, networkStatus);

fprintf('Graph generated successfully.\n');


%%\ =========================================================
%              HELPER: DRAW THE NETWORK FIGURE
% ==========================================================

function plotNetwork(A, n, source, destination, path, totalCost, networkStatus)

    % Colors
    cNode   = [0.20 0.45 0.80];   % blue
    cEdge   = [0.75 0.75 0.78];   % light gray
    cPath   = [0.85 0.10 0.10];   % red
    cSource = [0.10 0.70 0.30];   % green
    cDest   = [1.00 0.80 0.00];   % yellow
    cPathNode = [1.00 0.55 0.10]; % orange (middle routers on path)

    G = graph(A);

    fig = figure('Name','Network Routing Simulator', ...
                 'NumberTitle','off', ...
                 'Color','white', ...
                 'Position',[100 80 1000 650]);

    ax = axes('Parent',fig, ...
              'Position',[0.04 0.27 0.68 0.63], ...
              'Color','white');

    p = plot(ax, G, ...
        'Layout','circle', ...
        'NodeLabel',string(1:n), ...
        'EdgeLabel',G.Edges.Weight, ...
        'Marker','o', ...
        'MarkerSize',11, ...
        'NodeColor',cNode, ...
        'EdgeColor',cEdge, ...
        'LineWidth',2, ...
        'NodeLabelColor',[0.1 0.1 0.1], ...
        'EdgeLabelColor',[0.25 0.25 0.25], ...
        'NodeFontSize',13, ...
        'EdgeFontSize',11);

    axis(ax,'off');
    axis(ax,'equal');

    % Highlight shortest path (only the path edges)
    if ~isempty(path)
        highlight(p, path, 'NodeColor',cPathNode, 'MarkerSize',13);
        highlight(p, path(1:end-1), path(2:end), ...
            'EdgeColor',cPath, 'LineWidth',5);
    end

    % Source and destination on top
    highlight(p, source, 'NodeColor',cSource, 'MarkerSize',16);
    highlight(p, destination, 'NodeColor',cDest, 'MarkerSize',16);

    % Title
    title(ax, 'NETWORK ROUTING SIMULATOR', ...
          'FontSize',18, 'FontWeight','bold', 'Color',[0.1 0.2 0.4]);

    % Legend (dummy points, so colors match exactly)
    hold(ax,'on');
    h1 = plot(ax, NaN, NaN, 'o', 'MarkerFaceColor',cSource, ...
              'MarkerEdgeColor',cSource, 'MarkerSize',10);
    h2 = plot(ax, NaN, NaN, 'o', 'MarkerFaceColor',cDest, ...
              'MarkerEdgeColor',cDest, 'MarkerSize',10);
    h3 = plot(ax, NaN, NaN, 'o', 'MarkerFaceColor',cPathNode, ...
              'MarkerEdgeColor',cPathNode, 'MarkerSize',10);
    h4 = plot(ax, NaN, NaN, 'o', 'MarkerFaceColor',cNode, ...
              'MarkerEdgeColor',cNode, 'MarkerSize',10);
    h5 = plot(ax, NaN, NaN, '-', 'Color',cPath, 'LineWidth',4);
    h6 = plot(ax, NaN, NaN, '-', 'Color',cEdge, 'LineWidth',2);
    hold(ax,'off');

    lg = legend(ax, [h1 h2 h3 h4 h5 h6], ...
        {'Source router','Destination router','Router on path', ...
         'Other router','Shortest path','Other connection'}, ...
        'FontSize',11, 'Box','on', 'Color','white', ...
        'TextColor','black', 'EdgeColor',[0.7 0.7 0.7]);
    lg.Position = [0.75 0.55 0.23 0.28];

    % Results panel
    if isempty(path)
        pathText = 'None (destination unreachable)';
        costText = '-';
    else
        pathText = char(strjoin("R" + string(path), "  ->  "));
        costText = sprintf('%.2f', totalCost);
    end

    infoText = { ...
        'ROUTING INFORMATION', ...
        sprintf('Source            :  Router %d', source), ...
        sprintf('Destination      :  Router %d', destination), ...
        sprintf('Shortest Path  :  %s', pathText), ...
        sprintf('Total Cost       :  %s', costText), ...
        sprintf('Network Status :  %s', networkStatus)};

    annotation(fig, 'textbox', [0.04 0.03 0.68 0.20], ...
        'String',infoText, ...
        'FitBoxToText','off', ...
        'BackgroundColor',[0.95 0.97 1.00], ...
        'Color','black', ...
        'FontSize',12, ...
        'FontName','Consolas', ...
        'EdgeColor',[0.20 0.45 0.80], ...
        'LineWidth',1.5, ...
        'Margin',10);

end


%%\ =========================================================
%              HELPER: SAFE NUMERIC INPUT
% ==========================================================

function val = getNumber(promptText)

    val = NaN;

    while isnan(val)
        txt = strtrim(input(promptText, 's'));
        if ~isempty(regexp(txt, '^[+-]?(\d+\.?\d*|\.\d+)$', 'once'))
            val = str2double(txt);
        else
            fprintf('  Please enter a single number.\n');
        end
    end

end


%%\ =========================================================
%              OWN DIJKSTRA ALGORITHM
% ==========================================================

function [dist, previous] = myDijkstra(A, source)

    n = size(A,1);
    dist = inf(1,n);
    dist(source) = 0;
    previous = zeros(1,n);
    visited = false(1,n);

    for count = 1:n

        minDistance = inf;
        current = -1;

        for i = 1:n
            if ~visited(i) && dist(i) < minDistance
                minDistance = dist(i);
                current = i;
            end
        end

        if current == -1
            break;
        end

        visited(current) = true;

        for neighbor = 1:n
            if A(current,neighbor) > 0 && ~visited(neighbor)
                newDistance = dist(current) + A(current,neighbor);
                if newDistance < dist(neighbor)
                    dist(neighbor) = newDistance;
                    previous(neighbor) = current;
                end
            end
        end

    end

end

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
