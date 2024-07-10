PatientLevelPredictionModule 0.3.0
=======================
- Using renv project profiles to manage core packages required for module execution vs. those that are needed for development purposes.

PatientLevelPredictionModule 0.2.1
=======================

- Added xgboost to module

PatientLevelPredictionModule 0.2.0
=======================

- Updated module to use HADES wide lock file and updated to use renv v1.0.2
- Added functions and tests for creating the results data model for use by Strategus upload functionality
- Added additional GitHub Action tests to unit test the module functionality on HADES supported R version (v4.2.3) and the latest release of R

PatientLevelPredictionModule 0.1.0
=======================

- Fix mismatch between renv dependency in lock file (0.17.0) and renv/activate.R script (still using 0.15.1)

PatientLevelPredictionModule 0.0.8
=======================

- Updating renv to use PatientLevelPrediction 6.3.1

PatientLevelPredictionModule 0.0.7
=======================

- Removed results being zipped 


PatientLevelPredictionModule 0.0.6
=======================

- Fix bug with cohorts as features not getting schema and table name set

PatientLevelPredictionModule 0.0.1
=======================

- Initial module
