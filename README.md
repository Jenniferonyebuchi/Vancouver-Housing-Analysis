# Vancouver Housing Analysis

This project examines how housing affordability and core housing need vary across visible minority groups in Vancouver, with a specific focus on how Black households compare with other groups across time. The work is built around a Shiny dashboard that makes the story accessible to a broad audience through clear visuals and interactive comparisons.

## Project purpose

Vancouver has long faced intense pressure on housing affordability, and the data used in this project suggests that these pressures are not distributed evenly across communities. The dashboard is designed to make visible who is carrying the heaviest burden in terms of shelter costs, household income, and core housing need.

The goal is not to reduce a complex issue to a single story, but to show where the data points suggest structural inequities in the housing market. In particular, the findings are consistent with the view that Black households in Vancouver experience significant marginalization within the housing system.

## Data source

The project draws on Statistics Canada data on household income, shelter costs, tenure, and core housing need for Vancouver by visible minority status. The dataset includes multiple time points from 2001 to 2021 and is processed into a clean long-format table before being visualized.

The project workflow is organized as follows:

- [scripts/prepare_vancouver_housing_data.R](scripts/prepare_vancouver_housing_data.R) cleans the original Excel workbook and standardizes labels.
- [data/vancouver_housing_tidy.csv](data/vancouver_housing_tidy.csv) stores the cleaned table used by the app.
- [app.R](app.R) renders the interactive dashboard.

## What the dashboard shows

The dashboard allows users to:

- compare selected visible minority groups side by side,
- switch between years from 2001 to 2021,
- compare different housing indicators,
- filter by tenure,
- separate households into those in core housing need versus those not in core housing need.

Groups included in the comparison are designed to preserve the original Statistics Canada categories rather than collapsing them into broad buckets. This approach keeps the data faithful to the source table and allows for more precise community-level comparison.

## Findings from the data

The data supports a clear pattern of housing vulnerability for Black households in Vancouver:

- In 2021, Black households in Vancouver totaled 13,975 households.
- 3,355 Black households were in core housing need, or roughly 24% of all Black households in the dataset.
- Among Black households in core housing need, the average shelter-cost-to-income ratio was 43.9%.
- For Black households not in core housing need, the average shelter-cost-to-income ratio was 21.3%.
- Black households in core housing need had an average household income of $43,640, with an average monthly shelter cost of $1,470.

This pattern matters because it shows that Black households are not simply facing a general affordability problem; they are facing a severe one, where income is comparatively low while shelter costs remain high enough to push households into core housing need. The figures suggest that Black households are heavily exposed to housing strain in Vancouver, even when measured against other visible minority groups.

## Important nuance

The dataset is not a causal model, and it does not isolate one single explanation for the observed disparities. But the evidence is consistent with a broader story of marginalization in the housing market: households with lower income and higher shelter-cost burdens are more likely to be in core housing need. Within that pattern, Black households are clearly among those experiencing serious pressure.

The app is therefore best read as a public-facing evidence tool: it highlights where the data suggests inequity, and it helps users see how housing outcomes differ across communities over time.

## How to run the app

From the project root, run:

```r
shiny::runApp()
```

This will launch the interactive dashboard locally.

## Summary

The project does not claim that one group is the only one affected by housing stress. Instead, it shows that Black households in Vancouver experience a pronounced concentration of affordability pressure and core housing need in the data. That is the central finding this dashboard is designed to surface.