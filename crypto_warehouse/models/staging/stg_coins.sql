-- stg_coins.sql
-- Unifica los 23 CSVs de criptomonedas en una sola tabla limpia.
-- Renombra columnas a snake_case, convierte fechas y elimina duplicados.

with source as (

    {% set coins = [
        'coin_Aave', 'coin_BinanceCoin', 'coin_Bitcoin', 'coin_Cardano',
        'coin_ChainLink', 'coin_Cosmos', 'coin_CryptocomCoin', 'coin_Dogecoin',
        'coin_EOS', 'coin_Ethereum', 'coin_Iota', 'coin_Litecoin',
        'coin_Monero', 'coin_NEM', 'coin_Polkadot', 'coin_Solana',
        'coin_Stellar', 'coin_Tether', 'coin_Tron', 'coin_USDCoin',
        'coin_Uniswap', 'coin_WrappedBitcoin', 'coin_XRP'
    ] %}

    {% for coin in coins %}
        select
            SNo,
            Name,
            Symbol,
            Date,
            High,
            Low,
            Open,
            Close,
            Volume,
            Marketcap
        from {{ ref(coin) }}
        {% if not loop.last %}union all{% endif %}
    {% endfor %}

),

renamed as (

    select
        -- IDs
        cast(SNo as integer)                        as sno,
        Name                                        as name,
        upper(Symbol)                               as symbol,

        -- Fecha — convertir a DATE
        cast(Date as date)                          as date,

        -- Precios
        round(cast(High as double), 4)              as high_price,
        round(cast(Low as double), 4)               as low_price,
        round(cast(Open as double), 4)              as open_price,
        round(cast(Close as double), 4)             as close_price,

        -- Volumen y capitalización
        round(cast(Volume as double), 2)            as volume_usd,
        round(cast(Marketcap as double), 2)         as market_cap_usd,

        -- Clave única
        Name || '_' || cast(Date as varchar)        as coin_id

    from source

)

select * from renamed
