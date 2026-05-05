-- mart_daily_prices.sql
-- Precios diarios enriquecidos con métricas calculadas:
-- retorno diario, rango de precio y año/mes para análisis temporal.

with base as (

    select * from {{ ref('stg_coins') }}

),

with_metrics as (

    select
        name,
        symbol,
        date,
        year(date)                                              as year,
        month(date)                                             as month,
        open_price,
        high_price,
        low_price,
        close_price,
        volume_usd,
        market_cap_usd,

        -- Rango de precio diario (volatilidad intradía)
        round(high_price - low_price, 4)                        as price_range,

        -- Retorno diario (%)
        round(
            (close_price - lag(close_price) over (
                partition by name order by date
            )) / nullif(lag(close_price) over (
                partition by name order by date
            ), 0) * 100
        , 4)                                                    as daily_return_pct,

        -- Clasificación de rendimiento
        case
            when close_price > open_price then 'Bullish'
            when close_price < open_price then 'Bearish'
            else 'Neutral'
        end                                                     as day_sentiment

    from base

)

select * from with_metrics
