# PLP_Dementia_Prediction

<img src="https://img.shields.io/badge/Study%20Status-Repo%20Created-lightgray.svg" alt="Study Status: Repo Created"/>

-   Analytics use case(s): Clinical application
-   Study type: Patient level Prediction
-   Tags: Taiwan chapter
-   Study lead: Phan Thanh Phuc, Alex Phung-Anh Nguyen, Maz Solie, Jason Hsu
-   Study lead forums tag: [**[Lead tag]**](https://forums.ohdsi.org/u/%5BLead%20tag%5D)
-   Study start date: March 2024
-   Study end date: **-**
-   Protocol: **-**
-   Publications: **-**
-   Results explorer: <http://35.229.190.150/shiny/dementia/>

# Introduction

This study aims to develop a personalized predictive model, utilizing artificial intelligence, to assess the 5-year dementia risk among patients with chronic diseases who are prescribed medications.

# How to run

1.  Install the packages

    ``` R
    install.packages("remotes")
    remotes::install_github("ohdsi/Strategus", ref = "main", force = T)
    remotes::install_github("ohdsi/CohortGenerator", ref = "v0.9.0", force = T)
    remotes::install_github("ohdsi/CohortDiagnostics", ref = "v3.2.5", force = T)
    remotes::install_github("ohdsi/PatientLevelPrediction", ref = "v6.3.6", force = TRUE)
    remotes::install_github("ohdsi/ROhdsiWebApi", ref = "main", force = TRUE)
    ```

2.  Execute the strategustoCreateSpec.R to create the Analysis Specification

3.  Execute strategusCodetoRun to run the Patient-prediction-level

4.  Upload the result

5.  See the result on the Shinyapps

# 
