return {
  name = "allay-unicornpkg-compat",
  version = "1.0.0",
  description = "Read unicornpkg-format packages with allay. Install this if you want to use sources written for unicornpkg's hoof.",
  author = "alfa",
  license = "MIT",

  base_url = "https://raw.githubusercontent.com/allaycc/unicornpkg-compat/main",

  files = {
    -- The translator file goes into a special 'translator' kind that allay
    -- knows to look for at /usr/allay/translators/.
    translator = {
      ["init.lua"] = "unicornpkg-compat.lua",
    },
  },
  hashes = {},

  post_install_message = "Reboot or restart allay to activate unicornpkg-format support.",
}
