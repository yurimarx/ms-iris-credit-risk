Class dc.creditrisk.CreditRiskAPI Extends %CSP.REST
{

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <Route Url="/creditrisk/:id" Method="GET" Call="GetById"/>
    <Route Url="/creditrisk" Method="GET" Call="GetAll"/>
    <Route Url="/creditrisk" Method="POST" Call="Create"/>
    <Route Url="/creditrisk/:id" Method="PUT" Call="Update"/>
    <Route Url="/creditrisk/:id" Method="DELETE" Call="Delete"/>
    <Route Url="/creditrisk/predict" Method="POST" Call="Predict"/>
</Routes>
}

Parameter CHARSET = "utf-8";

Parameter CONTENTTYPE = "application/json";

Parameter HandleCorsRequest = 1;

/// Implements GET /creditrisk
ClassMethod GetAll() As %Status
{
    Set sc = $$$OK
    Try {
        Set sc = ##class(dc.creditrisk.CreditRiskService).GetAll(.jsonArray)
        If $$$ISERR(sc) {
            Set %response.Status = 500
            Write { "error": { "summary": "Failed to get all", "details": ($System.Status.GetErrorText(sc)) } }.%ToJSON()
            Quit
        }
        
        Write jsonArray.%ToJSON()
        
    } Catch ex {
        Set sc = ex.AsStatus()
        Set %response.Status = 500 // Internal Server Error
        Write { "error": { "summary": (ex.Name), "details": ($System.Status.GetErrorText(sc)) } }.%ToJSON()
    }
    Return sc
}

ClassMethod GetById(id As %Integer) As %Status
{
    Set sc = $$$OK
    Try {
        
        If '##class(dc.creditrisk.CreditRiskService).Exists(id) {
            Set %response.Status = 404 // Not Found
            Return 1
        }
        
        Set sc = ##class(dc.creditrisk.CreditRiskService).GetById(id, .obj)
        If $$$ISERR(sc) {
            Set %response.Status = 500
            Return 1
        }
        
        Do obj.%JSONExport()
        Return 1
        
    } Catch ex {
        Set sc = ex.AsStatus()
        Set %response.Status = 500 // Internal Server Error
        Write { "error": { "summary": (ex.Name), "details": ($System.Status.GetErrorText(sc)) } }.%ToJSON()
    }
    Return sc
}

/// Implements POST /creditrisk/predict
ClassMethod Predict() As %Status
{
    
    Set sc = $$$OK

    Try {

      If '$IsObject(%request.Content) || (%request.Content.Size = 0) {
          Set %response.Status = 400 // Bad Request
          Write { "error": { "summary": "Bad Request", "details": "Request body is empty" } }.%ToJSON()
          Return sc
      }
      
      Set data = {}.%FromJSON(%request.Content)
      
      Set sc = ##class(dc.creditrisk.CreditRiskService).Predict(data, .responseObj)
      If $$$ISERR(sc) {
          Set %response.Status = 500
          Write { "error": { "summary": "Prediction failed", "details": ($System.Status.GetErrorText(sc)) } }.%ToJSON()
          Return sc
      }
      
      Write responseObj.%ToJSON()
    } Catch ex {
        Set sc = ex.AsStatus()
        Set %response.Status = 500 // Internal Server Error
        Write { "error": { "summary": (ex.Name), "details": ($System.Status.GetErrorText(sc)) } }.%ToJSON()
    }

    Return sc
}

/// Implements POST /creditrisk
ClassMethod Create() As %Status
{
    Set sc = $$$OK
    Try {
        If '$IsObject(%request.Content) || (%request.Content.Size = 0) {
            Set %response.Status = 400 // Bad Request
            Write { "error": { "summary": "Bad Request", "details": "Request body is empty" } }.%ToJSON()
            Return sc
        }
        
        // Gets the JSON from the request body
        Set json = {}.%FromJSON(%request.Content)
        
        Set sc = ##class(dc.creditrisk.CreditRiskService).Create(json, .newId)
        If $$$ISERR(sc) {
            Set %response.Status = 400 // Bad Request
            Write { "error": { "summary": "Failed to create", "details": ($System.Status.GetErrorText(sc)) } }.%ToJSON()
            Return sc
        }
        
        Set %response.Status = 201 // Created
        Set %response.Headers("Location") = %request.URL _ "/" _ newId
        Write { "id": (newId) }.%ToJSON()
        
    } Catch ex {
        Set sc = ex.AsStatus()
        Set %response.Status = 500 // Internal Server Error
        Write { "error": { "summary": (ex.Name), "details": ($System.Status.GetErrorText(sc)) } }.%ToJSON()
    }
    Return sc
}

/// Implements PUT /creditrisk/:id
ClassMethod Update(pId As %String) As %Status
{
    Set sc = $$$OK
    Try {
        If '##class(dc.creditrisk.CreditRiskService).Exists(pId) {
            Set %response.Status = 404 // Not Found
            Return sc
        }
        
        If '$IsObject(%request.Content) || (%request.Content.Size = 0) {
            Set %response.Status = 400 // Bad Request
            Write { "error": { "summary": "Bad Request", "details": "Request body is empty" } }.%ToJSON()
            Return sc
        }
        
        Set json = {}.%FromJSON(%request.Content)
        
        Set sc = ##class(dc.creditrisk.CreditRiskService).Update(pId, json)
        If $$$ISERR(sc) {
            Set %response.Status = 400 // Bad Request
            Write { "error": { "summary": "Failed to update", "details": ($System.Status.GetErrorText(sc)) } }.%ToJSON()
            Return sc
        }
        
        Set %response.Status = 200 // OK
        
    } Catch ex {
        Set sc = ex.AsStatus()
        Set %response.Status = 500 // Internal Server Error
        Write { "error": { "summary": (ex.Name), "details": ($System.Status.GetErrorText(sc)) } }.%ToJSON()
    }
    Return sc
}

/// Implements DELETE /creditrisk/:id
ClassMethod Delete(pId As %String) As %Status
{
    Set sc = $$$OK
    Try {
        If '##class(dc.creditrisk.CreditRiskService).Exists(pId) {
            Set %response.Status = 404 // Not Found
            Return sc
        }
        
        Set sc = ##class(dc.creditrisk.CreditRiskService).Delete(pId)
        If $$$ISERR(sc) {
            Set %response.Status = 500 // Internal Error
            Return sc
        }
        
        Set %response.Status = 204 // No Content
        
    } Catch ex {
        Set sc = ex.AsStatus()
        Set %response.Status = 500 // Internal Server Error
        Write { "error": { "summary": (ex.Name), "details": ($System.Status.GetErrorText(sc)) } }.%ToJSON()
    }
    Return sc
}

}
