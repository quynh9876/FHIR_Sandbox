- dashboard: 1__facility__vulnerability__strategic_planning
  title: 1 - Facility - Vulnerability / Strategic Planning
  layout: newspaper
  preferred_slug: nd0Fr6uh7WzDjTBmTrgIdl
  elements:
  - name: Patient Vulnerability Score
    type: text
    title_text: Patient Vulnerability Score
    row: 0
    col: 0
    width: 12
    height: 2
  - name: Geography Vulnerability Score (SDOH)
    type: text
    title_text: Geography Vulnerability Score (SDOH)
    row: 0
    col: 12
    width: 12
    height: 2
  - title: Vulnerability Map
    name: Vulnerability Map
    model: fhir_hcls
    explore: fhir_hcls
    type: looker_map
    fields: [analytics.vulnerability_score, analytics.patient_postal_code, analytics.organization_name]
    filters:
      analytics.admission_date: 7 days
    limit: 500
    map_plot_mode: points
    heatmap_gridlines: false
    heatmap_gridlines_empty: false
    heatmap_opacity: 0.5
    show_region_field: true
    draw_map_labels_above_data: true
    map_tile_provider: light
    map_position: fit_data
    map_scale_indicator: 'off'
    map_pannable: true
    map_zoomable: true
    map_marker_type: circle
    map_marker_icon_name: default
    map_marker_radius_mode: proportional_value
    map_marker_units: meters
    map_marker_proportional_scale_type: linear
    map_marker_color_mode: fixed
    show_view_names: false
    show_legend: true
    quantize_map_value_colors: false
    reverse_map_value_colors: false
    series_types: {}
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    defaults_version: 1
    hidden_fields: []
    y_axes: []
    listen:
      Hospital Name: analytics.organization_name
      Weight - % >70: analytics.weight_over_70
      Weight - % Obesity: analytics.weight_obesity
      Weight - % Comorbidity: analytics.weight_comorbidity
    row: 2
    col: 0
    width: 12
    height: 9
  - title: Pivot Deep Dive
    name: Pivot Deep Dive
    model: fhir_hcls
    explore: fhir_hcls
    type: looker_grid
    fields: [analytics.pivot_value, analytics.count_total_patients, analytics.vulnerability_score,
      analytics.percent_patients_has_comorbidity, analytics.percent_patients_obese,
      analytics.percent_patients_over_70]
    filters:
      analytics.admission_date: 7 days
      analytics.pivot_value: "-NULL"
      analytics.count_total_patients: ">10"
    sorts: [analytics.vulnerability_score desc]
    limit: 500
    show_view_names: false
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: '12'
    rows_font_size: '12'
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    show_sql_query_menu_options: false
    show_totals: true
    show_row_totals: true
    series_labels:
      analytics.pivot_value: Value
      analytics.count_covid_confirmed: "# COVID Patients"
      analytics.percent_patients_has_comorbidity: "% Comorbidity"
      analytics.percent_patients_obese: "% Obese"
      analytics.percent_patients_over_70: "% >70"
      analytics.count_total_patients: "# Patients"
    series_cell_visualizations:
      analytics.count_covid_confirmed:
        is_active: true
      analytics.count_total_patients:
        is_active: true
    series_types: {}
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    defaults_version: 1
    hidden_fields: []
    y_axes: []
    listen:
      Hospital Name: analytics.organization_name
      Weight - % >70: analytics.weight_over_70
      Weight - % Obesity: analytics.weight_obesity
      Weight - % Comorbidity: analytics.weight_comorbidity
      Pivot Value: analytics.pivot
    row: 11
    col: 0
    width: 12
    height: 7
  - title: Population Density Map
    name: Population Density Map
    model: fhir_hcls
    explore: fhir_hcls
    type: looker_map
    fields: [analytics.patient_postal_code, analytics.average_population_density,
      analytics.organization_name]
    filters:
      analytics.admission_date: 7 days
    sorts: [analytics.average_population_density desc]
    limit: 500
    map_plot_mode: points
    heatmap_gridlines: false
    heatmap_gridlines_empty: false
    heatmap_opacity: 0.5
    show_region_field: true
    draw_map_labels_above_data: true
    map_tile_provider: light
    map_position: fit_data
    map_scale_indicator: 'off'
    map_pannable: true
    map_zoomable: true
    map_marker_type: circle
    map_marker_icon_name: default
    map_marker_radius_mode: proportional_value
    map_marker_units: meters
    map_marker_proportional_scale_type: linear
    map_marker_color_mode: fixed
    show_view_names: false
    show_legend: true
    quantize_map_value_colors: false
    reverse_map_value_colors: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: change
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    comparison_label: vs. National Average
    series_types: {}
    defaults_version: 1
    hidden_fields: []
    y_axes: []
    listen:
      Hospital Name: analytics.organization_name
    row: 2
    col: 12
    width: 12
    height: 9
  - title: Pivot Deep Dive (SDOH)
    name: Pivot Deep Dive (SDOH)
    model: fhir_hcls
    explore: fhir_hcls
    type: looker_grid
    fields: [analytics.pivot_value, analytics.count_total_patients, analytics.median_income,
      analytics.percent_above_70, analytics.average_population_density]
    filters:
      analytics.admission_date: 7 days
      analytics.pivot_value: "-NULL"
    sorts: [analytics.average_population_density desc]
    limit: 500
    show_view_names: false
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: '12'
    rows_font_size: '12'
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    show_sql_query_menu_options: false
    show_totals: true
    show_row_totals: true
    series_labels:
      analytics.percent_above_70: "% > 70"
    series_cell_visualizations:
      analytics.average_population_density:
        is_active: false
      analytics.median_income:
        is_active: false
      analytics.percent_above_70:
        is_active: false
      analytics.count_total_patients:
        is_active: true
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: change
    comparison_reverse_colors: false
    show_comparison_label: true
    comparison_label: vs. National Average
    series_types: {}
    defaults_version: 1
    map_plot_mode: points
    heatmap_gridlines: false
    heatmap_gridlines_empty: false
    heatmap_opacity: 0.5
    show_region_field: true
    draw_map_labels_above_data: true
    map_tile_provider: light
    map_position: fit_data
    map_scale_indicator: 'off'
    map_pannable: true
    map_zoomable: true
    map_marker_type: circle
    map_marker_icon_name: default
    map_marker_radius_mode: proportional_value
    map_marker_units: meters
    map_marker_proportional_scale_type: linear
    map_marker_color_mode: fixed
    show_legend: true
    quantize_map_value_colors: false
    reverse_map_value_colors: false
    hidden_fields: []
    y_axes: []
    listen:
      Hospital Name: analytics.organization_name
      Pivot Value: analytics.pivot
    row: 11
    col: 12
    width: 12
    height: 7
  - title: "# Visits by Day"
    name: "# Visits by Day"
    model: fhir_hcls
    explore: fhir_hcls
    type: looker_column
    fields: [analytics.admission_date, analytics.count_ed_visits, analytics.count_inpatient_visit,
      analytics.count_office_visit]
    fill_fields: [analytics.admission_date]
    filters:
      analytics.admission_date: 7 days
    sorts: [analytics.admission_date desc]
    limit: 500
    column_limit: 50
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: normal
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    series_types: {}
    show_null_points: true
    interpolation: linear
    defaults_version: 1
    hidden_fields: []
    y_axes: []
    row: 18
    col: 0
    width: 24
    height: 6
  filters:
  - name: Hospital Name
    title: Hospital Name
    type: field_filter
    default_value: HALLMARK HEALTH SYSTEM
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
    model: fhir_hcls
    explore: fhir_hcls
    listens_to_filters: []
    field: analytics.organization_name
  - name: Weight - % >70
    title: Weight - % >70
    type: field_filter
    default_value: '3'
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
    model: fhir_hcls
    explore: fhir_hcls
    listens_to_filters: []
    field: analytics.weight_over_70
  - name: Weight - % Obesity
    title: Weight - % Obesity
    type: field_filter
    default_value: '2'
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
    model: fhir_hcls
    explore: fhir_hcls
    listens_to_filters: []
    field: analytics.weight_obesity
  - name: Weight - % Comorbidity
    title: Weight - % Comorbidity
    type: field_filter
    default_value: '4'
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
    model: fhir_hcls
    explore: fhir_hcls
    listens_to_filters: []
    field: analytics.weight_comorbidity
  - name: Pivot Value
    title: Pivot Value
    type: field_filter
    default_value: patient^_postal^_code
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
    model: fhir_hcls
    explore: fhir_hcls
    listens_to_filters: []
    field: analytics.pivot



