Class dc.creditrisk.CreditRiskProduction Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="dc.creditrisk.CreditRiskProduction" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="CreditRiskPredictService" Category="" ClassName="dc.creditrisk.CreditRiskPredictService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="GroupID">iris</Setting>
    <Setting Target="Adapter" Name="Topic">CreditRiskInTopic</Setting>
    <Setting Target="Adapter" Name="Servers">kafka:9092</Setting>
  </Item>
  <Item Name="CreditRiskOperation" Category="" ClassName="EnsLib.Kafka.Operation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="ClientID">iris</Setting>
    <Setting Target="Adapter" Name="Servers">kafka:9092</Setting>
  </Item>
  <Item Name="CreditRiskProcess" Category="" ClassName="dc.creditrisk.CreditRiskProcess" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
