#########################################
#
# Use to determine vertical and lateral susceptibility
#
# From SCCWRP Technical Report #606
# Bledsoe, B.P., R.J. Hawley, E.D. Stein, D.B. Booth. 2010.
# Hydromodification screening tools: field manual for assessing channel susceptibility
#
# Vertical susceptibility has 3 components:
#
#
#    ### ATTENTION!!! MOST FIELD CREWS DETERMINED A "PRIMARY STATE OF STREAMBED" SCORE AS A SURROGATE FOR VERTICAL SUSCEPTIBILITY,
#    ### INSTEAD OF DETERMINING ARMORING POTENTIAL AND GRADE CONTROL. THEREFORE THE PROGRAM HAS BEEN REVISED TO REFLECT THIS.
#
#
#
#     i) Armoring potential (assessed in the field)
#         Armoring potential looks at the amount of sand + fines  (<5%, 5-25%, >25%) and if the course gravels and cobbles are tightly packed.
#         Field crews categorize the armoring potential as A, B, or C (best to worst)
#    ii) Grade control (assessed in the field)
#         Looks at evidence of failure, mass wasting, and presence and spacing of grade control (artificial or geologic)
#         Field crews categorize the grade control as A, B, or C (best to worst)
#   iii) Screening index [Field: median particle size (d50); Office: watershed area, annual precipitation (both used to calculated Q10), stream slope]
#         Looks at the risk for incising/braiding, based on the relationship between median particle size (d50) and 10-yr screening index (INDEX) = Slope * Q10^0.5.
#         Historical d50 & INDEX data (from the field manual) that represent the 50% risk threshold were used to create a regression model in SigmaPlot.  
#         The d50 and INDEX data for each site are plugged into the model to see if data for each site is above or below the 50% risk threshold.
#         The site is categorized as A (below the threshold), B (indeterminate d50 or hardpan), or C (above the threshold).
#    For each of the 3 components, the letter categories are converted to a number value (A=3, B=6, C=9).  The vertical susceptibility rating is then calculated as:
#    Vertical Rating = sqrt((sqrt(armoring * grade control) * screening index score))
#    Vertical Rating <4.5 = LOW; 4.5-7 = MEDIUM; >7 = HIGH
#    #
#    Fully Armored = Yes:                            Vertical Rating = 3 & Vertical Susceptibility = Low.  (d50 not needed)
#    Streambed State = C (course/armored/resistent): Vertical Rating = 3 & Vertical Susceptibility = Low.  (d50 not needed)
#    Streambed State = A (sand/gravel):              Vertical Rating = 9 & Vertical Susceptibility = High. (d50 not needed)
#
#
# Lateral susceptibility uses a decision tree based on:
#     i) Lateral adjustability of stream (assessed in the field).  Includes assessment of:
#        a. Armoring (assessed in field).  Field crews determine if bank is fully armored or not.
#        b. Evidence of mass wasting, chute formation, avulsions (assessed in field, using flow chart)
#        c. Confinement (can stream move 2x bank full width?) (assessed in field)
#    ii) Consolidation of bank material (kick test, assessed in the field)
#   iii) Probability of mass wasting bank failure.  Based on relationship between bank angle and bank height (measured in the field, assessed in the office)
#        Regression model made in SigmaPlot with historic data (from field manual) is used to see if each site is above or below the 10% mass wasting probability.
#    iv) Valley Width Index (VWI) = Valley width / (6.99 * Q10^0.438) (assessed in the office)
#     v) Vertical Rating (<=7 or >7).  Calculated above for assessing vertical susceptibility.
#
#
# Jeff Brown, SCCWRP, December 2016
#
#
##This software and its documentation are furnished by Southern California Coastal Water Research Project Authority "as is."
##The authors, Southern California Coastal Water Research Project Authority, its instrumentalities, officers, employees, and agents make no warranties,
##expressed or implied, as to the usefulness of the software and documentation for any purpose.
##They also assume no responsibility (1) for the use of the software and documentation; or (2) to provide technical support to users.
#
#
# REVISIONS
#
#   Change d50 to 5660 if concrete
#
#   Fully Armored sites now have lateral rating = "Low" (17Nov2017)
#   Average Susceptibility = "Low" when avg is <1.5, instead of =1 (17Nov2017)
#
#########################################


####--- GET DATA ---####

#One file containing all data, or individual files?  Here, test files are used.
#HM1  <- read.csv("L:/SMC Regional Monitoring_ES/SMC_RM/Data/Working/Hydromod_2016/csv for R/LARWMP Hydromod 2016.csv", stringsAsFactors = F)
#HM2  <- read.csv("L:/SMC Regional Monitoring_ES/SMC_RM/Data/Working/Hydromod_2016/csv for R/OCPW-SAR Hydromod 2016.csv", stringsAsFactors = F)
#HM3  <- read.csv("L:/SMC Regional Monitoring_ES/SMC_RM/Data/Working/Hydromod_2016/csv for R/OCPW-SDR Hydromod 2016.csv", stringsAsFactors = F)
#HM4  <- read.csv("L:/SMC Regional Monitoring_ES/SMC_RM/Data/Working/Hydromod_2016/csv for R/RCFCD_Weston_2016_SMCHydromodTemplate_08_20_2015-2.csv", stringsAsFactors = F)
#HM5  <- read.csv("L:/SMC Regional Monitoring_ES/SMC_RM/Data/Working/Hydromod_2016/csv for R/SD_Weston_2016_SMCHydromodTemplate_08_20_2015-2.csv", stringsAsFactors = F)
#HM6  <- read.csv("L:/SMC Regional Monitoring_ES/SMC_RM/Data/Working/Hydromod_2016/csv for R/SGRRMP Hydromod 2016.csv", stringsAsFactors = F)
#HM7  <- read.csv("L:/SMC Regional Monitoring_ES/SMC_RM/Data/Working/Hydromod_2016/csv for R/SMCHydromodTemplate_08_20_2015-1_WESTON.csv", stringsAsFactors = F)
#HM8  <- read.csv("L:/SMC Regional Monitoring_ES/SMC_RM/Data/Working/Hydromod_2016/csv for R/VCWPD Hydromod 2016.csv", stringsAsFactors = F)
#HM9  <- read.csv("L:/SMC Regional Monitoring_ES/SMC_RM/Data/Working/Hydromod_2016/csv for R/tblSMCHydromod_Amec_All_2016.csv", stringsAsFactors = F)
#HM10 <- read.csv("L:/SMC Regional Monitoring_ES/SMC_RM/Data/Working/Hydromod_2016/csv for R/SMCHydromod_CSULB-SEAL_2016.csv", stringsAsFactors = F)

AllHydromod     <-read.csv("Z:/SMCStreamMonitoringProgram/Data/2018_Data/Hydromod/Hydromod consolidated with LatLong.csv" , stringsAsFactors = F)





####--- Conformity ---####

AllHydromod  <- AllHydromod[!is.na(AllHydromod$StationCode), ] #get rid of StationCode = NA
AllHydromod  <- AllHydromod[!(AllHydromod$StationCode == ""), ] #get rid of StationCode blanks
AllHydromod$SampleDate <- as.Date(as.character(AllHydromod$SampleDate),"%m/%d/%Y") #format date (use for restricting to current SMC year, if desired)
AllHydromod$FullyArmored <- ifelse(AllHydromod$FullyArmored == "yes", "Yes", AllHydromod$FullyArmored)
AllHydromod$FullyArmored <- ifelse(AllHydromod$FullyArmored == "no", "No", AllHydromod$FullyArmored)



##################################################################### NEED StreamStats, Slope and Valley Width calculations for most recent data



