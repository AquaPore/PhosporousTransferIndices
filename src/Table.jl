module table
	using Tables, CSV



	function TABLE_iiSITE(;Percentile, P_Min, P_Max, Q_Min, Q_Max, QsitesList, PsitesList, Percentile_QₓP, Percentile_Q, Percentile_P, Percentile_QmatchP, OutputPath)

		Header = ["SiteName_Q", "SiteName_P", "P_Min", "P_Max", "Q_Min", "Q_Max"]

		HeaderVariables = ["QₓP_", "Qall_", "P_", "QmatchP_"]

		for iHeader_Variables ∈ HeaderVariables
			for iPercentile ∈ Percentile
				Header_1 = iHeader_Variables * string(Int64(100 * iPercentile))
				Header = push!(Header, Header_1)
			end
		end
		println(Header)

		Path_Output_QₓP = joinpath(OutputPath, "PerSite", "PerSiteStatistics.csv")

		CSV.write(Path_Output_QₓP, Tables.table([QsitesList PsitesList P_Min P_Max Q_Min Q_Max Percentile_QₓP Percentile_Q Percentile_P Percentile_QmatchP]), writeheader = true, header=Header, bom = true)

	return nothing
	end

end # module table