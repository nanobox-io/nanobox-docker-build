if boxfile[:plugin] do
  # verify engine is specified
  exit HOOKIT::ABORT unless boxfile[:engine]

  # download and prepare plugin/engine
  execute "nanobox-cli fetch #{boxfile[:plugin]}"
end
