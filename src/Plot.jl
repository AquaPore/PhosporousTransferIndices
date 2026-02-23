# =============================================================
#		module: plot
# =============================================================
module plot
using CairoMakie, Dates, Statistics

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#		FUNCTION : PLOT
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function PLOT(; path, Date_P, Date_Q, P, QmatchP, QₓP, iiSite_P, 🎏_PlotLog1p, Pctl_Min=0.04, Pctl_Max=0.94)

   iFind = findfirst('.', iiSite_P)
   iiSite_P₁ = iiSite_P[1:(iFind-1)]

	Scale = [identity, log]

	if 🎏_PlotLog1p
		QmatchP = QmatchP .+ 1
		QₓP = QₓP .+ 1

		ii🎏_PlotLog1p = 2
	else
		ii🎏_PlotLog1p = 1
	end

   Width=800 ; Height=400; Dpi = 200

   Pctl = collect(Pctl_Min:0.001:Pctl_Max)

   P_Quantile = Statistics.quantile(P[:], Pctl)
   Q_Quantile = Statistics.quantile(QmatchP[:], Pctl)
   QₓP_Quantile = Statistics.quantile(QₓP[:], Pctl)

   CairoMakie.activate!(type="svg", px_per_unit=0.75) # type="png", px_per_unit=0.5
   Fig = Figure(; size=(Width, 2 * Height), font="Sans", titlesize=30, xlabelsize=20, ylabelsize=20, labelsize=20, fontsize=20)

   Ax_1 = Axis(Fig[1, 1]; xlabel=L"$Q \ [m^{3} \ day^{-1}]$ ",
      xtickalign=0, ytickalign=0, xticklabelcolor=:red, xgridvisible=true, ygridvisible=true, xgridstyle=:dash, ygridstyle=:dash,yautolimitmargin = (0, 0), xscale=Scale[ii🎏_PlotLog1p])

		hideydecorations!(Ax_1)

		Ax_1.yticks = (0:0.1:1.1, string.(0:0.1:1.1))
		ylims!(Ax_1, 0, 1.1)
		lines!(Ax_1, Q_Quantile, Pctl; linewidth=3, color=:red)

   Ax_2 = Axis(Fig[1, 1]; xlabel=L"$QxP \ [g \ m^{-3} \ day^{-1}]$ ", ylabel=L"$ Cumulative \ Frequency$",
      xgridstyle=:dashdot, ygridstyle=:dashdot, xaxisposition=:top, xtickalign=0, ytickalign=0, xticklabelcolor=:blue, xgridvisible=true, ygridvisible=true, ygridcolor=:orange, yautolimitmargin = (0, 0), xscale=Scale[ii🎏_PlotLog1p])

		ylims!(Ax_2, 0, 1.1)
		Ax_2.yticks = (0:0.1:1.1, string.(0:0.1:1.1))
		lines!(Ax_2, QₓP_Quantile, Pctl, ; linewidth=3, color=:blue)

   Ax_3 = Axis(Fig[2, 1]; title=iiSite_P₁, titlecolor=:navyblue, titlealign =:right, xlabel=L"$P \ [g \ m^{3}]$ ",
      ylabel=L"$Cumulative \ Frequency$", xgridstyle=:dashdot, ygridstyle=:dashdot, xtickalign=0, ytickalign=0, xticklabelcolor=:green, xgridvisible=true,
       ygridwidth=1, ygridvisible=true, ygridcolor=:orange, yautolimitmargin = (0, 0), xautolimitmargin = (0, 0))

		ylims!(Ax_3, 0, 1.1)
		Ax_3.yticks = (0:0.1:1.1, string.(0:0.1:1.1))

		lines!(Ax_3, P_Quantile, Pctl, ; linewidth=3, color=:green)

   colgap!(Fig.layout, 40)
   # rowgap!(Fig.layout, 50)
   resize_to_layout!(Fig)
   trim!(Fig.layout)
   display(Fig)


   Path_OutputPlot = joinpath(path.OutputPlot, "Plot_" * iiSite_P₁ * ".svg")
   CairoMakie.save(Path_OutputPlot, Fig, px_per_unit=Dpi / 96)
   # println("		~~ ", Path_OutputPlot, "~~")

   return nothing
end  # function: PLOT
# ------------------------------------------------------------------

end  # module: plot
# ............................................................