- dashboard: 2__facility
  title: 2 - Facility
  layout: newspaper
  description: ''
  preferred_slug: yE6ZR1S67t7t9DsL0dya8y
  elements:
  - title: Hospital Name
    name: Hospital Name
    model: fhir_hcls
    explore: fhir_hcls
    type: single_value
    fields: [analytics.organization_name]
    limit: 500
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    series_types: {}
    defaults_version: 1
    hidden_fields: []
    y_axes: []
    listen:
      Facility Name: analytics.organization_name
      Date: analytics.admission_date
    row: 0
    col: 0
    width: 3
    height: 4
  - title: "# Hospitalizations"
    name: "# Hospitalizations"
    model: fhir_hcls
    explore: fhir_hcls
    type: single_value
    fields: [analytics.count_inpatient_visit, analytics.admission_date]
    fill_fields: [analytics.admission_date]
    filters: {}
    sorts: [analytics.admission_date desc]
    limit: 500
    dynamic_fields: [{table_calculation: yesterday, label: yesterday, expression: 'offset(${analytics.count_inpatient_visit},1)',
        value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
        _type_hint: number}, {table_calculation: vs_yesterday, label: vs. Yesterday,
        expression: "(${analytics.count_inpatient_visit} - ${yesterday})/${yesterday}",
        value_format: !!null '', value_format_name: percent_1, _kind_hint: measure,
        _type_hint: number}]
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: change
    comparison_reverse_colors: true
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    comparison_label: ''
    series_types: {}
    defaults_version: 1
    hidden_fields: [yesterday]
    y_axes: []
    listen:
      Facility Name: analytics.organization_name
      Date: analytics.admission_date
    row: 0
    col: 3
    width: 3
    height: 4
  - title: Events by Day
    name: Events by Day
    model: fhir_hcls
    explore: fhir_hcls
    type: looker_column
    fields: [analytics.admission_date, analytics.encounter_type, analytics.count_total_patients]
    pivots: [analytics.encounter_type]
    fill_fields: [analytics.admission_date]
    sorts: [analytics.admission_date desc]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: normal
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    series_types: {}
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    defaults_version: 1
    hidden_fields: []
    y_axes: []
    listen:
      Facility Name: analytics.organization_name
      Date: analytics.admission_date
    row: 0
    col: 6
    width: 6
    height: 8
  - title: Patient Count
    name: Patient Count
    model: fhir_hcls
    explore: fhir_hcls
    type: looker_map
    fields: [analytics.count_total_patients, analytics.patient_postal_code]
    filters: {}
    sorts: [analytics.count_total_patients desc]
    limit: 500
    map_plot_mode: points
    heatmap_gridlines: false
    heatmap_gridlines_empty: false
    heatmap_opacity: 0.5
    show_region_field: true
    draw_map_labels_above_data: true
    map_tile_provider: light
    map_position: fit_data
    map_scale_indicator: 'off'
    map_pannable: true
    map_zoomable: true
    map_marker_type: circle
    map_marker_icon_name: default
    map_marker_radius_mode: proportional_value
    map_marker_units: meters
    map_marker_proportional_scale_type: linear
    map_marker_color_mode: fixed
    show_view_names: false
    show_legend: true
    quantize_map_value_colors: false
    reverse_map_value_colors: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: normal
    limit_displayed_rows: false
    legend_position: center
    series_types: {}
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    defaults_version: 1
    hidden_fields: []
    y_axes: []
    listen:
      Facility Name: analytics.organization_name
      Date: analytics.admission_date
    row: 0
    col: 18
    width: 6
    height: 8
  - title: "# Emergency Visits"
    name: "# Emergency Visits"
    model: fhir_hcls
    explore: fhir_hcls
    type: single_value
    fields: [analytics.admission_date, analytics.count_ed_visits]
    fill_fields: [analytics.admission_date]
    filters: {}
    sorts: [analytics.admission_date desc]
    limit: 500
    dynamic_fields: [{table_calculation: yesterday, label: yesterday, expression: 'offset(${analytics.count_ed_visits},1)',
        value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
        _type_hint: number}, {table_calculation: vs_yesterday, label: vs. Yesterday,
        expression: "(${analytics.count_ed_visits} - ${yesterday})/${yesterday}",
        value_format: !!null '', value_format_name: percent_1, _kind_hint: measure,
        _type_hint: number}]
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: change
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    comparison_label: ''
    series_types: {}
    defaults_version: 1
    hidden_fields: [yesterday]
    y_axes: []
    listen:
      Facility Name: analytics.organization_name
      Date: analytics.admission_date
    row: 4
    col: 0
    width: 3
    height: 4
  - title: "# Office Visits"
    name: "# Office Visits"
    model: fhir_hcls
    explore: fhir_hcls
    type: single_value
    fields: [analytics.admission_date, analytics.count_office_visit]
    fill_fields: [analytics.admission_date]
    filters: {}
    sorts: [analytics.admission_date desc]
    limit: 500
    dynamic_fields: [{table_calculation: yesterday, label: yesterday, expression: 'offset(${analytics.count_office_visit},1)',
        value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
        _type_hint: number}, {table_calculation: vs_yesterday, label: vs. Yesterday,
        expression: "(${analytics.count_office_visit} - ${yesterday})/${yesterday}",
        value_format: !!null '', value_format_name: percent_1, _kind_hint: measure,
        _type_hint: number}]
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: change
    comparison_reverse_colors: true
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    comparison_label: ''
    series_types: {}
    defaults_version: 1
    hidden_fields: [yesterday]
    y_axes: []
    listen:
      Facility Name: analytics.organization_name
      Date: analytics.admission_date
    row: 4
    col: 3
    width: 3
    height: 4
  - title: Provider Deep Dive
    name: Provider Deep Dive
    model: fhir_hcls
    explore: fhir_hcls
    type: looker_grid
    fields: [analytics.count_total_patients, analytics.count_office_visit, analytics.count_inpatient_visit,
      analytics.practitioner_name]
    filters:
      analytics.practitioner_name: "-NULL,-SELF"
    sorts: [analytics.count_total_patients desc]
    limit: 500
    show_view_names: false
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: '12'
    rows_font_size: '12'
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    show_sql_query_menu_options: false
    show_totals: true
    show_row_totals: true
    series_labels:
      analytics.count_total_patients: "# Patients"
      analytics.count_covid_confirmed: "# COVID Patients"
      analytics.count_office_visit: "# Office Visits"
      analytics.count_inpatient_visit: "# Inpatient"
      analytics.vulnerability_score: Avg Vulnerability Score
      analytics.practitioner_name: Provider Name
    series_cell_visualizations:
      analytics.count_total_patients:
        is_active: true
    series_types: {}
    defaults_version: 1
    hidden_fields: []
    y_axes: []
    listen:
      Date: analytics.admission_date
    row: 8
    col: 0
    width: 14
    height: 12
  - title: Hospital Volume
    name: Hospital Volume
    model: fhir_hcls
    explore: fhir_hcls
    type: table
    fields: [analytics.admission_day_of_week, analytics.admission_hour_of_day, analytics.count_total_encounters]
    pivots: [analytics.admission_day_of_week]
    fill_fields: [analytics.admission_day_of_week, analytics.admission_hour_of_day]
    filters: {}
    sorts: [analytics.admission_hour_of_day, analytics.admission_day_of_week]
    limit: 500
    show_view_names: false
    show_row_numbers: false
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: gray
    limit_displayed_rows: false
    enable_conditional_formatting: true
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    conditional_formatting: [{type: along a scale..., value: !!null '', background_color: "#4285F4",
        font_color: !!null '', color_application: {collection_id: google, palette_id: google-diverging-0,
          options: {constraints: {min: {type: minimum}, mid: {type: number, value: 0},
              max: {type: maximum}}, mirror: true, reverse: false, stepped: false}},
        bold: false, italic: false, strikethrough: false, fields: [analytics.count_total_encounters]}]
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: normal
    legend_position: center
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    series_types: {}
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    defaults_version: 1
    hidden_fields: []
    y_axes: []
    listen:
      Facility Name: analytics.organization_name
      Date: analytics.admission_date
    row: 8
    col: 14
    width: 10
    height: 12
  - title: COVID Status
    name: COVID Status
    model: fhir_hcls
    explore: fhir_hcls
    type: looker_column
    fields: [analytics.admission_date, analytics.count_total_patients, analytics.covid_status]
    pivots: [analytics.covid_status]
    fill_fields: [analytics.admission_date]
    filters: {}
    sorts: [analytics.admission_date desc, analytics.covid_status]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: normal
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    y_axes: []
    hidden_series: [Not Suspected - analytics.count_total_patients]
    series_types: {}
    series_labels:
      Confirmed - analytics.count_total_patients: Confirmed
      Not Suspected - analytics.count_total_patients: Not Suspected
      Suspected - analytics.count_total_patients: Suspected
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    defaults_version: 1
    hidden_fields: []
    listen:
      Facility Name: analytics.organization_name
      Date: analytics.admission_date
    row: 0
    col: 12
    width: 6
    height: 8
  filters:
  - name: Facility Name
    title: Facility Name
    type: field_filter
    default_value: HALLMARK HEALTH SYSTEM
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
    model: fhir_hcls
    explore: fhir_hcls
    listens_to_filters: []
    field: analytics.organization_name
  - name: Date
    title: Date
    type: field_filter
    default_value: 7 days
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
    model: fhir_hcls
    explore: fhir_hcls
    listens_to_filters: []
    field: analytics.admission_date



