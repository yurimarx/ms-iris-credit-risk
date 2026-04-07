# Application Documentation: Credit Risk

## Overview
This application is a microservice developed on the **InterSystems IRIS** platform aimed at managing and predicting customer credit risks. It exposes a RESTful API for CRUD operations (Create, Read, Update, Delete) and a specific Artificial Intelligence/Machine Learning endpoint that evaluates credit risk using IRIS's **IntegratedML**. Additionally, the system features integration with **Apache Kafka** via the interoperability engine (Ensemble/IRIS Interoperability) for asynchronous messaging.

## Architecture and Classes
The application follows a well-defined architecture with separation of concerns (API, Service/Business, and Integration Processes).

### 1. `dc.creditrisk.CreditRiskAPI` (API / REST Layer)
Class that extends `%CSP.REST` to expose HTTP endpoints.
- **Routing (`UrlMap`)**: Defines the routes for managing credit risk requests (GET, POST, PUT, DELETE) and prediction (POST `/predict`).
- **Automatic Documentation**: Has a `/_spec` endpoint that dynamically generates the Swagger/OpenAPI specification of the REST API.
- **Error Handling**: Encapsulates service calls and standardizes error responses in JSON (e.g., 400, 404, 500 status codes).

### 2. `dc.creditrisk.CreditRiskService` (Service / Business Layer)
Class responsible for encapsulating all business logic, database access, and Machine Learning operations.
- **CRUD**: Contains the `Create`, `GetById`, `GetAll`, `Update`, and `Delete` methods, which directly manipulate the persistent model class (`dc.creditrisk.CreditRisk`).
- **Machine Learning (`Predict`)**: Executes an SQL query using native IRIS AI functions (`PREDICT` and `PROBABILITY`) applying the predefined `CreditRiskModel`. It evaluates variables such as Age, Sex, Job, Housing, and Accounts to determine if the customer has "Good credit" or "Poor credit", also returning the mathematical probability of this prediction.

### 3. `dc.creditrisk.CreditRiskProcess` (Integration / Interoperability Layer)
Class that extends `Ens.BusinessProcess`, integrating data flow into the IRIS interoperability engine.
- **Kafka Messaging**: Upon receiving a prediction request (`OnRequest`), the class processes the JSON payload by calling the Service's `Predict` method, then asynchronously builds and sends the response to an Apache Kafka topic named `CreditRiskOutTopic`.
- **Orchestration**: Delegates the actual sending to an outbound operation (`TargetConfigName` with default value `CreditRiskOperation`).

## Infrastructure and Containers (Devcontainer)
The development environment was containerized to facilitate configuration, integration, and deployment, ensuring a clean and reproducible dev environment.

### Devcontainer Configuration (`.devcontainer/devcontainer.json`)
- **Docker Compose**: The environment is spun up using the `iris` service referenced in a parent `docker-compose.yml` file. This implies the environment runs alongside other services (like Kafka and Zookeeper).
- **InterSystems Server Manager**: Pre-configured to connect VS Code to the IRIS instance in the container via port `52773` using administrative credentials (SuperUser).
- **Native Python Support**: The instance defines the default Python interpreter pointing to the embedded Python in InterSystems IRIS (`/usr/irissys/bin/irispython`).
- **Included IDE Extensions**: Includes `intersystems-community.vscode-objectscript` and `intersystems.language-server` for ObjectScript support, `intersystems-community.servermanager` for database connections, and official Microsoft Python and Docker extensions.

## Main Execution Flow (Risk Prediction)
1. The client makes a **POST** request to the `/api/creditrisk/predict` route with user financial data in the body.
2. The **`CreditRiskAPI`** class intercepts the request, validates the body, and invokes the **`CreditRiskService`**.
3. The **`CreditRiskService`** executes the SQL statement with the **IntegratedML** engine (`PREDICT(CreditRiskModel)`).
4. The result determines the probability of credit risk (1 - Good, 0 - Poor).
5. *(Alternative Interoperability Flow)*: If the data enters via the BPL/Business Process through **`CreditRiskProcess`**, the same prediction is made, but the final result is injected as an event into **Kafka** via the `CreditRiskOutTopic` utilizing the `EnsLib.Kafka.Message` class, allowing other microservices in the ecosystem to react to the credit decision.