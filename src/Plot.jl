# =============================================================
#		module: plot
# =============================================================
module plot
using CairoMakie, Dates, Statistics, PDFmerger

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#		FUNCTION : PLOT
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function PLOT(; path, Baseflow, BaseFlow_LocalMinima, Date_P, Date_Q, P, QmatchP, Q, QₓP, iiSite_P, 🎏_PlotLog1p, Pctl_Min=0.0, Pctl_Max=1.0, Width=3000, Height=400, Dpi=200)

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

   Pctl = collect(Pctl_Min:0.001:Pctl_Max)

   P_Quantile = Statistics.quantile(P[:], Pctl)
   Q_Quantile = Statistics.quantile(QmatchP[:], Pctl)
   QₓP_Quantile = Statistics.quantile(QₓP[:], Pctl)

   CairoMakie.activate!(type="svg", px_per_unit=0.75) # type="png", px_per_unit=0.5
   Fig = Figure(; size=(Width, 4 * Height), font="Sans", titlesize=30, labelsize=40, fontsize=30)

   Ax_1 = Axis(Fig[1, 1]; xlabel=L"$Q \ [m^{3} \ day^{-1}]$",
      xtickalign=0, ytickalign=0, xticklabelcolor=:red, xgridvisible=true, ygridvisible=true, xgridstyle=:dash, ygridstyle=:dash, yautolimitmargin=(0, 0), xscale=Scale[ii🎏_PlotLog1p], width=Width, height=Height, xlabelsize=50, ylabelsize=50)

   hideydecorations!(Ax_1)

   Ax_1.yticks = (0:0.1:1.1, string.(0:0.1:1.1))
   ylims!(Ax_1, 0, 1.1)
   lines!(Ax_1, Q_Quantile, Pctl; linewidth=10, color=:red)

   Ax_2 = Axis(Fig[1, 1]; xlabel=L"$QxP \ [g \ m^{-3} \ day^{-1}]$ ", ylabel=L"$ Cumulative \ Frequency$",
      xgridstyle=:dashdot, ygridstyle=:dashdot, xaxisposition=:top, xtickalign=0, ytickalign=0, xticklabelcolor=:blue, xgridvisible=true, ygridvisible=true, ygridcolor=:orange, yautolimitmargin=(0, 0), xscale=Scale[ii🎏_PlotLog1p], width=Width, height=Height, xlabelsize=50, ylabelsize=50, title=iiSite_P₁, titlealign=:right)

   ylims!(Ax_2, 0, 1.1)
   Ax_2.yticks = (0:0.1:1.1, string.(0:0.1:1.1))
   lines!(Ax_2, QₓP_Quantile, Pctl, ; linewidth=10, color=:blue)

   Ax_3 = Axis(Fig[2, 1]; title=iiSite_P₁, titlecolor=:navyblue, titlealign=:right, xlabel=L"$P \ [g \ m^{3}]$ ",
      ylabel=L"$Cumulative \ Frequency$", xgridstyle=:dashdot, ygridstyle=:dashdot, xtickalign=0, ytickalign=0, xticklabelcolor=:green, xgridvisible=true,
      ygridwidth=1, ygridvisible=true, ygridcolor=:orange, yautolimitmargin=(0, 0), xautolimitmargin=(0, 0), width=Width, height=Height, xlabelsize=50, ylabelsize=50)

      ylims!(Ax_3, 0, 1.1)
      Ax_3.yticks = (0:0.1:1.1, string.(0:0.1:1.1))

      lines!(Ax_3, P_Quantile, Pctl; linewidth=10, color=:green)

   Ax_4 = Axis(Fig[3, 1]; xlabel=L"$Q \ [m^{3} \ day^{-1}]$",
      ylabel=L"$P \ [g \ m^{-3}]$", xgridstyle=:dashdot, ygridstyle=:dashdot, xtickalign=0, ytickalign=0, xticklabelcolor=:blue, xgridvisible=true,
      ygridwidth=1, ygridvisible=true, ygridcolor=:orange, yautolimitmargin=(0, 0), xautolimitmargin=(0, 0), xscale=Scale[ii🎏_PlotLog1p], width=Width, height=Height, xlabelsize=50, ylabelsize=50, title=iiSite_P₁, titlealign=:right)

      scatter!(Ax_4, QmatchP, P; markersize=20, marker=:diamond, color=:blue)

   Ax_5 = Axis(Fig[4, 1]; xlabel=L"$Date$",
      ylabel=L"Q [m^{3} \ day^{-1}]", xgridstyle=:dashdot, ygridstyle=:dashdot, xtickalign=0, ytickalign=0, xticklabelcolor=:blue, xgridvisible=true, ygridwidth=1, ygridvisible=true, ygridcolor=:purple, yautolimitmargin=(0, 0), xautolimitmargin=(0, 0), xticklabelrotation=π / 2.0, width=Width, height=Height, xlabelsize=50, ylabelsize=50)

      lines!(Ax_5, Date_Q[1:365], Baseflow[1:365]; color=:brown, linewidth=10,)
      lines!(Ax_5, Date_Q[1:365], Q[1:365], color=:blue, linewidth=6)

      BaseFlow_LocalMinima = min.(BaseFlow_LocalMinima, 365)
      scatter!(Ax_5, Date_Q[BaseFlow_LocalMinima], Q[BaseFlow_LocalMinima]; markersize=30, marker=:circle, color=:red)

   # band!(Ax_5, Dates.value.(Date_Q[1:365]), zeros(365), Q[1:365];  color=:blue, label= "Qobs" )

   # band!(Ax_5, BaseFlow_LocalMinima, zeros(length(BaseFlow_LocalMinima)), Q[BaseFlow_LocalMinima];  color=:brown, label= "Qobs" )

   colgap!(Fig.layout, 40)
   # rowgap!(Fig.layout, 50)
   resize_to_layout!(Fig)
   trim!(Fig.layout)
   display(Fig)

   Path_OutputPlot = joinpath(path.OutputPlot, "Plot_" * iiSite_P₁ * ".pdf")
   CairoMakie.save(Path_OutputPlot, Fig, px_per_unit=Dpi / 96)
   # println("		~~ ", Path_OutputPlot, "~~")

   return nothing