####--- Flow calcs  ---####
AllHydromod$ValleySlope <- as.numeric(AllHydromod$ValleySlope)
AllHydromod$ValleyWidth <- as.numeric(AllHydromod$ValleyWidth)
AllHydromod$D50         <- as.numeric(AllHydromod$D50)
AllHydromod$D50         <- ifelse(is.na(AllHydromod$D50) | AllHydromod$D50 <=0, AllHydromod$D50Estimated, AllHydromod$D50)   #Get estimated d50 if not measured
AllHydromod$D50         <- ifelse(is.na(AllHydromod$D50), -88, AllHydromod$D50)                    #Need to have a value for d50
AllHydromod$D50         <- ifelse(AllHydromod$D50 <= 0  , -88, AllHydromod$D50)                    #Consistent indeterminate d50 value, in case "-99" or "0" was used
AllHydromod$D50         <- as.numeric(AllHydromod$D50)
#
AllHydromod$Q10     <- 18.2 * (AllHydromod$Area^0.87) * (AllHydromod$Precipitation^0.77) * 0.0283  #Calculate Q10 (10 year peak flow, Hydromod field manual p. 6)
AllHydromod$INDEX   <- AllHydromod$ValleySlope * (AllHydromod$Q10^0.5)                             #Calculate 10 year screening index (Sv * Q10^0.5, p. 6)
#
#AllHydromod <- AllHydromod[!(AllHydromod$StreambedState == "" & AllHydromod$FullyArmored == "No"), ] #see if this gets rid of the trouble maker



####--- Vertical Susceptibility ---####


    ### ATTENTION!!!  Most of the field crews determined a "Primary state of streambed" score as a surrogate for vertical susceptibility (StreambedState column),
    ###   instead of determining armoring potential and grade control.  Therefore the program has been revised to reflect this.


## Vertical Susceptibility Loop
AList  <- AllHydromod[!duplicated(AllHydromod$StationCode), ]
AList  <- AList$StationCode
#i <- "902M18864"  #Used to test code.  Delete or disable when code is working
#i <- "SMC01097"   #Used to test code.  Delete or disable when code is working
#i <- "404R4S015"   #Used to test code.  Delete or disable when code is working
FirstTime <- 1

for (i in AList) {
  StationCodeCurrent  <- AllHydromod[AllHydromod$StationCode == i, ]   #Subset data for current StationCode
  if (StationCodeCurrent$FullyArmored == "Yes") {
    StationCodeCurrent$VertRating  <- 3
    StationCodeCurrent$VertSuscept <- "LOW"
  } else if (StationCodeCurrent$FullyArmored == "No") {
        if (StationCodeCurrent$StreambedState == "C") {
          StationCodeCurrent$VertRating  <- 3
          StationCodeCurrent$VertSuscept <- "LOW"
        }
        if (StationCodeCurrent$StreambedState == "A") {
          StationCodeCurrent$VertRating <- 9
          StationCodeCurrent$VertSuscept <- "High"
        }
        if (StationCodeCurrent$StreambedState == "B" | StationCodeCurrent$StreambedState == "" | is.na(StationCodeCurrent$StreambedState)) {
          if (StationCodeCurrent$ArmoringPotential == "" | StationCodeCurrent$GradeControl == "" | StationCodeCurrent$D50 == "" | StationCodeCurrent$INDEX == "" |
              is.na(StationCodeCurrent$ArmoringPotential) | is.na(StationCodeCurrent$GradeControl) | is.na(StationCodeCurrent$D50) | is.na(StationCodeCurrent$INDEX)) {
            StationCodeCurrent$VertRating  <- -88
            StationCodeCurrent$VertSuscept <- "Unk"
          } else {
            
            ##Armoring
            StationCodeCurrent$ArmoringPotential <- ifelse(StationCodeCurrent$ArmoringPotential == "A", 3,
                                                    ifelse (StationCodeCurrent$ArmoringPotential == "B", 6,
                                                            ifelse(StationCodeCurrent$ArmoringPotential == "C", 9, -999)))#Translate letters into numbers (A=3, B=6, C=9)
            StationCodeCurrent$ArmoringPotential <- as.integer(StationCodeCurrent$ArmoringPotential)                             #change from character to integer
            
            
            
            ##Grade Control
            StationCodeCurrent$GradeControl <- ifelse(StationCodeCurrent$GradeControl == "A", 3,
                                                    ifelse (StationCodeCurrent$GradeControl == "B", 6,
                                                            ifelse(StationCodeCurrent$GradeControl == "C", 9, -999)))  #Translate letters into numbers (A=3, B=6, C=9)
            StationCodeCurrent$GradeControl <- as.integer(StationCodeCurrent$GradeControl)                                    #change from character to integer
            
            
            
            ##Screening Index
            #  What: Need to see how the SMC 10 year screening index for each site (Sv * Q10^0.5) compares with the 50% risk threshold.
            #     The 50% risk threshold is based on the relationship between the d50 and 10 year screeining index for previous data (see Form 3,
            #     Fig 4 of the hydromod field manual, p19). A regression model was created in SigmaPlot using these data (quadratic regression option).
            #  How: Plug the measured SMC d50 values into the regression equation in order to derive the 50% risk threshold.
            #     Then compare the SMC 10 year screening index with the derived threshold value.  The Screeining Index Score is taken from Form 3,
            #     Table 1 of the hydromod field manual (p.19).
            #     Particle sizes larger than cobble (sizes >256mm, which includes boulders and larger particles) are treated as hardpan for the screening index.
            
            StationCodeCurrent$V.RiskThresh <- 1.852*10^-2 + (1.659*10^-3 * StationCodeCurrent$D50) + (-5.403*10^-6 * StationCodeCurrent$D50^2) #Plug in to quadratic regression from SigmaPlot
            
            #Screening Index Score
            #
            StationCodeCurrent$SIS <- ifelse((StationCodeCurrent$D50 > 256 | StationCodeCurrent$D50 < 0), 6,           #Boulder/hardpan or indeterminate (Screening Index Score = "B")
                                      ifelse(StationCodeCurrent$INDEX < StationCodeCurrent$V.RiskThresh, 3, 9))   #Below threshold, <50% probability of incision (Screening Index Score = "A")
                                                                                                    #Above threshold, >=50% probability of incision or braiding (SIS = "C")
            
            
            ##Vertical Rating
            StationCodeCurrent$VertRating  <- sqrt(sqrt(StationCodeCurrent$ArmoringPotential + StationCodeCurrent$GradeControl) * StationCodeCurrent$SIS)
            StationCodeCurrent$VertSuscept <- ifelse(StationCodeCurrent$VertRating < 4.5, "LOW",
                                              ifelse(StationCodeCurrent$VertRating >= 4.5 & StationCodeCurrent$VertRating <= 7, "MEDIUM", "HIGH"))
        
        StationCodeCurrent$V.RiskThresh <- NULL #remove to conform with StationCodeCurrent2 prior to rbind step
        StationCodeCurrent$SIS          <- NULL #remove to conform with StationCodeCurrent2 prior to rbind step
        }
      }
  }
  if (FirstTime == 1){
    StationCodeCurrent2 <- StationCodeCurrent
  } else{
    StationCodeCurrent2 <- rbind(StationCodeCurrent2, StationCodeCurrent)
  }
  FirstTime <- FirstTime + 1 
}
AllHydromod2 <- StationCodeCurrent2
#write.csv(AllHydromod2, file="Z:/SMCStreamMonitoringProgram/Data/2018_Data/Hydromod/Hydromod 2018 part2_VerticalSusceptibility.csv")





####--- Lateral Susceptibility ---####
# Note: requires AllHydromod2$VertRating calculated above

