-- mart_market_dominance.sql
-- Dominancia de mercado por criptomoneda y año.
-- Muestra qué porcentaje del market cap total representó cada coin por año.

with daily as (

    select * from {{ ref('stg_coins') }}

),

yearly as (

    select
        year(date)                                              as year,
        name,
        symbol,
        round(avg(market_cap_usd), 2)                          as avg_market_cap,
        round(avg(close_price), 4)                             as avg_price,
        round(avg(volume_usd), 2)                              as avg_volume

    from daily
    where market_cap_usd > 0
    group by year(date), name, symbol

),

with_dominance as (

    select
        year,
        name,
        symbol,
        avg_market_cap,
        avg_price,
        avg_volume,
        sum(avg_market_cap) over (partition by year)            as total_market_cap_year,
        round(
            avg_market_cap / nullif(
                sum(avg_market_cap) over (partition by year), 0
            ) * 100
        , 2)                                                    as dominance_pct

    from yearly

)

select
    year,
    name,
    symbol,
    avg_market_cap,
    avg_price,
    avg_volume,
    total_market_cap_year,
    dominance_pct,
    rank() over (partition by year order by avg_market_cap desc) as rank_by_year

from with_dominance
order by year, dominance_pct desc
