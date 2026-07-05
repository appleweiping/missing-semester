#!/usr/bin/env bash
# Ex6: Find an online dataset, fetch it with curl, extract two columns of
# numerical data, compute the min/max of one column, and the difference of
# the two column sums — each in a single pipeline.
#
# Dataset: the World Bank total-population indicator (SP.POP.TOTL) is served as
# JSON. To keep this fully offline-reproducible and dependency-light, we fetch
# a small, stable CSV of country population for two years and process it.
#
# We use the restcountries-style dataset via a stable CSV mirror. If the network
# is unavailable, we fall back to a committed sample so the pipeline still runs.
set -uo pipefail

DIR="$(dirname "$0")"
CSV="$DIR/data/population.csv"
mkdir -p "$DIR/data"

# Two-column numeric CSV: population_2000,population_2020 for a set of countries.
URL="https://raw.githubusercontent.com/datasets/population/main/data/population.csv"

fetch() {
    echo "fetching dataset with curl ..."
    # The datasets/population CSV has columns: Country Name,Country Code,Year,Value
    curl -fsSL --retry 3 "$URL" -o "$DIR/data/population_raw.csv" 2>/dev/null
}

if fetch && [ -s "$DIR/data/population_raw.csv" ]; then
    RAW="$DIR/data/population_raw.csv"
    echo "got $(wc -l < "$RAW") rows"
    # Build a two-column numeric table: year 2000 value vs year 2020 value,
    # for the country 'World'. Columns are: Country Name,Country Code,Year,Value
    # Extract World, keep Year & Value, pivot to two columns for 2000 and 2020.
    y2000=$(awk -F',' '$1=="World" && $3=="2000"{print $4}' "$RAW")
    y2020=$(awk -F',' '$1=="World" && $3=="2020"{print $4}' "$RAW")
    echo "World population 2000 = $y2000 ; 2020 = $y2020"
    # Also build a per-country two-column file (2000,2020) for the column stats.
    awk -F',' '$3=="2000"{a[$2]=$4} $3=="2020"{b[$2]=$4}
               END{for(k in a) if(k in b) print a[k]","b[k]}' "$RAW" > "$CSV"
else
    echo "network unavailable — using committed sample data/population_sample.csv"
    cp "$DIR/data/population_sample.csv" "$CSV"
fi

echo
echo "two-column numeric data (col1=year2000, col2=year2020), first 5 rows:"
head -5 "$CSV"
rows=$(wc -l < "$CSV")
echo "($rows rows total)"

echo
echo "=== min and max of column 1 (single awk pipeline) ==="
awk -F',' 'NR==1{min=max=$1} {if($1<min)min=$1; if($1>max)max=$1}
           END{printf "min=%d  max=%d\n", min, max}' "$CSV"

echo
echo "=== difference between the sums of the two columns (single pipeline) ==="
awk -F',' '{s1+=$1; s2+=$2} END{printf "sum(col2) - sum(col1) = %d\n", s2-s1}' "$CSV"