##Prep
AllHydromod2$VWI <- AllHydromod2$ValleyWidth / (6.99 * AllHydromod2$Q10^0.438) #Valley width index (VWI)
#
#Inverse second order regression model.  Equation created in SigmaPlot using historical data from p.26 of the field manual.
AllHydromod2$Mass.RiskThresh.L1 <- 1.545 + (-265.2 / AllHydromod2$BankAngleL1) + (13390 / AllHydromod2$BankAngleL1^2) #Mass wasting threshold, for each bank angle (L1)
AllHydromod2$Mass.RiskThresh.L2 <- 1.545 + (-265.2 / AllHydromod2$BankAngleL2) + (13390 / AllHydromod2$BankAngleL2^2) #Mass wasting threshold, for each bank angle (L2)
AllHydromod2$Mass.RiskThresh.L3 <- 1.545 + (-265.2 / AllHydromod2$BankAngleL3) + (13390 / AllHydromod2$BankAngleL3^2) #Mass wasting threshold, for each bank angle (L3)
AllHydromod2$Mass.RiskThresh.R1 <- 1.545 + (-265.2 / AllHydromod2$BankAngleR1) + (13390 / AllHydromod2$BankAngleR1^2) #Mass wasting threshold, for each bank angle (R1)
AllHydromod2$Mass.RiskThresh.R2 <- 1.545 + (-265.2 / AllHydromod2$BankAngleR2) + (13390 / AllHydromod2$BankAngleR2^2) #Mass wasting threshold, for each bank angle (R2)
AllHydromod2$Mass.RiskThresh.R3 <- 1.545 + (-265.2 / AllHydromod2$BankAngleR3) + (13390 / AllHydromod2$BankAngleR3^2) #Mass wasting threshold, for each bank angle (R3)
#
AllHydromod2$Mass.Suscept.L1 <- ifelse(AllHydromod2$BankHeightL1 > AllHydromod2$Mass.RiskThresh.L1, "HIGH", "LOW") #Evaluation of mass wasting (L1).  Recalculated below
AllHydromod2$Mass.Suscept.L2 <- ifelse(AllHydromod2$BankHeightL2 > AllHydromod2$Mass.RiskThresh.L2, "HIGH", "LOW") #Evaluation of mass wasting (L2).  Recalculated below
AllHydromod2$Mass.Suscept.L3 <- ifelse(AllHydromod2$BankHeightL3 > AllHydromod2$Mass.RiskThresh.L3, "HIGH", "LOW") #Evaluation of mass wasting (L3).  Recalculated below
AllHydromod2$Mass.Suscept.R1 <- ifelse(AllHydromod2$BankHeightR1 > AllHydromod2$Mass.RiskThresh.R1, "HIGH", "LOW") #Evaluation of mass wasting (R1).  Recalculated below
AllHydromod2$Mass.Suscept.R2 <- ifelse(AllHydromod2$BankHeightR2 > AllHydromod2$Mass.RiskThresh.R2, "HIGH", "LOW") #Evaluation of mass wasting (R2).  Recalculated below
AllHydromod2$Mass.Suscept.R3 <- ifelse(AllHydromod2$BankHeightR3 > AllHydromod2$Mass.RiskThresh.R3, "HIGH", "LOW") #Evaluation of mass wasting (R3).  Recalculated below

## Fully Armored sites
AllHydromod2$LateralSusceptibilityL <- ifelse(AllHydromod2$FullyArmored == "Yes", 1, AllHydromod2$LateralSusceptibilityL)
AllHydromod2$LateralSusceptibilityR <- ifelse(AllHydromod2$FullyArmored == "Yes", 1, AllHydromod2$LateralSusceptibilityR)


##Decision Tree Loop
AList  <- AllHydromod2[!duplicated(AllHydromod2$StationCode), ]
AList  <- AList$StationCode
#i <- "902M18864"  #Used to test code.  Delete or disable when code is working
#i <- "SMC01097"   #Used to test code.  Delete or disable when code is working
#i <- "404M07354"  # Fully armored site used to test code.
FirstTime <- 1

