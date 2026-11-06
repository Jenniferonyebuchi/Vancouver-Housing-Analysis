suppressPackageStartupMessages({
  library(readxl)
  library(dplyr)
  library(stringr)
  library(readr)
})

standardize_group <- function(x) {
  x %>%
    str_trim() %>%
    str_replace_all("\\s+", " ") %>%
    recode(
      "Primary household maintainer is a visible minority" = "Visible minority total",
      "Primary household maintainer is not a visible minority" = "Not a visible minority",
      "Total - Visible minority status of the primary household maintainer" = "All households",
      "Visible minority not included elsewhere" = "Visible minority not included elsewhere",
      "Multiple visible minorities" = "Multiple visible minorities"
    )
}

standardize_core_need <- function(x) {
  x %>%
    str_trim() %>%
    str_replace("6$", "") %>%
    recode(
      "Total - Households examined for core housing need" = "Total",
      "Household in core housing need" = "In core housing need",
      "Household not in core housing need" = "Not in core housing need"
    )
}

standardize_tenure <- function(x) {
  x %>%
    str_trim() %>%
    recode(
      "Total - Tenure" = "Total",
      "Total - Tenure " = "Total",
      "Owner" = "Owner",
      "Renter" = "Renter"
    )
}

prepare_vancouver_housing_data <- function(
  excel_path = "data/household-income-costs-visible-minority-groups-2001-2021-en.xlsx",
  output_path = "data/vancouver_housing_tidy.csv"
) {
  years <- c("2001", "2006", "2011", "2016", "2021")

  all_rows <- lapply(years, function(year) {
    sheet_df <- read_excel(excel_path, sheet = year, col_names = FALSE, skip = 8)

    if (ncol(sheet_df) < 8) {
      return(NULL)
    }

    names(sheet_df) <- c(
      "geography",
      "core_housing_need_status",
      "tenure",
      "visible_minority_status",
      "household_count",
      "avg_household_income",
      "avg_monthly_shelter_cost",
      "avg_stir_pct"
    )

    sheet_df <- sheet_df[-1, ]

    sheet_df %>%
      filter(!is.na(geography)) %>%
      filter(trimws(geography) == "Vancouver" | grepl("^Vancouver", trimws(geography))) %>%
      mutate(
        year = as.integer(year),
        geography = str_trim(geography),
        core_housing_need_status = standardize_core_need(core_housing_need_status),
        tenure = standardize_tenure(tenure),
        visible_minority_status = standardize_group(visible_minority_status),
        household_count = suppressWarnings(as.numeric(gsub("[^0-9-]", "", household_count))),
        avg_household_income = suppressWarnings(as.numeric(gsub("[^0-9-]", "", avg_household_income))),
        avg_monthly_shelter_cost = suppressWarnings(as.numeric(gsub("[^0-9-]", "", avg_monthly_shelter_cost))),
        avg_stir_pct = suppressWarnings(as.numeric(avg_stir_pct))
      ) %>%
      select(
        year,
        geography,
        core_housing_need_status,
        tenure,
        visible_minority_status,
        household_count,
        avg_household_income,
        avg_monthly_shelter_cost,
        avg_stir_pct
      )
  })

  df <- bind_rows(all_rows)

  write_csv(df, output_path)
  message("Saved tidy data to: ", output_path)
  return(df)
}

if (sys.nframe() == 0) {
  prepare_vancouver_housing_data()
}
