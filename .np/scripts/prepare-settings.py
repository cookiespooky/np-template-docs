#!/usr/bin/env python3
import json
import os
import re
import shutil
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
NP_DIR = ROOT / ".np"
GENERATED_DIR = NP_DIR / "generated"
SETTINGS_JSON = GENERATED_DIR / "settings.json"


SITE_KEYS = [
    "site_title",
    "site_description",
    "site_language",
    "site_default_og_image",
    "site_icon",
    "brand_name",
    "brand_logo",
    "theme_accent",
    "theme_link",
    "theme_font",
    "theme_heading_font",
    "theme_font_stack",
    "theme_heading_font_stack",
    "theme_font_url",
    "theme_radius",
    "favicon",
    "favicon_16",
    "favicon_32",
    "apple_touch_icon",
    "mask_icon",
    "manifest_icon_192",
    "manifest_icon_512",
    "manifest_name",
    "manifest_short_name",
    "manifest_description",
    "manifest_theme_color",
    "manifest_background_color",
    "manifest_display",
]

INTERFACE_KEYS = [
    "ui_home",
    "ui_documentation_navigation",
    "ui_breadcrumb",
    "ui_open_navigation",
    "ui_close_navigation",
    "ui_search",
    "ui_close",
    "ui_search_placeholder",
    "ui_all_results",
    "ui_search_query",
    "ui_search_no_results",
    "ui_search_no_results_found",
    "ui_search_loading",
    "ui_search_error",
    "ui_next_page",
    "ui_home_hubs_title",
    "ui_hub_materials_title",
    "ui_related_materials_title",
    "ui_not_found_title",
    "ui_not_found_lead",
    "ui_not_found_back",
    "ui_error_title",
    "ui_error_lead",
]

MEDIA_FALLBACKS = {
    "site_default_og_image": "/media/notepub.jpg",
    "site_icon": "/media/notepub.png",
    "brand_logo": "/media/notepub.svg",
}

ASSET_FALLBACKS = {
    "site_default_og_image": "/assets/notepub.jpg",
    "site_icon": "/assets/notepub.png",
    "brand_logo": "/assets/notepub.svg",
    "favicon": "/assets/favicon.ico",
    "favicon_16": "/assets/favicon-16x16.png",
    "favicon_32": "/assets/favicon-32x32.png",
    "apple_touch_icon": "/assets/apple-touch-icon.png",
    "mask_icon": "/assets/notepub.svg",
    "manifest_icon_192": "/assets/android-chrome-192x192.png",
    "manifest_icon_512": "/assets/android-chrome-512x512.png",
}

ICON_OUTPUTS = {
    "site_icon": "site-icon.png",
    "favicon": "favicon.ico",
    "favicon_16": "favicon-16x16.png",
    "favicon_32": "favicon-32x32.png",
    "apple_touch_icon": "apple-touch-icon.png",
    "mask_icon": "notepub.svg",
    "manifest_icon_192": "android-chrome-192x192.png",
    "manifest_icon_512": "android-chrome-512x512.png",
}


def read_text(path):
    try:
        return Path(path).read_text(encoding="utf-8")
    except FileNotFoundError:
        return ""


def strip_quotes(value):
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {"'", '"'}:
        return value[1:-1]
    return value


def parse_simple_yaml_section(text, section):
    out = {}
    lines = text.splitlines()
    in_section = False
    for line in lines:
        if re.match(rf"^{re.escape(section)}:\s*$", line):
            in_section = True
            continue
        if in_section and re.match(r"^[A-Za-z_][A-Za-z0-9_]*:\s*$", line):
            break
        if not in_section:
            continue
        m = re.match(r"^\s{2}([A-Za-z_][A-Za-z0-9_]*):\s*(.*?)\s*(?:#.*)?$", line)
        if m:
            out[m.group(1)] = strip_quotes(m.group(2))
    return {k: v for k, v in out.items() if v != ""}


def extract_frontmatter(text):
    text = text.replace("\r\n", "\n").lstrip("\ufeff")
    if not text.startswith("---\n"):
        return {}, text
    end = text.find("\n---", 4)
    if end < 0:
        return {}, text
    fm = text[4:end]
    body = text[text.find("\n", end + 1) + 1 :]
    props = {}
    for line in fm.splitlines():
        m = re.match(r"^([A-Za-z_][A-Za-z0-9_]*):\s*(.*?)\s*$", line)
        if m:
            props[m.group(1)] = strip_quotes(m.group(2))
    return {k: v for k, v in props.items() if v != ""}, body


