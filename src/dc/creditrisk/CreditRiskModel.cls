Class dc.creditrisk.CreditRiskModel
{

ClassMethod BuildAndTrain() As %Status
{
    Set sc = $$$OK
    
    Try {
        Set stmt = ##class(%SQL.Statement).%New()
        
        Set dropSQL = "DROP MODEL CreditRiskModel"
        Do stmt.%Prepare(dropSQL)
        Do stmt.%Execute() 
        
        Write !, "Creating the model definition..."
        Set createSQL = "CREATE MODEL CreditRiskModel PREDICTING (CreditRisk) FROM "_
            "(SELECT Age, CheckingAccount, CreditAmount, CreditRisk, Duration, Housing, "_
            "Job, Purpose, SavingAccounts, Sex FROM dc_creditrisk.CreditRisk)"
        Set sc = stmt.%Prepare(createSQL)
        If $$$ISERR(sc) Quit
        
        Set result = stmt.%Execute()
        If result.%SQLCODE < 0 {
            Set sc = $$$ERROR($$$SQLError, result.%SQLCODE, result.%Message)
            Quit
        }
        Write !, "Model created successfully!"
        
        Write !, "Training the model(This may take a few moments)..."
        Set trainSQL = "TRAIN MODEL CreditRiskModel"
        Set sc = stmt.%Prepare(trainSQL)
        If $$$ISERR(sc) Quit
        
        Set result = stmt.%Execute()
        If result.%SQLCODE < 0 {
            Set sc = $$$ERROR($$$SQLError, result.%SQLCODE, result.%Message)
            Quit
        }
        Write !, "CreditRiskModel model trained successfully!"
        
    } Catch ex {
        Set sc = ex.AsStatus()
        Write !, "Exception occurred: ", $System.Status.GetErrorText(sc)
    }
    
    Return sc
}

ClassMethod TestPredictions() As %Status
{
    Set sc = $$$OK
    Try {
        Set query = "SELECT TOP 5 CreditRisk AS CurrentRisk, PREDICT(CreditRiskModel) AS RiskPrediction, PROBABILITY(CreditRiskModel FOR 1) AS RiskProbability FROM dc_creditrisk.CreditRisk"
        Set stmt = ##class(%SQL.Statement).%New()
        Set sc = stmt.%Prepare(query)
        If $$$ISERR(sc) Quit
        
        Set result = stmt.%Execute()
        
        Write !, "Prediction Results (Sample):"
        Write !, "CurrentRisk ", ?12, "RiskPrediction", ?28, "RiskProbability"
        Write !, "------------------------------------------------------"
        
        While result.%Next() {
            Write !, result.%Get("CurrentRisk"), ?12, result.%Get("RiskPrediction"), ?28, $FNUMBER(result.%Get("RiskProbability"), "", 4)
        }
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Return sc
}

}
