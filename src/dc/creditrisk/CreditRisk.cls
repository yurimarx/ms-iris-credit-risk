Class dc.creditrisk.CreditRisk Extends (%Persistent, %JSON.Adaptor)
{

Property CreditRiskId As %Integer [ Calculated, SqlComputeCode = { set {*}={%%ID}}, SqlComputed ];

Property Age As %Integer;

Property Sex As %String;

Property Job As %Integer;

Property Housing As %String;

Property SavingAccounts As %String;

Property CheckingAccount As %String;

Property CreditAmount As %Integer;

Property Duration As %Integer;

Property Purpose As %String;

Property CreditRisk As %Integer;

Storage Default
{
<Data name="CreditRiskDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Age</Value>
</Value>
<Value name="3">
<Value>Sex</Value>
</Value>
<Value name="4">
<Value>Job</Value>
</Value>
<Value name="5">
<Value>Housing</Value>
</Value>
<Value name="6">
<Value>SavingAccounts</Value>
</Value>
<Value name="7">
<Value>CheckingAccount</Value>
</Value>
<Value name="8">
<Value>CreditAmount</Value>
</Value>
<Value name="9">
<Value>Duration</Value>
</Value>
<Value name="10">
<Value>Purpose</Value>
</Value>
<Value name="11">
<Value>CreditRisk</Value>
</Value>
</Data>
<DataLocation>^dc.creditrisk.CreditRiskD</DataLocation>
<DefaultData>CreditRiskDefaultData</DefaultData>
<IdLocation>^dc.creditrisk.CreditRiskD</IdLocation>
<IndexLocation>^dc.creditrisk.CreditRiskI</IndexLocation>
<StreamLocation>^dc.creditrisk.CreditRiskS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
