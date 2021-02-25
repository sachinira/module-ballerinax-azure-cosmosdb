// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerinax/azure_cosmosdb as cosmosdb;
import ballerina/log;
import ballerina/os;

cosmosdb:Configuration config = {
    baseUrl: os:getEnv("BASE_URL"),
    masterOrResourceToken: os:getEnv("MASTER_OR_RESOURCE_TOKEN")
};

cosmosdb:DataPlaneClient azureCosmosClient = new (config);

public function main() {
    string databaseId = "my_database";
    string containerId = "my_container";

    log:print("Query1 - Select all from the container where gender 0");
    string selectAllQuery = string `SELECT * FROM ${containerId.toString()} f WHERE f.gender = ${0}`;
    int maxItemCount = 10;

    cosmosdb:ResourceQueryOptions options = {partitionKey : 0, enableCrossPartition: false};
    var result = azureCosmosClient->queryDocuments(databaseId, containerId, selectAllQuery, options, maxItemCount);
    if (result is error) {
        log:printError(result.message());
    }
    if (result is stream<cosmosdb:Document>) {
        error? e = result.forEach(function (cosmosdb:Document document) {
            log:print(document.toString());
        });
        log:print("Success!");
    }
}