for (i in AList) {
  StationCodeCurrent3  <- AllHydromod2[AllHydromod2$StationCode == i, ]   #Subset data for current StationCode
  
  ##Lateral Susceptibility Decision Tree L1 (left bank, bank angle measurement #1)
  if (StationCodeCurrent3$LateralSusceptibilityL == "" | is.na(StationCodeCurrent3$LateralSusceptibilityL)){ #No lateral susceptibility number written in field
    StationCodeCurrent3$LatRating.L1 <- "Unk"
  } else {
      if(StationCodeCurrent3$LateralSusceptibilityL == 1){                                            #Not laterally adjustable
        StationCodeCurrent3$LatRating.L1 <- "LOW"
      }
      
      if(StationCodeCurrent3$LateralSusceptibilityL == 5){                                            #Laterally adjustable.  Lateral adjustments occurring
        if (StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI)) {
          StationCodeCurrent3$LatRating.L1 <- "Unk"
        } else {
        StationCodeCurrent3$LatRating.L1 <- ifelse(StationCodeCurrent3$VWI <= 2, "HIGH", "VERY HIGH")         #  VWI <=2 or >2
        }
      }
      
      if(StationCodeCurrent3$LateralSusceptibilityL == 2){                                            #Laterally adjustable, but not occurring & Moderately or well-consolidated
        if (StationCodeCurrent3$VertRating == "" | is.na(StationCodeCurrent3$VertRating) | StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI) |
            StationCodeCurrent3$BankAngleL1 == "" | is.na(StationCodeCurrent3$BankAngleL1) | StationCodeCurrent3$BankAngleL1 < 0 |
            StationCodeCurrent3$BankHeightL1 == "" | is.na(StationCodeCurrent3$BankHeightL1) | StationCodeCurrent3$BankHeightL1 < 0) {
          StationCodeCurrent3$LatRating.L1 <- "Unk"
        } else {
          if (StationCodeCurrent3$BankAngleL1 <= StationCodeCurrent3$Mass.RiskThresh.L1){                       #  <=10% risk of mass wasting
            if (StationCodeCurrent3$VertRating <= 7){                                                   #      Vertical rating <high
              StationCodeCurrent3$LatRating.L1 <- ifelse(StationCodeCurrent3$VWI <= 2, "LOW", "MEDIUM")         #         VWI <=2 or >2
            }
            if (StationCodeCurrent3$VertRating > 7){                                                    #      Vertical rating high
              StationCodeCurrent3$LatRating.L1 <- ifelse(StationCodeCurrent3$VWI <= 2, "MEDIUM", "HIGH")        #         VWI <=2 or >2
            }
          }
          if (StationCodeCurrent3$BankAngleL1 > StationCodeCurrent3$Mass.RiskThresh.L1){                        #  >10% risk of mass wasting
            if (StationCodeCurrent3$VWI <= 2){                                                          #      VWI <=2
              StationCodeCurrent3$LatRating.L1 <- ifelse(StationCodeCurrent3$VertRating <= 7, "MEDIUM", "HIGH") #         Vertical rating <=7 or >7
            }
            if (StationCodeCurrent3$VWI > 2){
              StationCodeCurrent3$LatRating.L1 <- ifelse(StationCodeCurrent3$VertRating <= 7, "HIGH", "VERY HIGH") #      Vertical rating <=7 or >7
            }
          }
        }
      }
      
      if (StationCodeCurrent3$LateralSusceptibilityL == 3){                            #Laterally adjustable, but not occurring. Poorly consolidated. Toe course/resistant
        if (StationCodeCurrent3$VertRating == "" | is.na(StationCodeCurrent3$VertRating) | StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI)) {
          StationCodeCurrent3$LatRating.L1 <- "Unk"
        } else {
          if(StationCodeCurrent3$VertRating <= 7){                                              #  Vertical rating <high
            StationCodeCurrent3$LatRating.L1 <- ifelse(StationCodeCurrent3$VWI <= 2, "LOW", "MEDIUM")   #     VWI <=2 or >2
          }
          if(StationCodeCurrent3$VertRating > 7){                                               #  Vertical rating high
            StationCodeCurrent3$LatRating.L1 <- ifelse(StationCodeCurrent3$VWI <= 2, "MEDIUM", "HIGH")  #     VWI <=2 or >2
          }
        }
      }
      
      if (StationCodeCurrent3$LateralSusceptibilityL == 4){                          #Laterally adjustable, but not occurring. Poorly consolidated. Toe not course/resistant
        if (StationCodeCurrent3$VertRating == "" | is.na(StationCodeCurrent3$VertRating) | StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI)) {
          StationCodeCurrent3$LatRating.L1 <- "Unk"
        } else {
          if(StationCodeCurrent3$VWI <= 2){                                                     #  VWI <=2
            StationCodeCurrent3$LatRating.L1 <- ifelse(StationCodeCurrent3$VertRating <= 7, "MEDIUM", "HIGH")   #     Vertical rating <=7 or >7
          }
          if(StationCodeCurrent3$VWI > 2){                                                      #  VWI <=2 or >2
            StationCodeCurrent3$LatRating.L1 <- ifelse(StationCodeCurrent3$VertRating <= 7, "HIGH", "VERY HIGH")    #     Vertical rating <=7 or >7
          }
          }
        }
  } # end of decision tree for left bank, bank angle measurement #1
  
  ##Lateral Susceptibility Decision Tree L2 (left bank, bank angle measurement #2)
  if (StationCodeCurrent3$LateralSusceptibilityL == "" | is.na(StationCodeCurrent3$LateralSusceptibilityL)){ #No lateral susceptibility number written in field
    StationCodeCurrent3$LatRating.L2 <- "Unk"
  } else {
    if(StationCodeCurrent3$LateralSusceptibilityL == 1){                                            #Not laterally adjustable
      StationCodeCurrent3$LatRating.L2 <- "LOW"
    }
    
    if(StationCodeCurrent3$LateralSusceptibilityL == 5){                                            #Laterally adjustable.  Lateral adjustments occurring
      if (StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI)) {
        StationCodeCurrent3$LatRating.L2 <- "Unk"
      } else {
        StationCodeCurrent3$LatRating.L2 <- ifelse(StationCodeCurrent3$VWI <= 2, "HIGH", "VERY HIGH")         #  VWI <=2 or >2
      }
    }
    
    if(StationCodeCurrent3$LateralSusceptibilityL == 2){                                            #Laterally adjustable, but not occurring & Moderately or well-consolidated
      if (StationCodeCurrent3$VertRating == "" | is.na(StationCodeCurrent3$VertRating) | StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI) |
          StationCodeCurrent3$BankAngleL2 == "" | is.na(StationCodeCurrent3$BankAngleL2) | StationCodeCurrent3$BankAngleL2 < 0 |
          StationCodeCurrent3$BankHeightL2 == "" | is.na(StationCodeCurrent3$BankHeightL2) | StationCodeCurrent3$BankHeightL2 < 0) {
        StationCodeCurrent3$LatRating.L2 <- "Unk"
      } else {
        if (StationCodeCurrent3$BankAngleL2 <= StationCodeCurrent3$Mass.RiskThresh.L2){                       #  <=10% risk of mass wasting
          if (StationCodeCurrent3$VertRating <= 7){                                                   #      Vertical rating <high
            StationCodeCurrent3$LatRating.L2 <- ifelse(StationCodeCurrent3$VWI <= 2, "LOW", "MEDIUM")         #         VWI <=2 or >2
          }
          if (StationCodeCurrent3$VertRating > 7){                                                    #      Vertical rating high
            StationCodeCurrent3$LatRating.L2 <- ifelse(StationCodeCurrent3$VWI <= 2, "MEDIUM", "HIGH")        #         VWI <=2 or >2
          }
        }
        if (StationCodeCurrent3$BankAngleL2 > StationCodeCurrent3$Mass.RiskThresh.L2){                        #  >10% risk of mass wasting
          if (StationCodeCurrent3$VWI <= 2){                                                          #      VWI <=2
            StationCodeCurrent3$LatRating.L2 <- ifelse(StationCodeCurrent3$VertRating <= 7, "MEDIUM", "HIGH") #         Vertical rating <=7 or >7
          }
          if (StationCodeCurrent3$VWI > 2){
            StationCodeCurrent3$LatRating.L2 <- ifelse(StationCodeCurrent3$VertRating <= 7, "HIGH", "VERY HIGH") #      Vertical rating <=7 or >7
          }
        }
      }
    }
    
    if (StationCodeCurrent3$LateralSusceptibilityL == 3){                            #Laterally adjustable, but not occurring. Poorly consolidated. Toe course/resistant
      if (StationCodeCurrent3$VertRating == "" | is.na(StationCodeCurrent3$VertRating) | StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI)) {
        StationCodeCurrent3$LatRating.L2 <- "Unk"
      } else {
        if(StationCodeCurrent3$VertRating <= 7){                                              #  Vertical rating <high
          StationCodeCurrent3$LatRating.L2 <- ifelse(StationCodeCurrent3$VWI <= 2, "LOW", "MEDIUM")   #     VWI <=2 or >2
        }
        if(StationCodeCurrent3$VertRating > 7){                                               #  Vertical rating high
          StationCodeCurrent3$LatRating.L2 <- ifelse(StationCodeCurrent3$VWI <= 2, "MEDIUM", "HIGH")  #     VWI <=2 or >2
        }
      }
    }
    
    if (StationCodeCurrent3$LateralSusceptibilityL == 4){                          #Laterally adjustable, but not occurring. Poorly consolidated. Toe not course/resistant
      if (StationCodeCurrent3$VertRating == "" | is.na(StationCodeCurrent3$VertRating) | StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI)) {
        StationCodeCurrent3$LatRating.L2 <- "Unk"
      } else {
        if(StationCodeCurrent3$VWI <= 2){                                                     #  VWI <=2
          StationCodeCurrent3$LatRating.L2 <- ifelse(StationCodeCurrent3$VertRating <= 7, "MEDIUM", "HIGH")   #     Vertical rating <=7 or >7
        }
        if(StationCodeCurrent3$VWI > 2){                                                      #  VWI <=2 or >2
          StationCodeCurrent3$LatRating.L2 <- ifelse(StationCodeCurrent3$VertRating <= 7, "HIGH", "VERY HIGH")    #     Vertical rating <=7 or >7
        }
      }
    }
  } # end of decision tree for left bank, bank angle measurement #2
  
  ##Lateral Susceptibility Decision Tree L1 (left bank, bank angle measurement #3)
  if (StationCodeCurrent3$LateralSusceptibilityL == "" | is.na(StationCodeCurrent3$LateralSusceptibilityL)){ #No lateral susceptibility number written in field
    StationCodeCurrent3$LatRating.L3 <- "Unk"
  } else {
    if(StationCodeCurrent3$LateralSusceptibilityL == 1){                                            #Not laterally adjustable
      StationCodeCurrent3$LatRating.L3 <- "LOW"
    }
    
    if(StationCodeCurrent3$LateralSusceptibilityL == 5){                                            #Laterally adjustable.  Lateral adjustments occurring
      if (StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI)) {
        StationCodeCurrent3$LatRating.L3 <- "Unk"
      } else {
        StationCodeCurrent3$LatRating.L3 <- ifelse(StationCodeCurrent3$VWI <= 2, "HIGH", "VERY HIGH")         #  VWI <=2 or >2
      }
    }
    
    if(StationCodeCurrent3$LateralSusceptibilityL == 2){                                            #Laterally adjustable, but not occurring & Moderately or well-consolidated
      if (StationCodeCurrent3$VertRating == "" | is.na(StationCodeCurrent3$VertRating) | StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI) |
          StationCodeCurrent3$BankAngleL3 == "" | is.na(StationCodeCurrent3$BankAngleL3) | StationCodeCurrent3$BankAngleL3 < 0 |
          StationCodeCurrent3$BankHeightL3 == "" | is.na(StationCodeCurrent3$BankHeightL3) | StationCodeCurrent3$BankHeightL3 < 0) {
        StationCodeCurrent3$LatRating.L3 <- "Unk"
      } else {
        if (StationCodeCurrent3$BankAngleL3 <= StationCodeCurrent3$Mass.RiskThresh.L3){                       #  <=10% risk of mass wasting
          if (StationCodeCurrent3$VertRating <= 7){                                                   #      Vertical rating <high
            StationCodeCurrent3$LatRating.L3 <- ifelse(StationCodeCurrent3$VWI <= 2, "LOW", "MEDIUM")         #         VWI <=2 or >2
          }
          if (StationCodeCurrent3$VertRating > 7){                                                    #      Vertical rating high
            StationCodeCurrent3$LatRating.L3 <- ifelse(StationCodeCurrent3$VWI <= 2, "MEDIUM", "HIGH")        #         VWI <=2 or >2
          }
        }
        if (StationCodeCurrent3$BankAngleL3 > StationCodeCurrent3$Mass.RiskThresh.L3){                        #  >10% risk of mass wasting
          if (StationCodeCurrent3$VWI <= 2){                                                          #      VWI <=2
            StationCodeCurrent3$LatRating.L3 <- ifelse(StationCodeCurrent3$VertRating <= 7, "MEDIUM", "HIGH") #         Vertical rating <=7 or >7
          }
          if (StationCodeCurrent3$VWI > 2){
            StationCodeCurrent3$LatRating.L3 <- ifelse(StationCodeCurrent3$VertRating <= 7, "HIGH", "VERY HIGH") #      Vertical rating <=7 or >7
          }
        }
      }
    }
    
    if (StationCodeCurrent3$LateralSusceptibilityL == 3){                            #Laterally adjustable, but not occurring. Poorly consolidated. Toe course/resistant
      if (StationCodeCurrent3$VertRating == "" | is.na(StationCodeCurrent3$VertRating) | StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI)) {
        StationCodeCurrent3$LatRating.L3 <- "Unk"
      } else {
        if(StationCodeCurrent3$VertRating <= 7){                                              #  Vertical rating <high
          StationCodeCurrent3$LatRating.L3 <- ifelse(StationCodeCurrent3$VWI <= 2, "LOW", "MEDIUM")   #     VWI <=2 or >2
        }
        if(StationCodeCurrent3$VertRating > 7){                                               #  Vertical rating high
          StationCodeCurrent3$LatRating.L3 <- ifelse(StationCodeCurrent3$VWI <= 2, "MEDIUM", "HIGH")  #     VWI <=2 or >2
        }
      }
    }
    
    if (StationCodeCurrent3$LateralSusceptibilityL == 4){                          #Laterally adjustable, but not occurring. Poorly consolidated. Toe not course/resistant
      if (StationCodeCurrent3$VertRating == "" | is.na(StationCodeCurrent3$VertRating) | StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI)) {
        StationCodeCurrent3$LatRating.L3 <- "Unk"
      } else {
        if(StationCodeCurrent3$VWI <= 2){                                                     #  VWI <=2
          StationCodeCurrent3$LatRating.L3 <- ifelse(StationCodeCurrent3$VertRating <= 7, "MEDIUM", "HIGH")   #     Vertical rating <=7 or >7
        }
        if(StationCodeCurrent3$VWI > 2){                                                      #  VWI <=2 or >2
          StationCodeCurrent3$LatRating.L3 <- ifelse(StationCodeCurrent3$VertRating <= 7, "HIGH", "VERY HIGH")    #     Vertical rating <=7 or >7
        }
      }
    }
  } # end of decision tree for left bank, bank angle measurement #3
  
  ##Lateral Susceptibility Decision Tree R1 (right bank, bank angle measurement #1)
  if (StationCodeCurrent3$LateralSusceptibilityR == "" | is.na(StationCodeCurrent3$LateralSusceptibilityR)){ #No lateral susceptibility number written in field
    StationCodeCurrent3$LatRating.R1 <- "Unk"
  } else {
    if(StationCodeCurrent3$LateralSusceptibilityR == 1){                                            #Not laterally adjustable
      StationCodeCurrent3$LatRating.R1 <- "LOW"
    }
    
    if(StationCodeCurrent3$LateralSusceptibilityR == 5){                                            #Laterally adjustable.  Lateral adjustments occurring
      if (StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI)) {
        StationCodeCurrent3$LatRating.R1 <- "Unk"
      } else {
        StationCodeCurrent3$LatRating.R1 <- ifelse(StationCodeCurrent3$VWI <= 2, "HIGH", "VERY HIGH")         #  VWI <=2 or >2
      }
    }
    
    if(StationCodeCurrent3$LateralSusceptibilityR == 2){                                            #Laterally adjustable, but not occurring & Moderately or well-consolidated
      if (StationCodeCurrent3$VertRating == "" | is.na(StationCodeCurrent3$VertRating) | StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI) |
          StationCodeCurrent3$BankAngleR1 == "" | is.na(StationCodeCurrent3$BankAngleR1) | StationCodeCurrent3$BankAngleR1 < 0 |
          StationCodeCurrent3$BankHeightR1 == "" | is.na(StationCodeCurrent3$BankHeightR1) | StationCodeCurrent3$BankHeightR1 < 0) {
        StationCodeCurrent3$LatRating.R1 <- "Unk"
      } else {
        if (StationCodeCurrent3$BankAngleR1 <= StationCodeCurrent3$Mass.RiskThresh.R1){                       #  <=10% risk of mass wasting
          if (StationCodeCurrent3$VertRating <= 7){                                                   #      Vertical rating <high
            StationCodeCurrent3$LatRating.R1 <- ifelse(StationCodeCurrent3$VWI <= 2, "LOW", "MEDIUM")         #         VWI <=2 or >2
          }
          if (StationCodeCurrent3$VertRating > 7){                                                    #      Vertical rating high
            StationCodeCurrent3$LatRating.R1 <- ifelse(StationCodeCurrent3$VWI <= 2, "MEDIUM", "HIGH")        #         VWI <=2 or >2
          }
        }
        if (StationCodeCurrent3$BankAngleR1 > StationCodeCurrent3$Mass.RiskThresh.R1){                        #  >10% risk of mass wasting
          if (StationCodeCurrent3$VWI <= 2){                                                          #      VWI <=2
            StationCodeCurrent3$LatRating.R1 <- ifelse(StationCodeCurrent3$VertRating <= 7, "MEDIUM", "HIGH") #         Vertical rating <=7 or >7
          }
          if (StationCodeCurrent3$VWI > 2){
            StationCodeCurrent3$LatRating.R1 <- ifelse(StationCodeCurrent3$VertRating <= 7, "HIGH", "VERY HIGH") #      Vertical rating <=7 or >7
          }
        }
      }
    }
    
    if (StationCodeCurrent3$LateralSusceptibilityR == 3){                            #Laterally adjustable, but not occurring. Poorly consolidated. Toe course/resistant
      if (StationCodeCurrent3$VertRating == "" | is.na(StationCodeCurrent3$VertRating) | StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI)) {
        StationCodeCurrent3$LatRating.R1 <- "Unk"
      } else {
        if(StationCodeCurrent3$VertRating <= 7){                                              #  Vertical rating <high
          StationCodeCurrent3$LatRating.R1 <- ifelse(StationCodeCurrent3$VWI <= 2, "LOW", "MEDIUM")   #     VWI <=2 or >2
        }
        if(StationCodeCurrent3$VertRating > 7){                                               #  Vertical rating high
          StationCodeCurrent3$LatRating.R1 <- ifelse(StationCodeCurrent3$VWI <= 2, "MEDIUM", "HIGH")  #     VWI <=2 or >2
        }
      }
    }
    
    if (StationCodeCurrent3$LateralSusceptibilityR == 4){                          #Laterally adjustable, but not occurring. Poorly consolidated. Toe not course/resistant
      if (StationCodeCurrent3$VertRating == "" | is.na(StationCodeCurrent3$VertRating) | StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI)) {
        StationCodeCurrent3$LatRating.R1 <- "Unk"
      } else {
        if(StationCodeCurrent3$VWI <= 2){                                                     #  VWI <=2
          StationCodeCurrent3$LatRating.R1 <- ifelse(StationCodeCurrent3$VertRating <= 7, "MEDIUM", "HIGH")   #     Vertical rating <=7 or >7
        }
        if(StationCodeCurrent3$VWI > 2){                                                      #  VWI <=2 or >2
          StationCodeCurrent3$LatRating.R1 <- ifelse(StationCodeCurrent3$VertRating <= 7, "HIGH", "VERY HIGH")    #     Vertical rating <=7 or >7
        }
      }
    }
  } # end of decision tree for right bank, bank angle measurement #1
  
  ##Lateral Susceptibility Decision Tree R2 (right bank, bank angle measurement #2)
  if (StationCodeCurrent3$LateralSusceptibilityR == "" | is.na(StationCodeCurrent3$LateralSusceptibilityR)){ #No lateral susceptibility number written in field
    StationCodeCurrent3$LatRating.R2 <- "Unk"
  } else {
    if(StationCodeCurrent3$LateralSusceptibilityR == 1){                                            #Not laterally adjustable
      StationCodeCurrent3$LatRating.R2 <- "LOW"
    }
    
    if(StationCodeCurrent3$LateralSusceptibilityR == 5){                                            #Laterally adjustable.  Lateral adjustments occurring
      if (StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI)) {
        StationCodeCurrent3$LatRating.R2 <- "Unk"
      } else {
        StationCodeCurrent3$LatRating.R2 <- ifelse(StationCodeCurrent3$VWI <= 2, "HIGH", "VERY HIGH")         #  VWI <=2 or >2
      }
    }
    
    if(StationCodeCurrent3$LateralSusceptibilityR == 2){                                            #Laterally adjustable, but not occurring & Moderately or well-consolidated
      if (StationCodeCurrent3$VertRating == "" | is.na(StationCodeCurrent3$VertRating) | StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI) |
          StationCodeCurrent3$BankAngleR2 == "" | is.na(StationCodeCurrent3$BankAngleR2) | StationCodeCurrent3$BankAngleR2 < 0 |
          StationCodeCurrent3$BankHeightR2 == "" | is.na(StationCodeCurrent3$BankHeightR2) | StationCodeCurrent3$BankHeightR2 < 0) {
        StationCodeCurrent3$LatRating.R2 <- "Unk"
      } else {
        if (StationCodeCurrent3$BankAngleR2 <= StationCodeCurrent3$Mass.RiskThresh.R2){                       #  <=10% risk of mass wasting
          if (StationCodeCurrent3$VertRating <= 7){                                                   #      Vertical rating <high
            StationCodeCurrent3$LatRating.R2 <- ifelse(StationCodeCurrent3$VWI <= 2, "LOW", "MEDIUM")         #         VWI <=2 or >2
          }
          if (StationCodeCurrent3$VertRating > 7){                                                    #      Vertical rating high
            StationCodeCurrent3$LatRating.R2 <- ifelse(StationCodeCurrent3$VWI <= 2, "MEDIUM", "HIGH")        #         VWI <=2 or >2
          }
        }
        if (StationCodeCurrent3$BankAngleR2 > StationCodeCurrent3$Mass.RiskThresh.R2){                        #  >10% risk of mass wasting
          if (StationCodeCurrent3$VWI <= 2){                                                          #      VWI <=2
            StationCodeCurrent3$LatRating.R2 <- ifelse(StationCodeCurrent3$VertRating <= 7, "MEDIUM", "HIGH") #         Vertical rating <=7 or >7
          }
          if (StationCodeCurrent3$VWI > 2){
            StationCodeCurrent3$LatRating.R2 <- ifelse(StationCodeCurrent3$VertRating <= 7, "HIGH", "VERY HIGH") #      Vertical rating <=7 or >7
          }
        }
      }
    }
    
    if (StationCodeCurrent3$LateralSusceptibilityR == 3){                            #Laterally adjustable, but not occurring. Poorly consolidated. Toe course/resistant
      if (StationCodeCurrent3$VertRating == "" | is.na(StationCodeCurrent3$VertRating) | StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI)) {
        StationCodeCurrent3$LatRating.R2 <- "Unk"
      } else {
        if(StationCodeCurrent3$VertRating <= 7){                                              #  Vertical rating <high
          StationCodeCurrent3$LatRating.R2 <- ifelse(StationCodeCurrent3$VWI <= 2, "LOW", "MEDIUM")   #     VWI <=2 or >2
        }
        if(StationCodeCurrent3$VertRating > 7){                                               #  Vertical rating high
          StationCodeCurrent3$LatRating.R2 <- ifelse(StationCodeCurrent3$VWI <= 2, "MEDIUM", "HIGH")  #     VWI <=2 or >2
        }
      }
    }
    
    if (StationCodeCurrent3$LateralSusceptibilityR == 4){                          #Laterally adjustable, but not occurring. Poorly consolidated. Toe not course/resistant
      if (StationCodeCurrent3$VertRating == "" | is.na(StationCodeCurrent3$VertRating) | StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI)) {
        StationCodeCurrent3$LatRating.R2 <- "Unk"
      } else {
        if(StationCodeCurrent3$VWI <= 2){                                                     #  VWI <=2
          StationCodeCurrent3$LatRating.R2 <- ifelse(StationCodeCurrent3$VertRating <= 7, "MEDIUM", "HIGH")   #     Vertical rating <=7 or >7
        }
        if(StationCodeCurrent3$VWI > 2){                                                      #  VWI <=2 or >2
          StationCodeCurrent3$LatRating.R2 <- ifelse(StationCodeCurrent3$VertRating <= 7, "HIGH", "VERY HIGH")    #     Vertical rating <=7 or >7
        }
      }
    }
  } # end of decision tree for right bank, bank angle measurement #2
  
  ##Lateral Susceptibility Decision Tree R3 (right bank, bank angle measurement #3)
  if (StationCodeCurrent3$LateralSusceptibilityR == "" | is.na(StationCodeCurrent3$LateralSusceptibilityR)){ #No lateral susceptibility number written in field
    StationCodeCurrent3$LatRating.R3 <- "Unk"
  } else {
    if(StationCodeCurrent3$LateralSusceptibilityR == 1){                                            #Not laterally adjustable
      StationCodeCurrent3$LatRating.R3 <- "LOW"
    }
    
    if(StationCodeCurrent3$LateralSusceptibilityR == 5){                                            #Laterally adjustable.  Lateral adjustments occurring
      if (StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI)) {
        StationCodeCurrent3$LatRating.R3 <- "Unk"
      } else {
        StationCodeCurrent3$LatRating.R3 <- ifelse(StationCodeCurrent3$VWI <= 2, "HIGH", "VERY HIGH")         #  VWI <=2 or >2
      }
    }
    
    if(StationCodeCurrent3$LateralSusceptibilityR == 2){                                            #Laterally adjustable, but not occurring & Moderately or well-consolidated
      if (StationCodeCurrent3$VertRating == "" | is.na(StationCodeCurrent3$VertRating) | StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI) |
          StationCodeCurrent3$BankAngleR3 == "" | is.na(StationCodeCurrent3$BankAngleR3) | StationCodeCurrent3$BankAngleR3 < 0 |
          StationCodeCurrent3$BankHeightR3 == "" | is.na(StationCodeCurrent3$BankHeightR3) | StationCodeCurrent3$BankHeightR3 < 0) {
        StationCodeCurrent3$LatRating.R3 <- "Unk"
      } else {
        if (StationCodeCurrent3$BankAngleR3 <= StationCodeCurrent3$Mass.RiskThresh.R3){                       #  <=10% risk of mass wasting
          if (StationCodeCurrent3$VertRating <= 7){                                                   #      Vertical rating <high
            StationCodeCurrent3$LatRating.R3 <- ifelse(StationCodeCurrent3$VWI <= 2, "LOW", "MEDIUM")         #         VWI <=2 or >2
          }
          if (StationCodeCurrent3$VertRating > 7){                                                    #      Vertical rating high
            StationCodeCurrent3$LatRating.R3 <- ifelse(StationCodeCurrent3$VWI <= 2, "MEDIUM", "HIGH")        #         VWI <=2 or >2
          }
        }
        if (StationCodeCurrent3$BankAngleR3 > StationCodeCurrent3$Mass.RiskThresh.R3){                        #  >10% risk of mass wasting
          if (StationCodeCurrent3$VWI <= 2){                                                          #      VWI <=2
            StationCodeCurrent3$LatRating.R3 <- ifelse(StationCodeCurrent3$VertRating <= 7, "MEDIUM", "HIGH") #         Vertical rating <=7 or >7
          }
          if (StationCodeCurrent3$VWI > 2){
            StationCodeCurrent3$LatRating.R3 <- ifelse(StationCodeCurrent3$VertRating <= 7, "HIGH", "VERY HIGH") #      Vertical rating <=7 or >7
          }
        }
      }
    }
    
    if (StationCodeCurrent3$LateralSusceptibilityR == 3){                            #Laterally adjustable, but not occurring. Poorly consolidated. Toe course/resistant
      if (StationCodeCurrent3$VertRating == "" | is.na(StationCodeCurrent3$VertRating) | StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI)) {
        StationCodeCurrent3$LatRating.R3 <- "Unk"
      } else {
        if(StationCodeCurrent3$VertRating <= 7){                                              #  Vertical rating <high
          StationCodeCurrent3$LatRating.R3 <- ifelse(StationCodeCurrent3$VWI <= 2, "LOW", "MEDIUM")   #     VWI <=2 or >2
        }
        if(StationCodeCurrent3$VertRating > 7){                                               #  Vertical rating high
          StationCodeCurrent3$LatRating.R3 <- ifelse(StationCodeCurrent3$VWI <= 2, "MEDIUM", "HIGH")  #     VWI <=2 or >2
        }
      }
    }
    
    if (StationCodeCurrent3$LateralSusceptibilityR == 4){                          #Laterally adjustable, but not occurring. Poorly consolidated. Toe not course/resistant
      if (StationCodeCurrent3$VertRating == "" | is.na(StationCodeCurrent3$VertRating) | StationCodeCurrent3$VWI == "" | is.na(StationCodeCurrent3$VWI)) {
        StationCodeCurrent3$LatRating.R3 <- "Unk"
      } else {
        if(StationCodeCurrent3$VWI <= 2){                                                     #  VWI <=2
          StationCodeCurrent3$LatRating.R3 <- ifelse(StationCodeCurrent3$VertRating <= 7, "MEDIUM", "HIGH")   #     Vertical rating <=7 or >7
        }
        if(StationCodeCurrent3$VWI > 2){                                                      #  VWI <=2 or >2
          StationCodeCurrent3$LatRating.R3 <- ifelse(StationCodeCurrent3$VertRating <= 7, "HIGH", "VERY HIGH")    #     Vertical rating <=7 or >7
        }
      }
    }
  } # end of decision tree for right bank, bank angle measurement #3
  
  if (FirstTime == 1){
    StationCodeCurrent4 <- StationCodeCurrent3
  } else{
    StationCodeCurrent4 <- rbind(StationCodeCurrent4, StationCodeCurrent3)
  }
  FirstTime <- FirstTime + 1
}

