-- mart_coin_performance.sql
-- Resumen histórico de rendimiento por criptomoneda.
-- Incluye precio inicial, final, crecimiento total y métricas de volatilidad.

with daily as (

    select * from {{ ref('mart_daily_prices') }}

),

first_last as (

    select
        name,
        symbol,
        min(date)                                               as first_date,
        max(date)                                               as last_date,
        count(*)                                                as total_days

    from daily
    group by name, symbol

),

prices as (

    select
        d.name,
        d.symbol,
        fl.first_date,
        fl.last_date,
        fl.total_days,

        -- Precio inicial y final
        first(d.close_price order by d.date)                    as first_price,
        last(d.close_price order by d.date)                     as last_price,

        -- Métricas históricas
        round(max(d.high_price), 4)                             as all_time_high,
        round(min(d.low_price), 4)                              as all_time_low,
        round(avg(d.close_price), 4)                            as avg_price,
        round(avg(d.volume_usd), 2)                             as avg_volume,
        round(max(d.market_cap_usd), 2)                         as peak_market_cap,

        -- Mejor y peor día
        round(max(d.daily_return_pct), 2)                       as best_day_return_pct,
        round(min(d.daily_return_pct), 2)                       as worst_day_return_pct,

        -- Volatilidad promedio
        round(avg(d.price_range), 4)                            as avg_daily_range,

        -- Días alcistas vs bajistas
        count(case when d.day_sentiment = 'Bullish' then 1 end) as bullish_days,
        count(case when d.day_sentiment = 'Bearish' then 1 end) as bearish_days

    from daily d
    join first_last fl on d.name = fl.name
    group by d.name, d.symbol, fl.first_date, fl.last_date, fl.total_days

)

select
    name,
    symbol,
    first_date,
    last_date,
    total_days,
    first_price,
    last_price,
    round((last_price - first_price) / nullif(first_price, 0) * 100, 2) as total_return_pct,
    all_time_high,
    all_time_low,
    avg_price,
    avg_volume,
    peak_market_cap,
    best_day_return_pct,
    worst_day_return_pct,
    avg_daily_range,
    bullish_days,
    bearish_days,
    round(bullish_days * 100.0 / nullif(total_days, 0), 1)              as bullish_pct

from prices
order by total_return_pct desc