- dashboard: 3__provider
  title: 3 - Provider
  layout: newspaper
  preferred_slug: n1ABxmYFpTbYW3fMNabLhA
  elements:
  - title: "# Hospitalizations"
    name: "# Hospitalizations"
    model: fhir_hcls
    explore: fhir_hcls
    type: single_value
    fields: [analytics.count_inpatient_visit, analytics.admission_date]
    fill_fields: [analytics.admission_date]
    sorts: [analytics.admission_date desc]
    limit: 500
    dynamic_fields: [{table_calculation: yesterday, label: yesterday, expression: 'offset(${analytics.count_inpatient_visit},1)',
        value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
        _type_hint: number}, {table_calculation: vs_yesterday, label: vs. Yesterday,
        expression: "(${analytics.count_inpatient_visit} - ${yesterday})/${yesterday}",
        value_format: !!null '', value_format_name: percent_1, _kind_hint: measure,
        _type_hint: number}]
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    comparison_label: ''
    series_types: {}
    defaults_version: 1
    hidden_fields: [yesterday]
    y_axes: []
    listen:
      Date: analytics.admission_date
      Provider Name: analytics.practitioner_name
    row: 0
    col: 3
    width: 3
    height: 4
  - title: "# Office Visits"
    name: "# Office Visits"
    model: fhir_hcls
    explore: fhir_hcls
    type: single_value
    fields: [analytics.admission_date, analytics.count_office_visit]
    fill_fields: [analytics.admission_date]
    sorts: [analytics.admission_date desc]
    limit: 500
    dynamic_fields: [{table_calculation: yesterday, label: yesterday, expression: 'offset(${analytics.count_office_visit},1)',
        value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
        _type_hint: number}, {table_calculation: vs_yesterday, label: vs. Yesterday,
        expression: "(${analytics.count_office_visit} - ${yesterday})/${yesterday}",
        value_format: !!null '', value_format_name: percent_1, _kind_hint: measure,
        _type_hint: number}]
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    comparison_label: ''
    series_types: {}
    defaults_version: 1
    hidden_fields: [yesterday]
    y_axes: []
    listen:
      Date: analytics.admission_date
      Provider Name: analytics.practitioner_name
    row: 4
    col: 3
    width: 3
    height: 4
  - title: Patients by Encounter Type
    name: Patients by Encounter Type
    model: fhir_hcls
    explore: fhir_hcls
    type: looker_column
    fields: [analytics.admission_date, analytics.encounter_type, analytics.count_total_patients]
    pivots: [analytics.encounter_type]
    fill_fields: [analytics.admission_date]
    sorts: [analytics.admission_date desc]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: normal
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    series_types: {}
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    defaults_version: 1
    hidden_fields: []
    y_axes: []
    listen:
      Date: analytics.admission_date
      Provider Name: analytics.practitioner_name
    row: 0
    col: 6
    width: 6
    height: 8
  - title: Patients by COVID Status
    name: Patients by COVID Status
    model: fhir_hcls
    explore: fhir_hcls
    type: looker_column
    fields: [analytics.admission_date, analytics.count_total_patients, analytics.covid_status]
    pivots: [analytics.covid_status]
    fill_fields: [analytics.admission_date]
    filters: {}
    sorts: [analytics.admission_date desc, analytics.covid_status]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: normal
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    series_types: {}
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    defaults_version: 1
    hidden_series: [Not Suspected - analytics.count_total_patients]
    hidden_fields: []
    y_axes: []
    listen:
      Date: analytics.admission_date
      Provider Name: analytics.practitioner_name
    row: 0
    col: 12
    width: 6
    height: 8
  - title: Patient Map
    name: Patient Map
    model: fhir_hcls
    explore: fhir_hcls
    type: looker_map
    fields: [analytics.count_total_patients, analytics.patient_postal_code]
    filters: {}
    sorts: [analytics.count_total_patients desc]
    limit: 500
    map_plot_mode: points
    heatmap_gridlines: false
    heatmap_gridlines_empty: false
    heatmap_opacity: 0.5
    show_region_field: true
    draw_map_labels_above_data: true
    map_tile_provider: light
    map_position: fit_data
    map_scale_indicator: 'off'
    map_pannable: true
    map_zoomable: true
    map_marker_type: circle
    map_marker_icon_name: default
    map_marker_radius_mode: proportional_value
    map_marker_units: meters
    map_marker_proportional_scale_type: linear
    map_marker_color_mode: fixed
    show_view_names: false
    show_legend: true
    quantize_map_value_colors: false
    reverse_map_value_colors: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: normal
    limit_displayed_rows: false
    legend_position: center
    series_types: {}
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    defaults_version: 1
    hidden_fields: []
    y_axes: []
    listen:
      Date: analytics.admission_date
      Provider Name: analytics.practitioner_name
    row: 0
    col: 18
    width: 6
    height: 8
  - title: Practitioner Name
    name: Practitioner Name
    model: fhir_hcls
    explore: fhir_hcls
    type: single_value
    fields: [analytics.practitioner_name]
    limit: 500
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    series_types: {}
    defaults_version: 1
    hidden_fields: []
    y_axes: []
    listen:
      Date: analytics.admission_date
      Provider Name: analytics.practitioner_name
    row: 0
    col: 0
    width: 3
    height: 4
  - title: Patient Deep Dive
    name: Patient Deep Dive
    model: fhir_hcls
    explore: fhir_hcls
    type: looker_grid
    fields: [analytics.patient_name, analytics.patient_age, analytics.patient_gender,
      analytics.patient_city, analytics.patient_state, analytics.bmi, analytics.bmi_weight_tier]
    filters:
      analytics.patient_name: "-NULL"
    limit: 500
    column_limit: 50
    show_view_names: false
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: '12'
    rows_font_size: '12'
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    show_sql_query_menu_options: false
    show_totals: true
    show_row_totals: true
    series_labels:
      analytics.count_total_patients: "# Patients"
      analytics.count_covid_confirmed: "# COVID Patients"
      analytics.count_office_visit: "# Office Visits"
      analytics.count_inpatient_visit: "# Hospitalizations"
      analytics.vulnerability_score: Avg Vulnerability Score
    series_cell_visualizations:
      analytics.count_total_patients:
        is_active: true
    series_types: {}
    defaults_version: 1
    hidden_fields: []
    y_axes: []
    listen:
      Date: analytics.admission_date
      Provider Name: analytics.practitioner_name
    row: 8
    col: 0
    width: 24
    height: 10
  - title: "# Emergency Visits"
    name: "# Emergency Visits"
    model: fhir_hcls
    explore: fhir_hcls
    type: single_value
    fields: [analytics.admission_date, analytics.count_ed_visits]
    fill_fields: [analytics.admission_date]
    filters: {}
    sorts: [analytics.admission_date desc]
    limit: 500
    column_limit: 50
    dynamic_fields: [{table_calculation: yesterday, label: yesterday, expression: 'offset(${analytics.count_ed_visits},1)',
        value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
        _type_hint: number}, {table_calculation: vs_yesterday, label: vs. Yesterday,
        expression: "(${analytics.count_ed_visits} - ${yesterday})/${yesterday}",
        value_format: !!null '', value_format_name: percent_1, _kind_hint: measure,
        _type_hint: number}]
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: change
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    comparison_label: ''
    series_types: {}
    defaults_version: 1
    hidden_fields: [yesterday]
    y_axes: []
    listen:
      Date: analytics.admission_date
      Provider Name: analytics.practitioner_name
    row: 4
    col: 0
    width: 3
    height: 4
  filters:
  - name: Date
    title: Date
    type: field_filter
    default_value: 7 days
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
    model: fhir_hcls
    explore: fhir_hcls
    listens_to_filters: []
    field: analytics.admission_date
  - name: Provider Name
    title: Provider Name
    type: field_filter
    default_value: Dr. Lane Jacobi
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
    model: fhir_hcls
    explore: fhir_hcls
    listens_to_filters: []
    field: analytics.practitioner_name



