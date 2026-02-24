# =============================================================
#		module: baseflow
# =============================================================
module baseflows

	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#		FUNCTION : BASEFLOW
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		function BASEFLOW(;Q, Date_Q, baseflow)

			N = length(Q)

			Q_UpOrDown = fill("",N)

			for iQ =1:N
				if Q[max(iQ-1,1)] ≥ Q[iQ] ≥ Q[min(iQ+1,N)]
					Q_UpOrDown[iQ] = "Decrease"

				elseif Q[max(iQ-1,1)] < Q[iQ] < Q[min(iQ+1,N)]
					Q_UpOrDown[iQ] = "Increase"

				elseif Q[max(iQ-1,1)] ≤ Q[iQ] ≥ Q[min(iQ+1,N)]
					Q_UpOrDown[iQ] = "Peek"

				elseif Q[max(iQ-1,1)] ≥ Q[iQ] ≤ Q[min(iQ+1,N)]
					Q_UpOrDown[iQ] = "LocalMinima"
				else
					error("Did not find flow direction")
				end
			end

			LocalMinima = []
			iMinima = 1
			iCount = 1

			# Just at the beginning
			iMinima = findmin(Q[1:baseflow.ΔTtimeLag_Min])[2]
			append!(LocalMinima , iMinima)

			for iQ =2:N
				if Q[iQ-1] ≥ Q[iQ]
					iMinima = iQ
				end

				if  (iCount ≥ baseflow.ΔTtimeLag_Min) && (Q_UpOrDown[iQ] == "LocalMinima") && (Q[max(iQ-2,1)] > Q[max(iQ-1,1)]) && baseflow.🎏_LocalMinima
					append!(LocalMinima , iMinima)
					iCount = 0

				elseif (iCount ≥ baseflow.ΔTtimeLag_Max) && (Q_UpOrDown[iQ] == "Decrease") && baseflow.🎏_Reduce
					append!(LocalMinima , iMinima)
					iCount = 0
				end

				iCount += 1
			end

			iLocalMinima = 1
			Baseflow = zeros(N)
			NlocalMinima = length(LocalMinima)

			for iQ=1:N

				if LocalMinima[1] ≥ iQ
					Baseflow[iQ] = Q[LocalMinima[iLocalMinima]]

				else

					if !(LocalMinima[min(iLocalMinima+1, NlocalMinima)] ≥ iQ ≥ LocalMinima[iLocalMinima])
						iLocalMinima = min(1 + iLocalMinima, NlocalMinima)
					end

					Intercept, Slope = baseflows.POINTS_2_SlopeIntercept(LocalMinima[iLocalMinima], Q[LocalMinima[iLocalMinima]], LocalMinima[min(iLocalMinima+1, NlocalMinima)], Q[LocalMinima[min(iLocalMinima+1, NlocalMinima)]])

					Baseflow[iQ] = Slope * iQ + Intercept
				end

			end # iQ=1:N

		return Baseflow, LocalMinima
		end  # function: BASEFLOW
	# ------------------------------------------------------------------


	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#		FUNCTION : LINEAR_INTERPOLATION
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		function LINEAR_INTERPOLATION(; ∑T, ∑T_Reduced, ∑obs)
			N = length(∑T)
			Nreduced = length(∑T_Reduced)
			∑obs_Reduced = fill(0.0::Float64, Nreduced)

			for iT_Reduced ∈ 1:Nreduced
				iT_X = 2
				🎏Break = false
				while !(🎏Break)
					if (∑T[iT_X-1] ≤ ∑T_Reduced[iT_Reduced] ≤ ∑T[iT_X]) || (iT_X == N)
						🎏Break = true
						break
					else
						iT_X += 1
						🎏Break = false
					end # if
				end # while

				# Building a regression line which passes from POINT1(∑T[iT_X], ∑Pet_Sim[iT_Pr]) and POINT2: (∑T[iT_Pr+1], ∑Pet_Sim[iT_Pr+1])
				Intercept, Slope = POINTS_2_SlopeIntercept(∑T[iT_X-1], ∑obs[iT_X-1], ∑T[iT_X], ∑obs[iT_X])
				∑obs_Reduced[iT_Reduced] = Slope * ∑T_Reduced[iT_Reduced] + Intercept
			end # for iT = 1:Nmeteo_Reduced

			Obs_Reduced = fill(0.0::Float64, Nreduced)
			Obs_Reduced[1] = ∑obs_Reduced[1]

			for iT_Reduced ∈ 2:Nreduced
				Obs_Reduced[iT_Reduced] = ∑obs_Reduced[iT_Reduced] - ∑obs_Reduced[iT_Reduced-1]
			end

		return ∑obs_Reduced, Obs_Reduced
		end  # function: LINEAR_INTERPOLATION
	# ------------------------------------------------------------------


	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#		FUNCTION : POINTS_2_SlopeIntercept
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	"""POINTS_2_SlopeIntercept
	From Point1 [X1, Y1] and point2 [X2, Y2] compute Y = Slope.X₀ + Intercept
	"""
	function POINTS_2_SlopeIntercept(X1, Y1, X2, Y2)
		Slope = (Y2 - Y1) / (X2 - X1 + eps())
		Intercept = (Y1 * X2 - X1 * Y2) / (X2 - X1)
	return Intercept, Slope
	end # POINTS_2_SlopeIntercept
	#...................................................................

end  # module: baseflow
# ............................................................