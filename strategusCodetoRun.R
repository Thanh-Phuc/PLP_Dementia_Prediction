## Running the study
#remotes::install_github('ohdsi/Strategus', ref='main', force=T)
library(Strategus)

##=========== START OF INPUTS ==========

# Add your json file location, connection to OMOP CDM data settings
options(renv.config.repos.override = c("https://cran.r-project.org/"))

connectionDetailsReference <- "your connectionDetailsReference"
workDatabaseSchema <- 'your workDatabaseSchema'
cdmDatabaseSchema <- 'your cdmDatabaseSchema'

# use absolute path
outputLocation <- "~/aIDem/output"
minCellCount <- 3
cohortTableName <- "aIDem"

# the keyring entry should correspond to what you selected in KeyringSetup.R
connectionDetails = DatabaseConnector::createConnectionDetails(
  dbms = keyring::key_get("dbms", keyring = "dem"),
  connectionString = keyring::key_get("connectionString", keyring = "dem"),
  user = keyring::key_get("username", keyring = "dem"),
  password = keyring::key_get("password", keyring = "dem"),
  pathToDriver = keyring::key_get("pathToDriver", keyring = "dem")
)

##=========== END OF INPUTS ==========

# load the json spec
analysisSpecifications <- ParallelLogger::loadSettingsFromJson('specs.json')

storeConnectionDetails(
  connectionDetails = connectionDetails,
  connectionDetailsReference = connectionDetailsReference,
  keyringName='dem'
)

executionSettings <- createCdmExecutionSettings(
  connectionDetailsReference = connectionDetailsReference,
  workDatabaseSchema = workDatabaseSchema,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortTableNames = CohortGenerator::getCohortTableNames(cohortTable = cohortTableName),
  workFolder = file.path(outputLocation, "strategusWork"),
  resultsFolder = file.path(outputLocation, "strategusOutput"),
  minCellCount = minCellCount
)

# Note: this environmental variable should be set once for each compute node
Sys.setenv("INSTANTIATED_MODULES_FOLDER" = file.path(outputLocation, "StrategusInstantiatedModules"))

Strategus::ensureAllModulesInstantiated(analysisSpecifications = analysisSpecifications)

execute(
  analysisSpecifications = analysisSpecifications,
  executionSettings = executionSettings,
  executionScriptFolder = file.path(outputLocation, "strategusExecution")
)
