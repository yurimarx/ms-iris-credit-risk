Class dc.creditrisk.KafkaPredictService Extends Ens.BusinessService
{

Parameter ADAPTER = "EnsLib.Kafka.InboundAdapter";

Property TargetConfigName As Ens.DataType.ConfigName [ InitialExpression = "CreditRiskProcess" ];

Parameter SETTINGS = "TargetConfigName:Basic:selector?context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";

Method OnProcessInput(pInput As EnsLib.Kafka.Message, Output pOutput As Ens.StringResponse) As %Status
{
    Set sc = $$$OK
    Try {
        // Extracts the Kafka message payload to a persistent object
        Set request = ##class(Ens.StringRequest).%New()
        Set request.StringValue = pInput.Value
        
        // Sends asynchronously to the Business Process
        Do ..SendRequestAsync(..TargetConfigName, request)

        Set pOutput = ##class(Ens.StringResponse).%New()
        Set pOutput.StringValue = "OK"
        
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Return sc
}

}