#Average L1, L2, L3, R1, R2, R3
#First convert designations (low, medium, high, very high) to values, then average
StationCodeCurrent4$LatSuscept.L1 <- ifelse(StationCodeCurrent4$LatRating.L1 == "LOW", 1,
                                            ifelse(StationCodeCurrent4$LatRating.L1 == "MEDIUM", 2,
                                                   ifelse(StationCodeCurrent4$LatRating.L1 == "HIGH", 3,
                                                          ifelse(StationCodeCurrent4$LatRating.L1 == "VERY HIGH", 4, ""))))
StationCodeCurrent4$LatSuscept.L2 <- ifelse(StationCodeCurrent4$LatRating.L2 == "LOW", 1,
                                            ifelse(StationCodeCurrent4$LatRating.L2 == "MEDIUM", 2,
                                                   ifelse(StationCodeCurrent4$LatRating.L2 == "HIGH", 3,
                                                          ifelse(StationCodeCurrent4$LatRating.L2 == "VERY HIGH", 4, ""))))
StationCodeCurrent4$LatSuscept.L3 <- ifelse(StationCodeCurrent4$LatRating.L3 == "LOW", 1,
                                            ifelse(StationCodeCurrent4$LatRating.L3 == "MEDIUM", 2,
                                                   ifelse(StationCodeCurrent4$LatRating.L3 == "HIGH", 3,
                                                          ifelse(StationCodeCurrent4$LatRating.L3 == "VERY HIGH", 4, ""))))
