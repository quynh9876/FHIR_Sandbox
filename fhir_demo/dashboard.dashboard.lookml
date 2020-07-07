##################
# Overall (SDOH)
##################
- dashboard: 3__facility__vulnerability__strategic_planning
  title: 3 - Facility - Vulnerability / Strategic Planning
  layout: newspaper
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
    fields: [analytics.vulnerability_score, analytics.patient_postal_code]
    filters:
      analytics.admission_date: 7 days
      analytics.patient_state: OH
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
    series_types: {}
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    defaults_version: 1
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
    fields: [analytics.patient_postal_code, analytics.average_population_density]
    filters:
      analytics.admission_date: 7 days
      analytics.patient_state: OH
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
    fields: [analytics.pivot_value, analytics.median_income, analytics.percent_above_70,
      analytics.average_population_density]
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
        is_active: true
      analytics.median_income:
        is_active: true
      analytics.percent_above_70:
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
    listen:
      Hospital Name: analytics.organization_name
      Pivot Value: analytics.pivot
    row: 11
    col: 12
    width: 12
    height: 7
  filters:
  - name: Hospital Name
    title: Hospital Name
    type: field_filter
    default_value: CCF MAIN CAMPUS
    allow_multiple_values: true
    required: false
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
    model: fhir_hcls
    explore: fhir_hcls
    listens_to_filters: []
    field: analytics.weight_comorbidity
  - name: Pivot Value
    title: Pivot Value
    type: field_filter
    default_value: practitioner^_name
    allow_multiple_values: true
    required: false
    model: fhir_hcls
    explore: fhir_hcls
    listens_to_filters: []
    field: analytics.pivot

##################
# Facility
##################
- dashboard: 9__facility
  title: 9 - Facility
  layout: newspaper
  elements:
  - title: Hospital Name
    name: Hospital Name
    model: fhir_hcls
    explore: fhir_hcls
    type: single_value
    fields: [analytics.organization_name]
    filters: {}
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
    listen:
      Facility Name: analytics.organization_name
      Date: analytics.admission_date
      # COVID Status: analytics.covid_status_selector
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
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    comparison_label: ''
    series_types: {}
    defaults_version: 1
    hidden_fields: [yesterday]
    listen:
      Facility Name: analytics.organization_name
      Date: analytics.admission_date
      # COVID Status: analytics.covid_status_selector
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
    filters: {}
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
    listen:
      Facility Name: analytics.organization_name
      Date: analytics.admission_date
      # COVID Status: analytics.covid_status_selector
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
    filters:
      analytics.patient_state: OH
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
    listen:
      Facility Name: analytics.organization_name
      Date: analytics.admission_date
      # COVID Status: analytics.covid_status_selector
    row: 0
    col: 18
    width: 6
    height: 8
  - title: "# COVID Patients"
    name: "# COVID Patients"
    model: fhir_hcls
    explore: fhir_hcls
    type: single_value
    fields: [analytics.admission_date, analytics.count_covid_confirmed]
    fill_fields: [analytics.admission_date]
    filters: {}
    sorts: [analytics.admission_date desc]
    limit: 500
    dynamic_fields: [{table_calculation: yesterday, label: yesterday, expression: 'offset(${analytics.count_covid_confirmed},1)',
        value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
        _type_hint: number}, {table_calculation: vs_yesterday, label: vs. Yesterday,
        expression: "(${analytics.count_covid_confirmed} - ${yesterday})/${yesterday}",
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
    listen:
      Facility Name: analytics.organization_name
      Date: analytics.admission_date
      # COVID Status: analytics.covid_status_selector
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
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    comparison_label: ''
    series_types: {}
    defaults_version: 1
    hidden_fields: [yesterday]
    listen:
      Facility Name: analytics.organization_name
      Date: analytics.admission_date
      # COVID Status: analytics.covid_status_selector
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
    listen:
      Facility Name: analytics.organization_name
      Date: analytics.admission_date
      # COVID Status: analytics.covid_status_selector
    row: 8
    col: 0
    width: 16
    height: 11
  - title: Inpatient Volume
    name: Inpatient Volume
    model: fhir_hcls
    explore: fhir_hcls
    type: table
    fields: [analytics.admission_day_of_week, analytics.admission_hour_of_day, analytics.count_inpatient_visit]
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
        bold: false, italic: false, strikethrough: false, fields: [analytics.count_inpatient_visit]}]
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
    listen:
      Facility Name: analytics.organization_name
      Date: analytics.admission_date
      # COVID Status: analytics.covid_status_selector
    row: 8
    col: 16
    width: 8
    height: 11
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
    default_value: CCF MAIN CAMPUS
    allow_multiple_values: true
    required: false
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
    model: fhir_hcls
    explore: fhir_hcls
    listens_to_filters: []
    field: analytics.admission_date

