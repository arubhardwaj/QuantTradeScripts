using DataFrames, Backtest.jl

# Define the strategy
function multi_indicator_strategy(data)
    # Calculate the moving averages
    short_ma = SeriesMovingAverage(data, 10)
    long_ma = SeriesMovingAverage(data, 20)

    # Calculate the Relative Strength Index (RSI)
    rsi = SeriesRSI(data, 14)

    # Calculate the Bollinger Bands
    bands = SeriesBollingerBands(data, 20, 2)

    # Generate signals
    signals = DataFrame(time=data.time, signal=NaN)

    # Enter long positions when the price is below the lower Bollinger Band and RSI is oversold
    signals.signal[data.price < bands.lower_band & rsi < 30] = 1

    # Exit long positions when the price crosses above the upper Bollinger Band or RSI is overbought
    signals.signal[data.price > bands.upper_band | rsi > 70] = 0

    # Enter short positions when the price is above the upper Bollinger Band and RSI is overbought
    signals.signal[data.price > bands.upper_band & rsi > 70] = -1

    # Exit short positions when the price crosses below the lower Bollinger Band or RSI is oversold
    signals.signal[data.price < bands.lower_band | rsi < 30] = 0

    return signals
end

# Define the backtest
backtest = Backtest(multi_indicator_strategy, data)

# Run the backtest
results = run(backtest)

# Print the results
println(results)
