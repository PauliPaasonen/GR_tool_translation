
function events = detect_events(df_data, MF_gr_points, MC_gr_points, AT_gr_points, mc_area_edges, mgsc)

pairs = {};

MF_keys = fieldnames(MF_gr_points);
MC_keys = fieldnames(MC_gr_points);
AT_keys = fieldnames(AT_gr_points);

% -----------------------------
% BUILD PAIRS (faithful logic)
% -----------------------------
for i = 1:length(MF_keys)

    MF_line = MF_gr_points.(MF_keys{i});
    pts = MF_line.fitted_points;

    MF_t = cellfun(@(p) p(1), pts);
    MF_d = cellfun(@(p) p(2), pts);

    MF_gr = MF_line.growth_rate;

    MF_min_t = min(MF_t);
    MF_max_t = max(MF_t);
    MF_min_d = min(MF_d);
    MF_max_d = max(MF_d);

    % --- MF vs MC ---
    for j = 1:length(MC_keys)

        MC_line = MC_gr_points.(MC_keys{j});
        pts_MC = MC_line.fitted_points;

        MC_t = cellfun(@(p) p(1), pts_MC);
        MC_d = cellfun(@(p) p(2), pts_MC);

        valid = false;

        for k = 1:length(MC_t)
            if MF_min_t <= MC_t(k) && MC_t(k) <= MF_max_t && ...
               MF_min_d <= MC_d(k) && MC_d(k) <= MF_max_d
                valid = true;
                break
            end
        end

        if valid
            MF_line.method = 'MF';
            MC_line.method = 'MC';
            pairs{end+1} = {MF_line, MC_line};
        end
    end

    % --- MF vs AT ---
    for j = 1:length(AT_keys)

        AT_line = AT_gr_points.(AT_keys{j});
        pts_AT = AT_line.fitted_points;

        AT_t = cellfun(@(p) p(1), pts_AT);
        AT_d = cellfun(@(p) p(2), pts_AT);

        AT_gr = AT_line.growth_rate;

        if AT_gr < 0
            AT_t = flip(AT_t);
            AT_d = flip(AT_d);
        end

        b = MF_d(1) - (MF_gr * MF_t(1) * 24);

        valid = false;

        for k = 1:length(AT_t)
            t = AT_t(k);
            d = AT_d(k);

            if MF_gr >= 0
                cond = (MF_min_t <= t && t <= MF_max_t) && ...
                       (d >= MF_gr*t*24 + b) && ...
                       (d <= MF_max_d + MF_max_d*0.5);
            else
                cond = (MF_min_t <= t && t <= MF_max_t) && ...
                       (d <= MF_gr*t*24 + b) && ...
                       (d >= MF_min_d - MF_min_d*0.2);
            end

            if cond
                valid = true;
                break
            end
        end

        if valid
            AT_line.method = 'AT';
            MF_line.method = 'MF';
            pairs{end+1} = {MF_line, AT_line};
        end
    end
end

% -----------------------------
% GROUP LINES (graph logic)
% -----------------------------
events = group_lines(pairs);

end


% =============================
% GROUPING FUNCTION
% =============================
function grouped = group_lines(data)

graph = containers.Map('KeyType','int32','ValueType','any');
line_to_id = containers.Map;
id_counter = 1;

% Assign IDs
for i = 1:length(data)
    lines = data{i};
    pair_ids = [];

    for j = 1:length(lines)
        line = lines{j};
        key = jsonencode(line); % unique representation

        if ~isKey(line_to_id, key)
            line_to_id(key) = id_counter;
            id_counter = id_counter + 1;
        end

        pair_ids(end+1) = line_to_id(key);
    end

    % connect graph
    for a = pair_ids
        for b = pair_ids
            if a ~= b
                if ~isKey(graph,a)
                    graph(a) = [];
                end
                graph(a) = unique([graph(a), b]);
            end
        end
    end
end

% reverse mapping
keys_list = keys(line_to_id);
values_list = cell2mat(values(line_to_id));

id_to_line = containers.Map(values_list, keys_list);

% DFS
visited = [];
groups = {};

for node = values_list
    if ~ismember(node, visited)
        stack = [node];
        group = {};

        while ~isempty(stack)
            n = stack(end);
            stack(end) = [];

            if ismember(n, visited)
                continue
            end

            visited(end+1) = n;

            key = id_to_line(n);
            group{end+1} = jsondecode(key);

            if isKey(graph,n)
                neighbors = graph(n);
                stack = [stack neighbors];
            end
        end

        groups{end+1} = group;
    end
end

% output format
grouped = struct();
for i = 1:length(groups)
    grouped.(sprintf('event%d', i)) = groups{i};
end

end
