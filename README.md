# **PhosporousTransferIndices.jl**

[![Build Status](https://github.com/AquaPore/PhosporousTransferIndices.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/AquaPore/PhosporousTransferIndices.jl/actions/workflows/CI.yml?query=branch%3Amaster)
"# PhosporousTransferIndices.jl"

## **INPUT**

### *Inut: List of sites and metadata*

```julia
"DATA/INPUT/SiteInfo.csv"
```

The input data for all site:


| SiteName_Q | Name of file of  Discharge Q                                                                             |
| ------------ | ---------------------------------------------------------------------------------------------------------- |
| SiteName_P | Name of file of  phosphorous                                                                             |
| Latitude   | Latitude of site (metadata)                                                                              |
| Longitude  | Longitude of site (metadata)                                                                             |
| Region     | Reguion of the world (metadata)                                                                          |
| FlagModel  | **FlagModel=1** : the site is used for simulation or **FlagModel=0** the site not included in simulation |

### *INPUT DATA*

#### **Phosphorous concentration data**

For every site:

```julia
"/DATA/INPUT/concentration"
```

#### **Discharge data**

For every site:

```julia
"/DATA/INPUT/discharge.csv"
```

### **OPTION*

In a toml file

```JULIA
"/PARAMETER"
```

```toml
[param]
	Percentile = [0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95] # Percentile of output file
	"🎏_FilterData" = true # <false> || <true>. If <true> than Q and P will be filtered as below.
		QminTreshold = 0.04 #  [m ³ s ⁻³] minimum value of Q which are removed for analysis
		PminTreshold = 0.0001 # [g m⁻³] minimum value of phosphorous data which are removed from analysis

	NoValue = -9999 # need to be negative. The value is not imporant as the sites witth NoVlue are removed
	MinDataPointPerSite = 365 # Minimum number of observation of sites required to make observation. If the creteria is ot meet than the site is removed

[baseflow]
   "ΔTtimeLag_Min"  = 4 # [day] windows period were the search for minimum flow is computed
	Perc_IncreaseDecrease = 0.01 # [0-1] assure that between local minima there is a steady increase of decrease and not flat
   "🎏_LocalMinima" = true # <true> Use method of finding local minima
   "🎏_Reduce"      = false # <true> Search during period were flow is decreasing
	"🎏_Qvariability" = true # <true> accounting for the variability of the flow: Q_Std / (Q_Max-Q_Min)
	"🎏_LocalMinimaClean" = true # <true> then the local minima needs to be well formed
```

## **OUTPUT**

### **Tables**

#### *Baseflow*

```JULIA
"/Baseflow"
```


| Date                  | Date              |
| ----------------------- | ------------------- |
| Q[m³ day⁻¹]        | Discharge         |
| Baseflow[m³ day⁻¹] | Computed baseflow |

#### *Relashinship between Q and P*

```JULIA
"/P_Q_Relationship"
```

This is finding dates which simultaneously have data on Q (discharge) & P (phosphorous)


| Date           | Date        |
| ---------------- | ------------- |
| Year           | Year        |
| Month          | Month       |
| Day            | Day         |
| Q[m³ day⁻¹] | Dioscharge  |
| P[g m⁻³      | Phosphorous |

#### *Statistics per site*

The following outputs are statistics based on each site



SiteName_Q,SiteName_P,Latitude,Longitude,Region,P_Min,P_Max,Q_Min,Q_Max,N_P,N_Q,Baseflow,P_DeliveryIndex,P_MobilizationIndex,QₓP_5,QₓP_10,QₓP_20,QₓP_30,QₓP_40,QₓP_50,QₓP_60,QₓP_70,QₓP_80,QₓP_90,QₓP_95,Qall_5,Qall_10,Qall_20,Qall_30,Qall_40,Qall_50,Qall_60,Qall_70,Qall_80,Qall_90,Qall_95,P_5,P_10,P_20,P_30,P_40,P_50,P_60,P_70,P_80,P_90,P_95,QmatchP_5,QmatchP_10,QmatchP_20,QmatchP_30,QmatchP_40,QmatchP_50,QmatchP_60,QmatchP_70,QmatchP_80,QmatchP_90,QmatchP_95



| SiteName_Q          | col2 |
| --------------------- | ------ |
| SiteName_P          |      |
| Latitude            |      |
| Longitude           |      |
| Region              |      |
| P_Min               |      |
| P_Max               |      |
| Q_Min               |      |
| Q_Max               |      |
| Number_P,           |      |
| Number_Q,           |      |
| Baseflow,           |      |
| P_DeliveryIndex,    |      |
| P_MobilizationIndex |      |
| QₓP_5              |      |
| Qall_10             |      |
| P_5                 |      |
| QmatchP_5           |      |
|                     |      |
|                     |      |
|                     |      |
|                     |      |
|                     |      |

### **Plots**

The plots are described here
