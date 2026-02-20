# =============================================================
#		module: option
# =============================================================
module readtoml

using Configurations, TOML

	@option struct PATH
		InputConcentration::String
		InputDischarge::String
		OutputPath::String
		OutputPlot::String
	end # struct DATA

	@option mutable struct PARAM
		Percentile::Vector{Float64}
	end # STRUCT PARAM

	@option struct OPTION
		path::PATH
		param::PARAM
	end

	# ----------------------------
	function READTOML(PathToml)
		@assert isfile(PathToml)
		return Configurations.from_toml(OPTION, PathToml)
	end  # function: OPTION

end  # module: option
# ..........................................................
