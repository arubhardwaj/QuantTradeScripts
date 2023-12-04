using DataFrames

function generate_signals(data::DataFrame, short_window::Int, long_window::Int)
    data[!, :Short_MA] = shift(data[:, :Close], -short_window)
    data[!, :Long_MA] = shift(data[:, :Close], -long_window)

    data[!, :Signal] = ifelse.(data[:, :Short_MA] .> data[:, :Long_MA], 1, -1)

    data[!, :Position] = lag(data[:, :Signal])

    return data
end

function simulate_trading(data::DataFrame, initial_capital::Float64, stop_loss::Float64, target_profit::Float64)
    capital = initial_capital
    position = 0

    for i in 1:size(data, 1)
        if data[i, :Position] == 1 && position == 0
            # Buy signal
            entry_price = data[i, :Close]
            stop_loss_price = entry_price * (1 - stop_loss)
            target_profit_price = entry_price * (1 + target_profit)
            position = 1
        elseif data[i, :Position] == -1 && position == 1
            # Sell signal
            exit_price = data[i, :Close]
            capital = capital * (exit_price / entry_price)
            position = 0
        elseif position == 1
            # Check for stop loss or target profit
            if data[i, :Low] <= stop_loss_price
                exit_price = stop_loss_price
                capital = capital * (exit_price / entry_price)
                position = 0
            elseif data[i, :High] >= target_profit_price
                exit_price = target_profit_price
                capital = capital * (exit_price / entry_price)
                position = 0
            end
        end
    end

    return capital
end

# Example usage
data = DataFrame(Date = ["2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04"],
                  Close = [100.0, 105.0, 98.0, 110.0],
                  High = [102.0, 107.0, 100.0, 115.0],
                  Low = [98.0, 103.0, 96.0, 108.0])

data[!, :Date] = Dates.Date.(data[!, :Date], "yyyy-mm-dd")
data[!, :Short_MA] = missing
data[!, :Long_MA] = missing
data[!, :Signal] = missing
data[!, :Position] = missing

short_window = 2
long_window = 4
initial_capital = 10000.0
stop_loss = 0.02
target_profit = 0.04

data = generate_signals(data, short_window, long_window)

final_capital = simulate_trading(data, initial_capital, stop_loss, target_profit)

println("Final Capital: $final_capital")
