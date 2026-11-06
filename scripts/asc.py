#!/usr/bin/env python3
"""Minimal App Store Connect API client used by scripts/release.sh (stdlib + openssl only).

Auth comes from the environment:
  ASC_KEY_ID, ASC_ISSUER_ID   from App Store Connect > Users and Access > Integrations
  ASC_KEY_PATH                the .p8 key (default ~/.appstoreconnect/private_keys/AuthKey_<id>.p8)

Every subcommand prints its result on stdout and diagnostics on stderr; it exits non-zero on error.
"""
import base64
import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

API = "https://api.appstoreconnect.apple.com"
# appStoreVersion states in which the build and review notes can still be changed
EDITABLE_STATES = {
    "PREPARE_FOR_SUBMISSION", "DEVELOPER_REJECTED", "REJECTED",
    "METADATA_REJECTED", "INVALID_BINARY",
}


def log(msg):
    print(msg, file=sys.stderr)


def die(msg):
    log(f"asc: {msg}")
    sys.exit(1)


def b64url(data):
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()


def der_to_raw(der):
    """Convert openssl's DER ECDSA signature to the raw r||s form JWT ES256 needs."""
    def read_int(buf, i):
        if buf[i] != 0x02:
            raise ValueError("bad DER integer")
        length = buf[i + 1]
        value = buf[i + 2:i + 2 + length].lstrip(b"\x00")
        return value.rjust(32, b"\x00"), i + 2 + length

    if der[0] != 0x30:
        raise ValueError("bad DER sequence")
    i = 3 if der[1] & 0x80 else 2
    r, i = read_int(der, i)
    s, _ = read_int(der, i)
    return r + s


def token():
    key_id = os.environ.get("ASC_KEY_ID") or die("ASC_KEY_ID is not set")
    issuer = os.environ.get("ASC_ISSUER_ID") or die("ASC_ISSUER_ID is not set")
    key_path = os.path.expanduser(os.environ.get(
        "ASC_KEY_PATH", f"~/.appstoreconnect/private_keys/AuthKey_{key_id}.p8"))
    if not os.path.isfile(key_path):
        die(f"API key not found at {key_path}")
    now = int(time.time())
    header = b64url(json.dumps({"alg": "ES256", "kid": key_id, "typ": "JWT"}).encode())
    payload = b64url(json.dumps({
        "iss": issuer, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1",
    }).encode())
    signing_input = f"{header}.{payload}".encode()
    der = subprocess.run(
        ["openssl", "dgst", "-sha256", "-sign", key_path],
        input=signing_input, capture_output=True, check=True).stdout
    return f"{header}.{payload}.{b64url(der_to_raw(der))}"


