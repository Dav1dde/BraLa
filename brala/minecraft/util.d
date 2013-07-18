module brala.minecraft.util;

private {
    import arsd.http : HttpResponse, httpRequest;

    import std.string : format;
    import std.traits : isUnsigned;
    import std.exception : enforceEx;
    import std.range : ElementEncodingType;
    import j = std.json;

    import brala.exception : YggdrasilException;
}


j.JSONValue toJSON(T)(auto ref T arg) {
    j.JSONValue ret;
    static if(is(T : string)) {
        ret.type = j.JSON_TYPE.STRING;
        ret.str = arg;
    } else static if(is(T : ulong) && isUnsigned!T) {
        ret.type = j.JSON_TYPE.UINTEGER;
        ret.uinteger = arg;
    } else static if(is(T : long)) {
        ret.type = j.JSON_TYPE.INTEGER;
        ret.integer = arg;
    } else static if(is(T : Value[Key], Key, Value)) {
        static assert(is(Key : string), "AA key != string");
        ret.type = j.JSON_TYPE.OBJECT;
        static if(is(Value : j.JSONValue)) {
            ret.object = arg;
        } else {
            j.JSONValue[string] aa;
            foreach(key, value; arg) {
                aa[key] = toJSON(value);
            }
            ret.object = aa;
        }
    } else static if(isArray!T) {
        ret.type = j.JSON_TYPE.ARRAY;
        static if(is(ElementEncodingType!T : j.JSONValue)) {
            ret.arg = arg;
        } else {
            j.JSONValue[] new_arg = new j.JSONValue[arg.length];
            foreach(i, e; arg) {
                new_arg[i] = toJSON(e);
            }
            ret.arg = new_arg;
        }
    } else static if(is(T : bool)) {
        if(arg) {
            ret.type = j.JSON_TYPE.TRUE;
        } else {
            ret.type = j.JSON_TYPE.FALSE;
        }
        ret.integer = cast(int)arg;
    } else {
        static assert(false, "unable to convert type to json");
    }
    return ret;
}


string to(T : string)(j.JSONValue value) {
    return j.toJSON(&value);
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