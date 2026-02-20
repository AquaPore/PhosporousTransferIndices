module PhosphorusTransferIndices

using Configurations, TOML, CSV, DataFrames, Dates, Statistics

export PHOSPHOROUS_START

include("ReadToml.jl")
include("Table.jl")
include("Plot.jl")

	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#		FUNCTION : PHOSPHOROUS_START
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		function PHOSPHOROUS_START(;Path_Toml)
			printstyled("======= Start Running phosphorous ========== \n", color = :red)
			println(" ")

			# READ TOML INPUT FILE
				Path_Toml₁ = joinpath(pwd(), Path_Toml)
				option = readtoml.READTOML(Path_Toml₁)

			# READING LIST OF SITES IN FOLDER
				QsitesList = readdir(option.path.InputDischarge)
				QsitesList = sort(QsitesList, by = QsitesList -> QsitesList[1])
				Nsites = length(QsitesList)

			# INITIALIZING
            Npercentile        = length(option.param.Percentile)
            Percentile_QₓP     = zeros(Float64, Nsites, Npercentile)
            Percentile_Q       = zeros(Float64, Nsites, Npercentile)
            Percentile_P       = zeros(Float64, Nsites, Npercentile)
            Percentile_QmatchP = zeros(Float64, Nsites, Npercentile)
            P_Min  = zeros(Float64, Nsites)
            P_Max = zeros(Float64, Nsites)
            Q_Min  = zeros(Float64, Nsites)
            Q_Max  = zeros(Float64, Nsites)

			PsitesList = []

			# FOR EVERY SITE
			Date_P=[]; Date_Q=[]; P=[]; Q=[]; QₓP=[]; iiSite_P=""
			for (iSite, iiSite) in enumerate(QsitesList)

				# Abstracting discharge: Q
					Path_Input_Discharge = joinpath(pwd(), option.path.InputDischarge, iiSite)
					@assert isfile(Path_Input_Discharge)

				# Reading discharge data
				Data_Discharge = CSV.read(Path_Input_Discharge, DataFrame; header=true)
					Date_Q = convert(Vector, Tables.getcolumn(Data_Discharge, :date))
					Date_Q = Date.(Dates.year.(Date_Q), Dates.month.(Date_Q), Dates.day.(Date_Q))
					Q = convert(Vector{Float64}, Tables.getcolumn(Data_Discharge, :value))

				# Phosphorous sites
					iFind = findfirst('-', iiSite)
					iiSite_P = iiSite[(iFind+1):end]
					PsitesList = push!(PsitesList, iiSite_P)

					PathInput_P = joinpath(pwd(), option.path.InputConcentration, iiSite_P)
					@assert isfile(PathInput_P)
					Data_P = CSV.read(PathInput_P, DataFrame; header = true)
						Date_P = convert(Vector, Tables.getcolumn(Data_P, :date))
						Date_P = Date.(Dates.year.(Date_P), Dates.month.(Date_P), Dates.day.(Date_P))

				P = convert(Vector{Float64}, Tables.getcolumn(Data_P, :value))

				# Matching dates of concentration of P and Q
					QmatchP, QₓP = PhosphorusTransferIndices.MATCHING_DATES(;option.path.OutputPath, iiSite_P, Date_P, P, Date_Q, Q)

				Percentile_P, Percentile_Q, Percentile_QmatchP, Percentile_QₓP, P_Max, P_Min, Q_Max, Q_Min = STATISTICS(;iSite, option.param, P_Min, P_Max, Q_Min, Q_Max, QₓP, Q, P, QmatchP, Npercentile, Percentile_QₓP, Percentile_Q, Percentile_P, Percentile_QmatchP)

			end # FOR EVERY SITE
			plot.PLOT(;option.path, Date_P, Date_Q, P, Q, QₓP, iiSite_P)

			table.TABLE_iiSITE(;option.param.Percentile, P_Min, P_Max, Q_Min, Q_Max, QsitesList, PsitesList, Percentile_QₓP, Percentile_Q, Percentile_P, Percentile_QmatchP, option.path.OutputPath)

		println("")
		printstyled("======= End Running phosphorous ========== \n", color = :red)
		end # function PHOSPHOROUS_START
	# ------------------------------------------------------------------


	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#		FUNCTION : MATCHING_DATES
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		function MATCHING_DATES(;OutputPath, iiSite_P, Date_P, P, Date_Q, Q)
			QmatchP=[]
			QₓP=[]

			iDate_P = 1
			for (iDate_Q, iiDate_Q) in enumerate(Date_Q)
				if iiDate_Q == Date_P[iDate_P]

					QmatchP = append!(QmatchP, Q[iDate_Q])

					QₓP₀ = Q[iDate_Q] * P[iDate_P]
					QₓP = append!(QₓP, QₓP₀)

					@assert !(Date_P[iDate_P] > iiDate_Q)

					iDate_P += 1
				end
			end

			Header = ["Date", "Year", "Month", "Day", "Q[m³ day⁻¹]", "P[g m⁻³]", "QₓP[g m³ day⁻¹]"]
			Df = Dates.DateFormat("y-m-d")
			Path_Output_QₓP = joinpath(OutputPath, "P_Q_Relationship", "QₓP_" * iiSite_P)

			CSV.write(Path_Output_QₓP, Tables.table([Date_P year.(Date_P) month.(Date_P) day.(Date_P) QmatchP P QₓP]), writeheader = true, header = Header, bom = true)

		return QmatchP, QₓP
		end # function MATCHING_DATES
	# ------------------------------------------------------------------


	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#		FUNCTION : PERCENTILE
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		function STATISTICS(;iSite, param, QₓP, Q, P, QmatchP, Npercentile, Percentile_QₓP, Percentile_Q, Percentile_P, Percentile_QmatchP, P_Min, P_Max, Q_Min, Q_Max)

			# PERCENTILES
				Percentile_QₓP[iSite, 1: Npercentile] 	   = Statistics.quantile(QₓP[:], param.Percentile)
				Percentile_Q[iSite, 1: Npercentile] 		= Statistics.quantile(Q[:], param.Percentile)
				Percentile_P[iSite, 1: Npercentile] 		= Statistics.quantile(P[:], param.Percentile)
				Percentile_QmatchP[iSite, 1:Npercentile]  = Statistics.quantile(QmatchP[:], param.Percentile)

			# MIN MAX values
				P_Min[iSite] = minimum(P[:])
				P_Max[iSite] = maximum(P[:])
				Q_Min[iSite] = minimum(Q[:])
				Q_Max[iSite] = maximum(Q[:])

		return Percentile_P, Percentile_Q, Percentile_QmatchP, Percentile_QₓP, P_Max, P_Min, Q_Max, Q_Min
		end  # function: PERCENTILE
	# ------------------------------------------------------------------
end # module PhosporousTransferIndices

# include(raw"D:\JOE\MAIN\MODELS\PHOSPHOROUS\PhosporousTransferIndices\src\PhosphorusTransferIndices.jl")
Path_Toml = raw"D:\JOE\MAIN\MODELS\PHOSPHOROUS\PhosporousTransferIndices\PARAMETER\PhosphorousOption.toml"
PhosphorusTransferIndices.PHOSPHOROUS_START(;Path_Toml)