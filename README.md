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


| SiteName_Q          | col2Name of site Q                                                                     |
| --------------------- | ---------------------------------------------------------------------------------------- |
| SiteName_P          | Name of site P                                                                         |
| Latitude            | metadata                                                                               |
| Longitude           | metadata                                                                               |
| Region              | metadata                                                                               |
| P_Min               | Minimum value of*P*                                                                    |
| P_Max               | Maximum value of*P*                                                                    |
| Q_Min               | Minimum value of Q                                                                     |
| Q_Max               | Maximum value of Q                                                                     |
| Number_P            | Number of P data points                                                                |
| Number_Q            | Number of Q data points                                                                |
| Baseflow_Avr        | Average value of baseflow                                                              |
| P_DeliveryIndex     | ((quantile(QₓP,0.95)-quantile(QₓP,0.5))/((quantile(QₓP[:],0.5)-quantile(QₓP,0.05)) |
| P_MobilizationIndex | quantile(P,0.95)/quantile(P[:],0.05)                                                   |
| QₓP_5...           | quantile(QxP , 0.05,0.1,...)                                                           |
| Qall_5...           | For not filtered Q: quantile(Q , 0.05, 0.1,...)                                        |
| P_5...              | quantile(P , 0.05)                                                                     |
| QmatchP_5...        | Filtered Q to match the dates of P. quantile(Q , 0.05,0.1,...)                         |

## **Plots**

### Plots All Sites

```julia
"OUTPUT/PlotAllSites"
```

For convenience merged all output into one pdf

```julia
"OUTPUT/MergedPlots"
```

Plot for all sites between [Phosphorous delivery index] and [Phosphorous mobilisation index]

### Plots for every site

For every site the following is plotted:

**Plot 1**

* quantile(Q[:], [0.,..,1 ])
* quantile(QₓP[:], [0.,..,1 ])

**Plot 2**

* quantile(P, [0.,..,1 ])

**Plot 3**

* [Q] against [P]

**Plot 4**
For one year only.

* [Date] with Q(Time)
* [Date] with Baseflow
