# =============================================================
#		module: option
# =============================================================
module readtoml

using Configurations, TOML

	@option struct PATH
		InputConcentration::String
		InputDischarge::String
		InputSiteInfo::String
		OutputPath::String
		OutputPlot::String

	end # struct DATA

	@option mutable struct PARAM
		Percentile::Vector{Float64}
		QminTreshold::Float64
		🎏_FilterData::Bool
		NoValue::Float64
		MinDataPointPerSite::Float64
		PminTreshold::Float64
	end # STRUCT PARAM


	@option mutable struct BASEFLOW
		ΔTtimeLag_Min::Int64
		ΔTtimeLag_Max::Int64
		🎏_LocalMinima::Bool
		🎏_Reduce::Bool
	end

	@option struct PLOT
		🎏_PlotLog1p::Bool
		🎏_Plot::Bool
	end

	@option struct OPTION
		path::PATH
		param::PARAM
		plot::PLOT
		baseflow::BASEFLOW
	end

	# ----------------------------
	function READTOML(PathToml)
		@assert isfile(PathToml)
		return Configurations.from_toml(OPTION, PathToml)
	end  # function: OPTION

end  # module: option
# ..........................................................
