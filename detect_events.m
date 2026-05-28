
function events = detect_events(df_data, MF_gr_points, MC_gr_points, AT_gr_points, mc_area_edges, mgsc)

pairs = {};

MF_keys = fieldnames(MF_gr_points);
MC_keys = fieldnames(MC_gr_points);
AT_keys = fieldnames(AT_gr_points);

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

    for j = 1:length(MC_keys)

        MC_line = MC_gr_points.(MC_keys{j});
        pts_MC = MC_line.fitted_points;

        MC_t = cellfun(@(p) p(1), pts_MC);
        MC_d = cellfun(@(p) p(2), pts_MC);

        valid = [];

        for k = 1:length(MC_t)
            if MF_min_t <= MC_t(k) && MC_t(k) <= MF_max_t && ...
               MF_min_d <= MC_d(k) && MC_d(k) <= MF_max_d
                valid = 1;
            end
        end

        if ~isempty(valid)
            MF_line.method = 'MF';
            MC_line.method = 'MC';
            pairs{end+1} = {MF_line, MC_line};
        end
    end
end

events = struct();
events.event1 = pairs;

end
``