- dashboard: 4__patient
  title: 4 - Patient
  layout: newspaper
  preferred_slug: ZtOBC8H33GzqcXPVtr1lhl
  elements:
  - title: General Information
    name: General Information
    model: fhir_hcls
    explore: fhir_hcls
    type: looker_single_record
    fields: [analytics.patient_name, analytics.patient_age_color, analytics.patient_gender,
      analytics.patient_city, analytics.patient_state, analytics.patient_postal_code,
      analytics.covid_status]
    sorts: [analytics.patient_name]
    limit: 500
    column_limit: 50
    show_view_names: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    defaults_version: 1
    series_types: {}
    hidden_fields: []
    y_axes: []
    listen:
      Date: analytics.admission_date
      Patient Name: analytics.patient_name
    row: 0
    col: 0
    width: 5
    height: 5
  - title: Vitals
    name: Vitals
    model: fhir_hcls
    explore: fhir_hcls
    type: looker_single_record
    fields: [analytics.bmi_weight_tier_color, analytics.height_ft, analytics.weight_lb,
      analytics.bmi]
    sorts: [analytics.bmi_weight_tier_color]
    limit: 500
    column_limit: 50
    show_view_names: false
    series_types: {}
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    defaults_version: 1
    hidden_fields: []
    y_axes: []
    listen:
      Date: analytics.admission_date
      Patient Name: analytics.patient_name
    row: 0
    col: 5
    width: 5
    height: 5
  - title: Comorbidities
    name: Comorbidities
    model: fhir_hcls
    explore: fhir_hcls
    type: looker_single_record
    fields: [analytics.comorbidity_asthma, analytics.comorbidity_copd, analytics.comorbidity_diabetes_1,
      analytics.comorbidity_diabetes_2, analytics.comorbidity_hypertension, analytics.comorbidity_immunocompromised]
    limit: 500
    column_limit: 50
    show_view_names: false
    series_types: {}
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    defaults_version: 1
    hidden_fields: []
    y_axes: []
    listen:
      Date: analytics.admission_date
      Patient Name: analytics.patient_name
    row: 0
    col: 10
    width: 5
    height: 5
  - title: Location
    name: Location
    model: fhir_hcls
    explore: fhir_hcls
    type: looker_map
    fields: [analytics.patient_postal_code, analytics.count_covid_confirmed]
    sorts: [analytics.patient_postal_code]
    limit: 1
    column_limit: 50
    map_plot_mode: points
    heatmap_gridlines: false
    heatmap_gridlines_empty: false
    heatmap_opacity: 0.5
    show_region_field: true
    draw_map_labels_above_data: true
    map_tile_provider: light
    map_position: fit_data
    map_scale_indicator: 'off'
    map_pannable: true
    map_zoomable: true
    map_marker_type: circle
    map_marker_icon_name: default
    map_marker_radius_mode: proportional_value
    map_marker_units: meters
    map_marker_proportional_scale_type: linear
    map_marker_color_mode: fixed
    show_view_names: false
    show_legend: true
    quantize_map_value_colors: false
    reverse_map_value_colors: false
    series_types: {}
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    defaults_version: 1
    hidden_fields: []
    y_axes: []
    listen:
      Date: analytics.admission_date
      Patient Name: analytics.patient_name
    row: 0
    col: 15
    width: 5
    height: 5
  - title: Encounter Details
    name: Encounter Details
    model: fhir_hcls
    explore: fhir_hcls
    type: looker_grid
    fields: [analytics.admission_date, analytics.encounter_type, encounter.id, analytics.practitioner_name]
    sorts: [analytics.admission_date desc]
    limit: 500
    column_limit: 50
    show_view_names: false
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: '12'
    rows_font_size: '12'
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    show_sql_query_menu_options: false
    show_totals: true
    show_row_totals: true
    series_labels:
      analytics.admission_date: Start
      analytics.discharge_date: End
      analytics.practitioner_name: Provider Name
    series_types: {}
    defaults_version: 1
    hidden_fields: []
    y_axes: []
    listen:
      Date: analytics.admission_date
      Patient Name: analytics.patient_name
    row: 5
    col: 0
    width: 20
    height: 12
  filters:
  - name: Date
    title: Date
    type: field_filter
    default_value: 7 days
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
    model: fhir_hcls
    explore: fhir_hcls
    listens_to_filters: []
    field: analytics.admission_date
  - name: Patient Name
    title: Patient Name
    type: field_filter
    default_value: Adolfo Corwin
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
    model: fhir_hcls
    explore: fhir_hcls
    listens_to_filters: []
    field: analytics.patient_name




