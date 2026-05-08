-- allay-unicornpkg-compat: translator for unicornpkg-format packages.
--
-- Registers itself with allay's translator registry. After this package
-- is installed, sources whose `index.lua` declares `format = "unicornpkg/v1.0.0"`
-- are read using this translator.

local M = {}

M.format_name = "unicornpkg/v1.0.0"

-- Provider URL builders for the most common unicornpkg pkgTypes.
local PROVIDERS = {
  ["com.github"] = function(d)
    return string.format("https://raw.githubusercontent.com/%s/%s/%s",
      d.repo_owner, d.repo_name, d.repo_ref or "main")
  end,
  ["com.github.release"] = function(d)
    return string.format("https://github.com/%s/%s/releases/download/%s",
      d.repo_owner, d.repo_name, d.repo_ref)
  end,
  ["com.github.gist"] = function(d)
    return string.format("https://gist.githubusercontent.com/%s/%s/raw",
      d.gist_owner or d.repo_owner, d.gist_id or d.repo_name)
  end,
  ["com.pastebin"] = function(_)
    return "https://pastebin.com/raw"
  end,
}

-- Categorize a destination path into one of allay's file kinds.
local function categorize(dest)
  local function strip(prefix)
    return (dest:gsub("^" .. prefix:gsub("([^%w])", "%%%1"), ""))
  end

  if dest:match("^/bin/") then
    local name = strip("/bin/")
    return "bin", (name:gsub("%.lua$", ""))
  end
  if dest:match("^/lib/")              then return "lib",     strip("/lib/")              end
  if dest:match("^/usr/lib/")          then return "lib",     strip("/usr/lib/")          end
  if dest:match("^/usr/libexec/")      then return "libexec", strip("/usr/libexec/")      end
  if dest:match("^/usr/libLoadAPI/")   then return "loadapi", strip("/usr/libLoadAPI/")   end
  if dest:match("^/usr/share/help/")   then return "help",    strip("/usr/share/help/")   end
  if dest:match("^/etc/startup/")      then return "startup", strip("/etc/startup/")      end
  if dest:match("^/startup/")          then return "startup", strip("/startup/")          end
  if dest:match("^/etc/")              then return "etc",     strip("/etc/")              end

  -- Compatibility kind: install at the literal absolute path.
  return "raw", dest
end

-- Translate a unicornpkg-format package table into allay's internal model.
function M.translate(raw)
  if type(raw) ~= "table" or not raw.unicornSpec then
    return nil, "not a unicornpkg package"
  end

  local result = {
    name = raw.name,
    version = raw.version,
    description = raw.desc,
    author = raw.maintainer,
    license = raw.licensing,
  }

  -- Resolve base_url from pkgType + instdat.
  local pkgType = raw.pkgType
  if not pkgType then return nil, "package missing pkgType" end
  local builder = PROVIDERS[pkgType]
  if not builder then
    return nil, "pkgType not supported by allay-unicornpkg-compat: " .. pkgType
  end
  result.base_url = builder(raw.instdat or {})

  -- Convert filemaps into structured files.
  result.files = {}
  if raw.instdat and raw.instdat.filemaps then
    for src, dest in pairs(raw.instdat.filemaps) do
      local kind, dest_name = categorize(dest)
      result.files[kind] = result.files[kind] or {}
      result.files[kind][src] = dest_name
    end
  end

  -- Hashes.
  if raw.security and raw.security.sha256 then
    result.hashes = {}
    for src, h in pairs(raw.security.sha256) do
      result.hashes[src] = h
    end
  end

  -- Dependencies and conflicts.
  if raw.rel then
    if raw.rel.depends then
      result.dependencies = {}
      for _, d in ipairs(raw.rel.depends) do
        table.insert(result.dependencies, d)
      end
    end
    if raw.rel.conflicts then
      result.conflicts = {}
      for _, c in ipairs(raw.rel.conflicts) do
        table.insert(result.conflicts, c)
      end
    end
  end

  -- Hooks: skipped with a notice. Setup ceremonies in unicornpkg packages
  -- are usually trivial; the README usually documents what to do.
  if raw.script then
    result._hooks_skipped = {}
    for k, _ in pairs(raw.script) do
      table.insert(result._hooks_skipped, k)
    end
  end

  return result
end

return M
