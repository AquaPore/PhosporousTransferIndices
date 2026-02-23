module table
	using Tables, CSV

	function TABLE_iiSITE(;param, Percentile, P_Min, P_Max, Q_Min, Q_Max, SiteName_Q, PsitesList, Percentile_QₓP, Percentile_Q, Percentile_P, Percentile_QmatchP, OutputPath,NdataPerSite_P, NdataPerSite_Q, P_DeliveryIndex, P_MobilizationIndex)

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

		Header = ["SiteName_Q", "SiteName_P", "P_Min", "P_Max", "Q_Min", "Q_Max", "N_P", "N_Q", "P_DeliveryIndex", "P_MobilizationIndex"]

		HeaderVariables = ["QₓP_", "Qall_", "P_", "QmatchP_"]

		for iHeader_Variables ∈ HeaderVariables
			for iPercentile ∈ Percentile
				Header_1 = iHeader_Variables * string(Int64(100 * iPercentile))
				Header = push!(Header, Header_1)
			end
		end

		Path_Output_QₓP = joinpath(OutputPath, "PerSite", "PerSiteStatistics.csv")

		CSV.write(Path_Output_QₓP, Tables.table([SiteName_Q[🎏_Good] PsitesList[🎏_Good] P_Min[🎏_Good] P_Max[🎏_Good] Q_Min[🎏_Good] Q_Max[🎏_Good] NdataPerSite_P[🎏_Good] NdataPerSite_Q[🎏_Good] P_DeliveryIndex[🎏_Good] P_MobilizationIndex[🎏_Good] Percentile_QₓP[🎏_Good, :] Percentile_Q[🎏_Good,:] Percentile_P[🎏_Good,:] Percentile_QmatchP[🎏_Good,:]]), writeheader = true, header=Header, bom = true)

		printstyled("	~~~~  Number of sites = $iCount ~~~~~ \n", color = :green)

	return nothing
	end

end # module table