end  # function: PLOT
# ------------------------------------------------------------------

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#		FUNCTION : name
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function PLOT_ALLSITES(; P_DeliveryIndex, P_MobilizationIndex, path, Width=800, Height=600, Dpi=200)

   CairoMakie.activate!(type="svg", px_per_unit=0.75)
   Fig = Figure(; size=(Width, Height), font="Sans", titlesize=30, xlabelsize=20, ylabelsize=20, labelsize=20, fontsize=30)

   Ax_1 = Axis(Fig[1, 1]; xlabel=L"$P_{deliveryIndex}$", ylabel=L"$P_{MobilizationIndex}$",
      xtickalign=0, ytickalign=0, xticklabelcolor=:violet, yticklabelcolor=:violet, xgridvisible=true, ygridvisible=true, xgridstyle=:dash, ygridstyle=:dash, xautolimitmargin=(0, 0), yautolimitmargin=(0, 0))

   scatter!(Ax_1, P_DeliveryIndex, P_MobilizationIndex; markersize=15, marker=:diamond, color=:blue)

   colgap!(Fig.layout, 40)
   # rowgap!(Fig.layout, 50)
   resize_to_layout!(Fig)
   trim!(Fig.layout)
   display(Fig)

   Path_OutputPlot = joinpath(path.OutputPath, "PlotAllSites", "PlotAllSites.svg")
   CairoMakie.save(Path_OutputPlot, Fig, px_per_unit=Dpi / 96)
   # println("		~~ ", Path_OutputPlot, "~~")

   return nothing
end  # function: PLOT_ALLSITES
# ------------------------------------------------------------------

end  # module: plot
# ............................................................
