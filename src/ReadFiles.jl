module readFiles

function READ_FILE()

end


QsitesList = readdir(Input_PathDischarge)
QsitesList = sort(QsitesList, by = QsitesList -> QsitesList[1])
PsitesList = []

N_Sites = length(QsitesList)
N_Percentile = length(Percentile)

Percentile_QₓP = zeros(Float64, N_Sites, N_Percentile)
Percentile_Q = zeros(Float64, N_Sites, N_Percentile)
Percentile_P = zeros(Float64, N_Sites, N_Percentile)
Percentile_QmatchP = zeros(Float64, N_Sites, N_Percentile)

for (iSite, iiSite) in enumerate(QsitesList)
	# Abstracting discharge
		Path_Input_Discharge = joinpath(pwd(), Input_PathDischarge, iiSite)
		@assert isfile(Path_Input_Discharge)

		Data_Discharge  = CSV.read(Path_Input_Discharge, DataFrame; header=true)
			Date_Q= convert(Vector, Tables.getcolumn(Data_Discharge, :date))
			Q = convert(Vector{Float64}, Tables.getcolumn(Data_Discharge, :value))
			Date_Q = Date.(Dates.year.(Date_Q), Dates.month.(Date_Q), Dates.day.(Date_Q))

	# Abstracting concentration
		iFind = findfirst('-', iiSite)
		iiSite_P = iiSite[iFind+1: end]
		PsitesList =  push!(PsitesList, iiSite_P)

		println(iiSite_P)
		Path_Input_Concentration = joinpath(pwd(), Input_PathConcentration, iiSite_P)
		@assert isfile(Path_Input_Concentration)

		Data_Concentration  = CSV.read(Path_Input_Concentration, DataFrame; header=true)
			Date_P= convert(Vector, Tables.getcolumn(Data_Concentration, :date))
			Date_P = Date.(Dates.year.(Date_P), Dates.month.(Date_P), Dates.day.(Date_P))

			P = convert(Vector{Float64}, Tables.getcolumn(Data_Concentration, :value))

	# Matching dates of concentration of P and Q
		QmatchP, QₓP = MATCHING_DATES(;OutputPath, iiSite_P, Date_P, P, Date_Q, Q)

      Percentile_QₓP[iSite, 1      : N_Percentile] = Statistics.quantile(QₓP, Percentile)
      Percentile_Q[iSite, 1        : N_Percentile] = Statistics.quantile(Q, Percentile)
      Percentile_P[iSite, 1        : N_Percentile] = Statistics.quantile(P, Percentile)
      Percentile_QmatchP[iSite, 1 : N_Percentile] = Statistics.quantile(QmatchP, Percentile)

end



end