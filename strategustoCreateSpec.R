# module	version	remote_repo	remote_username	module_type	main_package	main_package_tag
# CharacterizationModule	v0.6.0	github.com	OHDSI	cdm	Characterization	v0.2.0
# CohortDiagnosticsModule	v0.2.0	github.com	OHDSI	cdm	CohortDiagnostics	v3.2.5
# CohortGeneratorModule	v0.4.1	github.com	OHDSI	cdm	CohortGenerator	v0.9.0
# CohortIncidenceModule	v0.4.1	github.com	OHDSI	cdm	CohortIncidence	v3.3.0
# CohortMethodModule	v0.3.1	github.com	OHDSI	cdm	CohortMethod	v5.3.0
# PatientLevelPredictionModule	v0.3.0	github.com	OHDSI	cdm	PatientLevelPrediction	v6.3.6
# SelfControlledCaseSeriesModule	v0.5.0	github.com	OHDSI	cdm	SelfControlledCaseSeries	v5.2.0
# EvidenceSynthesisModule	v0.6.1	github.com	OHDSI	results	EvidenceSynthesis	v0.5.0

install.packages("remotes")
remotes::install_github("ohdsi/Strategus", ref = "main", force = T)
remotes::install_github("ohdsi/CohortGenerator", ref = "v0.9.0", force = T)
remotes::install_github("ohdsi/CohortDiagnostics", ref = "v3.2.5", force = T)
remotes::install_github("ohdsi/PatientLevelPrediction", ref = "v6.3.6", force = TRUE)
remotes::install_github("ohdsi/ROhdsiWebApi", ref = "main", force = TRUE)


library(Strategus)
library(CohortGenerator)
library(CohortDiagnostics)
library(PatientLevelPrediction)
library(dplyr)


targetIds <- c(242,262,267)
outcomeIds <- c(243,260)
# first define your ATLAS webapi:
baseUrl <- 'http://10.164.1.154:8080/WebAPI'

# now we extract the two cohorts
# note: if you used cohorts as predictors you need to add them here as well

cohortDefinitionset <- ROhdsiWebApi::exportCohortDefinitionSet(
  baseUrl = baseUrl,
  cohortIds = c(targetIds,outcomeIds),
  generateStats = T # set this to T if you want stats
)

# here we modify the cohort into the format for Strategus
cohortDefinitionset<-system.file("extdata", "CohorttoCreate.csv", package = "aIDem") |>read.csv()
cohortDefinitions <- lapply(1:length(cohortDefinitionset$atlasId), function(i){list(
  cohortId = cohortDefinitionset$cohortId[i],
  cohortName = cohortDefinitionset$cohortName[i],
  cohortDefinition = cohortDefinitionset$json[i]
)})

# source the cohort generator settings function
source("https://raw.githubusercontent.com/OHDSI/CohortGeneratorModule/v0.1.0/SettingsFunctions.R")

cohortGeneratorModuleSpecifications <- createCohortGeneratorModuleSpecifications(
  incremental = TRUE,
  generateStats = TRUE
)

createCohortSharedResource <- function(cohortDefinitionSet) {
  sharedResource <- list(cohortDefinitions = cohortDefinitionSet)
  class(sharedResource) <- c("CohortDefinitionSharedResources", "SharedResources")
  return(sharedResource)
}


# CohortDiagnosticsModule ------------------------------------------------------
source("https://raw.githubusercontent.com/OHDSI/CohortDiagnosticsModule/v0.2.0/SettingsFunctions.R")


cohortDiagnosticsModuleSpecifications <- createCohortDiagnosticsModuleSpecifications(
  runInclusionStatistics = TRUE,
  runIncludedSourceConcepts = TRUE,
  runOrphanConcepts = TRUE,
  runTimeSeries = FALSE,
  runVisitContext = TRUE,
  runBreakdownIndexEvents = TRUE,
  runIncidenceRate = TRUE,
  runCohortRelationship = TRUE,
  runTemporalCohortCharacterization = TRUE,
  minCharacterizationMean = 0.0001,
  temporalCovariateSettings = getDefaultCovariateSettings(),
  incremental = FALSE,
  cohortIds = cohortDefinitionset$cohortId)