# - dashboard: 1a__covid_patient_status_original
#   title: 1A - COVID Patient Status (Original)
#   layout: newspaper
#   elements:
#   - title: "# Ambulatory Patients"
#     name: "# Ambulatory Patients"
#     model: fhir_hcls
#     explore: final_patient_status_dashboard
#     type: single_value
#     fields: [final_patient_status_dashboard.snapshot_date, final_patient_status_dashboard.count_patients_status_1_ambulatory,
#       final_patient_status_dashboard.percent_patients_status_1_ambulatory]
#     fill_fields: [final_patient_status_dashboard.snapshot_date]
#     sorts: [final_patient_status_dashboard.snapshot_date desc]
#     limit: 500
#     dynamic_fields: [{table_calculation: offset, label: offset, expression: 'offset(${final_patient_status_dashboard.count_patients},1)',
#         value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
#         _type_hint: number, is_disabled: true}, {table_calculation: vs_yesterday,
#         label: "% vs. Yesterday", expression: "(${final_patient_status_dashboard.count_patients}\
#           \ - ${offset})/${offset}", value_format: !!null '', value_format_name: percent_1,
#         _kind_hint: measure, _type_hint: number, is_disabled: true}]
#     custom_color_enabled: true
#     show_single_value_title: true
#     show_comparison: true
#     comparison_type: value
#     comparison_reverse_colors: true
#     show_comparison_label: true
#     enable_conditional_formatting: false
#     conditional_formatting_include_totals: false
#     conditional_formatting_include_nulls: false
#     comparison_label: of Total
#     series_types: {}
#     defaults_version: 1
#     hidden_fields: []
#     listen:
#       Date: final_patient_status_dashboard.snapshot_date
#     row: 2
#     col: 4
#     width: 4
#     height: 4
#   - title: Status by Day
#     name: Status by Day
#     model: fhir_hcls
#     explore: final_patient_status_dashboard
#     type: looker_column
#     fields: [final_patient_status_dashboard.snapshot_date, final_patient_status_dashboard.count_patients,
#       final_patient_status_dashboard.patient_status]
#     pivots: [final_patient_status_dashboard.patient_status]
#     fill_fields: [final_patient_status_dashboard.snapshot_date]
#     filters:
#       final_patient_status_dashboard.snapshot_date: 90 days
#     sorts: [final_patient_status_dashboard.snapshot_date desc, final_patient_status_dashboard.patient_status]
#     limit: 500
#     dynamic_fields: [{table_calculation: offset, label: offset, expression: 'offset(${final_patient_status_dashboard.count_patients},1)',
#         value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
#         _type_hint: number, is_disabled: true}, {table_calculation: vs_yesterday,
#         label: "% vs. Yesterday", expression: "(${final_patient_status_dashboard.count_patients}\
#           \ - ${offset})/${offset}", value_format: !!null '', value_format_name: percent_1,
#         _kind_hint: measure, _type_hint: number, is_disabled: true}]
#     x_axis_gridlines: false
#     y_axis_gridlines: true
#     show_view_names: false
#     show_y_axis_labels: true
#     show_y_axis_ticks: true
#     y_axis_tick_density: default
#     y_axis_tick_density_custom: 5
#     show_x_axis_label: true
#     show_x_axis_ticks: true
#     y_axis_scale_mode: linear
#     x_axis_reversed: false
#     y_axis_reversed: false
#     plot_size_by_field: false
#     trellis: ''
#     stacking: normal
#     limit_displayed_rows: false
#     legend_position: center
#     point_style: none
#     show_value_labels: false
#     label_density: 25
#     x_axis_scale: auto
#     y_axis_combined: true
#     ordering: none
#     show_null_labels: false
#     show_totals_labels: false
#     show_silhouette: false
#     totals_color: "#808080"
#     series_types: {}
#     custom_color_enabled: true
#     show_single_value_title: true
#     show_comparison: true
#     comparison_type: change
#     comparison_reverse_colors: true
#     show_comparison_label: true
#     enable_conditional_formatting: false
#     conditional_formatting_include_totals: false
#     conditional_formatting_include_nulls: false
#     defaults_version: 1
#     hidden_fields: []
#     listen: {}
#     row: 6
#     col: 0
#     width: 9
#     height: 8
#   - title: Inpatient & ICU Beds
#     name: Inpatient & ICU Beds
#     model: fhir_hcls
#     explore: final_patient_status_dashboard
#     type: looker_line
#     fields: [final_patient_status_dashboard.snapshot_date, final_patient_status_dashboard.count_patients,
#       final_patient_status_dashboard.patient_status]
#     pivots: [final_patient_status_dashboard.patient_status]
#     fill_fields: [final_patient_status_dashboard.snapshot_date]
#     filters:
#       final_patient_status_dashboard.snapshot_date: 90 days
#       final_patient_status_dashboard.patient_status: 3 - Inpatient ICU,2 - Inpatient
#     sorts: [final_patient_status_dashboard.snapshot_date desc, final_patient_status_dashboard.patient_status]
#     limit: 500
#     dynamic_fields: [{table_calculation: offset, label: offset, expression: 'offset(${final_patient_status_dashboard.count_patients},1)',
#         value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
#         _type_hint: number, is_disabled: true}, {table_calculation: vs_yesterday,
#         label: "% vs. Yesterday", expression: "(${final_patient_status_dashboard.count_patients}\
#           \ - ${offset})/${offset}", value_format: !!null '', value_format_name: percent_1,
#         _kind_hint: measure, _type_hint: number, is_disabled: true}]
#     x_axis_gridlines: false
#     y_axis_gridlines: true
#     show_view_names: false
#     show_y_axis_labels: true
#     show_y_axis_ticks: true
#     y_axis_tick_density: default
#     y_axis_tick_density_custom: 5
#     show_x_axis_label: true
#     show_x_axis_ticks: true
#     y_axis_scale_mode: linear
#     x_axis_reversed: false
#     y_axis_reversed: false
#     plot_size_by_field: false
#     trellis: ''
#     stacking: ''
#     limit_displayed_rows: false
#     legend_position: center
#     point_style: none
#     show_value_labels: false
#     label_density: 25
#     x_axis_scale: auto
#     y_axis_combined: true
#     show_null_points: true
#     interpolation: linear
#     series_types: {}
#     series_labels:
#       2 - Inpatient - final_patient_status_dashboard.count_patients: Inpatient Beds
#       3 - Inpatient ICU - final_patient_status_dashboard.count_patients: ICU Beds
#     ordering: none
#     show_null_labels: false
#     show_totals_labels: false
#     show_silhouette: false
#     totals_color: "#808080"
#     custom_color_enabled: true
#     show_single_value_title: true
#     show_comparison: true
#     comparison_type: change
#     comparison_reverse_colors: true
#     show_comparison_label: true
#     enable_conditional_formatting: false
#     conditional_formatting_include_totals: false
#     conditional_formatting_include_nulls: false
#     defaults_version: 1
#     hidden_fields: []
#     listen: {}
#     row: 6
#     col: 9
#     width: 9
#     height: 8
#   - title: Deep Dive
#     name: Deep Dive
#     model: fhir_hcls
#     explore: final_patient_status_dashboard
#     type: looker_grid
#     fields: [final_patient_status_patient_details_dashboard.pivot_value, final_patient_status_dashboard.count_patients_status_1_ambulatory,
#       final_patient_status_dashboard.count_patients_status_2_inpatient, final_patient_status_dashboard.count_patients_status_3_inpatient_icu,
#       final_patient_status_dashboard.count_patients_status_4_discharged_snf, final_patient_status_dashboard.count_patients_status_5_discharged_home,
#       final_patient_status_dashboard.count_patients_status_6_death]
#     filters:
#       final_patient_status_patient_details_dashboard.pivot_value: "-NULL"
#     sorts: [final_patient_status_dashboard.count_patients_status_1_ambulatory desc]
#     limit: 500
#     dynamic_fields: [{table_calculation: offset, label: offset, expression: 'offset(${final_patient_status_dashboard.count_patients},1)',
#         value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
#         _type_hint: number, is_disabled: true}, {table_calculation: vs_yesterday,
#         label: "% vs. Yesterday", expression: "(${final_patient_status_dashboard.count_patients}\
#           \ - ${offset})/${offset}", value_format: !!null '', value_format_name: percent_1,
#         _kind_hint: measure, _type_hint: number, is_disabled: true}]
#     show_view_names: false
#     show_row_numbers: true
#     transpose: false
#     truncate_text: true
#     hide_totals: false
#     hide_row_totals: false
#     size_to_fit: true
#     table_theme: white
#     limit_displayed_rows: false
#     enable_conditional_formatting: false
#     header_text_alignment: left
#     header_font_size: '12'
#     rows_font_size: '12'
#     conditional_formatting_include_totals: false
#     conditional_formatting_include_nulls: false
#     show_sql_query_menu_options: false
#     show_totals: true
#     show_row_totals: true
#     series_labels:
#       2 - Inpatient - final_patient_status_dashboard.count_patients: Inpatient Beds
#       3 - Inpatient ICU - final_patient_status_dashboard.count_patients: ICU Beds
#       final_patient_status_dashboard.count_patients_status_1_ambulatory: "# Ambulatory"
#       final_patient_status_dashboard.count_patients_status_2_inpatient: "# Inpatient"
#       final_patient_status_dashboard.count_patients_status_3_inpatient_icu: "# Inpatient\
#         \ ICU"
#       final_patient_status_dashboard.count_patients_status_4_discharged_snf: "# SNF"
#       final_patient_status_dashboard.count_patients_status_5_discharged_home: "# Discharged\
#         \ Home"
#       final_patient_status_dashboard.count_patients_status_6_death: "# Death"
#     x_axis_gridlines: false
#     y_axis_gridlines: true
#     show_y_axis_labels: true
#     show_y_axis_ticks: true
#     y_axis_tick_density: default
#     y_axis_tick_density_custom: 5
#     show_x_axis_label: true
#     show_x_axis_ticks: true
#     y_axis_scale_mode: linear
#     x_axis_reversed: false
#     y_axis_reversed: false
#     plot_size_by_field: false
#     trellis: ''
#     stacking: normal
#     legend_position: center
#     point_style: none
#     show_value_labels: false
#     label_density: 25
#     x_axis_scale: auto
#     y_axis_combined: true
#     show_null_points: true
#     interpolation: linear
#     series_types: {}
#     ordering: none
#     show_null_labels: false
#     show_totals_labels: false
#     show_silhouette: false
#     totals_color: "#808080"
#     custom_color_enabled: true
#     show_single_value_title: true
#     show_comparison: true
#     comparison_type: change
#     comparison_reverse_colors: true
#     show_comparison_label: true
#     defaults_version: 1
#     hidden_fields: []
#     listen:
#       Pivot: final_patient_status_patient_details_dashboard.pivot
#       Date: final_patient_status_dashboard.snapshot_date
#     row: 14
#     col: 0
#     width: 24
#     height: 8
#   - title: Patient by Age Tier
#     name: Patient by Age Tier
#     model: fhir_hcls
#     explore: final_patient_status_dashboard
#     type: looker_column
#     fields: [final_patient_status_dashboard.count_patients, final_patient_status_patient_details_dashboard.patient_age_tier]
#     fill_fields: [final_patient_status_patient_details_dashboard.patient_age_tier]
#     sorts: [final_patient_status_patient_details_dashboard.patient_age_tier]
#     limit: 500
#     dynamic_fields: [{table_calculation: offset, label: offset, expression: 'offset(${final_patient_status_dashboard.count_patients},1)',
#         value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
#         _type_hint: number, is_disabled: true}, {table_calculation: vs_yesterday,
#         label: "% vs. Yesterday", expression: "(${final_patient_status_dashboard.count_patients}\
#           \ - ${offset})/${offset}", value_format: !!null '', value_format_name: percent_1,
#         _kind_hint: measure, _type_hint: number, is_disabled: true}]
#     x_axis_gridlines: false
#     y_axis_gridlines: true
#     show_view_names: false
#     show_y_axis_labels: true
#     show_y_axis_ticks: true
#     y_axis_tick_density: default
#     y_axis_tick_density_custom: 5
#     show_x_axis_label: true
#     show_x_axis_ticks: true
#     y_axis_scale_mode: linear
#     x_axis_reversed: false
#     y_axis_reversed: false
#     plot_size_by_field: false
#     trellis: ''
#     stacking: ''
#     limit_displayed_rows: false
#     legend_position: center
#     point_style: none
#     show_value_labels: false
#     label_density: 25
#     x_axis_scale: auto
#     y_axis_combined: true
#     ordering: none
#     show_null_labels: false
#     show_totals_labels: false
#     show_silhouette: false
#     totals_color: "#808080"
#     map_plot_mode: points
#     heatmap_gridlines: false
#     heatmap_gridlines_empty: false
#     heatmap_opacity: 0.5
#     show_region_field: true
#     draw_map_labels_above_data: true
#     map_tile_provider: light
#     map_position: fit_data
#     map_scale_indicator: 'off'
#     map_pannable: true
#     map_zoomable: true
#     map_marker_type: circle
#     map_marker_icon_name: default
#     map_marker_radius_mode: proportional_value
#     map_marker_units: meters
#     map_marker_proportional_scale_type: linear
#     map_marker_color_mode: fixed
#     show_legend: true
#     quantize_map_value_colors: false
#     reverse_map_value_colors: false
#     custom_color_enabled: true
#     show_single_value_title: true
#     show_comparison: true
#     comparison_type: change
#     comparison_reverse_colors: true
#     show_comparison_label: true
#     enable_conditional_formatting: false
#     conditional_formatting_include_totals: false
#     conditional_formatting_include_nulls: false
#     series_types: {}
#     defaults_version: 1
#     hidden_fields: []
#     listen:
#       Date: final_patient_status_dashboard.snapshot_date
#     row: 6
#     col: 18
#     width: 6
#     height: 8
#   - title: "# Inpatient Patients"
#     name: "# Inpatient Patients"
#     model: fhir_hcls
#     explore: final_patient_status_dashboard
#     type: single_value
#     fields: [final_patient_status_dashboard.snapshot_date, final_patient_status_dashboard.count_patients_status_2_inpatient,
#       final_patient_status_dashboard.percent_patients_status_2_inpatient]
#     fill_fields: [final_patient_status_dashboard.snapshot_date]
#     sorts: [final_patient_status_dashboard.snapshot_date desc]
#     limit: 500
#     dynamic_fields: [{table_calculation: offset, label: offset, expression: 'offset(${final_patient_status_dashboard.count_patients},1)',
#         value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
#         _type_hint: number, is_disabled: true}, {table_calculation: vs_yesterday,
#         label: "% vs. Yesterday", expression: "(${final_patient_status_dashboard.count_patients}\
#           \ - ${offset})/${offset}", value_format: !!null '', value_format_name: percent_1,
#         _kind_hint: measure, _type_hint: number, is_disabled: true}]
#     custom_color_enabled: true
#     show_single_value_title: true
#     show_comparison: true
#     comparison_type: value
#     comparison_reverse_colors: true
#     show_comparison_label: true
#     enable_conditional_formatting: false
#     conditional_formatting_include_totals: false
#     conditional_formatting_include_nulls: false
#     comparison_label: of Total
#     series_types: {}
#     defaults_version: 1
#     hidden_fields: []
#     listen:
#       Date: final_patient_status_dashboard.snapshot_date
#     row: 2
#     col: 8
#     width: 4
#     height: 4
#   - title: "# Patients Discharged to SNF"
#     name: "# Patients Discharged to SNF"
#     model: fhir_hcls
#     explore: final_patient_status_dashboard
#     type: single_value
#     fields: [final_patient_status_dashboard.snapshot_date, final_patient_status_dashboard.count_patients_status_4_discharged_snf,
#       final_patient_status_dashboard.percent_patients_status_4_discharged_snf]
#     fill_fields: [final_patient_status_dashboard.snapshot_date]
#     sorts: [final_patient_status_dashboard.snapshot_date desc]
#     limit: 500
#     dynamic_fields: [{table_calculation: offset, label: offset, expression: 'offset(${final_patient_status_dashboard.count_patients},1)',
#         value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
#         _type_hint: number, is_disabled: true}, {table_calculation: vs_yesterday,
#         label: "% vs. Yesterday", expression: "(${final_patient_status_dashboard.count_patients}\
#           \ - ${offset})/${offset}", value_format: !!null '', value_format_name: percent_1,
#         _kind_hint: measure, _type_hint: number, is_disabled: true}]
#     custom_color_enabled: true
#     show_single_value_title: true
#     show_comparison: true
#     comparison_type: value
#     comparison_reverse_colors: true
#     show_comparison_label: true
#     enable_conditional_formatting: false
#     conditional_formatting_include_totals: false
#     conditional_formatting_include_nulls: false
#     comparison_label: of Total
#     series_types: {}
#     defaults_version: 1
#     hidden_fields: []
#     listen:
#       Date: final_patient_status_dashboard.snapshot_date
#     row: 2
#     col: 16
#     width: 4
#     height: 4
#   - title: "# Inpatient Patients (ICU)"
#     name: "# Inpatient Patients (ICU)"
#     model: fhir_hcls
#     explore: final_patient_status_dashboard
#     type: single_value
#     fields: [final_patient_status_dashboard.snapshot_date, final_patient_status_dashboard.count_patients_status_3_inpatient_icu,
#       final_patient_status_dashboard.percent_patients_status_3_inpatient_icu]
#     fill_fields: [final_patient_status_dashboard.snapshot_date]
#     sorts: [final_patient_status_dashboard.snapshot_date desc]
#     limit: 500
#     dynamic_fields: [{table_calculation: offset, label: offset, expression: 'offset(${final_patient_status_dashboard.count_patients},1)',
#         value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
#         _type_hint: number, is_disabled: true}, {table_calculation: vs_yesterday,
#         label: "% vs. Yesterday", expression: "(${final_patient_status_dashboard.count_patients}\
#           \ - ${offset})/${offset}", value_format: !!null '', value_format_name: percent_1,
#         _kind_hint: measure, _type_hint: number, is_disabled: true}]
#     custom_color_enabled: true
#     show_single_value_title: true
#     show_comparison: true
#     comparison_type: value
#     comparison_reverse_colors: true
#     show_comparison_label: true
#     enable_conditional_formatting: false
#     conditional_formatting_include_totals: false
#     conditional_formatting_include_nulls: false
#     comparison_label: of Total
#     series_types: {}
#     defaults_version: 1
#     hidden_fields: []
#     listen:
#       Date: final_patient_status_dashboard.snapshot_date
#     row: 2
#     col: 12
#     width: 4
#     height: 4
#   - title: "# Patients who Died"
#     name: "# Patients who Died"
#     model: fhir_hcls
#     explore: final_patient_status_dashboard
#     type: single_value
#     fields: [final_patient_status_dashboard.snapshot_date, final_patient_status_dashboard.count_patients_status_6_death,
#       final_patient_status_dashboard.percent_patients_status_6_death]
#     fill_fields: [final_patient_status_dashboard.snapshot_date]
#     sorts: [final_patient_status_dashboard.snapshot_date desc]
#     limit: 500
#     dynamic_fields: [{table_calculation: offset, label: offset, expression: 'offset(${final_patient_status_dashboard.count_patients},1)',
#         value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
#         _type_hint: number, is_disabled: true}, {table_calculation: vs_yesterday,
#         label: "% vs. Yesterday", expression: "(${final_patient_status_dashboard.count_patients}\
#           \ - ${offset})/${offset}", value_format: !!null '', value_format_name: percent_1,
#         _kind_hint: measure, _type_hint: number, is_disabled: true}]
#     custom_color_enabled: true
#     show_single_value_title: true
#     show_comparison: true
#     comparison_type: value
#     comparison_reverse_colors: true
#     show_comparison_label: true
#     enable_conditional_formatting: false
#     conditional_formatting_include_totals: false
#     conditional_formatting_include_nulls: false
#     comparison_label: of Total
#     series_types: {}
#     defaults_version: 1
#     hidden_fields: []
#     listen:
#       Date: final_patient_status_dashboard.snapshot_date
#     row: 2
#     col: 20
#     width: 4
#     height: 4
#   - title: Total Patients with COVID
#     name: Total Patients with COVID
#     model: fhir_hcls
#     explore: final_patient_status_dashboard
#     type: single_value
#     fields: [final_patient_status_dashboard.snapshot_date, final_patient_status_dashboard.count_patients]
#     fill_fields: [final_patient_status_dashboard.snapshot_date]
#     sorts: [final_patient_status_dashboard.snapshot_date desc]
#     limit: 500
#     dynamic_fields: [{table_calculation: offset, label: offset, expression: 'offset(${final_patient_status_dashboard.count_patients},1)',
#         value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
#         _type_hint: number, is_disabled: true}, {table_calculation: vs_yesterday,
#         label: "% vs. Yesterday", expression: "(${final_patient_status_dashboard.count_patients}\
#           \ - ${offset})/${offset}", value_format: !!null '', value_format_name: percent_1,
#         _kind_hint: measure, _type_hint: number, is_disabled: true}]
#     custom_color_enabled: true
#     show_single_value_title: true
#     show_comparison: false
#     comparison_type: value
#     comparison_reverse_colors: true
#     show_comparison_label: true
#     enable_conditional_formatting: false
#     conditional_formatting_include_totals: false
#     conditional_formatting_include_nulls: false
#     comparison_label: of Total
#     series_types: {}
#     defaults_version: 1
#     hidden_fields: []
#     listen:
#       Date: final_patient_status_dashboard.snapshot_date
#     row: 2
#     col: 0
#     width: 4
#     height: 4
#   - name: COVID Patient Statuses
#     type: text
#     title_text: COVID Patient Statuses
#     subtitle_text: As of Date Specified
#     body_text: ''
#     row: 0
#     col: 0
#     width: 24
#     height: 2
#   filters:
#   - name: Pivot
#     title: Pivot
#     type: field_filter
#     default_value: organization^_name
#     allow_multiple_values: true
#     required: false
#     ui_config:
#       type: advanced
#       display: popover
#     model: fhir_hcls
#     explore: final_patient_status_dashboard
#     listens_to_filters: []
#     field: final_patient_status_patient_details_dashboard.pivot
#   - name: Date
#     title: Date
#     type: field_filter
#     default_value: 2020/06/28
#     allow_multiple_values: true
#     required: false
#     model: fhir_hcls
#     explore: final_patient_status_dashboard
#     listens_to_filters: []
#     field: final_patient_status_dashboard.snapshot_date


