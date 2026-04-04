Class dc.creditrisk.CreditRiskProcess Extends Ens.BusinessProcess
{

Property TargetConfigName As Ens.DataType.ConfigName [ InitialExpression = "CreditRiskOperation" ];

Parameter SETTINGS = "TargetConfigName:Basic:selector?context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";

Method OnRequest(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
    Set sc = $$$OK
    Try {
        Set data = {}.%FromJSON(pRequest.StringValue)
        
        Set sc = ##class(dc.creditrisk.CreditRiskService).Predict(data, .responseObj)
        If $$$ISERR(sc) Quit
        
        Set request = ##class(EnsLib.Kafka.Message).%New()
        Set request.topic = "CreditRiskOutTopic"
        Set request.value = responseObj.%ToJSON()
        Set request.key = "iris"
        
        Set sc = ..SendRequestAsync(..TargetConfigName, request, 0)
        If $$$ISERR(sc) Quit

        Set pResponse = ##class(Ens.StringResponse).%New()
        Set pResponse.StringValue = "OK"
        
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Return sc
}

Storage Default
{
<Data name="CreditRiskProcessDefaultData">
<Subscript>"CreditRiskProcess"</Subscript>
<Value name="1">
<Value>TargetConfigName</Value>
</Value>
</Data>
<DefaultData>CreditRiskProcessDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
