using Plots

# plot the yearly CO2 emmisions for producing 6.44 TWh per year from gas or wind
# first scenary: until 2040 100% wind energy

# TODO add offshore wind

const CO2_liquid_gas = 238.8  # g per kWh
const CO2_wind_land  =   5.6  # g per kWh
WIND_ENERGY_PER_TURBINE = 440 # GWh in 20 years
CONSUMPTION_ONSHORE =    6440 # GWh per year from new onshore turbines
CONSUMPTION_GAS =       40500 # GWh electricity from gas per year in the 2040 scenario
LIFE_TIME = 20                # lifetime of a turbine in years
YEARS = 10                    # simulation time in years
WINDTURBINE_CO2 = WIND_ENERGY_PER_TURBINE * 1e6 * CO2_wind_land / 1e6

mutable struct State
    wind_turbines::Int64
    wind_co2::Float64 # emmissions from building the turbines
    gas_co2::Float64  # emmissions from burning gas
    wind_co2_tot::Float64
    gas_co2_tot::Float64
end

function build_turbines(s::State, n)
    s.wind_turbines += n
    s.wind_co2 = WINDTURBINE_CO2 * n
    s.wind_co2_tot += s.wind_co2
end

# calculate the co2 emmisions per year
# energy: electricity in kWh
# returns CO2 emmisions in tons
function calc_co2(s::State, energy)
    # produce as much of the required energy using wind energy
    energy -= s.wind_turbines * (WIND_ENERGY_PER_TURBINE*1e6/LIFE_TIME)
    if energy < 0 
        energy = 0.0
    end
    # produce the remaining energy needed from gas
    s.gas_co2 = CO2_liquid_gas*energy/1000000
    s.gas_co2 += CO2_liquid_gas*CONSUMPTION_GAS
    s.gas_co2_tot += s.gas_co2
end

function calc_scenario(turbines_per_year, prn=false)
    s = State(0, 0.0, 0.0, 0.0, 0.0)
    Y = zeros(YEARS)
    X = 1:YEARS
    for i = 1:YEARS
        calc_co2(s, CONSUMPTION_ONSHORE*1e6)
        build_turbines(s, turbines_per_year)
        co2 = s.wind_co2 + s.gas_co2
        Y[i] = co2/1e6
        if prn
            println(i+2020, " CO2 emmisions: $co2 tons")
        end
    end
    X, Y
end

X, Y = calc_scenario(32, true)
plot(X, Y, ylims=(0,Inf), label="yearly CO2 emmissions [Mt]")
X1, Y1 = calc_scenario(0)
plot!(X, Y1, label="yearly emmisions without turbines [Mt]")