using DataFrames
using Statistics

function calculate_bollinger_bands(data::DataFrame, window::Int, num_std::Float64)
    data[!, :MA] = shift(DataFrames.groupby(data, :Symbol)[:, :Close] .rolling(window=window) => mean)
    data[!, :Std] = shift(DataFrames.groupby(data, :Symbol)[:, :Close] .rolling(window=window) => std)
    data[!, :UpperBand] = data[:, :MA] + num_std * data[:, :Std]
    data[!, :LowerBand] = data[:, :MA] - num_std * data[:, :Std]

    return data
end

function generate_signals(data::DataFrame)
    data[!, :Signal] = ifelse.(data[:, :Close] .> data[:, :UpperBand], -1,
                                ifelse.(data[:, :Close] .< data[:, :LowerBand], 1, 0))

    data[!, :Position] = lag(data[:, :Signal])

    return data
end

# Example Data
data = DataFrame(Symbol = ["AAPL", "AAPL", "AAPL", "AAPL"],
                  Date = ["2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04"],
                  Close = [100.0, 105.0, 98.0, 110.0])

data[!, :Date] = Dates.Date.(data[!, :Date], "yyyy-mm-dd")
data[!, :MA] = missing
data[!, :Std] = missing
data[!, :UpperBand] = missing
data[!, :LowerBand] = missing
data[!, :Signal] = missing
data[!, :Position] = missing

window = 3
num_std = 2.0

data = calculate_bollinger_bands(data, window, num_std)
data = generate_signals(data)

println(data)
