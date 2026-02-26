# =============================================================
#		module: baseflow
# =============================================================
module baseflows

	using Statistics
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#		FUNCTION : BASEFLOW
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		function BASEFLOW(;Q, Date_Q, baseflow)

			@assert baseflow.🎏_LocalMinima || baseflow.🎏_Reduce

			N = length(Q)
			Q_Min = minimum(Q[1:N])
			Q_Max = maximum(Q[1:N])
			Q_Std = Statistics.std(Q[1:N])

			ΔQMinMax = Q_Max - Q_Min

			if baseflow.🎏_Qvariability
				Qvariability = Q_Std / ΔQMinMax
			else
				Qvariability = 1.0
			end

			# INCREASE OR DECREASE Q
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
			for iQ =baseflow.ΔTtimeLag_Min+1:N

				# Searching for local minima
				if Q[iQ-1] ≥ Q[iQ]
					iMinima = iQ
				end

				# Accounting for the variability of the data
				if baseflow.🎏_Qvariability
					AddDays = floor(10.0 * Qvariability)
				else
					AddDays = 0
				end

				if (iCount ≥ baseflow.ΔTtimeLag_Min + AddDays) && (Q_UpOrDown[iQ] == "LocalMinima") && ( Q[max(iQ-2,1)] > Q[max(iQ-1,1)]) && (Q[min(iQ+2, N)] < Q[min(iQ+1,N)]) && baseflow.🎏_LocalMinima && baseflow.🎏_LocalMinimaClean

					#  Assuring that there is an increase or decrease
					if abs(Q[LocalMinima[end]] - Q[iQ]) / ΔQMinMax > Qvariability * baseflow.Perc_IncreaseDecrease
						append!(LocalMinima , iMinima)
						iCount = 0
					end

				elseif (iCount ≥ baseflow.ΔTtimeLag_Min + AddDays) && (Q_UpOrDown[iQ] == "LocalMinima") && ( Q[max(iQ-2,1)] > Q[max(iQ-1,1)]) && baseflow.🎏_LocalMinima && !(baseflow.🎏_LocalMinimaClean)

					#  Assuring that there is an increase or decrease
					if abs(Q[LocalMinima[end]] - Q[iQ]) / ΔQMinMax > Qvariability * baseflow.Perc_IncreaseDecrease
						append!(LocalMinima , iMinima)
						iCount = 0
					end

				elseif (iCount ≥ baseflow.ΔTtimeLag_Min) && (Q_UpOrDown[iQ] == "Decrease") && baseflow.🎏_Reduce
					if abs(Q[LocalMinima[end]] - Q[iQ]) / ΔQMinMax > baseflow.Perc_IncreaseDecrease
						append!(LocalMinima , iMinima)
						iCount = 0
					end
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

					if iLocalMinima + 1 ≤ NlocalMinima

						Intercept, Slope = baseflows.POINTS_2_SlopeIntercept(LocalMinima[iLocalMinima], Q[LocalMinima[iLocalMinima]], LocalMinima[min(iLocalMinima+1, NlocalMinima)], Q[LocalMinima[min(iLocalMinima+1, NlocalMinima)]])

						Baseflow[iQ] = Slope * iQ + Intercept
						Baseflow[iQ] = min(Baseflow[iQ], Q[iQ])

					# Dealing with the extremite
					else
						Baseflow[iQ] = min(Baseflow[iQ-1], Q[iQ])
					end
				end
			end # for iQ=1:N

		return Baseflow, LocalMinima
		end  # function: BASEFLOW
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