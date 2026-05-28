
function [all_events, final_events] = growth_events(df_data, df_plot, MF_gr_points, MC_gr_points, AT_gr_points, mc_area_edges, mgsc)

% Main pipeline (equivalent of init_events)

all_events = detect_events(df_data, MF_gr_points, MC_gr_points, AT_gr_points, mc_area_edges, mgsc);

final_events = split_events(all_events);

all_events = filter_events(all_events, df_plot, mgsc);
final_events = filter_events(final_events, df_plot, mgsc);

all_events = add_event_info(all_events);
final_events = add_event_info(final_events);

end
