# =============================================================
#		module: plot
# =============================================================
module plot
using CairoMakie, Dates, Statistics


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#		FUNCTION : PLOT
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function PLOT(; path, Date_P, Date_Q, P, Q, QₓP, iiSite_P)

   Width = 3000
   Height = 800
   Dpi = 500

   Pctl = collect(0.0:0.001:1.0)

   P_Quantile = Statistics.quantile(P[:], Pctl)
   Q_Quantile = Statistics.quantile(Q[:], Pctl)
   QₓP_Quantile = Statistics.quantile(QₓP[:], Pctl)

   CairoMakie.activate!(type="png", px_per_unit=0.5)
   Fig = Figure(; size=(Width, 3 * Height), font="Sans", titlesize = 30, xlabelsize = 20, ylabelsize = 20, labelsize = 30, fontsize = 50)

   Ax_1 = Axis(Fig[1, 1]; xlabel=L"$Q m^{3} day^{-1}$ ",
      ylabel=L"$ Cunulative frequency$ ", xgridstyle=:dashdot, ygridstyle=:dashdot, xtickalign=0, ytickalign=0)
		Ax_1.yticks = (0:0.2:1, string.(0:0.2:1))
		pts1 = lines!(Ax_1, Q_Quantile, Pctl, ; linewidth = 2, color=:red)

   Ax_2 = Axis(Fig[2, 1]; xlabel=L"$Q m^{3} day^{-1}$ ",
      ylabel=L"$ Cumulative frequency$ ", xgridstyle=:dashdot, ygridstyle=:dashdot, xtickalign=0, ytickalign=0)
			Ax_2.yticks = (0:0.2:1, string.(0:0.2:1))
			pts1 = lines!(Ax_2, P_Quantile, Pctl, ; linewidth = 2, color=:red)

   Ax_3 = Axis(Fig[3, 1]; xlabel=L"$P m^{3} day^{-1}$ ",
      ylabel=L"$ Cumulative frequency$ ", xgridstyle=:dashdot, ygridstyle=:dashdot, xtickalign=0, ytickalign=0)
		Ax_3.yticks = (0:0.2:1, string.(0:0.2:1))
		pts1 = lines!(Ax_3, QₓP_Quantile, Pctl, ; linewidth = 2, color=:red)

   colgap!(Fig.layout, 15)
   rowgap!(Fig.layout, 15)
   resize_to_layout!(Fig)
   trim!(Fig.layout)
   display(Fig)

   iFind = findfirst('.', iiSite_P)
   iiSite_P₁ = iiSite_P[1:(iFind-1)]
   Path_OutputPlot = joinpath(path.OutputPlot, "Plot_" * iiSite_P₁ * ".png")
   CairoMakie.save(Path_OutputPlot, Fig, px_per_unit=Dpi / 96)
   # println("		~~ ", Path_OutputPlot, "~~")

   return nothing
end  # function: PLOT
# ------------------------------------------------------------------

end  # module: plot
# ............................................................
