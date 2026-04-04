Class dc.creditrisk.FileLoader
{

/// Loads credit_risk_data.csv
ClassMethod LoadCreditRiskData() As %Status
{
    Set sc = $$$OK
    zw ##class(community.csvgen).Generate("/tmp/credit_risk_data.csv", ",", "dc.creditrisk.CreditRisk")
    Return sc
}

}