StationCodeCurrent4$LatSuscept.R1 <- ifelse(StationCodeCurrent4$LatRating.R1 == "LOW", 1,
                                            ifelse(StationCodeCurrent4$LatRating.R1 == "MEDIUM", 2,
                                                   ifelse(StationCodeCurrent4$LatRating.R1 == "HIGH", 3,
                                                          ifelse(StationCodeCurrent4$LatRating.R1 == "VERY HIGH", 4, ""))))
StationCodeCurrent4$LatSuscept.R2 <- ifelse(StationCodeCurrent4$LatRating.R2 == "LOW", 1,
                                            ifelse(StationCodeCurrent4$LatRating.R2 == "MEDIUM", 2,
                                                   ifelse(StationCodeCurrent4$LatRating.R2 == "HIGH", 3,
                                                          ifelse(StationCodeCurrent4$LatRating.R2 == "VERY HIGH", 4, ""))))
StationCodeCurrent4$LatSuscept.R3 <- ifelse(StationCodeCurrent4$LatRating.R3 == "LOW", 1,
                                            ifelse(StationCodeCurrent4$LatRating.R3 == "MEDIUM", 2,
                                                   ifelse(StationCodeCurrent4$LatRating.R3 == "HIGH", 3,
                                                          ifelse(StationCodeCurrent4$LatRating.R3 == "VERY HIGH", 4, ""))))
