'use strict';

const AWS = require('aws-sdk');
const https = require('https');
const ddb = new AWS.DynamoDB.DocumentClient();
// AWS.config.update({region: 'ap-southeast-1'});

exports.handler = async (event, context) => {

    // console.log(JSON.stringify(event, null, '-'));

    let customerId = event.request.userAttributes["custom:customerId"];
    if (typeof customerId === 'undefined' || !customerId) {
        console.log("User: "+event.userName+" has not a valid Mambu customerId.");
        throw "User: "+event.userName+" has not a valid Mambu customerId.";
    }

    let dataString = '';
    const tableName = 'bankstart_dev_accounts';

    const serviceName = 'deposits?accountHolderType=CLIENT&accountState=ACTIVE&accountHolderId=' + customerId
    const options = {
        host: 'gftit.sandbox.mambu.com',
        port: 443,
        path: '/api/'+serviceName,
        headers: {
            'Authorization': 'Basic xxx',
            'Accept': 'application/vnd.mambu.v2+json',
            'Content-Type': 'application/json'
        }
    };

    const mambu = await new Promise((resolve, reject) => {
        const req = https.get(options, function(res) {
            res.on('data', chunk => {
                dataString += chunk;
            });
            res.on('end', () => {
                resolve(JSON.parse(dataString));
            });
        });

        req.on('error', (e) => {
            reject('Something went wrong!');
        });
    });

    //25 is as many as you can write in one time
    let itemsArray = [];
    console.log("Syncing " + mambu.length + " Deposit Accounts");
    mambu.forEach((account, index) => {
        itemsArray.push({
            PutRequest: {
                Item: {
                    "id": account.id,
                    "alias": "LAMBDA",
                    "balance": String(account.balances.availableBalance),
                    "currency": account.currencyCode,
                    "customerId": customerId,
                    "createdOn": account.creationDate,
                    "name": account.name,
                    "number": account.encodedKey,
                    "status": account.accountState,
                    "type": account.accountType
                }
            }
        });

    });

    let params = {
        RequestItems: {
            [tableName]: itemsArray
        }
    };

    // Send post authentication data to Cloudwatch logs
    console.log ("Authentication successful for user: " + event.userName + "with customerId: " + customerId);

    await ddb.batchWrite(params).promise().then(data => {
        console.log(data);
    }).catch(err => [err]);

    // Return to Amazon Cognito
    return event;
};