def call(method, path, body=None, params=None):
    url = API + path
    if params:
        url += "?" + urllib.parse.urlencode(params)
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method, headers={
        "Authorization": f"Bearer {token()}", "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            raw = resp.read()
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as e:
        detail = e.read().decode(errors="replace")
        die(f"{method} {path} -> HTTP {e.code}: {detail[:800]}")


def app_id(bundle_id):
    data = call("GET", "/v1/apps", params={"filter[bundleId]": bundle_id})["data"]
    if not data:
        die(f"no app with bundle id {bundle_id}")
    print(data[0]["id"])


def version(app, version_string):
    """Print '<id> <state>' of the iOS App Store version, failing if it can't be edited."""
    data = call("GET", f"/v1/apps/{app}/appStoreVersions", params={
        "filter[platform]": "IOS", "filter[versionString]": version_string})["data"]
    if not data:
        die(f"no App Store version {version_string}; create it in App Store Connect first")
    attrs = data[0]["attributes"]
    state = attrs.get("appStoreState") or attrs.get("appVersionState")
    print(data[0]["id"], state)
    if state not in EDITABLE_STATES:
        die(f"version {version_string} is {state}; its build can't be changed now")


def builds(app, version_string):
    return call("GET", "/v1/builds", params={
        "filter[app]": app, "filter[preReleaseVersion.version]": version_string,
        "fields[builds]": "version,processingState", "limit": 200})["data"]


def next_build(app, version_string, local):
    """Print a build number higher than both the local one and any already uploaded."""
    uploaded = [int(b["attributes"]["version"]) for b in builds(app, version_string)
                if b["attributes"]["version"].isdigit()]
    print(max(uploaded + [int(local)]) + 1)


def wait_build(app, version_string, number, timeout_min="60"):
    """Wait until the uploaded build has processed, then print its id."""
    deadline = time.time() + int(timeout_min) * 60
    while time.time() < deadline:
        for b in builds(app, version_string):
            if b["attributes"]["version"] == str(number):
                state = b["attributes"]["processingState"]
                if state == "VALID":
                    print(b["id"])
                    return
                if state in ("FAILED", "INVALID"):
                    die(f"build {number} processing ended as {state}")
                log(f"asc: build {number} is {state}, waiting...")
                break
        else:
            log(f"asc: build {number} not visible yet, waiting...")
        time.sleep(30)
    die(f"build {number} did not finish processing in {timeout_min} minutes")


def attach_build(version_id, build_id):
    call("PATCH", f"/v1/appStoreVersions/{version_id}/relationships/build",
         {"data": {"type": "builds", "id": build_id}})
    log(f"asc: build {build_id} attached to version {version_id}")


def set_notes(version_id, notes_file):
    with open(notes_file, encoding="utf-8") as f:
        notes = f.read().strip()
    detail = call("GET", f"/v1/appStoreVersions/{version_id}/appStoreReviewDetail").get("data")
    if detail:
        call("PATCH", f"/v1/appStoreReviewDetails/{detail['id']}", {"data": {
            "type": "appStoreReviewDetails", "id": detail["id"],
            "attributes": {"notes": notes}}})
    else:
        call("POST", "/v1/appStoreReviewDetails", {"data": {
            "type": "appStoreReviewDetails", "attributes": {"notes": notes},
            "relationships": {"appStoreVersion": {
                "data": {"type": "appStoreVersions", "id": version_id}}}}})
    log("asc: review notes updated")


def list_iap(app):
    """Print the app's in-app purchases (read-only; removal stays a manual decision)."""
    data = call("GET", f"/v1/apps/{app}/inAppPurchasesV2", params={"limit": 200})["data"]
    for item in data:
        a = item["attributes"]
        print(f"{a.get('productId')}\t{a.get('state')}\t{a.get('name')}")


def submit(app, version_id):
    """Add the version to an open review submission (or a new one) and submit it."""
    open_subs = call("GET", "/v1/reviewSubmissions", params={
        "filter[app]": app, "filter[platform]": "IOS",
        "filter[state]": "READY_FOR_REVIEW,UNRESOLVED_ISSUES,WAITING_FOR_REVIEW,IN_REVIEW",
    })["data"]
    busy = [s for s in open_subs if s["attributes"]["state"] in ("WAITING_FOR_REVIEW", "IN_REVIEW")]
    if busy:
        die(f"a submission is already {busy[0]['attributes']['state']}; nothing to do")
    if open_subs:
        sub_id = open_subs[0]["id"]
    else:
        sub_id = call("POST", "/v1/reviewSubmissions", {"data": {
            "type": "reviewSubmissions", "attributes": {"platform": "IOS"},
            "relationships": {"app": {"data": {"type": "apps", "id": app}}}}})["data"]["id"]
    items = call("GET", f"/v1/reviewSubmissions/{sub_id}/items",
                 params={"include": "appStoreVersion"})
    has_version = any(
        (i.get("relationships", {}).get("appStoreVersion", {}).get("data") or {}).get("id")
        == version_id for i in items.get("data", []))
    if not has_version:
        call("POST", "/v1/reviewSubmissionItems", {"data": {
            "type": "reviewSubmissionItems", "relationships": {
                "reviewSubmission": {"data": {"type": "reviewSubmissions", "id": sub_id}},
                "appStoreVersion": {"data": {"type": "appStoreVersions", "id": version_id}}}}})
    call("PATCH", f"/v1/reviewSubmissions/{sub_id}", {"data": {
        "type": "reviewSubmissions", "id": sub_id, "attributes": {"submitted": True}}})
    log(f"asc: submitted for review (submission {sub_id})")


COMMANDS = {
    "app-id": app_id, "version": version, "next-build": next_build,
    "wait-build": wait_build, "attach-build": attach_build, "set-notes": set_notes,
    "list-iap": list_iap, "submit": submit,
}

if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] not in COMMANDS:
        die(f"usage: asc.py <{'|'.join(COMMANDS)}> args...")
    COMMANDS[sys.argv[1]](*sys.argv[2:])