# - dashboard: 2__covid__status_risk_score_over_time
#   title: 2 - COVID - Status Risk Score over Time
#   layout: newspaper
#   elements:
#   - title: Status Risk Score over Time
#     name: Status Risk Score over Time
#     model: fhir_hcls
#     explore: final_patient_status_dashboard
#     type: looker_line
#     fields: [final_patient_status_dashboard.days_since_first_event, final_patient_status_dashboard.average_patient_score,
#       final_patient_status_patient_details_dashboard.min_organization_name]
#     pivots: [final_patient_status_patient_details_dashboard.min_organization_name]
#     filters:
#       final_patient_status_dashboard.count_patients: ">10"
#     sorts: [final_patient_status_patient_details_dashboard.min_organization_name desc
#         0, final_patient_status_dashboard.days_since_first_event]
#     limit: 500
#     column_limit: 50
#     x_axis_gridlines: false
#     y_axis_gridlines: true
#     show_view_names: false
#     show_y_axis_labels: true
#     show_y_axis_ticks: true
#     y_axis_tick_density: default
#     y_axis_tick_density_custom: 5
#     show_x_axis_label: true
#     show_x_axis_ticks: true
#     y_axis_scale_mode: linear
#     x_axis_reversed: false
#     y_axis_reversed: false
#     plot_size_by_field: false
#     trellis: ''
#     stacking: ''
#     limit_displayed_rows: false
#     legend_position: center
#     point_style: none
#     show_value_labels: false
#     label_density: 25
#     x_axis_scale: auto
#     y_axis_combined: true
#     show_null_points: true
#     interpolation: linear
#     y_axes: [{label: Status Risk Score, orientation: left, series: [{axisId: final_patient_status_dashboard.average_patient_score,
#             id: final_patient_status_dashboard.average_patient_score, name: Average
#               Patient Score}], showLabels: true, showValues: true, unpinAxis: false,
#         tickDensity: default, tickDensityCustom: 5, type: linear}]
#     defaults_version: 1
#     listen:
#       Days since COVID Diagnosis: final_patient_status_dashboard.days_since_first_event
#       Age: final_patient_status_patient_details_dashboard.patient_age_tier
#       Gender: final_patient_status_patient_details_dashboard.min_gender
#     row: 0
#     col: 0
#     width: 19
#     height: 11
#   filters:
#   - name: Days since COVID Diagnosis
#     title: Days since COVID Diagnosis
#     type: field_filter
#     default_value: "[1, 30]"
#     allow_multiple_values: true
#     required: false
#     model: fhir_hcls
#     explore: final_patient_status_dashboard
#     listens_to_filters: []
#     field: final_patient_status_dashboard.days_since_first_event
#   - name: Age
#     title: Age
#     type: field_filter
#     default_value: 70 to 79,80 to 89,90 or Above
#     allow_multiple_values: true
#     required: false
#     model: fhir_hcls
#     explore: final_patient_status_dashboard
#     listens_to_filters: []
#     field: final_patient_status_patient_details_dashboard.patient_age_tier
#   - name: Gender
#     title: Gender
#     type: field_filter
#     default_value: male
#     allow_multiple_values: true
#     required: false
#     model: fhir_hcls
#     explore: final_patient_status_dashboard
#     listens_to_filters: []
#     field: final_patient_status_patient_details_dashboard.min_gender