# PatientLevelPredictionModule -------------------------------------------------
source("https://raw.githubusercontent.com/OHDSI/PatientLevelPredictionModule/v0.3.0/SettingsFunctions.R")

targetIds <- c(242,262,267)
outcomeIds <- c(243,260)
covariateSettings <- FeatureExtraction::createCovariateSettings(
  useDemographicsGender = T,
  useDemographicsAgeGroup = T, #PLP age group
  useDemographicsIndexMonth = TRUE,
  useDemographicsPriorObservationTime = TRUE,
  useDemographicsPostObservationTime = TRUE,
  useDemographicsTimeInCohort = TRUE,
  useConditionOccurrenceAnyTimePrior = TRUE,
  useConditionOccurrenceLongTerm = TRUE,
  useConditionOccurrenceMediumTerm = TRUE,
  useConditionOccurrenceShortTerm = TRUE,
  useConditionEraAnyTimePrior = TRUE,
  useConditionGroupEraLongTerm = TRUE,
  useConditionGroupEraShortTerm = F,
  useDrugGroupEraLongTerm = TRUE,
  useDrugGroupEraShortTerm = F,
  useDrugGroupEraOverlapping = TRUE,
  useDrugExposureAnyTimePrior = TRUE,
  useDrugExposureLongTerm = TRUE,
  useDrugExposureMediumTerm = TRUE,
  useDrugExposureShortTerm = F,
  useDcsi = TRUE,
  useChads2 = TRUE,
  useChads2Vasc = TRUE,
  useCharlsonIndex = TRUE
)


# List of model settings
modelSettingsList <- list(
  setLassoLogisticRegression(),
  setRandomForest(),
  setGradientBoostingMachine()
)

# Define the common settings
restrictPlpDataSettings <- createRestrictPlpDataSettings()
populationSettings <- createStudyPopulationSettings(
  washoutPeriod = 365,
  firstExposureOnly = FALSE,
  removeSubjectsWithPriorOutcome = T,
  priorOutcomeLookback = 365,
  riskWindowStart = 1,
  riskWindowEnd = 365 * 5,
  startAnchor = 'cohort start',
  endAnchor = 'cohort start',
  minTimeAtRisk = 1,
  requireTimeAtRisk = TRUE,
  includeAllOutcomes = TRUE
)
covariateSettings <- covariateSettings
preprocessSettings <- createPreprocessSettings()
splitSettings <- createDefaultSplitSetting()

# Initialize the modelDesignList

modelDesignList <- list()

# Populate the modelDesignList using a nested loop
for (targetId in targetIds ) {
  for (outcomeId in outcomeIds) {
    for (modelSetting in modelSettingsList)  {
      modelDesignList[[length(modelDesignList) + 1]] <- PatientLevelPrediction::createModelDesign(
        targetId = targetId,
        outcomeId = outcomeId,
        restrictPlpDataSettings = restrictPlpDataSettings,
        populationSettings = populationSettings,
        covariateSettings = covariateSettings,
        featureEngineeringSettings = NULL,
        sampleSettings = NULL,
        preprocessSettings = preprocessSettings,
        modelSettings = modelSetting,
        splitSettings = splitSettings,
        runCovariateSummary = TRUE
      )
    }
  }
}

patientLevelPredictionModuleSpecifications <- createPatientLevelPredictionModuleSpecifications(modelDesignList)


analysisSpecifications <- createEmptyAnalysisSpecificiations() %>%
  addSharedResources(createCohortSharedResource(cohortDefinitions)) %>%
  addModuleSpecifications(cohortGeneratorModuleSpecifications) %>%
 # addModuleSpecifications(cohortDiagnosticsModuleSpecifications) %>%
  addModuleSpecifications(patientLevelPredictionModuleSpecifications)

ParallelLogger::saveSettingsToJson(analysisSpecifications, './specs.json')
