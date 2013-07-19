module brala.minecraft.util;

private {
    import arsd.http : HttpResponse, httpRequest;

    import std.conv : to;
    import std.string : format;
    import std.traits : isUnsigned;
    import std.exception : enforceEx;
    import std.range : ElementEncodingType;
    import j = std.json;

    import brala.exception : YggdrasilException;
}


auto post(string url, j.JSONValue content, string[string] cookies = null) {
    auto hr = httpRequest(
        "POST", url, cast(ubyte[])content.to!string, cookies,
        ["Content-Type: application/json"]
    );

    return hr;
}


YggdrasilException get_exception(HttpResponse response, string f=__FILE__, size_t l=__LINE__) {
    j.JSONValue json;
    try {
        json = j.parseJSON(response.content);
    } catch(j.JSONException e) {
        return new YggdrasilException("Yggdrasil responded with error code %s".format(response.code), f, l);
    }

    if(json.type != j.JSON_TYPE.OBJECT &&
       "error" !in json.object &&
       "errorMessage" !in json.object) {
        return new YggdrasilException("Yggdrasil responded with unknown json: %s".format(cast(string)response.content), f, l);
    }

    string error = json["error"].str;
    string error_message = json["errorMessage"].str;
    string cause = "cause" in json.object ? json.object["cause"].str : "";

    auto exc = new YggdrasilException("%s: %s%s".format(
        error, error_message,
        cause.length == 0 ? "" : "\n" ~ cause
    ), f, l);
    exc.error = error;
    exc.error_message = error_message;
    exc.cause = cause;

    return exc;
}