# make numeric
StationCodeCurrent4$LatSuscept.L1 <- as.numeric(StationCodeCurrent4$LatSuscept.L1)
StationCodeCurrent4$LatSuscept.L2 <- as.numeric(StationCodeCurrent4$LatSuscept.L2)
StationCodeCurrent4$LatSuscept.L3 <- as.numeric(StationCodeCurrent4$LatSuscept.L3)
StationCodeCurrent4$LatSuscept.R1 <- as.numeric(StationCodeCurrent4$LatSuscept.R1)
StationCodeCurrent4$LatSuscept.R2 <- as.numeric(StationCodeCurrent4$LatSuscept.R2)
StationCodeCurrent4$LatSuscept.R3 <- as.numeric(StationCodeCurrent4$LatSuscept.R3)
#average by row
StationCodeCurrent4$AverageLatSuscept   <- rowMeans(StationCodeCurrent4[, c("LatSuscept.L1", "LatSuscept.L2", "LatSuscept.L3", "LatSuscept.R1",
                                                                      "LatSuscept.R2", "LatSuscept.R3")])  #get mean for columns 1-20, and put into new variable "Result_Mean"
#convert back to designation
StationCodeCurrent4$AverageLatSuscept <- ifelse(StationCodeCurrent4$AverageLatSuscept < 1.5, "LOW",
                                            ifelse(StationCodeCurrent4$AverageLatSuscept <=2.5, "MEDIUM",
                                                   ifelse(StationCodeCurrent4$AverageLatSuscept <= 3.4, "HIGH",
                                                          ifelse(StationCodeCurrent4$AverageLatSuscept <= 4, "VERY HIGH", ""))))
#
StationCodeCurrent4$LatSuscept.L1 <- NULL #no longer needed
StationCodeCurrent4$LatSuscept.L2 <- NULL #no longer needed
StationCodeCurrent4$LatSuscept.L3 <- NULL #no longer needed
StationCodeCurrent4$LatSuscept.R1 <- NULL #no longer needed
StationCodeCurrent4$LatSuscept.R2 <- NULL #no longer needed
StationCodeCurrent4$LatSuscept.R3 <- NULL #no longer needed


# Fully armored = LOW lateral susceptability.  Some crews didn't write down any channel characteristics if fully armored.  This creates designation for those instances.
StationCodeCurrent4$AverageLatSuscept <- ifelse(StationCodeCurrent4$FullyArmored == "Yes", "LOW", StationCodeCurrent4$AverageLatSuscept)