def parse_note(path):
    props, _ = extract_frontmatter(read_text(path))
    return props


def yaml_scalar(value):
    return json.dumps(str(value), ensure_ascii=False)


def local_path_for_ref(ref):
    if not isinstance(ref, str) or not ref:
        return None
    if ref.startswith("http://") or ref.startswith("https://"):
        return None
    if ref.startswith("/media/"):
        return ROOT / "media" / ref.removeprefix("/media/")
    if ref.startswith("/assets/"):
        return NP_DIR / "theme" / ref.removeprefix("/")
    return None


def ref_exists(ref):
    if ref.startswith("http://") or ref.startswith("https://"):
        return True
    path = local_path_for_ref(ref)
    return bool(path and path.is_file())


def best_existing(default_media, default_asset):
    if default_media and ref_exists(default_media):
        return default_media
    return default_asset


def sanitize_ref(settings, key):
    value = settings.get(key, "").strip()
    if value and ref_exists(value):
        return value
    media = MEDIA_FALLBACKS.get(key, "")
    asset = ASSET_FALLBACKS.get(key, "")
    if media or asset:
        return best_existing(media, asset)
    return value


def sanitize_color(value, fallback):
    value = str(value or "").strip()
    if re.match(r"^#[0-9a-fA-F]{6}$", value):
        return value
    return fallback


def sanitize_font_stack(value):
    value = str(value or "").strip()
    if not value:
        return ""
    value = value.replace('"', "").replace("'", "")
    if len(value) > 240:
        return ""
    lowered = value.lower()
    blocked = [";", "{", "}", "<", ">", "url(", "@import", "expression(", "\\"]
    if any(token in lowered for token in blocked):
        return ""
    if not re.match(r"^[A-Za-z0-9 _.,\\-]+$", value):
        return ""
    return value


def sanitize_font_url(value):
    value = str(value or "").strip()
    if not value:
        return ""
    if len(value) > 300:
        return ""
    if not value.startswith("https://"):
        return ""
    if any(token in value.lower() for token in ['"', "'", "<", ">", "\\"]):
        return ""
    return value


def font_stack(name):
    name = str(name or "").strip().lower()
    if name == "inter":
        return "Inter, ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif"
    if name == "serif":
        return "Georgia, Cambria, Times New Roman, Times, serif"
    if name == "mono":
        return "ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, Liberation Mono, Courier New, monospace"
    return "ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif"


def public_base_urls(config_text):
    site = parse_simple_yaml_section(config_text, "site")
    base_url = os.environ.get("NOTEPUB_BASE_URL") or site.get("base_url", "http://127.0.0.1:8080/")
    media_base_url = os.environ.get("NOTEPUB_MEDIA_BASE_URL") or site.get("media_base_url", "")
    base_url = base_url.rstrip("/")
    media_base_url = media_base_url.rstrip("/") if media_base_url else base_url + "/media"
    return base_url, media_base_url


def public_ref(ref, base_url, media_base_url):
    if not isinstance(ref, str) or not ref:
        return ref
    if ref.startswith("http://") or ref.startswith("https://"):
        return ref
    if ref.startswith("/media/"):
        return media_base_url + ref.removeprefix("/media")
    if ref.startswith("/assets/"):
        return base_url + ref
    return ref


def default_settings(config_text):
    site = parse_simple_yaml_section(config_text, "site")
    title = site.get("title", "Notepub Docs Template")
    description = site.get("description", "Template repository for documentation websites powered by Notepub.")
    og = site.get("default_og_image", "/media/notepub.jpg")
    return {
        "site_title": title,
        "site_description": description,
        "site_language": "en",
        "site_default_og_image": og,
        "site_icon": "/media/notepub.png",
        "brand_name": title,
        "brand_logo": "/media/notepub.svg",
        "theme_accent": "#0a0a0a",
        "theme_link": "#0a0a0a",
        "theme_font": "system",
        "theme_heading_font": "system",
        "theme_font_stack": font_stack("system"),
        "theme_heading_font_stack": font_stack("system"),
        "theme_font_url": "",
        "theme_radius": "14",
        "favicon": "",
        "favicon_16": "",
        "favicon_32": "",
        "apple_touch_icon": "",
        "mask_icon": "",
        "manifest_icon_192": "",
        "manifest_icon_512": "",
        "manifest_name": "",
        "manifest_short_name": "",
        "manifest_description": "",
        "manifest_theme_color": "",
        "manifest_background_color": "#ffffff",
        "manifest_display": "standalone",
        "ui_home": "Home",
        "ui_documentation_navigation": "Documentation navigation",
        "ui_breadcrumb": "Breadcrumb",
        "ui_open_navigation": "Open navigation",
        "ui_close_navigation": "Close navigation",
        "ui_search": "Search",
        "ui_close": "Close",
        "ui_search_placeholder": "Search documentation",
        "ui_all_results": "All results",
        "ui_search_query": "Query",
        "ui_search_no_results": "No results",
        "ui_search_no_results_found": "No results found.",
        "ui_search_loading": "Loading...",
        "ui_search_error": "Error loading results",
        "ui_next_page": "Next page",
        "ui_home_hubs_title": "Documentation Hubs",
        "ui_hub_materials_title": "Section Materials",
        "ui_related_materials_title": "Related Materials",
        "ui_not_found_title": "Page not found",
        "ui_not_found_lead": "The page no longer exists or was never created.",
        "ui_not_found_back": "Back to Home",
        "ui_error_title": "Error",
        "ui_error_lead": "The template could not render this page. Reason is below.",
    }


