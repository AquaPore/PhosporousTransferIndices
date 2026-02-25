module PhosphorusTransferIndices

using Configurations, TOML, CSV, DataFrames, Dates, Statistics

export PHOSPHOROUS_START

include("ReadToml.jl")
include("Table.jl")
include("Plot.jl")
include("Baseflow.jl")

	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#		FUNCTION : PHOSPHOROUS_START
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		function PHOSPHOROUS_START(;Path_Toml)
			printstyled("======= Start Running phosphorous ========== \n", color = :red)
			println(" ")

			# READ TOML INPUT FILE
				Path_Toml₁ = joinpath(pwd(), Path_Toml)
				option = readtoml.READTOML(Path_Toml₁)

			# CLEANING DELEATING PLOTS & TABLES

				# Cleaning plots
				if option.plot.🎏_Plot_EverySite
					OutputPlots = readdir(option.path.OutputPlot)
					for iPlot ∈ OutputPlots
						rm(joinpath(option.path.OutputPlot, iPlot), force=true)
					end
					rm(joinpath(option.path.OutputPath, "PerSite", "PerSiteStatistics.csv"), force=true)
				end

				# Cleaning table
				OutputTables = readdir(joinpath(option.path.OutputPath, "P_Q_Relationship"))
				for iTable ∈ OutputTables
					rm(joinpath(option.path.OutputPath, "P_Q_Relationship", iTable), force=true)
				end

				OutputTables = readdir(joinpath(option.path.OutputPath, "Baseflow"))
				for iTable ∈ OutputTables
					rm(joinpath(option.path.OutputPath, "Baseflow", iTable), force=true)
				end

			# READING FILE & WHICH SITES TO READ <🎏_SiteTrue>
				Data_SiteInfo = CSV.read(option.path.InputSiteInfo, DataFrame; header = true)

					SiteName_Q = convert(Vector{String}, Tables.getcolumn(Data_SiteInfo, :SiteName_Q))
					SiteName_P = convert(Vector{String}, Tables.getcolumn(Data_SiteInfo, :SiteName_P))
					🎏_SiteTrue = convert(Vector{Bool}, Tables.getcolumn(Data_SiteInfo, :FlagModel))
					Latitude = convert(Vector{Float64}, Tables.getcolumn(Data_SiteInfo, :Latitude))
					Longitude = convert(Vector{Float64}, Tables.getcolumn(Data_SiteInfo, :Longitude))
					Region = convert(Vector{String}, Tables.getcolumn(Data_SiteInfo, :Region))

					# Selecting sites
               SiteName_Q = SiteName_Q[🎏_SiteTrue]
               SiteName_P = SiteName_P[🎏_SiteTrue]
               Latitude   = Latitude[🎏_SiteTrue]
               Longitude  = Longitude[🎏_SiteTrue]
               Region     = Region[🎏_SiteTrue]

					Nsites     = length(SiteName_Q)

			# INITIALIZING
            Baseflow_Aver       = zeros(Float64, Nsites)
            NdataPerSite_P      = zeros(Float64, Nsites)
            NdataPerSite_Q      = zeros(Float64, Nsites)
            NdataPerSite_QₓP    = zeros(Float64, Nsites)
            Npercentile         = length(option.param.Percentile)
            P_DeliveryIndex     = zeros(Float64, Nsites)
            P_Max               = zeros(Float64, Nsites)
            P_Min               = zeros(Float64, Nsites)
            P_MobilizationIndex = zeros(Float64, Nsites)
            Percentile_P        = zeros(Float64, Nsites, Npercentile)
            Percentile_Q        = zeros(Float64, Nsites, Npercentile)
            Percentile_QmatchP  = zeros(Float64, Nsites, Npercentile)
            Percentile_QₓP      = zeros(Float64, Nsites, Npercentile)
            Q_Max               = zeros(Float64, Nsites)
            Q_Min               = zeros(Float64, Nsites)

			PsitesList = []

			# FOR EVERY SITE
			for (iSite, iiSite) in enumerate(SiteName_Q)
				# println("==== $iiSite ====")

				# Abstracting discharge: Q
					Path_Input_Discharge = joinpath(pwd(), option.path.InputDischarge, iiSite)
						@assert isfile(Path_Input_Discharge)

				# Reading discharge data
					Data_Discharge = CSV.read(Path_Input_Discharge, DataFrame; header=true)
						Date_Q = convert(Vector, Tables.getcolumn(Data_Discharge, :date))
						Date_Q = Date.(Dates.year.(Date_Q), Dates.month.(Date_Q), Dates.day.(Date_Q))
						Q      = convert(Vector{Float64}, Tables.getcolumn(Data_Discharge, :value))

					# If Q > option.param.QminTreshold
						if option.param.🎏_FilterData
							🎏_GoodQ = PhosphorusTransferIndices.FILTER_DATA(Q; option.param)
						else
							🎏_GoodQ = fill(true, length(Q))
						end

				# Phosphorous sites
					iFind = findfirst('-', iiSite)
					iiSite_P = iiSite[(iFind+1):end]
					PsitesList = push!(PsitesList, iiSite_P)

					PathInput_P = joinpath(pwd(), option.path.InputConcentration, iiSite_P)
					@assert isfile(PathInput_P)
					Data_P = CSV.read(PathInput_P, DataFrame; header = true)
                  Date_P = convert(Vector, Tables.getcolumn(Data_P, :date))
                  Date_P = Date.(Dates.year.(Date_P), Dates.month.(Date_P), Dates.day.(Date_P))
                  P      = convert(Vector{Float64}, Tables.getcolumn(Data_P, :value))

				# Matching dates of concentration of P and Q
					Date_P, P, QmatchP, QₓP = PhosphorusTransferIndices.MATCHING_DATES!(;option.path, iiSite_P, Date_P, option.param, P, Date_Q, Q, 🎏_GoodQ)

				# Computting Baseflow
					Baseflow, BaseFlow_LocalMinima = baseflows.BASEFLOW(;Q, Date_Q, option.baseflow)

					table.TABLE_BASEFLOW(;Date_Q, Q, Baseflow, iiSite_P, option.path)

				# Statistics
					Baseflow_Aver, NdataPerSite_P, NdataPerSite_Q, NdataPerSite_QₓP, P_DeliveryIndex, P_Max, P_Min, P_MobilizationIndex, Percentile_P, Percentile_Q, Percentile_QmatchP, Percentile_QₓP, Q_Max, Q_Min = STATISTICS(;Baseflow, Baseflow_Aver, iSite, NdataPerSite_P, NdataPerSite_Q, NdataPerSite_QₓP, Npercentile, option.param, P, P_DeliveryIndex, P_Max, P_Min, P_MobilizationIndex, Percentile_P, Percentile_Q, Percentile_QmatchP, Percentile_QₓP, Q, Q_Max, Q_Min, QmatchP, QₓP)

				# Plotting for every site
					if option.plot.🎏_Plot_EverySite && NdataPerSite_QₓP[iSite] ≥ option.param.MinDataPointPerSite && P_Min[iSite] > option.param.NoValue
						plot.PLOT(;option.path, Baseflow, BaseFlow_LocalMinima, Date_P, Date_Q, P, Q, QmatchP, QₓP, iiSite_P, option.plot.🎏_PlotLog1p)
					end
			end # FOR EVERY SITE
			# ------------------------------------------

			table.TABLE_iiSITE(;option.param, option.param.Percentile, P_Min, P_Max, Q_Min, Q_Max, SiteName_Q, PsitesList, Percentile_QₓP, Percentile_Q, Percentile_P, Percentile_QmatchP, option.path.OutputPath, NdataPerSite_P, NdataPerSite_Q, P_DeliveryIndex, P_MobilizationIndex, Baseflow_Aver, Latitude, Longitude, Region)

			if option.plot.🎏_Plot_AllSites
				plot.PLOT_ALLSITES(;P_DeliveryIndex, P_MobilizationIndex, option.path)
			end

		println("")
		printstyled("======= End Running phosphorous ========== \n", color = :red)
		end # function PHOSPHOROUS_START
	# ------------------------------------------------------------------


	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#		FUNCTION : MATCHING_DATES!
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		function MATCHING_DATES!(;path, iiSite_P, Date_P, param, P, Date_Q, Q, 🎏_GoodQ)
         Date_P_Filter = []
         P_Filter      = []
         QmatchP       = []
         QₓP           = []

			iDate_P = 1
			for (iDate_Q, iiDate_Q) in enumerate(Date_Q)
				if iiDate_Q == Date_P[iDate_P]
					if 🎏_GoodQ[iDate_Q] && P[iDate_P] > param.PminTreshold
						QmatchP = append!(QmatchP, Q[iDate_Q])

						QₓP₀ = Q[iDate_Q] * P[iDate_P]
							QₓP = append!(QₓP, QₓP₀)
						Date_P_Filter = push!(Date_P_Filter, Date_P[iDate_P])

						P_Filter = append!(P_Filter, P[iDate_P])

						@assert !(Date_P[iDate_P] > iiDate_Q)
					end # if 🎏_GoodQ[iDate_Q]

					iDate_P += 1
				end # if iiDate_Q == Date_P[iDate_P]

			end # for (iDate_Q, iiDate_Q) in enumerate(Date_Q)

			table.TABLE_MATHCH_P_Q(;Date_P_Filter, iiSite_P, P_Filter, path, QmatchP, QₓP)


		return Date_P_Filter, P_Filter, QmatchP, QₓP
		end # function MATCHING_DATES!
	# ------------------------------------------------------------------


	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#		FUNCTION : PERCENTILE
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		function STATISTICS(;Baseflow, Baseflow_Aver, iSite, NdataPerSite_P, NdataPerSite_Q, NdataPerSite_QₓP, Npercentile, P, P_DeliveryIndex, P_Max, P_Min, P_MobilizationIndex, param, Percentile_P, Percentile_Q, Percentile_QmatchP, Percentile_QₓP, Q, Q_Max, Q_Min, QmatchP, QₓP)

			# N VALUES
            NdataPerSite_P[iSite]   = length(P[:])
            NdataPerSite_Q[iSite]   = length(Q[:])
            NdataPerSite_QₓP[iSite] = length(QₓP[:])

			# BASEFLOW
			Baseflow_Aver[iSite] = Statistics.mean(Baseflow[:])
			# println(Baseflow_Aver[iSite])

			Percentile_Q[iSite, 1: Npercentile] = Statistics.quantile(Q[:], param.Percentile)
			if NdataPerSite_QₓP[iSite] ≥ param.MinDataPointPerSite
				# PERCENTILES
					Percentile_QₓP[iSite, 1: Npercentile] 	   = Statistics.quantile(QₓP[:], param.Percentile)
					Percentile_P[iSite, 1: Npercentile] 		= Statistics.quantile(P[:], param.Percentile)
					Percentile_QmatchP[iSite, 1:Npercentile]  = Statistics.quantile(QmatchP[:], param.Percentile)

				# INDEXES
					P_DeliveryIndex[iSite] =  ( quantile(QₓP[:], 0.95) - quantile(QₓP[:], 0.5)) / (quantile(QₓP[:], 0.5) - quantile(QₓP[:], 0.05))

					P_MobilizationIndex[iSite] = quantile(P[:], 0.95) / quantile(P[:], 0.05)

				# MIN MAX values
					P_Min[iSite] = minimum(P[:])
					P_Max[iSite] = maximum(P[:])
					Q_Min[iSite] = minimum(Q[:])
					Q_Max[iSite] = maximum(Q[:])
			else
				# PERCENTILES
					Percentile_QₓP[iSite, 1: Npercentile] 	   .= param.NoValue
					Percentile_Q[iSite, 1: Npercentile] 		.= param.NoValue
					Percentile_P[iSite, 1: Npercentile] 		.= param.NoValue
					Percentile_QmatchP[iSite, 1:Npercentile]  .= param.NoValue

				# MIN MAX values
					P_Min[iSite] = param.NoValue
					P_Max[iSite] = param.NoValue
					Q_Min[iSite] = param.NoValue
					Q_Max[iSite] = param.NoValue
			end

		return Baseflow_Aver, NdataPerSite_P, NdataPerSite_Q, NdataPerSite_QₓP, P_DeliveryIndex, P_Max, P_Min, P_MobilizationIndex, Percentile_P, Percentile_Q, Percentile_QmatchP, Percentile_QₓP, Q_Max, Q_Min
		end  # function: PERCENTILE
	# ------------------------------------------------------------------


	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#		FUNCTION : FILTER_DATA
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		function FILTER_DATA(Var; param)
			N = length(Var)
			🎏_GoodQ = fill(true, N)

			for i=1:N
				if Var[i] ≤ param.QminTreshold
					🎏_GoodQ[i] = false
				end
			end

		return 🎏_GoodQ
		end  # function: FILTER_DATA
	# ------------------------------------------------------------------
end # module PhosporousTransferIndices

# include(raw"D:\JOE\MAIN\MODELS\PHOSPHOROUS\PhosporousTransferIndices\src\PhosphorusTransferIndices.jl")
Path_Toml = raw"D:\JOE\MAIN\MODELS\PHOSPHOROUS\PhosporousTransferIndices\PARAMETER\PhosphorousOption.toml"
PhosphorusTransferIndices.PHOSPHOROUS_START(;Path_Toml)