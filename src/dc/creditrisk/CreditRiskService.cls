Class dc.creditrisk.CreditRiskService
{

ClassMethod Exists(pId As %String) As %Boolean
{
    Return ##class(dc.creditrisk.CreditRisk).%ExistsId(pId)
}

ClassMethod GetAll(Output pArray As %DynamicArray) As %Status
{
    Set sc = $$$OK
    Try {
        Set pArray = []
        Set stmt = ##class(%SQL.Statement).%New()
        Set sc = stmt.%Prepare("SELECT ID FROM dc_creditrisk.CreditRisk")
        If $$$ISERR(sc) Quit
        
        Set rs = stmt.%Execute()
        If rs.%SQLCODE < 0 {
            Set sc = $$$ERROR($$$SQLError, rs.%SQLCODE, rs.%Message)
            Quit
        }
        
        While rs.%Next() {
            Set obj = ##class(dc.creditrisk.CreditRisk).%OpenId(rs.%Get("ID"))
            If $IsObject(obj) {
                Do obj.%JSONExportToString(.jsonString)
                Set jsonObj = {}.%FromJSON(jsonString)
                Set jsonObj.Id = obj.%Id()
                Do pArray.%Push(jsonObj)
            }
        }
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Return sc
}

ClassMethod GetById(pId As %Integer, Output pObj As dc.creditrisk.CreditRisk) As %Status
{
    Set sc = $$$OK
    Try {
        Set pObj = ##class(dc.creditrisk.CreditRisk).%OpenId(pId)
        If '$IsObject(pObj) {
            Set sc = $$$ERROR($$$GeneralError, "Object not found")
        }
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Return sc
}

ClassMethod Predict(data As %DynamicObject, Output pResponse As %DynamicObject) As %Status
{
    Set sc = $$$OK
    Try {
        Set sql = "SELECT PREDICT(CreditRiskModel) AS RiskPrediction, "_
                  "       PROBABILITY(CreditRiskModel FOR 1) AS RiskProbability "_
                  "  FROM (SELECT ? As Age, ? As Sex, ? As Job, ? As Housing, ? As SavingAccounts, "_
                  "               ? As CheckingAccount, ? As CreditAmount, ? As Duration, ? As Purpose) "
        
        Set tStatement = ##class(%SQL.Statement).%New()
        Set sc = tStatement.%Prepare(sql)
        If $$$ISERR(sc) Quit
        
        Set rset = tStatement.%Execute(data.Age, data.Sex, data.Job, data.Housing, data.SavingAccounts, 
                                       data.CheckingAccount, data.CreditAmount, data.Duration, data.Purpose)
        Do rset.%Next()

        Set pResponse = {}
        Set pResponse.Age = data.Age
        Set pResponse.Sex = data.Sex
        Set pResponse.Job = data.Job
        Set pResponse.Housing = data.Housing
        Set pResponse.SavingAccounts = data.SavingAccounts
        Set pResponse.CheckingAccount = data.CheckingAccount
        Set pResponse.CreditAmount = data.CreditAmount
        Set pResponse.Duration = data.Duration
        Set pResponse.Purpose = data.Purpose
        Set pResponse.RiskPrediction = rset.RiskPrediction
        Set pResponse.RiskProbability = rset.RiskProbability
        If (pResponse.RiskPrediction = "1") {
            Set pResponse.RiskAnalisysPrediction = "Good credit"
        } Else {
            Set pResponse.RiskAnalisysPrediction = "Poor credit"
        }
        
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Return sc
}

ClassMethod Create(data As %DynamicObject, Output pId As %String) As %Status
{
    Set sc = $$$OK
    Try {
        Set obj = ##class(dc.creditrisk.CreditRisk).%New()
        Set sc = obj.%JSONImport(data)
        If $$$ISERR(sc) Quit
        
        Set sc = obj.%Save()
        If $$$ISERR(sc) Quit
        
        Set pId = obj.%Id()
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Return sc
}

ClassMethod Update(pId As %String, data As %DynamicObject) As %Status
{
    Set sc = $$$OK
    Try {
        Set obj = ##class(dc.creditrisk.CreditRisk).%OpenId(pId)
        Set sc = obj.%JSONImport(data)
        If $$$ISERR(sc) Quit
        
        Set sc = obj.%Save()
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Return sc
}

ClassMethod Delete(pId As %String) As %Status
{
    Return ##class(dc.creditrisk.CreditRisk).%DeleteId(pId)
}

}