# Change and add column headers to conform with Access database
# STILL DOES NOT UPLOAD TO ACCESS DATABASE (even with all these modifications to make the formatting compatible. 09/12/2017)
library (reshape)
StationCodeCurrent4 <- rename(StationCodeCurrent4, c(D50Estimated = "D50Estimate", SterambedStateComments = "StreambedStateComments", INDEX = "Num_Index",
                                                     LateralSusceptibilityComments = "LaterSusceptibilityComments", Mass.Suscept.R3 = "MassSusceptR3",
                                                     Mass.Suscept.R2 = "MassSusceptR2", Mass.Suscept.R1 = "MassSusceptR1", Mass.Suscept.L1 = "MassSusceptL1",
                                                     Mass.Suscept.L2 = "MassSusceptL2", Mass.Suscept.L3 = "MassSusceptL3", Mass.RiskThresh.R1 = "MassRiskThreshR1",
                                                     Mass.RiskThresh.R2 = "MassRiskThreshR2", Mass.RiskThresh.R3 = "MassRiskThreshR3",
                                                     Mass.RiskThresh.L3 = "MassRiskThreshL3", Mass.RiskThresh.L2 = "MassRiskThreshL2",
                                                     Mass.RiskThresh.L1 = "MassRiskThreshL1", LatSuscept.L1 = "LatSusceptL1", LatSuscept.L2 = "LatSusceptL2",
                                                     LatSuscept.L3 = "LatSusceptL3", LatSuscept.R1 = "LatSusceptR1", LatSuscept.R2 = "LatSusceptR2",
                                                     LatSuscept.R3 = "LatSusceptR3", LatRating.L1 = "LatRatingL1", LatRating.L2 = "LatRatingL2",
                                                     LatRating.L3 = "LatRatingL3", LatRating.R1 = "LatRatingR1", LatRating.R2 = "LatRatingR2",
                                                     LatRating.R3 = "LatRatingR3"))
StationCodeCurrent4$LeftRatingOverall    <- NA
StationCodeCurrent4$RightRatingOverall   <- NA
StationCodeCurrent4$LateralRatingOverall <- NA
StationCodeCurrent4$ProjectCode          <- NA
StationCodeCurrent4$SubmissionID         <- NA
StationCodeCurrent4$LastChangeDate       <- NA
#
StationCodeCurrent4$FullyArmored <- ifelse(StationCodeCurrent4$FullyArmored == "Yes", -1,
                                           ifelse(StationCodeCurrent4$FullyArmored == "No", 0, -88))
#
StationCodeCurrent4$BankHeightL1 <- ifelse(is.na(StationCodeCurrent4$BankHeightL1), "", StationCodeCurrent4$BankHeightL1)
StationCodeCurrent4$BankHeightL2 <- ifelse(is.na(StationCodeCurrent4$BankHeightL2), "", StationCodeCurrent4$BankHeightL2)
StationCodeCurrent4$BankHeightL3 <- ifelse(is.na(StationCodeCurrent4$BankHeightL3), "", StationCodeCurrent4$BankHeightL3)
StationCodeCurrent4$BankHeightR1 <- ifelse(is.na(StationCodeCurrent4$BankHeightR1), "", StationCodeCurrent4$BankHeightR1)
StationCodeCurrent4$BankHeightR2 <- ifelse(is.na(StationCodeCurrent4$BankHeightR2), "", StationCodeCurrent4$BankHeightR2)
StationCodeCurrent4$BankHeightR3 <- ifelse(is.na(StationCodeCurrent4$BankHeightR3), "", StationCodeCurrent4$BankHeightR3)
#
StationCodeCurrent4$BankAngleL1  <- ifelse(is.na(StationCodeCurrent4$BankAngleL1),  "", StationCodeCurrent4$BankAngleL1)
StationCodeCurrent4$BankAngleL2  <- ifelse(is.na(StationCodeCurrent4$BankAngleL2),  "", StationCodeCurrent4$BankAngleL2)
StationCodeCurrent4$BankAngleL3  <- ifelse(is.na(StationCodeCurrent4$BankAngleL3),  "", StationCodeCurrent4$BankAngleL3)
StationCodeCurrent4$BankAngleR1  <- ifelse(is.na(StationCodeCurrent4$BankAngleR1),  "", StationCodeCurrent4$BankAngleR1)
StationCodeCurrent4$BankAngleR2  <- ifelse(is.na(StationCodeCurrent4$BankAngleR2),  "", StationCodeCurrent4$BankAngleR2)
StationCodeCurrent4$BankAngleR3  <- ifelse(is.na(StationCodeCurrent4$BankAngleR3),  "", StationCodeCurrent4$BankAngleR3)
#
StationCodeCurrent4$ArmoringPotential  <- ifelse(is.na(StationCodeCurrent4$ArmoringPotential),  "", StationCodeCurrent4$ArmoringPotential)
StationCodeCurrent4$GradeControl       <- ifelse(is.na(StationCodeCurrent4$GradeControl),       "", StationCodeCurrent4$GradeControl)
#
StationCodeCurrent4$LateralSusceptibilityL       <- ifelse(is.na(StationCodeCurrent4$LateralSusceptibilityL),       "", StationCodeCurrent4$LateralSusceptibilityL)
StationCodeCurrent4$LateralSusceptibilityR       <- ifelse(is.na(StationCodeCurrent4$LateralSusceptibilityR),       "", StationCodeCurrent4$LateralSusceptibilityR)
#
StationCodeCurrent4$MassRiskThreshL1  <- ifelse(is.na(StationCodeCurrent4$MassRiskThreshL1),  "", StationCodeCurrent4$MassRiskThreshL1)
StationCodeCurrent4$MassRiskThreshL2  <- ifelse(is.na(StationCodeCurrent4$MassRiskThreshL2),  "", StationCodeCurrent4$MassRiskThreshL2)
StationCodeCurrent4$MassRiskThreshL3  <- ifelse(is.na(StationCodeCurrent4$MassRiskThreshL3),  "", StationCodeCurrent4$MassRiskThreshL3)
StationCodeCurrent4$MassRiskThreshR1  <- ifelse(is.na(StationCodeCurrent4$MassRiskThreshR1),  "", StationCodeCurrent4$MassRiskThreshR1)
StationCodeCurrent4$MassRiskThreshR2  <- ifelse(is.na(StationCodeCurrent4$MassRiskThreshR2),  "", StationCodeCurrent4$MassRiskThreshR2)
StationCodeCurrent4$MassRiskThreshR3  <- ifelse(is.na(StationCodeCurrent4$MassRiskThreshR3),  "", StationCodeCurrent4$MassRiskThreshR3)
#
StationCodeCurrent4$MassSusceptL1  <- ifelse(is.na(StationCodeCurrent4$MassSusceptL1),  "", StationCodeCurrent4$MassSusceptL1)
StationCodeCurrent4$MassSusceptL2  <- ifelse(is.na(StationCodeCurrent4$MassSusceptL2),  "", StationCodeCurrent4$MassSusceptL2)
StationCodeCurrent4$MassSusceptL3  <- ifelse(is.na(StationCodeCurrent4$MassSusceptL3),  "", StationCodeCurrent4$MassSusceptL3)
StationCodeCurrent4$MassSusceptR1  <- ifelse(is.na(StationCodeCurrent4$MassSusceptR1),  "", StationCodeCurrent4$MassSusceptR1)
StationCodeCurrent4$MassSusceptR2  <- ifelse(is.na(StationCodeCurrent4$MassSusceptR2),  "", StationCodeCurrent4$MassSusceptR2)
StationCodeCurrent4$MassSusceptR3  <- ifelse(is.na(StationCodeCurrent4$MassSusceptR3),  "", StationCodeCurrent4$MassSusceptR3)

#write.csv(StationCodeCurrent4, file="Z:/SMCStreamMonitoringProgram/Data/2018_Data/Hydromod/Hydromod 2018 part2_Vertical and Lateral Susceptibility.csv")