def remove_overrides_block(config_text):
    lines = config_text.splitlines()
    out = []
    i = 0
    while i < len(lines):
        if re.match(r"^overrides:\s*$", lines[i]):
            i += 1
            while i < len(lines) and (lines[i].startswith(" ") or lines[i].strip() == ""):
                i += 1
            continue
        out.append(lines[i])
        i += 1
    return "\n".join(out).rstrip() + "\n"


def insert_overrides(config_text):
    block = 'overrides:\n  site_note: "./generated/Site.generated.md"\n  interface_note: "./generated/Interface.generated.md"\n'
    config_text = remove_overrides_block(config_text)
    if "\ncontent:\n" in config_text:
        return config_text.replace("\ncontent:\n", "\n" + block + "content:\n", 1)
    return config_text.rstrip() + "\n" + block


def write_note(path, keys, settings, title, body):
    lines = ["---"]
    for key in keys:
        if key in settings:
            lines.append(f"{key}: {yaml_scalar(settings[key])}")
    lines.extend(["---", "", f"# {title}", "", body, ""])
    path.write_text("\n".join(lines), encoding="utf-8")


def command_notes(config_path):
    config_path = Path(config_path)
    config_text = read_text(config_path)
    settings = default_settings(config_text)
    settings.update(parse_simple_yaml_section(config_text, "settings"))
    settings.update({k: v for k, v in parse_note(ROOT / "Site.md").items() if k in SITE_KEYS})
    settings.update({k: v for k, v in parse_note(ROOT / "Interface.md").items() if k in INTERFACE_KEYS})

    settings["theme_accent"] = sanitize_color(settings.get("theme_accent"), "#0a0a0a")
    settings["theme_link"] = sanitize_color(settings.get("theme_link"), settings["theme_accent"])
    settings["site_icon"] = sanitize_ref(settings, "site_icon")
    settings["manifest_name"] = settings.get("manifest_name") or settings.get("site_title")
    settings["manifest_short_name"] = settings.get("manifest_short_name") or settings.get("brand_name") or settings.get("site_title")
    settings["manifest_description"] = settings.get("manifest_description") or settings.get("site_description")
    settings["manifest_theme_color"] = sanitize_color(settings.get("manifest_theme_color"), settings["theme_accent"])
    settings["manifest_background_color"] = sanitize_color(settings.get("manifest_background_color"), "#ffffff")
    for key in ["favicon_16", "favicon_32", "apple_touch_icon", "manifest_icon_192", "manifest_icon_512"]:
        if not settings.get(key):
            settings[key] = settings["site_icon"]
    if not settings.get("favicon"):
        settings["favicon"] = ASSET_FALLBACKS["favicon"]
    if not settings.get("mask_icon"):
        settings["mask_icon"] = settings.get("brand_logo") or settings["site_icon"]
    for key in ASSET_FALLBACKS:
        settings[key] = sanitize_ref(settings, key)
    custom_font_stack = sanitize_font_stack(settings.get("theme_font_stack"))
    custom_heading_font_stack = sanitize_font_stack(settings.get("theme_heading_font_stack"))
    settings["theme_font_stack"] = custom_font_stack or font_stack(settings.get("theme_font"))
    settings["theme_heading_font_stack"] = custom_heading_font_stack or font_stack(settings.get("theme_heading_font"))
    settings["theme_font_url"] = sanitize_font_url(settings.get("theme_font_url"))

    base_url, media_base_url = public_base_urls(config_text)
    note_settings = dict(settings)
    for key in ASSET_FALLBACKS:
        note_settings[key] = public_ref(settings.get(key, ""), base_url, media_base_url)

    GENERATED_DIR.mkdir(parents=True, exist_ok=True)
    write_note(
        GENERATED_DIR / "Site.generated.md",
        SITE_KEYS,
        note_settings,
        "Generated Site Settings",
        "Generated by `.np/scripts/build.sh`. Edit `Site.md` or `.np/config.yaml` instead.",
    )
    write_note(
        GENERATED_DIR / "Interface.generated.md",
        INTERFACE_KEYS,
        settings,
        "Generated Interface Settings",
        "Generated by `.np/scripts/build.sh`. Edit `Interface.md` or `.np/config.yaml` instead.",
    )
    SETTINGS_JSON.write_text(json.dumps(settings, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    generated_config = NP_DIR / "config.generated.yaml"
    generated_config.write_text(insert_overrides(config_text), encoding="utf-8")
    print(generated_config)


def load_settings():
    try:
        return json.loads(SETTINGS_JSON.read_text(encoding="utf-8"))
    except FileNotFoundError:
        return {}


def parse_base_url(config_path):
    text = read_text(config_path)
    site = parse_simple_yaml_section(text, "site")
    base = os.environ.get("NOTEPUB_BASE_URL") or site.get("base_url", "http://127.0.0.1:8080/")
    return base.rstrip("/")


def absolute_url(base_url, ref):
    if ref.startswith("http://") or ref.startswith("https://"):
        return ref
    if ref.startswith("/"):
        return base_url + ref
    return base_url + "/" + ref


def copy_icon(settings, key, out_assets):
    ref = settings.get(key, ASSET_FALLBACKS.get(key, ""))
    source = local_path_for_ref(ref)
    target_name = ICON_OUTPUTS.get(key)
    if source and source.is_file() and target_name:
        shutil.copyfile(source, out_assets / target_name)


def note_body(path):
    props, body = extract_frontmatter(read_text(path))
    body = body.strip()
    return body


def write_llms(out_dir):
    llms = note_body(ROOT / "LLMS.md")
    llms_full = note_body(ROOT / "LLMS.full.md")
    if llms:
        (out_dir / "llms.txt").write_text(llms + "\n", encoding="utf-8")
    elif (out_dir / "assets" / "llms.txt").is_file():
        shutil.copyfile(out_dir / "assets" / "llms.txt", out_dir / "llms.txt")
    if llms_full:
        (out_dir / "llms-full.txt").write_text(llms_full + "\n", encoding="utf-8")
    elif (out_dir / "assets" / "llms-full.txt").is_file():
        shutil.copyfile(out_dir / "assets" / "llms-full.txt", out_dir / "llms-full.txt")


def command_assets(config_path, out_path):
    settings = load_settings()
    out_dir = Path(out_path)
    out_assets = out_dir / "assets"
    out_assets.mkdir(parents=True, exist_ok=True)
    for key in ICON_OUTPUTS:
        copy_icon(settings, key, out_assets)

    base_url = parse_base_url(config_path)
    manifest = {
        "name": settings.get("manifest_name") or settings.get("site_title") or "Notepub Docs Template",
        "short_name": settings.get("manifest_short_name") or settings.get("brand_name") or "Notepub",
        "description": settings.get("manifest_description") or settings.get("site_description") or "",
        "icons": [
            {
                "src": absolute_url(base_url, "/assets/android-chrome-192x192.png"),
                "sizes": "192x192",
                "type": "image/png",
            },
            {
                "src": absolute_url(base_url, "/assets/android-chrome-512x512.png"),
                "sizes": "512x512",
                "type": "image/png",
            },
        ],
        "theme_color": settings.get("manifest_theme_color") or settings.get("theme_accent") or "#0a0a0a",
        "background_color": settings.get("manifest_background_color") or "#ffffff",
        "display": settings.get("manifest_display") or "standalone",
    }
    (out_assets / "site.webmanifest").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    write_llms(out_dir)


def main():
    if len(sys.argv) < 3:
        print("usage: prepare-settings.py notes <config> | assets <config> <dist>", file=sys.stderr)
        return 2
    command = sys.argv[1]
    if command == "notes":
        command_notes(sys.argv[2])
        return 0
    if command == "assets" and len(sys.argv) == 4:
        command_assets(sys.argv[2], sys.argv[3])
        return 0
    print("usage: prepare-settings.py notes <config> | assets <config> <dist>", file=sys.stderr)
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