##################
# Provider
##################
- dashboard: 9__provider
  title: 9 - Provider
  layout: newspaper
  elements:
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
    listen:
      Date: analytics.admission_date
      Provider Name: analytics.practitioner_name
      # COVID Status: analytics.covid_status_selector
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
    listen:
      Date: analytics.admission_date
      Provider Name: analytics.practitioner_name
      # COVID Status: analytics.covid_status_selector
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
    filters: {}
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
    listen:
      Date: analytics.admission_date
      Provider Name: analytics.practitioner_name
      # COVID Status: analytics.covid_status_selector
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
    filters:
      analytics.patient_state: OH
    sorts: [analytics.count_total_patients desc]
    limit: 500
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
    listen:
      Date: analytics.admission_date
      Provider Name: analytics.practitioner_name
      # COVID Status: analytics.covid_status_selector
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
    filters: {}
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
    listen:
      Date: analytics.admission_date
      Provider Name: analytics.practitioner_name
      # COVID Status: analytics.covid_status_selector
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
    listen:
      Date: analytics.admission_date
      Provider Name: analytics.practitioner_name
      # COVID Status: analytics.covid_status_selector
    row: 8
    col: 0
    width: 24
    height: 10
  filters:
  - name: Date
    title: Date
    type: field_filter
    default_value: 7 days
    allow_multiple_values: true
    required: false
    model: fhir_hcls
    explore: fhir_hcls
    listens_to_filters: []
    field: analytics.admission_date
  - name: Provider Name
    title: Provider Name
    type: field_filter
    default_value: Abelson
    allow_multiple_values: true
    required: false
    model: fhir_hcls
    explore: fhir_hcls
    listens_to_filters: []
    field: analytics.practitioner_name

##################
# Patient
##################
- dashboard: 9__patient
  title: 9 - Patient
  layout: newspaper
  elements:
  - title: General Information
    name: General Information
    model: fhir_hcls
    explore: fhir_hcls
    type: looker_single_record
    fields: [analytics.patient_name, analytics.patient_age_color, analytics.patient_gender,
      analytics.patient_city, analytics.patient_state, analytics.patient_postal_code,
      analytics.covid_status]
    filters: {}
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
    listen:
      Date: analytics.admission_date
      CCF: analytics.patient_name
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
    filters: {}
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
    listen:
      Date: analytics.admission_date
      CCF: analytics.patient_name
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
    filters: {}
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
    listen:
      Date: analytics.admission_date
      CCF: analytics.patient_name
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
    filters: {}
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
    listen:
      Date: analytics.admission_date
      CCF: analytics.patient_name
    row: 0
    col: 15
    width: 5
    height: 5
  - title: Encounter Details
    name: Encounter Details
    model: fhir_hcls
    explore: fhir_hcls
    type: looker_grid
    fields: [analytics.admission_date, analytics.encounter_type, encounter.id,
      analytics.practitioner_name]
    filters: {}
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
    listen:
      Date: analytics.admission_date
      CCF: analytics.patient_name
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
    model: fhir_hcls
    explore: fhir_hcls
    listens_to_filters: []
    field: analytics.admission_date
  - name: CCF
    title: CCF
    type: field_filter
    default_value: '95001586'
    allow_multiple_values: true
    required: false
    model: fhir_hcls
    explore: fhir_hcls
    listens_to_filters: []
    field: analytics.patient_name
