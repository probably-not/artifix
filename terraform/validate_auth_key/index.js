import cf from "cloudfront";

const response401 = {
  statusCode: 401,
  statusDescription: "Unauthorized",
};

const loggingEnabled = ${logging_enabled};
const authEnabled = ${has_auth_keys};
const kvsId = "${keyvaluestore_id}";

async function handler(event) {
  const request = event.request;
  const headers = request.headers;

  if (!authEnabled) {
    log("Auth is not enabled")
    return request
  }

  const authKey = headers["authorization"]
    ? headers["authorization"].value
    : undefined;
  if (!authKey) {
    log("No auth key defined in headers");
    return response401;
  }

  const authKeyValue = await getAuthKeyExists();
  if (!authKeyValue) {
    return response401;
  }

  log("Valid Auth Key");
  return request;
}

async function getAuthKeyExists(authKey) {
  try {
    const kvsHandle = cf.kvs();
    return await kvsHandle.exists(authKey);
  } catch (err) {
    log(`Error reading value for key`, { authKey, err });
    return null;
  }
}

function log(message, attrs) {
  attrs = attrs || {};
  if (loggingEnabled) {
      console.log(message, attrs);
  }
}
