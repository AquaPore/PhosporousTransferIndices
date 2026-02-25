module table
	using Tables, CSV, Dates

	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#		FUNCTION : TABLE_iiSITE
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		function TABLE_iiSITE(;param, Percentile, P_Min, P_Max, Q_Min, Q_Max, SiteName_Q, PsitesList, Percentile_QₓP, Percentile_Q, Percentile_P, Percentile_QmatchP, OutputPath,NdataPerSite_P, NdataPerSite_Q, P_DeliveryIndex, P_MobilizationIndex, Baseflow_Aver, Latitude, Longitude, Region)

			N = length(P_Min)
			🎏_Good = fill(false, N)
			# Removing non good sites
			iCount = 0
			for iSite=1:N
				if P_Min[iSite] > param.NoValue
					🎏_Good[iSite] = true
					iCount += 1
				end
			end  # for iT=1:length(P_Min)

			Header = ["SiteName_Q", "SiteName_P", "Latitude", "Longitude", "Region", "P_Min", "P_Max", "Q_Min", "Q_Max", "N_P", "N_Q", "Baseflow", "P_DeliveryIndex", "P_MobilizationIndex"]

			HeaderVariables = ["QₓP_", "Qall_", "P_", "QmatchP_"]

			for iHeader_Variables ∈ HeaderVariables
				for iPercentile ∈ Percentile
					Header_1 = iHeader_Variables * string(Int64(100 * iPercentile))
					Header = push!(Header, Header_1)
				end
			end

			Path_Output_QₓP = joinpath(OutputPath, "PerSite", "PerSiteStatistics.csv")

			CSV.write(Path_Output_QₓP, Tables.table([SiteName_Q[🎏_Good] PsitesList[🎏_Good] Latitude[🎏_Good] Longitude[🎏_Good] Region[🎏_Good] P_Min[🎏_Good] P_Max[🎏_Good] Q_Min[🎏_Good] Q_Max[🎏_Good] NdataPerSite_P[🎏_Good] NdataPerSite_Q[🎏_Good] Baseflow_Aver[🎏_Good] P_DeliveryIndex[🎏_Good] P_MobilizationIndex[🎏_Good] Percentile_QₓP[🎏_Good, :] Percentile_Q[🎏_Good,:] Percentile_P[🎏_Good,:] Percentile_QmatchP[🎏_Good,:]]), writeheader = true, header=Header, bom = true)

			printstyled("	~~~~  Number of sites = $iCount ~~~~~ \n", color = :green)

		return nothing
		end
	# ------------------------------------------------------------------


	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#		FUNCTION : TABLE_MATHCH_P_Q
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		function TABLE_MATHCH_P_Q(;Date_P_Filter, iiSite_P, P_Filter, path, QmatchP, QₓP)
			Header = ["Date", "Year", "Month", "Day", "Q[m³ day⁻¹]", "P[g m⁻³]", "QₓP[g day⁻¹]"]
			Df = Dates.DateFormat("y-m-d")
			Path_Output_QₓP = joinpath(path.OutputPath, "P_Q_Relationship", "QₓP_" * iiSite_P)

			CSV.write(Path_Output_QₓP, Tables.table([Date_P_Filter year.(Date_P_Filter) month.(Date_P_Filter) day.(Date_P_Filter) QmatchP P_Filter QₓP]), writeheader = true, header = Header, bom = true)
		return nothing
		end  # function: TABLE_MATHCH_P_Q
	# ------------------------------------------------------------------


	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#		FUNCTION : TABLE_BASEFLWOW
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		function TABLE_BASEFLOW(;Date_Q, Q, Baseflow, iiSite_P, path)

			Header = ["Date", "Q", "Baseflow"]

			Path_Output_Baseflow = joinpath(path.OutputPath, "Baseflow", "Baseflow_" * iiSite_P)

			CSV.write(Path_Output_Baseflow, Tables.table([Date_Q Q Baseflow]), writeheader = true, header=Header, bom = true)

		return nothing
		end
	# ------------------------------------------------------------------

end # module table